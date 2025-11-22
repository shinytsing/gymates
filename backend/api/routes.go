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
			// Training stats
			users.GET("/:id/training/stats", middlewares.OptionalAuthMiddleware(), func(c *gin.Context) {
				c.JSON(http.StatusOK, gin.H{
					"success": true,
					"data": gin.H{
						"total_workouts":     0,
						"total_duration":     0,
						"total_calories":     0,
						"current_streak":     0,
						"longest_streak":     0,
						"favorite_exercises": []string{},
					},
				})
			})
			// Achievements
			users.GET("/:id/achievements", middlewares.OptionalAuthMiddleware(), func(c *gin.Context) {
				c.JSON(http.StatusOK, gin.H{
					"success": true,
					"data": gin.H{
						"achievements": []gin.H{},
						"total_points": 0,
						"badges":       []gin.H{},
					},
				})
			})
			// Records
			users.GET("/:id/records", middlewares.OptionalAuthMiddleware(), func(c *gin.Context) {
				c.JSON(http.StatusOK, gin.H{
					"success": true,
					"data": gin.H{
						"personal_records": []gin.H{},
					},
				})
			})
			// Social stats
			users.GET("/:id/social/stats", middlewares.OptionalAuthMiddleware(), func(c *gin.Context) {
				c.JSON(http.StatusOK, gin.H{
					"success": true,
					"data": gin.H{
						"followers_count":  0,
						"following_count":  0,
						"mates_count":      0,
						"posts_count":      0,
						"likes_count":      0,
						"comments_count":   0,
					},
				})
			})
		}

		// ============================================
		// Tab 1: 训练 (Training)
		// ============================================
		training := api.Group("/training")
		{
			// 训练计划相关
			training.GET("/plans", trainingHandler.GetTrainingPlans)
			training.GET("/plans/:id", trainingHandler.GetTrainingPlan)
			training.POST("/plans", middlewares.AuthMiddleware(), trainingHandler.CreateTrainingPlan)
			training.PUT("/plans/:id", middlewares.AuthMiddleware(), trainingHandler.UpdateTrainingPlan)
			training.DELETE("/plans/:id", middlewares.AuthMiddleware(), trainingHandler.DeleteTrainingPlan)
			
			// 训练执行相关（已通过setupExtendedTrainingRoutes实现）
			// - POST /api/training/sessions/start - 开始训练
			// - POST /api/training/sessions/progress - 更新进度
			// - POST /api/training/sessions/complete - 完成训练
			
			// 训练历史相关（已通过setupExtendedTrainingRoutes实现）
			// - GET /api/training/history - 获取训练历史
			
			// 训练统计相关（已通过setupExtendedTrainingRoutes实现）
			// - GET /api/training/statistics - 获取训练统计
			// - GET /api/training/user-stats - 获取用户统计
			
			// 动作库相关（已通过setupExtendedTrainingRoutes实现）
			// - GET /api/training/exercises - 获取动作库
			// - GET /api/training/exercises/:id - 获取动作详情
			// - POST /api/training/exercises/:id/favorite - 收藏动作
			
			// 今日训练相关（已通过setupExtendedTrainingRoutes实现）
			// - GET /api/training/today - 获取今日训练
			// - POST /api/training/today - 创建今日训练
			
			// AI训练相关（已通过setupAICoachRoutes和setupAIChatRoutes实现）
		}

		// ============================================
		// Tab 2: 社区 (Community)
		// ============================================
		community := api.Group("/community")
		{
			// 帖子相关
			community.GET("/posts", communityHandler.GetPosts)
			community.GET("/posts/:id", communityHandler.GetPost)
			community.POST("/posts", middlewares.AuthMiddleware(), communityHandler.CreatePost)
			community.PUT("/posts/:id", middlewares.AuthMiddleware(), communityHandler.UpdatePost)
			community.DELETE("/posts/:id", middlewares.AuthMiddleware(), communityHandler.DeletePost)
			
			// 互动相关
			community.POST("/posts/:id/like", middlewares.AuthMiddleware(), communityHandler.LikePost)
			community.DELETE("/posts/:id/like", middlewares.AuthMiddleware(), communityHandler.UnlikePost)
			// TODO: 添加收藏、分享、评论等功能路由
			
			// 分类和筛选
			community.GET("/posts/nearby", middlewares.OptionalAuthMiddleware(), communityHandler.GetPosts) // 附近帖子
			community.GET("/posts/recommended", middlewares.OptionalAuthMiddleware(), communityHandler.GetPosts) // 推荐帖子
			community.GET("/posts/activities", middlewares.OptionalAuthMiddleware(), communityHandler.GetPosts) // 活动帖子
		}

		// ============================================
		// Tab 3: 搭子 (Mates)
		// ============================================
		mates := api.Group("/mates")
		mates.Use(middlewares.AuthMiddleware())
		{
			// 搭子匹配相关
			mates.GET("", matesHandler.GetMates)
			mates.GET("/recommendations", matesHandler.GetMateRecommendations)
			mates.GET("/find", matesHandler.FindPotentialMates)
			mates.GET("/:id", func(c *gin.Context) {
				// TODO: 实现获取搭子详情
				c.JSON(http.StatusNotImplemented, gin.H{"message": "待实现"})
			})
			
			// 搭子请求相关
			mates.GET("/pending", matesHandler.GetPendingRequests)
			mates.POST("/request", matesHandler.SendMateRequest)
			mates.POST("/:id/accept", matesHandler.AcceptMateRequest)
			mates.POST("/:id/reject", matesHandler.RejectMateRequest)
			mates.DELETE("/:id", func(c *gin.Context) {
				// TODO: 实现移除搭子
				c.JSON(http.StatusNotImplemented, gin.H{"message": "待实现"})
			})
			
			// 健身房相关（搭子Tab中的地图功能）
			mates.GET("/gyms/nearby", func(c *gin.Context) {
				// 通过map路由实现
				c.Redirect(http.StatusMovedPermanently, "/api/map/gyms/nearby")
			})
		}

		// ============================================
		// Tab 4: 消息 (Messages)
		// ============================================
		messages := api.Group("/messages")
		messages.Use(middlewares.AuthMiddleware())
		{
			// 会话相关
			messages.GET("/conversations", messagesHandler.GetConversations)
			messages.GET("/chats", messagesHandler.GetConversations) // Alias for conversations
			messages.GET("/conversations/:userId", messagesHandler.GetMessages)
			messages.POST("/conversations", func(c *gin.Context) {
				// TODO: 实现创建新会话
				c.JSON(http.StatusNotImplemented, gin.H{"message": "待实现"})
			})
			messages.DELETE("/conversations/:id", func(c *gin.Context) {
				// TODO: 实现删除会话
				c.JSON(http.StatusNotImplemented, gin.H{"message": "待实现"})
			})
			
			// 消息相关
			messages.POST("/send", messagesHandler.SendMessage)
			messages.PUT("/:id/read", func(c *gin.Context) {
				// TODO: 实现标记单条消息已读
				c.JSON(http.StatusNotImplemented, gin.H{"message": "待实现"})
			})
			messages.POST("/mark-read", messagesHandler.MarkAsRead)
			messages.DELETE("/:id", func(c *gin.Context) {
				// TODO: 实现删除消息
				c.JSON(http.StatusNotImplemented, gin.H{"message": "待实现"})
			})
			
			// 未读相关
			messages.GET("/unread-count", messagesHandler.GetUnreadCount)
			messages.GET("/unread", messagesHandler.GetUnreadCount) // Alias for unread-count
			
			// 通知相关（通过通知路由实现）
		}

		// ============================================
		// Tab 5: 我的 (Profile)
		// ============================================
		profile := api.Group("/profile")
		profile.Use(middlewares.AuthMiddleware())
		{
			// 用户信息相关
			profile.GET("", authHandler.GetCurrentUser)
			profile.PUT("", authHandler.UpdateProfile)
			profile.GET("/stats", func(c *gin.Context) {
				// TODO: 实现获取用户统计数据
				c.JSON(http.StatusNotImplemented, gin.H{"message": "待实现"})
			})
			
			// 个人资料相关
			profile.GET("/detail", func(c *gin.Context) {
				// 通过detail路由实现
				c.Redirect(http.StatusMovedPermanently, "/api/profiles/:id/detail")
			})
			
			// 训练统计相关（已通过training路由实现）
			profile.GET("/training/stats", func(c *gin.Context) {
				// 重定向到训练统计API
				c.Redirect(http.StatusMovedPermanently, "/api/training/user-stats")
			})
			profile.GET("/training/records", func(c *gin.Context) {
				// 重定向到训练历史API
				c.Redirect(http.StatusMovedPermanently, "/api/training/history")
			})
			
			// 社交统计相关
			profile.GET("/social/stats", func(c *gin.Context) {
				// 通过users路由实现
				c.Redirect(http.StatusMovedPermanently, "/api/users/:id/social/stats")
			})
			
			// 成就相关
			profile.GET("/achievements", func(c *gin.Context) {
				// 通过users路由实现
				c.Redirect(http.StatusMovedPermanently, "/api/users/:id/achievements")
			})
			
			// 内容管理相关
			profile.GET("/posts", func(c *gin.Context) {
				// TODO: 实现获取我的帖子
				c.JSON(http.StatusNotImplemented, gin.H{"message": "待实现"})
			})
			profile.GET("/favorites", func(c *gin.Context) {
				// TODO: 实现获取我的收藏
				c.JSON(http.StatusNotImplemented, gin.H{"message": "待实现"})
			})
			profile.GET("/training-plans", func(c *gin.Context) {
				// 通过training路由实现，添加user_id参数
				c.Redirect(http.StatusMovedPermanently, "/api/training/plans?user_id=current")
			})
		}

		// Keep existing routes from old structure for backward compatibility
		// These will be gradually migrated to the new structure
		
		// Home routes (using old controller temporarily)
		setupHomeRoutes(api)

		// Training routes - extended (using old controller temporarily)
		setupExtendedTrainingRoutes(api)

		// Notifications routes
		setupNotificationRoutes(r)

		// Profile routes (commented out to avoid duplicate registration)
		// setupProfileRoutes(api) // Already registered above at line 245

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

		// Translation routes
		setupTranslationRoutes(api)
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
	trainingV2Controller := controllers.NewTrainingControllerV2()
	
	training := api.Group("/training")
	training.Use(middlewares.AuthMiddleware())
	{
		// 训练计划路由（兼容旧路由）
		training.GET("/list", trainingController.GetTrainingPlans)
		
		// 动作库路由
		training.GET("/exercises", trainingV2Controller.GetExerciseLibrary)
		training.GET("/exercises/:id", trainingV2Controller.GetExerciseDetail)
		training.POST("/exercises/:id/favorite", trainingV2Controller.ToggleFavoriteExercise)
		
		// 训练会话路由（已实现）
		training.POST("/sessions/start", trainingV2Controller.StartWorkoutSession)
		training.POST("/sessions/progress", trainingV2Controller.UpdateWorkoutProgress)
		training.POST("/sessions/complete", trainingV2Controller.CompleteWorkout)
		
		// 训练历史路由（已实现）
		training.GET("/history", trainingV2Controller.GetTrainingHistory)
		
		// 训练统计路由（已实现）
		training.GET("/statistics", trainingV2Controller.GetTrainingStatistics)
		training.GET("/user-stats", trainingV2Controller.GetUserStats)
		
		// 今日训练路由（已实现）
		training.GET("/today", trainingV2Controller.GetTodayWorkout)
		training.POST("/today", trainingV2Controller.CreateTodayWorkout)
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

// setupProfileRoutes is commented out because profile routes are already registered above at line 241-246
// func setupProfileRoutes(api *gin.RouterGroup) {
// 	// Using new auth handler for profile routes
// 	authHandler := handlers.NewAuthHandler()
// 	profile := api.Group("/profile")
// 	profile.Use(middlewares.AuthMiddleware())
// 	{
// 		profile.GET("", authHandler.GetCurrentUser)
// 		profile.PUT("", authHandler.UpdateProfile)
// 	}
// }

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
	
	// AI训练计划相关路由
	aiTrainingController := controllers.NewAITrainingController()
	aiTraining := api.Group("/training/ai")
	aiTraining.Use(middlewares.AuthMiddleware())
	{
		// 训练计划生成
		aiTraining.POST("/generate-plan", aiTrainingController.GeneratePersonalizedPlan)
		aiTraining.GET("/recommend", aiTrainingController.GetAIRecommendation)
		aiTraining.POST("/preferences", aiTrainingController.SaveTrainingPreferences)
		
		// 动作指导与训练
		aiTraining.GET("/exercise/:id/guidance", aiTrainingController.GetExerciseGuidance)
		aiTraining.POST("/start", aiTrainingController.StartTraining)
		aiTraining.POST("/chat", aiTrainingController.AIChat)
		
		// 实时纠正
		aiTraining.POST("/correction", aiTrainingController.GetRealTimeCorrection)
		
		// 训练数据与反馈
		aiTraining.POST("/upload-data", aiTrainingController.UploadTrainingData)
		aiTraining.POST("/session", aiTrainingController.SaveTrainingSession)
		aiTraining.GET("/feedback", aiTrainingController.GetTrainingFeedback)
		aiTraining.GET("/progress", aiTrainingController.GetTrainingProgress)
	}
}

