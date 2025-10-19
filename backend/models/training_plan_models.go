package models

import (
	"time"
	"gorm.io/gorm"
)

// WeeklyTrainingPlan 一周训练计划模型
type WeeklyTrainingPlan struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	UserID      uint           `json:"user_id" gorm:"not null"`
	User        User           `json:"user" gorm:"foreignKey:UserID"`
	Name        string         `json:"name" gorm:"size:100;not null"`
	Description string         `json:"description" gorm:"type:text"`
	Days        []TrainingDay  `json:"days" gorm:"foreignKey:WeeklyTrainingPlanID"`
	IsActive    bool           `json:"is_active" gorm:"default:true"`
	IsPublic    bool           `json:"is_public" gorm:"default:false"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

// TrainingDay 训练日模型
type TrainingDay struct {
	ID                    uint           `json:"id" gorm:"primaryKey"`
	WeeklyTrainingPlanID  uint           `json:"weekly_training_plan_id" gorm:"not null"`
	WeeklyTrainingPlan    WeeklyTrainingPlan `json:"weekly_training_plan" gorm:"foreignKey:WeeklyTrainingPlanID"`
	DayOfWeek             int            `json:"day_of_week" gorm:"not null"` // 1-7 (周一-周日)
	DayName               string         `json:"day_name" gorm:"size:20;not null"`
	Parts                 []TrainingPart `json:"parts" gorm:"foreignKey:TrainingDayID"`
	IsRestDay             bool           `json:"is_rest_day" gorm:"default:false"`
	Notes                 string         `json:"notes" gorm:"type:text"`
	CreatedAt             time.Time      `json:"created_at"`
	UpdatedAt             time.Time      `json:"updated_at"`
	DeletedAt             gorm.DeletedAt `json:"-" gorm:"index"`
}

// TrainingPart 训练部位模型
type TrainingPart struct {
	ID           uint           `json:"id" gorm:"primaryKey"`
	TrainingDayID uint          `json:"training_day_id" gorm:"not null"`
	TrainingDay  TrainingDay   `json:"training_day" gorm:"foreignKey:TrainingDayID"`
	MuscleGroup  string         `json:"muscle_group" gorm:"size:50;not null"`
	MuscleGroupName string      `json:"muscle_group_name" gorm:"size:50;not null"`
	Exercises    []Exercise     `json:"exercises" gorm:"foreignKey:TrainingPartID"`
	Order        int            `json:"order" gorm:"not null"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `json:"-" gorm:"index"`
}

// 请求DTO结构

// CreateWeeklyTrainingPlanRequest 创建一周训练计划请求
type CreateWeeklyTrainingPlanRequest struct {
	Name        string                    `json:"name" binding:"required"`
	Description string                    `json:"description"`
	Days        []CreateTrainingDayRequest `json:"days" binding:"required"`
	IsPublic    bool                      `json:"is_public"`
}

// CreateTrainingDayRequest 创建训练日请求
type CreateTrainingDayRequest struct {
	DayOfWeek int                        `json:"day_of_week" binding:"required,min=1,max=7"`
	DayName   string                     `json:"day_name" binding:"required"`
	Parts     []CreateTrainingPartRequest `json:"parts"`
	IsRestDay bool                       `json:"is_rest_day"`
	Notes     string                     `json:"notes"`
}

// CreateTrainingPartRequest 创建训练部位请求
type CreateTrainingPartRequest struct {
	MuscleGroup     string                   `json:"muscle_group" binding:"required"`
	MuscleGroupName string                   `json:"muscle_group_name" binding:"required"`
	Exercises       []CreateExerciseRequest   `json:"exercises"`
	Order           int                      `json:"order"`
}

// CreateExerciseRequest 创建训练动作请求 (扩展)
type CreateExerciseRequest struct {
	Name         string  `json:"name" binding:"required"`
	Description  string  `json:"description"`
	MuscleGroup  string  `json:"muscle_group"`
	Sets         int     `json:"sets" binding:"required,min=1"`
	Reps         int     `json:"reps" binding:"required,min=1"`
	Weight       float64 `json:"weight"`
	Duration     int     `json:"duration"`
	RestTime     int     `json:"rest_time"`
	RestSeconds  int     `json:"rest_seconds"`
	Instructions string  `json:"instructions"`
	ImageURL     string  `json:"image_url"`
	VideoURL     string  `json:"video_url"`
	Notes        string  `json:"notes"`
	Order        int     `json:"order"`
}

