package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"math/rand"
	"net/http"
	"os"
	"strings"
	"time"

	"gymates-backend/config"
	"gymates-backend/models"
)

// AITrainingPlanService AI训练计划生成服务
type AITrainingPlanService struct {
	llmAPIKey    string
	llmAPIURL    string
	llmProvider  string // "openai", "anthropic", "zhipu", "tongyi"
	httpClient   *http.Client
}

// NewAITrainingPlanService 创建AI训练计划服务
func NewAITrainingPlanService() *AITrainingPlanService {
	// 从环境变量读取LLM配置
	// 优先级：DeepSeek > OpenAI > Anthropic > 智谱AI > 通义千问
	apiKey := os.Getenv("DEEPSEEK_API_KEY")
	if apiKey == "" {
		apiKey = os.Getenv("LLM_API_KEY")
	}
	if apiKey == "" {
		apiKey = os.Getenv("OPENAI_API_KEY")
	}
	if apiKey == "" {
		apiKey = os.Getenv("ZHIPU_API_KEY")
	}
	
	provider := os.Getenv("LLM_PROVIDER")
	if provider == "" {
		// 如果有DeepSeek密钥，默认使用DeepSeek
		if os.Getenv("DEEPSEEK_API_KEY") != "" {
			provider = "deepseek"
		} else {
			provider = "openai"
		}
	}

	apiURL := os.Getenv("LLM_API_URL")
	if apiURL == "" {
		switch provider {
		case "deepseek":
			apiURL = "https://api.deepseek.com/v1/chat/completions"
		case "openai":
			apiURL = "https://api.openai.com/v1/chat/completions"
		case "anthropic":
			apiURL = "https://api.anthropic.com/v1/messages"
		case "zhipu":
			apiURL = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
		case "tongyi":
			apiURL = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation"
		default:
			apiURL = "https://api.openai.com/v1/chat/completions"
		}
	}

	return &AITrainingPlanService{
		llmAPIKey:   apiKey,
		llmAPIURL:   apiURL,
		llmProvider: provider,
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// GeneratePersonalizedPlan 生成个性化训练计划
func (s *AITrainingPlanService) GeneratePersonalizedPlan(userID uint, preferences models.UserTrainingPreferences) (*models.WeeklyTrainingPlan, error) {
	// 1. 获取用户训练历史
	history := s.getUserTrainingHistory(userID)
	
	// 2. 获取用户体能数据
	userProfile := s.getUserProfile(userID)
	
	// 3. 从动作库获取可用动作
	var exerciseLibrary []models.ExerciseLibrary
	config.DB.Where("level = ?", s.mapExperienceToLevel(preferences.Experience)).
		Order("RANDOM()").
		Limit(50).
		Find(&exerciseLibrary)
	
	// 4. 使用LLM生成训练计划
	planData, err := s.generatePlanWithLLM(userProfile, preferences, history, exerciseLibrary)
	if err != nil {
		// 如果LLM失败，使用规则引擎生成
		fmt.Printf("⚠️ LLM生成失败，使用规则引擎: %v\n", err)
		planData = s.generatePlanWithRules(preferences, exerciseLibrary)
	}
	
	// 5. 保存到数据库
	plan := s.savePlanToDatabase(userID, planData)
	
	return plan, nil
}

// generatePlanWithLLM 使用LLM生成训练计划
func (s *AITrainingPlanService) generatePlanWithLLM(
	userProfile models.User,
	preferences models.UserTrainingPreferences,
	history []models.UserTrainingHistory,
	exerciseLibrary []models.ExerciseLibrary,
) (map[string]interface{}, error) {
	// 构建提示词
	prompt := s.buildTrainingPlanPrompt(userProfile, preferences, history, exerciseLibrary)
	
	// 调用LLM API
	response, err := s.callLLMAPI(prompt)
	if err != nil {
		return nil, err
	}
	
	// 解析LLM响应
	planData := s.parseLLMResponse(response)
	
	return planData, nil
}

// buildTrainingPlanPrompt 构建训练计划提示词
func (s *AITrainingPlanService) buildTrainingPlanPrompt(
	userProfile models.User,
	preferences models.UserTrainingPreferences,
	history []models.UserTrainingHistory,
	exerciseLibrary []models.ExerciseLibrary,
) string {
	// 构建动作库列表
	exerciseList := ""
	for i, ex := range exerciseLibrary {
		exerciseList += fmt.Sprintf("%d. %s (部位: %s, 难度: %s, 器械: %s)\n", 
			i+1, ex.Name, ex.Part, ex.Level, ex.Equipment)
	}
	
	// 构建训练历史
	historyStr := ""
	if len(history) > 0 {
		historyStr = fmt.Sprintf("最近训练了 %d 次，主要部位: ", len(history))
		muscleGroups := make(map[string]int)
		for _, h := range history {
			muscleGroups[h.MuscleGroup]++
		}
		for group, count := range muscleGroups {
			historyStr += fmt.Sprintf("%s(%d次) ", group, count)
		}
	} else {
		historyStr = "暂无训练历史"
	}
	
	prompt := fmt.Sprintf(`你是一位专业的AI健身教练，请根据以下用户信息生成一周训练计划：

【用户信息】
- 性别: %s
- 年龄: %d 岁
- 体重: %.1f kg
- 身高: %.1f cm
- 训练目标: %s
- 训练经验: %s
- 每周训练频率: %d 次
- 偏好训练部位: %s
- 当前体重: %.1f kg
- 目标体重: %.1f kg

【训练历史】
%s

【可用动作库】
%s

【要求】
1. 根据用户目标(%s)生成一周训练计划
2. 每周训练 %d 次，合理分配到一周7天
3. 每次训练选择 4-6 个动作
4. 为每个动作指定：组数(sets)、次数(reps)、重量(weight)、休息时间(rest_seconds)
5. 考虑训练经验(%s)调整训练强度
6. 优先选择用户偏好部位(%s)
7. 确保训练计划科学、安全、有效

【输出格式】(严格按照JSON格式输出)
{
  "plan_name": "训练计划名称",
  "description": "计划描述",
  "days": [
    {
      "day_name": "Monday",
      "day_of_week": 1,
      "is_rest_day": false,
      "parts": [
        {
          "muscle_group": "chest",
          "muscle_group_name": "胸部",
          "exercises": [
            {
              "name": "动作名称",
              "sets": 3,
              "reps": 12,
              "weight": 50.0,
              "rest_seconds": 90,
              "description": "动作描述",
              "notes": "注意事项"
            }
          ]
        }
      ]
    }
  ]
}

请直接输出JSON，不要包含任何其他文字说明。`,
		userProfile.Gender,
		userProfile.Age,
		preferences.CurrentWeight,
		userProfile.Height,
		preferences.Goal,
		preferences.Experience,
		preferences.Frequency,
		preferences.PreferredParts,
		preferences.CurrentWeight,
		preferences.TargetWeight,
		historyStr,
		exerciseList,
		preferences.Goal,
		preferences.Frequency,
		preferences.Experience,
		preferences.PreferredParts,
	)
	
	return prompt
}

// callLLMAPI 调用LLM API
func (s *AITrainingPlanService) callLLMAPI(prompt string) (string, error) {
	if s.llmAPIKey == "" {
		return "", fmt.Errorf("LLM API密钥未配置")
	}
	
	var reqBody interface{}
	var headers map[string]string
	
	switch s.llmProvider {
	case "deepseek":
		reqBody = map[string]interface{}{
			"model": "deepseek-chat",
			"messages": []map[string]interface{}{
				{"role": "system", "content": "你是一位专业的AI健身教练，擅长制定个性化训练计划。"},
				{"role": "user", "content": prompt},
			},
			"temperature": 0.7,
			"max_tokens": 2000,
		}
		headers = map[string]string{
			"Content-Type":  "application/json",
			"Authorization": fmt.Sprintf("Bearer %s", s.llmAPIKey),
		}
		
	case "openai":
		reqBody = map[string]interface{}{
			"model": "gpt-3.5-turbo",
			"messages": []map[string]interface{}{
				{"role": "system", "content": "你是一位专业的AI健身教练，擅长制定个性化训练计划。"},
				{"role": "user", "content": prompt},
			},
			"temperature": 0.7,
			"max_tokens": 2000,
		}
		headers = map[string]string{
			"Content-Type":  "application/json",
			"Authorization": fmt.Sprintf("Bearer %s", s.llmAPIKey),
		}
		
	case "zhipu":
		reqBody = map[string]interface{}{
			"model": "glm-4",
			"messages": []map[string]interface{}{
				{"role": "system", "content": "你是一位专业的AI健身教练，擅长制定个性化训练计划。"},
				{"role": "user", "content": prompt},
			},
			"temperature": 0.7,
			"max_tokens": 2000,
		}
		headers = map[string]string{
			"Content-Type":  "application/json",
			"Authorization": fmt.Sprintf("Bearer %s", s.llmAPIKey),
		}
		
	case "anthropic":
		reqBody = map[string]interface{}{
			"model": "claude-3-sonnet-20240229",
			"messages": []map[string]interface{}{
				{"role": "user", "content": prompt},
			},
			"max_tokens": 2000,
		}
		headers = map[string]string{
			"Content-Type":      "application/json",
			"x-api-key":         s.llmAPIKey,
			"anthropic-version": "2023-06-01",
		}
		
	default:
		return "", fmt.Errorf("不支持的LLM提供商: %s", s.llmProvider)
	}
	
	// 序列化请求体
	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return "", fmt.Errorf("序列化请求失败: %v", err)
	}
	
	// 创建HTTP请求
	req, err := http.NewRequest("POST", s.llmAPIURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", fmt.Errorf("创建请求失败: %v", err)
	}
	
	// 设置请求头
	for key, value := range headers {
		req.Header.Set(key, value)
	}
	
	// 发送请求
	resp, err := s.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("请求LLM API失败: %v", err)
	}
	defer resp.Body.Close()
	
	// 读取响应
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("读取响应失败: %v", err)
	}
	
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("LLM API返回错误: %d, %s", resp.StatusCode, string(body))
	}
	
	// 解析响应
	var result map[string]interface{}
	if err := json.Unmarshal(body, &result); err != nil {
		return "", fmt.Errorf("解析响应失败: %v", err)
	}
	
	// 提取内容
	content := ""
	switch s.llmProvider {
	case "deepseek", "openai", "zhipu":
		if choices, ok := result["choices"].([]interface{}); ok && len(choices) > 0 {
			if choice, ok := choices[0].(map[string]interface{}); ok {
				if message, ok := choice["message"].(map[string]interface{}); ok {
					content = message["content"].(string)
				}
			}
		}
	case "anthropic":
		if contentArray, ok := result["content"].([]interface{}); ok && len(contentArray) > 0 {
			if contentObj, ok := contentArray[0].(map[string]interface{}); ok {
				content = contentObj["text"].(string)
			}
		}
	}
	
	if content == "" {
		return "", fmt.Errorf("无法从LLM响应中提取内容")
	}
	
	return content, nil
}

