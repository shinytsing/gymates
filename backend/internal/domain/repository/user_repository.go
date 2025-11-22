package repository

import (
	"context"
	"gymates-backend/internal/domain/entity"
)

// UserRepository defines the interface for user data access
type UserRepository interface {
	// Create creates a new user
	Create(ctx context.Context, user *entity.User) error
	
	// GetByID retrieves a user by ID
	GetByID(ctx context.Context, id uint) (*entity.User, error)
	
	// GetByEmail retrieves a user by email
	GetByEmail(ctx context.Context, email string) (*entity.User, error)
	
	// GetByPhone retrieves a user by phone number
	GetByPhone(ctx context.Context, phone string) (*entity.User, error)
	
	// GetByProvider retrieves a user by social provider
	GetByProvider(ctx context.Context, provider, providerID string) (*entity.User, error)
	
	// Update updates a user
	Update(ctx context.Context, user *entity.User) error
	
	// Delete deletes a user
	Delete(ctx context.Context, id uint) error
	
	// List retrieves users with pagination
	List(ctx context.Context, offset, limit int) ([]*entity.User, int64, error)
	
	// Exists checks if a user exists by email or phone
	ExistsByEmail(ctx context.Context, email string) (bool, error)
	ExistsByPhone(ctx context.Context, phone string) (bool, error)
	
	// UpdateLastLogin updates the user's last login time
	UpdateLastLogin(ctx context.Context, userID uint) error
	
	// UpdateStats updates user's statistics
	UpdateStats(ctx context.Context, userID uint, stats map[string]interface{}) error
}

