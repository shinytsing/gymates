package repositories

import (
	"gymates-backend/config"
	"gymates-backend/models"

	"gorm.io/gorm"
)

// PostRepository handles all database operations for posts
type PostRepository struct {
	db *gorm.DB
}

// NewPostRepository creates a new post repository
func NewPostRepository() *PostRepository {
	return &PostRepository{
		db: config.DB,
	}
}

// Create creates a new post
func (r *PostRepository) Create(post *models.Post) error {
	return r.db.Create(post).Error
}

// GetByID retrieves a post by ID with user information
func (r *PostRepository) GetByID(id uint) (*models.Post, error) {
	var post models.Post
	err := r.db.Preload("User").First(&post, id).Error
	if err != nil {
		return nil, err
	}
	return &post, nil
}

// Update updates a post
func (r *PostRepository) Update(post *models.Post) error {
	return r.db.Save(post).Error
}

// Delete deletes a post (soft delete)
func (r *PostRepository) Delete(id uint) error {
	return r.db.Delete(&models.Post{}, id).Error
}

// List retrieves a paginated list of posts
func (r *PostRepository) List(page, limit int, typeFilter string, tab string) ([]models.Post, int64, error) {
	var posts []models.Post
	var total int64

	query := r.db.Model(&models.Post{}).Where("is_public = ?", true)

	// Filter by type if specified
	if typeFilter != "" {
		query = query.Where("type = ?", typeFilter)
	}

	// Apply tab-specific ordering
	switch tab {
	case "recommended":
		query = query.Order("likes DESC, created_at DESC")
	case "following":
		// TODO: Implement following logic
		query = query.Order("created_at DESC")
	case "nearby":
		// TODO: Implement nearby logic with location
		query = query.Order("created_at DESC")
	default:
		query = query.Order("created_at DESC")
	}

	// Get total count
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	offset := (page - 1) * limit
	err := query.Preload("User").Offset(offset).Limit(limit).Find(&posts).Error
	return posts, total, err
}

// GetByUserID retrieves all posts by a specific user
func (r *PostRepository) GetByUserID(userID uint, page, limit int) ([]models.Post, int64, error) {
	var posts []models.Post
	var total int64

	query := r.db.Model(&models.Post{}).Where("user_id = ?", userID)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * limit
	err := query.Preload("User").Order("created_at DESC").Offset(offset).Limit(limit).Find(&posts).Error
	return posts, total, err
}

// IncrementLikes increments the likes count for a post
func (r *PostRepository) IncrementLikes(id uint) error {
	return r.db.Model(&models.Post{}).Where("id = ?", id).Update("likes", gorm.Expr("likes + 1")).Error
}

// DecrementLikes decrements the likes count for a post
func (r *PostRepository) DecrementLikes(id uint) error {
	return r.db.Model(&models.Post{}).Where("id = ?", id).Update("likes", gorm.Expr("likes - 1")).Error
}

// IncrementComments increments the comments count for a post
func (r *PostRepository) IncrementComments(id uint) error {
	return r.db.Model(&models.Post{}).Where("id = ?", id).Update("comments", gorm.Expr("comments + 1")).Error
}

// DecrementComments decrements the comments count for a post
func (r *PostRepository) DecrementComments(id uint) error {
	return r.db.Model(&models.Post{}).Where("id = ?", id).Update("comments", gorm.Expr("comments - 1")).Error
}

// IncrementShares increments the shares count for a post
func (r *PostRepository) IncrementShares(id uint) error {
	return r.db.Model(&models.Post{}).Where("id = ?", id).Update("shares", gorm.Expr("shares + 1")).Error
}

