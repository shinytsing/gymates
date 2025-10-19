package main

import (
	"log"
	"gymates-backend/config"
	"gymates-backend/models"
)

func main() {
	// 初始化数据库连接
	config.InitDB()

	// 自动迁移数据库表结构
	err := config.DB.AutoMigrate(
		&models.User{},
		&models.TrainingPlan{},
		&models.Exercise{},
		&models.WorkoutSession{},
		&models.Post{},
		&models.Comment{},
		&models.PostLike{},
		&models.Mate{},
		&models.Chat{},
		&models.Message{},
		&models.ChatParticipant{},
		&models.Achievement{},
		&models.Notification{},
		// 新增的一周训练计划相关表
		&models.WeeklyTrainingPlan{},
		&models.TrainingDay{},
		&models.TrainingPart{},
		// 新增的动作库相关表
		&models.ExerciseLibrary{},
		&models.TrainingMode{},
		&models.UserTrainingHistory{},
		// 新增的AI训练相关表
		&models.UserTrainingPreferences{},
		&models.AITrainingSession{},
		&models.VoiceSettings{},
	)

	if err != nil {
		log.Fatal("数据库迁移失败:", err)
	}

	log.Println("数据库迁移成功完成！")

	// 创建一些示例数据
	createSampleData()
}

