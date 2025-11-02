package main

import (
	"fmt"
	"log"
	"math/rand"
	"time"

	"gymates-backend/config"
	"gymates-backend/models"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func main() {
	// 初始化随机数种子
	rand.Seed(time.Now().UnixNano())

	// 初始化数据库
	err := config.InitDB()
	if err != nil {
		log.Fatalf("❌ 数据库初始化失败: %v", err)
	}

	db := config.DB

	fmt.Println("🚀 开始注入丰富的测试数据...")

	// 1. 创建用户（包括小王）
	users := seedRichUsers(db)
	fmt.Printf("✅ 创建了 %d 个用户\n", len(users))

	// 2. 创建训练计划
	trainingPlans := seedRichTrainingPlans(db, users)
	fmt.Printf("✅ 创建了 %d 个训练计划\n", len(trainingPlans))

	// 3. 创建训练动作
	exercises := seedRichExercises(db, trainingPlans)
	fmt.Printf("✅ 创建了 %d 个训练动作\n", len(exercises))

	// 4. 创建训练记录
	sessions := seedRichWorkoutSessions(db, users, trainingPlans)
	fmt.Printf("✅ 创建了 %d 个训练记录\n", len(sessions))

	// 5. 创建社区帖子
	posts := seedRichPosts(db, users)
	fmt.Printf("✅ 创建了 %d 个社区帖子\n", len(posts))

	// 6. 创建评论
	comments := seedRichComments(db, users, posts)
	fmt.Printf("✅ 创建了 %d 条评论\n", len(comments))

	// 7. 创建点赞
	likes := seedRichLikes(db, users, posts)
	fmt.Printf("✅ 创建了 %d 个点赞\n", len(likes))

	// 8. 创建搭子关系
	mates := seedRichMates(db, users)
	fmt.Printf("✅ 创建了 %d 个搭子关系\n", len(mates))

	// 9. 创建成就
	achievements := seedRichAchievements(db, users)
	fmt.Printf("✅ 创建了 %d 个成就\n", len(achievements))

	// 10. 创建通知
	notifications := seedRichNotifications(db, users)
	fmt.Printf("✅ 创建了 %d 条通知\n", len(notifications))

	fmt.Println("🎉 所有丰富测试数据注入完成！")
	fmt.Println("\n📱 可以使用以下账号登录:")
	fmt.Println("👤 健身达人小王: 13900139000 / password123")
	fmt.Println("👤 健身教练张强: 13900139001 / password123")
	fmt.Println("👤 瑜伽老师李美: 13900139002 / password123")
	fmt.Println("👤 跑步达人王磊: 13900139003 / password123")
	fmt.Println("👤 普通用户刘洋: 13900139004 / password123")
}

// seedRichUsers 创建丰富的测试用户
func seedRichUsers(db *gorm.DB) []models.User {
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)

	// 先删除可能存在的测试用户（通过email或phone匹配）
	db.Unscoped().Where("email LIKE '%@gymates.com' OR phone LIKE '139001390%'").Delete(&models.User{})

	users := []models.User{
		{
			Name:           "健身达人小王",
			Email:          "xiaowang@gymates.com",
			Phone:          "13900139000",
			Password:       string(hashedPassword),
			Avatar:         "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400",
			Bio:            "💪 5年健身经验！专注力量训练和体态矫正。市级健美大赛第二名。自由职业健身博主，热爱分享健身知识！周末经常组织团建活动~",
			Location:       "北京市海淀区中关村",
			Latitude:       39.9893,
			Longitude:      116.3138,
			Age:            29,
			Gender:         "male",
			Height:         180.0,
			Weight:         82.0,
			Goal:           "保持体型,提升力量",
			Experience:     "高级",
			PreferredTime:  "下午 4-6点",
			TrainingTypes:  "力量训练,CrossFit,搏击,游泳,篮球",
			LookingForMate: true,
			LoginType:      "email",
		},
		{
			Name:           "健身教练张强",
			Email:          "zhangqiang@gymates.com",
			Phone:          "13900139001",
			Password:       string(hashedPassword),
			Avatar:         "https://images.unsplash.com/photo-1607286908165-b8b6a2874fc4?w=400",
			Bio:            "🏋️ 国家二级健身指导员，10年执教经验。擅长增肌减脂、功能性训练。帮助过500+学员达成目标！",
			Location:       "北京市朝阳区三里屯",
			Latitude:       39.9357,
			Longitude:      116.4475,
			Age:            32,
			Gender:         "male",
			Height:         178.0,
			Weight:         85.0,
			Goal:           "增肌",
			Experience:     "专业",
			PreferredTime:  "全天",
			TrainingTypes:  "力量训练,CrossFit,功能性训练,HIIT",
			LookingForMate: true,
			LoginType:      "email",
		},
		{
			Name:           "瑜伽老师李美",
			Email:          "limei@gymates.com",
			Phone:          "13900139002",
			Password:       string(hashedPassword),
			Avatar:         "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400",
			Bio:            "🧘‍♀️ RYT200认证瑜伽教练。专注哈他、阿斯汤加瑜伽。身心灵的平衡才是真正的健康~",
			Location:       "北京市东城区",
			Latitude:       39.9289,
			Longitude:      116.4203,
			Age:            27,
			Gender:         "female",
			Height:         165.0,
			Weight:         52.0,
			Goal:           "保持体型,提升柔韧性",
			Experience:     "高级",
			PreferredTime:  "早上 7-9点",
			TrainingTypes:  "瑜伽,普拉提,冥想",
			LookingForMate: true,
			LoginType:      "email",
		},
		{
			Name:           "跑步达人王磊",
			Email:          "wanglei@gymates.com",
			Phone:          "13900139003",
			Password:       string(hashedPassword),
			Avatar:         "https://images.unsplash.com/photo-1566753323558-f4e0952af115?w=400",
			Bio:            "🏃 全马330完赛者！每周跑量70km+。北京跑团核心成员，热爱户外运动，约跑随时欢迎！",
			Location:       "北京市西城区",
			Latitude:       39.9139,
			Longitude:      116.3664,
			Age:            31,
			Gender:         "male",
			Height:         175.0,
			Weight:         65.0,
			Goal:           "提升耐力",
			Experience:     "高级",
			PreferredTime:  "早上 5-7点",
			TrainingTypes:  "跑步,游泳,骑行",
			LookingForMate: true,
			LoginType:      "email",
		},
		{
			Name:           "健身新手刘洋",
			Email:          "liuyang@gymates.com",
			Phone:          "13900139004",
			Password:       string(hashedPassword),
			Avatar:         "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400",
			Bio:            "健身小白，刚开始健身之旅！希望能找到靠谱的搭子一起进步💪",
			Location:       "北京市丰台区",
			Latitude:       39.8586,
			Longitude:      116.2867,
			Age:            24,
			Gender:         "male",
			Height:         172.0,
			Weight:         68.0,
			Goal:           "减脂,增肌",
			Experience:     "初级",
			PreferredTime:  "晚上 7-9点",
			TrainingTypes:  "力量训练,有氧运动",
			LookingForMate: true,
			LoginType:      "email",
		},
		{
			Name:           "减脂达人陈欣",
			Email:          "chenxin@gymates.com",
			Phone:          "13900139005",
			Password:       string(hashedPassword),
			Avatar:         "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400",
			Bio:            "📉 成功减重25kg！从130斤到105斤，坚持就是胜利。现在热爱HIIT和力量训练~",
			Location:       "北京市石景山区",
			Latitude:       39.9063,
			Longitude:      116.2228,
			Age:            26,
			Gender:         "female",
			Height:         160.0,
			Weight:         52.5,
			Goal:           "保持体型",
			Experience:     "中级",
			PreferredTime:  "晚上 6-8点",
			TrainingTypes:  "HIIT,力量训练,有氧运动",
			LookingForMate: true,
			LoginType:      "email",
		},
		{
			Name:           "搏击教练赵刚",
			Email:          "zhaogang@gymates.com",
			Phone:          "13900139006",
			Password:       string(hashedPassword),
			Avatar:         "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400",
			Bio:            "🥊 拳击、泰拳教练。实战经验丰富，可以教授自卫术和搏击技巧。让你在锻炼的同时学会保护自己！",
			Location:       "北京市昌平区",
			Latitude:       40.2206,
			Longitude:      116.2312,
			Age:            30,
			Gender:         "male",
			Height:         176.0,
			Weight:         72.0,
			Goal:           "提升力量,保持体型",
			Experience:     "专业",
			PreferredTime:  "下午 2-10点",
			TrainingTypes:  "搏击,力量训练,HIIT",
			LookingForMate: true,
			LoginType:      "email",
		},
		{
			Name:           "游泳教练孙丽",
			Email:          "sunli@gymates.com",
			Phone:          "13900139007",
			Password:       string(hashedPassword),
			Avatar:         "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400",
			Bio:            "🏊‍♀️ 游泳国家二级运动员。专业教授自由泳、蛙泳、仰泳、蝶泳。水中健身，低冲击高效果！",
			Location:       "北京市海淀区",
			Latitude:       39.9591,
			Longitude:      116.2980,
			Age:            28,
			Gender:         "female",
			Height:         168.0,
			Weight:         56.0,
			Goal:           "保持体型,提升耐力",
			Experience:     "专业",
			PreferredTime:  "下午 3-8点",
			TrainingTypes:  "游泳,有氧运动",
			LookingForMate: true,
			LoginType:      "email",
		},
	}

	// 创建用户并获取ID
	for i := range users {
		// 使用原生SQL插入，避免GORM的空字符串问题
		result := db.Exec(`INSERT INTO users 
			(name, email, phone, password, avatar, bio, location, latitude, longitude, 
			 age, gender, height, weight, goal, experience, preferred_time, training_types,
			 looking_for_mate, login_type, created_at, updated_at) 
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'), datetime('now'))`,
			users[i].Name, users[i].Email, users[i].Phone, users[i].Password,
			users[i].Avatar, users[i].Bio, users[i].Location, users[i].Latitude, users[i].Longitude,
			users[i].Age, users[i].Gender, users[i].Height, users[i].Weight,
			users[i].Goal, users[i].Experience, users[i].PreferredTime, users[i].TrainingTypes,
			users[i].LookingForMate, users[i].LoginType)
			
		if result.Error != nil {
			fmt.Printf("❌ 创建用户失败: %s, Error: %v\n", users[i].Name, result.Error)
		} else {
			// 重新查询获取ID
			db.Where("email = ?", users[i].Email).First(&users[i])
			fmt.Printf("   ✓ %s (ID: %d)\n", users[i].Name, users[i].ID)
		}
	}

	return users
}

