package repositories

import (
	"gymates-backend/config"
	"gymates-backend/models"

	"gorm.io/gorm"
)

// TrainingRepository handles all database operations for training plans and exercises
type TrainingRepository struct {
	db *gorm.DB
}

// NewTrainingRepository creates a new training repository
func NewTrainingRepository() *TrainingRepository {
	return &TrainingRepository{
		db: config.DB,
	}
}

// CreatePlan creates a new training plan
func (r *TrainingRepository) CreatePlan(plan *models.TrainingPlan) error {
	return r.db.Create(plan).Error
}

// GetPlanByID retrieves a training plan by ID with exercises
func (r *TrainingRepository) GetPlanByID(id uint) (*models.TrainingPlan, error) {
	var plan models.TrainingPlan
	err := r.db.Preload("Exercises").Preload("User").First(&plan, id).Error
	if err != nil {
		return nil, err
	}
	return &plan, nil
}

// UpdatePlan updates a training plan
func (r *TrainingRepository) UpdatePlan(plan *models.TrainingPlan) error {
	return r.db.Save(plan).Error
}

// DeletePlan deletes a training plan (soft delete)
func (r *TrainingRepository) DeletePlan(id uint) error {
	return r.db.Delete(&models.TrainingPlan{}, id).Error
}

// ListPlans retrieves a paginated list of training plans
func (r *TrainingRepository) ListPlans(page, limit int, userID *uint, isPublic *bool) ([]models.TrainingPlan, int64, error) {
	var plans []models.TrainingPlan
	var total int64

	query := r.db.Model(&models.TrainingPlan{})

	if userID != nil {
		query = query.Where("user_id = ?", *userID)
	}

	if isPublic != nil {
		query = query.Where("is_public = ?", *isPublic)
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * limit
	err := query.Preload("User").Order("created_at DESC").Offset(offset).Limit(limit).Find(&plans).Error
	return plans, total, err
}

// CreateExercise creates a new exercise
func (r *TrainingRepository) CreateExercise(exercise *models.Exercise) error {
	return r.db.Create(exercise).Error
}

// GetExerciseByID retrieves an exercise by ID
func (r *TrainingRepository) GetExerciseByID(id uint) (*models.Exercise, error) {
	var exercise models.Exercise
	err := r.db.First(&exercise, id).Error
	if err != nil {
		return nil, err
	}
	return &exercise, nil
}

// UpdateExercise updates an exercise
func (r *TrainingRepository) UpdateExercise(exercise *models.Exercise) error {
	return r.db.Save(exercise).Error
}

// DeleteExercise deletes an exercise (soft delete)
func (r *TrainingRepository) DeleteExercise(id uint) error {
	return r.db.Delete(&models.Exercise{}, id).Error
}

// GetExercisesByPlanID retrieves all exercises for a training plan
func (r *TrainingRepository) GetExercisesByPlanID(planID uint) ([]models.Exercise, error) {
	var exercises []models.Exercise
	err := r.db.Where("training_plan_id = ?", planID).Order("\"order\" ASC").Find(&exercises).Error
	return exercises, err
}

// CreateWorkoutSession creates a new workout session
func (r *TrainingRepository) CreateWorkoutSession(session *models.WorkoutSession) error {
	return r.db.Create(session).Error
}

// GetWorkoutSessionByID retrieves a workout session by ID
func (r *TrainingRepository) GetWorkoutSessionByID(id uint) (*models.WorkoutSession, error) {
	var session models.WorkoutSession
	err := r.db.Preload("User").Preload("TrainingPlan").First(&session, id).Error
	if err != nil {
		return nil, err
	}
	return &session, nil
}

// UpdateWorkoutSession updates a workout session
func (r *TrainingRepository) UpdateWorkoutSession(session *models.WorkoutSession) error {
	return r.db.Save(session).Error
}

// GetWorkoutSessionsByUserID retrieves all workout sessions for a user
func (r *TrainingRepository) GetWorkoutSessionsByUserID(userID uint, page, limit int) ([]models.WorkoutSession, int64, error) {
	var sessions []models.WorkoutSession
	var total int64

	query := r.db.Model(&models.WorkoutSession{}).Where("user_id = ?", userID)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * limit
	err := query.Preload("TrainingPlan").Order("start_time DESC").Offset(offset).Limit(limit).Find(&sessions).Error
	return sessions, total, err
}

