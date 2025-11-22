package dto

import "time"

// RegisterRequest represents a registration request
type RegisterRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
	Name     string `json:"name" binding:"required"`
}

// LoginRequest represents a login request
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// PhoneRegisterRequest represents a phone registration request
type PhoneRegisterRequest struct {
	Phone string `json:"phone" binding:"required"`
	Code  string `json:"code" binding:"required"`
	Name  string `json:"name" binding:"required"`
}

// PhoneLoginRequest represents a phone login request
type PhoneLoginRequest struct {
	Phone string `json:"phone" binding:"required"`
	Code  string `json:"code" binding:"required"`
}

// SocialLoginRequest represents a social login request
type SocialLoginRequest struct {
	Provider   string `json:"provider" binding:"required,oneof=google apple wechat"`
	Token      string `json:"token" binding:"required"`
	Name       string `json:"name"`
	Avatar     string `json:"avatar"`
	ProviderID string `json:"provider_id"`
}

// SendCodeRequest represents a send verification code request
type SendCodeRequest struct {
	Phone string `json:"phone" binding:"required"`
}

// RefreshTokenRequest represents a refresh token request
type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

// AuthResponse represents an authentication response
type AuthResponse struct {
	User         *UserDTO      `json:"user"`
	AccessToken  string        `json:"access_token"`
	RefreshToken string        `json:"refresh_token"`
	TokenType    string        `json:"token_type"`
	ExpiresIn    int64         `json:"expires_in"` // seconds
}

// TokenResponse represents a token response
type TokenResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	TokenType    string `json:"token_type"`
	ExpiresIn    int64  `json:"expires_in"`
}

// UserDTO represents a user data transfer object
type UserDTO struct {
	ID              uint       `json:"id"`
	Email           string     `json:"email,omitempty"`
	Phone           string     `json:"phone,omitempty"`
	Name            string     `json:"name"`
	Avatar          string     `json:"avatar"`
	Bio             string     `json:"bio,omitempty"`
	Gender          string     `json:"gender,omitempty"`
	Birthday        *time.Time `json:"birthday,omitempty"`
	Height          float64    `json:"height,omitempty"`
	Weight          float64    `json:"weight,omitempty"`
	Location        string     `json:"location,omitempty"`
	FollowersCount  int        `json:"followers_count"`
	FollowingCount  int        `json:"following_count"`
	MatesCount      int        `json:"mates_count"`
	PostsCount      int        `json:"posts_count"`
	TotalWorkouts   int        `json:"total_workouts"`
	TotalDuration   int        `json:"total_duration"`
	TotalCalories   int        `json:"total_calories"`
	CurrentStreak   int        `json:"current_streak"`
	IsEmailVerified bool       `json:"is_email_verified"`
	IsPhoneVerified bool       `json:"is_phone_verified"`
	CreatedAt       time.Time  `json:"created_at"`
}

// UpdateProfileRequest represents a profile update request
type UpdateProfileRequest struct {
	Name     string     `json:"name"`
	Avatar   string     `json:"avatar"`
	Bio      string     `json:"bio"`
	Gender   string     `json:"gender"`
	Birthday *time.Time `json:"birthday"`
	Height   float64    `json:"height"`
	Weight   float64    `json:"weight"`
	Location string     `json:"location"`
}

