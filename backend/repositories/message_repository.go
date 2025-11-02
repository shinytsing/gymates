package repositories

import (
	"gymates-backend/config"
	"gymates-backend/models"

	"gorm.io/gorm"
)

// MessageRepository handles all database operations for messages
type MessageRepository struct {
	db *gorm.DB
}

// NewMessageRepository creates a new message repository
func NewMessageRepository() *MessageRepository {
	return &MessageRepository{
		db: config.DB,
	}
}

// CreateMessage creates a new message
func (r *MessageRepository) CreateMessage(message *models.Message) error {
	return r.db.Create(message).Error
}

// GetMessageByID retrieves a message by ID
func (r *MessageRepository) GetMessageByID(id uint) (*models.Message, error) {
	var message models.Message
	err := r.db.Preload("Sender").Preload("Receiver").First(&message, id).Error
	if err != nil {
		return nil, err
	}
	return &message, nil
}

// GetConversation retrieves messages between two users
func (r *MessageRepository) GetConversation(user1ID, user2ID uint, page, limit int) ([]models.Message, int64, error) {
	var messages []models.Message
	var total int64

	query := r.db.Model(&models.Message{}).Where(
		"(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
		user1ID, user2ID, user2ID, user1ID,
	)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * limit
	err := query.Preload("Sender").Preload("Receiver").
		Order("created_at DESC").
		Offset(offset).Limit(limit).Find(&messages).Error
	
	return messages, total, err
}

// GetUserConversations retrieves all conversation partners for a user
func (r *MessageRepository) GetUserConversations(userID uint) ([]models.User, error) {
	var users []models.User
	
	// Get distinct conversation partners
	err := r.db.Raw(`
		SELECT DISTINCT u.* FROM users u
		INNER JOIN (
			SELECT DISTINCT 
				CASE 
					WHEN sender_id = ? THEN receiver_id 
					ELSE sender_id 
				END as partner_id
			FROM messages
			WHERE sender_id = ? OR receiver_id = ?
		) as conversations ON u.id = conversations.partner_id
		ORDER BY u.name ASC
	`, userID, userID, userID).Scan(&users).Error
	
	return users, err
}

// MarkAsRead marks messages as read
func (r *MessageRepository) MarkAsRead(messageIDs []uint) error {
	return r.db.Model(&models.Message{}).
		Where("id IN ?", messageIDs).
		Update("is_read", true).Error
}

// GetUnreadCount gets the count of unread messages for a user
func (r *MessageRepository) GetUnreadCount(userID uint) (int64, error) {
	var count int64
	err := r.db.Model(&models.Message{}).
		Where("receiver_id = ? AND is_read = ?", userID, false).
		Count(&count).Error
	return count, err
}

// DeleteMessage deletes a message (soft delete)
func (r *MessageRepository) DeleteMessage(id uint) error {
	return r.db.Delete(&models.Message{}, id).Error
}