// seedRichTrainingPlans 创建丰富的训练计划
func seedRichTrainingPlans(db *gorm.DB, users []models.User) []models.TrainingPlan {
	plans := []models.TrainingPlan{
		// 小王的训练计划
		{
			UserID:         users[0].ID,
			Name:           "💪 胸肌轰炸日 - 终极版",
			Description:    "专注胸大肌全方位刺激，包含上中下胸部训练。适合有一定基础的健身者，每组做到力竭。重点：慢速离心收缩，顶峰收缩停留2秒。",
			Duration:       90,
			CaloriesBurned: 450,
			Difficulty:     "hard",
			IsPublic:       true,
		},
		{
			UserID:         users[0].ID,
			Name:           "🦅 倒三角背部塑造",
			Description:    "打造宽厚背部，重点训练背阔肌、斜方肌和菱形肌。包含各种拉的变式动作，注意背部发力感。",
			Duration:       85,
			CaloriesBurned: 420,
			Difficulty:     "hard",
			IsPublic:       true,
		},
		{
			UserID:         users[0].ID,
			Name:           "🦵 腿部力量爆发训练",
			Description:    "深蹲为王！全面刺激股四头肌、臀大肌和腘绳肌。包含深蹲、硬拉、箭步蹲等经典动作。练腿日=进步日！",
			Duration:       100,
			CaloriesBurned: 550,
			Difficulty:     "hard",
			IsPublic:       true,
		},
		{
			UserID:         users[0].ID,
			Name:           "🔥 20分钟极速燃脂HIIT",
			Description:    "高强度间歇训练，短时间内达到最大燃脂效果。包含波比跳、登山跑、深蹲跳等爆发力动作。",
			Duration:       20,
			CaloriesBurned: 350,
			Difficulty:     "hard",
			IsPublic:       true,
		},
		// 教练张强的训练计划
		{
			UserID:         users[1].ID,
			Name:           "新手入门全身训练",
			Description:    "适合健身新手的全身性训练计划。从基础动作开始，建立正确的发力模式和动作模式。",
			Duration:       60,
			CaloriesBurned: 300,
			Difficulty:     "beginner",
			IsPublic:       true,
		},
		{
			UserID:         users[1].ID,
			Name:           "增肌进阶训练营",
			Description:    "中级增肌训练计划。采用渐进超负荷原则，系统提升肌肉量和力量水平。",
			Duration:       75,
			CaloriesBurned: 400,
			Difficulty:     "intermediate",
			IsPublic:       true,
		},
		// 瑜伽老师李美的计划
		{
			UserID:         users[2].ID,
			Name:           "🧘‍♀️ 晨间唤醒瑜伽",
			Description:    "适合早晨练习的哈他瑜伽序列。唤醒身体，开启美好一天。",
			Duration:       45,
			CaloriesBurned: 150,
			Difficulty:     "beginner",
			IsPublic:       true,
		},
		{
			UserID:         users[2].ID,
			Name:           "🌙 睡前放松瑜伽",
			Description:    "舒缓的阴瑜伽序列，帮助放松身心，改善睡眠质量。",
			Duration:       30,
			CaloriesBurned: 100,
			Difficulty:     "beginner",
			IsPublic:       true,
		},
		// 跑步达人王磊的计划
		{
			UserID:         users[3].ID,
			Name:           "🏃 5公里轻松跑",
			Description:    "适合日常训练的轻松跑。心率保持在最大心率的65-75%，享受跑步的乐趣。",
			Duration:       30,
			CaloriesBurned: 300,
			Difficulty:     "intermediate",
			IsPublic:       true,
		},
		{
			UserID:         users[3].ID,
			Name:           "⚡ 间歇跑训练",
			Description:    "提升速度和耐力的间歇训练。400m冲刺×8组，组间休息90秒。",
			Duration:       45,
			CaloriesBurned: 450,
			Difficulty:     "hard",
			IsPublic:       true,
		},
		// 减脂达人陈欣的计划
		{
			UserID:         users[5].ID,
			Name:           "🔥 30分钟燃脂大作战",
			Description:    "结合HIIT和力量训练的高效燃脂计划。适合想要快速减脂的你！",
			Duration:       30,
			CaloriesBurned: 380,
			Difficulty:     "intermediate",
			IsPublic:       true,
		},
	}

	for i := range plans {
		db.Create(&plans[i])
	}

	return plans
}

