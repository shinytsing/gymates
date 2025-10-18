package routes

import (
	"github.com/gin-gonic/gin"
	"gymates-backend/controllers"
	"gymates-backend/middleware"
)

// SetupHomeRoutes 设置首页路由
func SetupHomeRoutes(r *gin.RouterGroup) {
	homeController := controllers.NewHomeController()

	// 首页相关路由
	home := r.Group("/home")
	{
		// 公开接口（无需认证）
		home.GET("/list", homeController.GetHomeList)           // GET /api/home/list
		home.GET("/stats", homeController.GetHomeStats)         // GET /api/home/stats
		home.GET("/:id", homeController.GetHomeItem)            // GET /api/home/:id
		home.POST("/:id/like", homeController.LikeHomeItem)     // POST /api/home/:id/like

		// 需要认证的接口
		homeAuth := home.Group("")
		homeAuth.Use(middleware.AuthMiddleware())
		{
			homeAuth.POST("/add", homeController.AddHomeItem)           // POST /api/home/add
			homeAuth.PUT("/update/:id", homeController.UpdateHomeItem) // PUT /api/home/update/:id
			homeAuth.DELETE("/delete/:id", homeController.DeleteHomeItem) // DELETE /api/home/delete/:id
		}
	}
}

// SetupTrainingRoutes 设置训练相关路由
func SetupTrainingRoutes(r *gin.RouterGroup) {
	trainingController := controllers.NewTrainingController()

	training := r.Group("/training")
	{
		// 公开接口
		training.GET("/plans", middleware.OptionalAuthMiddleware(), trainingController.GetTrainingPlans)
		training.GET("/plans/:id", middleware.OptionalAuthMiddleware(), trainingController.GetTrainingPlan)

		// 需要认证的接口
		trainingAuth := training.Group("")
		trainingAuth.Use(middleware.AuthMiddleware())
		{
			trainingAuth.POST("/plans", trainingController.CreateTrainingPlan)
			trainingAuth.POST("/sessions", trainingController.StartWorkoutSession)
			trainingAuth.PUT("/sessions/:id/progress", trainingController.UpdateWorkoutProgress)
			trainingAuth.POST("/sessions/:id/complete", trainingController.CompleteWorkoutSession)
			trainingAuth.GET("/history", trainingController.GetWorkoutHistory)
		}
	}
}

// SetupCommunityRoutes 设置社区相关路由
func SetupCommunityRoutes(r *gin.RouterGroup) {
	communityController := controllers.NewCommunityController()

	community := r.Group("/community")
	{
		// 公开接口
		community.GET("/posts", middleware.OptionalAuthMiddleware(), communityController.GetPosts)
		community.GET("/posts/:id", middleware.OptionalAuthMiddleware(), communityController.GetPost)
		community.GET("/posts/:id/comments", middleware.OptionalAuthMiddleware(), communityController.GetComments)
		community.GET("/search", middleware.OptionalAuthMiddleware(), communityController.SearchPosts)

		// 需要认证的接口
		communityAuth := community.Group("")
		communityAuth.Use(middleware.AuthMiddleware())
		{
			communityAuth.POST("/posts", communityController.CreatePost)
			communityAuth.POST("/posts/:id/like", communityController.LikePost)
			communityAuth.DELETE("/posts/:id/like", communityController.UnlikePost)
			communityAuth.POST("/posts/:id/comments", communityController.CreateComment)
		}
	}
}

// SetupMatesRoutes 设置搭子相关路由
func SetupMatesRoutes(r *gin.RouterGroup) {
	matesController := controllers.NewMatesController()

	mates := r.Group("/mates")
	mates.Use(middleware.AuthMiddleware())
	{
		mates.GET("", matesController.GetMates)
		mates.GET("/requests", matesController.GetMateRequests)
		mates.POST("/requests", matesController.SendMateRequest)
		mates.POST("/requests/:id/accept", matesController.AcceptMateRequest)
		mates.POST("/requests/:id/reject", matesController.RejectMateRequest)
		mates.DELETE("/:id", matesController.RemoveMate)
		mates.GET("/search", matesController.SearchMates)
		mates.GET("/stats", matesController.GetMateStats)
	}
}

// SetupMessagesRoutes 设置消息相关路由
func SetupMessagesRoutes(r *gin.RouterGroup) {
	messagesController := controllers.NewMessagesController()

	messages := r.Group("/messages")
	messages.Use(middleware.AuthMiddleware())
	{
		messages.GET("/chats", messagesController.GetChats)
		messages.GET("/chats/:id", messagesController.GetChat)
		messages.POST("/chats", messagesController.CreateChat)
		messages.GET("/chats/:id/messages", messagesController.GetMessages)
		messages.POST("/chats/:id/messages", messagesController.SendMessage)
		messages.PUT("/chats/:id/read", messagesController.MarkAsRead)
		messages.GET("/unread", messagesController.GetUnreadCount)
	}
}

// SetupProfileRoutes 设置用户资料相关路由
func SetupProfileRoutes(r *gin.RouterGroup) {
	authController := controllers.NewAuthController()

	profile := r.Group("/profile")
	profile.Use(middleware.AuthMiddleware())
	{
		profile.GET("/me", authController.GetCurrentUser)
		profile.PUT("/update", authController.UpdateProfile)
		profile.GET("/stats", authController.GetUserStats)
	}
}
