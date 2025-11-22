package controllers

import (
	"fmt"
	"math/rand"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gymates-backend/config"
	"gymates-backend/models"
	"gymates-backend/services"
)

// AITrainingController AI训练控制器
type AITrainingController struct{
	planService     *services.AITrainingPlanService
	voiceService    *services.AIVoiceGuidanceService
}

// NewAITrainingController 创建AI训练控制器
func NewAITrainingController() *AITrainingController {
	return &AITrainingController{
		planService:  services.NewAITrainingPlanService(),
		voiceService: services.NewAIVoiceGuidanceService(),
	}
}

// GetAIRecommendation 获取AI推荐训练计划
// GET /api/training/ai/recommend?user_id={uid}
func (aic *AITrainingController) GetAIRecommendation(c *gin.Context) {
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

	// 获取用户训练偏好
	var preferences models.UserTrainingPreferences
	if err := config.DB.Where("user_id = ?", uint(userID)).First(&preferences).Error; err != nil {
		// 如果没有偏好设置，使用默认值
		preferences = models.UserTrainingPreferences{
			UserID:         uint(userID),
			Goal:           "增肌",
			Frequency:      3,
			PreferredParts: "chest,back,legs",
			CurrentWeight:  70.0,
			TargetWeight:   75.0,
			Experience:     "中级",
		}
	}

	// 获取用户训练历史
	var recentHistory []models.UserTrainingHistory
	config.DB.Where("user_id = ? AND completed_at > ?", uint(userID), time.Now().AddDate(0, 0, -7)).
		Order("completed_at DESC").
		Limit(10).
		Find(&recentHistory)

	// 计算完成率
	completionRate := aic.calculateCompletionRate(uint(userID))

	// 生成AI推荐
	recommendation := aic.generateAIRecommendation(preferences, recentHistory, completionRate)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "AI推荐生成成功",
		Data:    recommendation,
	})
}

// SaveTrainingPreferences 保存用户训练偏好
// POST /api/training/ai/preferences
func (aic *AITrainingController) SaveTrainingPreferences(c *gin.Context) {
	var req models.SavePreferencesRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 查找或创建用户偏好
	var preferences models.UserTrainingPreferences
	if err := config.DB.Where("user_id = ?", req.UserID).First(&preferences).Error; err != nil {
		preferences = models.UserTrainingPreferences{
			UserID: req.UserID,
		}
	}

	// 更新偏好
	preferences.Goal = req.Goal
	preferences.Frequency = req.Frequency
	preferences.PreferredParts = req.PreferredParts
	preferences.CurrentWeight = req.CurrentWeight
	preferences.TargetWeight = req.TargetWeight
	preferences.Experience = req.Experience

	if err := config.DB.Save(&preferences).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "保存偏好失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "偏好保存成功",
		Data:    preferences,
	})
}

// AIChat AI聊天接口
// POST /api/training/ai/chat
func (aic *AITrainingController) AIChat(c *gin.Context) {
	var req models.AIChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 生成AI回复
	reply := aic.generateAIResponse(req.Message, req.UserID)

	// 生成语音URL（模拟）
	speechURL := fmt.Sprintf("https://cdn.gymates.com/audio/reply_%d_%d.mp3", req.UserID, time.Now().Unix())

	response := models.AIChatResponse{
		Reply:     reply,
		SpeechURL: speechURL,
		Timestamp: time.Now(),
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "AI回复生成成功",
		Data:    response,
	})
}

// SaveTrainingSession 保存训练会话记录
// POST /api/training/ai/session
func (aic *AITrainingController) SaveTrainingSession(c *gin.Context) {
	var req models.TrainingSessionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 创建训练会话记录
	session := models.AITrainingSession{
		UserID:      req.UserID,
		SessionType: "training_session",
		Content:     fmt.Sprintf("训练日期: %s, 计划ID: %d", req.Date, req.PlanID),
		Response:    fmt.Sprintf("完成动作数: %d", len(req.CompletedExercises)),
	}

	if err := config.DB.Create(&session).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "保存训练会话失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 更新用户训练历史
	for _, exercise := range req.CompletedExercises {
		history := models.UserTrainingHistory{
			UserID:      req.UserID,
			MuscleGroup: aic.getMuscleGroupFromExercise(exercise.Name),
			Sets:        exercise.SetsDone,
			CompletedAt: time.Now(),
		}
		config.DB.Create(&history)
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "训练会话保存成功",
		Data:    session,
	})
}

