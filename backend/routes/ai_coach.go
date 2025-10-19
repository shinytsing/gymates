package routes

import (
	"gymates-backend/controllers"
	"gymates-backend/middleware"

	"github.com/gin-gonic/gin"
)

// SetupAICoachRoutes 设置AI教练相关路由
func SetupAICoachRoutes(router *gin.RouterGroup) {
	aiCoachController := controllers.NewAICoachController()

	// AI教练路由组
	aiGroup := router.Group("/ai")
	{
		// AI教练聊天接口
		aiGroup.POST("/coach", middleware.OptionalAuthMiddleware(), aiCoachController.CoachChat)

		// 训练进度上报接口
		aiGroup.POST("/progress", middleware.OptionalAuthMiddleware(), aiCoachController.TrainingProgress)

		// 获取AI服务状态
		aiGroup.GET("/status", aiCoachController.GetServiceStatus)

		// 切换AI服务提供商
		aiGroup.POST("/switch-provider", aiCoachController.SwitchProvider)
	}
}
