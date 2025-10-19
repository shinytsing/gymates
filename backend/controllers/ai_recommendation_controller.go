package controllers

import (
	"math/rand"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gymates-backend/config"
	"gymates-backend/models"
)

// AIRecommendationController AI推荐控制器
type AIRecommendationController struct{}

// NewAIRecommendationController 创建AI推荐控制器
func NewAIRecommendationController() *AIRecommendationController {
	return &AIRecommendationController{}
}

// GetAIRecommendation 获取AI推荐训练
// GET /api/training/ai/recommend?user_id={uid}&day={Monday}
func (aic *AIRecommendationController) GetAIRecommendation(c *gin.Context) {
	userIDStr := c.Query("user_id")
	day := c.Query("day")
	muscleGroup := c.Query("muscle_group") // 可选指定肌群

	if userIDStr == "" || day == "" {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "用户ID和训练日不能为空",
			Error:   "user_id and day are required",
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

	// 获取用户训练模式
	var trainingMode models.TrainingMode
	if err := config.DB.Where("user_id = ? AND is_active = ?", uint(userID), true).
		First(&trainingMode).Error; err != nil {
		// 如果没有设置训练模式，使用默认的三分化
		trainingMode = models.TrainingMode{
			UserID:    uint(userID),
			Mode:      "三分化",
			TrainDays: 3,
			Target:    "增肌",
			Level:     "中级",
			IsActive:  true,
		}
	}

	// 获取用户训练历史
	var recentHistory []models.UserTrainingHistory
	config.DB.Where("user_id = ? AND completed_at > ?", uint(userID), time.Now().AddDate(0, 0, -7)).
		Order("completed_at DESC").
		Limit(20).
		Find(&recentHistory)

	// 根据训练模式和训练日确定目标肌群
	targetMuscleGroups := aic.getTargetMuscleGroups(day, trainingMode.Mode, muscleGroup)

	// 生成推荐
	recommendation := models.AIRecommendationResponse{
		UserID: uint(userID),
		Day:    day,
		Parts:  []models.RecommendedPart{},
		Mode:   trainingMode.Mode,
		Target: trainingMode.Target,
	}

	// 为每个目标肌群生成推荐动作
	for _, muscleGroup := range targetMuscleGroups {
		part := models.RecommendedPart{
			PartName:  getPartName(muscleGroup),
			Exercises: []models.RecommendedExercise{},
		}

		// 从动作库中筛选动作
		var exercises []models.ExerciseLibrary
		query := config.DB.Where("part = ?", muscleGroup)
		
		// 根据用户等级筛选
		if trainingMode.Level == "初级" {
			query = query.Where("level IN (?)", []string{"beginner", "intermediate"})
		} else if trainingMode.Level == "高级" {
			query = query.Where("level IN (?)", []string{"intermediate", "advanced"})
		}

		// 避免重复最近训练的动作
		if len(recentHistory) > 0 {
			var recentExerciseIDs []uint
			for _, history := range recentHistory {
				if history.MuscleGroup == muscleGroup {
					recentExerciseIDs = append(recentExerciseIDs, history.ExerciseID)
				}
			}
			if len(recentExerciseIDs) > 0 {
				query = query.Where("id NOT IN (?)", recentExerciseIDs)
			}
		}

		// 随机选择5-7个动作
		limit := 7
		if trainingMode.Target == "减脂" {
			limit = 5 // 减脂训练动作少一些
		}
		
		query.Order("RANDOM()").Limit(limit).Find(&exercises)

		// 转换为推荐动作
		for _, exercise := range exercises {
			recommendedExercise := models.RecommendedExercise{
				Name:        exercise.Name,
				Sets:        aic.generateSets(trainingMode.Target, trainingMode.Level),
				Reps:        aic.generateReps(trainingMode.Target, trainingMode.Level),
				Weight:      aic.generateWeight(uint(userID), exercise.Name),
				RestSeconds: aic.generateRestTime(trainingMode.Target, trainingMode.Level),
				Part:        exercise.Part,
				Description: exercise.Description,
				VideoURL:    "",
				Notes:       "",
			}
			part.Exercises = append(part.Exercises, recommendedExercise)
		}

		if len(part.Exercises) > 0 {
			recommendation.Parts = append(recommendation.Parts, part)
		}
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "AI推荐生成成功",
		Data:    recommendation,
	})
}

