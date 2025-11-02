package api

import (
	"net/http"

	"gymates-backend/api/handlers"
	"gymates-backend/api/middlewares"
	"gymates-backend/controllers"

	"github.com/gin-gonic/gin"
)

// SetupAPIRoutes sets up all API routes with the new modular structure
func SetupAPIRoutes(r *gin.Engine) {
	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "healthy",
			"timestamp": "2024-01-01T00:00:00Z",
			"version":   "2.0.0",
		})
	})

	// API route group
	api := r.Group("/api")
	{
		// Initialize handlers
		authHandler := handlers.NewAuthHandler()
		communityHandler := handlers.NewCommunityHandler()
		trainingHandler := handlers.NewTrainingHandler()
		matesHandler := handlers.NewMatesHandler()
		messagesHandler := handlers.NewMessagesHandler()

		// Authentication routes
		auth := api.Group("/auth")
		{
			// Basic auth
			auth.POST("/login", authHandler.Login)
			auth.POST("/register", authHandler.Register)
			auth.GET("/me", middlewares.AuthMiddleware(), authHandler.GetCurrentUser)
			auth.PUT("/profile", middlewares.AuthMiddleware(), authHandler.UpdateProfile)
			auth.POST("/logout", middlewares.AuthMiddleware(), authHandler.Logout)

			// Enhanced auth (phone, social login, etc.)
			enhancedAuthController := controllers.NewEnhancedAuthController()
			auth.POST("/send-code", enhancedAuthController.SendVerificationCode)
			auth.POST("/phone/login", enhancedAuthController.PhoneLogin)
			auth.POST("/phone/register", enhancedAuthController.PhoneRegister)
			auth.POST("/social/login", enhancedAuthController.SocialLogin)
			auth.POST("/guest/login", enhancedAuthController.GuestLogin)
			auth.POST("/refresh", enhancedAuthController.RefreshToken)
			auth.POST("/revoke", middlewares.AuthMiddleware(), enhancedAuthController.RevokeToken)
		}

		// User routes
		users := api.Group("/users")
		{
			users.GET("/:id", authHandler.GetUserProfile)
		}

		// Community routes
		community := api.Group("/community")
		{
			community.GET("/posts", communityHandler.GetPosts)
			community.GET("/posts/:id", communityHandler.GetPost)
			community.POST("/posts", middlewares.AuthMiddleware(), communityHandler.CreatePost)
			community.PUT("/posts/:id", middlewares.AuthMiddleware(), communityHandler.UpdatePost)
			community.DELETE("/posts/:id", middlewares.AuthMiddleware(), communityHandler.DeletePost)
			community.POST("/posts/:id/like", middlewares.AuthMiddleware(), communityHandler.LikePost)
			community.DELETE("/posts/:id/like", middlewares.AuthMiddleware(), communityHandler.UnlikePost)
		}

		// Training routes
		training := api.Group("/training")
		{
			training.GET("/plans", trainingHandler.GetTrainingPlans)
			training.GET("/plans/:id", trainingHandler.GetTrainingPlan)
			training.POST("/plans", middlewares.AuthMiddleware(), trainingHandler.CreateTrainingPlan)
			training.PUT("/plans/:id", middlewares.AuthMiddleware(), trainingHandler.UpdateTrainingPlan)
			training.DELETE("/plans/:id", middlewares.AuthMiddleware(), trainingHandler.DeleteTrainingPlan)
		}

		// Mates routes
		mates := api.Group("/mates")
		mates.Use(middlewares.AuthMiddleware())
		{
			mates.GET("", matesHandler.GetMates)
			mates.GET("/pending", matesHandler.GetPendingRequests)
			mates.GET("/find", matesHandler.FindPotentialMates)
			mates.POST("/request", matesHandler.SendMateRequest)
			mates.POST("/:id/accept", matesHandler.AcceptMateRequest)
			mates.POST("/:id/reject", matesHandler.RejectMateRequest)
		}

		// Messages routes
		messages := api.Group("/messages")
		messages.Use(middlewares.AuthMiddleware())
		{
			messages.GET("/conversations", messagesHandler.GetConversations)
			messages.GET("/conversations/:userId", messagesHandler.GetMessages)
			messages.POST("/send", messagesHandler.SendMessage)
			messages.POST("/mark-read", messagesHandler.MarkAsRead)
			messages.GET("/unread-count", messagesHandler.GetUnreadCount)
		}

		// Keep existing routes from old structure for backward compatibility
		// These will be gradually migrated to the new structure
		
		// Home routes (using old controller temporarily)
		setupHomeRoutes(api)

		// Training routes - extended (using old controller temporarily)
		setupExtendedTrainingRoutes(api)

		// Notifications routes
		setupNotificationRoutes(r)

		// Profile routes
		setupProfileRoutes(api)

		// Detail routes
		setupDetailRoutes(api)

		// AI Coach routes
		setupAICoachRoutes(api)

		// AI Chat routes
		setupAIChatRoutes(api)

		// Map routes
		setupMapRoutes(api)

		// WebSocket routes
		setupWebSocketRoutes(api)
	}
}

