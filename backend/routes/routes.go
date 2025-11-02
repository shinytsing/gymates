package routes

import (
	"gymates-backend/api"

	"github.com/gin-gonic/gin"
)

// SetupRoutes sets up all application routes
// This is the main entry point for route configuration
func SetupRoutes(r *gin.Engine) {
	// Use the new modular API routes structure
	api.SetupAPIRoutes(r)
}
