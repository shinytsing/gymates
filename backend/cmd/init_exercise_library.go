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
	)

	if err != nil {
		log.Fatal("数据库迁移失败:", err)
	}

	log.Println("数据库迁移成功完成！")

	// 初始化动作库数据
	initExerciseLibrary()
}

func initExerciseLibrary() {
	// 检查是否已有数据
	var count int64
	config.DB.Model(&models.ExerciseLibrary{}).Count(&count)
	if count > 0 {
		log.Println("动作库数据已存在，跳过初始化")
		return
	}

	// 胸部动作
	chestExercises := []models.ExerciseLibrary{
		{Name: "Bench Press", Part: "chest", Level: "intermediate", Type: "compound", Equipment: "barbell", MuscleGroups: "chest,triceps,shoulders", Description: "经典胸部训练动作", Instructions: "平躺在卧推凳上，双手握杠铃，缓慢下放至胸部，然后推起"},
		{Name: "Incline Press", Part: "chest", Level: "intermediate", Type: "compound", Equipment: "barbell", MuscleGroups: "chest,triceps,shoulders", Description: "上斜卧推", Instructions: "调整卧推凳角度至30-45度，进行卧推动作"},
		{Name: "Chest Fly", Part: "chest", Level: "beginner", Type: "isolation", Equipment: "dumbbell", MuscleGroups: "chest", Description: "胸部飞鸟", Instructions: "平躺，双手持哑铃，缓慢向两侧展开，感受胸部拉伸"},
		{Name: "Push-up", Part: "chest", Level: "beginner", Type: "compound", Equipment: "bodyweight", MuscleGroups: "chest,triceps,shoulders", Description: "俯卧撑", Instructions: "双手与肩同宽，保持身体挺直，上下运动"},
		{Name: "Dumbbell Press", Part: "chest", Level: "intermediate", Type: "compound", Equipment: "dumbbell", MuscleGroups: "chest,triceps,shoulders", Description: "哑铃卧推", Instructions: "平躺，双手持哑铃，缓慢下放至胸部两侧，然后推起"},
		{Name: "Decline Press", Part: "chest", Level: "advanced", Type: "compound", Equipment: "barbell", MuscleGroups: "chest,triceps", Description: "下斜卧推", Instructions: "调整卧推凳为下斜角度，进行卧推动作"},
		{Name: "Cable Fly", Part: "chest", Level: "intermediate", Type: "isolation", Equipment: "cable", MuscleGroups: "chest", Description: "绳索飞鸟", Instructions: "使用绳索器械，双手向中间合拢，感受胸部收缩"},
	}

	// 背部动作
	backExercises := []models.ExerciseLibrary{
		{Name: "Pull-up", Part: "back", Level: "intermediate", Type: "compound", Equipment: "pullup_bar", MuscleGroups: "back,biceps", Description: "引体向上", Instructions: "双手正握单杠，身体垂直上拉至下巴过杠"},
		{Name: "Barbell Row", Part: "back", Level: "intermediate", Type: "compound", Equipment: "barbell", MuscleGroups: "back,biceps", Description: "杠铃划船", Instructions: "弯腰90度，双手握杠铃，向腹部拉拽"},
		{Name: "Lat Pulldown", Part: "back", Level: "beginner", Type: "compound", Equipment: "cable", MuscleGroups: "back,biceps", Description: "高位下拉", Instructions: "坐在器械上，双手握杆，向下拉至胸部"},
		{Name: "Deadlift", Part: "back", Level: "advanced", Type: "compound", Equipment: "barbell", MuscleGroups: "back,legs,glutes", Description: "硬拉", Instructions: "双脚与肩同宽，弯腰握杠铃，挺直身体拉起"},
		{Name: "T-Bar Row", Part: "back", Level: "intermediate", Type: "compound", Equipment: "barbell", MuscleGroups: "back,biceps", Description: "T杠划船", Instructions: "使用T杠器械，向胸部拉拽"},
		{Name: "Seated Row", Part: "back", Level: "beginner", Type: "compound", Equipment: "cable", MuscleGroups: "back,biceps", Description: "坐姿划船", Instructions: "坐在器械上，双手握杆，向腹部拉拽"},
		{Name: "Face Pull", Part: "back", Level: "intermediate", Type: "isolation", Equipment: "cable", MuscleGroups: "rear_delts,rhomboids", Description: "面拉", Instructions: "使用绳索，向面部拉拽，感受后三角肌收缩"},
	}

	// 腿部动作
	legExercises := []models.ExerciseLibrary{
		{Name: "Squat", Part: "legs", Level: "intermediate", Type: "compound", Equipment: "barbell", MuscleGroups: "quads,glutes,hamstrings", Description: "深蹲", Instructions: "双脚与肩同宽，下蹲至大腿平行地面，然后站起"},
		{Name: "Leg Press", Part: "legs", Level: "beginner", Type: "compound", Equipment: "machine", MuscleGroups: "quads,glutes", Description: "腿举", Instructions: "坐在器械上，双脚推举重量"},
		{Name: "Lunge", Part: "legs", Level: "intermediate", Type: "compound", Equipment: "bodyweight", MuscleGroups: "quads,glutes,hamstrings", Description: "弓步蹲", Instructions: "向前迈一大步，下蹲至后膝接近地面"},
		{Name: "Calf Raise", Part: "legs", Level: "beginner", Type: "isolation", Equipment: "bodyweight", MuscleGroups: "calves", Description: "提踵", Instructions: "双脚并拢，踮起脚尖，感受小腿收缩"},
		{Name: "Romanian Deadlift", Part: "legs", Level: "intermediate", Type: "compound", Equipment: "barbell", MuscleGroups: "hamstrings,glutes", Description: "罗马尼亚硬拉", Instructions: "保持腿部微弯，弯腰下放杠铃至膝盖下方"},
		{Name: "Bulgarian Split Squat", Part: "legs", Level: "intermediate", Type: "compound", Equipment: "bodyweight", MuscleGroups: "quads,glutes", Description: "保加利亚分腿蹲", Instructions: "后脚抬高，前腿下蹲"},
		{Name: "Leg Extension", Part: "legs", Level: "beginner", Type: "isolation", Equipment: "machine", MuscleGroups: "quads", Description: "腿屈伸", Instructions: "坐在器械上，双腿向前伸展"},
	}

	// 肩部动作
	shoulderExercises := []models.ExerciseLibrary{
		{Name: "Shoulder Press", Part: "shoulders", Level: "intermediate", Type: "compound", Equipment: "dumbbell", MuscleGroups: "shoulders,triceps", Description: "肩推", Instructions: "双手持哑铃，从肩部推举至头顶"},
		{Name: "Lateral Raise", Part: "shoulders", Level: "beginner", Type: "isolation", Equipment: "dumbbell", MuscleGroups: "shoulders", Description: "侧平举", Instructions: "双手持哑铃，向两侧平举至肩高"},
		{Name: "Rear Delt Fly", Part: "shoulders", Level: "intermediate", Type: "isolation", Equipment: "dumbbell", MuscleGroups: "rear_delts", Description: "后三角肌飞鸟", Instructions: "弯腰，双手持哑铃向两侧展开"},
		{Name: "Front Raise", Part: "shoulders", Level: "beginner", Type: "isolation", Equipment: "dumbbell", MuscleGroups: "front_delts", Description: "前平举", Instructions: "双手持哑铃，向前平举至肩高"},
		{Name: "Upright Row", Part: "shoulders", Level: "intermediate", Type: "compound", Equipment: "barbell", MuscleGroups: "shoulders,traps", Description: "直立划船", Instructions: "双手握杠铃，向上拉至胸部"},
		{Name: "Arnold Press", Part: "shoulders", Level: "intermediate", Type: "compound", Equipment: "dumbbell", MuscleGroups: "shoulders", Description: "阿诺德推举", Instructions: "哑铃从胸部旋转推举至头顶"},
		{Name: "Shrug", Part: "shoulders", Level: "beginner", Type: "isolation", Equipment: "barbell", MuscleGroups: "traps", Description: "耸肩", Instructions: "双手握杠铃，向上耸肩"},
	}

	// 手臂动作
	armExercises := []models.ExerciseLibrary{
		{Name: "Bicep Curl", Part: "arms", Level: "beginner", Type: "isolation", Equipment: "dumbbell", MuscleGroups: "biceps", Description: "二头弯举", Instructions: "双手持哑铃，弯曲肘部向上举起"},
		{Name: "Tricep Extension", Part: "arms", Level: "beginner", Type: "isolation", Equipment: "dumbbell", MuscleGroups: "triceps", Description: "三头伸展", Instructions: "双手持哑铃，向后伸展手臂"},
		{Name: "Hammer Curl", Part: "arms", Level: "beginner", Type: "isolation", Equipment: "dumbbell", MuscleGroups: "biceps,forearms", Description: "锤式弯举", Instructions: "双手持哑铃，保持中立握法弯举"},
		{Name: "Close Grip Press", Part: "arms", Level: "intermediate", Type: "compound", Equipment: "barbell", MuscleGroups: "triceps,chest", Description: "窄握卧推", Instructions: "双手窄握杠铃，进行卧推动作"},
		{Name: "Preacher Curl", Part: "arms", Level: "intermediate", Type: "isolation", Equipment: "barbell", MuscleGroups: "biceps", Description: "牧师椅弯举", Instructions: "使用牧师椅，进行二头弯举"},
		{Name: "Overhead Extension", Part: "arms", Level: "intermediate", Type: "isolation", Equipment: "dumbbell", MuscleGroups: "triceps", Description: "过头伸展", Instructions: "双手持哑铃举过头顶，向后伸展"},
		{Name: "Cable Curl", Part: "arms", Level: "beginner", Type: "isolation", Equipment: "cable", MuscleGroups: "biceps", Description: "绳索弯举", Instructions: "使用绳索器械，进行二头弯举"},
	}

	// 核心动作
	coreExercises := []models.ExerciseLibrary{
		{Name: "Crunch", Part: "core", Level: "beginner", Type: "isolation", Equipment: "bodyweight", MuscleGroups: "abs", Description: "卷腹", Instructions: "平躺，膝盖弯曲，向上卷起上半身"},
		{Name: "Plank", Part: "core", Level: "beginner", Type: "isometric", Equipment: "bodyweight", MuscleGroups: "core", Description: "平板支撑", Instructions: "保持身体成一条直线，核心收紧"},
		{Name: "Leg Raise", Part: "core", Level: "intermediate", Type: "isolation", Equipment: "bodyweight", MuscleGroups: "lower_abs", Description: "抬腿", Instructions: "平躺，双腿向上抬起至90度"},
		{Name: "Russian Twist", Part: "core", Level: "intermediate", Type: "isolation", Equipment: "bodyweight", MuscleGroups: "obliques", Description: "俄罗斯转体", Instructions: "坐姿，双腿抬起，左右转体"},
		{Name: "Mountain Climber", Part: "core", Level: "intermediate", Type: "cardio", Equipment: "bodyweight", MuscleGroups: "core,cardio", Description: "登山者", Instructions: "平板支撑姿势，交替提膝"},
		{Name: "Dead Bug", Part: "core", Level: "beginner", Type: "isolation", Equipment: "bodyweight", MuscleGroups: "core", Description: "死虫式", Instructions: "平躺，对侧手脚同时伸展"},
		{Name: "Bicycle Crunch", Part: "core", Level: "intermediate", Type: "isolation", Equipment: "bodyweight", MuscleGroups: "abs,obliques", Description: "自行车卷腹", Instructions: "平躺，模拟骑自行车动作"},
	}

	// 合并所有动作
	allExercises := append(chestExercises, backExercises...)
	allExercises = append(allExercises, legExercises...)
	allExercises = append(allExercises, shoulderExercises...)
	allExercises = append(allExercises, armExercises...)
	allExercises = append(allExercises, coreExercises...)

	// 批量插入动作库
	if err := config.DB.CreateInBatches(allExercises, 50).Error; err != nil {
		log.Fatal("初始化动作库失败:", err)
	}

	log.Printf("成功初始化 %d 个动作到动作库", len(allExercises))
}
