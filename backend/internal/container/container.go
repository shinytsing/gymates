package container

import (
	"time"

	"gymates-backend/internal/application/usecase/auth"
	"gymates-backend/internal/domain/repository"
	infraAuth "gymates-backend/internal/infrastructure/auth"
	gormRepo "gymates-backend/internal/infrastructure/persistence/gorm"
	"gymates-backend/internal/infrastructure/service/sms"
	"gymates-backend/internal/interfaces/http/handler"
	"gymates-backend/internal/interfaces/http/middleware"
	"gymates-backend/internal/interfaces/http/router"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// Container holds all dependencies
type Container struct {
	DB *gorm.DB
	
	// Infrastructure
	JWTManager          *infraAuth.JWTManager
	VerificationService *sms.VerificationService
	
	// Repositories
	UserRepo repository.UserRepository
	
	// Use Cases
	RegisterUserUseCase *auth.RegisterUserUseCase
	LoginUserUseCase    *auth.LoginUserUseCase
	PhoneLoginUseCase   *auth.PhoneLoginUseCase
	
	// Handlers
	AuthHandler *handler.AuthHandler
	
	// Middleware
	AuthMiddleware         gin.HandlerFunc
	OptionalAuthMiddleware gin.HandlerFunc
	
	// Router
	Router *router.Router
}

// NewContainer creates a new dependency injection container
func NewContainer(db *gorm.DB, jwtSecret string) *Container {
	c := &Container{
		DB: db,
	}
	
	// Initialize infrastructure
	c.JWTManager = infraAuth.NewJWTManager(
		jwtSecret,
		24*time.Hour,  // Access token duration
		7*24*time.Hour, // Refresh token duration
	)
	c.VerificationService = sms.NewVerificationService(5 * time.Minute)
	
	// Initialize repositories
	c.UserRepo = gormRepo.NewUserRepository(db)
	
	// Initialize use cases
	c.RegisterUserUseCase = auth.NewRegisterUserUseCase(c.UserRepo, c.JWTManager)
	c.LoginUserUseCase = auth.NewLoginUserUseCase(c.UserRepo, c.JWTManager)
	c.PhoneLoginUseCase = auth.NewPhoneLoginUseCase(c.UserRepo, c.JWTManager, c.VerificationService)
	
	// Initialize handlers
	c.AuthHandler = handler.NewAuthHandler(
		c.RegisterUserUseCase,
		c.LoginUserUseCase,
		c.PhoneLoginUseCase,
	)
	
	// Initialize middleware
	c.AuthMiddleware = middleware.AuthMiddleware(c.JWTManager, c.UserRepo)
	c.OptionalAuthMiddleware = middleware.OptionalAuthMiddleware(c.JWTManager, c.UserRepo)
	
	// Initialize router
	c.Router = router.NewRouter(&router.Config{
		AuthHandler:            c.AuthHandler,
		AuthMiddleware:         c.AuthMiddleware,
		OptionalAuthMiddleware: c.OptionalAuthMiddleware,
	})
	
	return c
}

// GetEngine returns the Gin engine
func (c *Container) GetEngine() *gin.Engine {
	return c.Router.GetEngine()
}
