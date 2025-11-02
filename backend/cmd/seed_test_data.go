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
	// 初始化数据库
	err := config.InitDB()
	if err != nil {
		log.Fatalf("❌ 数据库初始化失败: %v", err)
	}
	
	db := config.DB
	
	// 自动迁移
	err = db.AutoMigrate(
		&models.User{},
		&models.TrainingPlan{},
		&models.Exercise{},
		&models.WorkoutSession{},
		&models.Post{},
		&models.Comment{},
		&models.PostLike{},
		&models.Mate{},
		&models.Achievement{},
		&models.Notification{},
	)
	if err != nil {
		log.Fatalf("❌ 数据库迁移失败: %v", err)
	}

	fmt.Println("🚀 开始注入测试数据...")
	
	// 1. 创建用户
	users := seedUsers(db)
	fmt.Printf("✅ 创建了 %d 个用户\n", len(users))
	
	// 2. 创建训练计划
	trainingPlans := seedTrainingPlans(db, users)
	fmt.Printf("✅ 创建了 %d 个训练计划\n", len(trainingPlans))
	
	// 3. 创建社区帖子
	posts := seedPosts(db, users)
	fmt.Printf("✅ 创建了 %d 个社区帖子\n", len(posts))
	
	// 4. 创建评论
	comments := seedComments(db, users, posts)
	fmt.Printf("✅ 创建了 %d 条评论\n", len(comments))
	
	// 5. 创建点赞
	likes := seedLikes(db, users, posts)
	fmt.Printf("✅ 创建了 %d 个点赞\n", len(likes))
	
	// 6. 创建搭子关系
	mates := seedMates(db, users)
	fmt.Printf("✅ 创建了 %d 个搭子关系\n", len(mates))
	
	// 7. 创建成就
	achievements := seedAchievements(db, users)
	fmt.Printf("✅ 创建了 %d 个成就\n", len(achievements))
	
	// 8. 创建训练会话
	sessions := seedWorkoutSessions(db, users, trainingPlans)
	fmt.Printf("✅ 创建了 %d 个训练会话\n", len(sessions))
	
	// 9. 创建通知
	notifications := seedNotifications(db, users)
	fmt.Printf("✅ 创建了 %d 条通知\n", len(notifications))
	
	fmt.Println("🎉 所有测试数据注入完成！")
}

// seedUsers 创建测试用户
func seedUsers(db *gorm.DB) []models.User {
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	
	users := []models.User{
		{
			Name:          "陈雨晨",
			Email:         "chenyuchen@gymates.com",
			Phone:         "13800138001",
			Password:      string(hashedPassword),
			Avatar:        "https://images.unsplash.com/photo-1541338784564-51087dabc0de?w=400",
			Bio:           "热爱运动的设计师，希望找到一起坚持健身的伙伴！每周至少4次训练，追求健康生活方式。",
			Location:      "北京市朝阳区",
			Latitude:      39.9042,
			Longitude:     116.4074,
			Age:           25,
			Gender:        "female",
			Height:        165.0,
			Weight:        55.0,
			Goal:          "减脂塑形",
			Experience:    "中级",
			PreferredTime: "晚上 7-9点",
			TrainingTypes: "力量训练,瑜伽,跑步",
			LookingForMate: true,
			LoginType:     "email",
		},
		{
			Name:          "张健康",
			Email:         "zhangjiankang@gymates.com",
			Phone:         "13800138002",
			Password:      string(hashedPassword),
			Avatar:        "https://images.unsplash.com/photo-1607286908165-b8b6a2874fc4?w=400",
			Bio:           "健身教练，专注力量训练5年+。喜欢挑战自己，也乐于帮助健身新手。",
			Location:      "上海市浦东新区",
			Latitude:      31.2304,
			Longitude:     121.4737,
			Age:           28,
			Gender:        "male",
			Height:        178.0,
			Weight:        75.0,
			Goal:          "增肌",
			Experience:    "高级",
			PreferredTime: "早上 6-8点",
			TrainingTypes: "力量训练,CrossFit,游泳",
			LookingForMate: true,
			LoginType:     "email",
		},
		{
			Name:          "李明",
			Email:         "liming@gymates.com",
			Phone:         "13800138003",
			Password:      string(hashedPassword),
			Avatar:        "https://images.unsplash.com/photo-1566753323558-f4e0952af115?w=400",
			Bio:           "跑步爱好者，马拉松完赛者。喜欢户外运动，每周跑步50公里+。",
			Location:      "广州市天河区",
			Latitude:      23.1291,
			Longitude:     113.2644,
			Age:           30,
			Gender:        "male",
			Height:        175.0,
			Weight:        68.0,
			Goal:          "提升耐力",
			Experience:    "高级",
			PreferredTime: "早上 5-7点",
			TrainingTypes: "跑步,游泳,骑行",
			LookingForMate: true,
			LoginType:     "email",
		},
		{
			Name:          "王小美",
			Email:         "wangxiaomei@gymates.com",
			Phone:         "13800138004",
			Password:      string(hashedPassword),
			Avatar:        "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400",
			Bio:           "瑜伽教练，专注身心健康。教授哈他瑜伽和阴瑜伽，欢迎交流。",
			Location:      "深圳市南山区",
			Latitude:      22.5431,
			Longitude:     114.0579,
			Age:           26,
			Gender:        "female",
			Height:        162.0,
			Weight:        50.0,
			Goal:          "塑形",
			Experience:    "中级",
			PreferredTime: "早上 8-10点",
			TrainingTypes: "瑜伽,普拉提,冥想",
			LookingForMate: true,
			LoginType:     "email",
		},
		{
			Name:          "赵强",
			Email:         "zhaoqiang@gymates.com",
			Phone:         "13800138005",
			Password:      string(hashedPassword),
			Avatar:        "https://images.unsplash.com/photo-1583468982228-19f19164aee2?w=400",
			Bio:           "CrossFit爱好者，力量举三项选手。追求极限，突破自我。",
			Location:      "杭州市西湖区",
			Latitude:      30.2741,
			Longitude:     120.1551,
			Age:           32,
			Gender:        "male",
			Height:        180.0,
			Weight:        85.0,
			Goal:          "增肌增力",
			Experience:    "高级",
			PreferredTime: "晚上 6-8点",
			TrainingTypes: "力量训练,CrossFit,举重",
			LookingForMate: false,
			LoginType:     "email",
		},
	}
	
	for i := range users {
		db.Create(&users[i])
	}
	
	return users
}

