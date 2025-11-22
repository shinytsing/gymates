package services

import (
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"gymates-backend/config"
	"gymates-backend/models"

	"gorm.io/gorm"
)

// TrainingService 训练服务
type TrainingService struct {
	db *gorm.DB
}

// NewTrainingService 创建训练服务
func NewTrainingService() *TrainingService {
	return &TrainingService{
		db: config.DB,
	}
}

// ==================== 运动库相关 ====================

// GetExerciseLibrary 获取运动库列表 (带过滤)
func (s *TrainingService) GetExerciseLibrary(muscleGroup, difficulty, equipment, search string, page, limit int) ([]models.ExerciseLibrary, int64, error) {
	var exercises []models.ExerciseLibrary
	var total int64

	query := s.db.Model(&models.ExerciseLibrary{})

	// 应用过滤
	if muscleGroup != "" {
		query = query.Where("part = ?", muscleGroup)
	}
	if difficulty != "" {
		query = query.Where("level = ?", difficulty)
	}
	if equipment != "" {
		query = query.Where("equipment = ?", equipment)
	}
	if search != "" {
		query = query.Where("name LIKE ? OR description LIKE ?", "%"+search+"%", "%"+search+"%")
	}

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询
	offset := (page - 1) * limit
	if err := query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&exercises).Error; err != nil {
		return nil, 0, err
	}

	return exercises, total, nil
}

// GetExerciseByID 根据ID获取运动详情
func (s *TrainingService) GetExerciseByID(id uint) (*models.ExerciseLibrary, error) {
	var exercise models.ExerciseLibrary
	if err := s.db.First(&exercise, id).Error; err != nil {
		return nil, err
	}
	return &exercise, nil
}

// ToggleFavoriteExercise 切换运动收藏状态
func (s *TrainingService) ToggleFavoriteExercise(userID, exerciseID uint) (bool, error) {
	var favorite models.UserExerciseFavorite
	err := s.db.Where("user_id = ? AND exercise_id = ?", userID, exerciseID).First(&favorite).Error

	if err == gorm.ErrRecordNotFound {
		// 添加收藏
		favorite = models.UserExerciseFavorite{
			UserID:     userID,
			ExerciseID: exerciseID,
		}
		if err := s.db.Create(&favorite).Error; err != nil {
			return false, err
		}
		return true, nil
	} else if err != nil {
		return false, err
	}

	// 取消收藏
	if err := s.db.Delete(&favorite).Error; err != nil {
		return false, err
	}
	return false, nil
}

// GetUserFavoriteExercises 获取用户收藏的运动
func (s *TrainingService) GetUserFavoriteExercises(userID uint) ([]models.ExerciseLibrary, error) {
	var exercises []models.ExerciseLibrary
	err := s.db.
		Joins("JOIN user_exercise_favorites ON user_exercise_favorites.exercise_id = exercise_library.id").
		Where("user_exercise_favorites.user_id = ?", userID).
		Find(&exercises).Error
	return exercises, err
}

// ==================== 训练计划相关 ====================

// CreateTrainingPlan 创建训练计划
func (s *TrainingService) CreateTrainingPlan(plan *models.TrainingPlanV2) error {
	return s.db.Transaction(func(tx *gorm.DB) error {
		// 创建计划
		if err := tx.Create(plan).Error; err != nil {
			return err
		}

		// 计算预估值
		if plan.EstimatedDuration == 0 || plan.EstimatedCalories == 0 {
			duration, calories := s.calculatePlanEstimates(plan.Exercises)
			plan.EstimatedDuration = duration
			plan.EstimatedCalories = calories
			if err := tx.Model(plan).Updates(map[string]interface{}{
				"estimated_duration": duration,
				"estimated_calories": calories,
			}).Error; err != nil {
				return err
			}
		}

		return nil
	})
}

// GetTrainingPlan 获取训练计划详情
func (s *TrainingService) GetTrainingPlan(planID uint) (*models.TrainingPlanV2, error) {
	var plan models.TrainingPlanV2
	err := s.db.Preload("User").Preload("Exercises.Exercise").First(&plan, planID).Error
	return &plan, err
}

