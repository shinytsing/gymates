package repository

import (
	"context"
	"gymates-backend/internal/domain/entity"
)

// TokenRepository defines the interface for token data access
type TokenRepository interface {
	// Create creates a new token
	Create(ctx context.Context, token *entity.Token) error
	
	// GetByAccessToken retrieves a token by access token
	GetByAccessToken(ctx context.Context, accessToken string) (*entity.Token, error)
	
	// GetByRefreshToken retrieves a token by refresh token
	GetByRefreshToken(ctx context.Context, refreshToken string) (*entity.Token, error)
	
	// GetByUserID retrieves all tokens for a user
	GetByUserID(ctx context.Context, userID uint) ([]*entity.Token, error)
	
	// Update updates a token
	Update(ctx context.Context, token *entity.Token) error
	
	// Revoke revokes a token
	Revoke(ctx context.Context, tokenID uint) error
	
	// RevokeAllForUser revokes all tokens for a user
	RevokeAllForUser(ctx context.Context, userID uint) error
	
	// DeleteExpired deletes all expired tokens
	DeleteExpired(ctx context.Context) error
}