// parseLLMResponse 解析LLM响应
func (s *AITrainingPlanService) parseLLMResponse(response string) map[string]interface{} {
	// 尝试从响应中提取JSON
	jsonStart := strings.Index(response, "{")
	jsonEnd := strings.LastIndex(response, "}")
	
	if jsonStart == -1 || jsonEnd == -1 {
		return nil
	}
	
	jsonStr := response[jsonStart : jsonEnd+1]
	
	var planData map[string]interface{}
	if err := json.Unmarshal([]byte(jsonStr), &planData); err != nil {
		fmt.Printf("解析LLM响应失败: %v\n", err)
		return nil
	}
	
	return planData
}

// generatePlanWithRules 使用规则引擎生成训练计划（备用方案）
func (s *AITrainingPlanService) generatePlanWithRules(
	preferences models.UserTrainingPreferences,
	exerciseLibrary []models.ExerciseLibrary,
) map[string]interface{} {
	days := []map[string]interface{}{}
	
	// 根据训练频率分配训练日
	trainingDays := s.allocateTrainingDays(preferences.Frequency)
	
	// 为每个训练日生成训练内容
	for dayIdx, dayOfWeek := range trainingDays {
		dayName := s.getDayName(dayOfWeek)
		
		// 根据目标选择训练部位
		muscleGroups := s.selectMuscleGroupsForDay(preferences.Goal, dayIdx, preferences.Frequency)
		
		parts := []map[string]interface{}{}
		for _, muscleGroup := range muscleGroups {
			// 为每个部位选择动作
			exercises := s.selectExercisesForMuscleGroup(muscleGroup, exerciseLibrary, preferences)
			
			if len(exercises) > 0 {
				parts = append(parts, map[string]interface{}{
					"muscle_group":      muscleGroup,
					"muscle_group_name": s.getMuscleGroupName(muscleGroup),
					"exercises":         exercises,
				})
			}
		}
		
		days = append(days, map[string]interface{}{
			"day_name":    dayName,
			"day_of_week": dayOfWeek,
			"is_rest_day": false,
			"parts":       parts,
		})
	}
	
	// 添加休息日
	for i := 1; i <= 7; i++ {
		isTrainingDay := false
		for _, day := range trainingDays {
			if day == i {
				isTrainingDay = true
				break
			}
		}
		if !isTrainingDay {
			days = append(days, map[string]interface{}{
				"day_name":    s.getDayName(i),
				"day_of_week": i,
				"is_rest_day": true,
				"parts":       []map[string]interface{}{},
			})
		}
	}
	
	return map[string]interface{}{
		"plan_name":   fmt.Sprintf("%s训练计划", preferences.Goal),
		"description": fmt.Sprintf("基于您的目标(%s)和训练经验(%s)定制的训练计划", preferences.Goal, preferences.Experience),
		"days":        days,
	}
}

