package services

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"time"

	"gymates-backend/config"
	"gymates-backend/models"

	"github.com/sashabaranov/go-openai"
	"gorm.io/gorm"
)

// AICoachService AI教练服务
type AICoachService struct {
	db            *gorm.DB
	trainingService *TrainingService
	aiClient      *openai.Client
}

// NewAICoachService 创建AI教练服务
func NewAICoachService() *AICoachService {
	var aiClient *openai.Client
	apiKey := os.Getenv("OPENAI_API_KEY")
	if apiKey != "" {
		aiClient = openai.NewClient(apiKey)
	}
	
	return &AICoachService{
		db:              config.DB,
		trainingService: NewTrainingService(),
		aiClient:        aiClient,
	}
}

// GenerateWorkoutPlan 生成AI训练计划
func (s *AICoachService) GenerateWorkoutPlan(userID uint, preferences map[string]interface{}) (*models.TrainingPlanV2, error) {
	// 获取用户信息
	var user models.User
	if err := s.db.First(&user, userID).Error; err != nil {
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	// 获取用户统计
	stats, err := s.trainingService.GetUserStats(userID)
	if err != nil {
		return nil, fmt.Errorf("failed to get user stats: %w", err)
	}

	// 获取最近训练历史
	recentHistories, _, err := s.trainingService.GetTrainingHistory(userID, nil, nil, 1, 10)
	if err != nil {
		return nil, fmt.Errorf("failed to get training history: %w", err)
	}

	// 构建AI提示词
	prompt := s.buildWorkoutPlanPrompt(&user, stats, recentHistories, preferences)

	// 调用AI生成计划
	planData, err := s.callAIForPlan(prompt)
	if err != nil {
		return nil, fmt.Errorf("failed to generate AI plan: %w", err)
	}

	// 创建训练计划
	plan := &models.TrainingPlanV2{
		UserID:        userID,
		Name:          planData.Name,
		Description:   planData.Description,
		Difficulty:    planData.Difficulty,
		Goal:          planData.Goal,
		IsAIGenerated: true,
		IsPublic:      false,
	}

	// 添加运动项
	exercises, err := s.convertAIExercisesToPlanExercises(planData.Exercises)
	if err != nil {
		return nil, fmt.Errorf("failed to convert exercises: %w", err)
	}
	plan.Exercises = exercises

	// 保存计划
	if err := s.trainingService.CreateTrainingPlan(plan); err != nil {
		return nil, fmt.Errorf("failed to create plan: %w", err)
	}

	return plan, nil
}

// GetRealtimeFeedback 获取实时训练反馈
func (s *AICoachService) GetRealtimeFeedback(userID uint, exerciseName string, currentSet, targetSets int, performance map[string]interface{}) (string, error) {
	// 构建反馈提示词
	prompt := fmt.Sprintf(`
你是一位专业的健身教练。用户正在进行 %s 训练。

当前状态:
- 已完成组数: %d/%d
- 表现数据: %v

请提供简短的实时反馈和鼓励 (不超过50字):
`, exerciseName, currentSet, targetSets, performance)

	// 调用AI
	feedback, err := s.callAIForFeedback(prompt)
	if err != nil {
		// 如果AI调用失败,返回预设反馈
		return s.getFallbackFeedback(currentSet, targetSets), nil
	}

	return feedback, nil
}

// AdjustWorkoutIntensity 动态调整训练强度
func (s *AICoachService) AdjustWorkoutIntensity(userID uint, sessionID uint, currentPerformance map[string]interface{}) (map[string]interface{}, error) {
	// 获取会话信息
	var session models.WorkoutSessionV2
	if err := s.db.Preload("Plan.Exercises.Exercise").First(&session, sessionID).Error; err != nil {
		return nil, err
	}

	// 分析表现
	analysis := s.analyzePerformance(currentPerformance)

	adjustments := make(map[string]interface{})
	
	// 根据表现调整
	if analysis["difficulty"] == "too_easy" {
		adjustments["recommendation"] = "增加重量或组数"
		adjustments["weight_increase"] = 2.5 // kg
		adjustments["rest_decrease"] = 10    // seconds
	} else if analysis["difficulty"] == "too_hard" {
		adjustments["recommendation"] = "降低重量或减少组数"
		adjustments["weight_decrease"] = 2.5
		adjustments["rest_increase"] = 15
	} else {
		adjustments["recommendation"] = "保持当前强度"
		adjustments["message"] = "你的表现很好!继续保持!"
	}

	return adjustments, nil
}

// GenerateMotivationalMessage 生成激励消息
func (s *AICoachService) GenerateMotivationalMessage(userID uint, context string) (string, error) {
	// 获取用户统计
	stats, err := s.trainingService.GetUserStats(userID)
	if err != nil {
		return "", err
	}

	prompt := fmt.Sprintf(`
生成一条简短的健身激励消息 (不超过30字)。

用户信息:
- 总训练次数: %d
- 连续训练天数: %d
- 场景: %s

要求: 积极向上、个性化、简短有力
`, stats.TotalWorkouts, stats.CurrentStreak, context)

	message, err := s.callAIForFeedback(prompt)
	if err != nil {
		return s.getDefaultMotivationalMessage(context), nil
	}

	return message, nil
}

// AnalyzeWorkoutForm 分析动作姿势 (预留接口,需要视觉AI)
func (s *AICoachService) AnalyzeWorkoutForm(userID uint, exerciseID uint, videoData []byte) (map[string]interface{}, error) {
	// TODO: 集成姿势识别AI (如 MediaPipe, TensorFlow Lite)
	// 这里返回模拟数据
	return map[string]interface{}{
		"overall_score": 85,
		"feedback": []string{
			"背部姿势良好",
			"建议膝盖稍微弯曲",
		},
		"corrections": []string{
			"保持核心收紧",
		},
	}, nil
}

// ==================== 私有辅助方法 ====================

// buildWorkoutPlanPrompt 构建训练计划提示词
func (s *AICoachService) buildWorkoutPlanPrompt(user *models.User, stats *models.UserTrainingStats, history []models.TrainingHistory, preferences map[string]interface{}) string {
	historyStr := "无"
	if len(history) > 0 {
		historyStr = fmt.Sprintf("最近完成了 %d 次训练", len(history))
	}

	goal := user.Goal
	if goal == "" {
		goal = "增肌"
	}

	level := user.Experience
	if level == "" {
		level = "初级"
	}

	return fmt.Sprintf(`
你是一位专业的健身教练。请为用户生成一个个性化的训练计划。

用户信息:
- 年龄: %d
- 身高: %.1f cm
- 体重: %.1f kg
- 健身目标: %s
- 健身水平: %s
- 训练历史: %s
- 连续训练天数: %d

用户偏好:
%v

请生成一个训练计划,包含以下JSON格式:
{
  "name": "计划名称",
  "description": "计划描述",
  "difficulty": "beginner/intermediate/advanced",
  "goal": "目标",
  "exercises": [
    {
      "name": "运动名称",
      "muscle_group": "目标肌群",
      "sets": 组数,
      "reps": 次数,
      "rest_time": 休息时间(秒),
      "notes": "注意事项"
    }
  ]
}
`, user.Age, user.Height, user.Weight, goal, level, historyStr, stats.CurrentStreak, preferences)
}

// callAIForPlan 调用AI生成计划
func (s *AICoachService) callAIForPlan(prompt string) (*AIPlanData, error) {
	if s.aiClient == nil {
		// 如果AI客户端未初始化,返回默认计划
		return s.getDefaultPlan(), nil
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	resp, err := s.aiClient.CreateChatCompletion(ctx, openai.ChatCompletionRequest{
		Model: openai.GPT3Dot5Turbo,
		Messages: []openai.ChatCompletionMessage{
			{
				Role:    openai.ChatMessageRoleSystem,
				Content: "你是一位专业的健身教练,擅长制定个性化训练计划。",
			},
			{
				Role:    openai.ChatMessageRoleUser,
				Content: prompt,
			},
		},
		Temperature: 0.7,
	})

	if err != nil {
		return s.getDefaultPlan(), nil
	}

	// 解析AI响应
	var planData AIPlanData
	if err := json.Unmarshal([]byte(resp.Choices[0].Message.Content), &planData); err != nil {
		return s.getDefaultPlan(), nil
	}

	return &planData, nil
}

// callAIForFeedback 调用AI获取反馈
func (s *AICoachService) callAIForFeedback(prompt string) (string, error) {
	if s.aiClient == nil {
		return "", fmt.Errorf("AI client not initialized")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	resp, err := s.aiClient.CreateChatCompletion(ctx, openai.ChatCompletionRequest{
		Model: openai.GPT3Dot5Turbo,
		Messages: []openai.ChatCompletionMessage{
			{
				Role:    openai.ChatMessageRoleSystem,
				Content: "你是一位热情的健身教练,提供简短有力的反馈和鼓励。",
			},
			{
				Role:    openai.ChatMessageRoleUser,
				Content: prompt,
			},
		},
		Temperature: 0.8,
		MaxTokens:   100,
	})

	if err != nil {
		return "", err
	}

	return resp.Choices[0].Message.Content, nil
}

// convertAIExercisesToPlanExercises 转换AI运动到计划运动
func (s *AICoachService) convertAIExercisesToPlanExercises(aiExercises []AIExercise) ([]models.PlanExerciseV2, error) {
	var planExercises []models.PlanExerciseV2

	for i, aiEx := range aiExercises {
		// 在运动库中查找匹配的运动
		var exercise models.ExerciseLibrary
		err := s.db.Where("name LIKE ?", "%"+aiEx.Name+"%").First(&exercise).Error
		if err != nil {
			// 如果找不到,跳过
			continue
		}

		planEx := models.PlanExerciseV2{
			ExerciseID: exercise.ID,
			Sets:       aiEx.Sets,
			Reps:       aiEx.Reps,
			RestTime:   aiEx.RestTime,
			Order:      i + 1,
			Notes:      aiEx.Notes,
		}
		planExercises = append(planExercises, planEx)
	}

	return planExercises, nil
}

// analyzePerformance 分析表现
func (s *AICoachService) analyzePerformance(performance map[string]interface{}) map[string]interface{} {
	// 简单的表现分析逻辑
	completionRate, _ := performance["completion_rate"].(float64)
	
	analysis := make(map[string]interface{})
	
	if completionRate > 0.95 {
		analysis["difficulty"] = "too_easy"
	} else if completionRate < 0.7 {
		analysis["difficulty"] = "too_hard"
	} else {
		analysis["difficulty"] = "appropriate"
	}
	
	return analysis
}

// getFallbackFeedback 获取备用反馈
func (s *AICoachService) getFallbackFeedback(currentSet, targetSets int) string {
	progress := float64(currentSet) / float64(targetSets)
	
	if progress < 0.3 {
		return "很好的开始!保持节奏,继续加油! 💪"
	} else if progress < 0.7 {
		return "做得不错!已经完成一半了,坚持住! 🔥"
	} else {
		return "最后冲刺!你能行的,加油! 🚀"
	}
}

// getDefaultMotivationalMessage 获取默认激励消息
func (s *AICoachService) getDefaultMotivationalMessage(context string) string {
	messages := map[string]string{
		"start":    "开始训练!让我们一起创造不可能! 💪",
		"middle":   "坚持就是胜利!你已经很棒了! 🔥",
		"end":      "完成得太棒了!为自己骄傲! 🎉",
		"rest":     "休息是为了走更远的路! 😌",
		"struggle": "困难只是暂时的,你比你想象的更强! 💪",
	}
	
	if msg, ok := messages[context]; ok {
		return msg
	}
	return "相信自己,你可以做到! 💪"
}

// getDefaultPlan 获取默认计划
func (s *AICoachService) getDefaultPlan() *AIPlanData {
	return &AIPlanData{
		Name:        "AI推荐全身训练",
		Description: "适合初学者的全面训练计划",
		Difficulty:  "beginner",
		Goal:        "strength",
		Exercises: []AIExercise{
			{
				Name:        "深蹲",
				MuscleGroup: "legs",
				Sets:        3,
				Reps:        12,
				RestTime:    60,
				Notes:       "保持背部挺直,膝盖不超过脚尖",
			},
			{
				Name:        "俯卧撑",
				MuscleGroup: "chest",
				Sets:        3,
				Reps:        10,
				RestTime:    60,
				Notes:       "身体保持一条直线",
			},
			{
				Name:        "平板支撑",
				MuscleGroup: "abs",
				Sets:        3,
				Reps:        30,
				RestTime:    45,
				Notes:       "保持核心收紧",
			},
		},
	}
}

// ==================== 数据结构 ====================

// AIPlanData AI计划数据
type AIPlanData struct {
	Name        string       `json:"name"`
	Description string       `json:"description"`
	Difficulty  string       `json:"difficulty"`
	Goal        string       `json:"goal"`
	Exercises   []AIExercise `json:"exercises"`
}

// AIExercise AI运动数据
type AIExercise struct {
	Name        string `json:"name"`
	MuscleGroup string `json:"muscle_group"`
	Sets        int    `json:"sets"`
	Reps        int    `json:"reps"`
	RestTime    int    `json:"rest_time"`
	Notes       string `json:"notes"`
}

