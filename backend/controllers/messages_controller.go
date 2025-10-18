package controllers

import (
	"net/http"
	"strconv"

	"gymates-backend/config"
	"gymates-backend/models"

	"github.com/gin-gonic/gin"
)

// MessagesController 消息控制器
type MessagesController struct{}

// NewMessagesController 创建消息控制器
func NewMessagesController() *MessagesController {
	return &MessagesController{}
}

// GetChats 获取聊天列表
func (mc *MessagesController) GetChats(c *gin.Context) {
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

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	currentUser := user.(*models.User)

	var chats []models.Chat
	var total int64

	// 获取用户参与的聊天
	query := config.DB.Table("chats").
		Joins("JOIN chat_participants ON chats.id = chat_participants.chat_id").
		Where("chat_participants.user_id = ?", currentUser.ID)

	// 获取总数
	query.Count(&total)

	// 分页查询
	offset := (page - 1) * limit
	if err := query.Preload("Participants").Preload("LastMessage").
		Offset(offset).Limit(limit).Order("updated_at DESC").Find(&chats).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取聊天列表失败",
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
		Message: "获取聊天列表成功",
		Data: models.ChatsResponse{
			Chats:      chats,
			Pagination: pagination,
		},
	})
}

// GetChat 获取单个聊天
func (mc *MessagesController) GetChat(c *gin.Context) {
	chatIDStr := c.Param("id")
	chatID, err := strconv.ParseUint(chatIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的聊天ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

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

	var chat models.Chat
	if err := config.DB.Preload("Participants").Preload("LastMessage").
		First(&chat, uint(chatID)).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "聊天不存在",
			Error:   "Chat not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 检查用户是否参与此聊天
	var participant models.ChatParticipant
	if err := config.DB.Where("chat_id = ? AND user_id = ?", uint(chatID), currentUser.ID).
		First(&participant).Error; err != nil {
		c.JSON(http.StatusForbidden, models.ErrorResponse{
			Success: false,
			Message: "无权访问此聊天",
			Error:   "Access denied",
			Code:    http.StatusForbidden,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取聊天成功",
		Data:    chat,
	})
}

// GetMessages 获取聊天消息
func (mc *MessagesController) GetMessages(c *gin.Context) {
	chatIDStr := c.Param("id")
	chatID, err := strconv.ParseUint(chatIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的聊天ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

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

	// 检查用户是否参与此聊天
	var participant models.ChatParticipant
	if err := config.DB.Where("chat_id = ? AND user_id = ?", uint(chatID), currentUser.ID).
		First(&participant).Error; err != nil {
		c.JSON(http.StatusForbidden, models.ErrorResponse{
			Success: false,
			Message: "无权访问此聊天",
			Error:   "Access denied",
			Code:    http.StatusForbidden,
		})
		return
	}

	var messages []models.Message
	var total int64

	// 获取总数
	config.DB.Model(&models.Message{}).Where("chat_id = ?", uint(chatID)).Count(&total)

	// 分页查询
	offset := (page - 1) * limit
	if err := config.DB.Where("chat_id = ?", uint(chatID)).
		Preload("Sender").
		Offset(offset).Limit(limit).Order("created_at ASC").Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取消息失败",
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
		Message: "获取消息成功",
		Data: models.MessagesResponse{
			Messages:   messages,
			Pagination: pagination,
		},
	})
}

// SendMessage 发送消息
func (mc *MessagesController) SendMessage(c *gin.Context) {
	chatIDStr := c.Param("id")
	chatID, err := strconv.ParseUint(chatIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的聊天ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

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

	currentUser := user.(*models.User)

	// 检查用户是否参与此聊天
	var participant models.ChatParticipant
	if err := config.DB.Where("chat_id = ? AND user_id = ?", uint(chatID), currentUser.ID).
		First(&participant).Error; err != nil {
		c.JSON(http.StatusForbidden, models.ErrorResponse{
			Success: false,
			Message: "无权访问此聊天",
			Error:   "Access denied",
			Code:    http.StatusForbidden,
		})
		return
	}

	// 创建消息
	message := models.Message{
		ChatID:   uint(chatID),
		SenderID: currentUser.ID,
		Content:  req.Content,
		Type:     req.Type,
		IsRead:   false,
	}

	if err := config.DB.Create(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "发送消息失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 更新聊天的最后消息和更新时间
	config.DB.Model(&models.Chat{}).Where("id = ?", uint(chatID)).
		Updates(map[string]interface{}{
			"last_message_id": message.ID,
			"updated_at":      "NOW()",
		})

	// 重新加载数据
	config.DB.Preload("Sender").First(&message, message.ID)

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "发送消息成功",
		Data:    message,
	})
}

// CreateChat 创建聊天
func (mc *MessagesController) CreateChat(c *gin.Context) {
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

	var req struct {
		ParticipantIDs []uint `json:"participant_ids" binding:"required"`
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

	currentUser := user.(*models.User)

	// 检查参与者是否存在
	var participants []models.User
	if err := config.DB.Where("id IN ?", req.ParticipantIDs).Find(&participants).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "部分参与者不存在",
			Error:   "Some participants not found",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 添加当前用户到参与者列表
	participantIDs := append(req.ParticipantIDs, currentUser.ID)

	// 检查是否已存在相同的聊天
	var existingChat models.Chat
	subQuery := config.DB.Table("chat_participants").
		Select("chat_id").
		Where("user_id IN ?", participantIDs).
		Group("chat_id").
		Having("COUNT(DISTINCT user_id) = ?", len(participantIDs))

	if err := config.DB.Where("id IN (?)", subQuery).First(&existingChat).Error; err == nil {
		c.JSON(http.StatusConflict, models.ErrorResponse{
			Success: false,
			Message: "聊天已存在",
			Error:   "Chat already exists",
			Code:    http.StatusConflict,
		})
		return
	}

	// 创建聊天
	chat := models.Chat{}
	if err := config.DB.Create(&chat).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "创建聊天失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 添加参与者
	for _, participantID := range participantIDs {
		participant := models.ChatParticipant{
			ChatID: chat.ID,
			UserID: participantID,
		}
		config.DB.Create(&participant)
	}

	// 重新加载数据
	config.DB.Preload("Participants").First(&chat, chat.ID)

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "创建聊天成功",
		Data:    chat,
	})
}

