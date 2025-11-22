package gorm

import (
	"context"
	"gymates-backend/internal/domain/entity"
	"gymates-backend/internal/domain/repository"
	"gymates-backend/models"
	"time"

	"gorm.io/gorm"
)

type userRepository struct {
	db *gorm.DB
}

// NewUserRepository creates a new user repository
func NewUserRepository(db *gorm.DB) repository.UserRepository {
	return &userRepository{db: db}
}

func (r *userRepository) Create(ctx context.Context, user *entity.User) error {
	dbUser := r.entityToModel(user)
	return r.db.WithContext(ctx).Create(dbUser).Error
}

func (r *userRepository) GetByID(ctx context.Context, id uint) (*entity.User, error) {
	var user models.User
	err := r.db.WithContext(ctx).First(&user, id).Error
	if err != nil {
		return nil, err
	}
	return r.modelToEntity(&user), nil
}

func (r *userRepository) GetByEmail(ctx context.Context, email string) (*entity.User, error) {
	var user models.User
	err := r.db.WithContext(ctx).Where("email = ?", email).First(&user).Error
	if err != nil {
		return nil, err
	}
	return r.modelToEntity(&user), nil
}

func (r *userRepository) GetByPhone(ctx context.Context, phone string) (*entity.User, error) {
	var user models.User
	err := r.db.WithContext(ctx).Where("phone = ?", phone).First(&user).Error
	if err != nil {
		return nil, err
	}
	return r.modelToEntity(&user), nil
}

func (r *userRepository) GetByProvider(ctx context.Context, provider, providerID string) (*entity.User, error) {
	var user models.User
	err := r.db.WithContext(ctx).Where("provider = ? AND provider_id = ?", provider, providerID).First(&user).Error
	if err != nil {
		return nil, err
	}
	return r.modelToEntity(&user), nil
}

func (r *userRepository) Update(ctx context.Context, user *entity.User) error {
	dbUser := r.entityToModel(user)
	return r.db.WithContext(ctx).Save(dbUser).Error
}

func (r *userRepository) Delete(ctx context.Context, id uint) error {
	return r.db.WithContext(ctx).Delete(&models.User{}, id).Error
}

func (r *userRepository) List(ctx context.Context, offset, limit int) ([]*entity.User, int64, error) {
	var users []models.User
	var total int64
	
	err := r.db.WithContext(ctx).Model(&models.User{}).Count(&total).Error
	if err != nil {
		return nil, 0, err
	}
	
	err = r.db.WithContext(ctx).Offset(offset).Limit(limit).Find(&users).Error
	if err != nil {
		return nil, 0, err
	}
	
	entities := make([]*entity.User, len(users))
	for i, u := range users {
		entities[i] = r.modelToEntity(&u)
	}
	
	return entities, total, nil
}

func (r *userRepository) ExistsByEmail(ctx context.Context, email string) (bool, error) {
	var count int64
	err := r.db.WithContext(ctx).Model(&models.User{}).Where("email = ?", email).Count(&count).Error
	return count > 0, err
}

func (r *userRepository) ExistsByPhone(ctx context.Context, phone string) (bool, error) {
	var count int64
	err := r.db.WithContext(ctx).Model(&models.User{}).Where("phone = ?", phone).Count(&count).Error
	return count > 0, err
}

func (r *userRepository) UpdateLastLogin(ctx context.Context, userID uint) error {
	now := time.Now()
	return r.db.WithContext(ctx).Model(&models.User{}).Where("id = ?", userID).Update("last_login_at", now).Error
}

func (r *userRepository) UpdateStats(ctx context.Context, userID uint, stats map[string]interface{}) error {
	return r.db.WithContext(ctx).Model(&models.User{}).Where("id = ?", userID).Updates(stats).Error
}

// Helper methods to convert between entity and model
func (r *userRepository) entityToModel(e *entity.User) *models.User {
	// Map provider to LoginType
	loginType := e.Provider
	if loginType == "" {
		loginType = "email"
	}
	
	// Determine provider ID fields
	var appleID, googleID, wechatID string
	switch e.Provider {
	case "apple":
		appleID = e.ProviderID
	case "google":
		googleID = e.ProviderID
	case "wechat":
		wechatID = e.ProviderID
	}
	
	return &models.User{
		ID:          e.ID,
		Email:       e.Email,
		Phone:       e.Phone,
		Password:    e.Password,
		Name:        e.Name,
		Avatar:      e.Avatar,
		Bio:         e.Bio,
		Gender:      e.Gender,
		Height:      e.Height,
		Weight:      e.Weight,
		Location:    e.Location,
		LoginType:   loginType,
		AppleID:     appleID,
		GoogleID:    googleID,
		WechatID:    wechatID,
		IsGuest:     e.IsGuest(),
		LastLoginAt: e.LastLoginAt,
		CreatedAt:   e.CreatedAt,
		UpdatedAt:   e.UpdatedAt,
	}
}

func (r *userRepository) modelToEntity(m *models.User) *entity.User {
	// Determine provider and providerID from the model
	provider := m.LoginType
	providerID := ""
	
	switch provider {
	case "apple":
		providerID = m.AppleID
	case "google":
		providerID = m.GoogleID
	case "wechat":
		providerID = m.WechatID
	}
	
	return &entity.User{
		ID:              m.ID,
		Email:           m.Email,
		Phone:           m.Phone,
		Password:        m.Password,
		Name:            m.Name,
		Avatar:          m.Avatar,
		Bio:             m.Bio,
		Gender:          m.Gender,
		Height:          m.Height,
		Weight:          m.Weight,
		Location:        m.Location,
		Provider:        provider,
		ProviderID:      providerID,
		IsEmailVerified: m.Email != "",
		IsPhoneVerified: m.Phone != "",
		IsActive:        !m.IsGuest,
		CreatedAt:       m.CreatedAt,
		UpdatedAt:       m.UpdatedAt,
		LastLoginAt:     m.LastLoginAt,
	}
}