// seedRichExercises 创建训练动作
func seedRichExercises(db *gorm.DB, plans []models.TrainingPlan) []models.Exercise {
	if len(plans) == 0 {
		return []models.Exercise{}
	}

	// 为第一个计划（胸肌轰炸日）添加详细动作
	exercises := []models.Exercise{
		{
			TrainingPlanID: plans[0].ID,
			Name:           "杠铃平板卧推",
			Description:    "胸部训练之王！采用金字塔递增重量法，最后一组做到力竭。",
			MuscleGroup:    "胸大肌,肱三头肌,三角肌前束",
			Equipment:      "杠铃,卧推凳",
			Sets:           4,
			Reps:           10,
			Weight:         80.0,
			RestTime:       90,
			Calories:       80,
			Difficulty:     "intermediate",
			Order:          1,
		},
		{
			TrainingPlanID: plans[0].ID,
			Name:           "上斜哑铃卧推",
			Description:    "针对胸大肌上束。凳子调整为30-45度，顶峰收缩时挤压胸肌。",
			MuscleGroup:    "胸大肌上束,三角肌前束",
			Equipment:      "哑铃,可调节卧推凳",
			Sets:           4,
			Reps:           12,
			Weight:         30.0,
			RestTime:       75,
			Calories:       70,
			Difficulty:     "intermediate",
			Order:          2,
		},
		{
			TrainingPlanID: plans[0].ID,
			Name:           "龙门架夹胸",
			Description:    "孤立刺激胸大肌中缝。顶峰收缩停留2秒，感受胸肌的挤压感。",
			MuscleGroup:    "胸大肌中缝",
			Equipment:      "龙门架",
			Sets:           3,
			Reps:           15,
			RestTime:       60,
			Calories:       50,
			Difficulty:     "easy",
			Order:          3,
		},
		{
			TrainingPlanID: plans[0].ID,
			Name:           "双杠臂屈伸",
			Description:    "下胸部的最佳动作！身体前倾，肘关节向外打开。",
			MuscleGroup:    "胸大肌下束,肱三头肌",
			Equipment:      "双杠",
			Sets:           3,
			Reps:           12,
			RestTime:       90,
			Calories:       60,
			Difficulty:     "hard",
			Order:          4,
		},
		{
			TrainingPlanID: plans[0].ID,
			Name:           "哑铃飞鸟",
			Description:    "完美的收尾动作！充分拉伸胸肌，重量不要太重。",
			MuscleGroup:    "胸大肌",
			Equipment:      "哑铃,卧推凳",
			Sets:           3,
			Reps:           15,
			Weight:         12.0,
			RestTime:       60,
			Calories:       45,
			Difficulty:     "easy",
			Order:          5,
		},
	}

	// 为其他几个计划添加简单动作
	if len(plans) > 1 {
		exercises = append(exercises,
			models.Exercise{
				TrainingPlanID: plans[1].ID,
				Name:           "引体向上",
				Description:    "背部训练之王，发展背阔肌宽度。",
				MuscleGroup:    "背阔肌",
				Equipment:      "引体向上杆",
				Sets:           4,
				Reps:           10,
				RestTime:       90,
				Calories:       70,
				Difficulty:     "hard",
				Order:          1,
			},
			models.Exercise{
				TrainingPlanID: plans[1].ID,
				Name:           "杠铃划船",
				Description:    "增加背部厚度的经典动作。",
				MuscleGroup:    "背阔肌,斜方肌",
				Equipment:      "杠铃",
				Sets:           4,
				Reps:           10,
				Weight:         70.0,
				RestTime:       90,
				Calories:       75,
				Difficulty:     "intermediate",
				Order:          2,
			},
		)
	}

	for i := range exercises {
		db.Create(&exercises[i])
	}

	return exercises
}