// Temporary functions to maintain backward compatibility with old routes
// These should be gradually migrated to the new handler structure

func setupHomeRoutes(api *gin.RouterGroup) {
	homeController := controllers.NewHomeController()
	home := api.Group("/home")
	{
		home.GET("", middlewares.OptionalAuthMiddleware(), homeController.GetHomeList)
		home.GET("/list", middlewares.OptionalAuthMiddleware(), homeController.GetHomeList)
	}
}

func setupExtendedTrainingRoutes(api *gin.RouterGroup) {
	trainingController := controllers.NewTrainingController()
	training := api.Group("/training")
	training.Use(middlewares.AuthMiddleware())
	{
		training.GET("/list", trainingController.GetTrainingPlans)
	}
}

func setupNotificationRoutes(r *gin.Engine) {
	notificationController := controllers.NewNotificationsController()
	api := r.Group("/api/notifications")
	api.Use(middlewares.AuthMiddleware())
	{
		api.GET("", notificationController.GetNotifications)
		api.PUT("/:id/read", notificationController.MarkNotificationAsRead)
		api.PUT("/read-all", notificationController.MarkAllNotificationsAsRead)
		api.DELETE("/:id", notificationController.DeleteNotification)
	}
}

func setupProfileRoutes(api *gin.RouterGroup) {
	// Using new auth handler for profile routes
	authHandler := handlers.NewAuthHandler()
	profile := api.Group("/profile")
	profile.Use(middlewares.AuthMiddleware())
	{
		profile.GET("", authHandler.GetCurrentUser)
		profile.PUT("", authHandler.UpdateProfile)
	}
}

func setupDetailRoutes(api *gin.RouterGroup) {
	detailController := controllers.NewDetailController()
	
	// Post detail
	api.GET("/posts/:id/detail", middlewares.OptionalAuthMiddleware(), detailController.GetDetail)
	
	// Profile detail  
	api.GET("/profiles/:id/detail", middlewares.OptionalAuthMiddleware(), detailController.GetDetail)
	
	// Training detail
	api.GET("/trainings/:id/detail", middlewares.OptionalAuthMiddleware(), detailController.GetDetail)
}

func setupAICoachRoutes(api *gin.RouterGroup) {
	aiCoachController := controllers.NewAICoachController()
	aiCoach := api.Group("/ai/coach")
	aiCoach.Use(middlewares.AuthMiddleware())
	{
		aiCoach.POST("/chat", aiCoachController.CoachChat)
		aiCoach.POST("/progress", aiCoachController.TrainingProgress)
		aiCoach.GET("/status", aiCoachController.GetServiceStatus)
		aiCoach.POST("/switch-provider", aiCoachController.SwitchProvider)
	}
}

func setupAIChatRoutes(api *gin.RouterGroup) {
	aiChatController := controllers.NewAIChatController()
	aiChat := api.Group("/ai/chat")
	aiChat.Use(middlewares.AuthMiddleware())
	{
		aiChat.POST("", aiChatController.Chat)
		aiChat.POST("/fitness-advice", aiChatController.GetFitnessAdvice)
		aiChat.POST("/workout-plan", aiChatController.GenerateWorkoutPlan)
		aiChat.POST("/analyze-form", aiChatController.AnalyzeWorkoutForm)
		aiChat.POST("/nutrition", aiChatController.GetNutritionAdvice)
	}
}

func setupMapRoutes(api *gin.RouterGroup) {
	mapController := controllers.NewMapController()
	mapGroup := api.Group("/map")
	{
		mapGroup.POST("/geocode", mapController.GeocodeAddress)
		mapGroup.GET("/gyms/nearby", middlewares.OptionalAuthMiddleware(), mapController.SearchNearbyGyms)
		mapGroup.POST("/distance", mapController.CalculateDistance)
		mapGroup.GET("/gyms/:id", mapController.GetGymDetails)
		mapGroup.GET("/gyms/city/:city", mapController.SearchGymsByCity)
	}
}

func setupWebSocketRoutes(api *gin.RouterGroup) {
	wsController := controllers.NewWebSocketController()
	ws := api.Group("/ws")
	{
		ws.GET("/connect", wsController.HandleWebSocket)
	}
}

