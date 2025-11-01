package controllers

import (
	"net/http"
	"strconv"
	"time"

	"gymates-backend/models"
	"gymates-backend/services"

	"github.com/gin-gonic/gin"
)

// TrainingControllerV2 训练控制器 V2
type TrainingControllerV2 struct {
	trainingService *services.TrainingService
	aiCoachService  *services.AICoachService
}

// NewTrainingControllerV2 创建训练控制器 V2
func NewTrainingControllerV2() *TrainingControllerV2 {
	return &TrainingControllerV2{
		trainingService: services.NewTrainingService(),
		aiCoachService:  services.NewAICoachService(),
	}
}

// ==================== 运动库接口 ====================

// GetExerciseLibrary 获取运动库
// @Summary 获取运动库列表
// @Tags 训练
// @Param muscle_group query string false "肌肉群"
// @Param difficulty query string false "难度"
// @Param equipment query string false "器械"
// @Param search query string false "搜索关键词"
// @Param page query int false "页码" default(1)
// @Param limit query int false "每页数量" default(20)
// @Success 200 {object} map[string]interface{}
// @Router /api/training/exercises [get]
func (ctrl *TrainingControllerV2) GetExerciseLibrary(c *gin.Context) {
	muscleGroup := c.Query("muscle_group")
	difficulty := c.Query("difficulty")
	equipment := c.Query("equipment")
	search := c.Query("search")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	exercises, total, err := ctrl.trainingService.GetExerciseLibrary(
		muscleGroup, difficulty, equipment, search, page, limit,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "获取运动库失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    exercises,
		"total":   total,
		"page":    page,
		"limit":   limit,
	})
}

// GetExerciseDetail 获取运动详情
// @Summary 获取运动详情
// @Tags 训练
// @Param id path int true "运动ID"
// @Success 200 {object} map[string]interface{}
// @Router /api/training/exercises/{id} [get]
func (ctrl *TrainingControllerV2) GetExerciseDetail(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "无效的运动ID",
		})
		return
	}

	exercise, err := ctrl.trainingService.GetExerciseByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "运动不存在",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    exercise,
	})
}

// ToggleFavoriteExercise 收藏/取消收藏运动
// @Summary 收藏/取消收藏运动
// @Tags 训练
// @Param id path int true "运动ID"
// @Success 200 {object} map[string]interface{}
// @Router /api/training/exercises/{id}/favorite [post]
func (ctrl *TrainingControllerV2) ToggleFavoriteExercise(c *gin.Context) {
	userID := c.GetUint("user_id")
	exerciseID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "无效的运动ID",
		})
		return
	}

	isFavorited, err := ctrl.trainingService.ToggleFavoriteExercise(userID, uint(exerciseID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "操作失败",
			"error":   err.Error(),
		})
		return
	}

	message := "已取消收藏"
	if isFavorited {
		message = "已收藏"
	}

	c.JSON(http.StatusOK, gin.H{
		"success":     true,
		"message":     message,
		"is_favorited": isFavorited,
	})
}

// ==================== 训练计划接口 ====================

// CreateTrainingPlan 创建训练计划
// @Summary 创建训练计划
// @Tags 训练
// @Param body body models.TrainingPlanV2 true "训练计划"
// @Success 200 {object} map[string]interface{}
// @Router /api/training/plans [post]
func (ctrl *TrainingControllerV2) CreateTrainingPlan(c *gin.Context) {
	userID := c.GetUint("user_id")

	var plan models.TrainingPlanV2
	if err := c.ShouldBindJSON(&plan); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "请求数据格式错误",
			"error":   err.Error(),
		})
		return
	}

	plan.UserID = userID

	if err := ctrl.trainingService.CreateTrainingPlan(&plan); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "创建训练计划失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "创建成功",
		"data":    plan,
	})
}

