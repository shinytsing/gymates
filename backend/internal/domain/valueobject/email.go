package valueobject

import (
	"errors"
	"regexp"
	"strings"
)

var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)

// Email represents an email value object
type Email struct {
	value string
}

// NewEmail creates a new Email value object
func NewEmail(email string) (*Email, error) {
	email = strings.TrimSpace(strings.ToLower(email))
	
	if email == "" {
		return nil, errors.New("email cannot be empty")
	}
	
	if !emailRegex.MatchString(email) {
		return nil, errors.New("invalid email format")
	}
	
	return &Email{value: email}, nil
}

// String returns the email string
func (e *Email) String() string {
	return e.value
}

// Equals checks if two emails are equal
func (e *Email) Equals(other *Email) bool {
	return e.value == other.value
}

