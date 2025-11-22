package sms

import (
	"context"
	"errors"
	"fmt"
	"math/rand"
	"sync"
	"time"
)

// VerificationService handles SMS verification codes
type VerificationService struct {
	codes    map[string]*VerificationCode
	mu       sync.RWMutex
	codeExpiry time.Duration
}

// VerificationCode represents a verification code
type VerificationCode struct {
	Code      string
	Phone     string
	ExpiresAt time.Time
	Attempts  int
}

// NewVerificationService creates a new verification service
func NewVerificationService(codeExpiry time.Duration) *VerificationService {
	service := &VerificationService{
		codes:      make(map[string]*VerificationCode),
		codeExpiry: codeExpiry,
	}
	
	// Start cleanup goroutine
	go service.cleanupExpiredCodes()
	
	return service
}

// SendCode sends a verification code to a phone number
func (s *VerificationService) SendCode(ctx context.Context, phone string) (string, error) {
	code := s.generateCode()
	
	s.mu.Lock()
	s.codes[phone] = &VerificationCode{
		Code:      code,
		Phone:     phone,
		ExpiresAt: time.Now().Add(s.codeExpiry),
		Attempts:  0,
	}
	s.mu.Unlock()
	
	// In production, integrate with SMS provider (Twilio, Aliyun, etc.)
	// For now, just log the code
	fmt.Printf("📱 SMS Code for %s: %s (expires in %v)\n", phone, code, s.codeExpiry)
	
	return code, nil
}

// VerifyCode verifies a code for a phone number
func (s *VerificationService) VerifyCode(ctx context.Context, phone, code string) (bool, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	
	storedCode, exists := s.codes[phone]
	if !exists {
		return false, errors.New("no verification code found for this phone number")
	}
	
	// Check if expired
	if time.Now().After(storedCode.ExpiresAt) {
		delete(s.codes, phone)
		return false, errors.New("verification code has expired")
	}
	
	// Check attempts
	storedCode.Attempts++
	if storedCode.Attempts > 5 {
		delete(s.codes, phone)
		return false, errors.New("too many failed attempts")
	}
	
	// Verify code
	if storedCode.Code != code {
		return false, errors.New("invalid verification code")
	}
	
	// Success - remove code
	delete(s.codes, phone)
	return true, nil
}

// generateCode generates a 6-digit verification code
func (s *VerificationService) generateCode() string {
	rand.Seed(time.Now().UnixNano())
	code := rand.Intn(900000) + 100000 // Generate 6-digit code
	return fmt.Sprintf("%06d", code)
}

// cleanupExpiredCodes periodically removes expired codes
func (s *VerificationService) cleanupExpiredCodes() {
	ticker := time.NewTicker(1 * time.Minute)
	defer ticker.Stop()
	
	for range ticker.C {
		s.mu.Lock()
		now := time.Now()
		for phone, code := range s.codes {
			if now.After(code.ExpiresAt) {
				delete(s.codes, phone)
			}
		}
		s.mu.Unlock()
	}
}

