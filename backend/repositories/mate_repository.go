package repositories

import (
	"gymates-backend/config"
	"gymates-backend/models"

	"gorm.io/gorm"
)

// MateRepository handles all database operations for mate relationships
type MateRepository struct {
	db *gorm.DB
}

// NewMateRepository creates a new mate repository
func NewMateRepository() *MateRepository {
	return &MateRepository{
		db: config.DB,
	}
}

// CreateMateRequest creates a new mate request
func (r *MateRepository) CreateMateRequest(mate *models.Mate) error {
	return r.db.Create(mate).Error
}

// GetMateByID retrieves a mate relationship by ID
func (r *MateRepository) GetMateByID(id uint) (*models.Mate, error) {
	var mate models.Mate
	err := r.db.Preload("User").Preload("MateUser").First(&mate, id).Error
	if err != nil {
		return nil, err
	}
	return &mate, nil
}

// UpdateMateStatus updates the status of a mate relationship
func (r *MateRepository) UpdateMateStatus(id uint, status string) error {
	return r.db.Model(&models.Mate{}).Where("id = ?", id).Update("status", status).Error
}

// GetMatesByUserID retrieves all mates for a user
func (r *MateRepository) GetMatesByUserID(userID uint, status *string) ([]models.Mate, error) {
	var mates []models.Mate
	
	query := r.db.Where("user_id = ? OR mate_id = ?", userID, userID)
	
	if status != nil {
		query = query.Where("status = ?", *status)
	}
	
	err := query.Preload("User").Preload("MateUser").Order("created_at DESC").Find(&mates).Error
	return mates, err
}

// GetPendingRequests retrieves pending mate requests for a user
func (r *MateRepository) GetPendingRequests(userID uint) ([]models.Mate, error) {
	var mates []models.Mate
	err := r.db.Where("mate_id = ? AND status = ?", userID, "pending").
		Preload("User").
		Order("created_at DESC").
		Find(&mates).Error
	return mates, err
}

// CheckExistingRelationship checks if a mate relationship already exists
func (r *MateRepository) CheckExistingRelationship(userID, mateUserID uint) (*models.Mate, error) {
	var mate models.Mate
	err := r.db.Where(
		"(user_id = ? AND mate_id = ?) OR (user_id = ? AND mate_id = ?)",
		userID, mateUserID, mateUserID, userID,
	).First(&mate).Error
	
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	
	return &mate, err
}

// DeleteMate deletes a mate relationship (soft delete)
func (r *MateRepository) DeleteMate(id uint) error {
	return r.db.Delete(&models.Mate{}, id).Error
}

// FindPotentialMates finds potential mates based on preferences
func (r *MateRepository) FindPotentialMates(userID uint, preferences map[string]interface{}) ([]models.User, error) {
	var users []models.User
	
	query := r.db.Where("id != ? AND looking_for_mate = ?", userID, true)
	
	// Apply preference filters
	if location, ok := preferences["location"].(string); ok && location != "" {
		query = query.Where("location LIKE ?", "%"+location+"%")
	}
	
	if trainingTypes, ok := preferences["training_types"].(string); ok && trainingTypes != "" {
		query = query.Where("training_types LIKE ?", "%"+trainingTypes+"%")
	}
	
	if experience, ok := preferences["experience"].(string); ok && experience != "" {
		query = query.Where("experience = ?", experience)
	}
	
	err := query.Limit(20).Find(&users).Error
	return users, err
}

