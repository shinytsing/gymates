package models

import "time"

// 请求DTO结构

// LoginRequest 登录请求
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

// RegisterRequest 注册请求
type RegisterRequest struct {
	Name     string `json:"name" binding:"required,min=2,max=50"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

// UpdateProfileRequest 更新用户资料请求
type UpdateProfileRequest struct {
	Name       string  `json:"name"`
	Bio        string  `json:"bio"`
	Location   string  `json:"location"`
	Age        int     `json:"age"`
	Height     float64 `json:"height"`
	Weight     float64 `json:"weight"`
	Goal       string  `json:"goal"`
	Experience string  `json:"experience"`
}

// CreateTrainingPlanRequest 创建训练计划请求
type CreateTrainingPlanRequest struct {
	Name           string     `json:"name" binding:"required"`
	Description    string     `json:"description"`
	Exercises      []Exercise `json:"exercises" binding:"required"`
	Duration       int        `json:"duration" binding:"required,min=1"`
	CaloriesBurned int        `json:"calories_burned" binding:"required,min=1"`
	Difficulty     string     `json:"difficulty"`
	IsPublic       bool       `json:"is_public"`
}

// CreateExerciseRequest 创建训练动作请求
type CreateExerciseRequest struct {
	Name         string  `json:"name" binding:"required"`
	Sets         int     `json:"sets" binding:"required,min=1"`
	Reps         int     `json:"reps" binding:"required,min=1"`
	Weight       float64 `json:"weight"`
	Duration     int     `json:"duration"`
	RestTime     int     `json:"rest_time"`
	Instructions string  `json:"instructions"`
	ImageURL     string  `json:"image_url"`
	Order        int     `json:"order"`
}

// StartWorkoutSessionRequest 开始训练会话请求
type StartWorkoutSessionRequest struct {
	TrainingPlanID uint `json:"training_plan_id" binding:"required"`
}

// UpdateWorkoutProgressRequest 更新训练进度请求
type UpdateWorkoutProgressRequest struct {
	Progress int `json:"progress" binding:"required,min=0,max=100"`
}

// CreatePostRequest 创建帖子请求
type CreatePostRequest struct {
	Content string   `json:"content" binding:"required"`
	Images  []string `json:"images"`
	Type    string   `json:"type"`
}

// CreateCommentRequest 创建评论请求
type CreateCommentRequest struct {
	Content string `json:"content" binding:"required"`
}

// SendMateRequestRequest 发送搭子请求
type SendMateRequestRequest struct {
	MateID uint `json:"mate_id" binding:"required"`
}

// SendMessageRequest 发送消息请求
type SendMessageRequest struct {
	ChatID  uint   `json:"chat_id" binding:"required"`
	Content string `json:"content" binding:"required"`
	Type    string `json:"type"`
}

// 响应DTO结构

// AuthResponse 认证响应
type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

// PaginationResponse 分页响应
type PaginationResponse struct {
	Data       interface{} `json:"data"`
	Pagination Pagination  `json:"pagination"`
}

// Pagination 分页信息
type Pagination struct {
	Page       int   `json:"page"`
	Limit      int   `json:"limit"`
	Total      int64 `json:"total"`
	TotalPages int   `json:"total_pages"`
	HasMore    bool  `json:"has_more"`
}

// PostsResponse 帖子列表响应
type PostsResponse struct {
	Posts      []Post     `json:"posts"`
	Pagination Pagination `json:"pagination"`
}

// CommentsResponse 评论列表响应
type CommentsResponse struct {
	Comments   []Comment  `json:"comments"`
	Pagination Pagination `json:"pagination"`
}

// MatesResponse 搭子列表响应
type MatesResponse struct {
	Mates      []User     `json:"mates"`
	Pagination Pagination `json:"pagination"`
}

// ChatsResponse 聊天列表响应
type ChatsResponse struct {
	Chats      []Chat     `json:"chats"`
	Pagination Pagination `json:"pagination"`
}

// MessagesResponse 消息列表响应
type MessagesResponse struct {
	Messages   []Message  `json:"messages"`
	Pagination Pagination `json:"pagination"`
}

// TrainingPlansResponse 训练计划列表响应
type TrainingPlansResponse struct {
	Plans      []TrainingPlan `json:"plans"`
	Pagination Pagination     `json:"pagination"`
}

// WorkoutSessionsResponse 训练会话列表响应
type WorkoutSessionsResponse struct {
	Sessions   []WorkoutSession `json:"sessions"`
	Pagination Pagination       `json:"pagination"`
}

// ExercisesResponse 训练动作列表响应
type ExercisesResponse struct {
	Exercises  []Exercise  `json:"exercises"`
	Pagination Pagination  `json:"pagination"`
}

// API响应结构

// APIResponse 通用API响应
type APIResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// ErrorResponse 错误响应
type ErrorResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	Error   string `json:"error"`
	Code    int    `json:"code"`
}

// SuccessResponse 成功响应
type SuccessResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// 统计响应结构

// UserStatsResponse 用户统计响应
type UserStatsResponse struct {
	TotalWorkouts     int `json:"total_workouts"`
	TotalCalories     int `json:"total_calories"`
	TotalPosts        int `json:"total_posts"`
	TotalMates        int `json:"total_mates"`
	TotalAchievements int `json:"total_achievements"`
}

// PostStatsResponse 帖子统计响应
type PostStatsResponse struct {
	TotalPosts    int `json:"total_posts"`
	TotalLikes    int `json:"total_likes"`
	TotalComments int `json:"total_comments"`
	TotalShares   int `json:"total_shares"`
}

// TrainingStatsResponse 训练统计响应
type TrainingStatsResponse struct {
	TotalSessions     int     `json:"total_sessions"`
	TotalDuration     int     `json:"total_duration"`
	TotalCalories     int     `json:"total_calories"`
	AverageProgress   float64 `json:"average_progress"`
	CompletedSessions int     `json:"completed_sessions"`
}

// 搜索和过滤结构

// SearchRequest 搜索请求
type SearchRequest struct {
	Query string `json:"query" binding:"required"`
	Type  string `json:"type"`
	Page  int    `json:"page"`
	Limit int    `json:"limit"`
}

// FilterRequest 过滤请求
type FilterRequest struct {
	Category string    `json:"category"`
	Tags     []string  `json:"tags"`
	DateFrom time.Time `json:"date_from"`
	DateTo   time.Time `json:"date_to"`
	Page     int       `json:"page"`
	Limit    int       `json:"limit"`
}

// 文件上传响应

// FileUploadResponse 文件上传响应
type FileUploadResponse struct {
	URL      string `json:"url"`
	Filename string `json:"filename"`
	Size     int64  `json:"size"`
	Type     string `json:"type"`
}

// 健康检查响应

// HealthResponse 健康检查响应
type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Version   string    `json:"version"`
	Database  string    `json:"database"`
	Redis     string    `json:"redis,omitempty"`
}

// AddCommentRequest 添加评论请求
type AddCommentRequest struct {
	Content string `json:"content" binding:"required"`
}
