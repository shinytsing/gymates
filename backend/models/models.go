package models

import (
	"gorm.io/gorm"
	"time"
)

// User 用户模型
type User struct {
	ID             uint           `json:"id" gorm:"primaryKey"`
	Name           string         `json:"name" gorm:"size:100;not null"`
	Email          string         `json:"email" gorm:"size:100;index"`     // 改为普通索引，允许空值重复
	Phone          string         `json:"phone" gorm:"size:20;index"`      // 改为普通索引，允许空值重复
	Password       string         `json:"-" gorm:"size:255"`
	Avatar         string         `json:"avatar" gorm:"size:255"`
	Bio            string         `json:"bio" gorm:"type:text"`
	Location       string         `json:"location" gorm:"size:100"`
	Latitude       float64        `json:"latitude"`
	Longitude      float64        `json:"longitude"`
	Age            int            `json:"age"`
	Gender         string         `json:"gender" gorm:"size:20"`
	Height         float64        `json:"height"`
	Weight         float64        `json:"weight"`
	Goal           string         `json:"goal" gorm:"size:50"`
	Experience     string         `json:"experience" gorm:"size:50"`
	PreferredTime  string         `json:"preferred_time" gorm:"size:100"`            // 偏好训练时间
	TrainingTypes  string         `json:"training_types" gorm:"size:255"`            // 训练类型偏好，逗号分隔
	LookingForMate bool           `json:"looking_for_mate" gorm:"default:false"`     // 是否寻找搭子
	LoginType      string         `json:"login_type" gorm:"size:20;default:'email'"` // 登录类型: email, phone, apple, google, wechat
	AppleID        string         `json:"apple_id" gorm:"size:255;index"`            // Apple登录ID (改为普通索引，允许NULL重复)
	GoogleID       string         `json:"google_id" gorm:"size:255;index"`           // Google登录ID (改为普通索引，允许NULL重复)
	WechatID       string         `json:"wechat_id" gorm:"size:255;index"`           // 微信登录ID (改为普通索引，允许NULL重复)
	IsGuest        bool           `json:"is_guest" gorm:"default:false"`             // 是否游客
	LastLoginAt    *time.Time     `json:"last_login_at"`                             // 最后登录时间
	CreatedAt      time.Time      `json:"created_at"`
	UpdatedAt      time.Time      `json:"updated_at"`
	DeletedAt      gorm.DeletedAt `json:"-" gorm:"index"`
}

// TrainingPlan 训练计划模型
type TrainingPlan struct {
	ID             uint           `json:"id" gorm:"primaryKey"`
	UserID         uint           `json:"user_id" gorm:"not null"`
	User           User           `json:"user" gorm:"foreignKey:UserID"`
	Name           string         `json:"name" gorm:"size:100;not null"`
	Description    string         `json:"description" gorm:"type:text"`
	Exercises      []Exercise     `json:"exercises" gorm:"foreignKey:TrainingPlanID"`
	Duration       int            `json:"duration" gorm:"not null"`
	CaloriesBurned int            `json:"calories_burned" gorm:"not null"`
	Difficulty     string         `json:"difficulty" gorm:"size:20;default:'beginner'"`
	IsPublic       bool           `json:"is_public" gorm:"default:false"`
	CreatedAt      time.Time      `json:"created_at"`
	UpdatedAt      time.Time      `json:"updated_at"`
	DeletedAt      gorm.DeletedAt `json:"-" gorm:"index"`
}

// Exercise 训练动作模型
type Exercise struct {
	ID             uint           `json:"id" gorm:"primaryKey"`
	TrainingPlanID uint           `json:"training_plan_id" gorm:"not null"`
	TrainingPlan   TrainingPlan   `json:"training_plan" gorm:"foreignKey:TrainingPlanID"`
	TrainingPartID *uint          `json:"training_part_id"` // 新增：关联到训练部位
	TrainingPart   *TrainingPart  `json:"training_part" gorm:"foreignKey:TrainingPartID"`
	Name           string         `json:"name" gorm:"size:100;not null"`
	Description    string         `json:"description" gorm:"type:text"`
	MuscleGroup    string         `json:"muscle_group" gorm:"size:50"`
	Difficulty     string         `json:"difficulty" gorm:"size:20;default:'intermediate'"`
	Equipment      string         `json:"equipment" gorm:"size:50"`
	Sets           int            `json:"sets" gorm:"not null"`
	Reps           int            `json:"reps" gorm:"not null"`
	Weight         float64        `json:"weight"`
	Duration       int            `json:"duration"`
	RestTime       int            `json:"rest_time"`
	RestSeconds    int            `json:"rest_seconds"` // 新增：休息时间（秒）
	Instructions   string         `json:"instructions" gorm:"type:text"`
	ImageURL       string         `json:"image_url" gorm:"size:255"`
	VideoURL       string         `json:"video_url" gorm:"size:255"`
	Calories       int            `json:"calories" gorm:"default:50"`
	Notes          string         `json:"notes" gorm:"type:text"`
	IsCompleted    bool           `json:"is_completed" gorm:"default:false"`
	CompletedAt    *time.Time     `json:"completed_at"`
	Order          int            `json:"order" gorm:"not null"`
	CreatedAt      time.Time      `json:"created_at"`
	UpdatedAt      time.Time      `json:"updated_at"`
	DeletedAt      gorm.DeletedAt `json:"-" gorm:"index"`
}

