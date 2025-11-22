package auth

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

var (
	ErrInvalidToken = errors.New("invalid token")
	ErrExpiredToken = errors.New("token has expired")
)

// JWTManager manages JWT token generation and validation
type JWTManager struct {
	secretKey             string
	accessTokenDuration   time.Duration
	refreshTokenDuration  time.Duration
}

// Claims represents JWT claims
type Claims struct {
	UserID   uint   `json:"user_id"`
	Email    string `json:"email"`
	Name     string `json:"name"`
	Provider string `json:"provider"`
	jwt.RegisteredClaims
}

// NewJWTManager creates a new JWT manager
func NewJWTManager(secretKey string, accessDuration, refreshDuration time.Duration) *JWTManager {
	return &JWTManager{
		secretKey:            secretKey,
		accessTokenDuration:  accessDuration,
		refreshTokenDuration: refreshDuration,
	}
}

// GenerateAccessToken generates an access token
func (m *JWTManager) GenerateAccessToken(userID uint, email, name, provider string) (string, time.Time, error) {
	expiresAt := time.Now().Add(m.accessTokenDuration)
	
	claims := &Claims{
		UserID:   userID,
		Email:    email,
		Name:     name,
		Provider: provider,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expiresAt),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
			Issuer:    "gymates-api",
		},
	}
	
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(m.secretKey))
	if err != nil {
		return "", time.Time{}, err
	}
	
	return tokenString, expiresAt, nil
}

// GenerateRefreshToken generates a refresh token
func (m *JWTManager) GenerateRefreshToken(userID uint) (string, time.Time, error) {
	expiresAt := time.Now().Add(m.refreshTokenDuration)
	
	claims := &Claims{
		UserID: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expiresAt),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "gymates-api",
		},
	}
	
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(m.secretKey))
	if err != nil {
		return "", time.Time{}, err
	}
	
	return tokenString, expiresAt, nil
}

// ValidateToken validates a token and returns claims
func (m *JWTManager) ValidateToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrInvalidToken
		}
		return []byte(m.secretKey), nil
	})
	
	if err != nil {
		return nil, err
	}
	
	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, ErrInvalidToken
	}
	
	// Check if token is expired
	if claims.ExpiresAt != nil && claims.ExpiresAt.Before(time.Now()) {
		return nil, ErrExpiredToken
	}
	
	return claims, nil
}

// GetAccessTokenDuration returns access token duration in seconds
func (m *JWTManager) GetAccessTokenDuration() int64 {
	return int64(m.accessTokenDuration.Seconds())
}

