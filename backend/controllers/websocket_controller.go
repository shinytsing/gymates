package controllers

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"gymates-backend/models"
	"gymates-backend/services"
)

// WebSocketController WebSocket控制器
type WebSocketController struct {
	wsService *services.WebSocketService
	upgrader  websocket.Upgrader
}

// NewWebSocketController 创建WebSocket控制器
func NewWebSocketController() *WebSocketController {
	return &WebSocketController{
		wsService: services.GetWebSocketService(),
		upgrader: websocket.Upgrader{
			ReadBufferSize:  1024,
			WriteBufferSize: 1024,
			CheckOrigin: func(r *http.Request) bool {
				// 在生产环境应该检查来源
				return true
			},
		},
	}
}

// HandleWebSocket 处理WebSocket连接
func (wc *WebSocketController) HandleWebSocket(c *gin.Context) {
	// 获取用户信息
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "用户未认证",
			Error:   "User not authenticated",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	currentUser := user.(*models.User)

	// 升级HTTP连接为WebSocket
	conn, err := wc.upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("Failed to upgrade connection: %v", err)
		return
	}

	// 创建客户端
	client := &services.Client{
		ID:       currentUser.ID,
		Conn:     conn,
		Send:     make(chan *services.Message, 256),
		Service:  wc.wsService,
		UserID:   currentUser.ID,
		Username: currentUser.Name,
	}

	// 注册客户端
	wc.wsService.RegisterClient(client)

	// 启动读写协程
	go client.WritePump()
	go client.ReadPump()

	log.Printf("WebSocket connection established for user: %d", currentUser.ID)
}

// GetOnlineUsers 获取在线用户列表
func (wc *WebSocketController) GetOnlineUsers(c *gin.Context) {
	users := wc.wsService.GetOnlineUsers()

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取在线用户成功",
		Data: map[string]interface{}{
			"online_users": users,
			"total":        len(users),
		},
	})
}

// CheckUserOnline 检查用户是否在线
func (wc *WebSocketController) CheckUserOnline(c *gin.Context) {
	userID := c.Param("user_id")
	if userID == "" {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "用户ID不能为空",
			Error:   "User ID is required",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 转换userID为uint
	var uid uint
	if _, err := fmt.Sscanf(userID, "%d", &uid); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的用户ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	isOnline := wc.wsService.IsUserOnline(uid)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "检查成功",
		Data: map[string]interface{}{
			"user_id":   uid,
			"is_online": isOnline,
		},
	})
}