// 生成AI推荐训练计划
func (aic *AITrainingController) generateAIRecommendation(preferences models.UserTrainingPreferences, history []models.UserTrainingHistory, completionRate float64) models.AITrainingRecommendation {
	// 根据目标确定训练类型
	var exercises []models.RecommendedExercise
	var trainingType string

	switch preferences.Goal {
	case "增肌":
		trainingType = "力量训练"
		exercises = aic.generateMuscleBuildingExercises(preferences, completionRate)
	case "减脂":
		trainingType = "有氧训练"
		exercises = aic.generateFatLossExercises(preferences, completionRate)
	default:
		trainingType = "综合训练"
		exercises = aic.generateMaintenanceExercises(preferences, completionRate)
	}

	// 生成训练概览
	overview := models.TrainingOverview{
		Goal:           preferences.Goal,
		TrainingType:   trainingType,
		Frequency:      preferences.Frequency,
		CompletionRate: completionRate,
		LastTraining:   aic.getLastTrainingDate(preferences.UserID),
		WeeklyProgress: aic.getWeeklyProgress(preferences.UserID),
	}

	return models.AITrainingRecommendation{
		UserID:    preferences.UserID,
		Overview:  overview,
		Exercises: exercises,
		Generated: time.Now(),
	}
}

// 生成增肌训练动作
func (aic *AITrainingController) generateMuscleBuildingExercises(preferences models.UserTrainingPreferences, completionRate float64) []models.RecommendedExercise {
	var exercises []models.RecommendedExercise

	// 根据完成率调整强度
	intensityMultiplier := 1.0
	if completionRate > 0.8 {
		intensityMultiplier = 1.1 // 增加强度
	} else if completionRate < 0.5 {
		intensityMultiplier = 0.9 // 降低强度
	}

	// 获取动作库
	var exerciseLibrary []models.ExerciseLibrary
	config.DB.Where("level IN (?)", []string{"beginner", "intermediate", "advanced"}).
		Order("RANDOM()").
		Limit(8).
		Find(&exerciseLibrary)

	for _, exercise := range exerciseLibrary {
		recommendedExercise := models.RecommendedExercise{
			Name:        exercise.Name,
			Sets:        int(float64(3+rand.Intn(2)) * intensityMultiplier), // 3-5组
			Reps:        8 + rand.Intn(5),                                   // 8-12次
			Weight:      aic.calculateWeight(exercise.Name, preferences.CurrentWeight),
			RestSeconds: 90 + rand.Intn(30), // 90-120秒
			Part:        exercise.Part,
			Description: exercise.Description,
			VideoURL:    fmt.Sprintf("https://cdn.gymates.com/videos/%s.mp4", exercise.Name),
			Notes:       "",
		}
		exercises = append(exercises, recommendedExercise)
	}

	return exercises
}

// 生成减脂训练动作
func (aic *AITrainingController) generateFatLossExercises(preferences models.UserTrainingPreferences, completionRate float64) []models.RecommendedExercise {
	var exercises []models.RecommendedExercise

	// 减脂训练：高次数、短休息
	var exerciseLibrary []models.ExerciseLibrary
	config.DB.Where("type IN (?)", []string{"compound", "cardio"}).
		Order("RANDOM()").
		Limit(6).
		Find(&exerciseLibrary)

	for _, exercise := range exerciseLibrary {
		recommendedExercise := models.RecommendedExercise{
			Name:        exercise.Name,
			Sets:        3,
			Reps:        15 + rand.Intn(10),                                                  // 15-25次
			Weight:      aic.calculateWeight(exercise.Name, preferences.CurrentWeight) * 0.7, // 较轻重量
			RestSeconds: 30 + rand.Intn(15),                                                  // 30-45秒
			Part:        exercise.Part,
			Description: exercise.Description,
			VideoURL:    fmt.Sprintf("https://cdn.gymates.com/videos/%s.mp4", exercise.Name),
			Notes:       "减脂训练：保持高心率",
		}
		exercises = append(exercises, recommendedExercise)
	}

	return exercises
}

// 生成维持训练动作
func (aic *AITrainingController) generateMaintenanceExercises(preferences models.UserTrainingPreferences, completionRate float64) []models.RecommendedExercise {
	var exercises []models.RecommendedExercise

	var exerciseLibrary []models.ExerciseLibrary
	config.DB.Order("RANDOM()").Limit(7).Find(&exerciseLibrary)

	for _, exercise := range exerciseLibrary {
		recommendedExercise := models.RecommendedExercise{
			Name:        exercise.Name,
			Sets:        3,
			Reps:        10 + rand.Intn(5), // 10-15次
			Weight:      aic.calculateWeight(exercise.Name, preferences.CurrentWeight),
			RestSeconds: 60 + rand.Intn(30), // 60-90秒
			Part:        exercise.Part,
			Description: exercise.Description,
			VideoURL:    fmt.Sprintf("https://cdn.gymates.com/videos/%s.mp4", exercise.Name),
			Notes:       "维持训练：保持当前水平",
		}
		exercises = append(exercises, recommendedExercise)
	}

	return exercises
}

