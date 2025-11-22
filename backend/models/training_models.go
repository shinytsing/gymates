package models

import (
	"time"

	"gorm.io/gorm"
)

// UserExerciseFavorite 已在 exercise_library.go 中定义

// TrainingPlanV2 增强的训练计划模型
type TrainingPlanV2 struct {
	ID                uint             `json:"id" gorm:"primaryKey"`
	UserID            uint             `json:"user_id" gorm:"not null;index"`
	User              User             `json:"user" gorm:"foreignKey:UserID"`
	Name              string           `json:"name" gorm:"size:100;not null"`
	Description       string           `json:"description" gorm:"type:text"`
	Difficulty        string           `json:"difficulty" gorm:"size:20;default:'beginner'"`
	Goal              string           `json:"goal" gorm:"size:50"`
	IsAIGenerated     bool             `json:"is_ai_generated" gorm:"default:false"`
	IsPublic          bool             `json:"is_public" gorm:"default:false"`
	ImageURL          string           `json:"image_url" gorm:"size:255"`
	EstimatedDuration int              `json:"estimated_duration"`
	EstimatedCalories int              `json:"estimated_calories"`
	Exercises         []PlanExerciseV2 `json:"exercises" gorm:"foreignKey:TrainingPlanID"`
	CreatedAt         time.Time        `json:"created_at"`
	UpdatedAt         time.Time        `json:"updated_at"`
	DeletedAt         gorm.DeletedAt   `json:"-" gorm:"index"`
}

// PlanExerciseV2 训练计划中的运动项
type PlanExerciseV2 struct {
	ID             uint            `json:"id" gorm:"primaryKey"`
	TrainingPlanID uint            `json:"training_plan_id" gorm:"not null;index"`
	ExerciseID     uint            `json:"exercise_id" gorm:"not null"`
	Exercise       ExerciseLibrary `json:"exercise" gorm:"foreignKey:ExerciseID"`
	Sets           int             `json:"sets" gorm:"not null"`
	Reps           int             `json:"reps" gorm:"not null"`
	Weight         float64         `json:"weight"`
	Duration       int             `json:"duration"`
	RestTime       int             `json:"rest_time" gorm:"default:60"`
	Order          int             `json:"order" gorm:"not null"`
	Notes          string          `json:"notes" gorm:"type:text"`
	CreatedAt      time.Time       `json:"created_at"`
	UpdatedAt      time.Time       `json:"updated_at"`
}

// TodayWorkout 今日训练
type TodayWorkout struct {
	ID        uint                `json:"id" gorm:"primaryKey"`
	UserID    uint                `json:"user_id" gorm:"not null;index"`
	User      User                `json:"user" gorm:"foreignKey:UserID"`
	PlanID    *uint               `json:"plan_id"`
	Plan      *TrainingPlanV2     `json:"plan" gorm:"foreignKey:PlanID"`
	Date      time.Time           `json:"date" gorm:"not null;index"`
	Status    string              `json:"status" gorm:"size:20;default:'not_started'"` // not_started, in_progress, completed
	SessionID *uint               `json:"session_id"`
	Session   *WorkoutSessionV2   `json:"session" gorm:"foreignKey:SessionID"`
	Exercises []WorkoutExerciseV2 `json:"exercises" gorm:"foreignKey:WorkoutID"`
	CreatedAt time.Time           `json:"created_at"`
	UpdatedAt time.Time           `json:"updated_at"`
}

// WorkoutSessionV2 训练会话 V2
type WorkoutSessionV2 struct {
	ID             uint            `json:"id" gorm:"primaryKey"`
	UserID         uint            `json:"user_id" gorm:"not null;index"`
	User           User            `json:"user" gorm:"foreignKey:UserID"`
	PlanID         *uint           `json:"plan_id"`
	Plan           *TrainingPlanV2 `json:"plan" gorm:"foreignKey:PlanID"`
	IsAIWorkout    bool            `json:"is_ai_workout" gorm:"default:false"`
	StartTime      time.Time       `json:"start_time" gorm:"not null"`
	EndTime        *time.Time      `json:"end_time"`
	Status         string          `json:"status" gorm:"size:20;default:'ongoing'"` // ongoing, completed, abandoned
	Duration       int             `json:"duration"`                                // minutes
	CaloriesBurned int             `json:"calories_burned"`
	Progress       int             `json:"progress" gorm:"default:0"` // 0-100
	Notes          string          `json:"notes" gorm:"type:text"`
	CreatedAt      time.Time       `json:"created_at"`
	UpdatedAt      time.Time       `json:"updated_at"`
	DeletedAt      gorm.DeletedAt  `json:"-" gorm:"index"`
}

// WorkoutExerciseV2 训练中的运动项
type WorkoutExerciseV2 struct {
	ID            uint            `json:"id" gorm:"primaryKey"`
	WorkoutID     uint            `json:"workout_id" gorm:"not null;index"`
	Workout       TodayWorkout    `json:"workout" gorm:"foreignKey:WorkoutID"`
	ExerciseID    uint            `json:"exercise_id" gorm:"not null"`
	Exercise      ExerciseLibrary `json:"exercise" gorm:"foreignKey:ExerciseID"`
	TotalSets     int             `json:"total_sets" gorm:"not null"`
	CompletedSets int             `json:"completed_sets" gorm:"default:0"`
	TargetReps    int             `json:"target_reps"`
	TargetWeight  float64         `json:"target_weight"`
	SetRecords    []SetRecord     `json:"set_records" gorm:"foreignKey:WorkoutExerciseID"`
	Order         int             `json:"order" gorm:"not null"`
	CreatedAt     time.Time       `json:"created_at"`
	UpdatedAt     time.Time       `json:"updated_at"`
}