// seedTrainingPlans 创建训练计划
func seedTrainingPlans(db *gorm.DB, users []models.User) []models.TrainingPlan {
	plans := []models.TrainingPlan{
		{
			UserID:         users[0].ID,
			Name:           "全身力量训练计划",
			Description:    "适合中级训练者的全身力量训练计划，每周3-4次，每次45-60分钟",
			Duration:       60,
			CaloriesBurned: 400,
			Difficulty:     "intermediate",
			IsPublic:       true,
		},
		{
			UserID:         users[1].ID,
			Name:           "增肌五分化训练",
			Description:    "专业增肌训练计划，分别训练胸、背、肩、腿、手臂，每周5-6次训练",
			Duration:       75,
			CaloriesBurned: 500,
			Difficulty:     "advanced",
			IsPublic:       true,
		},
		{
			UserID:         users[2].ID,
			Name:           "马拉松备战计划",
			Description:    "12周马拉松训练计划，循序渐进提升耐力和速度",
			Duration:       90,
			CaloriesBurned: 600,
			Difficulty:     "advanced",
			IsPublic:       true,
		},
		{
			UserID:         users[3].ID,
			Name:           "瑜伽塑形课程",
			Description:    "结合哈他瑜伽和阴瑜伽的塑形课程，适合初中级学员",
			Duration:       45,
			CaloriesBurned: 200,
			Difficulty:     "beginner",
			IsPublic:       true,
		},
		{
			UserID:         users[0].ID,
			Name:           "HIIT燃脂训练",
			Description:    "高强度间歇训练，快速燃烧脂肪，提升心肺功能",
			Duration:       30,
			CaloriesBurned: 350,
			Difficulty:     "intermediate",
			IsPublic:       true,
		},
	}
	
	// 为每个计划添加动作
	exercises := []struct {
		Name        string
		MuscleGroup string
		Sets        int
		Reps        int
		RestTime    int
		Calories    int
	}{
		{"卧推", "胸部", 4, 10, 90, 60},
		{"深蹲", "腿部", 4, 12, 120, 80},
		{"硬拉", "背部", 4, 8, 120, 70},
		{"肩上推举", "肩部", 3, 12, 60, 50},
		{"引体向上", "背部", 3, 8, 90, 60},
		{"哑铃卧推", "胸部", 3, 12, 60, 50},
		{"腿举", "腿部", 4, 15, 90, 70},
		{"杠铃弯举", "手臂", 3, 12, 60, 40},
	}
	
	for i := range plans {
		db.Create(&plans[i])
		
		// 为每个计划添加3-5个动作
		numExercises := rand.Intn(3) + 3
		for j := 0; j < numExercises; j++ {
			ex := exercises[rand.Intn(len(exercises))]
			exercise := models.Exercise{
				TrainingPlanID: plans[i].ID,
				Name:           ex.Name,
				MuscleGroup:    ex.MuscleGroup,
				Sets:           ex.Sets,
				Reps:           ex.Reps,
				RestTime:       ex.RestTime,
				Calories:       ex.Calories,
				Difficulty:     plans[i].Difficulty,
				Equipment:      "哑铃",
				Order:          j + 1,
			}
			db.Create(&exercise)
		}
	}
	
	return plans
}

