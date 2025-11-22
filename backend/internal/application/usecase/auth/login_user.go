package auth

import (
	"context"
	"errors"
	"time"

	"gymates-backend/internal/application/dto"
	"gymates-backend/internal/domain/entity"
	"gymates-backend/internal/domain/repository"
	"gymates-backend/internal/domain/valueobject"
	"gymates-backend/internal/infrastructure/auth"
	
	"gorm.io/gorm"
)

// LoginUserUseCase handles user login
type LoginUserUseCase struct {
	userRepo   repository.UserRepository
	jwtManager *auth.JWTManager
}

// NewLoginUserUseCase creates a new login user use case
func NewLoginUserUseCase(userRepo repository.UserRepository, jwtManager *auth.JWTManager) *LoginUserUseCase {
	return &LoginUserUseCase{
		userRepo:   userRepo,
		jwtManager: jwtManager,
	}
}

// Execute executes the login user use case
func (uc *LoginUserUseCase) Execute(ctx context.Context, req *dto.LoginRequest) (*dto.AuthResponse, error) {
	// Validate email
	email, err := valueobject.NewEmail(req.Email)
	if err != nil {
		return nil, err
	}
	
	// Get user by email
	user, err := uc.userRepo.GetByEmail(ctx, email.String())
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("invalid email or password")
		}
		return nil, err
	}
	
	// Check if user is active
	if !user.CanLogin() {
		return nil, errors.New("user account is not active")
	}
	
	// Verify password
	password := valueobject.NewPasswordFromHash(user.Password)
	if !password.Compare(req.Password) {
		return nil, errors.New("invalid email or password")
	}
	
	// Update last login
	err = uc.userRepo.UpdateLastLogin(ctx, user.ID)
	if err != nil {
		// Log error but don't fail the login
	}
	
	// Generate tokens
	accessToken, expiresAt, err := uc.jwtManager.GenerateAccessToken(user.ID, user.Email, user.Name, user.Provider)
	if err != nil {
		return nil, err
	}
	
	refreshToken, _, err := uc.jwtManager.GenerateRefreshToken(user.ID)
	if err != nil {
		return nil, err
	}
	
	// Build response
	return &dto.AuthResponse{
		User:         uc.userToDTO(user),
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		TokenType:    "Bearer",
		ExpiresIn:    time.Until(expiresAt).Milliseconds() / 1000,
	}, nil
}

func (uc *LoginUserUseCase) userToDTO(user *entity.User) *dto.UserDTO {
	return &dto.UserDTO{
		ID:              user.ID,
		Email:           user.Email,
		Phone:           user.Phone,
		Name:            user.Name,
		Avatar:          user.Avatar,
		Bio:             user.Bio,
		Gender:          user.Gender,
		Birthday:        user.Birthday,
		Height:          user.Height,
		Weight:          user.Weight,
		Location:        user.Location,
		FollowersCount:  user.FollowersCount,
		FollowingCount:  user.FollowingCount,
		MatesCount:      user.MatesCount,
		PostsCount:      user.PostsCount,
		TotalWorkouts:   user.TotalWorkouts,
		TotalDuration:   user.TotalDuration,
		TotalCalories:   user.TotalCalories,
		CurrentStreak:   user.CurrentStreak,
		IsEmailVerified: user.IsEmailVerified,
		IsPhoneVerified: user.IsPhoneVerified,
		CreatedAt:       user.CreatedAt,
	}
}

