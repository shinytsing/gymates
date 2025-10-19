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
)

// AITrainingController AI训练控制器
type AITrainingController struct{}

// NewAITrainingController 创建AI训练控制器
func NewAITrainingController() *AITrainingController {
	return &AITrainingController{}
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
			UserID:     req.UserID,
			MuscleGroup: aic.getMuscleGroupFromExercise(exercise.Name),
			Sets:       exercise.SetsDone,
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
			Reps:        8 + rand.Intn(5), // 8-12次
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
			Reps:        15 + rand.Intn(10), // 15-25次
			Weight:      aic.calculateWeight(exercise.Name, preferences.CurrentWeight) * 0.7, // 较轻重量
			RestSeconds: 30 + rand.Intn(15), // 30-45秒
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
		"Squat": "legs",
		"Deadlift": "back",
		"Pull-up": "back",
		"Push-up": "chest",
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