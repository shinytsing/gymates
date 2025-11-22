package models

import "time"

// 请求DTO结构

// LoginRequest 登录请求
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

// PhoneLoginRequest 手机号登录请求
type PhoneLoginRequest struct {
	Phone string `json:"phone" binding:"required"`
	Code  string `json:"code" binding:"required,len=6"`
}

// SendCodeRequest 发送验证码请求
type SendCodeRequest struct {
	Phone string `json:"phone" binding:"required"`
	Type  string `json:"type" binding:"required,oneof=login register reset_password"`
}

// SocialLoginRequest 社交登录请求
type SocialLoginRequest struct {
	Provider    string          `json:"provider" binding:"required,oneof=apple google wechat"`
	AccessToken string          `json:"access_token" binding:"required"`
	UserInfo    *SocialUserInfo `json:"user_info,omitempty"`
}

// SocialUserInfo 社交登录用户信息
type SocialUserInfo struct {
	ID     string `json:"id"`
	Name   string `json:"name"`
	Email  string `json:"email"`
	Avatar string `json:"avatar"`
}

// RefreshTokenRequest 刷新Token请求
type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

// RegisterRequest 注册请求
type RegisterRequest struct {
	Name     string `json:"name" binding:"required,min=2,max=50"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

// PhoneRegisterRequest 手机号注册请求
type PhoneRegisterRequest struct {
	Phone    string `json:"phone" binding:"required"`
	Code     string `json:"code" binding:"required,len=6"`
	Name     string `json:"name" binding:"required,min=2,max=50"`
	Password string `json:"password"`
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

// UpdatePostRequest 更新帖子请求
type UpdatePostRequest struct {
	Content string   `json:"content"`
	Images  []string `json:"images"`
}

// UpdateTrainingPlanRequest 更新训练计划请求
type UpdateTrainingPlanRequest struct {
	Name           string     `json:"name"`
	Description    string     `json:"description"`
	Exercises      []Exercise `json:"exercises"`
	Duration       int        `json:"duration"`
	CaloriesBurned int        `json:"calories_burned"`
	Difficulty     string     `json:"difficulty"`
	IsPublic       bool       `json:"is_public"`
}

// CreateCommentRequest 创建评论请求
type CreateCommentRequest struct {
	Content string `json:"content" binding:"required"`
}

// SendMateRequestRequest 发送搭子请求
type SendMateRequestRequest struct {
	MateID uint `json:"mate_id" binding:"required"`
}

// MateRecommendationRequest 搭子推荐请求
type MateRecommendationRequest struct {
	MaxDistance   int      `json:"max_distance" form:"max_distance"`     // 最大距离（米），默认5000
	Gender        string   `json:"gender" form:"gender"`                 // 性别过滤
	TrainingTypes []string `json:"training_types" form:"training_types"` // 训练类型
	Goals         []string `json:"goals" form:"goals"`                   // 健身目标
	PreferredTime string   `json:"preferred_time" form:"preferred_time"` // 偏好时间
	Experience    string   `json:"experience" form:"experience"`         // 经验等级
	Page          int      `json:"page" form:"page"`
	Limit         int      `json:"limit" form:"limit"`
}

// MateProfile 搭子资料
type MateProfile struct {
	User
	Distance     float64  `json:"distance"`       // 距离（米）
	MatchScore   int      `json:"match_score"`    // 匹配度分数（0-100）
	CommonGoals  []string `json:"common_goals"`   // 共同健身目标
	CommonTypes  []string `json:"common_types"`   // 共同训练类型
	IsOnline     bool     `json:"is_online"`      // 是否在线
	LastActiveAt string   `json:"last_active_at"` // 最后活跃时间
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
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int64  `json:"expires_in"` // 访问令牌过期时间（秒）
	User         User   `json:"user"`
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
	Exercises  []Exercise `json:"exercises"`
	Pagination Pagination `json:"pagination"`
}

// NotificationsResponse 通知列表响应
type NotificationsResponse struct {
	Notifications []Notification `json:"notifications"`
	Pagination    Pagination     `json:"pagination"`
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
