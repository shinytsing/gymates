package controllers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gymates-backend/config"
	"gymates-backend/models"
)

// WeeklyTrainingPlanController 一周训练计划控制器
type WeeklyTrainingPlanController struct{}

// NewWeeklyTrainingPlanController 创建一周训练计划控制器
func NewWeeklyTrainingPlanController() *WeeklyTrainingPlanController {
	return &WeeklyTrainingPlanController{}
}

// GetWeeklyTrainingPlans 获取一周训练计划列表
func (wtc *WeeklyTrainingPlanController) GetWeeklyTrainingPlans(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	userIDStr := c.Query("user_id")

	var plans []models.WeeklyTrainingPlan
	var total int64

	query := config.DB.Model(&models.WeeklyTrainingPlan{}).Where("is_public = ?", true)

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
	if err := query.Preload("User").Preload("Days.Parts.Exercises").
		Offset(offset).Limit(limit).Order("created_at DESC").Find(&plans).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取一周训练计划失败",
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
		Message: "获取一周训练计划成功",
		Data: models.WeeklyTrainingPlansResponse{
			Plans:      plans,
			Pagination: pagination,
		},
	})
}

// GetWeeklyTrainingPlan 获取单个一周训练计划
func (wtc *WeeklyTrainingPlanController) GetWeeklyTrainingPlan(c *gin.Context) {
	planIDStr := c.Param("id")
	planID, err := strconv.ParseUint(planIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的一周训练计划ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	var plan models.WeeklyTrainingPlan
	if err := config.DB.Preload("User").Preload("Days.Parts.Exercises").
		First(&plan, uint(planID)).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "一周训练计划不存在",
			Error:   "Weekly training plan not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取一周训练计划成功",
		Data: models.WeeklyTrainingPlanResponse{
			Plan: plan,
		},
	})
}

// CreateWeeklyTrainingPlan 创建一周训练计划
func (wtc *WeeklyTrainingPlanController) CreateWeeklyTrainingPlan(c *gin.Context) {
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

	var req models.CreateWeeklyTrainingPlanRequest
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

	// 开始事务
	tx := config.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 创建一周训练计划
	plan := models.WeeklyTrainingPlan{
		UserID:      currentUser.ID,
		Name:        req.Name,
		Description: req.Description,
		IsPublic:    req.IsPublic,
	}

	if err := tx.Create(&plan).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "创建一周训练计划失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 创建训练日
	for _, dayReq := range req.Days {
		day := models.TrainingDay{
			WeeklyTrainingPlanID: plan.ID,
			DayOfWeek:            dayReq.DayOfWeek,
			DayName:              dayReq.DayName,
			IsRestDay:            dayReq.IsRestDay,
			Notes:                dayReq.Notes,
		}

		if err := tx.Create(&day).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "创建训练日失败",
				Error:   err.Error(),
				Code:    http.StatusInternalServerError,
			})
			return
		}

		// 创建训练部位
		for _, partReq := range dayReq.Parts {
			part := models.TrainingPart{
				TrainingDayID:     day.ID,
				MuscleGroup:       partReq.MuscleGroup,
				MuscleGroupName:   partReq.MuscleGroupName,
				Order:             partReq.Order,
			}

			if err := tx.Create(&part).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, models.ErrorResponse{
					Success: false,
					Message: "创建训练部位失败",
					Error:   err.Error(),
					Code:    http.StatusInternalServerError,
				})
				return
			}

			// 创建训练动作
			for _, exerciseReq := range partReq.Exercises {
				exercise := models.Exercise{
					TrainingPlanID:  plan.ID, // 保持与原有模型的兼容性
					TrainingPartID:  &part.ID,
					Name:            exerciseReq.Name,
					Description:     exerciseReq.Description,
					MuscleGroup:     exerciseReq.MuscleGroup,
					Sets:            exerciseReq.Sets,
					Reps:            exerciseReq.Reps,
					Weight:          exerciseReq.Weight,
					Duration:        exerciseReq.Duration,
					RestTime:        exerciseReq.RestTime,
					RestSeconds:     exerciseReq.RestSeconds,
					Instructions:    exerciseReq.Instructions,
					ImageURL:        exerciseReq.ImageURL,
					VideoURL:        exerciseReq.VideoURL,
					Notes:           exerciseReq.Notes,
					Order:           exerciseReq.Order,
				}

				if err := tx.Create(&exercise).Error; err != nil {
					tx.Rollback()
					c.JSON(http.StatusInternalServerError, models.ErrorResponse{
						Success: false,
						Message: "创建训练动作失败",
						Error:   err.Error(),
						Code:    http.StatusInternalServerError,
					})
					return
				}
			}
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "保存训练计划失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 重新加载数据
	config.DB.Preload("User").Preload("Days.Parts.Exercises").First(&plan, plan.ID)

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "创建一周训练计划成功",
		Data: models.WeeklyTrainingPlanResponse{
			Plan: plan,
		},
	})
}