// MarkAsRead 标记消息为已读
func (mc *MessagesController) MarkAsRead(c *gin.Context) {
	chatIDStr := c.Param("id")
	chatID, err := strconv.ParseUint(chatIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的聊天ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

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

	// 检查用户是否参与此聊天
	var participant models.ChatParticipant
	if err := config.DB.Where("chat_id = ? AND user_id = ?", uint(chatID), currentUser.ID).
		First(&participant).Error; err != nil {
		c.JSON(http.StatusForbidden, models.ErrorResponse{
			Success: false,
			Message: "无权访问此聊天",
			Error:   "Access denied",
			Code:    http.StatusForbidden,
		})
		return
	}

	// 标记该聊天中所有消息为已读
	if err := config.DB.Model(&models.Message{}).
		Where("chat_id = ? AND sender_id != ?", uint(chatID), currentUser.ID).
		Update("is_read", true).Error; err != nil {
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
	})
}

// GetUnreadCount 获取未读消息数量
func (mc *MessagesController) GetUnreadCount(c *gin.Context) {
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

	var result struct {
		Total  int64          `json:"total"`
		ByChat map[uint]int64 `json:"by_chat"`
	}

	result.ByChat = make(map[uint]int64)

	// 获取用户参与的聊天
	var chatIDs []uint
	config.DB.Table("chat_participants").
		Select("chat_id").
		Where("user_id = ?", currentUser.ID).
		Pluck("chat_id", &chatIDs)

	// 统计每个聊天的未读消息数
	for _, chatID := range chatIDs {
		var count int64
		config.DB.Model(&models.Message{}).
			Where("chat_id = ? AND sender_id != ? AND is_read = ?", chatID, currentUser.ID, false).
			Count(&count)
		result.ByChat[chatID] = count
		result.Total += count
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取未读消息数量成功",
		Data:    result,
	})
}
