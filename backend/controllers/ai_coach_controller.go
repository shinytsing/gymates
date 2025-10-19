package controllers

import (
	"net/http"
	"strconv"
	"time"

	"gymates-backend/services"

	"github.com/gin-gonic/gin"
)

// AICoachController AI教练控制器
type AICoachController struct{}

// CoachChatRequest AI教练聊天请求
type CoachChatRequest struct {
	UserID  int                    `json:"user_id" binding:"required"`
	Message string                 `json:"message" binding:"required"`
	Context map[string]interface{} `json:"context,omitempty"`
}

// CoachChatResponse AI教练聊天响应
type CoachChatResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	Data    struct {
		Response string `json:"response"`
		Speak    bool   `json:"speak"`
	} `json:"data"`
}

// TrainingProgressRequest 训练进度请求
type TrainingProgressRequest struct {
	UserID             int    `json:"user_id" binding:"required"`
	PlanID             string `json:"plan_id"`
	CompletedAt        string `json:"completed_at"`
	ExercisesCompleted int    `json:"exercises_completed"`
	Duration           int    `json:"duration"` // 训练时长（分钟）
	CaloriesBurned     int    `json:"calories_burned"`
	Notes              string `json:"notes"`
}

// TrainingProgressResponse 训练进度响应
type TrainingProgressResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	Data    struct {
		ProgressID    string `json:"progress_id"`
		TotalWorkouts int    `json:"total_workouts"`
		Streak        int    `json:"streak"`
		Level         int    `json:"level"`
	} `json:"data"`
}

// AIServiceStatusResponse AI服务状态响应
type AIServiceStatusResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	Data    struct {
		CurrentProvider      string          `json:"current_provider"`
		AvailableProviders   []string        `json:"available_providers"`
		ServiceStatus        map[string]bool `json:"service_status"`
		ServicePriority      map[string]int  `json:"service_priority"`
		ServicesWithPriority []struct {
			Provider  string `json:"provider"`
			Priority  int    `json:"priority"`
			Available bool   `json:"available"`
		} `json:"services_with_priority"`
	} `json:"data"`
}

// SwitchProviderRequest 切换提供商请求
type SwitchProviderRequest struct {
	Provider string `json:"provider" binding:"required"`
}

// NewAICoachController 创建AI教练控制器
func NewAICoachController() *AICoachController {
	return &AICoachController{}
}

// CoachChat AI教练聊天接口
func (c *AICoachController) CoachChat(ctx *gin.Context) {
	var req CoachChatRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "请求参数错误",
			"error":   err.Error(),
		})
		return
	}

	// 获取AI服务管理器
	aiManager := services.GetAIManager()
	if aiManager == nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "AI服务未初始化",
		})
		return
	}

	// 构建聊天消息
	messages := []services.ChatMessage{
		{
			Role:    "system",
			Content: c.buildSystemPrompt(req.Context),
		},
		{
			Role:    "user",
			Content: req.Message,
		},
	}

	// 发送到AI服务
	response, err := aiManager.Chat(messages)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "AI服务请求失败",
			"error":   err.Error(),
		})
		return
	}

	// 解析响应
	var aiResponse string
	var shouldSpeak bool = false

	if len(response.Choices) > 0 {
		aiResponse = response.Choices[0].Message.Content
		// 根据响应内容决定是否需要语音播报
		shouldSpeak = c.shouldSpeak(aiResponse)
	}

	// 返回响应
	ctx.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "AI教练回复成功",
		"data": gin.H{
			"response": aiResponse,
			"speak":    shouldSpeak,
		},
	})
}

// TrainingProgress 训练进度上报接口
func (c *AICoachController) TrainingProgress(ctx *gin.Context) {
	var req TrainingProgressRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "请求参数错误",
			"error":   err.Error(),
		})
		return
	}

	// 解析完成时间
	completedAt, err := time.Parse(time.RFC3339, req.CompletedAt)
	if err != nil {
		completedAt = time.Now()
	}

	// 使用completedAt变量（避免未使用错误）
	_ = completedAt

	// 这里应该保存到数据库，暂时返回模拟数据
	progressID := "progress_" + strconv.FormatInt(time.Now().Unix(), 10)

	// 计算用户等级和连续训练天数（模拟）
	totalWorkouts := 15 // 从数据库获取
	streak := 7         // 从数据库获取
	level := (totalWorkouts / 10) + 1

	resp := TrainingProgressResponse{
		Success: true,
		Message: "训练进度保存成功",
		Data: struct {
			ProgressID    string `json:"progress_id"`
			TotalWorkouts int    `json:"total_workouts"`
			Streak        int    `json:"streak"`
			Level         int    `json:"level"`
		}{
			ProgressID:    progressID,
			TotalWorkouts: totalWorkouts,
			Streak:        streak,
			Level:         level,
		},
	}

	ctx.JSON(http.StatusOK, resp)
}