// 根据训练模式和训练日确定目标肌群
func (aic *AIRecommendationController) getTargetMuscleGroups(day, mode, specifiedMuscleGroup string) []string {
	if specifiedMuscleGroup != "" {
		return []string{specifiedMuscleGroup}
	}

	switch mode {
	case "三分化":
		return aic.getThreeDaySplitMuscleGroups(day)
	case "五分化":
		return aic.getFiveDaySplitMuscleGroups(day)
	case "推拉腿":
		return aic.getPushPullLegMuscleGroups(day)
	default:
		// 默认三分化
		return aic.getThreeDaySplitMuscleGroups(day)
	}
}

// 三分化训练肌群分配
func (aic *AIRecommendationController) getThreeDaySplitMuscleGroups(day string) []string {
	switch day {
	case "Monday", "Thursday":
		return []string{"chest", "shoulders", "arms"} // 推日
	case "Tuesday", "Friday":
		return []string{"back", "arms"} // 拉日
	case "Wednesday", "Saturday":
		return []string{"legs", "core"} // 腿日
	default:
		return []string{"core"} // 周日核心训练
	}
}

// 五分化训练肌群分配
func (aic *AIRecommendationController) getFiveDaySplitMuscleGroups(day string) []string {
	switch day {
	case "Monday":
		return []string{"chest"}
	case "Tuesday":
		return []string{"back"}
	case "Wednesday":
		return []string{"legs"}
	case "Thursday":
		return []string{"shoulders"}
	case "Friday":
		return []string{"arms"}
	case "Saturday":
		return []string{"core"}
	default:
		return []string{"core"} // 周日核心训练
	}
}

// 推拉腿训练肌群分配
func (aic *AIRecommendationController) getPushPullLegMuscleGroups(day string) []string {
	switch day {
	case "Monday", "Thursday":
		return []string{"chest", "shoulders", "arms"} // 推日
	case "Tuesday", "Friday":
		return []string{"back", "arms"} // 拉日
	case "Wednesday", "Saturday":
		return []string{"legs", "core"} // 腿日
	default:
		return []string{"core"} // 周日核心训练
	}
}

// 生成组数
func (aic *AIRecommendationController) generateSets(target, level string) int {
	switch target {
	case "增肌":
		if level == "初级" {
			return 3
		} else if level == "中级" {
			return 4
		} else {
			return 5
		}
	case "减脂":
		return 3
	default: // 综合
		return 4
	}
}

// 生成次数
func (aic *AIRecommendationController) generateReps(target, level string) int {
	switch target {
	case "增肌":
		if level == "初级" {
			return 10 + rand.Intn(3) // 10-12
		} else if level == "中级" {
			return 8 + rand.Intn(5) // 8-12
		} else {
			return 6 + rand.Intn(7) // 6-12
		}
	case "减脂":
		return 12 + rand.Intn(6) // 12-17
	default: // 综合
		return 10 + rand.Intn(5) // 10-14
	}
}

// 生成重量（基于历史数据）
func (aic *AIRecommendationController) generateWeight(userID uint, exerciseName string) float64 {
	var history models.UserTrainingHistory
	if err := config.DB.Where("user_id = ? AND exercise_id IN (SELECT id FROM exercise_libraries WHERE name = ?)", userID, exerciseName).
		Order("completed_at DESC").
		First(&history).Error; err == nil {
		// 基于历史重量，增减5%
		variation := 0.05
		if rand.Float64() < 0.5 {
			variation = -variation
		}
		return history.Weight * (1 + variation)
	}
	
	// 如果没有历史数据，使用默认重量
	return 20.0 + rand.Float64()*40.0 // 20-60kg
}

// 生成休息时间
func (aic *AIRecommendationController) generateRestTime(target, level string) int {
	switch target {
	case "增肌":
		if level == "初级" {
			return 60 + rand.Intn(30) // 60-90秒
		} else if level == "中级" {
			return 90 + rand.Intn(30) // 90-120秒
		} else {
			return 120 + rand.Intn(60) // 120-180秒
		}
	case "减脂":
		return 30 + rand.Intn(30) // 30-60秒
	default: // 综合
		return 60 + rand.Intn(60) // 60-120秒
	}
}

// 获取部位名称
func getPartName(muscleGroup string) string {
	partMap := map[string]string{
		"chest":     "Chest",
		"back":      "Back",
		"legs":      "Legs",
		"shoulders": "Shoulders",
		"arms":      "Arms",
		"core":      "Core",
	}
	return partMap[muscleGroup]
}