// seedPosts 创建社区帖子
func seedPosts(db *gorm.DB, users []models.User) []models.Post {
	posts := []models.Post{
		{
			UserID:  users[0].ID,
			Content: "今天完成了胸部训练！卧推突破80kg，感觉状态越来越好了💪 坚持就是胜利，兄弟们加油！",
			Images:  "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800",
			Type:    "image",
			Likes:   328,
			Comments: 45,
			Shares:  12,
			IsPublic: true,
		},
		{
			UserID:  users[3].ID,
			Content: "清晨瑜伽，开启美好的一天🧘‍♀️ 早起的鸟儿有虫吃，早起的人儿心情好~",
			Images:  "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800,https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800",
			Type:    "image",
			Likes:   892,
			Comments: 123,
			Shares:  45,
			IsPublic: true,
		},
		{
			UserID:  users[2].ID,
			Content: "10公里晨跑打卡✅ 配速5分钟/公里，感觉越跑越爽！#坚持跑步100天",
			Images:  "https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=800",
			Type:    "image",
			Likes:   567,
			Comments: 89,
			Shares:  34,
			IsPublic: true,
		},
		{
			UserID:  users[1].ID,
			Content: "今天教大家一个背部拉伸动作，办公室久坐必备！跟着视频一起做，缓解肩颈疲劳~",
			Images:  "",
			Type:    "text",
			Likes:   1234,
			Comments: 278,
			Shares:  89,
			IsPublic: true,
		},
		{
			UserID:  users[4].ID,
			Content: "深蹲日来了！5组×8个，重量120kg。腿部训练虽然痛苦，但练完那种感觉太爽了！💪",
			Images:  "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800",
			Type:    "image",
			Likes:   445,
			Comments: 67,
			Shares:  23,
			IsPublic: true,
		},
		{
			UserID:  users[0].ID,
			Content: "分享一下我的减脂餐：鸡胸肉+西兰花+糙米饭，简单健康又美味！",
			Images:  "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800",
			Type:    "image",
			Likes:   756,
			Comments: 134,
			Shares:  56,
			IsPublic: true,
		},
		{
			UserID:  users[3].ID,
			Content: "今天的瑜伽课超级棒！感谢大家的支持和信任，让我们一起变得更好~",
			Images:  "",
			Type:    "text",
			Likes:   523,
			Comments: 98,
			Shares:  34,
			IsPublic: true,
		},
		{
			UserID:  users[2].ID,
			Content: "参加了第一次半马比赛，成绩1小时45分！虽然不是很快，但完赛就是胜利！",
			Images:  "https://images.unsplash.com/photo-1452626212852-811d58933cae?w=800",
			Type:    "image",
			Likes:   987,
			Comments: 156,
			Shares:  78,
			IsPublic: true,
		},
	}
	
	for i := range posts {
		// 随机设置创建时间（最近7天内）
		posts[i].CreatedAt = time.Now().Add(-time.Duration(rand.Intn(168)) * time.Hour)
		db.Create(&posts[i])
	}
	
	return posts
}

// seedComments 创建评论
func seedComments(db *gorm.DB, users []models.User, posts []models.Post) []models.Comment {
	commentTexts := []string{
		"太棒了！我也在坚持训练，一起加油！",
		"动作很标准，学习了！",
		"请问用的什么训练计划呀？",
		"好厉害！目标就是你！",
		"这个动作我也在练，效果确实不错",
		"有空一起练呀！",
		"求详细训练计划",
		"坚持就是胜利！加油！",
		"太励志了，给我很大动力",
		"可以分享一下饮食吗？",
	}
	
	var comments []models.Comment
	
	for _, post := range posts {
		// 每个帖子添加2-5条评论
		numComments := rand.Intn(4) + 2
		for i := 0; i < numComments; i++ {
			comment := models.Comment{
				PostID:  post.ID,
				UserID:  users[rand.Intn(len(users))].ID,
				Content: commentTexts[rand.Intn(len(commentTexts))],
				Likes:   rand.Intn(50),
			}
			db.Create(&comment)
			comments = append(comments, comment)
		}
	}
	
	return comments
}

// seedLikes 创建点赞
func seedLikes(db *gorm.DB, users []models.User, posts []models.Post) []models.PostLike {
	var likes []models.PostLike
	
	for _, post := range posts {
		// 每个帖子随机获得一些点赞
		numLikes := rand.Intn(len(users)) + 1
		usedUsers := make(map[uint]bool)
		
		for i := 0; i < numLikes; i++ {
			userID := users[rand.Intn(len(users))].ID
			if !usedUsers[userID] {
				like := models.PostLike{
					PostID: post.ID,
					UserID: userID,
				}
				db.Create(&like)
				likes = append(likes, like)
				usedUsers[userID] = true
			}
		}
	}
	
	return likes
}

