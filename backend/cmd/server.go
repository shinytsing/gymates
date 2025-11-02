package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"gymates-backend/api/middlewares"
	"gymates-backend/config"
	"gymates-backend/routes"
	"gymates-backend/services"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Initialize database
	if err := config.InitDB(); err != nil {
		log.Fatal("Failed to initialize database:", err)
	}

	// Initialize AI services
	services.InitAIServices()
	log.Println("🤖 AI Services initialized")

	// Set Gin mode
	if os.Getenv("GIN_MODE") == "release" {
		gin.SetMode(gin.ReleaseMode)
	}

	// Create Gin engine
	r := gin.New()

	// Setup middleware
	setupMiddleware(r)

	// Setup routes
	routes.SetupRoutes(r)

	// Get configuration
	port := config.GetPort()
	host := config.GetHost()

	// Startup information
	printStartupInfo(host, port)

	// Create and start server
	server := &http.Server{
		Addr:           fmt.Sprintf("%s:%s", host, port),
		Handler:        r,
		ReadTimeout:    30 * time.Second,
		WriteTimeout:   30 * time.Second,
		MaxHeaderBytes: 1 << 20, // 1MB
	}

	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal("Failed to start server:", err)
	}
}

// setupMiddleware configures all middleware for the application
func setupMiddleware(r *gin.Engine) {
	// Recovery middleware - recovers from panics
	r.Use(gin.Recovery())

	// Logging middleware - logs all requests
	r.Use(gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		return fmt.Sprintf("[%s] %s %s %d %s %s %s\n",
			param.TimeStamp.Format("2006/01/02 15:04:05"),
			param.ClientIP,
			param.Method,
			param.StatusCode,
			param.Latency,
			param.Path,
			param.ErrorMessage,
		)
	}))

	// CORS middleware - handles cross-origin requests
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"}, // In production, restrict to specific domains
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// Request ID middleware - adds unique request ID
	r.Use(middlewares.RequestIDMiddleware())

	// Rate limiting middleware - prevents abuse
	r.Use(middlewares.RateLimitMiddleware())

	// Error handling middleware - standardizes error responses
	r.Use(middlewares.ErrorHandlerMiddleware())
}

// printStartupInfo displays server startup information
func printStartupInfo(host, port string) {
	log.Printf("🚀 Gymates Backend Server Starting...")
	log.Printf("📍 Host: %s", host)
	log.Printf("🔌 Port: %s", port)
	log.Printf("🌐 API Base URL: http://%s:%s/api", host, port)
	log.Printf("🏥 Health Check: http://%s:%s/health", host, port)
	log.Printf("📚 API Docs: http://%s:%s/api", host, port)
	log.Printf("🗄️  Database: %s", config.GetDBType())
	log.Printf("🔧 Environment: %s", config.GetEnvironment())
	log.Printf("=====================================")
}

