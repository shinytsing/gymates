package controllers

import (
	"net/http"

	"gymates-backend/services"

	"github.com/gin-gonic/gin"
)

// AIChatController AI聊天控制器
type AIChatController struct {
	deepseekService *services.DeepSeekService
}

// NewAIChatController 创建AI聊天控制器
func NewAIChatController() *AIChatController {
	return &AIChatController{
		deepseekService: services.NewDeepSeekService(),
	}
}

// ChatRequest 聊天请求
type ChatRequest struct {
	Message      string                 `json:"message" binding:"required"`
	SystemPrompt string                 `json:"system_prompt,omitempty"`
	Messages     []services.ChatMessage `json:"messages,omitempty"`
}

// ChatResponse 聊天响应
type ChatResponse struct {
	Response string `json:"response"`
	Success  bool   `json:"success"`
	Message  string `json:"message,omitempty"`
}

// FitnessAdviceRequest 健身建议请求
type FitnessAdviceRequest struct {
	Age        int     `json:"age"`
	Height     float64 `json:"height"`
	Weight     float64 `json:"weight"`
	Goal       string  `json:"goal"`
	Experience string  `json:"experience"`
}

// WorkoutPlanRequest 训练计划请求
type WorkoutPlanRequest struct {
	Goal     string `json:"goal" binding:"required"`
	Level    string `json:"level" binding:"required"`
	Duration int    `json:"duration" binding:"required"`
}

// Chat 处理聊天请求
// @Summary AI聊天
// @Description 与AI进行对话
// @Tags AI
// @Accept json
// @Produce json
// @Param request body ChatRequest true "聊天请求"
// @Success 200 {object} ChatResponse
// @Router /api/ai/chat [post]
func (c *AIChatController) Chat(ctx *gin.Context) {
	var req ChatRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, ChatResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	// 如果提供了完整的消息历史，使用上下文聊天
	var response string
	var err error

	if len(req.Messages) > 0 {
		response, err = c.deepseekService.ChatWithContext(req.Messages)
	} else {
		response, err = c.deepseekService.GenerateResponse(req.Message, req.SystemPrompt)
	}

	if err != nil {
		ctx.JSON(http.StatusInternalServerError, ChatResponse{
			Success: false,
			Message: "Failed to generate response: " + err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, ChatResponse{
		Success:  true,
		Response: response,
	})
}

// GetFitnessAdvice 获取健身建议
// @Summary 获取健身建议
// @Description 根据用户信息生成个性化健身建议
// @Tags AI
// @Accept json
// @Produce json
// @Param request body FitnessAdviceRequest true "健身建议请求"
// @Success 200 {object} ChatResponse
// @Router /api/ai/fitness-advice [post]
func (c *AIChatController) GetFitnessAdvice(ctx *gin.Context) {
	var req FitnessAdviceRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, ChatResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	userProfile := map[string]interface{}{
		"age":        req.Age,
		"height":     req.Height,
		"weight":     req.Weight,
		"goal":       req.Goal,
		"experience": req.Experience,
	}

	advice, err := c.deepseekService.GenerateFitnessAdvice(userProfile)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, ChatResponse{
			Success: false,
			Message: "Failed to generate advice: " + err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, ChatResponse{
		Success:  true,
		Response: advice,
	})
}

// GenerateWorkoutPlan 生成训练计划
// @Summary 生成训练计划
// @Description 根据目标、水平和时长生成训练计划
// @Tags AI
// @Accept json
// @Produce json
// @Param request body WorkoutPlanRequest true "训练计划请求"
// @Success 200 {object} ChatResponse
// @Router /api/ai/workout-plan [post]
func (c *AIChatController) GenerateWorkoutPlan(ctx *gin.Context) {
	var req WorkoutPlanRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, ChatResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	plan, err := c.deepseekService.GenerateWorkoutPlan(req.Goal, req.Level, req.Duration)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, ChatResponse{
			Success: false,
			Message: "Failed to generate plan: " + err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, ChatResponse{
		Success:  true,
		Response: plan,
	})
}

// AnalyzeWorkoutForm 分析动作姿势
// @Summary 分析动作姿势
// @Description 分析用户的动作执行情况
// @Tags AI
// @Accept json
// @Produce json
// @Success 200 {object} ChatResponse
// @Router /api/ai/analyze-form [post]
func (c *AIChatController) AnalyzeWorkoutForm(ctx *gin.Context) {
	var req struct {
		ExerciseName string `json:"exercise_name" binding:"required"`
		Description  string `json:"description" binding:"required"`
	}

	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, ChatResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	analysis, err := c.deepseekService.AnalyzeWorkoutForm(req.ExerciseName, req.Description)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, ChatResponse{
			Success: false,
			Message: "Failed to analyze form: " + err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, ChatResponse{
		Success:  true,
		Response: analysis,
	})
}

// GetNutritionAdvice 获取营养建议
// @Summary 获取营养建议
// @Description 根据目标和体重生成营养建议
// @Tags AI
// @Accept json
// @Produce json
// @Success 200 {object} ChatResponse
// @Router /api/ai/nutrition-advice [post]
func (c *AIChatController) GetNutritionAdvice(ctx *gin.Context) {
	var req struct {
		Goal          string  `json:"goal" binding:"required"`
		Weight        float64 `json:"weight" binding:"required"`
		ActivityLevel string  `json:"activity_level" binding:"required"`
	}

	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, ChatResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	advice, err := c.deepseekService.GenerateNutritionAdvice(req.Goal, req.Weight, req.ActivityLevel)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, ChatResponse{
			Success: false,
			Message: "Failed to generate advice: " + err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, ChatResponse{
		Success:  true,
		Response: advice,
	})
}
