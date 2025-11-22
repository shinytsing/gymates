package valueobject

import (
	"errors"
	"golang.org/x/crypto/bcrypt"
)

const (
	MinPasswordLength = 6
	MaxPasswordLength = 128
)

// Password represents a password value object
type Password struct {
	hash string
}

// NewPassword creates a new Password from plain text
func NewPassword(plainPassword string) (*Password, error) {
	if len(plainPassword) < MinPasswordLength {
		return nil, errors.New("password is too short")
	}
	
	if len(plainPassword) > MaxPasswordLength {
		return nil, errors.New("password is too long")
	}
	
	hash, err := bcrypt.GenerateFromPassword([]byte(plainPassword), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}
	
	return &Password{hash: string(hash)}, nil
}

// NewPasswordFromHash creates a Password from an existing hash
func NewPasswordFromHash(hash string) *Password {
	return &Password{hash: hash}
}

// Hash returns the password hash
func (p *Password) Hash() string {
	return p.hash
}

// Compare compares the password with a plain text password
func (p *Password) Compare(plainPassword string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(p.hash), []byte(plainPassword))
	return err == nil
}

