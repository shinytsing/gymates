package models

import (
	"time"
	"gorm.io/gorm"
)

// User 用户模型
type User struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	Name      string         `json:"name" gorm:"size:100;not null"`
	Email     string         `json:"email" gorm:"size:100;uniqueIndex;not null"`
	Password  string         `json:"-" gorm:"size:255;not null"`
	Avatar    string         `json:"avatar" gorm:"size:255"`
	Bio       string         `json:"bio" gorm:"type:text"`
	Location  string         `json:"location" gorm:"size:100"`
	Age       int            `json:"age"`
	Height    float64        `json:"height"`
	Weight    float64        `json:"weight"`
	Goal      string         `json:"goal" gorm:"size:50"`
	Experience string        `json:"experience" gorm:"size:50"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

// TrainingPlan 训练计划模型
type TrainingPlan struct {
	ID            uint           `json:"id" gorm:"primaryKey"`
	UserID        uint           `json:"user_id" gorm:"not null"`
	User          User           `json:"user" gorm:"foreignKey:UserID"`
	Name          string         `json:"name" gorm:"size:100;not null"`
	Description   string         `json:"description" gorm:"type:text"`
	Exercises     []Exercise     `json:"exercises" gorm:"foreignKey:TrainingPlanID"`
	Duration      int            `json:"duration" gorm:"not null"`
	CaloriesBurned int           `json:"calories_burned" gorm:"not null"`
	Difficulty    string         `json:"difficulty" gorm:"size:20;default:'beginner'"`
	IsPublic      bool           `json:"is_public" gorm:"default:false"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `json:"-" gorm:"index"`
}

// Exercise 训练动作模型
type Exercise struct {
	ID              uint           `json:"id" gorm:"primaryKey"`
	TrainingPlanID  uint           `json:"training_plan_id" gorm:"not null"`
	TrainingPlan    TrainingPlan   `json:"training_plan" gorm:"foreignKey:TrainingPlanID"`
	Name            string         `json:"name" gorm:"size:100;not null"`
	Sets            int            `json:"sets" gorm:"not null"`
	Reps            int            `json:"reps" gorm:"not null"`
	Weight          float64        `json:"weight"`
	Duration        int            `json:"duration"`
	RestTime        int            `json:"rest_time"`
	Instructions    string         `json:"instructions" gorm:"type:text"`
	ImageURL        string         `json:"image_url" gorm:"size:255"`
	Order           int            `json:"order" gorm:"not null"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `json:"-" gorm:"index"`
}

// WorkoutSession 训练会话模型
type WorkoutSession struct {
	ID            uint           `json:"id" gorm:"primaryKey"`
	UserID        uint           `json:"user_id" gorm:"not null"`
	User          User           `json:"user" gorm:"foreignKey:UserID"`
	TrainingPlanID uint          `json:"training_plan_id" gorm:"not null"`
	TrainingPlan  TrainingPlan   `json:"training_plan" gorm:"foreignKey:TrainingPlanID"`
	StartTime     time.Time      `json:"start_time" gorm:"not null"`
	EndTime       *time.Time     `json:"end_time"`
	Status        string         `json:"status" gorm:"size:20;default:'ongoing'"`
	Progress      int            `json:"progress" gorm:"default:0"`
	TotalCalories int            `json:"total_calories" gorm:"default:0"`
	Notes         string         `json:"notes" gorm:"type:text"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `json:"-" gorm:"index"`
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
