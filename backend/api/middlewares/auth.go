package middlewares

import (
	"fmt"
	"net/http"
	"strings"
	"time"

	"gymates-backend/config"
	"gymates-backend/models"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

// JWTConfig JWT配置
type JWTConfig struct {
	SecretKey string
	ExpiresIn time.Duration
}

var jwtConfig = JWTConfig{
	SecretKey: "gymates-secret-key", // 生产环境应该从环境变量获取
	ExpiresIn: 30 * time.Minute,     // Access Token: 30分钟
}

// Refresh Token 配置
const (
	RefreshTokenExpiry = 7 * 24 * time.Hour // Refresh Token: 7天
)

// Claims JWT声明
type Claims struct {
	UserID uint   `json:"user_id"`
	Email  string `json:"email"`
	jwt.RegisteredClaims
}

// GenerateToken 生成JWT token
func GenerateToken(user *models.User) (string, error) {
	claims := Claims{
		UserID: user.ID,
		Email:  user.Email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(jwtConfig.ExpiresIn)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(jwtConfig.SecretKey))
}

// ValidateToken 验证JWT token
func ValidateToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(jwtConfig.SecretKey), nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims, nil
	}

	return nil, jwt.ErrTokenMalformed
}

// GenerateRefreshToken 生成刷新令牌
func GenerateRefreshToken(user *models.User) (string, error) {
	claims := Claims{
		UserID: user.ID,
		Email:  user.Email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(RefreshTokenExpiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(jwtConfig.SecretKey))
	if err != nil {
		return "", err
	}

	// 将刷新令牌保存到数据库
	refreshToken := models.RefreshToken{
		UserID:    user.ID,
		Token:     tokenString,
		ExpiresAt: time.Now().Add(RefreshTokenExpiry),
	}

	if err := config.DB.Create(&refreshToken).Error; err != nil {
		return "", err
	}

	return tokenString, nil
}

// ValidateRefreshToken 验证刷新令牌
func ValidateRefreshToken(tokenString string) (*models.User, error) {
	// 验证JWT签名
	claims, err := ValidateToken(tokenString)
	if err != nil {
		return nil, err
	}

	// 检查数据库中的刷新令牌
	var refreshToken models.RefreshToken
	if err := config.DB.Where("token = ? AND is_revoked = false", tokenString).First(&refreshToken).Error; err != nil {
		return nil, fmt.Errorf("refresh token not found or revoked")
	}

	// 检查是否过期
	if time.Now().After(refreshToken.ExpiresAt) {
		return nil, fmt.Errorf("refresh token expired")
	}

	// 获取用户信息
	var user models.User
	if err := config.DB.First(&user, claims.UserID).Error; err != nil {
		return nil, err
	}

	return &user, nil
}

// RevokeRefreshToken 撤销刷新令牌
func RevokeRefreshToken(tokenString string) error {
	now := time.Now()
	return config.DB.Model(&models.RefreshToken{}).
		Where("token = ?", tokenString).
		Updates(map[string]interface{}{
			"is_revoked": true,
			"revoked_at": &now,
		}).Error
}

// AuthMiddleware JWT认证中间件
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, models.ErrorResponse{
				Success: false,
				Message: "缺少认证token",
				Error:   "Authorization header is required",
				Code:    http.StatusUnauthorized,
			})
			c.Abort()
			return
		}

		// 检查Bearer前缀
		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == authHeader {
			c.JSON(http.StatusUnauthorized, models.ErrorResponse{
				Success: false,
				Message: "无效的token格式",
				Error:   "Bearer token format required",
				Code:    http.StatusUnauthorized,
			})
			c.Abort()
			return
		}

		// 验证token
		claims, err := ValidateToken(tokenString)
		if err != nil {
			c.JSON(http.StatusUnauthorized, models.ErrorResponse{
				Success: false,
				Message: "无效的token",
				Error:   err.Error(),
				Code:    http.StatusUnauthorized,
			})
			c.Abort()
			return
		}

		// 检查用户是否存在
		var user models.User
		if err := config.DB.First(&user, claims.UserID).Error; err != nil {
			c.JSON(http.StatusUnauthorized, models.ErrorResponse{
				Success: false,
				Message: "用户不存在",
				Error:   "User not found",
				Code:    http.StatusUnauthorized,
			})
			c.Abort()
			return
		}

		// 将用户信息存储到上下文中
		c.Set("user", &user)
		c.Set("user_id", user.ID)
		c.Next()
	}
}

// OptionalAuthMiddleware 可选认证中间件
func OptionalAuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.Next()
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == authHeader {
			c.Next()
			return
		}

		claims, err := ValidateToken(tokenString)
		if err != nil {
			c.Next()
			return
		}

		var user models.User
		if err := config.DB.First(&user, claims.UserID).Error; err == nil {
			c.Set("user", &user)
			c.Set("user_id", user.ID)
		}

		c.Next()
	}
}

