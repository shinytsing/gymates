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
)

// RegisterUserUseCase handles user registration
type RegisterUserUseCase struct {
	userRepo   repository.UserRepository
	jwtManager *auth.JWTManager
}

// NewRegisterUserUseCase creates a new register user use case
func NewRegisterUserUseCase(userRepo repository.UserRepository, jwtManager *auth.JWTManager) *RegisterUserUseCase {
	return &RegisterUserUseCase{
		userRepo:   userRepo,
		jwtManager: jwtManager,
	}
}

// Execute executes the register user use case
func (uc *RegisterUserUseCase) Execute(ctx context.Context, req *dto.RegisterRequest) (*dto.AuthResponse, error) {
	// Validate email
	email, err := valueobject.NewEmail(req.Email)
	if err != nil {
		return nil, err
	}
	
	// Check if user already exists
	exists, err := uc.userRepo.ExistsByEmail(ctx, email.String())
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, errors.New("user with this email already exists")
	}
	
	// Hash password
	password, err := valueobject.NewPassword(req.Password)
	if err != nil {
		return nil, err
	}
	
	// Create user entity
	user := &entity.User{
		Email:           email.String(),
		Password:        password.Hash(),
		Name:            req.Name,
		Provider:        "email",
		IsEmailVerified: false,
		IsActive:        true,
		CreatedAt:       time.Now(),
		UpdatedAt:       time.Now(),
	}
	
	// Save user
	err = uc.userRepo.Create(ctx, user)
	if err != nil {
		return nil, err
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

func (uc *RegisterUserUseCase) userToDTO(user *entity.User) *dto.UserDTO {
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

