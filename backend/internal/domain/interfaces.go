package domain

import (
	"context"
	"time"

	"gymates-backend/models"
)

// Repository interfaces define data access contracts

// UserRepository defines user data operations
type UserRepository interface {
	Create(ctx context.Context, user *models.User) error
	GetByID(ctx context.Context, id uint) (*models.User, error)
	GetByEmail(ctx context.Context, email string) (*models.User, error)
	GetByPhone(ctx context.Context, phone string) (*models.User, error)
	Update(ctx context.Context, user *models.User) error
	Delete(ctx context.Context, id uint) error
	List(ctx context.Context, offset, limit int) ([]*models.User, int64, error)
	Search(ctx context.Context, query string, offset, limit int) ([]*models.User, int64, error)
}

// PostRepository defines post data operations
type PostRepository interface {
	Create(ctx context.Context, post *models.Post) error
	GetByID(ctx context.Context, id uint) (*models.Post, error)
	Update(ctx context.Context, post *models.Post) error
	Delete(ctx context.Context, id uint) error
	List(ctx context.Context, offset, limit int) ([]*models.Post, int64, error)
	GetByUserID(ctx context.Context, userID uint, offset, limit int) ([]*models.Post, int64, error)
	GetFeed(ctx context.Context, userID uint, offset, limit int) ([]*models.Post, int64, error)
}

// TrainingRepository defines training data operations
type TrainingRepository interface {
	Create(ctx context.Context, plan *models.TrainingPlan) error
	GetByID(ctx context.Context, id uint) (*models.TrainingPlan, error)
	Update(ctx context.Context, plan *models.TrainingPlan) error
	Delete(ctx context.Context, id uint) error
	GetByUserID(ctx context.Context, userID uint) ([]*models.TrainingPlan, error)
	GetActive(ctx context.Context, userID uint) (*models.TrainingPlan, error)
}

// MessageRepository defines message data operations
type MessageRepository interface {
	Create(ctx context.Context, message *models.Message) error
	GetByID(ctx context.Context, id uint) (*models.Message, error)
	GetConversation(ctx context.Context, user1ID, user2ID uint, offset, limit int) ([]*models.Message, error)
	GetConversations(ctx context.Context, userID uint) ([]*models.Conversation, error)
	MarkAsRead(ctx context.Context, messageID uint) error
	GetUnreadCount(ctx context.Context, userID uint) (int64, error)
}

// MateRepository defines mate relationship operations
type MateRepository interface {
	Create(ctx context.Context, request *models.MateRequest) error
	GetByID(ctx context.Context, id uint) (*models.MateRequest, error)
	Update(ctx context.Context, request *models.MateRequest) error
	GetMates(ctx context.Context, userID uint) ([]*models.User, error)
	GetPendingRequests(ctx context.Context, userID uint) ([]*models.MateRequest, error)
	CheckMateStatus(ctx context.Context, user1ID, user2ID uint) (string, error)
	FindPotentialMates(ctx context.Context, userID uint, filters map[string]interface{}) ([]*models.User, error)
}

// Service interfaces define business logic contracts

// AuthService defines authentication business logic
type AuthService interface {
	Register(ctx context.Context, req *models.RegisterRequest) (*models.AuthResponse, error)
	Login(ctx context.Context, req *models.LoginRequest) (*models.AuthResponse, error)
	PhoneLogin(ctx context.Context, phone, code string) (*models.AuthResponse, error)
	SocialLogin(ctx context.Context, provider string, token string) (*models.AuthResponse, error)
	RefreshToken(ctx context.Context, refreshToken string) (*models.AuthResponse, error)
	RevokeToken(ctx context.Context, token string) error
	ValidateToken(ctx context.Context, token string) (*models.User, error)
	SendVerificationCode(ctx context.Context, phone string) error
}

