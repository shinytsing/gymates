package controllers

import (
	"os"
	"testing"

	"gymates-backend/config"
	"gymates-backend/models"

	"github.com/gin-gonic/gin"
)

// TestMain 测试主函数
func TestMain(m *testing.M) {
	// 设置测试环境变量
	os.Setenv("DB_TYPE", "sqlite")
	os.Setenv("DB_PATH", ":memory:") // 使用内存数据库
	os.Setenv("GIN_MODE", "test")
	os.Setenv("JWT_SECRET", "test-secret-key")

	// 初始化测试数据库
	err := config.InitDB()
	if err != nil {
		panic("Failed to initialize test database: " + err.Error())
	}

	// 运行测试
	code := m.Run()

	// 清理资源
	// 这里可以添加清理逻辑

	os.Exit(code)
}

// setupTestRouter 设置测试路由
func setupTestRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	router := gin.Default()

	// 添加测试路由
	router.GET("/api/home/list", NewHomeController().GetHomeList)
	router.POST("/api/home/add", NewHomeController().AddHomeItem)
	router.PUT("/api/home/update/:id", NewHomeController().UpdateHomeItem)
	router.DELETE("/api/home/delete/:id", NewHomeController().DeleteHomeItem)
	router.GET("/api/home/:id", NewHomeController().GetHomeItem)
	router.POST("/api/home/:id/like", NewHomeController().LikeHomeItem)
	router.GET("/api/home/stats", NewHomeController().GetHomeStats)

	router.GET("/api/detail/list", NewDetailController().GetDetailList)
	router.GET("/api/detail/:id", NewDetailController().GetDetail)
	router.POST("/api/detail/submit", NewDetailController().SubmitDetail)
	router.PUT("/api/detail/update/:id", NewDetailController().UpdateDetail)
	router.DELETE("/api/detail/delete/:id", NewDetailController().DeleteDetail)
	router.POST("/api/detail/:id/like", NewDetailController().LikeDetail)
	router.POST("/api/detail/:id/share", NewDetailController().ShareDetail)
	router.GET("/api/detail/stats", NewDetailController().GetDetailStats)

	router.POST("/api/auth/login", NewAuthController().Login)
	router.POST("/api/auth/register", NewAuthController().Register)
	router.GET("/api/auth/me", NewAuthController().GetCurrentUser)
	router.PUT("/api/auth/profile", NewAuthController().UpdateProfile)
	router.POST("/api/auth/logout", NewAuthController().Logout)
	router.GET("/api/users/:id", NewAuthController().GetUserProfile)
	router.GET("/api/profile/stats", NewAuthController().GetUserStats)

	router.GET("/api/training/plans", NewTrainingController().GetTrainingPlans)
	router.GET("/api/training/plans/:id", NewTrainingController().GetTrainingPlan)
	router.POST("/api/training/plans", NewTrainingController().CreateTrainingPlan)
	router.POST("/api/training/sessions", NewTrainingController().StartWorkoutSession)
	router.PUT("/api/training/sessions/:id/progress", NewTrainingController().UpdateWorkoutProgress)
	router.POST("/api/training/sessions/:id/complete", NewTrainingController().CompleteWorkoutSession)
	router.GET("/api/training/history", NewTrainingController().GetWorkoutHistory)

	router.GET("/api/community/posts", NewCommunityController().GetPosts)
	router.GET("/api/community/posts/:id", NewCommunityController().GetPost)
	router.POST("/api/community/posts", NewCommunityController().CreatePost)
	router.POST("/api/community/posts/:id/like", NewCommunityController().LikePost)
	router.DELETE("/api/community/posts/:id/like", NewCommunityController().UnlikePost)
	router.GET("/api/community/posts/:id/comments", NewCommunityController().GetComments)
	router.POST("/api/community/posts/:id/comments", NewCommunityController().CreateComment)
	router.DELETE("/api/community/comments/:id", NewCommunityController().CreateComment)

	return router
}

// createTestUser 创建测试用户
func createTestUser() *models.User {
	user := &models.User{
		Name:     "测试用户",
		Email:    "test@gymates.com",
		Password: "password123",
	}

	// 这里可以添加创建用户的逻辑
	return user
}

// createTestHomeItem 创建测试首页项
func createTestHomeItem() *models.HomeItem {
	item := &models.HomeItem{
		Title:       "测试首页项",
		Description: "这是一个测试首页项",
		Category:    "fitness",
		Priority:    1,
		Status:      "published",
	}

	// 这里可以添加创建首页项的逻辑
	return item
}

// createTestDetailItem 创建测试详情项
func createTestDetailItem() *models.DetailItem {
	item := &models.DetailItem{
		Title:       "测试详情项",
		Content:     "这是测试内容",
		Description: "测试描述",
		Type:        "post",
		Category:    "fitness",
		Status:      "published",
	}

	// 这里可以添加创建详情项的逻辑
	return item
}

// createTestPost 创建测试帖子
func createTestPost() *models.Post {
	post := &models.Post{
		Content: "这是一个测试帖子",
		Type:    "text",
	}

	// 这里可以添加创建帖子的逻辑
	return post
}

// createTestTrainingPlan 创建测试训练计划
func createTestTrainingPlan() *models.TrainingPlan {
	plan := &models.TrainingPlan{
		Name:        "测试训练计划",
		Description: "这是一个测试训练计划",
		Duration:    30,
		Difficulty:  "beginner",
		Exercises: []models.Exercise{
			{
				Name:     "俯卧撑",
				Sets:     3,
				Reps:     10,
				Weight:   0,
				RestTime: 60,
			},
		},
	}

	// 这里可以添加创建训练计划的逻辑
	return plan
}
