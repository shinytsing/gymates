package services

import (
	"context"
	"errors"
	"fmt"
	"os"
	"time"

	"gymates-backend/internal/domain"
	"gymates-backend/models"

	"github.com/golang-jwt/jwt/v4"
	"golang.org/x/crypto/bcrypt"
)

// authService implements domain.AuthService
type authService struct {
	userRepo   domain.UserRepository
	smsService domain.SMSService
	jwtSecret  []byte
}

// NewAuthService creates a new auth service
func NewAuthService(userRepo domain.UserRepository, smsService domain.SMSService) domain.AuthService {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = "gymates-default-secret-change-in-production"
	}

	return &authService{
		userRepo:   userRepo,
		smsService: smsService,
		jwtSecret:  []byte(secret),
	}
}

// Register implements domain.AuthService
func (s *authService) Register(ctx context.Context, req *models.RegisterRequest) (*models.AuthResponse, error) {
	// Check if user already exists
	existing, _ := s.userRepo.GetByEmail(ctx, req.Email)
	if existing != nil {
		return nil, errors.New("email already registered")
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	// Create user
	user := &models.User{
		Email:    req.Email,
		Password: string(hashedPassword),
		Name:     req.Name,
	}

	if err := s.userRepo.Create(ctx, user); err != nil {
		return nil, err
	}

	// Generate tokens
	return s.generateAuthResponse(user)
}

// Login implements domain.AuthService
func (s *authService) Login(ctx context.Context, req *models.LoginRequest) (*models.AuthResponse, error) {
	// Find user by email
	user, err := s.userRepo.GetByEmail(ctx, req.Email)
	if err != nil {
		return nil, errors.New("invalid credentials")
	}

	// Check password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return nil, errors.New("invalid credentials")
	}

	// Generate tokens
	return s.generateAuthResponse(user)
}

// PhoneLogin implements domain.AuthService
func (s *authService) PhoneLogin(ctx context.Context, phone, code string) (*models.AuthResponse, error) {
	// Validate verification code
	valid, err := s.smsService.ValidateVerificationCode(ctx, phone, code)
	if err != nil || !valid {
		return nil, errors.New("invalid verification code")
	}

	// Find or create user by phone
	user, err := s.userRepo.GetByPhone(ctx, phone)
	if err != nil {
		// Create new user if not exists
		user = &models.User{
			Phone:    phone,
			Name:     phone,
		}
		if err := s.userRepo.Create(ctx, user); err != nil {
			return nil, err
		}
	}

	// Generate tokens
	return s.generateAuthResponse(user)
}

// SocialLogin implements domain.AuthService
func (s *authService) SocialLogin(ctx context.Context, provider string, token string) (*models.AuthResponse, error) {
	// TODO: Implement social login verification
	return nil, errors.New("social login not implemented yet")
}

// RefreshToken implements domain.AuthService
func (s *authService) RefreshToken(ctx context.Context, refreshToken string) (*models.AuthResponse, error) {
	// Parse and validate refresh token
	claims := &jwt.RegisteredClaims{}
	token, err := jwt.ParseWithClaims(refreshToken, claims, func(token *jwt.Token) (interface{}, error) {
		return s.jwtSecret, nil
	})

	if err != nil || !token.Valid {
		return nil, errors.New("invalid refresh token")
	}

	// Get user
	userIDStr := claims.ID
	userID, _ := stringToUint(userIDStr)
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return nil, errors.New("user not found")
	}

	// Generate new tokens
	return s.generateAuthResponse(user)
}

// RevokeToken implements domain.AuthService
func (s *authService) RevokeToken(ctx context.Context, token string) error {
	// TODO: Implement token revocation (store in Redis/DB)
	return nil
}

// ValidateToken implements domain.AuthService
func (s *authService) ValidateToken(ctx context.Context, tokenString string) (*models.User, error) {
	// Parse token
	claims := &jwt.RegisteredClaims{}
	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return s.jwtSecret, nil
	})

	if err != nil || !token.Valid {
		return nil, errors.New("invalid token")
	}

	// Get user
	userIDStr := claims.ID
	userID, _ := stringToUint(userIDStr)
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return nil, errors.New("user not found")
	}

	return user, nil
}

// SendVerificationCode implements domain.AuthService
func (s *authService) SendVerificationCode(ctx context.Context, phone string) error {
	// Generate random 6-digit code
	code := "123456" // TODO: Generate random code

	// Send SMS
	return s.smsService.SendVerificationCode(ctx, phone, code)
}

// generateAuthResponse generates JWT tokens and auth response
func (s *authService) generateAuthResponse(user *models.User) (*models.AuthResponse, error) {
	// Generate access token (expires in 30 minutes)
	accessToken, err := s.generateToken(user, 30*time.Minute)
	if err != nil {
		return nil, err
	}

	// Generate refresh token (expires in 7 days)
	refreshToken, err := s.generateToken(user, 7*24*time.Hour)
	if err != nil {
		return nil, err
	}

	return &models.AuthResponse{
		User:         *user,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    1800, // 30 minutes in seconds
	}, nil
}

// generateToken generates a JWT token
func (s *authService) generateToken(user *models.User, duration time.Duration) (string, error) {
	claims := jwt.RegisteredClaims{
		ID:        uintToString(user.ID),
		Subject:   user.Email,
		ExpiresAt: jwt.NewNumericDate(time.Now().Add(duration)),
		IssuedAt:  jwt.NewNumericDate(time.Now()),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(s.jwtSecret)
}

// Helper functions
func uintToString(u uint) string {
	return fmt.Sprintf("%d", u)
}

func stringToUint(s string) (uint, error) {
	var u uint64
	_, err := fmt.Sscanf(s, "%d", &u)
	return uint(u), err
}