// 计算建议重量
func (aic *AITrainingController) calculateWeight(exerciseName string, userWeight float64) float64 {
	// 根据动作类型和用户体重计算建议重量
	baseWeight := userWeight * 0.6 // 基础重量为体重的60%

	// 根据动作类型调整
	switch exerciseName {
	case "Bench Press", "Squat":
		return baseWeight * 1.2
	case "Deadlift":
		return baseWeight * 1.5
	case "Pull-up", "Push-up":
		return 0 // 自重训练
	default:
		return baseWeight * 0.8
	}
}

// 计算完成率
func (aic *AITrainingController) calculateCompletionRate(userID uint) float64 {
	var totalSessions int64
	var completedSessions int64

	config.DB.Model(&models.WorkoutSession{}).Where("user_id = ?", userID).Count(&totalSessions)
	config.DB.Model(&models.WorkoutSession{}).Where("user_id = ? AND status = ?", userID, "completed").Count(&completedSessions)

	if totalSessions == 0 {
		return 0.0
	}
	return float64(completedSessions) / float64(totalSessions)
}

// 获取最后训练日期
func (aic *AITrainingController) getLastTrainingDate(userID uint) *time.Time {
	var session models.WorkoutSession
	if err := config.DB.Where("user_id = ?", userID).Order("created_at DESC").First(&session).Error; err != nil {
		return nil
	}
	return &session.CreatedAt
}

// 获取周进度
func (aic *AITrainingController) getWeeklyProgress(userID uint) int {
	var count int64
	weekAgo := time.Now().AddDate(0, 0, -7)
	config.DB.Model(&models.WorkoutSession{}).Where("user_id = ? AND created_at > ?", userID, weekAgo).Count(&count)
	return int(count)
}

// 生成AI回复
func (aic *AITrainingController) generateAIResponse(message string, userID uint) string {
	// 简单的关键词匹配回复（实际项目中可集成LLM）
	responses := map[string]string{
		"呼吸": "训练时要注意呼吸节奏：用力时呼气，放松时吸气。这样可以提供更好的力量输出。",
		"疼痛": "如果感到疼痛，建议立即停止训练。疼痛是身体的警告信号，不要强行训练。",
		"肩膀": "肩膀疼痛时避免肩部参与较多的动作，如卧推。可以改为下肢训练或肩部拉伸。",
		"深蹲": "深蹲时腰疼通常是姿势问题：保持背部挺直，膝盖与脚尖方向一致，重心在脚跟。",
		"卧推": "卧推时肩胛骨要收紧，保持稳定。下放时控制速度，推起时爆发用力。",
		"减脂": "减脂需要控制饮食和增加有氧运动。建议力量训练+有氧训练结合。",
		"增肌": "增肌需要渐进超负荷训练，保证蛋白质摄入，充足休息。",
	}

	// 查找匹配的关键词
	for keyword, response := range responses {
		if contains(message, keyword) {
			return response
		}
	}

	// 默认回复
	return "我理解您的问题。建议您根据个人情况调整训练强度，如有不适请咨询专业教练。"
}

// 获取动作对应的肌群
func (aic *AITrainingController) getMuscleGroupFromExercise(exerciseName string) string {
	// 简单的动作名称到肌群映射
	muscleGroups := map[string]string{
		"Bench Press": "chest",
		"Squat":       "legs",
		"Deadlift":    "back",
		"Pull-up":     "back",
		"Push-up":     "chest",
	}

	if group, exists := muscleGroups[exerciseName]; exists {
		return group
	}
	return "other"
}

// 辅助函数：检查字符串包含
func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr ||
		(len(s) > len(substr) && (s[:len(substr)] == substr ||
			s[len(s)-len(substr):] == substr ||
			contains(s[1:], substr))))
}

// ============================================
// 新增：一键生成个性化训练计划
// ============================================

