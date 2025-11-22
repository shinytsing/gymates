package handlers

import (
	"net/http"
	"strconv"

	"gymates-backend/models"
	"gymates-backend/repositories"

	"github.com/gin-gonic/gin"
)

// MessagesHandler handles message-related requests
type MessagesHandler struct {
	messageRepo *repositories.MessageRepository
	userRepo    *repositories.UserRepository
}

// NewMessagesHandler creates a new messages handler
func NewMessagesHandler() *MessagesHandler {
	return &MessagesHandler{
		messageRepo: repositories.NewMessageRepository(),
		userRepo:    repositories.NewUserRepository(),
	}
}

// GetConversations retrieves all conversations for the current user
func (h *MessagesHandler) GetConversations(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未认证",
			Error:   "Unauthorized",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	currentUser := user.(*models.User)

	chats, err := h.messageRepo.GetUserConversations(currentUser.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取会话列表失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// Return empty array if no chats found
	if chats == nil {
		chats = []models.Chat{}
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取会话列表成功",
		Data:    chats,
	})
}

// GetMessages retrieves messages in a conversation
func (h *MessagesHandler) GetMessages(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未认证",
			Error:   "Unauthorized",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	currentUser := user.(*models.User)

	otherUserIDStr := c.Param("userId")
	otherUserID, err := strconv.ParseUint(otherUserIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的用户ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))

	messages, total, err := h.messageRepo.GetConversation(currentUser.ID, uint(otherUserID), page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取消息列表失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	pagination := models.Pagination{
		Page:       page,
		Limit:      limit,
		Total:      total,
		TotalPages: int((total + int64(limit) - 1) / int64(limit)),
		HasMore:    int64(page*limit) < total,
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取消息列表成功",
		Data: gin.H{
			"messages":   messages,
			"pagination": pagination,
		},
	})
}

// SendMessage sends a message to another user
func (h *MessagesHandler) SendMessage(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未认证",
			Error:   "Unauthorized",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	currentUser := user.(*models.User)

	var req models.SendMessageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Note: Using ChatID from request, need to extract receiver from chat
	// For simplicity, assuming we'll enhance this later with proper chat management
	message := models.Message{
		SenderID: currentUser.ID,
		// ReceiverID will need to be determined from ChatID
		// For now, this is a placeholder that needs enhancement
		Content: req.Content,
		Type:    req.Type,
		IsRead:  false,
	}

	if err := h.messageRepo.CreateMessage(&message); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "发送消息失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// Reload message with sender and receiver information
	reloadedMsg, _ := h.messageRepo.GetMessageByID(message.ID)
	if reloadedMsg != nil {
		message = *reloadedMsg
	}

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "发送消息成功",
		Data:    message,
	})
}

// MarkAsRead marks messages as read
func (h *MessagesHandler) MarkAsRead(c *gin.Context) {
	_, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未认证",
			Error:   "Unauthorized",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	var req struct {
		MessageIDs []uint `json:"message_ids"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	if err := h.messageRepo.MarkAsRead(req.MessageIDs); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "标记已读失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "标记已读成功",
		Data:    nil,
	})
}

// GetUnreadCount retrieves the count of unread messages
func (h *MessagesHandler) GetUnreadCount(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未认证",
			Error:   "Unauthorized",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	currentUser := user.(*models.User)

	count, err := h.messageRepo.GetUnreadCount(currentUser.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取未读消息数失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取未读消息数成功",
		Data: gin.H{
			"unread_count": count,
		},
	})
}

