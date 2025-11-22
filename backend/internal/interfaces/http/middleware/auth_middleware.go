package middleware

import (
	"gymates-backend/internal/domain/repository"
	"gymates-backend/internal/infrastructure/auth"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// AuthMiddleware creates an authentication middleware
func AuthMiddleware(jwtManager *auth.JWTManager, userRepo repository.UserRepository) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Extract token from Authorization header
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"error": gin.H{
					"code":    "UNAUTHORIZED",
					"message": "Authorization header is required",
				},
			})
			c.Abort()
			return
		}
		
		// Check Bearer prefix
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"error": gin.H{
					"code":    "UNAUTHORIZED",
					"message": "Invalid authorization header format",
				},
			})
			c.Abort()
			return
		}
		
		token := parts[1]
		
		// Validate token
		claims, err := jwtManager.ValidateToken(token)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"error": gin.H{
					"code":    "UNAUTHORIZED",
					"message": "Invalid or expired token",
				},
			})
			c.Abort()
			return
		}
		
		// Get user from database
		user, err := userRepo.GetByID(c.Request.Context(), claims.UserID)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"error": gin.H{
					"code":    "UNAUTHORIZED",
					"message": "User not found",
				},
			})
			c.Abort()
			return
		}
		
		// Check if user is active
		if !user.IsActive {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"error": gin.H{
					"code":    "UNAUTHORIZED",
					"message": "User account is not active",
				},
			})
			c.Abort()
			return
		}
		
		// Set user info in context
		c.Set("user_id", user.ID)
		c.Set("user", user)
		c.Set("claims", claims)
		
		c.Next()
	}
}

// OptionalAuthMiddleware creates an optional authentication middleware
func OptionalAuthMiddleware(jwtManager *auth.JWTManager, userRepo repository.UserRepository) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.Next()
			return
		}
		
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.Next()
			return
		}
		
		token := parts[1]
		claims, err := jwtManager.ValidateToken(token)
		if err != nil {
			c.Next()
			return
		}
		
		user, err := userRepo.GetByID(c.Request.Context(), claims.UserID)
		if err != nil {
			c.Next()
			return
		}
		
		if user.IsActive {
			c.Set("user_id", user.ID)
			c.Set("user", user)
			c.Set("claims", claims)
		}
		
		c.Next()
	}
}

