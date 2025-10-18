package models

import (
	"time"
	"gorm.io/gorm"
)

// HomeItem 通用首页数据项
type HomeItem struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	Title       string         `json:"title" gorm:"size:200;not null"`
	Description string         `json:"description" gorm:"type:text"`
	Image       string         `json:"image" gorm:"size:500"`
	Category    string         `json:"category" gorm:"size:50"`
	Tags        string         `json:"tags" gorm:"size:500"`
	Status      string         `json:"status" gorm:"size:20;default:'active'"`
	Priority    int            `json:"priority" gorm:"default:0"`
	ViewCount   int            `json:"view_count" gorm:"default:0"`
	LikeCount   int            `json:"like_count" gorm:"default:0"`
	CommentCount int           `json:"comment_count" gorm:"default:0"`
	UserID      uint           `json:"user_id"`
	User        User           `json:"user" gorm:"foreignKey:UserID"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

// HomeListRequest 首页列表请求
type HomeListRequest struct {
	Page     int    `json:"page" form:"page"`
	Limit    int    `json:"limit" form:"limit"`
	Category string `json:"category" form:"category"`
	Status   string `json:"status" form:"status"`
	Keyword  string `json:"keyword" form:"keyword"`
	SortBy   string `json:"sort_by" form:"sort_by"`
	Order    string `json:"order" form:"order"`
}

// HomeAddRequest 首页新增请求
type HomeAddRequest struct {
	Title       string `json:"title" binding:"required"`
	Description string `json:"description"`
	Image       string `json:"image"`
	Category    string `json:"category"`
	Tags        string `json:"tags"`
	Priority    int    `json:"priority"`
}

// HomeUpdateRequest 首页更新请求
type HomeUpdateRequest struct {
	Title       string `json:"title"`
	Description string `json:"description"`
	Image       string `json:"image"`
	Category    string `json:"category"`
	Tags        string `json:"tags"`
	Status      string `json:"status"`
	Priority    int    `json:"priority"`
}

// HomeListResponse 首页列表响应
type HomeListResponse struct {
	Items      []HomeItem `json:"items"`
	Pagination Pagination `json:"pagination"`
}

// HomeDetailResponse 首页详情响应
type HomeDetailResponse struct {
	Item HomeItem `json:"item"`
}

// HomeStatsResponse 首页统计响应
type HomeStatsResponse struct {
	TotalItems    int64 `json:"total_items"`
	ActiveItems   int64 `json:"active_items"`
	TotalViews    int64 `json:"total_views"`
	TotalLikes    int64 `json:"total_likes"`
	TotalComments int64 `json:"total_comments"`
}
