package handler

import (
	"gymates-backend/internal/application/dto"
	"gymates-backend/internal/application/usecase/auth"

	"github.com/gin-gonic/gin"
)

// AuthHandler handles authentication HTTP requests
type AuthHandler struct {
	*BaseHandler
	registerUseCase   *auth.RegisterUserUseCase
	loginUseCase      *auth.LoginUserUseCase
	phoneLoginUseCase *auth.PhoneLoginUseCase
}

// NewAuthHandler creates a new auth handler
func NewAuthHandler(
	registerUseCase *auth.RegisterUserUseCase,
	loginUseCase *auth.LoginUserUseCase,
	phoneLoginUseCase *auth.PhoneLoginUseCase,
) *AuthHandler {
	return &AuthHandler{
		BaseHandler:       NewBaseHandler(),
		registerUseCase:   registerUseCase,
		loginUseCase:      loginUseCase,
		phoneLoginUseCase: phoneLoginUseCase,
	}
}

// Register handles user registration
// @Summary Register a new user
// @Tags auth
// @Accept json
// @Produce json
// @Param request body dto.RegisterRequest true "Registration details"
// @Success 201 {object} dto.AuthResponse
// @Failure 400 {object} dto.Response
// @Router /api/v1/auth/register [post]
func (h *AuthHandler) Register(c *gin.Context) {
	var req dto.RegisterRequest
	if !h.BindJSON(c, &req) {
		return
	}
	
	response, err := h.registerUseCase.Execute(c.Request.Context(), &req)
	if err != nil {
		h.BadRequestResponse(c, err.Error())
		return
	}
	
	h.CreatedResponse(c, response)
}

// Login handles user login
// @Summary Login a user
// @Tags auth
// @Accept json
// @Produce json
// @Param request body dto.LoginRequest true "Login credentials"
// @Success 200 {object} dto.AuthResponse
// @Failure 400 {object} dto.Response
// @Failure 401 {object} dto.Response
// @Router /api/v1/auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var req dto.LoginRequest
	if !h.BindJSON(c, &req) {
		return
	}
	
	response, err := h.loginUseCase.Execute(c.Request.Context(), &req)
	if err != nil {
		h.UnauthorizedResponse(c, err.Error())
		return
	}
	
	h.SuccessResponse(c, response)
}

// PhoneLogin handles phone-based login
// @Summary Login with phone number
// @Tags auth
// @Accept json
// @Produce json
// @Param request body dto.PhoneLoginRequest true "Phone login details"
// @Success 200 {object} dto.AuthResponse
// @Failure 400 {object} dto.Response
// @Failure 401 {object} dto.Response
// @Router /api/v1/auth/phone/login [post]
func (h *AuthHandler) PhoneLogin(c *gin.Context) {
	var req dto.PhoneLoginRequest
	if !h.BindJSON(c, &req) {
		return
	}
	
	response, err := h.phoneLoginUseCase.Execute(c.Request.Context(), &req)
	if err != nil {
		h.UnauthorizedResponse(c, err.Error())
		return
	}
	
	h.SuccessResponse(c, response)
}

// GetCurrentUser retrieves the current authenticated user
// @Summary Get current user
// @Tags auth
// @Produce json
// @Security BearerAuth
// @Success 200 {object} dto.UserDTO
// @Failure 401 {object} dto.Response
// @Router /api/v1/auth/me [get]
func (h *AuthHandler) GetCurrentUser(c *gin.Context) {
	// User info is set in context by auth middleware
	user, exists := c.Get("user")
	if !exists {
		h.UnauthorizedResponse(c, "User not found")
		return
	}
	
	h.SuccessResponse(c, user)
}

// Logout handles user logout
// @Summary Logout user
// @Tags auth
// @Security BearerAuth
// @Success 200 {object} dto.Response
// @Failure 401 {object} dto.Response
// @Router /api/v1/auth/logout [post]
func (h *AuthHandler) Logout(c *gin.Context) {
	// In a real implementation, revoke the token
	// For now, just return success
	h.SuccessResponse(c, gin.H{"message": "Logged out successfully"})
}