// GetTrainingPlans 获取训练计划列表
// @Summary 获取训练计划列表
// @Tags 训练
// @Param page query int false "页码" default(1)
// @Param limit query int false "每页数量" default(10)
// @Success 200 {object} map[string]interface{}
// @Router /api/training/plans [get]
func (ctrl *TrainingControllerV2) GetTrainingPlans(c *gin.Context) {
	userID := c.GetUint("user_id")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	plans, total, err := ctrl.trainingService.GetUserTrainingPlans(userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "获取训练计划失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    plans,
		"total":   total,
		"page":    page,
		"limit":   limit,
	})
}

// GetTrainingPlanDetail 获取训练计划详情
// @Summary 获取训练计划详情
// @Tags 训练
// @Param id path int true "计划ID"
// @Success 200 {object} map[string]interface{}
// @Router /api/training/plans/{id} [get]
func (ctrl *TrainingControllerV2) GetTrainingPlanDetail(c *gin.Context) {
	planID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "无效的计划ID",
		})
		return
	}

	plan, err := ctrl.trainingService.GetTrainingPlan(uint(planID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "训练计划不存在",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    plan,
	})
}

// UpdateTrainingPlan 更新训练计划
// @Summary 更新训练计划
// @Tags 训练
// @Param id path int true "计划ID"
// @Param body body models.TrainingPlanV2 true "训练计划"
// @Success 200 {object} map[string]interface{}
// @Router /api/training/plans/{id} [put]
func (ctrl *TrainingControllerV2) UpdateTrainingPlan(c *gin.Context) {
	userID := c.GetUint("user_id")
	planID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "无效的计划ID",
		})
		return
	}

	var plan models.TrainingPlanV2
	if err := c.ShouldBindJSON(&plan); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "请求数据格式错误",
			"error":   err.Error(),
		})
		return
	}

	plan.ID = uint(planID)
	plan.UserID = userID

	if err := ctrl.trainingService.UpdateTrainingPlan(&plan); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "更新训练计划失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "更新成功",
		"data":    plan,
	})
}

// DeleteTrainingPlan 删除训练计划
// @Summary 删除训练计划
// @Tags 训练
// @Param id path int true "计划ID"
// @Success 200 {object} map[string]interface{}
// @Router /api/training/plans/{id} [delete]
func (ctrl *TrainingControllerV2) DeleteTrainingPlan(c *gin.Context) {
	planID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "无效的计划ID",
		})
		return
	}

	if err := ctrl.trainingService.DeleteTrainingPlan(uint(planID)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "删除训练计划失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "删除成功",
	})
}

// ==================== 今日训练接口 ====================

// GetTodayWorkout 获取今日训练
// @Summary 获取今日训练
// @Tags 训练
// @Param date query string false "日期 (YYYY-MM-DD)" default(today)
// @Success 200 {object} map[string]interface{}
// @Router /api/training/today [get]
func (ctrl *TrainingControllerV2) GetTodayWorkout(c *gin.Context) {
	userID := c.GetUint("user_id")
	dateStr := c.DefaultQuery("date", time.Now().Format("2006-01-02"))
	
	date, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		date = time.Now()
	}

	workout, err := ctrl.trainingService.GetTodayWorkout(userID, date)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "获取今日训练失败",
			"error":   err.Error(),
		})
		return
	}

	if workout == nil {
		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"data":    nil,
			"message": "今日暂无训练计划",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    workout,
	})
}