// Conversation 对话模型
type Conversation struct {
	ID               uint       `json:"id" gorm:"primaryKey"`
	User1ID          uint       `json:"user1_id" gorm:"not null"`
	User2ID          uint       `json:"user2_id" gorm:"not null"`
	LastMessageID    *uint      `json:"last_message_id"`
	LastMessageAt    *time.Time `json:"last_message_at"`
	UnreadCount1     int        `json:"unread_count_1" gorm:"default:0"`  // User1未读数
	UnreadCount2     int        `json:"unread_count_2" gorm:"default:0"`  // User2未读数
	CreatedAt        time.Time  `json:"created_at"`
	UpdatedAt        time.Time  `json:"updated_at"`
}

// MateRequest 好友请求模型
type MateRequest struct {
	ID         uint           `json:"id" gorm:"primaryKey"`
	SenderID   uint           `json:"sender_id" gorm:"not null"`
	ReceiverID uint           `json:"receiver_id" gorm:"not null"`
	Status     string         `json:"status" gorm:"size:20;default:'pending'"` // pending, accepted, rejected
	Message    string         `json:"message" gorm:"type:text"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`
}

// UserProfile 用户资料扩展
type UserProfile struct {
	UserID            uint      `json:"user_id" gorm:"primaryKey"`
	FitnessLevel      string    `json:"fitness_level"`
	TrainingFrequency int       `json:"training_frequency"`
	Injuries          string    `json:"injuries" gorm:"type:text"`
	Medications       string    `json:"medications" gorm:"type:text"`
	DietaryType       string    `json:"dietary_type"`
	Allergies         string    `json:"allergies" gorm:"type:text"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`
}

// ExerciseGuidance AI动作指导
type ExerciseGuidance struct {
	ExerciseID     uint     `json:"exercise_id"`
	ExerciseName   string   `json:"exercise_name"`
	Description    string   `json:"description"`
	Instructions   []string `json:"instructions"`
	CommonMistakes []string `json:"common_mistakes"`
	SafetyTips     []string `json:"safety_tips"`
	VideoURL       string   `json:"video_url"`
}

// FormAnalysis 动作分析结果
type FormAnalysis struct {
	VideoURL       string   `json:"video_url"`
	OverallScore   float64  `json:"overall_score"`
	Feedback       string   `json:"feedback"`
	Corrections    []string `json:"corrections"`
	GoodPoints     []string `json:"good_points"`
	InjuryRisks    []string `json:"injury_risks"`
}

// NutritionAdvice 营养建议
type NutritionAdvice struct {
	DailyCalories      int               `json:"daily_calories"`
	Protein            int               `json:"protein"`
	Carbs              int               `json:"carbs"`
	Fat                int               `json:"fat"`
	MealPlan           []Meal            `json:"meal_plan"`
	Supplements        []string          `json:"supplements"`
	HydrationGoal      float64           `json:"hydration_goal"`
	Recommendations    string            `json:"recommendations"`
}

// Meal 餐食
type Meal struct {
	Name        string   `json:"name"`
	Time        string   `json:"time"`
	Calories    int      `json:"calories"`
	Description string   `json:"description"`
	Foods       []string `json:"foods"`
}

// WorkoutSession 训练会话模型
type WorkoutSession struct {
	ID             uint           `json:"id" gorm:"primaryKey"`
	UserID         uint           `json:"user_id" gorm:"not null"`
	User           User           `json:"user" gorm:"foreignKey:UserID"`
	TrainingPlanID uint           `json:"training_plan_id" gorm:"not null"`
	TrainingPlan   TrainingPlan   `json:"training_plan" gorm:"foreignKey:TrainingPlanID"`
	StartTime      time.Time      `json:"start_time" gorm:"not null"`
	EndTime        *time.Time     `json:"end_time"`
	Status         string         `json:"status" gorm:"size:20;default:'ongoing'"`
	Progress       int            `json:"progress" gorm:"default:0"`
	TotalCalories  int            `json:"total_calories" gorm:"default:0"`
	Notes          string         `json:"notes" gorm:"type:text"`
	CreatedAt      time.Time      `json:"created_at"`
	UpdatedAt      time.Time      `json:"updated_at"`
	DeletedAt      gorm.DeletedAt `json:"-" gorm:"index"`
}

