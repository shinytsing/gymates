package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"gymates-backend/config"
	"gymates-backend/internal/container"

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

	// Get database connection
	db := config.GetDB()
	if db == nil {
		log.Fatal("Database connection is nil")
	}

	// Get JWT secret from environment
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "gymates-super-secret-key-change-in-production"
		log.Println("⚠️  Using default JWT secret. Set JWT_SECRET environment variable in production!")
	}

	// Create dependency injection container
	cnt := container.NewContainer(db, jwtSecret)

	// Get configured Gin engine
	engine := cnt.GetEngine()

	// Server configuration
	port := config.GetPort()
	host := config.GetHost()
	addr := fmt.Sprintf("%s:%s", host, port)

	server := &http.Server{
		Addr:           addr,
		Handler:        engine,
		ReadTimeout:    30 * time.Second,
		WriteTimeout:   30 * time.Second,
		MaxHeaderBytes: 1 << 20, // 1MB
	}

	// Start server in a goroutine
	go func() {
		log.Println("🚀 ============================================")
		log.Println("🚀 Gymates Backend Server (Clean Architecture)")
		log.Println("🚀 ============================================")
		log.Printf("📍 Host: %s", host)
		log.Printf("🔌 Port: %s", port)
		log.Printf("🌐 API Base URL: http://%s:%s/api/v1", host, port)
		log.Printf("🏥 Health Check: http://%s:%s/health", host, port)
		log.Printf("🗄️  Database: %s", config.GetDBType())
		log.Printf("🔧 Environment: %s", config.GetEnvironment())
		log.Println("🚀 ============================================")
		log.Printf("✅ Server is running on %s", addr)

		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("🛑 Shutting down server...")

	// Graceful shutdown with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Fatal("Server forced to shutdown:", err)
	}

	log.Println("✅ Server exited gracefully")
}

