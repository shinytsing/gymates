package routes

import (
	"net/http"

	"gymates-backend/controllers"
	"gymates-backend/middleware"

	"github.com/gin-gonic/gin"
)

// SetupRoutes 设置路由
func SetupRoutes(r *gin.Engine) {
	// 健康检查
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "healthy",
			"timestamp": "2024-01-01T00:00:00Z",
			"version":   "1.0.0",
		})
	})

	// API路由组
	api := r.Group("/api")
	{
		// 认证路由
		auth := api.Group("/auth")
		{
			authController := controllers.NewAuthController()
			auth.POST("/login", authController.Login)
			auth.POST("/register", authController.Register)
			auth.GET("/me", middleware.AuthMiddleware(), authController.GetCurrentUser)
			auth.PUT("/profile", middleware.AuthMiddleware(), authController.UpdateProfile)
			auth.POST("/logout", middleware.AuthMiddleware(), authController.Logout)
		}

		// 用户路由
		users := api.Group("/users")
		{
			authController := controllers.NewAuthController()
			users.GET("/:id", authController.GetUserProfile)
		}

		// 首页路由
		SetupHomeRoutes(api)

		// 训练路由
		SetupTrainingRoutes(api)

		// 社区路由
		SetupCommunityRoutes(api)

		// 搭子路由
		SetupMatesRoutes(api)

		// 消息路由
		SetupMessagesRoutes(api)

		// 用户资料路由
		SetupProfileRoutes(api)

		// 详情路由
		SetupDetailRoutes(api)
		SetupPostDetailRoutes(api)
		SetupProfileDetailRoutes(api)
		SetupChatDetailRoutes(api)
		SetupAchievementDetailRoutes(api)
		SetupTrainingDetailRoutes(api)
		SetupMatesDetailRoutes(api)

		// AI教练路由
		SetupAICoachRoutes(api)
	}
}