func setupAIChatRoutes(api *gin.RouterGroup) {
	aiChatController := controllers.NewAIChatController()
	// LLM配置管理路由
	llmConfigController := controllers.NewLLMConfigController()
	aiLLM := api.Group("/ai/llm")
	aiLLM.Use(middlewares.AuthMiddleware())
	{
		aiLLM.GET("/configs", llmConfigController.GetAvailableLLMs)
		aiLLM.POST("/set-provider", llmConfigController.SetUserLLMProvider)
		aiLLM.POST("/test-connection", llmConfigController.TestLLMConnection)
	}

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
		// WebSocket 需要 JWT 认证
		ws.GET("/connect", middlewares.AuthMiddleware(), wsController.HandleWebSocket)
		
		// 在线用户管理
		ws.GET("/online-users", middlewares.AuthMiddleware(), wsController.GetOnlineUsers)
		ws.GET("/users/:user_id/online", middlewares.AuthMiddleware(), wsController.CheckUserOnline)
	}
}

func setupTranslationRoutes(api *gin.RouterGroup) {
	translationController := controllers.NewTranslationController()
	translation := api.Group("/translation")
	{
		translation.POST("/exercise-name", translationController.TranslateExerciseName)
		translation.POST("/exercise-names/batch", translationController.BatchTranslateExerciseNames)
	}
}

