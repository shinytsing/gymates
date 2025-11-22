package handlers

import (
	"net/http"
	"strconv"

	"gymates-backend/models"
	"gymates-backend/repositories"

	"github.com/gin-gonic/gin"
)

// MatesHandler handles mate-related requests
type MatesHandler struct {
	mateRepo *repositories.MateRepository
	userRepo *repositories.UserRepository
}

// NewMatesHandler creates a new mates handler
func NewMatesHandler() *MatesHandler {
	return &MatesHandler{
		mateRepo: repositories.NewMateRepository(),
		userRepo: repositories.NewUserRepository(),
	}
}

// GetMates retrieves all mates for the current user
func (h *MatesHandler) GetMates(c *gin.Context) {
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
	status := c.Query("status")

	var statusPtr *string
	if status != "" {
		statusPtr = &status
	}

	mates, err := h.mateRepo.GetMatesByUserID(currentUser.ID, statusPtr)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取搭子列表失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取搭子列表成功",
		Data:    mates,
	})
}

// GetPendingRequests retrieves pending mate requests
func (h *MatesHandler) GetPendingRequests(c *gin.Context) {
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

	requests, err := h.mateRepo.GetPendingRequests(currentUser.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取待处理请求失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取待处理请求成功",
		Data:    requests,
	})
}

// SendMateRequest sends a mate request
func (h *MatesHandler) SendMateRequest(c *gin.Context) {
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

	var req models.SendMateRequestRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Check if mate user exists
	_, err := h.userRepo.GetByID(req.MateID)
	if err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "目标用户不存在",
			Error:   err.Error(),
			Code:    http.StatusNotFound,
		})
		return
	}

	// Check for existing relationship
	existing, err := h.mateRepo.CheckExistingRelationship(currentUser.ID, req.MateID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "检查关系失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	if existing != nil {
		c.JSON(http.StatusConflict, models.ErrorResponse{
			Success: false,
			Message: "已存在搭子关系",
			Error:   "Relationship already exists",
			Code:    http.StatusConflict,
		})
		return
	}

	// Create mate request
	mate := models.Mate{
		UserID: currentUser.ID,
		MateID: req.MateID,
		Status: "pending",
	}

	if err := h.mateRepo.CreateMateRequest(&mate); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "发送搭子请求失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "发送搭子请求成功",
		Data:    mate,
	})
}

// AcceptMateRequest accepts a mate request
func (h *MatesHandler) AcceptMateRequest(c *gin.Context) {
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

	mateIDStr := c.Param("id")
	mateID, err := strconv.ParseUint(mateIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的搭子ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	if err := h.mateRepo.UpdateMateStatus(uint(mateID), "accepted"); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "接受搭子请求失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "接受搭子请求成功",
		Data:    nil,
	})
}

// RejectMateRequest rejects a mate request
func (h *MatesHandler) RejectMateRequest(c *gin.Context) {
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

	mateIDStr := c.Param("id")
	mateID, err := strconv.ParseUint(mateIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的搭子ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	if err := h.mateRepo.UpdateMateStatus(uint(mateID), "rejected"); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "拒绝搭子请求失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "拒绝搭子请求成功",
		Data:    nil,
	})
}

// FindPotentialMates finds potential mates based on preferences
func (h *MatesHandler) FindPotentialMates(c *gin.Context) {
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

	// Build preferences from query parameters
	preferences := make(map[string]interface{})
	if location := c.Query("location"); location != "" {
		preferences["location"] = location
	}
	if trainingTypes := c.Query("training_types"); trainingTypes != "" {
		preferences["training_types"] = trainingTypes
	}
	if experience := c.Query("experience"); experience != "" {
		preferences["experience"] = experience
	}

	potentialMates, err := h.mateRepo.FindPotentialMates(currentUser.ID, preferences)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "查找潜在搭子失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "查找潜在搭子成功",
		Data:    potentialMates,
	})
}

// GetMateRecommendations gets mate recommendations based on user preferences
func (h *MatesHandler) GetMateRecommendations(c *gin.Context) {
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

	// Build preferences from query parameters
	preferences := make(map[string]interface{})
	if location := c.Query("location"); location != "" {
		preferences["location"] = location
	}
	if trainingTypes := c.Query("training_types"); trainingTypes != "" {
		preferences["training_types"] = trainingTypes
	}
	if experience := c.Query("experience"); experience != "" {
		preferences["experience"] = experience
	}
	if gender := c.Query("gender"); gender != "" {
		preferences["gender"] = gender
	}
	if ageMin := c.Query("age_min"); ageMin != "" {
		preferences["age_min"] = ageMin
	}
	if ageMax := c.Query("age_max"); ageMax != "" {
		preferences["age_max"] = ageMax
	}

	// Use FindPotentialMates as the recommendation engine
	recommendations, err := h.mateRepo.FindPotentialMates(currentUser.ID, preferences)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取推荐搭子失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// Format response to match frontend expectations
	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取推荐搭子成功",
		Data: gin.H{
			"recommendations": recommendations,
			"total":           len(recommendations),
		},
	})
}