// CreateTodayWorkout 创建今日训练
// @Summary 创建今日训练
// @Tags 训练
// @Param body body map[string]interface{} true "请求体"
// @Success 200 {object} map[string]interface{}
// @Router /api/training/today [post]
func (ctrl *TrainingControllerV2) CreateTodayWorkout(c *gin.Context) {
	userID := c.GetUint("user_id")

	var req struct {
		PlanID *uint  `json:"plan_id"`
		Date   string `json:"date"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "请求数据格式错误",
			"error":   err.Error(),
		})
		return
	}

	date := time.Now()
	if req.Date != "" {
		parsedDate, err := time.Parse("2006-01-02", req.Date)
		if err == nil {
			date = parsedDate
		}
	}

	workout, err := ctrl.trainingService.CreateTodayWorkout(userID, req.PlanID, date)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "创建今日训练失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "创建成功",
		"data":    workout,
	})
}

// StartWorkoutSession 开始训练会话
// @Summary 开始训练会话
// @Tags 训练
// @Param body body map[string]interface{} true "请求体"
// @Success 200 {object} map[string]interface{}
// @Router /api/training/sessions/start [post]
func (ctrl *TrainingControllerV2) StartWorkoutSession(c *gin.Context) {
	userID := c.GetUint("user_id")

	var req struct {
		PlanID      *uint `json:"plan_id"`
		IsAIWorkout bool  `json:"is_ai_workout"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "请求数据格式错误",
			"error":   err.Error(),
		})
		return
	}

	session, err := ctrl.trainingService.StartWorkoutSession(userID, req.PlanID, req.IsAIWorkout)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "开始训练失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "训练开始",
		"data":    session,
	})
}

// UpdateWorkoutProgress 更新训练进度
// @Summary 更新训练进度
// @Tags 训练
// @Param body body map[string]interface{} true "请求体"
// @Success 200 {object} map[string]interface{}
// @Router /api/training/sessions/progress [post]
func (ctrl *TrainingControllerV2) UpdateWorkoutProgress(c *gin.Context) {
	var req struct {
		WorkoutExerciseID uint    `json:"workout_exercise_id" binding:"required"`
		SetNumber         int     `json:"set_number" binding:"required"`
		Reps              int     `json:"reps" binding:"required"`
		Weight            float64 `json:"weight"`
		Duration          int     `json:"duration"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "请求数据格式错误",
			"error":   err.Error(),
		})
		return
	}

	err := ctrl.trainingService.UpdateWorkoutProgress(
		req.WorkoutExerciseID,
		req.SetNumber,
		req.Reps,
		req.Weight,
		req.Duration,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "更新进度失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "进度已更新",
	})
}

// CompleteWorkout 完成训练
// @Summary 完成训练
// @Tags 训练
// @Param body body map[string]interface{} true "请求体"
// @Success 200 {object} map[string]interface{}
// @Router /api/training/sessions/complete [post]
func (ctrl *TrainingControllerV2) CompleteWorkout(c *gin.Context) {
	var req struct {
		SessionID uint `json:"session_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "请求数据格式错误",
			"error":   err.Error(),
		})
		return
	}

	if err := ctrl.trainingService.CompleteWorkout(req.SessionID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "完成训练失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "训练已完成,恭喜你! 🎉",
	})
}

// ==================== 训练历史接口 ====================

// GetTrainingHistory 获取训练历史
// @Summary 获取训练历史
// @Tags 训练
// @Param start_date query string false "开始日期"
// @Param end_date query string false "结束日期"
// @Param page query int false "页码" default(1)
// @Param limit query int false "每页数量" default(10)
// @Success 200 {object} map[string]interface{}
// @Router /api/training/history [get]
func (ctrl *TrainingControllerV2) GetTrainingHistory(c *gin.Context) {
	userID := c.GetUint("user_id")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	var startDate, endDate *time.Time
	if startStr := c.Query("start_date"); startStr != "" {
		if d, err := time.Parse("2006-01-02", startStr); err == nil {
			startDate = &d
		}
	}
	if endStr := c.Query("end_date"); endStr != "" {
		if d, err := time.Parse("2006-01-02", endStr); err == nil {
			endDate = &d
		}
	}

	histories, total, err := ctrl.trainingService.GetTrainingHistory(userID, startDate, endDate, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "获取训练历史失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    histories,
		"total":   total,
		"page":    page,
		"limit":   limit,
	})
}

