package models

import (
	"time"
	"gorm.io/gorm"
)

// UserTrainingPreferences 用户训练偏好
type UserTrainingPreferences struct {
	ID             uint           `json:"id" gorm:"primaryKey"`
	UserID         uint           `json:"user_id" gorm:"not null"`
	User           User           `json:"user" gorm:"foreignKey:UserID"`
	Goal           string         `json:"goal" gorm:"size:20"` // 增肌/减脂/维持
	Frequency      int            `json:"frequency" gorm:"default:3"` // 每周训练次数
	PreferredParts string         `json:"preferred_parts" gorm:"size:100"` // 偏好训练部位
	CurrentWeight  float64        `json:"current_weight"`
	TargetWeight   float64        `json:"target_weight"`
	Experience     string         `json:"experience" gorm:"size:20"` // 初级/中级/高级
	CreatedAt      time.Time      `json:"created_at"`
	UpdatedAt      time.Time      `json:"updated_at"`
	DeletedAt      gorm.DeletedAt `json:"-" gorm:"index"`
}

// AITrainingRecommendation AI训练推荐
type AITrainingRecommendation struct {
	UserID    uint                `json:"user_id"`
	Overview  TrainingOverview    `json:"overview"`
	Exercises []RecommendedExercise `json:"exercises"`
	Generated time.Time           `json:"generated"`
}

// TrainingOverview 训练概览
type TrainingOverview struct {
	Goal           string     `json:"goal"`
	TrainingType   string     `json:"training_type"`
	Frequency      int        `json:"frequency"`
	CompletionRate float64    `json:"completion_rate"`
	LastTraining   *time.Time `json:"last_training"`
	WeeklyProgress int        `json:"weekly_progress"`
}

// AIChatRequest AI聊天请求
type AIChatRequest struct {
	UserID  uint   `json:"user_id" binding:"required"`
	Message string `json:"message" binding:"required"`
}

// AIChatResponse AI聊天响应
type AIChatResponse struct {
	Reply     string    `json:"reply"`
	SpeechURL string    `json:"speech_url"`
	Timestamp time.Time `json:"timestamp"`
}

// SavePreferencesRequest 保存偏好请求
type SavePreferencesRequest struct {
	UserID         uint    `json:"user_id" binding:"required"`
	Goal           string  `json:"goal" binding:"required"`
	Frequency      int     `json:"frequency" binding:"required"`
	PreferredParts string  `json:"preferred_parts"`
	CurrentWeight  float64 `json:"current_weight"`
	TargetWeight   float64 `json:"target_weight"`
	Experience     string  `json:"experience"`
}

// TrainingSessionRequest 训练会话请求
type TrainingSessionRequest struct {
	UserID            uint                    `json:"user_id" binding:"required"`
	Date              string                  `json:"date" binding:"required"`
	PlanID            uint                    `json:"plan_id"`
	CompletedExercises []CompletedExercise    `json:"completed_exercises"`
}

// CompletedExercise 完成的动作
type CompletedExercise struct {
	Name     string `json:"name"`
	SetsDone int    `json:"sets_done"`
}

// AITrainingSession AI训练会话
type AITrainingSession struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	UserID      uint           `json:"user_id" gorm:"not null"`
	User        User           `json:"user" gorm:"foreignKey:UserID"`
	SessionType string         `json:"session_type" gorm:"size:20"` // ai_recommendation/ai_chat/training_session
	Content     string         `json:"content" gorm:"type:text"`
	Response    string         `json:"response" gorm:"type:text"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

// VoiceSettings 语音设置
type VoiceSettings struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	UserID    uint           `json:"user_id" gorm:"not null"`
	User      User           `json:"user" gorm:"foreignKey:UserID"`
	Language  string         `json:"language" gorm:"size:10;default:'zh-CN'"`
	VoiceType string         `json:"voice_type" gorm:"size:20;default:'standard'"`
	Speed     float64        `json:"speed" gorm:"default:1.0"`
	Volume    float64        `json:"volume" gorm:"default:1.0"`
	Enabled   bool           `json:"enabled" gorm:"default:true"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}