// UpdateWeeklyTrainingPlanRequest 更新一周训练计划请求
type UpdateWeeklyTrainingPlanRequest struct {
	Name        string                    `json:"name"`
	Description string                    `json:"description"`
	Days        []UpdateTrainingDayRequest `json:"days"`
	IsPublic    *bool                     `json:"is_public"`
}

// UpdateTrainingDayRequest 更新训练日请求
type UpdateTrainingDayRequest struct {
	ID        uint                        `json:"id"`
	DayOfWeek int                         `json:"day_of_week"`
	DayName   string                      `json:"day_name"`
	Parts     []UpdateTrainingPartRequest `json:"parts"`
	IsRestDay bool                        `json:"is_rest_day"`
	Notes     string                      `json:"notes"`
}

// UpdateTrainingPartRequest 更新训练部位请求
type UpdateTrainingPartRequest struct {
	ID              uint                      `json:"id"`
	MuscleGroup     string                    `json:"muscle_group"`
	MuscleGroupName string                    `json:"muscle_group_name"`
	Exercises       []UpdateExerciseRequest    `json:"exercises"`
	Order           int                       `json:"order"`
}

// UpdateExerciseRequest 更新训练动作请求
type UpdateExerciseRequest struct {
	ID           uint     `json:"id"`
	Name         string   `json:"name"`
	Description  string   `json:"description"`
	MuscleGroup  string   `json:"muscle_group"`
	Sets         int      `json:"sets"`
	Reps         int      `json:"reps"`
	Weight       float64  `json:"weight"`
	Duration     int      `json:"duration"`
	RestTime     int      `json:"rest_time"`
	RestSeconds  int      `json:"rest_seconds"`
	Instructions string   `json:"instructions"`
	ImageURL     string   `json:"image_url"`
	VideoURL     string   `json:"video_url"`
	Notes        string   `json:"notes"`
	IsCompleted  *bool    `json:"is_completed"`
	Order        int      `json:"order"`
}

// 响应DTO结构

// WeeklyTrainingPlansResponse 一周训练计划列表响应
type WeeklyTrainingPlansResponse struct {
	Plans      []WeeklyTrainingPlan `json:"plans"`
	Pagination Pagination           `json:"pagination"`
}

// WeeklyTrainingPlanResponse 一周训练计划响应
type WeeklyTrainingPlanResponse struct {
	Plan WeeklyTrainingPlan `json:"plan"`
}

// AIRecommendationRequest AI推荐请求
type AIRecommendationRequest struct {
	UserID      uint   `json:"user_id" binding:"required"`
	Day         string `json:"day" binding:"required"` // Monday, Tuesday, etc.
	MuscleGroup string `json:"muscle_group,omitempty"` // 可选指定肌群
}

// AIRecommendationResponse AI推荐响应
type AIRecommendationResponse struct {
	UserID uint                    `json:"user_id"`
	Day    string                  `json:"day"`
	Parts  []RecommendedPart       `json:"parts"`
	Mode   string                  `json:"mode"`
	Target string                  `json:"target"`
}

// RecommendedPart 推荐部位
type RecommendedPart struct {
	PartName  string                `json:"part_name"`
	Exercises []RecommendedExercise `json:"exercises"`
}

// RecommendedExercise 推荐动作（扩展版）
type RecommendedExercise struct {
	Name        string  `json:"name"`
	Sets        int     `json:"sets"`
	Reps        int     `json:"reps"`
	Weight      float64 `json:"weight"`
	RestSeconds int     `json:"rest_seconds"`
	Part        string  `json:"part"`
	Description string  `json:"description"`
	VideoURL    string  `json:"video_url"`
	Notes       string  `json:"notes"`
}