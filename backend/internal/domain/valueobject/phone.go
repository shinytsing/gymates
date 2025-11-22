package valueobject

import (
	"errors"
	"regexp"
	"strings"
)

var phoneRegex = regexp.MustCompile(`^1[3-9]\d{9}$`) // Chinese phone number format

// Phone represents a phone number value object
type Phone struct {
	value string
}

// NewPhone creates a new Phone value object
func NewPhone(phone string) (*Phone, error) {
	phone = strings.TrimSpace(phone)
	
	if phone == "" {
		return nil, errors.New("phone number cannot be empty")
	}
	
	if !phoneRegex.MatchString(phone) {
		return nil, errors.New("invalid phone number format")
	}
	
	return &Phone{value: phone}, nil
}

// String returns the phone string
func (p *Phone) String() string {
	return p.value
}

// Equals checks if two phone numbers are equal
func (p *Phone) Equals(other *Phone) bool {
	return p.value == other.value
}

// Masked returns a masked phone number (e.g., 138****1234)
func (p *Phone) Masked() string {
	if len(p.value) != 11 {
		return p.value
	}
	return p.value[:3] + "****" + p.value[7:]
}