// GeneratePersonalizedPlan 生成个性化训练计划
// POST /api/training/ai/generate-plan
func (aic *AITrainingController) GeneratePersonalizedPlan(c *gin.Context) {
	var req models.GeneratePlanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 保存或更新用户训练偏好
	var preferences models.UserTrainingPreferences
	if err := config.DB.Where("user_id = ?", req.UserID).First(&preferences).Error; err != nil {
		preferences = models.UserTrainingPreferences{
			UserID: req.UserID,
		}
	}

	preferences.Goal = req.Goal
	preferences.Frequency = req.Frequency
	preferences.PreferredParts = req.PreferredParts
	preferences.CurrentWeight = req.CurrentWeight
	preferences.TargetWeight = req.TargetWeight
	preferences.Experience = req.Experience

	if err := config.DB.Save(&preferences).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "保存用户偏好失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 使用AI服务生成训练计划
	plan, err := aic.planService.GeneratePersonalizedPlan(req.UserID, preferences)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成训练计划失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "AI训练计划生成成功",
		Data:    plan,
	})
}

// ============================================
// 新增：动作演示与语音指导
// ============================================

// GetExerciseGuidance 获取动作指导（文字+语音）
// GET /api/training/ai/exercise/:id/guidance
func (aic *AITrainingController) GetExerciseGuidance(c *gin.Context) {
	exerciseIDStr := c.Param("id")
	exerciseID, err := strconv.ParseUint(exerciseIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的动作ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 获取动作信息
	var exercise models.Exercise
	if err := config.DB.First(&exercise, uint(exerciseID)).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "动作不存在",
			Error:   err.Error(),
			Code:    http.StatusNotFound,
		})
		return
	}

	// 生成语音指导
	guidance, err := aic.voiceService.GenerateExerciseGuidance(exercise)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成指导失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取动作指导成功",
		Data:    guidance,
	})
}

// StartTraining 开始训练（获取实时指导）
// POST /api/training/ai/start
func (aic *AITrainingController) StartTraining(c *gin.Context) {
	var req models.StartTrainingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 获取动作信息
	var exercise models.Exercise
	if err := config.DB.First(&exercise, req.ExerciseID).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "动作不存在",
			Error:   err.Error(),
			Code:    http.StatusNotFound,
		})
		return
	}

	// 生成实时指导
	guidance, err := aic.voiceService.GenerateExerciseGuidance(exercise)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成指导失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 创建训练会话记录
	session := models.AITrainingSession{
		UserID:      req.UserID,
		SessionType: "training_start",
		Content:     fmt.Sprintf("开始训练: %s (计划ID: %d)", exercise.Name, req.PlanID),
		Response:    fmt.Sprintf("动作ID: %d", req.ExerciseID),
	}
	config.DB.Create(&session)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "开始训练",
		Data: gin.H{
			"exercise": exercise,
			"guidance": guidance,
			"session_id": session.ID,
		},
	})
}

// ============================================
// 新增：实时动作纠正
// ============================================

// GetRealTimeCorrection 获取实时纠正建议
// POST /api/training/ai/correction
func (aic *AITrainingController) GetRealTimeCorrection(c *gin.Context) {
	var req models.GetCorrectionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 获取动作信息
	var exercise models.Exercise
	if err := config.DB.First(&exercise, req.ExerciseID).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "动作不存在",
			Error:   err.Error(),
			Code:    http.StatusNotFound,
		})
		return
	}

	// 生成纠正建议
	correction, err := aic.voiceService.GenerateRealTimeCorrection(exercise, req.SensorData)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成纠正建议失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取纠正建议成功",
		Data:    correction,
	})
}

// ============================================
// 新增：训练数据上传与反馈
// ============================================

// UploadTrainingData 上传训练数据
// POST /api/training/ai/upload-data
func (aic *AITrainingController) UploadTrainingData(c *gin.Context) {
	var req models.UploadTrainingDataRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 保存训练会话
	session := models.AITrainingSession{
		UserID:      req.UserID,
		SessionType: "training_complete",
		Content:     fmt.Sprintf("训练时长: %d分钟, 完成动作: %d个", req.SessionData.Duration, len(req.SessionData.CompletedExercises)),
		Response:    fmt.Sprintf("总组数: %d, 总次数: %d, 消耗卡路里: %d", req.SessionData.TotalSets, req.SessionData.TotalReps, req.SessionData.CaloriesBurned),
	}

	if err := config.DB.Create(&session).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "保存训练数据失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 更新用户训练历史
	for _, exercise := range req.SessionData.CompletedExercises {
		history := models.UserTrainingHistory{
			UserID:      req.UserID,
			MuscleGroup: aic.getMuscleGroupFromExercise(exercise.ExerciseName),
			Sets:        exercise.SetsDone,
			CompletedAt: time.Now(),
		}
		config.DB.Create(&history)
	}

	// 生成训练总结
	summary, err := aic.voiceService.GenerateTrainingSummary(req.UserID, req.SessionData)
	if err != nil {
		summary = &models.TrainingSummaryResponse{
			OverallSummary:     "训练完成！",
			Strengths:          "保持了良好的训练状态",
			Improvements:       "继续保持",
			NextRecommendation: "建议休息后继续训练",
			Rating:             4,
			Timestamp:          time.Now(),
		}
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "训练数据上传成功",
		Data: gin.H{
			"session_id": session.ID,
			"summary":    summary,
		},
	})
}