// 辅助方法

func (s *AITrainingPlanService) getUserTrainingHistory(userID uint) []models.UserTrainingHistory {
	var history []models.UserTrainingHistory
	config.DB.Where("user_id = ? AND completed_at > ?", userID, time.Now().AddDate(0, 0, -30)).
		Order("completed_at DESC").
		Limit(20).
		Find(&history)
	return history
}

func (s *AITrainingPlanService) getUserProfile(userID uint) models.User {
	var user models.User
	config.DB.First(&user, userID)
	return user
}

func (s *AITrainingPlanService) mapExperienceToLevel(experience string) string {
	switch experience {
	case "初级":
		return "beginner"
	case "中级":
		return "intermediate"
	case "高级":
		return "advanced"
	default:
		return "intermediate"
	}
}

func (s *AITrainingPlanService) calculateAge(birthday *time.Time) int {
	if birthday == nil {
		return 25 // 默认年龄
	}
	return int(time.Since(*birthday).Hours() / 24 / 365)
}

func (s *AITrainingPlanService) allocateTrainingDays(frequency int) []int {
	// 根据训练频率分配训练日
	switch frequency {
	case 3:
		return []int{1, 3, 5} // 周一、周三、周五
	case 4:
		return []int{1, 2, 4, 5} // 周一、周二、周四、周五
	case 5:
		return []int{1, 2, 3, 4, 5} // 周一到周五
	case 6:
		return []int{1, 2, 3, 4, 5, 6} // 周一到周六
	default:
		return []int{1, 3, 5} // 默认3天
	}
}

