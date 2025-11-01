package routes

import (
	"gymates-backend/controllers"
	"gymates-backend/middleware"

	"github.com/gin-gonic/gin"
)

// SetupTrainingV2Routes 设置训练V2路由
func SetupTrainingV2Routes(r *gin.RouterGroup) {
	ctrl := controllers.NewTrainingControllerV2()

	training := r.Group("/training")
	training.Use(middleware.AuthMiddleware())
	{
		// 运动库路由
		exercises := training.Group("/exercises")
		{
			exercises.GET("", ctrl.GetExerciseLibrary)          // 获取运动库
			exercises.GET("/:id", ctrl.GetExerciseDetail)       // 获取运动详情
			exercises.POST("/:id/favorite", ctrl.ToggleFavoriteExercise) // 收藏/取消收藏
		}

		// 训练计划路由
		plans := training.Group("/plans")
		{
			plans.POST("", ctrl.CreateTrainingPlan)           // 创建训练计划
			plans.GET("", ctrl.GetTrainingPlans)              // 获取训练计划列表
			plans.GET("/:id", ctrl.GetTrainingPlanDetail)     // 获取训练计划详情
			plans.PUT("/:id", ctrl.UpdateTrainingPlan)        // 更新训练计划
			plans.DELETE("/:id", ctrl.DeleteTrainingPlan)     // 删除训练计划
		}

		// 今日训练路由
		today := training.Group("/today")
		{
			today.GET("", ctrl.GetTodayWorkout)      // 获取今日训练
			today.POST("", ctrl.CreateTodayWorkout)  // 创建今日训练
		}

		// 训练会话路由
		sessions := training.Group("/sessions")
		{
			sessions.POST("/start", ctrl.StartWorkoutSession)      // 开始训练
			sessions.POST("/progress", ctrl.UpdateWorkoutProgress) // 更新进度
			sessions.POST("/complete", ctrl.CompleteWorkout)       // 完成训练
		}

		// 训练历史路由
		history := training.Group("/history")
		{
			history.GET("", ctrl.GetTrainingHistory)          // 获取训练历史
		}

		// 训练统计路由
		training.GET("/statistics", ctrl.GetTrainingStatistics) // 获取训练统计
		training.GET("/user-stats", ctrl.GetUserStats)          // 获取用户统计

		// AI训练路由
		ai := training.Group("/ai")
		{
			ai.POST("/generate-plan", ctrl.GenerateAIWorkoutPlan)      // 生成AI训练计划
			ai.POST("/feedback", ctrl.GetRealtimeFeedback)             // 获取实时反馈
			ai.POST("/motivation", ctrl.GenerateMotivationalMessage)   // 生成激励消息
		}
	}
}