// seedRichWorkoutSessions 创建训练记录
func seedRichWorkoutSessions(db *gorm.DB, users []models.User, plans []models.TrainingPlan) []models.WorkoutSession {
	if len(users) == 0 || len(plans) == 0 {
		return []models.WorkoutSession{}
	}

	sessions := []models.WorkoutSession{}

	// 为小王创建最近一周的训练记录
	for i := 1; i <= 7; i++ {
		planIdx := i % len(plans)
		if planIdx >= len(plans) {
			planIdx = 0
		}

		startTime := time.Now().AddDate(0, 0, -i).Add(-2 * time.Hour)
		endTime := startTime.Add(time.Duration(plans[planIdx].Duration) * time.Minute)

		session := models.WorkoutSession{
			UserID:         users[0].ID,
			TrainingPlanID: plans[planIdx].ID,
			Status:         "completed",
			StartTime:      startTime,
			EndTime:        &endTime,
			TotalCalories:  plans[planIdx].CaloriesBurned + rand.Intn(50),
			Progress:       100,
			Notes:          getNotes(i),
		}
		sessions = append(sessions, session)
	}

	// 为其他用户创建一些训练记录
	for i := 1; i < len(users) && i < 5; i++ {
		for j := 1; j <= 3; j++ {
			planIdx := (i + j) % len(plans)
			if planIdx >= len(plans) {
				planIdx = 0
			}

			startTime := time.Now().AddDate(0, 0, -j*2).Add(-2 * time.Hour)
			endTime := startTime.Add(time.Duration(plans[planIdx].Duration) * time.Minute)

			session := models.WorkoutSession{
				UserID:         users[i].ID,
				TrainingPlanID: plans[planIdx].ID,
				Status:         "completed",
				StartTime:      startTime,
				EndTime:        &endTime,
				TotalCalories:  plans[planIdx].CaloriesBurned,
				Progress:       100,
			}
			sessions = append(sessions, session)
		}
	}

	for i := range sessions {
		db.Create(&sessions[i])
	}

	return sessions
}