// UpdateWeeklyTrainingPlan 更新一周训练计划
func (wtc *WeeklyTrainingPlanController) UpdateWeeklyTrainingPlan(c *gin.Context) {
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

	planIDStr := c.Param("id")
	planID, err := strconv.ParseUint(planIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的一周训练计划ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	var req models.UpdateWeeklyTrainingPlanRequest
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

	// 检查计划是否存在且属于当前用户
	var plan models.WeeklyTrainingPlan
	if err := config.DB.Where("id = ? AND user_id = ?", uint(planID), currentUser.ID).
		First(&plan).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "一周训练计划不存在或无权限",
			Error:   "Weekly training plan not found or no permission",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 开始事务
	tx := config.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 更新计划基本信息
	updates := map[string]interface{}{
		"updated_at": time.Now(),
	}

	if req.Name != "" {
		updates["name"] = req.Name
	}
	if req.Description != "" {
		updates["description"] = req.Description
	}
	if req.IsPublic != nil {
		updates["is_public"] = *req.IsPublic
	}

	if err := tx.Model(&plan).Updates(updates).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "更新训练计划失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 更新训练日
	if len(req.Days) > 0 {
		// 删除现有的训练日和相关数据
		if err := tx.Where("weekly_training_plan_id = ?", plan.ID).Delete(&models.TrainingDay{}).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "删除现有训练日失败",
				Error:   err.Error(),
				Code:    http.StatusInternalServerError,
			})
			return
		}

		// 创建新的训练日
		for _, dayReq := range req.Days {
			day := models.TrainingDay{
				WeeklyTrainingPlanID: plan.ID,
				DayOfWeek:            dayReq.DayOfWeek,
				DayName:              dayReq.DayName,
				IsRestDay:            dayReq.IsRestDay,
				Notes:                dayReq.Notes,
			}

			if err := tx.Create(&day).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, models.ErrorResponse{
					Success: false,
					Message: "创建训练日失败",
					Error:   err.Error(),
					Code:    http.StatusInternalServerError,
				})
				return
			}

			// 创建训练部位
			for _, partReq := range dayReq.Parts {
				part := models.TrainingPart{
					TrainingDayID:     day.ID,
					MuscleGroup:       partReq.MuscleGroup,
					MuscleGroupName:   partReq.MuscleGroupName,
					Order:             partReq.Order,
				}

				if err := tx.Create(&part).Error; err != nil {
					tx.Rollback()
					c.JSON(http.StatusInternalServerError, models.ErrorResponse{
						Success: false,
						Message: "创建训练部位失败",
						Error:   err.Error(),
						Code:    http.StatusInternalServerError,
					})
					return
				}

				// 创建训练动作
				for _, exerciseReq := range partReq.Exercises {
					exercise := models.Exercise{
						TrainingPlanID:  plan.ID,
						TrainingPartID:  &part.ID,
						Name:            exerciseReq.Name,
						Description:     exerciseReq.Description,
						MuscleGroup:     exerciseReq.MuscleGroup,
						Sets:            exerciseReq.Sets,
						Reps:            exerciseReq.Reps,
						Weight:          exerciseReq.Weight,
						Duration:        exerciseReq.Duration,
						RestTime:        exerciseReq.RestTime,
						RestSeconds:     exerciseReq.RestSeconds,
						Instructions:    exerciseReq.Instructions,
						ImageURL:        exerciseReq.ImageURL,
						VideoURL:        exerciseReq.VideoURL,
						Notes:           exerciseReq.Notes,
						IsCompleted:     exerciseReq.IsCompleted != nil && *exerciseReq.IsCompleted,
						Order:           exerciseReq.Order,
					}

					if err := tx.Create(&exercise).Error; err != nil {
						tx.Rollback()
						c.JSON(http.StatusInternalServerError, models.ErrorResponse{
							Success: false,
							Message: "创建训练动作失败",
							Error:   err.Error(),
							Code:    http.StatusInternalServerError,
						})
						return
					}
				}
			}
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "更新训练计划失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 重新加载数据
	config.DB.Preload("User").Preload("Days.Parts.Exercises").First(&plan, plan.ID)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "更新一周训练计划成功",
		Data: models.WeeklyTrainingPlanResponse{
			Plan: plan,
		},
	})
}