// seedMates 创建搭子关系
func seedMates(db *gorm.DB, users []models.User) []models.Mate {
	var mates []models.Mate
	
	// 创建一些已接受的搭子关系
	mateRelations := []struct {
		UserIndex int
		MateIndex int
		Status    string
	}{
		{0, 1, "accepted"},
		{0, 3, "accepted"},
		{1, 2, "accepted"},
		{2, 3, "accepted"},
		{1, 4, "pending"},
		{3, 4, "pending"},
	}
	
	for _, relation := range mateRelations {
		mate := models.Mate{
			UserID: users[relation.UserIndex].ID,
			MateID: users[relation.MateIndex].ID,
			Status: relation.Status,
		}
		db.Create(&mate)
		mates = append(mates, mate)
	}
	
	return mates
}

// seedAchievements 创建成就
func seedAchievements(db *gorm.DB, users []models.User) []models.Achievement {
	achievementData := []struct {
		Title       string
		Description string
		Icon        string
		Points      int
	}{
		{"健身新手", "完成第一次训练", "🎯", 100},
		{"坚持一周", "连续训练7天", "💪", 200},
		{"力量之星", "卧推达到体重1倍", "🏋️", 300},
		{"跑步达人", "累计跑步100公里", "🏃", 250},
		{"瑜伽大师", "完成100节瑜伽课", "🧘", 300},
		{"社交达人", "发布10条动态", "📱", 150},
		{"早起鸟儿", "连续早起训练30天", "🌅", 250},
		{"健身月度之星", "月度训练20次", "⭐", 400},
	}
	
	var achievements []models.Achievement
	
	for _, user := range users {
		// 每个用户随机获得2-4个成就
		numAchievements := rand.Intn(3) + 2
		usedAchievements := make(map[int]bool)
		
		for i := 0; i < numAchievements; i++ {
			idx := rand.Intn(len(achievementData))
			if !usedAchievements[idx] {
				data := achievementData[idx]
				achievement := models.Achievement{
					UserID:      user.ID,
					Title:       data.Title,
					Description: data.Description,
					Icon:        data.Icon,
					Points:      data.Points,
					UnlockedAt:  time.Now().Add(-time.Duration(rand.Intn(720)) * time.Hour),
				}
				db.Create(&achievement)
				achievements = append(achievements, achievement)
				usedAchievements[idx] = true
			}
		}
	}
	
	return achievements
}

// seedWorkoutSessions 创建训练会话
func seedWorkoutSessions(db *gorm.DB, users []models.User, plans []models.TrainingPlan) []models.WorkoutSession {
	var sessions []models.WorkoutSession
	
	for _, user := range users {
		// 每个用户创建2-5个训练会话
		numSessions := rand.Intn(4) + 2
		
		for i := 0; i < numSessions; i++ {
			plan := plans[rand.Intn(len(plans))]
			startTime := time.Now().Add(-time.Duration(rand.Intn(720)) * time.Hour)
			endTime := startTime.Add(time.Duration(plan.Duration) * time.Minute)
			
			session := models.WorkoutSession{
				UserID:         user.ID,
				TrainingPlanID: plan.ID,
				StartTime:      startTime,
				EndTime:        &endTime,
				Status:         "completed",
				Progress:       100,
				TotalCalories:  plan.CaloriesBurned,
				Notes:          "训练完成，感觉不错！",
			}
			db.Create(&session)
			sessions = append(sessions, session)
		}
	}
	
	return sessions
}

// seedNotifications 创建通知
func seedNotifications(db *gorm.DB, users []models.User) []models.Notification {
	notificationData := []struct {
		Title   string
		Content string
		Type    string
	}{
		{"新的搭子请求", "张健康想成为你的健身搭子", "mate_request"},
		{"训练提醒", "今天还没有完成训练哦，加油！", "training_reminder"},
		{"点赞通知", "李明点赞了你的动态", "like"},
		{"评论通知", "王小美评论了你的帖子", "comment"},
		{"成就解锁", "恭喜你解锁新成就：坚持一周", "achievement"},
		{"系统消息", "新版本上线，快来体验新功能！", "system"},
	}
	
	var notifications []models.Notification
	
	for _, user := range users {
		// 每个用户创建3-6条通知
		numNotifications := rand.Intn(4) + 3
		
		for i := 0; i < numNotifications; i++ {
			data := notificationData[rand.Intn(len(notificationData))]
			notification := models.Notification{
				UserID:  user.ID,
				Title:   data.Title,
				Content: data.Content,
				Type:    data.Type,
				IsRead:  rand.Intn(2) == 0, // 随机已读/未读
			}
			db.Create(&notification)
			notifications = append(notifications, notification)
		}
	}
	
	return notifications
}

