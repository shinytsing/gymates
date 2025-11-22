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
	"gymates-backend/internal/infrastructure/service/sms"
	
	"gorm.io/gorm"
)

// PhoneLoginUseCase handles phone-based login
type PhoneLoginUseCase struct {
	userRepo       repository.UserRepository
	jwtManager     *auth.JWTManager
	verificationSvc *sms.VerificationService
}

// NewPhoneLoginUseCase creates a new phone login use case
func NewPhoneLoginUseCase(
	userRepo repository.UserRepository,
	jwtManager *auth.JWTManager,
	verificationSvc *sms.VerificationService,
) *PhoneLoginUseCase {
	return &PhoneLoginUseCase{
		userRepo:       userRepo,
		jwtManager:     jwtManager,
		verificationSvc: verificationSvc,
	}
}

// Execute executes the phone login use case
func (uc *PhoneLoginUseCase) Execute(ctx context.Context, req *dto.PhoneLoginRequest) (*dto.AuthResponse, error) {
	// Validate phone
	phone, err := valueobject.NewPhone(req.Phone)
	if err != nil {
		return nil, err
	}
	
	// Verify code
	valid, err := uc.verificationSvc.VerifyCode(ctx, phone.String(), req.Code)
	if err != nil || !valid {
		return nil, errors.New("invalid or expired verification code")
	}
	
	// Get user by phone
	user, err := uc.userRepo.GetByPhone(ctx, phone.String())
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("user not found, please register first")
		}
		return nil, err
	}
	
	// Check if user is active
	if !user.CanLogin() {
		return nil, errors.New("user account is not active")
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

func (uc *PhoneLoginUseCase) userToDTO(user *entity.User) *dto.UserDTO {
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