// GetTrainingFeedback 获取训练反馈
// GET /api/training/ai/feedback?user_id={uid}&session_id={sid}
func (aic *AITrainingController) GetTrainingFeedback(c *gin.Context) {
	userIDStr := c.Query("user_id")
	sessionIDStr := c.Query("session_id")

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

	// 获取训练历史统计
	var totalSessions int64
	config.DB.Model(&models.AITrainingSession{}).
		Where("user_id = ? AND session_type = ?", uint(userID), "training_complete").
		Count(&totalSessions)

	// 获取最近7天训练次数
	weekAgo := time.Now().AddDate(0, 0, -7)
	var recentSessions int64
	config.DB.Model(&models.AITrainingSession{}).
		Where("user_id = ? AND session_type = ? AND created_at > ?", uint(userID), "training_complete", weekAgo).
		Count(&recentSessions)

	// 获取训练历史
	var history []models.UserTrainingHistory
	config.DB.Where("user_id = ?", uint(userID)).
		Order("completed_at DESC").
		Limit(10).
		Find(&history)

	// 计算肌群分布
	muscleGroupStats := make(map[string]int)
	for _, h := range history {
		muscleGroupStats[h.MuscleGroup]++
	}

	// 如果指定了session_id，获取具体会话
	var sessionData *models.AITrainingSession
	if sessionIDStr != "" {
		sessionID, _ := strconv.ParseUint(sessionIDStr, 10, 32)
		var session models.AITrainingSession
		if err := config.DB.First(&session, uint(sessionID)).Error; err == nil {
			sessionData = &session
		}
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取训练反馈成功",
		Data: gin.H{
			"total_sessions":     totalSessions,
			"recent_sessions":    recentSessions,
			"muscle_group_stats": muscleGroupStats,
			"recent_history":     history,
			"session_data":       sessionData,
		},
	})
}

// GetTrainingProgress 获取训练进度
// GET /api/training/ai/progress?user_id={uid}&days={days}
func (aic *AITrainingController) GetTrainingProgress(c *gin.Context) {
	userIDStr := c.Query("user_id")
	daysStr := c.DefaultQuery("days", "30")

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

	days, _ := strconv.Atoi(daysStr)
	if days <= 0 || days > 365 {
		days = 30
	}

	// 获取指定天数内的训练历史
	startDate := time.Now().AddDate(0, 0, -days)
	var history []models.UserTrainingHistory
	config.DB.Where("user_id = ? AND completed_at > ?", uint(userID), startDate).
		Order("completed_at ASC").
		Find(&history)

	// 按日期分组统计
	dailyStats := make(map[string]int)
	for _, h := range history {
		date := h.CompletedAt.Format("2006-01-02")
		dailyStats[date]++
	}

	// 计算连续打卡天数
	streak := aic.calculateStreak(uint(userID))

	// 获取用户偏好和目标
	var preferences models.UserTrainingPreferences
	config.DB.Where("user_id = ?", uint(userID)).First(&preferences)

	// 计算完成率
	completionRate := aic.calculateCompletionRate(uint(userID))

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取训练进度成功",
		Data: gin.H{
			"daily_stats":     dailyStats,
			"total_workouts":  len(history),
			"streak":          streak,
			"completion_rate": completionRate,
			"goal":            preferences.Goal,
			"target_frequency": preferences.Frequency,
		},
	})
}

// calculateStreak 计算连续打卡天数
func (aic *AITrainingController) calculateStreak(userID uint) int {
	var history []models.UserTrainingHistory
	config.DB.Where("user_id = ?", userID).
		Order("completed_at DESC").
		Find(&history)

	if len(history) == 0 {
		return 0
	}

	streak := 0
	currentDate := time.Now().Truncate(24 * time.Hour)

	for _, h := range history {
		trainingDate := h.CompletedAt.Truncate(24 * time.Hour)
		daysDiff := int(currentDate.Sub(trainingDate).Hours() / 24)

		if daysDiff == streak {
			streak++
			currentDate = trainingDate
		} else if daysDiff > streak {
			break
		}
	}

	return streak
}