// seedRichPosts 创建丰富的社区帖子
func seedRichPosts(db *gorm.DB, users []models.User) []models.Post {
	if len(users) == 0 {
		return []models.Post{}
	}

	posts := []models.Post{
		// 小王的帖子
		{
			UserID:  users[0].ID,
			Content: "💪【深蹲技巧分享】很多新手问我深蹲怎么做才标准，今天分享几个关键点：\n\n1⃣ 站距与肩同宽或略宽，脚尖外展15-30度\n2⃣ 膝盖朝向脚尖方向，不要内扣\n3⃣ 髋部先启动，像坐椅子一样向后向下\n4⃣ 蹲到大腿平行地面或更低（量力而行）\n5⃣ 全程保持腰背挺直，核心收紧\n6⃣ 呼吸：下蹲吸气，起身呼气\n\n记住：重量不是最重要的，动作标准才是！#健身技巧 #深蹲",
			Type:    "workout",
			Images:  "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800,https://images.unsplash.com/photo-1434682881908-b43d0467b798?w=800",
			Likes:   156,
			Comments: 23,
			Shares:  12,
			IsPublic: true,
		},
		{
			UserID:  users[0].ID,
			Content: "🔥 今日训练打卡 Day 187\n\n胸肌轰炸日完成！✅\n- 杠铃卧推: 85kg × 8,8,7,6\n- 上斜哑铃: 32.5kg × 10,10,9,8\n- 龙门架夹胸: 15kg × 15,15,12\n\n今天状态真的好！卧推又进步了，泵感满满💪\n\n#健身打卡 #胸肌训练",
			Type:    "workout",
			Images:  "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800",
			Likes:   89,
			Comments: 15,
			Shares:  8,
			IsPublic: true,
		},
		{
			UserID:  users[0].ID,
			Content: "🥗【增肌期饮食分享】分享一下我的一日饮食：\n\n早餐: 燕麦片80g + 牛奶250ml + 水煮蛋3个\n午餐: 糙米饭200g + 牛肉150g + 西兰花200g\n晚餐: 红薯200g + 三文鱼180g + 蔬菜沙拉\n\n每天总热量约3200卡，蛋白质220g+\n\n三分练七分吃！#健身饮食 #增肌餐",
			Type:    "lifestyle",
			Images:  "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800,https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800",
			Likes:   198,
			Comments: 45,
			Shares:  32,
			IsPublic: true,
		},
		// 教练张强的帖子
		{
			UserID:  users[1].ID,
			Content: "📚【新手必看】健身房最常见的5个错误：\n\n1. 不热身就开始大重量训练\n2. 动作不标准，一味追求重量\n3. 忽视腿部训练\n4. 训练后不拉伸\n5. 饮食不控制\n\n避免这些错误，你的进步会更快！有问题随时问我~\n\n#健身教练 #新手指南",
			Type:    "text",
			Likes:   234,
			Comments: 56,
			Shares:  78,
			IsPublic: true,
		},
		{
			UserID:  users[1].ID,
			Content: "🎯 本周训练营招募！\n\n时间：周三、周五晚7-9点\n地点：朝阳区某健身房\n内容：增肌/减脂系统训练\n费用：体验课免费\n\n小班教学，每期限8人。想要改变自己的朋友们，欢迎报名！\n\n#健身训练营 #北京健身",
			Type:    "activity",
			Likes:   67,
			Comments: 28,
			Shares:  15,
			IsPublic: true,
		},
		// 瑜伽老师李美的帖子
		{
			UserID:  users[2].ID,
			Content: "🧘‍♀️ 早安，新的一天从瑜伽开始~\n\n今天练习了108遍拜日式，身心都得到了净化。瑜伽不仅是身体的练习，更是心灵的修行。\n\n推荐大家每天早上练习15分钟瑜伽，会有意想不到的收获哦💕\n\n#瑜伽生活 #晨练",
			Type:    "workout",
			Images:  "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800",
			Likes:   145,
			Comments: 32,
			Shares:  23,
			IsPublic: true,
		},
		{
			UserID:  users[2].ID,
			Content: "💆‍♀️【办公室久坐族必看】简单的肩颈放松动作：\n\n1. 头部左右侧屈，各保持30秒\n2. 肩部画圈，正反各10次\n3. 猫牛式拉伸，重复10次\n4. 坐姿扭转，左右各30秒\n\n每2小时做一次，告别肩颈酸痛！\n\n#久坐族 #肩颈放松",
			Type:    "text",
			Likes:   289,
			Comments: 67,
			Shares:  156,
			IsPublic: true,
		},
		// 跑步达人王磊的帖子
		{
			UserID:  users[3].ID,
			Content: "🏃 今晨10公里配速4'30\"，状态不错！\n\n最近在备战下个月的半马，目标是跑进1小时25分。训练计划已经进入最后阶段，每周总跑量70km。\n\n各位跑友们，一起加油！💪\n\n#跑步 #马拉松训练",
			Type:    "workout",
			Images:  "https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800",
			Likes:   112,
			Comments: 28,
			Shares:  15,
			IsPublic: true,
		},
		{
			UserID:  users[3].ID,
			Content: "🌅【周末约跑】\n\n本周六早上6点，奥森公园南门集合\n路线：10公里环湖跑\n配速：5'00\"-5'30\"（轻松跑）\n\n欢迎各位跑友加入！跑完一起吃早餐~\n\n#约跑 #北京跑团",
			Type:    "activity",
			Likes:   56,
			Comments: 34,
			Shares:  12,
			IsPublic: true,
		},
		// 减脂达人陈欣的帖子
		{
			UserID:  users[5].ID,
			Content: "📉【减脂25kg经验分享】\n\n从130斤到105斤，我用了10个月。最重要的经验：\n\n✅ 饮食控制大于运动\n✅ 不要节食，要科学减脂\n✅ 力量训练+有氧结合\n✅ 保证充足睡眠\n✅ 不要追求速度，稳定最重要\n\n现在的我更自信、更健康！大家一起加油💪\n\n#减脂经验 #瘦身成功",
			Type:    "lifestyle",
			Images:  "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800",
			Likes:   456,
			Comments: 123,
			Shares:  234,
			IsPublic: true,
		},
		// 健身新手刘洋的帖子
		{
			UserID:  users[4].ID,
			Content: "💪 健身第30天打卡！\n\n一个月前还是个完全不运动的宅男，现在已经爱上健身了！虽然还很菜，但是每次训练都能感受到进步。\n\n感谢各位大佬的指导和鼓励！继续加油！\n\n#健身新手 #坚持打卡",
			Type:    "workout",
			Likes:   78,
			Comments: 34,
			Shares:  5,
			IsPublic: true,
		},
		// 搏击教练赵刚的帖子
		{
			UserID:  users[6].ID,
			Content: "🥊 拳击训练不仅能锻炼身体，还能释放压力！\n\n今天带了一节拳击体验课，看到学员们挥汗如雨的样子，真的很有成就感。\n\n拳击能提升：\n- 心肺功能\n- 反应速度\n- 协调性\n- 自信心\n\n欢迎大家来体验！\n\n#拳击 #搏击训练",
			Type:    "workout",
			Images:  "https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?w=800",
			Likes:   98,
			Comments: 23,
			Shares:  16,
			IsPublic: true,
		},
		// 游泳教练孙丽的帖子
		{
			UserID:  users[7].ID,
			Content: "🏊‍♀️ 游泳是最好的全身性有氧运动！\n\n对关节冲击小，适合各个年龄段。今天教了一个学员蝶泳，看着她从完全不会到能游50米，真的很开心！\n\n游泳的好处：\n✅ 全身肌肉锻炼\n✅ 提升心肺功能\n✅ 塑造完美身材\n✅ 低关节冲击\n\n#游泳 #全身运动",
			Type:    "workout",
			Images:  "https://images.unsplash.com/photo-1530549387789-4c1017266635?w=800",
			Likes:   134,
			Comments: 28,
			Shares:  19,
			IsPublic: true,
		},
	}

	// 设置创建时间（最近2周内随机分布）
	for i := range posts {
		daysAgo := rand.Intn(14)
		posts[i].CreatedAt = time.Now().AddDate(0, 0, -daysAgo)
		posts[i].UpdatedAt = posts[i].CreatedAt
		db.Create(&posts[i])
	}

	return posts
}