func (s *AITrainingPlanService) getDayName(dayOfWeek int) string {
	days := []string{"", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}
	if dayOfWeek >= 1 && dayOfWeek <= 7 {
		return days[dayOfWeek]
	}
	return "Monday"
}

func (s *AITrainingPlanService) selectMuscleGroupsForDay(goal string, dayIndex int, frequency int) []string {
	// 根据目标和训练频率选择肌群
	if frequency == 3 {
		switch dayIndex {
		case 0:
			return []string{"chest", "triceps"}
		case 1:
			return []string{"back", "biceps"}
		case 2:
			return []string{"legs", "shoulders"}
		}
	} else if frequency == 4 {
		switch dayIndex {
		case 0:
			return []string{"chest"}
		case 1:
			return []string{"back"}
		case 2:
			return []string{"legs"}
		case 3:
			return []string{"shoulders", "arms"}
		}
	}
	
	// 默认返回
	allGroups := []string{"chest", "back", "legs", "shoulders", "arms", "core"}
	return []string{allGroups[dayIndex%len(allGroups)]}
}

func (s *AITrainingPlanService) selectExercisesForMuscleGroup(
	muscleGroup string,
	exerciseLibrary []models.ExerciseLibrary,
	preferences models.UserTrainingPreferences,
) []map[string]interface{} {
	exercises := []map[string]interface{}{}
	
	// 从动作库中筛选该肌群的动作
	for _, ex := range exerciseLibrary {
		if strings.Contains(strings.ToLower(ex.Part), muscleGroup) {
			// 根据目标调整训练参数
			sets, reps, weight, restSeconds := s.calculateTrainingParameters(preferences.Goal, preferences.Experience)
			
			exercises = append(exercises, map[string]interface{}{
				"name":         ex.Name,
				"sets":         sets,
				"reps":         reps,
				"weight":       weight * preferences.CurrentWeight * 0.01, // 体重百分比
				"rest_seconds": restSeconds,
				"description":  ex.Description,
				"notes":        ex.Description,
			})
			
			// 每个肌群选择3-4个动作
			if len(exercises) >= 4 {
				break
			}
		}
	}
	
	return exercises
}

