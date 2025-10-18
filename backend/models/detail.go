package models

import (
	"time"

	"gorm.io/gorm"
)

// DetailItem 通用详情数据项
type DetailItem struct {
	ID           uint           `json:"id" gorm:"primaryKey"`
	Title        string         `json:"title" gorm:"size:200;not null"`
	Content      string         `json:"content" gorm:"type:text"`
	Description  string         `json:"description" gorm:"type:text"`
	Images       string         `json:"images" gorm:"type:text"`
	Videos       string         `json:"videos" gorm:"type:text"`
	Files        string         `json:"files" gorm:"type:text"`
	Category     string         `json:"category" gorm:"size:50"`
	Type         string         `json:"type" gorm:"size:50;not null"`
	Status       string         `json:"status" gorm:"size:20;default:'draft'"`
	Priority     int            `json:"priority" gorm:"default:0"`
	ViewCount    int            `json:"view_count" gorm:"default:0"`
	LikeCount    int            `json:"like_count" gorm:"default:0"`
	CommentCount int            `json:"comment_count" gorm:"default:0"`
	ShareCount   int            `json:"share_count" gorm:"default:0"`
	Tags         string         `json:"tags" gorm:"size:500"`
	Metadata     string         `json:"metadata" gorm:"type:text"` // JSON格式的额外数据
	UserID       uint           `json:"user_id"`
	User         User           `json:"user" gorm:"foreignKey:UserID"`
	ParentID     *uint          `json:"parent_id"` // 父级ID，用于层级结构
	Parent       *DetailItem    `json:"parent" gorm:"foreignKey:ParentID"`
	Children     []DetailItem   `json:"children" gorm:"foreignKey:ParentID"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `json:"-" gorm:"index"`
}

// DetailListRequest 详情列表请求
type DetailListRequest struct {
	Page     int    `json:"page" form:"page"`
	Limit    int    `json:"limit" form:"limit"`
	Category string `json:"category" form:"category"`
	Type     string `json:"type" form:"type"`
	Status   string `json:"status" form:"status"`
	Keyword  string `json:"keyword" form:"keyword"`
	UserID   uint   `json:"user_id" form:"user_id"`
	ParentID *uint  `json:"parent_id" form:"parent_id"`
	SortBy   string `json:"sort_by" form:"sort_by"`
	Order    string `json:"order" form:"order"`
}

// DetailSubmitRequest 详情提交请求
type DetailSubmitRequest struct {
	Title       string   `json:"title" binding:"required"`
	Content     string   `json:"content"`
	Description string   `json:"description"`
	Images      []string `json:"images"`
	Videos      []string `json:"videos"`
	Files       []string `json:"files"`
	Category    string   `json:"category"`
	Type        string   `json:"type" binding:"required"`
	Status      string   `json:"status"`
	Priority    int      `json:"priority"`
	Tags        []string `json:"tags"`
	Metadata    string   `json:"metadata"`
	ParentID    *uint    `json:"parent_id"`
}

// DetailUpdateRequest 详情更新请求
type DetailUpdateRequest struct {
	Title       string   `json:"title"`
	Content     string   `json:"content"`
	Description string   `json:"description"`
	Images      []string `json:"images"`
	Videos      []string `json:"videos"`
	Files       []string `json:"files"`
	Category    string   `json:"category"`
	Type        string   `json:"type"`
	Status      string   `json:"status"`
	Priority    int      `json:"priority"`
	Tags        []string `json:"tags"`
	Metadata    string   `json:"metadata"`
}

// DetailListResponse 详情列表响应
type DetailListResponse struct {
	Items      []DetailItem `json:"items"`
	Pagination Pagination   `json:"pagination"`
}

// DetailResponse 详情响应
type DetailResponse struct {
	Item DetailItem `json:"item"`
}

// DetailStatsResponse 详情统计响应
type DetailStatsResponse struct {
	TotalItems     int64 `json:"total_items"`
	DraftItems     int64 `json:"draft_items"`
	PublishedItems int64 `json:"published_items"`
	TotalViews     int64 `json:"total_views"`
	TotalLikes     int64 `json:"total_likes"`
	TotalComments  int64 `json:"total_comments"`
	TotalShares    int64 `json:"total_shares"`
}

// PostDetail 帖子详情（继承DetailItem）
type PostDetail struct {
	DetailItem
	PostType      string `json:"post_type" gorm:"size:20"` // text, photo, video, checkin
	Location      string `json:"location" gorm:"size:100"`
	IsPublic      bool   `json:"is_public" gorm:"default:true"`
	AllowComments bool   `json:"allow_comments" gorm:"default:true"`
}

// ProfileDetail 用户资料详情（继承DetailItem）
type ProfileDetail struct {
	DetailItem
	Bio        string  `json:"bio" gorm:"type:text"`
	Location   string  `json:"location" gorm:"size:100"`
	Age        int     `json:"age"`
	Height     float64 `json:"height"`
	Weight     float64 `json:"weight"`
	Goal       string  `json:"goal" gorm:"size:50"`
	Experience string  `json:"experience" gorm:"size:50"`
	IsPublic   bool    `json:"is_public" gorm:"default:true"`
	ShowStats  bool    `json:"show_stats" gorm:"default:true"`
}

// ChatDetail 聊天详情（继承DetailItem）
type ChatDetail struct {
	DetailItem
	ChatID      uint        `json:"chat_id"`
	MessageType string      `json:"message_type" gorm:"size:20"` // text, image, video, file
	IsRead      bool        `json:"is_read" gorm:"default:false"`
	IsEdited    bool        `json:"is_edited" gorm:"default:false"`
	ReplyToID   *uint       `json:"reply_to_id"`
	ReplyTo     *ChatDetail `json:"reply_to" gorm:"foreignKey:ReplyToID"`
}

// AchievementDetail 成就详情（继承DetailItem）
type AchievementDetail struct {
	DetailItem
	AchievementType string     `json:"achievement_type" gorm:"size:50"`
	Icon            string     `json:"icon" gorm:"size:255"`
	Points          int        `json:"points" gorm:"default:0"`
	Progress        int        `json:"progress" gorm:"default:0"`
	MaxProgress     int        `json:"max_progress" gorm:"default:100"`
	IsUnlocked      bool       `json:"is_unlocked" gorm:"default:false"`
	UnlockedAt      *time.Time `json:"unlocked_at"`
	Rarity          string     `json:"rarity" gorm:"size:20;default:'common'"` // common, rare, epic, legendary
}
