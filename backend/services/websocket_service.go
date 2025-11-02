package services

import (
	"encoding/json"
	"log"
	"sync"
	"time"

	"github.com/gorilla/websocket"
	"gymates-backend/models"
)

// WebSocketService WebSocket服务
type WebSocketService struct {
	clients    map[uint]*Client // userID -> Client
	broadcast  chan *Message
	register   chan *Client
	unregister chan *Client
	mu         sync.RWMutex
}

// Client WebSocket客户端
type Client struct {
	ID       uint
	Conn     *websocket.Conn
	Send     chan *Message
	Service  *WebSocketService
	UserID   uint
	Username string
}

// Message WebSocket消息
type Message struct {
	Type      string      `json:"type"` // message, notification, typing, read
	From      uint        `json:"from"`
	To        uint        `json:"to"`
	ChatID    uint        `json:"chat_id,omitempty"`
	Content   string      `json:"content,omitempty"`
	Data      interface{} `json:"data,omitempty"`
	Timestamp time.Time   `json:"timestamp"`
}

var wsService *WebSocketService
var once sync.Once

// GetWebSocketService 获取WebSocket服务单例
func GetWebSocketService() *WebSocketService {
	once.Do(func() {
		wsService = &WebSocketService{
			clients:    make(map[uint]*Client),
			broadcast:  make(chan *Message, 256),
			register:   make(chan *Client),
			unregister: make(chan *Client),
		}
		go wsService.Run()
	})
	return wsService
}

// Run 运行WebSocket服务
func (s *WebSocketService) Run() {
	for {
		select {
		case client := <-s.register:
			s.mu.Lock()
			s.clients[client.UserID] = client
			s.mu.Unlock()
			log.Printf("Client registered: %d (total: %d)", client.UserID, len(s.clients))

			// 发送在线通知
			s.broadcastUserStatus(client.UserID, true)

		case client := <-s.unregister:
			s.mu.Lock()
			if _, ok := s.clients[client.UserID]; ok {
				delete(s.clients, client.UserID)
				close(client.Send)
				log.Printf("Client unregistered: %d (total: %d)", client.UserID, len(s.clients))
			}
			s.mu.Unlock()

			// 发送离线通知
			s.broadcastUserStatus(client.UserID, false)

		case message := <-s.broadcast:
			s.handleBroadcast(message)
		}
	}
}

// RegisterClient 注册客户端
func (s *WebSocketService) RegisterClient(client *Client) {
	s.register <- client
}

// UnregisterClient 注销客户端
func (s *WebSocketService) UnregisterClient(client *Client) {
	s.unregister <- client
}

// BroadcastMessage 广播消息
func (s *WebSocketService) BroadcastMessage(message *Message) {
	s.broadcast <- message
}

// SendToUser 发送消息给指定用户
func (s *WebSocketService) SendToUser(userID uint, message *Message) {
	s.mu.RLock()
	client, ok := s.clients[userID]
	s.mu.RUnlock()

	if ok {
		select {
		case client.Send <- message:
		default:
			// 发送缓冲区满，关闭连接
			s.UnregisterClient(client)
		}
	}
}

// IsUserOnline 检查用户是否在线
func (s *WebSocketService) IsUserOnline(userID uint) bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	_, ok := s.clients[userID]
	return ok
}

// GetOnlineUsers 获取在线用户列表
func (s *WebSocketService) GetOnlineUsers() []uint {
	s.mu.RLock()
	defer s.mu.RUnlock()

	users := make([]uint, 0, len(s.clients))
	for userID := range s.clients {
		users = append(users, userID)
	}
	return users
}

// handleBroadcast 处理广播消息
func (s *WebSocketService) handleBroadcast(message *Message) {
	// 如果指定了接收者，只发给特定用户
	if message.To != 0 {
		s.SendToUser(message.To, message)
		return
	}

	// 否则发给所有在线用户
	s.mu.RLock()
	defer s.mu.RUnlock()

	for _, client := range s.clients {
		select {
		case client.Send <- message:
		default:
			// 发送缓冲区满，关闭连接
			go s.UnregisterClient(client)
		}
	}
}

// broadcastUserStatus 广播用户在线状态
func (s *WebSocketService) broadcastUserStatus(userID uint, online bool) {
	status := "offline"
	if online {
		status = "online"
	}

	message := &Message{
		Type: "user_status",
		From: userID,
		Data: map[string]interface{}{
			"user_id": userID,
			"status":  status,
		},
		Timestamp: time.Now(),
	}

	// 广播给所有在线用户
	s.mu.RLock()
	defer s.mu.RUnlock()

	for _, client := range s.clients {
		if client.UserID != userID {
			select {
			case client.Send <- message:
			default:
			}
		}
	}
}

// ReadPump 读取客户端消息
func (c *Client) ReadPump() {
	defer func() {
		c.Service.UnregisterClient(c)
		c.Conn.Close()
	}()

	c.Conn.SetReadDeadline(time.Now().Add(60 * time.Second))
	c.Conn.SetPongHandler(func(string) error {
		c.Conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		return nil
	})

	for {
		_, messageData, err := c.Conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket error: %v", err)
			}
			break
		}

		var message Message
		if err := json.Unmarshal(messageData, &message); err != nil {
			log.Printf("Failed to unmarshal message: %v", err)
			continue
		}

		message.From = c.UserID
		message.Timestamp = time.Now()

		// 处理不同类型的消息
		switch message.Type {
		case "message":
			// 发送聊天消息
			c.Service.BroadcastMessage(&message)

		case "typing":
			// 发送正在输入状态
			if message.To != 0 {
				c.Service.SendToUser(message.To, &message)
			}

		case "read":
			// 标记消息已读
			if message.To != 0 {
				c.Service.SendToUser(message.To, &message)
			}

		default:
			log.Printf("Unknown message type: %s", message.Type)
		}
	}
}

// WritePump 向客户端发送消息
func (c *Client) WritePump() {
	ticker := time.NewTicker(54 * time.Second)
	defer func() {
		ticker.Stop()
		c.Conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.Send:
			c.Conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if !ok {
				// 通道已关闭
				c.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			if err := c.Conn.WriteJSON(message); err != nil {
				log.Printf("Failed to write message: %v", err)
				return
			}

		case <-ticker.C:
			c.Conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := c.Conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

// SendNotification 发送通知消息
func (s *WebSocketService) SendNotification(userID uint, notification *models.Notification) {
	message := &Message{
		Type:      "notification",
		To:        userID,
		Data:      notification,
		Timestamp: time.Now(),
	}
	s.SendToUser(userID, message)
}

// BroadcastMateRequest 广播搭子请求
func (s *WebSocketService) BroadcastMateRequest(userID uint, request interface{}) {
	message := &Message{
		Type:      "mate_request",
		To:        userID,
		Data:      request,
		Timestamp: time.Now(),
	}
	s.SendToUser(userID, message)
}
