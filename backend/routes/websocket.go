package routes

import (
	"gymates-backend/controllers"
	"gymates-backend/middleware"

	"github.com/gin-gonic/gin"
)

// SetupWebSocketRoutes 设置WebSocket路由
func SetupWebSocketRoutes(r *gin.RouterGroup) {
	wsController := controllers.NewWebSocketController()

	ws := r.Group("/ws")
	ws.Use(middleware.AuthMiddleware())
	{
		// WebSocket连接
		ws.GET("/connect", wsController.HandleWebSocket)

		// 获取在线用户列表
		ws.GET("/online-users", wsController.GetOnlineUsers)

		// 检查用户是否在线
		ws.GET("/user/:user_id/online", wsController.CheckUserOnline)
	}
}
