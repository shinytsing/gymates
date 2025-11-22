package middleware

import (
	"context"
	"fmt"
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"golang.org/x/time/rate"
)

// RequestIDMiddleware adds a unique request ID to each request
func RequestIDMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		requestID := c.GetHeader("X-Request-ID")
		if requestID == "" {
			requestID = uuid.New().String()
		}
		c.Set("request_id", requestID)
		c.Header("X-Request-ID", requestID)
		c.Next()
	}
}

// RecoveryMiddleware handles panics and returns proper error response
func RecoveryMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if err := recover(); err != nil {
				requestID, _ := c.Get("request_id")
				
				// Log the error
				fmt.Printf("[PANIC] Request ID: %v, Error: %v\n", requestID, err)

				c.JSON(http.StatusInternalServerError, gin.H{
					"success":    false,
					"message":    "Internal server error",
					"request_id": requestID,
				})
				c.Abort()
			}
		}()
		c.Next()
	}
}

// ErrorHandlerMiddleware handles errors consistently
func ErrorHandlerMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()

		// Check if there are any errors
		if len(c.Errors) > 0 {
			err := c.Errors.Last()
			requestID, _ := c.Get("request_id")

			// Log the error
			fmt.Printf("[ERROR] Request ID: %v, Error: %v\n", requestID, err.Error())

			// Return error response
			c.JSON(c.Writer.Status(), gin.H{
				"success":    false,
				"message":    err.Error(),
				"request_id": requestID,
			})
		}
	}
}

// RateLimiter holds rate limiting state
type RateLimiter struct {
	limiters map[string]*rate.Limiter
	mu       sync.RWMutex
	rate     rate.Limit
	burst    int
}

// NewRateLimiter creates a new rate limiter
func NewRateLimiter(r rate.Limit, b int) *RateLimiter {
	return &RateLimiter{
		limiters: make(map[string]*rate.Limiter),
		rate:     r,
		burst:    b,
	}
}

// GetLimiter returns a rate limiter for the given key
func (rl *RateLimiter) GetLimiter(key string) *rate.Limiter {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	limiter, exists := rl.limiters[key]
	if !exists {
		limiter = rate.NewLimiter(rl.rate, rl.burst)
		rl.limiters[key] = limiter
	}

	return limiter
}

// RateLimitMiddleware limits requests per IP
func RateLimitMiddleware(requestsPerSecond int, burst int) gin.HandlerFunc {
	limiter := NewRateLimiter(rate.Limit(requestsPerSecond), burst)

	return func(c *gin.Context) {
		key := c.ClientIP()
		rl := limiter.GetLimiter(key)

		if !rl.Allow() {
			c.JSON(http.StatusTooManyRequests, gin.H{
				"success": false,
				"message": "Too many requests. Please try again later.",
			})
			c.Abort()
			return
		}

		c.Next()
	}
}

// TimeoutMiddleware adds request timeout
func TimeoutMiddleware(timeout time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Wrap the request context with timeout
		ctx, cancel := context.WithTimeout(c.Request.Context(), timeout)
		defer cancel()

		c.Request = c.Request.WithContext(ctx)

		// Channel to signal when processing is done
		done := make(chan struct{})

		go func() {
			c.Next()
			close(done)
		}()

		select {
		case <-done:
			// Request completed successfully
		case <-ctx.Done():
			// Request timed out
			c.JSON(http.StatusGatewayTimeout, gin.H{
				"success": false,
				"message": "Request timeout",
			})
			c.Abort()
		}
	}
}

// CORSMiddleware handles CORS
func CORSMiddleware(allowOrigins []string) gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		
		// Check if origin is allowed
		allowed := false
		for _, allowedOrigin := range allowOrigins {
			if allowedOrigin == "*" || allowedOrigin == origin {
				allowed = true
				break
			}
		}

		if allowed {
			if origin != "" {
				c.Header("Access-Control-Allow-Origin", origin)
			} else {
				c.Header("Access-Control-Allow-Origin", "*")
			}
			c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH")
			c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Accept, Authorization, X-Requested-With")
			c.Header("Access-Control-Expose-Headers", "Content-Length, X-Request-ID")
			c.Header("Access-Control-Allow-Credentials", "true")
			c.Header("Access-Control-Max-Age", "86400")
		}

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}

// LoggerMiddleware logs HTTP requests
func LoggerMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Start timer
		start := time.Now()
		path := c.Request.URL.Path
		raw := c.Request.URL.RawQuery

		// Process request
		c.Next()

		// Calculate latency
		latency := time.Since(start)

		// Get request ID
		requestID, _ := c.Get("request_id")

		// Log format
		if raw != "" {
			path = path + "?" + raw
		}

		fmt.Printf("[%s] %s | %d | %v | %s | %s | %v\n",
			time.Now().Format("2006/01/02 15:04:05"),
			requestID,
			c.Writer.Status(),
			latency,
			c.ClientIP(),
			c.Request.Method,
			path,
		)
	}
}

