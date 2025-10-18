package controllers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gymates-backend/config"
	"gymates-backend/models"
)

// TrainingController 训练控制器
type TrainingController struct{}

// NewTrainingController 创建训练控制器
func NewTrainingController() *TrainingController {
	return &TrainingController{}
}

// GetTrainingPlans 获取训练计划列表
func (tc *TrainingController) GetTrainingPlans(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	userIDStr := c.Query("user_id")

	var plans []models.TrainingPlan
	var total int64

	query := config.DB.Model(&models.TrainingPlan{}).Where("is_public = ?", true)

	// 如果指定了用户ID，则包含该用户的私有计划
	if userIDStr != "" {
		userID, err := strconv.ParseUint(userIDStr, 10, 32)
		if err == nil {
			query = query.Or("user_id = ?", uint(userID))
		}
	}

	// 获取总数
	query.Count(&total)

	// 分页查询
	offset := (page - 1) * limit
	if err := query.Preload("User").Preload("Exercises").
		Offset(offset).Limit(limit).Order("created_at DESC").Find(&plans).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取训练计划失败",
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
		Message: "获取训练计划成功",
		Data: models.TrainingPlansResponse{
			Plans:      plans,
			Pagination: pagination,
		},
	})
}

// GetTrainingPlan 获取单个训练计划
func (tc *TrainingController) GetTrainingPlan(c *gin.Context) {
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

	var plan models.TrainingPlan
	if err := config.DB.Preload("User").Preload("Exercises").
		First(&plan, uint(planID)).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "训练计划不存在",
			Error:   "Training plan not found",
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

// CreateTrainingPlan 创建训练计划
func (tc *TrainingController) CreateTrainingPlan(c *gin.Context) {
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

	currentUser := user.(*models.User)

	// 创建训练计划
	plan := models.TrainingPlan{
		UserID:         currentUser.ID,
		Name:           req.Name,
		Description:    req.Description,
		Duration:       req.Duration,
		CaloriesBurned: req.CaloriesBurned,
		Difficulty:     req.Difficulty,
		IsPublic:       req.IsPublic,
	}

	if err := config.DB.Create(&plan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "创建训练计划失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 创建训练动作
	for i, exerciseReq := range req.Exercises {
		exercise := models.Exercise{
			TrainingPlanID: plan.ID,
			Name:           exerciseReq.Name,
			Sets:           exerciseReq.Sets,
			Reps:           exerciseReq.Reps,
			Weight:         exerciseReq.Weight,
			Duration:       exerciseReq.Duration,
			RestTime:       exerciseReq.RestTime,
			Instructions:   exerciseReq.Instructions,
			ImageURL:       exerciseReq.ImageURL,
			Order:          i + 1,
		}
		if err := config.DB.Create(&exercise).Error; err != nil {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "创建训练动作失败",
				Error:   err.Error(),
				Code:    http.StatusInternalServerError,
			})
			return
		}
	}

	// 重新加载数据
	config.DB.Preload("User").Preload("Exercises").First(&plan, plan.ID)

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "创建训练计划成功",
		Data:    plan,
	})
}

// StartWorkoutSession 开始训练会话
func (tc *TrainingController) StartWorkoutSession(c *gin.Context) {
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

	var req models.StartWorkoutSessionRequest
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

	// 检查训练计划是否存在
	var plan models.TrainingPlan
	if err := config.DB.First(&plan, req.TrainingPlanID).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "训练计划不存在",
			Error:   "Training plan not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 创建训练会话
	session := models.WorkoutSession{
		UserID:         currentUser.ID,
		TrainingPlanID: plan.ID,
		Status:         "ongoing",
		Progress:       0,
	}

	if err := config.DB.Create(&session).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "创建训练会话失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 重新加载数据
	config.DB.Preload("User").Preload("TrainingPlan").First(&session, session.ID)

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "开始训练会话成功",
		Data:    session,
	})
}

// UpdateWorkoutProgress 更新训练进度
func (tc *TrainingController) UpdateWorkoutProgress(c *gin.Context) {
	sessionIDStr := c.Param("id")
	sessionID, err := strconv.ParseUint(sessionIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的训练会话ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	var req models.UpdateWorkoutProgressRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	var session models.WorkoutSession
	if err := config.DB.First(&session, uint(sessionID)).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "训练会话不存在",
			Error:   "Workout session not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 更新进度
	if err := config.DB.Model(&session).Update("progress", req.Progress).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "更新训练进度失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 重新加载数据
	config.DB.Preload("User").Preload("TrainingPlan").First(&session, session.ID)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "更新训练进度成功",
		Data:    session,
	})
}