// GetTrainingStatistics 获取训练统计
// @Summary 获取训练统计
// @Tags 训练
// @Param period query string false "时间段" default(week)
// @Success 200 {object} map[string]interface{}
// @Router /api/training/statistics [get]
func (ctrl *TrainingControllerV2) GetTrainingStatistics(c *gin.Context) {
	userID := c.GetUint("user_id")
	period := c.DefaultQuery("period", "week")

	var startDate, endDate time.Time
	now := time.Now()

	switch period {
	case "week":
		startDate = now.AddDate(0, 0, -7)
		endDate = now
	case "month":
		startDate = now.AddDate(0, -1, 0)
		endDate = now
	case "year":
		startDate = now.AddDate(-1, 0, 0)
		endDate = now
	default:
		startDate = now.AddDate(0, 0, -7)
		endDate = now
	}

	stats, err := ctrl.trainingService.GetTrainingStatistics(userID, startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "获取统计数据失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    stats,
	})
}

// GetUserStats 获取用户统计
// @Summary 获取用户统计
// @Tags 训练
// @Success 200 {object} map[string]interface{}
// @Router /api/training/user-stats [get]
func (ctrl *TrainingControllerV2) GetUserStats(c *gin.Context) {
	userID := c.GetUint("user_id")

	stats, err := ctrl.trainingService.GetUserStats(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "获取用户统计失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    stats,
	})
}

// ==================== AI训练接口 ====================

// GenerateAIWorkoutPlan 生成AI训练计划
// @Summary 生成AI训练计划
// @Tags AI训练
// @Param body body map[string]interface{} true "用户偏好"
// @Success 200 {object} map[string]interface{}
// @Router /api/training/ai/generate-plan [post]
func (ctrl *TrainingControllerV2) GenerateAIWorkoutPlan(c *gin.Context) {
	userID := c.GetUint("user_id")

	var preferences map[string]interface{}
	if err := c.ShouldBindJSON(&preferences); err != nil {
		preferences = make(map[string]interface{})
	}

	plan, err := ctrl.aiCoachService.GenerateWorkoutPlan(userID, preferences)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "生成训练计划失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "AI训练计划已生成",
		"data":    plan,
	})
}

// GetRealtimeFeedback 获取实时反馈
// @Summary 获取实时训练反馈
// @Tags AI训练
// @Param body body map[string]interface{} true "训练状态"
// @Success 200 {object} map[string]interface{}
// @Router /api/training/ai/feedback [post]
func (ctrl *TrainingControllerV2) GetRealtimeFeedback(c *gin.Context) {
	userID := c.GetUint("user_id")

	var req struct {
		ExerciseName string                 `json:"exercise_name" binding:"required"`
		CurrentSet   int                    `json:"current_set" binding:"required"`
		TargetSets   int                    `json:"target_sets" binding:"required"`
		Performance  map[string]interface{} `json:"performance"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "请求数据格式错误",
			"error":   err.Error(),
		})
		return
	}

	feedback, err := ctrl.aiCoachService.GetRealtimeFeedback(
		userID,
		req.ExerciseName,
		req.CurrentSet,
		req.TargetSets,
		req.Performance,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "获取反馈失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":  true,
		"feedback": feedback,
	})
}

// GenerateMotivationalMessage 生成激励消息
// @Summary 生成激励消息
// @Tags AI训练
// @Param body body map[string]interface{} true "场景"
// @Success 200 {object} map[string]interface{}
// @Router /api/training/ai/motivation [post]
func (ctrl *TrainingControllerV2) GenerateMotivationalMessage(c *gin.Context) {
	userID := c.GetUint("user_id")

	var req struct {
		Context string `json:"context" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "请求数据格式错误",
			"error":   err.Error(),
		})
		return
	}

	message, err := ctrl.aiCoachService.GenerateMotivationalMessage(userID, req.Context)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "生成激励消息失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": message,
	})
}

