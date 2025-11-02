package routes

import (
	"gymates-backend/controllers"
	"gymates-backend/middleware"

	"github.com/gin-gonic/gin"
)

// SetupNotificationRoutes 设置通知相关路由
func SetupNotificationRoutes(router *gin.Engine) {
	nc := controllers.NewNotificationsController()

	// 通知路由组（需要认证）
	notifications := router.Group("/api/notifications")
	notifications.Use(middleware.AuthMiddleware())
	{
		// 获取通知列表
		notifications.GET("", nc.GetNotifications)

		// 获取未读通知数量
		notifications.GET("/unread-count", nc.GetUnreadNotificationsCount)

		// 标记单个通知为已读
		notifications.POST("/:id/read", nc.MarkNotificationAsRead)

		// 标记所有通知为已读
		notifications.POST("/read-all", nc.MarkAllNotificationsAsRead)

		// 删除通知
		notifications.DELETE("/:id", nc.DeleteNotification)

		// 创建通知（内部使用）
		notifications.POST("", nc.CreateNotification)
	}
}
