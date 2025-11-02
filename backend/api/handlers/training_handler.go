package handlers

import (
	"net/http"
	"strconv"

	"gymates-backend/models"
	"gymates-backend/repositories"

	"github.com/gin-gonic/gin"
)

// TrainingHandler handles training-related requests
type TrainingHandler struct {
	trainingRepo *repositories.TrainingRepository
}

// NewTrainingHandler creates a new training handler
func NewTrainingHandler() *TrainingHandler {
	return &TrainingHandler{
		trainingRepo: repositories.NewTrainingRepository(),
	}
}

// GetTrainingPlans retrieves a list of training plans
func (h *TrainingHandler) GetTrainingPlans(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	var userID *uint
	if userIDStr := c.Query("user_id"); userIDStr != "" {
		if id, err := strconv.ParseUint(userIDStr, 10, 32); err == nil {
			uid := uint(id)
			userID = &uid
		}
	}

	var isPublic *bool
	if isPublicStr := c.Query("is_public"); isPublicStr != "" {
		if isPublicStr == "true" {
			val := true
			isPublic = &val
		} else if isPublicStr == "false" {
			val := false
			isPublic = &val
		}
	}

	plans, total, err := h.trainingRepo.ListPlans(page, limit, userID, isPublic)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取训练计划列表失败",
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
		Message: "获取训练计划列表成功",
		Data: gin.H{
			"plans":      plans,
			"pagination": pagination,
		},
	})
}

// GetTrainingPlan retrieves a single training plan by ID
func (h *TrainingHandler) GetTrainingPlan(c *gin.Context) {
	planIDStr := c.Param("id")
	planID, err := strconv.ParseUint(planIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的训练计划ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	plan, err := h.trainingRepo.GetPlanByID(uint(planID))
	if err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "训练计划不存在",
			Error:   err.Error(),
			Code:    http.StatusNotFound,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取训练计划成功",
		Data:    plan,
	})
}

// CreateTrainingPlan creates a new training plan
func (h *TrainingHandler) CreateTrainingPlan(c *gin.Context) {
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

	var req models.CreateTrainingPlanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	plan := models.TrainingPlan{
		UserID:         currentUser.ID,
		Name:           req.Name,
		Description:    req.Description,
		Duration:       req.Duration,
		CaloriesBurned: req.CaloriesBurned,
		Difficulty:     req.Difficulty,
		IsPublic:       req.IsPublic,
	}

	if err := h.trainingRepo.CreatePlan(&plan); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "创建训练计划失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "创建训练计划成功",
		Data:    plan,
	})
}

// UpdateTrainingPlan updates an existing training plan
func (h *TrainingHandler) UpdateTrainingPlan(c *gin.Context) {
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

	planIDStr := c.Param("id")
	planID, err := strconv.ParseUint(planIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的训练计划ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	plan, err := h.trainingRepo.GetPlanByID(uint(planID))
	if err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "训练计划不存在",
			Error:   err.Error(),
			Code:    http.StatusNotFound,
		})
		return
	}

	// Check if user owns the plan
	if plan.UserID != currentUser.ID {
		c.JSON(http.StatusForbidden, models.ErrorResponse{
			Success: false,
			Message: "无权限修改此训练计划",
			Error:   "Forbidden",
			Code:    http.StatusForbidden,
		})
		return
	}

	var req models.CreateTrainingPlanRequest // Reuse CreateTrainingPlanRequest for updates
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Update fields
	if req.Name != "" {
		plan.Name = req.Name
	}
	if req.Description != "" {
		plan.Description = req.Description
	}
	if req.Duration > 0 {
		plan.Duration = req.Duration
	}
	if req.CaloriesBurned > 0 {
		plan.CaloriesBurned = req.CaloriesBurned
	}
	if req.Difficulty != "" {
		plan.Difficulty = req.Difficulty
	}
	plan.IsPublic = req.IsPublic

	if err := h.trainingRepo.UpdatePlan(plan); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "更新训练计划失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "更新训练计划成功",
		Data:    plan,
	})
}

// DeleteTrainingPlan deletes a training plan
func (h *TrainingHandler) DeleteTrainingPlan(c *gin.Context) {
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

	planIDStr := c.Param("id")
	planID, err := strconv.ParseUint(planIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的训练计划ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	plan, err := h.trainingRepo.GetPlanByID(uint(planID))
	if err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "训练计划不存在",
			Error:   err.Error(),
			Code:    http.StatusNotFound,
		})
		return
	}

	// Check if user owns the plan
	if plan.UserID != currentUser.ID {
		c.JSON(http.StatusForbidden, models.ErrorResponse{
			Success: false,
			Message: "无权限删除此训练计划",
			Error:   "Forbidden",
			Code:    http.StatusForbidden,
		})
		return
	}

	if err := h.trainingRepo.DeletePlan(uint(planID)); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "删除训练计划失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "删除训练计划成功",
		Data:    nil,
	})
}