// Post 社区帖子模型
type Post struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	UserID    uint           `json:"user_id" gorm:"not null"`
	User      User           `json:"user" gorm:"foreignKey:UserID"`
	Content   string         `json:"content" gorm:"type:text;not null"`
	Images    string         `json:"images" gorm:"type:text"`
	Type      string         `json:"type" gorm:"size:20;default:'text'"`
	Likes     int            `json:"likes" gorm:"default:0"`
	Comments  int            `json:"comments" gorm:"default:0"`
	Shares    int            `json:"shares" gorm:"default:0"`
	IsPublic  bool           `json:"is_public" gorm:"default:true"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

// Comment 评论模型
type Comment struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	PostID    uint           `json:"post_id" gorm:"not null"`
	Post      Post           `json:"post" gorm:"foreignKey:PostID"`
	UserID    uint           `json:"user_id" gorm:"not null"`
	User      User           `json:"user" gorm:"foreignKey:UserID"`
	Content   string         `json:"content" gorm:"type:text;not null"`
	Likes     int            `json:"likes" gorm:"default:0"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

// PostLike 帖子点赞模型
type PostLike struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	PostID    uint           `json:"post_id" gorm:"not null"`
	Post      Post           `json:"post" gorm:"foreignKey:PostID"`
	UserID    uint           `json:"user_id" gorm:"not null"`
	User      User           `json:"user" gorm:"foreignKey:UserID"`
	CreatedAt time.Time      `json:"created_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

// Mate 搭子关系模型
type Mate struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	UserID    uint           `json:"user_id" gorm:"not null"`
	User      User           `json:"user" gorm:"foreignKey:UserID"`
	MateID    uint           `json:"mate_id" gorm:"not null"`
	Mate      User           `json:"mate" gorm:"foreignKey:MateID"`
	Status    string         `json:"status" gorm:"size:20;default:'pending'"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

// Chat 聊天模型
type Chat struct {
	ID           uint           `json:"id" gorm:"primaryKey"`
	Participants []User         `json:"participants" gorm:"many2many:chat_participants"`
	LastMessage  *Message       `json:"last_message"`
	UnreadCount  int            `json:"unread_count" gorm:"default:0"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `json:"-" gorm:"index"`
}

// Message 消息模型
type Message struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	ChatID    uint           `json:"chat_id" gorm:"not null"`
	Chat      Chat           `json:"chat" gorm:"foreignKey:ChatID"`
	SenderID  uint           `json:"sender_id" gorm:"not null"`
	Sender    User           `json:"sender" gorm:"foreignKey:SenderID"`
	Content   string         `json:"content" gorm:"type:text;not null"`
	Type      string         `json:"type" gorm:"size:20;default:'text'"`
	IsRead    bool           `json:"is_read" gorm:"default:false"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

// ChatParticipant 聊天参与者模型
type ChatParticipant struct {
	ChatID uint `json:"chat_id" gorm:"primaryKey"`
	UserID uint `json:"user_id" gorm:"primaryKey"`
	Chat   Chat `json:"chat" gorm:"foreignKey:ChatID"`
	User   User `json:"user" gorm:"foreignKey:UserID"`
}

// Achievement 成就模型
type Achievement struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	UserID      uint           `json:"user_id" gorm:"not null"`
	User        User           `json:"user" gorm:"foreignKey:UserID"`
	Title       string         `json:"title" gorm:"size:100;not null"`
	Description string         `json:"description" gorm:"type:text"`
	Icon        string         `json:"icon" gorm:"size:255"`
	Points      int            `json:"points" gorm:"default:0"`
	UnlockedAt  time.Time      `json:"unlocked_at"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

// Notification 通知模型
type Notification struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	UserID    uint           `json:"user_id" gorm:"not null"`
	User      User           `json:"user" gorm:"foreignKey:UserID"`
	Title     string         `json:"title" gorm:"size:100;not null"`
	Content   string         `json:"content" gorm:"type:text"`
	Type      string         `json:"type" gorm:"size:50;not null"`
	IsRead    bool           `json:"is_read" gorm:"default:false"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

// VerificationCode 验证码模型
type VerificationCode struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	Phone     string         `json:"phone" gorm:"size:20;not null;index"`
	Code      string         `json:"code" gorm:"size:6;not null"`
	Type      string         `json:"type" gorm:"size:20;not null"` // login, register, reset_password
	ExpiresAt time.Time      `json:"expires_at" gorm:"not null"`
	IsUsed    bool           `json:"is_used" gorm:"default:false"`
	UsedAt    *time.Time     `json:"used_at"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

// RefreshToken 刷新令牌模型
type RefreshToken struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	UserID    uint           `json:"user_id" gorm:"not null;index"`
	User      User           `json:"user" gorm:"foreignKey:UserID"`
	Token     string         `json:"token" gorm:"size:500;not null;uniqueIndex"`
	ExpiresAt time.Time      `json:"expires_at" gorm:"not null"`
	IsRevoked bool           `json:"is_revoked" gorm:"default:false"`
	RevokedAt *time.Time     `json:"revoked_at"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}
