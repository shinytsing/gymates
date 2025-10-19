package models

import (
	"time"
	"gorm.io/gorm"
)

// ExerciseLibrary 动作库模型
type ExerciseLibrary struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	Name        string         `json:"name" gorm:"size:100;not null"`
	Part        string         `json:"part" gorm:"size:50;not null"`
	Level       string         `json:"level" gorm:"size:20;default:'intermediate'"`
	Type        string         `json:"type" gorm:"size:30"`
	Equipment   string         `json:"equipment" gorm:"size:50"`
	Tags        string         `json:"tags" gorm:"type:text"` // JSON字符串存储标签
	Description string         `json:"description" gorm:"type:text"`
	Instructions string        `json:"instructions" gorm:"type:text"`
	ImageURL    string         `json:"image_url" gorm:"size:255"`
	VideoURL    string         `json:"video_url" gorm:"size:255"`
	MuscleGroups string        `json:"muscle_groups" gorm:"size:100"` // 主要肌群
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

// TrainingMode 训练模式
type TrainingMode struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	UserID      uint           `json:"user_id" gorm:"not null"`
	User        User           `json:"user" gorm:"foreignKey:UserID"`
	Mode        string         `json:"mode" gorm:"size:20;not null"` // 三分化/五分化/推拉腿
	TrainDays   int            `json:"train_days" gorm:"default:3"` // 每周训练天数
	Target      string         `json:"target" gorm:"size:20"` // 增肌/减脂/综合
	Level       string         `json:"level" gorm:"size:20"` // 初级/中级/高级
	IsActive    bool           `json:"is_active" gorm:"default:true"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

// UserTrainingHistory 用户训练历史
type UserTrainingHistory struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	UserID      uint           `json:"user_id" gorm:"not null"`
	User        User           `json:"user" gorm:"foreignKey:UserID"`
	ExerciseID  uint           `json:"exercise_id" gorm:"not null"`
	Exercise    ExerciseLibrary `json:"exercise" gorm:"foreignKey:ExerciseID"`
	MuscleGroup string         `json:"muscle_group" gorm:"size:50"`
	Sets        int            `json:"sets"`
	Reps        int            `json:"reps"`
	Weight      float64        `json:"weight"`
	Duration    int            `json:"duration"` // 训练时长（秒）
	CompletedAt time.Time      `json:"completed_at"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}