func createSampleData() {
	// 创建示例用户
	user := models.User{
		Name:      "测试用户",
		Email:     "test@example.com",
		Password:  "password123", // 实际应用中应该加密
		Avatar:    "https://via.placeholder.com/150",
		Bio:       "健身爱好者",
		Location:  "北京",
		Age:       25,
		Height:    175.0,
		Weight:    70.0,
		Goal:      "增肌",
		Experience: "中级",
	}

	// 检查用户是否已存在
	var existingUser models.User
	if err := config.DB.Where("email = ?", user.Email).First(&existingUser).Error; err != nil {
		// 用户不存在，创建新用户
		if err := config.DB.Create(&user).Error; err != nil {
			log.Printf("创建示例用户失败: %v", err)
			return
		}
		log.Println("创建示例用户成功")
	} else {
		user = existingUser
		log.Println("示例用户已存在")
	}

	// 创建示例动作
	exercises := []models.Exercise{
		{
			Name:         "俯卧撑",
			Description:  "经典的上肢训练动作",
			MuscleGroup:  "chest",
			Difficulty:   "中等",
			Equipment:    "无器械",
			Sets:         3,
			Reps:         15,
			Weight:       0,
			Duration:     30,
			RestTime:     60,
			RestSeconds:  60,
			Instructions: "保持身体挺直，双手与肩同宽",
			ImageURL:     "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400",
			Calories:     50,
			Order:        1,
		},
		{
			Name:         "深蹲",
			Description:  "经典的下肢训练动作",
			MuscleGroup:  "legs",
			Difficulty:   "中等",
			Equipment:    "无器械",
			Sets:         3,
			Reps:         20,
			Weight:       0,
			Duration:     45,
			RestTime:     90,
			RestSeconds:  90,
			Instructions: "双脚与肩同宽，下蹲至大腿平行地面",
			ImageURL:     "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400",
			Calories:     80,
			Order:        2,
		},
		{
			Name:         "引体向上",
			Description:  "背部训练经典动作",
			MuscleGroup:  "back",
			Difficulty:   "困难",
			Equipment:    "单杠",
			Sets:         3,
			Reps:         8,
			Weight:       0,
			Duration:     60,
			RestTime:     120,
			RestSeconds:  120,
			Instructions: "双手正握单杠，身体垂直上拉",
			ImageURL:     "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400",
			Calories:     100,
			Order:        3,
		},
		{
			Name:         "平板支撑",
			Description:  "核心力量训练",
			MuscleGroup:  "core",
			Difficulty:   "中等",
			Equipment:    "无器械",
			Sets:         3,
			Reps:         1,
			Weight:       0,
			Duration:     60,
			RestTime:     90,
			RestSeconds:  90,
			Instructions: "保持身体成一条直线，核心收紧",
			ImageURL:     "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400",
			Calories:     40,
			Order:        4,
		},
		{
			Name:         "肩推",
			Description:  "肩部力量训练",
			MuscleGroup:  "shoulders",
			Difficulty:   "中等",
			Equipment:    "哑铃",
			Sets:         3,
			Reps:         12,
			Weight:       10,
			Duration:     40,
			RestTime:     75,
			RestSeconds:  75,
			Instructions: "双手持哑铃，从肩部推举至头顶",
			ImageURL:     "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400",
			Calories:     60,
			Order:        5,
		},
	}

	// 检查动作是否已存在，如果不存在则创建
	for _, exercise := range exercises {
		var existingExercise models.Exercise
		if err := config.DB.Where("name = ?", exercise.Name).First(&existingExercise).Error; err != nil {
			if err := config.DB.Create(&exercise).Error; err != nil {
				log.Printf("创建示例动作 %s 失败: %v", exercise.Name, err)
			} else {
				log.Printf("创建示例动作 %s 成功", exercise.Name)
			}
		}
	}

	// 创建示例一周训练计划
	weeklyPlan := models.WeeklyTrainingPlan{
		UserID:      user.ID,
		Name:        "我的第一周训练计划",
		Description:  "适合初学者的全身训练计划",
		IsActive:    true,
		IsPublic:    false,
	}

	// 检查计划是否已存在
	var existingPlan models.WeeklyTrainingPlan
	if err := config.DB.Where("user_id = ? AND name = ?", user.ID, weeklyPlan.Name).First(&existingPlan).Error; err != nil {
		// 计划不存在，创建新计划
		if err := config.DB.Create(&weeklyPlan).Error; err != nil {
			log.Printf("创建示例一周训练计划失败: %v", err)
			return
		}
		log.Println("创建示例一周训练计划成功")

		// 创建训练日
		dayNames := []string{"周一", "周二", "周三", "周四", "周五", "周六", "周日"}
		for i, dayName := range dayNames {
			day := models.TrainingDay{
				WeeklyTrainingPlanID: weeklyPlan.ID,
				DayOfWeek:            i + 1,
				DayName:              dayName,
				IsRestDay:            i == 6, // 周日为休息日
			}

			if err := config.DB.Create(&day).Error; err != nil {
				log.Printf("创建训练日 %s 失败: %v", dayName, err)
				continue
			}

			// 为非休息日添加训练部位
			if !day.IsRestDay {
				muscleGroups := map[string]string{
					"chest":     "胸部",
					"back":      "背部", 
					"legs":      "腿部",
					"shoulders": "肩部",
					"arms":      "手臂",
					"core":      "核心",
				}

				// 为不同天分配不同肌群
				muscleGroupKeys := []string{"chest", "back", "legs", "shoulders", "arms", "core"}
				if i < len(muscleGroupKeys) {
					muscleGroup := muscleGroupKeys[i]
					part := models.TrainingPart{
						TrainingDayID:     day.ID,
						MuscleGroup:       muscleGroup,
						MuscleGroupName:   muscleGroups[muscleGroup],
						Order:             0,
					}

					if err := config.DB.Create(&part).Error; err != nil {
						log.Printf("创建训练部位 %s 失败: %v", muscleGroup, err)
						continue
					}

					// 为训练部位添加动作
					for _, exercise := range exercises {
						if exercise.MuscleGroup == muscleGroup {
							exercise.TrainingPartID = &part.ID
							exercise.TrainingPlanID = weeklyPlan.ID
							if err := config.DB.Create(&exercise).Error; err != nil {
								log.Printf("创建训练动作 %s 失败: %v", exercise.Name, err)
							}
						}
					}
				}
			}
		}
	} else {
		log.Println("示例一周训练计划已存在")
	}

	log.Println("示例数据创建完成！")
}
