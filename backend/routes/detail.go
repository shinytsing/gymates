package routes

import (
	"gymates-backend/controllers"
	"gymates-backend/middleware"

	"github.com/gin-gonic/gin"
)

// SetupDetailRoutes 设置详情路由
func SetupDetailRoutes(r *gin.RouterGroup) {
	detailController := controllers.NewDetailController()

	// 详情相关路由
	detail := r.Group("/detail")
	{
		// 公开接口（无需认证）
		detail.GET("/list", detailController.GetDetailList)     // GET /api/detail/list
		detail.GET("/stats", detailController.GetDetailStats)   // GET /api/detail/stats
		detail.GET("/:id", detailController.GetDetail)          // GET /api/detail/:id
		detail.POST("/:id/like", detailController.LikeDetail)   // POST /api/detail/:id/like
		detail.POST("/:id/share", detailController.ShareDetail) // POST /api/detail/:id/share

		// 需要认证的接口
		detailAuth := detail.Group("")
		detailAuth.Use(middleware.AuthMiddleware())
		{
			detailAuth.POST("/submit", detailController.SubmitDetail)       // POST /api/detail/submit
			detailAuth.PUT("/update/:id", detailController.UpdateDetail)    // PUT /api/detail/update/:id
			detailAuth.DELETE("/delete/:id", detailController.DeleteDetail) // DELETE /api/detail/delete/:id
		}
	}
}

// SetupPostDetailRoutes 设置帖子详情路由
func SetupPostDetailRoutes(r *gin.RouterGroup) {
	detailController := controllers.NewDetailController()

	// 帖子详情路由
	postDetail := r.Group("/post-detail")
	{
		// 公开接口
		postDetail.GET("/list", detailController.GetDetailList)     // GET /api/post-detail/list
		postDetail.GET("/:id", detailController.GetDetail)          // GET /api/post-detail/:id
		postDetail.POST("/:id/like", detailController.LikeDetail)   // POST /api/post-detail/:id/like
		postDetail.POST("/:id/share", detailController.ShareDetail) // POST /api/post-detail/:id/share

		// 需要认证的接口
		postDetailAuth := postDetail.Group("")
		postDetailAuth.Use(middleware.AuthMiddleware())
		{
			postDetailAuth.POST("/submit", detailController.SubmitDetail)       // POST /api/post-detail/submit
			postDetailAuth.PUT("/update/:id", detailController.UpdateDetail)    // PUT /api/post-detail/update/:id
			postDetailAuth.DELETE("/delete/:id", detailController.DeleteDetail) // DELETE /api/post-detail/delete/:id
		}
	}
}

// SetupProfileDetailRoutes 设置用户资料详情路由
func SetupProfileDetailRoutes(r *gin.RouterGroup) {
	detailController := controllers.NewDetailController()

	// 用户资料详情路由
	profileDetail := r.Group("/profile-detail")
	{
		// 公开接口
		profileDetail.GET("/list", detailController.GetDetailList) // GET /api/profile-detail/list
		profileDetail.GET("/:id", detailController.GetDetail)      // GET /api/profile-detail/:id

		// 需要认证的接口
		profileDetailAuth := profileDetail.Group("")
		profileDetailAuth.Use(middleware.AuthMiddleware())
		{
			profileDetailAuth.POST("/submit", detailController.SubmitDetail)       // POST /api/profile-detail/submit
			profileDetailAuth.PUT("/update/:id", detailController.UpdateDetail)    // PUT /api/profile-detail/update/:id
			profileDetailAuth.DELETE("/delete/:id", detailController.DeleteDetail) // DELETE /api/profile-detail/delete/:id
		}
	}
}