// GetUserTrainingPlans 获取用户的训练计划列表
func (s *TrainingService) GetUserTrainingPlans(userID uint, page, limit int) ([]models.TrainingPlanV2, int64, error) {
	var plans []models.TrainingPlanV2
	var total int64

	query := s.db.Where("user_id = ?", userID)

	if err := query.Model(&models.TrainingPlanV2{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * limit
	err := query.
		Preload("Exercises.Exercise").
		Offset(offset).
		Limit(limit).
		Order("created_at DESC").
		Find(&plans).Error

	return plans, total, err
}

// UpdateTrainingPlan 更新训练计划
func (s *TrainingService) UpdateTrainingPlan(plan *models.TrainingPlanV2) error {
	return s.db.Transaction(func(tx *gorm.DB) error {
		// 删除旧的运动项
		if err := tx.Where("training_plan_id = ?", plan.ID).Delete(&models.PlanExerciseV2{}).Error; err != nil {
			return err
		}

		// 更新计划
		if err := tx.Model(plan).Updates(plan).Error; err != nil {
			return err
		}

		// 创建新的运动项
		if len(plan.Exercises) > 0 {
			for i := range plan.Exercises {
				plan.Exercises[i].TrainingPlanID = plan.ID
			}
			if err := tx.Create(&plan.Exercises).Error; err != nil {
				return err
			}
		}

		// 重新计算预估值
		duration, calories := s.calculatePlanEstimates(plan.Exercises)
		if err := tx.Model(plan).Updates(map[string]interface{}{
			"estimated_duration": duration,
			"estimated_calories": calories,
		}).Error; err != nil {
			return err
		}

		return nil
	})
}

// DeleteTrainingPlan 删除训练计划
func (s *TrainingService) DeleteTrainingPlan(planID uint) error {
	return s.db.Transaction(func(tx *gorm.DB) error {
		// 删除运动项
		if err := tx.Where("training_plan_id = ?", planID).Delete(&models.PlanExerciseV2{}).Error; err != nil {
			return err
		}
		// 删除计划
		return tx.Delete(&models.TrainingPlanV2{}, planID).Error
	})
}

// ==================== 今日训练相关 ====================

// GetTodayWorkout 获取今日训练
func (s *TrainingService) GetTodayWorkout(userID uint, date time.Time) (*models.TodayWorkout, error) {
	var workout models.TodayWorkout
	startOfDay := time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, date.Location())
	endOfDay := startOfDay.Add(24 * time.Hour)

	err := s.db.
		Preload("Plan.Exercises.Exercise").
		Preload("Exercises.Exercise").
		Preload("Exercises.SetRecords").
		Where("user_id = ? AND date >= ? AND date < ?", userID, startOfDay, endOfDay).
		First(&workout).Error

	if err == gorm.ErrRecordNotFound {
		return nil, nil // 没有今日训练计划
	}

	return &workout, err
}

// CreateTodayWorkout 创建今日训练
func (s *TrainingService) CreateTodayWorkout(userID uint, planID *uint, date time.Time) (*models.TodayWorkout, error) {
	workout := &models.TodayWorkout{
		UserID: userID,
		PlanID: planID,
		Date:   date,
		Status: "not_started",
	}

	// 如果指定了计划，加载计划的运动项
	if planID != nil {
		plan, err := s.GetTrainingPlan(*planID)
		if err != nil {
			return nil, err
		}

		if err := s.db.Create(workout).Error; err != nil {
			return nil, err
		}

		// 创建训练运动项
		for _, planEx := range plan.Exercises {
			workoutEx := models.WorkoutExerciseV2{
				WorkoutID:     workout.ID,
				ExerciseID:    planEx.ExerciseID,
				TotalSets:     planEx.Sets,
				CompletedSets: 0,
				TargetReps:    planEx.Reps,
				TargetWeight:  planEx.Weight,
				Order:         planEx.Order,
			}
			if err := s.db.Create(&workoutEx).Error; err != nil {
				return nil, err
			}
		}

		// 重新加载完整的 workout
		return s.GetTodayWorkout(userID, date)
	}

	if err := s.db.Create(workout).Error; err != nil {
		return nil, err
	}

	return workout, nil
}

// StartWorkoutSession 开始训练会话
func (s *TrainingService) StartWorkoutSession(userID uint, planID *uint, isAI bool) (*models.WorkoutSessionV2, error) {
	session := &models.WorkoutSessionV2{
		UserID:      userID,
		PlanID:      planID,
		IsAIWorkout: isAI,
		StartTime:   time.Now(),
		Status:      "ongoing",
		Progress:    0,
	}

	if err := s.db.Create(session).Error; err != nil {
		return nil, err
	}

	return session, nil
}

// UpdateWorkoutProgress 更新训练进度
func (s *TrainingService) UpdateWorkoutProgress(workoutExerciseID uint, setNumber, reps int, weight float64, duration int) error {
	return s.db.Transaction(func(tx *gorm.DB) error {
		// 创建组记录
		setRecord := models.SetRecord{
			WorkoutExerciseID: workoutExerciseID,
			SetNumber:         setNumber,
			Reps:              reps,
			Weight:            weight,
			Duration:          duration,
			CompletedAt:       time.Now(),
		}
		if err := tx.Create(&setRecord).Error; err != nil {
			return err
		}

		// 更新完成的组数
		if err := tx.Model(&models.WorkoutExerciseV2{}).
			Where("id = ?", workoutExerciseID).
			Update("completed_sets", gorm.Expr("completed_sets + 1")).Error; err != nil {
			return err
		}

		return nil
	})
}

// CompleteWorkout 完成训练
func (s *TrainingService) CompleteWorkout(sessionID uint) error {
	return s.db.Transaction(func(tx *gorm.DB) error {
		var session models.WorkoutSessionV2
		if err := tx.First(&session, sessionID).Error; err != nil {
			return err
		}

		endTime := time.Now()
		duration := int(endTime.Sub(session.StartTime).Minutes())

		// 更新会话
		if err := tx.Model(&session).Updates(map[string]interface{}{
			"end_time": endTime,
			"status":   "completed",
			"progress": 100,
			"duration": duration,
		}).Error; err != nil {
			return err
		}

		// 创建历史记录
		history := models.TrainingHistory{
			UserID:         session.UserID,
			SessionID:      session.ID,
			PlanID:         session.PlanID,
			Date:           session.StartTime,
			Duration:       duration,
			CaloriesBurned: session.CaloriesBurned,
			IsAIWorkout:    session.IsAIWorkout,
		}

		if session.PlanID != nil {
			var plan models.TrainingPlanV2
			if err := tx.First(&plan, *session.PlanID).Error; err == nil {
				history.PlanName = plan.Name
			}
		}

		if err := tx.Create(&history).Error; err != nil {
			return err
		}

		// 更新用户统计
		if err := s.updateUserStats(tx, session.UserID, duration, session.CaloriesBurned); err != nil {
			return err
		}

		return nil
	})
}

// ==================== 训练历史相关 ====================

// GetTrainingHistory 获取训练历史
func (s *TrainingService) GetTrainingHistory(userID uint, startDate, endDate *time.Time, page, limit int) ([]models.TrainingHistory, int64, error) {
	var histories []models.TrainingHistory
	var total int64

	query := s.db.Where("user_id = ?", userID)

	if startDate != nil {
		query = query.Where("date >= ?", *startDate)
	}
	if endDate != nil {
		query = query.Where("date <= ?", *endDate)
	}

	if err := query.Model(&models.TrainingHistory{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * limit
	err := query.
		Preload("Session").
		Offset(offset).
		Limit(limit).
		Order("date DESC").
		Find(&histories).Error

	return histories, total, err
}

// GetTrainingStatistics 获取训练统计
func (s *TrainingService) GetTrainingStatistics(userID uint, startDate, endDate time.Time) (map[string]interface{}, error) {
	var histories []models.TrainingHistory
	err := s.db.
		Where("user_id = ? AND date >= ? AND date <= ?", userID, startDate, endDate).
		Find(&histories).Error
	if err != nil {
		return nil, err
	}

	// 计算统计
	totalWorkouts := len(histories)
	totalMinutes := 0
	totalCalories := 0
	workoutsByDay := make(map[string]int)
	muscleGroups := make(map[string]int)
	dailyStats := []map[string]interface{}{}

	for _, h := range histories {
		totalMinutes += h.Duration
		totalCalories += h.CaloriesBurned
		dayKey := h.Date.Format("2006-01-02")
		workoutsByDay[dayKey]++

		dailyStats = append(dailyStats, map[string]interface{}{
			"date":     h.Date,
			"workouts": 1,
			"minutes":  h.Duration,
			"calories": h.CaloriesBurned,
		})
	}

	avgDuration := 0.0
	if totalWorkouts > 0 {
		avgDuration = float64(totalMinutes) / float64(totalWorkouts)
	}

	return map[string]interface{}{
		"start_date":                startDate,
		"end_date":                  endDate,
		"total_workouts":            totalWorkouts,
		"total_minutes":             totalMinutes,
		"total_calories":            totalCalories,
		"average_workout_duration":  avgDuration,
		"workouts_by_day":           workoutsByDay,
		"muscle_group_distribution": muscleGroups,
		"daily_stats":               dailyStats,
	}, nil
}

// GetUserStats 获取用户训练统计
func (s *TrainingService) GetUserStats(userID uint) (*models.UserTrainingStats, error) {
	var stats models.UserTrainingStats
	err := s.db.Where("user_id = ?", userID).First(&stats).Error
	if err == gorm.ErrRecordNotFound {
		// 创建新的统计记录
		stats = models.UserTrainingStats{
			UserID: userID,
		}
		if err := s.db.Create(&stats).Error; err != nil {
			return nil, err
		}
	} else if err != nil {
		return nil, err
	}
	return &stats, nil
}

// ==================== 辅助函数 ====================

// calculatePlanEstimates 计算训练计划的预估时长和卡路里
func (s *TrainingService) calculatePlanEstimates(exercises []models.PlanExerciseV2) (duration, calories int) {
	for _, ex := range exercises {
		// 需要先加载 Exercise 数据
		var exercise models.ExerciseLibrary
		if err := s.db.First(&exercise, ex.ExerciseID).Error; err != nil {
			continue
		}

		// 时长: (每组时长 * 组数) + (休息时间 * (组数-1))
		setDuration := exercise.EstimatedDuration
		if ex.Duration > 0 {
			setDuration = ex.Duration
		}
		totalDuration := (setDuration * ex.Sets) + (ex.RestTime * (ex.Sets - 1))
		duration += totalDuration / 60 // 转换为分钟

		// 卡路里
		calories += exercise.EstimatedCalories * ex.Sets * ex.Reps
	}
	return
}

// updateUserStats 更新用户统计
func (s *TrainingService) updateUserStats(tx *gorm.DB, userID uint, duration, calories int) error {
	var stats models.UserTrainingStats
	err := tx.Where("user_id = ?", userID).First(&stats).Error

	if err == gorm.ErrRecordNotFound {
		stats = models.UserTrainingStats{
			UserID:              userID,
			TotalWorkouts:       1,
			TotalMinutes:        duration,
			TotalCaloriesBurned: calories,
			CurrentStreak:       1,
			LongestStreak:       1,
		}
		now := time.Now()
		stats.LastWorkoutDate = &now
		return tx.Create(&stats).Error
	} else if err != nil {
		return err
	}

	// 更新统计
	updates := map[string]interface{}{
		"total_workouts":        stats.TotalWorkouts + 1,
		"total_minutes":         stats.TotalMinutes + duration,
		"total_calories_burned": stats.TotalCaloriesBurned + calories,
		"last_workout_date":     time.Now(),
	}

	// 更新连续天数
	if stats.LastWorkoutDate != nil {
		daysSince := int(time.Since(*stats.LastWorkoutDate).Hours() / 24)
		if daysSince == 1 {
			stats.CurrentStreak++
			if stats.CurrentStreak > stats.LongestStreak {
				updates["longest_streak"] = stats.CurrentStreak
			}
			updates["current_streak"] = stats.CurrentStreak
		} else if daysSince > 1 {
			updates["current_streak"] = 1
		}
	}

	return tx.Model(&stats).Where("user_id = ?", userID).Updates(updates).Error
}

// ==================== AI 训练推荐相关 ====================

// GenerateAIRecommendation 生成AI训练推荐
func (s *TrainingService) GenerateAIRecommendation(userID uint) (*models.AIRecommendation, error) {
	// 获取用户信息
	var user models.User
	if err := s.db.First(&user, userID).Error; err != nil {
		return nil, err
	}

	// 获取用户统计
	stats, err := s.GetUserStats(userID)
	if err != nil {
		return nil, err
	}

	// 基于用户数据生成推荐
	recommendation := s.generateRecommendationLogic(&user, stats)

	// 保存推荐
	if err := s.db.Create(recommendation).Error; err != nil {
		return nil, err
	}

	return recommendation, nil
}

// generateRecommendationLogic AI推荐逻辑
func (s *TrainingService) generateRecommendationLogic(user *models.User, stats *models.UserTrainingStats) *models.AIRecommendation {
	// 简化的推荐逻辑
	goal := user.Goal
	if goal == "" {
		goal = "strength"
	}

	level := user.Experience
	if level == "" {
		level = "beginner"
	}

	reason := fmt.Sprintf("基于您的目标 (%s) 和健身水平 (%s)，我们为您推荐以下训练计划", goal, level)

	// 简单的运动推荐
	exercises := []map[string]interface{}{
		{"id": "1", "name": "深蹲", "sets": 3, "reps": 12, "muscle_group": "legs"},
		{"id": "2", "name": "卧推", "sets": 3, "reps": 10, "muscle_group": "chest"},
		{"id": "3", "name": "引体向上", "sets": 3, "reps": 8, "muscle_group": "back"},
	}

	exercisesJSON, _ := json.Marshal(exercises)

	return &models.AIRecommendation{
		UserID:    user.ID,
		Reason:    reason,
		Goal:      goal,
		Level:     level,
		Exercises: string(exercisesJSON),
		IsApplied: false,
	}
}

// GetAIRecommendations 获取用户的AI推荐
func (s *TrainingService) GetAIRecommendations(userID uint, limit int) ([]models.AIRecommendation, error) {
	var recommendations []models.AIRecommendation
	err := s.db.
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Limit(limit).
		Preload("Plan.Exercises.Exercise").
		Find(&recommendations).Error
	return recommendations, err
}

// ApplyAIRecommendation 应用AI推荐
func (s *TrainingService) ApplyAIRecommendation(recommendationID uint) (*models.TrainingPlanV2, error) {
	var recommendation models.AIRecommendation
	if err := s.db.First(&recommendation, recommendationID).Error; err != nil {
		return nil, err
	}

	if recommendation.IsApplied {
		return nil, errors.New("recommendation already applied")
	}

	// 解析运动列表
	var exercises []map[string]interface{}
	if err := json.Unmarshal([]byte(recommendation.Exercises), &exercises); err != nil {
		return nil, err
	}

	// 创建训练计划
	plan := &models.TrainingPlanV2{
		UserID:        recommendation.UserID,
		Name:          fmt.Sprintf("AI推荐训练 - %s", time.Now().Format("2006-01-02")),
		Description:   recommendation.Reason,
		Difficulty:    recommendation.Level,
		Goal:          recommendation.Goal,
		IsAIGenerated: true,
	}

	if err := s.CreateTrainingPlan(plan); err != nil {
		return nil, err
	}

	// 标记推荐为已应用
	if err := s.db.Model(&recommendation).Update("is_applied", true).Error; err != nil {
		return nil, err
	}
	if err := s.db.Model(&recommendation).Update("plan_id", plan.ID).Error; err != nil {
		return nil, err
	}

	return plan, nil
}