// seedRichComments 创建评论
func seedRichComments(db *gorm.DB, users []models.User, posts []models.Post) []models.Comment {
	if len(users) == 0 || len(posts) == 0 {
		return []models.Comment{}
	}

	commentTexts := []string{
		"太实用了，感谢分享！👍",
		"学到了很多，继续加油💪",
		"这个方法我试过，确实有效！",
		"请问具体重量应该选择多少呢？",
		"棒棒哒！明天就去试试",
		"能加个微信请教一下吗？",
		"同感！坚持真的很重要",
		"看完又有动力了！",
		"大佬求带🙏",
		"点赞收藏了，慢慢学习",
		"这个训练计划太赞了！",
		"能不能详细讲讲饮食？",
		"一起加油！💪💪💪",
		"受益匪浅，感谢！",
		"已经分享给朋友了",
		"希望能看到更多这样的内容",
		"我也是这样练的，效果确实好",
		"新手求指导~",
		"太励志了！",
		"坚持就是胜利！",
	}

	comments := []models.Comment{}

	// 为每个帖子随机添加3-8条评论
	for _, post := range posts {
		commentCount := 3 + rand.Intn(6) // 3-8条评论
		for i := 0; i < commentCount; i++ {
			userIdx := rand.Intn(len(users))
			commentIdx := rand.Intn(len(commentTexts))

			comment := models.Comment{
				PostID:  post.ID,
				UserID:  users[userIdx].ID,
				Content: commentTexts[commentIdx],
			}
			comments = append(comments, comment)
		}
	}

	for i := range comments {
		db.Create(&comments[i])
	}

	return comments
}

