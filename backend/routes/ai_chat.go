package routes

import (
	"gymates-backend/controllers"
	"gymates-backend/middleware"

	"github.com/gin-gonic/gin"
)

// SetupAIChatRoutes 设置AI聊天路由
func SetupAIChatRoutes(api *gin.RouterGroup) {
	aiChatController := controllers.NewAIChatController()

	ai := api.Group("/ai")
	{
		// 基础聊天接口
		ai.POST("/chat", middleware.AuthMiddleware(), aiChatController.Chat)

		// 健身建议
		ai.POST("/fitness-advice", middleware.AuthMiddleware(), aiChatController.GetFitnessAdvice)

		// 生成训练计划
		ai.POST("/workout-plan", middleware.AuthMiddleware(), aiChatController.GenerateWorkoutPlan)

		// 分析动作姿势
		ai.POST("/analyze-form", middleware.AuthMiddleware(), aiChatController.AnalyzeWorkoutForm)

		// 营养建议
		ai.POST("/nutrition-advice", middleware.AuthMiddleware(), aiChatController.GetNutritionAdvice)
	}
}

