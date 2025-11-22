package controllers

import (
	"net/http"
	"strconv"

	"gymates-backend/config"
	"gymates-backend/models"

	"github.com/gin-gonic/gin"
)

// NotificationsController 通知控制器
type NotificationsController struct{}

// NewNotificationsController 创建通知控制器
func NewNotificationsController() *NotificationsController {
	return &NotificationsController{}
}

// GetNotifications 获取通知列表
func (nc *NotificationsController) GetNotifications(c *gin.Context) {
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
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	notifType := c.Query("type") // 可选过滤：system, social, like, comment, follow, invite, challenge, reward

	currentUser := user.(*models.User)

	var notifications []models.Notification
	var total int64

	query := config.DB.Model(&models.Notification{}).Where("user_id = ?", currentUser.ID)

	// 按类型过滤
	if notifType != "" {
		query = query.Where("type = ?", notifType)
	}

	// 获取总数
	query.Count(&total)

	// 分页查询
	offset := (page - 1) * limit
	if err := query.Offset(offset).Limit(limit).
		Order("created_at DESC").Find(&notifications).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取通知失败",
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
		Message: "获取通知成功",
		Data: models.NotificationsResponse{
			Notifications: notifications,
			Pagination:    pagination,
		},
	})
}

// GetUnreadNotificationsCount 获取未读通知数量
func (nc *NotificationsController) GetUnreadNotificationsCount(c *gin.Context) {
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

	var count int64
	config.DB.Model(&models.Notification{}).
		Where("user_id = ? AND is_read = ?", currentUser.ID, false).
		Count(&count)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取未读通知数量成功",
		Data: gin.H{
			"count": count,
		},
	})
}

// MarkNotificationAsRead 标记单个通知为已读
func (nc *NotificationsController) MarkNotificationAsRead(c *gin.Context) {
	notifIDStr := c.Param("id")
	notifID, err := strconv.ParseUint(notifIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的通知ID",
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

	// 检查通知是否属于当前用户
	var notification models.Notification
	if err := config.DB.Where("id = ? AND user_id = ?", uint(notifID), currentUser.ID).
		First(&notification).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "通知不存在",
			Error:   "Notification not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 标记为已读
	if err := config.DB.Model(&notification).Update("is_read", true).Error; err != nil {
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
		Data:    notification,
	})
}

// MarkAllNotificationsAsRead 标记所有通知为已读
func (nc *NotificationsController) MarkAllNotificationsAsRead(c *gin.Context) {
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

	// 标记所有未读通知为已读
	if err := config.DB.Model(&models.Notification{}).
		Where("user_id = ? AND is_read = ?", currentUser.ID, false).
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
		Message: "标记所有通知已读成功",
	})
}

// DeleteNotification 删除通知
func (nc *NotificationsController) DeleteNotification(c *gin.Context) {
	notifIDStr := c.Param("id")
	notifID, err := strconv.ParseUint(notifIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的通知ID",
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

	// 检查通知是否属于当前用户
	var notification models.Notification
	if err := config.DB.Where("id = ? AND user_id = ?", uint(notifID), currentUser.ID).
		First(&notification).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "通知不存在",
			Error:   "Notification not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 删除通知
	if err := config.DB.Delete(&notification).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "删除通知失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "删除通知成功",
	})
}

// CreateNotification 创建通知（内部使用或管理员使用）
func (nc *NotificationsController) CreateNotification(c *gin.Context) {
	var req struct {
		UserID  uint                   `json:"user_id" binding:"required"`
		Title   string                 `json:"title" binding:"required"`
		Content string                 `json:"content" binding:"required"`
		Type    string                 `json:"type" binding:"required"` // system, social, like, comment, follow, invite, challenge, reward
		Data    map[string]interface{} `json:"data"`
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

	// 创建通知
	notification := models.Notification{
		UserID:  req.UserID,
		Title:   req.Title,
		Content: req.Content,
		Type:    req.Type,
		IsRead:  false,
	}

	if err := config.DB.Create(&notification).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "创建通知失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "创建通知成功",
		Data:    notification,
	})
}
