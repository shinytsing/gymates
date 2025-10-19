package controllers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gymates-backend/config"
	"gymates-backend/models"
)

// TrainingPlanController 训练计划控制器
type TrainingPlanController struct{}

// NewTrainingPlanController 创建训练计划控制器
func NewTrainingPlanController() *TrainingPlanController {
	return &TrainingPlanController{}
}

// GetTrainingPlan 获取用户训练计划
// GET /api/training/plan?user_id={uid}
func (tpc *TrainingPlanController) GetTrainingPlan(c *gin.Context) {
	userIDStr := c.Query("user_id")
	if userIDStr == "" {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "用户ID不能为空",
			Error:   "user_id is required",
			Code:    http.StatusBadRequest,
		})
		return
	}

	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的用户ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 查找用户的一周训练计划
	var plan models.WeeklyTrainingPlan
	if err := config.DB.Where("user_id = ? AND is_active = ?", uint(userID), true).
		Preload("Days.Parts.Exercises").
		First(&plan).Error; err != nil {
		// 如果没有找到计划，返回空计划结构
		plan = models.WeeklyTrainingPlan{
			UserID:      uint(userID),
			Name:        "我的训练计划",
			Description: "个性化训练计划",
			Days:        createEmptyWeekDays(),
			IsActive:    true,
			IsPublic:    false,
		}
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取训练计划成功",
		Data:    plan,
	})
}

// UpdateTrainingPlan 更新训练计划
// POST /api/training/plan/update
func (tpc *TrainingPlanController) UpdateTrainingPlan(c *gin.Context) {
	var req struct {
		UserID uint                    `json:"user_id" binding:"required"`
		Plan   []TrainingDayRequest    `json:"plan" binding:"required"`
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

	// 开始事务
	tx := config.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 查找或创建用户的一周训练计划
	var plan models.WeeklyTrainingPlan
	if err := tx.Where("user_id = ?", req.UserID).First(&plan).Error; err != nil {
		// 创建新计划
		plan = models.WeeklyTrainingPlan{
			UserID:      req.UserID,
			Name:        "我的训练计划",
			Description: "个性化训练计划",
			IsActive:    true,
			IsPublic:    false,
		}
		if err := tx.Create(&plan).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "创建训练计划失败",
				Error:   err.Error(),
				Code:    http.StatusInternalServerError,
			})
			return
		}
	}

	// 删除现有的训练日
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
	for _, dayReq := range req.Plan {
		day := models.TrainingDay{
			WeeklyTrainingPlanID: plan.ID,
			DayOfWeek:            getDayOfWeek(dayReq.Day),
			DayName:              dayReq.Day,
			IsRestDay:            len(dayReq.Parts) == 0,
			Notes:                "",
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
				MuscleGroup:       getMuscleGroupKey(partReq.PartName),
				MuscleGroupName:   partReq.PartName,
				Order:             0,
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
					MuscleGroup:     getMuscleGroupKey(partReq.PartName),
					Sets:            exerciseReq.Sets,
					Reps:            exerciseReq.Reps,
					Weight:          exerciseReq.Weight,
					RestSeconds:     exerciseReq.RestSeconds,
					Notes:           exerciseReq.Notes,
					Order:           0,
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
	config.DB.Preload("Days.Parts.Exercises").First(&plan, plan.ID)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "更新训练计划成功",
		Data:    plan,
	})
}

// 请求结构体
type TrainingDayRequest struct {
	Day   string                `json:"day"`
	Parts []TrainingPartRequest `json:"parts"`
}

type TrainingPartRequest struct {
	PartName  string                    `json:"part_name"`
	Exercises []TrainingExerciseRequest `json:"exercises"`
}

type TrainingExerciseRequest struct {
	Name        string  `json:"name"`
	Sets        int     `json:"sets"`
	Reps        int     `json:"reps"`
	Weight      float64 `json:"weight"`
	RestSeconds int     `json:"rest_seconds"`
	Notes       string  `json:"notes"`
	Description string  `json:"description"`
}

// 辅助函数
func createEmptyWeekDays() []models.TrainingDay {
	dayNames := []string{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}
	days := make([]models.TrainingDay, 7)
	
	for i, dayName := range dayNames {
		days[i] = models.TrainingDay{
			DayOfWeek: i + 1,
			DayName:   dayName,
			Parts:     []models.TrainingPart{},
			IsRestDay: true,
		}
	}
	
	return days
}

func getDayOfWeek(dayName string) int {
	dayMap := map[string]int{
		"Monday":    1,
		"Tuesday":   2,
		"Wednesday": 3,
		"Thursday":  4,
		"Friday":    5,
		"Saturday":  6,
		"Sunday":    7,
	}
	return dayMap[dayName]
}

func getMuscleGroupKey(partName string) string {
	partMap := map[string]string{
		"Chest":     "chest",
		"Back":      "back",
		"Legs":      "legs",
		"Shoulders": "shoulders",
		"Arms":      "arms",
		"Core":      "core",
	}
	return partMap[partName]
}