func (s *AITrainingPlanService) calculateTrainingParameters(goal string, experience string) (int, int, float64, int) {
	// 根据目标和经验调整训练参数
	var sets, reps, restSeconds int
	var weight float64
	
	switch goal {
	case "增肌":
		sets = 3 + rand.Intn(2)      // 3-4组
		reps = 8 + rand.Intn(5)      // 8-12次
		weight = 60 + float64(rand.Intn(20)) // 60-80%
		restSeconds = 90 + rand.Intn(30)     // 90-120秒
	case "减脂":
		sets = 3
		reps = 15 + rand.Intn(10)    // 15-25次
		weight = 40 + float64(rand.Intn(20)) // 40-60%
		restSeconds = 30 + rand.Intn(20)     // 30-50秒
	case "力量":
		sets = 4 + rand.Intn(2)      // 4-5组
		reps = 4 + rand.Intn(4)      // 4-8次
		weight = 75 + float64(rand.Intn(15)) // 75-90%
		restSeconds = 120 + rand.Intn(60)    // 120-180秒
	default:
		sets = 3
		reps = 10 + rand.Intn(5)     // 10-15次
		weight = 50 + float64(rand.Intn(20)) // 50-70%
		restSeconds = 60 + rand.Intn(30)     // 60-90秒
	}
	
	// 根据经验调整
	if experience == "初级" {
		weight *= 0.8
		restSeconds += 30
	} else if experience == "高级" {
		weight *= 1.2
		restSeconds -= 15
	}
	
	return sets, reps, weight, restSeconds
}

func (s *AITrainingPlanService) getMuscleGroupName(muscleGroup string) string {
	names := map[string]string{
		"chest":     "胸部",
		"back":      "背部",
		"legs":      "腿部",
		"shoulders": "肩部",
		"arms":      "手臂",
		"biceps":    "二头肌",
		"triceps":   "三头肌",
		"core":      "核心",
	}
	if name, ok := names[muscleGroup]; ok {
		return name
	}
	return muscleGroup
}

func (s *AITrainingPlanService) savePlanToDatabase(userID uint, planData map[string]interface{}) *models.WeeklyTrainingPlan {
	// 开始事务
	tx := config.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()
	
	// 停用用户的其他计划
	tx.Model(&models.WeeklyTrainingPlan{}).Where("user_id = ?", userID).Update("is_active", false)
	
	// 创建新计划
	plan := models.WeeklyTrainingPlan{
		UserID:      userID,
		Name:        planData["plan_name"].(string),
		Description: planData["description"].(string),
		IsActive:    true,
		IsPublic:    false,
	}
	
	if err := tx.Create(&plan).Error; err != nil {
		tx.Rollback()
		return nil
	}
	
	// 创建训练日
	if days, ok := planData["days"].([]interface{}); ok {
		for _, dayData := range days {
			day := dayData.(map[string]interface{})
			
			trainingDay := models.TrainingDay{
				WeeklyTrainingPlanID: plan.ID,
				DayOfWeek:            int(day["day_of_week"].(float64)),
				DayName:              day["day_name"].(string),
				IsRestDay:            day["is_rest_day"].(bool),
			}
			
			if err := tx.Create(&trainingDay).Error; err != nil {
				tx.Rollback()
				return nil
			}
			
			// 创建训练部位和动作
			if parts, ok := day["parts"].([]interface{}); ok {
				for _, partData := range parts {
					part := partData.(map[string]interface{})
					
					trainingPart := models.TrainingPart{
						TrainingDayID:   trainingDay.ID,
						MuscleGroup:     part["muscle_group"].(string),
						MuscleGroupName: part["muscle_group_name"].(string),
						Order:           0,
					}
					
					if err := tx.Create(&trainingPart).Error; err != nil {
						tx.Rollback()
						return nil
					}
					
					// 创建动作
					if exercises, ok := part["exercises"].([]interface{}); ok {
						for _, exData := range exercises {
							ex := exData.(map[string]interface{})
							
							exercise := models.Exercise{
								TrainingPlanID: plan.ID,
								TrainingPartID: &trainingPart.ID,
								Name:           ex["name"].(string),
								Description:    s.getStringValue(ex, "description"),
								MuscleGroup:    part["muscle_group"].(string),
								Sets:           int(ex["sets"].(float64)),
								Reps:           int(ex["reps"].(float64)),
								Weight:         ex["weight"].(float64),
								RestSeconds:    int(ex["rest_seconds"].(float64)),
								Notes:          s.getStringValue(ex, "notes"),
								Order:          0,
							}
							
							if err := tx.Create(&exercise).Error; err != nil {
								tx.Rollback()
								return nil
							}
						}
					}
				}
			}
		}
	}
	
	// 提交事务
	if err := tx.Commit().Error; err != nil {
		return nil
	}
	
	// 重新加载完整数据
	config.DB.Preload("Days.Parts.Exercises").First(&plan, plan.ID)
	
	return &plan
}

func (s *AITrainingPlanService) getStringValue(data map[string]interface{}, key string) string {
	if val, ok := data[key]; ok {
		if str, ok := val.(string); ok {
			return str
		}
	}
	return ""
}