// GetServiceStatus 获取AI服务状态
func (c *AICoachController) GetServiceStatus(ctx *gin.Context) {
	aiManager := services.GetAIManager()
	if aiManager == nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "AI服务未初始化",
		})
		return
	}

	// 获取服务状态
	currentProvider := aiManager.GetCurrentProvider()
	availableProviders := aiManager.GetAvailableProviders()
	serviceStatus := aiManager.GetServiceStatus()
	servicePriority := aiManager.GetServicePriority()
	servicesWithPriority := aiManager.GetAvailableServicesWithPriority()

	// 转换为字符串数组
	var availableProvidersStr []string
	for _, provider := range availableProviders {
		availableProvidersStr = append(availableProvidersStr, string(provider))
	}

	// 转换为字符串键的map
	serviceStatusStr := make(map[string]bool)
	for provider, status := range serviceStatus {
		serviceStatusStr[string(provider)] = status
	}

	// 转换优先级信息
	servicePriorityStr := make(map[string]int)
	for provider, priority := range servicePriority {
		servicePriorityStr[provider] = priority
	}

	// 转换服务优先级信息
	var servicesWithPriorityStr []struct {
		Provider  string `json:"provider"`
		Priority  int    `json:"priority"`
		Available bool   `json:"available"`
	}
	for _, service := range servicesWithPriority {
		servicesWithPriorityStr = append(servicesWithPriorityStr, struct {
			Provider  string `json:"provider"`
			Priority  int    `json:"priority"`
			Available bool   `json:"available"`
		}{
			Provider:  service.Provider,
			Priority:  service.Priority,
			Available: service.Available,
		})
	}

	resp := AIServiceStatusResponse{
		Success: true,
		Message: "获取服务状态成功",
		Data: struct {
			CurrentProvider      string          `json:"current_provider"`
			AvailableProviders   []string        `json:"available_providers"`
			ServiceStatus        map[string]bool `json:"service_status"`
			ServicePriority      map[string]int  `json:"service_priority"`
			ServicesWithPriority []struct {
				Provider  string `json:"provider"`
				Priority  int    `json:"priority"`
				Available bool   `json:"available"`
			} `json:"services_with_priority"`
		}{
			CurrentProvider:      string(currentProvider),
			AvailableProviders:   availableProvidersStr,
			ServiceStatus:        serviceStatusStr,
			ServicePriority:      servicePriorityStr,
			ServicesWithPriority: servicesWithPriorityStr,
		},
	}

	ctx.JSON(http.StatusOK, resp)
}

// SwitchProvider 切换AI服务提供商
func (c *AICoachController) SwitchProvider(ctx *gin.Context) {
	var req SwitchProviderRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "请求参数错误",
			"error":   err.Error(),
		})
		return
	}

	aiManager := services.GetAIManager()
	if aiManager == nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "AI服务未初始化",
		})
		return
	}

	// 切换提供商
	err := aiManager.SwitchProvider(services.AIProvider(req.Provider))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "切换提供商失败",
			"error":   err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "切换提供商成功",
		"data": gin.H{
			"current_provider": string(aiManager.GetCurrentProvider()),
		},
	})
}

// buildSystemPrompt 构建系统提示词
func (c *AICoachController) buildSystemPrompt(context map[string]interface{}) string {
	systemPrompt := `你是一位专业的AI健身教练，具备以下特点：

1. 专业知识：
- 精通各种健身动作和训练方法
- 了解人体解剖学和运动生理学
- 熟悉不同训练计划的制定和执行

2. 教练风格：
- 专业、耐心、鼓励性
- 根据用户水平提供个性化建议
- 注重安全性和正确性

3. 回复要求：
- 回答要简洁明了，易于理解
- 提供具体的动作指导
- 给出合理的训练建议
- 适当使用鼓励性语言

4. 特殊情况处理：
- 如果用户询问非健身相关问题，礼貌地引导回健身话题
- 如果用户提到身体不适，建议咨询专业医生
- 根据用户训练状态调整回复内容

请用中文回复，语气要专业而友好。`

	// 根据上下文调整提示词
	if context != nil {
		if trainingPlan, ok := context["training_plan"]; ok {
			systemPrompt += "\n\n当前用户训练计划：" + c.formatTrainingPlan(trainingPlan)
		}
		if currentExercise, ok := context["current_exercise"]; ok {
			systemPrompt += "\n\n当前训练动作：" + c.formatCurrentExercise(currentExercise)
		}
		if trainingState, ok := context["training_state"]; ok {
			systemPrompt += "\n\n训练状态：" + c.formatTrainingState(trainingState)
		}
	}

	return systemPrompt
}

// shouldSpeak 判断是否需要语音播报
func (c *AICoachController) shouldSpeak(response string) bool {
	// 包含以下关键词的回复需要语音播报
	speakKeywords := []string{
		"开始", "准备", "倒计时", "休息", "完成", "恭喜", "加油", "很好", "继续",
		"下一组", "下一个动作", "训练结束", "辛苦了", "干得漂亮",
	}

	for _, keyword := range speakKeywords {
		if len(response) > 0 && len(keyword) > 0 {
			// 简单的字符串包含检查
			for i := 0; i <= len(response)-len(keyword); i++ {
				if response[i:i+len(keyword)] == keyword {
					return true
				}
			}
		}
	}

	return false
}

// formatTrainingPlan 格式化训练计划
func (c *AICoachController) formatTrainingPlan(plan interface{}) string {
	if planMap, ok := plan.(map[string]interface{}); ok {
		if name, exists := planMap["name"]; exists {
			return "训练计划：" + name.(string)
		}
	}
	return "无训练计划"
}

// formatCurrentExercise 格式化当前动作
func (c *AICoachController) formatCurrentExercise(exercise interface{}) string {
	if exerciseMap, ok := exercise.(map[string]interface{}); ok {
		if name, exists := exerciseMap["name"]; exists {
			return "当前动作：" + name.(string)
		}
	}
	return "无当前动作"
}

// formatTrainingState 格式化训练状态
func (c *AICoachController) formatTrainingState(state interface{}) string {
	if stateStr, ok := state.(string); ok {
		switch stateStr {
		case "idle":
			return "待开始"
		case "running":
			return "训练中"
		case "paused":
			return "已暂停"
		default:
			return "未知状态"
		}
	}
	return "无状态信息"
}