// seedRichLikes 创建点赞
func seedRichLikes(db *gorm.DB, users []models.User, posts []models.Post) []models.PostLike {
	if len(users) == 0 || len(posts) == 0 {
		return []models.PostLike{}
	}

	likes := []models.PostLike{}

	// 每个用户为一些随机帖子点赞
	for _, user := range users {
		likeCount := 5 + rand.Intn(10) // 每人点赞5-15个帖子
		usedPosts := make(map[uint]bool)

		for i := 0; i < likeCount && i < len(posts); i++ {
			postIdx := rand.Intn(len(posts))
			// 避免重复点赞同一个帖子
			if usedPosts[posts[postIdx].ID] {
				continue
			}
			usedPosts[posts[postIdx].ID] = true

			like := models.PostLike{
				PostID: posts[postIdx].ID,
				UserID: user.ID,
			}
			likes = append(likes, like)
		}
	}

	for i := range likes {
		db.Create(&likes[i])
	}

	return likes
}

// seedRichMates 创建搭子关系
func seedRichMates(db *gorm.DB, users []models.User) []models.Mate {
	if len(users) < 2 {
		return []models.Mate{}
	}

	mates := []models.Mate{
		// 小王的搭子关系
		{
			UserID: users[0].ID, // 小王
			MateID: users[1].ID, // 张强
			Status: "accepted",
		},
		{
			UserID: users[0].ID, // 小王
			MateID: users[2].ID, // 李美
			Status: "accepted",
		},
		{
			UserID: users[0].ID, // 小王
			MateID: users[3].ID, // 王磊
			Status: "accepted",
		},
		// 其他用户之间的搭子关系
		{
			UserID: users[1].ID,
			MateID: users[4].ID,
			Status: "accepted",
		},
		{
			UserID: users[1].ID,
			MateID: users[5].ID,
			Status: "accepted",
		},
		{
			UserID: users[2].ID,
			MateID: users[5].ID,
			Status: "accepted",
		},
		{
			UserID: users[3].ID,
			MateID: users[4].ID,
			Status: "accepted",
		},
		// 一些待处理的搭子请求（小王收到的）
		{
			UserID: users[4].ID, // 刘洋
			MateID: users[0].ID, // 小王
			Status: "pending",
		},
		{
			UserID: users[6].ID, // 赵刚
			MateID: users[0].ID, // 小王
			Status: "pending",
		},
	}

	for i := range mates {
		db.Create(&mates[i])
	}

	return mates
}

