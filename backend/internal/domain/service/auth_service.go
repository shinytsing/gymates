package service

import (
	"context"
	"gymates-backend/internal/application/dto"
	"gymates-backend/internal/domain/entity"
)

// AuthService defines the authentication service interface
type AuthService interface {
	// Register registers a new user with email
	Register(ctx context.Context, req *dto.RegisterRequest) (*dto.AuthResponse, error)
	
	// Login authenticates a user with email/password
	Login(ctx context.Context, req *dto.LoginRequest) (*dto.AuthResponse, error)
	
	// PhoneRegister registers a new user with phone number
	PhoneRegister(ctx context.Context, req *dto.PhoneRegisterRequest) (*dto.AuthResponse, error)
	
	// PhoneLogin authenticates a user with phone/code
	PhoneLogin(ctx context.Context, req *dto.PhoneLoginRequest) (*dto.AuthResponse, error)
	
	// SocialLogin authenticates or registers a user via social provider
	SocialLogin(ctx context.Context, req *dto.SocialLoginRequest) (*dto.AuthResponse, error)
	
	// GuestLogin creates a guest account
	GuestLogin(ctx context.Context, deviceID string) (*dto.AuthResponse, error)
	
	// RefreshToken refreshes the access token
	RefreshToken(ctx context.Context, refreshToken string) (*dto.TokenResponse, error)
	
	// Logout logs out a user (revokes tokens)
	Logout(ctx context.Context, userID uint) error
	
	// RevokeToken revokes a specific token
	RevokeToken(ctx context.Context, token string) error
	
	// ValidateToken validates an access token and returns the user
	ValidateToken(ctx context.Context, token string) (*entity.User, error)
	
	// SendVerificationCode sends a verification code to phone
	SendVerificationCode(ctx context.Context, phone string) error
	
	// VerifyCode verifies a phone verification code
	VerifyCode(ctx context.Context, phone, code string) (bool, error)
}