// SetupChatDetailRoutes 设置聊天详情路由
func SetupChatDetailRoutes(r *gin.RouterGroup) {
	detailController := controllers.NewDetailController()

	// 聊天详情路由
	chatDetail := r.Group("/chat-detail")
	chatDetail.Use(middleware.AuthMiddleware())
	{
		chatDetail.GET("/list", detailController.GetDetailList)         // GET /api/chat-detail/list
		chatDetail.GET("/:id", detailController.GetDetail)              // GET /api/chat-detail/:id
		chatDetail.POST("/submit", detailController.SubmitDetail)       // POST /api/chat-detail/submit
		chatDetail.PUT("/update/:id", detailController.UpdateDetail)    // PUT /api/chat-detail/update/:id
		chatDetail.DELETE("/delete/:id", detailController.DeleteDetail) // DELETE /api/chat-detail/delete/:id
	}
}

// SetupAchievementDetailRoutes 设置成就详情路由
func SetupAchievementDetailRoutes(r *gin.RouterGroup) {
	detailController := controllers.NewDetailController()

	// 成就详情路由
	achievementDetail := r.Group("/achievement-detail")
	{
		// 公开接口
		achievementDetail.GET("/list", detailController.GetDetailList)     // GET /api/achievement-detail/list
		achievementDetail.GET("/:id", detailController.GetDetail)          // GET /api/achievement-detail/:id
		achievementDetail.POST("/:id/like", detailController.LikeDetail)   // POST /api/achievement-detail/:id/like
		achievementDetail.POST("/:id/share", detailController.ShareDetail) // POST /api/achievement-detail/:id/share

		// 需要认证的接口
		achievementDetailAuth := achievementDetail.Group("")
		achievementDetailAuth.Use(middleware.AuthMiddleware())
		{
			achievementDetailAuth.POST("/submit", detailController.SubmitDetail)       // POST /api/achievement-detail/submit
			achievementDetailAuth.PUT("/update/:id", detailController.UpdateDetail)    // PUT /api/achievement-detail/update/:id
			achievementDetailAuth.DELETE("/delete/:id", detailController.DeleteDetail) // DELETE /api/achievement-detail/delete/:id
		}
	}
}

// SetupTrainingDetailRoutes 设置训练详情路由
func SetupTrainingDetailRoutes(r *gin.RouterGroup) {
	detailController := controllers.NewDetailController()

	// 训练详情路由
	trainingDetail := r.Group("/training-detail")
	{
		// 公开接口
		trainingDetail.GET("/list", detailController.GetDetailList)     // GET /api/training-detail/list
		trainingDetail.GET("/:id", detailController.GetDetail)          // GET /api/training-detail/:id
		trainingDetail.POST("/:id/like", detailController.LikeDetail)   // POST /api/training-detail/:id/like
		trainingDetail.POST("/:id/share", detailController.ShareDetail) // POST /api/training-detail/:id/share

		// 需要认证的接口
		trainingDetailAuth := trainingDetail.Group("")
		trainingDetailAuth.Use(middleware.AuthMiddleware())
		{
			trainingDetailAuth.POST("/submit", detailController.SubmitDetail)       // POST /api/training-detail/submit
			trainingDetailAuth.PUT("/update/:id", detailController.UpdateDetail)    // PUT /api/training-detail/update/:id
			trainingDetailAuth.DELETE("/delete/:id", detailController.DeleteDetail) // DELETE /api/training-detail/delete/:id
		}
	}
}

// SetupMatesDetailRoutes 设置搭子详情路由
func SetupMatesDetailRoutes(r *gin.RouterGroup) {
	detailController := controllers.NewDetailController()

	// 搭子详情路由
	matesDetail := r.Group("/mates-detail")
	matesDetail.Use(middleware.AuthMiddleware())
	{
		matesDetail.GET("/list", detailController.GetDetailList)         // GET /api/mates-detail/list
		matesDetail.GET("/:id", detailController.GetDetail)              // GET /api/mates-detail/:id
		matesDetail.POST("/submit", detailController.SubmitDetail)       // POST /api/mates-detail/submit
		matesDetail.PUT("/update/:id", detailController.UpdateDetail)    // PUT /api/mates-detail/update/:id
		matesDetail.DELETE("/delete/:id", detailController.DeleteDetail) // DELETE /api/mates-detail/delete/:id
	}
}