// DeleteWeeklyTrainingPlan 删除一周训练计划
func (wtc *WeeklyTrainingPlanController) DeleteWeeklyTrainingPlan(c *gin.Context) {
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

	planIDStr := c.Param("id")
	planID, err := strconv.ParseUint(planIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的一周训练计划ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	currentUser := user.(*models.User)

	// 检查计划是否存在且属于当前用户
	var plan models.WeeklyTrainingPlan
	if err := config.DB.Where("id = ? AND user_id = ?", uint(planID), currentUser.ID).
		First(&plan).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "一周训练计划不存在或无权限",
			Error:   "Weekly training plan not found or no permission",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 软删除计划（GORM会自动处理关联数据的软删除）
	if err := config.DB.Delete(&plan).Error; err != nil {
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
		Message: "删除一周训练计划成功",
		Data:    nil,
	})
}

// GetTodayTraining 获取今日训练内容
func (wtc *WeeklyTrainingPlanController) GetTodayTraining(c *gin.Context) {
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

	// 获取今日是星期几 (1-7, 1=周一)
	today := int(time.Now().Weekday())
	if today == 0 {
		today = 7 // 周日
	}

	// 查找用户的活动训练计划
	var plan models.WeeklyTrainingPlan
	if err := config.DB.Where("user_id = ? AND is_active = ?", currentUser.ID, true).
		Preload("Days", "day_of_week = ?", today).
		Preload("Days.Parts.Exercises").
		First(&plan).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "未找到今日训练计划",
			Error:   "No training plan found for today",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 查找今日的训练日
	var todayTraining *models.TrainingDay
	for _, day := range plan.Days {
		if day.DayOfWeek == today {
			todayTraining = &day
			break
		}
	}

	if todayTraining == nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "今日为休息日",
			Error:   "Today is a rest day",
			Code:    http.StatusNotFound,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取今日训练内容成功",
		Data:    todayTraining,
	})
}

// GetAIRecommendations 获取AI推荐动作 (已废弃，使用新的AI推荐接口)
func (wtc *WeeklyTrainingPlanController) GetAIRecommendations(c *gin.Context) {
	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "请使用新的AI推荐接口: /api/training/ai/recommend",
		Data: models.AIRecommendationResponse{
			UserID: 0,
			Day:    "",
			Parts:  []models.RecommendedPart{},
			Mode:   "",
			Target: "",
		},
	})
}