// SetRecord 单组记录
type SetRecord struct {
	ID                uint      `json:"id" gorm:"primaryKey"`
	WorkoutExerciseID uint      `json:"workout_exercise_id" gorm:"not null;index"`
	SetNumber         int       `json:"set_number" gorm:"not null"`
	Reps              int       `json:"reps" gorm:"not null"`
	Weight            float64   `json:"weight"`
	Duration          int       `json:"duration"`
	CompletedAt       time.Time `json:"completed_at" gorm:"not null"`
	Notes             string    `json:"notes" gorm:"type:text"`
	CreatedAt         time.Time `json:"created_at"`
}

// TrainingHistory 训练历史记录
type TrainingHistory struct {
	ID                 uint             `json:"id" gorm:"primaryKey"`
	UserID             uint             `json:"user_id" gorm:"not null;index"`
	User               User             `json:"user" gorm:"foreignKey:UserID"`
	SessionID          uint             `json:"session_id" gorm:"not null"`
	Session            WorkoutSessionV2 `json:"session" gorm:"foreignKey:SessionID"`
	PlanID             *uint            `json:"plan_id"`
	PlanName           string           `json:"plan_name" gorm:"size:100"`
	Date               time.Time        `json:"date" gorm:"not null;index"`
	Duration           int              `json:"duration"` // minutes
	CaloriesBurned     int              `json:"calories_burned"`
	CompletedExercises int              `json:"completed_exercises"`
	TotalExercises     int              `json:"total_exercises"`
	CompletionRate     float64          `json:"completion_rate"`
	IsAIWorkout        bool             `json:"is_ai_workout" gorm:"default:false"`
	Notes              string           `json:"notes" gorm:"type:text"`
	CreatedAt          time.Time        `json:"created_at"`
	UpdatedAt          time.Time        `json:"updated_at"`
}

// UserTrainingStats 用户训练统计
type UserTrainingStats struct {
	ID                   uint       `json:"id" gorm:"primaryKey"`
	UserID               uint       `json:"user_id" gorm:"uniqueIndex;not null"`
	User                 User       `json:"user" gorm:"foreignKey:UserID"`
	TotalWorkouts        int        `json:"total_workouts" gorm:"default:0"`
	TotalMinutes         int        `json:"total_minutes" gorm:"default:0"`
	TotalCaloriesBurned  int        `json:"total_calories_burned" gorm:"default:0"`
	CurrentStreak        int        `json:"current_streak" gorm:"default:0"`
	LongestStreak        int        `json:"longest_streak" gorm:"default:0"`
	LastWorkoutDate      *time.Time `json:"last_workout_date"`
	MuscleGroupFrequency string     `json:"muscle_group_frequency" gorm:"type:text"` // JSON格式
	RecentActivities     string     `json:"recent_activities" gorm:"type:text"`      // JSON格式
	AverageIntensity     float64    `json:"average_intensity"`
	UpdatedAt            time.Time  `json:"updated_at"`
}

// AIRecommendation AI训练推荐
type AIRecommendation struct {
	ID        uint            `json:"id" gorm:"primaryKey"`
	UserID    uint            `json:"user_id" gorm:"not null;index"`
	User      User            `json:"user" gorm:"foreignKey:UserID"`
	PlanID    *uint           `json:"plan_id"`
	Plan      *TrainingPlanV2 `json:"plan" gorm:"foreignKey:PlanID"`
	Reason    string          `json:"reason" gorm:"type:text"`
	Goal      string          `json:"goal" gorm:"size:50"`
	Level     string          `json:"level" gorm:"size:20"`
	Exercises string          `json:"exercises" gorm:"type:text"` // JSON格式的运动列表
	IsApplied bool            `json:"is_applied" gorm:"default:false"`
	CreatedAt time.Time       `json:"created_at"`
	DeletedAt gorm.DeletedAt  `json:"-" gorm:"index"`
}

// TableName 指定表名
// TableName 方法已在 exercise_library.go 中定义

func (TrainingPlanV2) TableName() string {
	return "training_plans_v2"
}

func (PlanExerciseV2) TableName() string {
	return "plan_exercises_v2"
}

func (TodayWorkout) TableName() string {
	return "today_workouts"
}

func (WorkoutSessionV2) TableName() string {
	return "workout_sessions_v2"
}

func (WorkoutExerciseV2) TableName() string {
	return "workout_exercises_v2"
}

func (SetRecord) TableName() string {
	return "set_records"
}

func (TrainingHistory) TableName() string {
	return "training_histories"
}

func (UserTrainingStats) TableName() string {
	return "user_training_stats"
}

func (AIRecommendation) TableName() string {
	return "ai_recommendations"
}