// seedRichAchievements 创建成就
func seedRichAchievements(db *gorm.DB, users []models.User) []models.Achievement {
	if len(users) == 0 {
		return []models.Achievement{}
	}

	achievements := []models.Achievement{
		// 小王的成就
		{
			UserID:      users[0].ID,
			Title:       "深蹲大师",
			Description: "深蹲重量突破体重1.5倍",
			Icon:        "🏋️",
			Points:      100,
		},
		{
			UserID:      users[0].ID,
			Title:       "坚持不懈",
			Description: "连续训练180天不间断",
			Icon:        "🔥",
			Points:      200,
		},
		{
			UserID:      users[0].ID,
			Title:       "引体达人",
			Description: "负重引体向上15kg×12次",
			Icon:        "💪",
			Points:      100,
		},
		// 其他用户的成就
		{
			UserID:      users[1].ID,
			Title:       "金牌教练",
			Description: "成功指导100名学员达成目标",
			Icon:        "👨‍🏫",
			Points:      500,
		},
		{
			UserID:      users[3].ID,
			Title:       "马拉松完赛者",
			Description: "全马PB 3小时30分",
			Icon:        "🏃",
			Points:      200,
		},
		{
			UserID:      users[5].ID,
			Title:       "减脂达人",
			Description: "成功减重25kg",
			Icon:        "📉",
			Points:      200,
		},
	}

	for i := range achievements {
		unlockedAt := time.Now().AddDate(0, 0, -rand.Intn(60))
		achievements[i].UnlockedAt = unlockedAt
		db.Create(&achievements[i])
	}

	return achievements
}

// seedRichNotifications 创建通知
func seedRichNotifications(db *gorm.DB, users []models.User) []models.Notification {
	if len(users) < 2 {
		return []models.Notification{}
	}

	notifications := []models.Notification{
		// 小王的通知
		{
			UserID:  users[0].ID,
			Type:    "like",
			Title:   "新的点赞",
			Content: "张强 赞了你的帖子《深蹲技巧分享》",
			IsRead:  false,
		},
		{
			UserID:  users[0].ID,
			Type:    "comment",
			Title:   "新的评论",
			Content: "李美 评论了你的帖子：「这个教程太实用了！」",
			IsRead:  false,
		},
		{
			UserID:  users[0].ID,
			Type:    "follow",
			Title:   "新的搭子请求",
			Content: "刘洋 想成为你的健身搭子",
			IsRead:  false,
		},
		{
			UserID:  users[0].ID,
			Type:    "follow",
			Title:   "新的搭子请求",
			Content: "赵刚 想成为你的健身搭子",
			IsRead:  false,
		},
		{
			UserID:  users[0].ID,
			Type:    "system",
			Title:   "成就解锁",
			Content: "🎉 恭喜你解锁成就「坚持不懈」！",
			IsRead:  true,
		},
		{
			UserID:  users[0].ID,
			Type:    "like",
			Title:   "新的点赞",
			Content: "王磊 赞了你的帖子《今日训练打卡》",
			IsRead:  true,
		},
		{
			UserID:  users[0].ID,
			Type:    "comment",
			Title:   "新的评论",
			Content: "陈欣 评论了：「一起加油💪」",
			IsRead:  true,
		},
	}

	for i := range notifications {
		hoursAgo := i * 3
		notifications[i].CreatedAt = time.Now().Add(-time.Duration(hoursAgo) * time.Hour)
		notifications[i].UpdatedAt = notifications[i].CreatedAt
		db.Create(&notifications[i])
	}

	return notifications
}

// getNotes 获取训练笔记
func getNotes(day int) string {
	notes := []string{
		"今天状态爆棚！训练强度很大，但完成度很高。",
		"感觉有点累，但还是坚持完成了所有动作。",
		"新PR达成！重量又提升了！",
		"今天泵感特别好，肌肉充血感很强。",
		"训练很充实，每组都做到力竭。",
		"有点疲劳，下次要注意休息。",
		"动作越来越标准了，继续保持！",
	}
	return notes[day%len(notes)]
}