// CommunityService defines community business logic
type CommunityService interface {
	CreatePost(ctx context.Context, userID uint, req *models.CreatePostRequest) (*models.Post, error)
	GetPost(ctx context.Context, postID uint) (*models.Post, error)
	UpdatePost(ctx context.Context, postID, userID uint, req *models.UpdatePostRequest) (*models.Post, error)
	DeletePost(ctx context.Context, postID, userID uint) error
	ListPosts(ctx context.Context, page, limit int) ([]*models.Post, int64, error)
	LikePost(ctx context.Context, postID, userID uint) error
	UnlikePost(ctx context.Context, postID, userID uint) error
	GetUserPosts(ctx context.Context, userID uint, page, limit int) ([]*models.Post, int64, error)
}

// TrainingService defines training business logic
type TrainingService interface {
	CreatePlan(ctx context.Context, userID uint, req *models.CreateTrainingPlanRequest) (*models.TrainingPlan, error)
	GetPlan(ctx context.Context, planID uint) (*models.TrainingPlan, error)
	UpdatePlan(ctx context.Context, planID, userID uint, req *models.UpdateTrainingPlanRequest) (*models.TrainingPlan, error)
	DeletePlan(ctx context.Context, planID, userID uint) error
	GetUserPlans(ctx context.Context, userID uint) ([]*models.TrainingPlan, error)
	GetActivePlan(ctx context.Context, userID uint) (*models.TrainingPlan, error)
	GenerateAIPlan(ctx context.Context, userID uint, preferences map[string]interface{}) (*models.TrainingPlan, error)
}

// MessageService defines messaging business logic
type MessageService interface {
	SendMessage(ctx context.Context, senderID, receiverID uint, content string) (*models.Message, error)
	GetConversation(ctx context.Context, user1ID, user2ID uint, page, limit int) ([]*models.Message, error)
	GetConversations(ctx context.Context, userID uint) ([]*models.Conversation, error)
	MarkAsRead(ctx context.Context, messageID, userID uint) error
	GetUnreadCount(ctx context.Context, userID uint) (int64, error)
}

// MateService defines mate matching business logic
type MateService interface {
	SendMateRequest(ctx context.Context, senderID, receiverID uint) error
	AcceptMateRequest(ctx context.Context, requestID, userID uint) error
	RejectMateRequest(ctx context.Context, requestID, userID uint) error
	GetMates(ctx context.Context, userID uint) ([]*models.User, error)
	GetPendingRequests(ctx context.Context, userID uint) ([]*models.MateRequest, error)
	FindPotentialMates(ctx context.Context, userID uint, filters map[string]interface{}) ([]*models.User, error)
	GetRecommendations(ctx context.Context, userID uint) ([]*models.User, error)
}

// AIService defines AI-related business logic
type AIService interface {
	GenerateTrainingPlan(ctx context.Context, userProfile *models.UserProfile, preferences map[string]interface{}) (*models.TrainingPlan, error)
	GetExerciseGuidance(ctx context.Context, exerciseID uint) (*models.ExerciseGuidance, error)
	AnalyzeWorkoutForm(ctx context.Context, videoURL string) (*models.FormAnalysis, error)
	GetNutritionAdvice(ctx context.Context, userProfile *models.UserProfile, goal string) (*models.NutritionAdvice, error)
	ChatWithCoach(ctx context.Context, userID uint, message string) (string, error)
}

// CacheService defines caching operations
type CacheService interface {
	Get(ctx context.Context, key string) (interface{}, error)
	Set(ctx context.Context, key string, value interface{}, expiration time.Duration) error
	Delete(ctx context.Context, key string) error
	Exists(ctx context.Context, key string) (bool, error)
}

// SMSService defines SMS operations
type SMSService interface {
	SendVerificationCode(ctx context.Context, phone, code string) error
	ValidateVerificationCode(ctx context.Context, phone, code string) (bool, error)
}

// WebSocketService defines real-time messaging
type WebSocketService interface {
	HandleConnection(ctx context.Context, userID uint, conn interface{}) error
	SendMessage(ctx context.Context, userID uint, message interface{}) error
	BroadcastMessage(ctx context.Context, message interface{}) error
	CloseConnection(ctx context.Context, userID uint) error
}

