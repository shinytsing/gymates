package models

import (
	"gorm.io/gorm"
	"time"
)

// UserTrainingPreferences 用户训练偏好
type UserTrainingPreferences struct {
	ID             uint           `json:"id" gorm:"primaryKey"`
	UserID         uint           `json:"user_id" gorm:"not null"`
	User           User           `json:"user" gorm:"foreignKey:UserID"`
	Goal           string         `json:"goal" gorm:"size:20"`             // 增肌/减脂/维持
	Frequency      int            `json:"frequency" gorm:"default:3"`      // 每周训练次数
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
	UserID    uint                  `json:"user_id"`
	Overview  TrainingOverview      `json:"overview"`
	Exercises []RecommendedExercise `json:"exercises"`
	Generated time.Time             `json:"generated"`
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
	UserID             uint                `json:"user_id" binding:"required"`
	Date               string              `json:"date" binding:"required"`
	PlanID             uint                `json:"plan_id"`
	CompletedExercises []CompletedExercise `json:"completed_exercises"`
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

// VoiceGuidance 语音指导
type VoiceGuidance struct {
	ExerciseID       uint     `json:"exercise_id"`
	ExerciseName     string   `json:"exercise_name"`
	GuidanceText     string   `json:"guidance_text"`
	SpeechURL        string   `json:"speech_url"`
	CountdownPrompts []string `json:"countdown_prompts"`
	RestPrompts      []string `json:"rest_prompts"`
	Duration         int      `json:"duration"` // 秒
	CreatedAt        time.Time `json:"created_at"`
}

// CorrectionAdvice 纠正建议
type CorrectionAdvice struct {
	CorrectionText string    `json:"correction_text"`
	SpeechURL      string    `json:"speech_url"`
	Severity       string    `json:"severity"` // info, warning, error
	Timestamp      time.Time `json:"timestamp"`
}

// TrainingSessionData 训练会话数据
type TrainingSessionData struct {
	UserID             uint                    `json:"user_id"`
	PlanID             uint                    `json:"plan_id"`
	StartTime          time.Time               `json:"start_time"`
	EndTime            time.Time               `json:"end_time"`
	Duration           int                     `json:"duration"` // 分钟
	CompletedExercises []CompletedExerciseData `json:"completed_exercises"`
	TotalSets          int                     `json:"total_sets"`
	TotalReps          int                     `json:"total_reps"`
	CaloriesBurned     int                     `json:"calories_burned"`
	Notes              string                  `json:"notes"`
}

// CompletedExerciseData 完成的动作数据
type CompletedExerciseData struct {
	ExerciseID   uint      `json:"exercise_id"`
	ExerciseName string    `json:"exercise_name"`
	SetsDone     int       `json:"sets_done"`
	RepsPerSet   []int     `json:"reps_per_set"`
	WeightUsed   []float64 `json:"weight_used"`
	RestTime     []int     `json:"rest_time"`
	Notes        string    `json:"notes"`
}

// TrainingSummaryResponse 训练总结响应
type TrainingSummaryResponse struct {
	OverallSummary     string    `json:"overall_summary"`
	Strengths          string    `json:"strengths"`
	Improvements       string    `json:"improvements"`
	NextRecommendation string    `json:"next_recommendation"`
	Rating             int       `json:"rating"` // 1-5
	SpeechURL          string    `json:"speech_url"`
	Timestamp          time.Time `json:"timestamp"`
}

// GeneratePlanRequest 生成训练计划请求
type GeneratePlanRequest struct {
	UserID         uint    `json:"user_id" binding:"required"`
	Goal           string  `json:"goal" binding:"required"`           // 增肌/减脂/力量/耐力
	Frequency      int     `json:"frequency" binding:"required"`      // 每周训练次数
	Experience     string  `json:"experience" binding:"required"`     // 初级/中级/高级
	PreferredParts string  `json:"preferred_parts"`                   // 偏好部位
	CurrentWeight  float64 `json:"current_weight"`
	TargetWeight   float64 `json:"target_weight"`
	Gender         string  `json:"gender"`
	Age            int     `json:"age"`
	Height         float64 `json:"height"`
}

// StartTrainingRequest 开始训练请求
type StartTrainingRequest struct {
	UserID     uint `json:"user_id" binding:"required"`
	PlanID     uint `json:"plan_id" binding:"required"`
	ExerciseID uint `json:"exercise_id" binding:"required"`
}

// UploadTrainingDataRequest 上传训练数据请求
type UploadTrainingDataRequest struct {
	UserID       uint                    `json:"user_id" binding:"required"`
	SessionData  TrainingSessionData     `json:"session_data" binding:"required"`
}

// GetCorrectionRequest 获取纠正建议请求
type GetCorrectionRequest struct {
	UserID     uint                   `json:"user_id" binding:"required"`
	ExerciseID uint                   `json:"exercise_id" binding:"required"`
	SensorData map[string]interface{} `json:"sensor_data"`
}
