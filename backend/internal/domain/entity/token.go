package entity

import "time"

// Token represents an authentication token
type Token struct {
	ID           uint
	UserID       uint
	AccessToken  string
	RefreshToken string
	TokenType    string // Bearer
	ExpiresAt    time.Time
	RefreshExpiresAt time.Time
	IsRevoked    bool
	CreatedAt    time.Time
}

// IsExpired checks if the access token is expired
func (t *Token) IsExpired() bool {
	return time.Now().After(t.ExpiresAt)
}

// IsRefreshExpired checks if the refresh token is expired
func (t *Token) IsRefreshExpired() bool {
	return time.Now().After(t.RefreshExpiresAt)
}

// CanRefresh checks if the token can be refreshed
func (t *Token) CanRefresh() bool {
	return !t.IsRevoked && !t.IsRefreshExpired()
}

// Revoke revokes the token
func (t *Token) Revoke() {
	t.IsRevoked = true
}