// CompleteWorkoutSession 完成训练会话
func (tc *TrainingController) CompleteWorkoutSession(c *gin.Context) {
	sessionIDStr := c.Param("id")
	sessionID, err := strconv.ParseUint(sessionIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的训练会话ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	var session models.WorkoutSession
	if err := config.DB.First(&session, uint(sessionID)).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "训练会话不存在",
			Error:   "Workout session not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 更新会话状态
	updates := map[string]interface{}{
		"status":     "completed",
		"progress":   100,
		"end_time":   "NOW()",
	}

	if err := config.DB.Model(&session).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "完成训练会话失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 重新加载数据
	config.DB.Preload("User").Preload("TrainingPlan").First(&session, session.ID)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "完成训练会话成功",
		Data:    session,
	})
}

// SearchExercises 搜索训练动作
func (tc *TrainingController) SearchExercises(c *gin.Context) {
	query := c.Query("q")
	muscleGroup := c.Query("muscle_group")
	difficulty := c.Query("difficulty")
	equipment := c.Query("equipment")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	var exercises []models.Exercise
	var total int64

	// 构建查询条件
	dbQuery := config.DB.Model(&models.Exercise{})

	// 如果有搜索关键词，进行模糊搜索
	if query != "" {
		dbQuery = dbQuery.Where("name LIKE ? OR instructions LIKE ?", "%"+query+"%", "%"+query+"%")
	}

	// 如果指定了肌群
	if muscleGroup != "" {
		dbQuery = dbQuery.Where("muscle_group = ?", muscleGroup)
	}

	// 如果指定了难度
	if difficulty != "" {
		dbQuery = dbQuery.Where("difficulty = ?", difficulty)
	}

	// 如果指定了器械
	if equipment != "" {
		dbQuery = dbQuery.Where("equipment = ?", equipment)
	}

	// 获取总数
	dbQuery.Count(&total)

	// 分页查询
	offset := (page - 1) * limit
	if err := dbQuery.Offset(offset).Limit(limit).Order("name ASC").Find(&exercises).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "搜索训练动作失败",
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
		Message: "搜索训练动作成功",
		Data: models.ExercisesResponse{
			Exercises:  exercises,
			Pagination: pagination,
		},
	})
}

// GetAllExercises 获取所有训练动作
func (tc *TrainingController) GetAllExercises(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	muscleGroup := c.Query("muscle_group")
	difficulty := c.Query("difficulty")

	var exercises []models.Exercise
	var total int64

	// 构建查询条件
	dbQuery := config.DB.Model(&models.Exercise{})

	if muscleGroup != "" {
		dbQuery = dbQuery.Where("muscle_group = ?", muscleGroup)
	}

	if difficulty != "" {
		dbQuery = dbQuery.Where("difficulty = ?", difficulty)
	}

	// 获取总数
	dbQuery.Count(&total)

	// 分页查询
	offset := (page - 1) * limit
	if err := dbQuery.Offset(offset).Limit(limit).Order("name ASC").Find(&exercises).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取训练动作失败",
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
		Message: "获取训练动作成功",
		Data: models.ExercisesResponse{
			Exercises:  exercises,
			Pagination: pagination,
		},
	})
}

// GetWorkoutHistory 获取训练历史
func (tc *TrainingController) GetWorkoutHistory(c *gin.Context) {
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

	var sessions []models.WorkoutSession
	var total int64

	// 获取总数
	config.DB.Model(&models.WorkoutSession{}).Where("user_id = ?", currentUser.ID).Count(&total)

	// 分页查询
	offset := (page - 1) * limit
	if err := config.DB.Where("user_id = ?", currentUser.ID).
		Preload("User").Preload("TrainingPlan").
		Offset(offset).Limit(limit).Order("created_at DESC").Find(&sessions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取训练历史失败",
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
		Message: "获取训练历史成功",
		Data: models.WorkoutSessionsResponse{
			Sessions:   sessions,
			Pagination: pagination,
		},
	})
}
