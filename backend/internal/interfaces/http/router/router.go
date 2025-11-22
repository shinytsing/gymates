package router

import (
	"gymates-backend/internal/interfaces/http/handler"
	"gymates-backend/internal/interfaces/http/middleware"
	"net/http"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

// Router represents the HTTP router
type Router struct {
	engine      *gin.Engine
	authHandler *handler.AuthHandler
	authMiddleware gin.HandlerFunc
	optionalAuthMiddleware gin.HandlerFunc
}

// Config holds router configuration
type Config struct {
	AuthHandler            *handler.AuthHandler
	AuthMiddleware         gin.HandlerFunc
	OptionalAuthMiddleware gin.HandlerFunc
}

// NewRouter creates a new router
func NewRouter(config *Config) *Router {
	r := &Router{
		engine:                 gin.New(),
		authHandler:            config.AuthHandler,
		authMiddleware:         config.AuthMiddleware,
		optionalAuthMiddleware: config.OptionalAuthMiddleware,
	}
	
	r.setupMiddleware()
	r.setupRoutes()
	
	return r
}

// setupMiddleware sets up global middleware
func (r *Router) setupMiddleware() {
	// Recovery middleware
	r.engine.Use(gin.Recovery())
	
	// Logger middleware
	r.engine.Use(gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		return ""
	}))
	
	// CORS middleware
	r.engine.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))
	
	// Request ID middleware
	r.engine.Use(middleware.RequestIDMiddleware())
}

// setupRoutes sets up all routes
func (r *Router) setupRoutes() {
	// Health check
	r.engine.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "healthy",
			"version": "1.0.0",
			"time":    time.Now().Format(time.RFC3339),
		})
	})
	
	// API v1 routes
	v1 := r.engine.Group("/api/v1")
	{
		r.setupAuthRoutes(v1)
		// Other route groups will be added here
	}
}

// setupAuthRoutes sets up authentication routes
func (r *Router) setupAuthRoutes(rg *gin.RouterGroup) {
	auth := rg.Group("/auth")
	{
		// Public routes
		auth.POST("/register", r.authHandler.Register)
		auth.POST("/login", r.authHandler.Login)
		auth.POST("/phone/login", r.authHandler.PhoneLogin)
		
		// Protected routes
		auth.GET("/me", r.authMiddleware, r.authHandler.GetCurrentUser)
		auth.POST("/logout", r.authMiddleware, r.authHandler.Logout)
	}
}

// GetEngine returns the Gin engine
func (r *Router) GetEngine() *gin.Engine {
	return r.engine
}

