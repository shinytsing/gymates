package handlers

import (
	"gymates-backend/internal/domain"
	"gymates-backend/models"

	"github.com/gin-gonic/gin"
)

// AuthHandler handles authentication requests
type AuthHandler struct {
	*BaseHandler
	authService domain.AuthService
}

// NewAuthHandler creates a new auth handler
func NewAuthHandler(authService domain.AuthService) *AuthHandler {
	return &AuthHandler{
		BaseHandler: NewBaseHandler(),
		authService: authService,
	}
}

// Register godoc
// @Summary Register a new user
// @Description Register a new user with email and password
// @Tags auth
// @Accept json
// @Produce json
// @Param request body models.RegisterRequest true "Registration request"
// @Success 201 {object} models.AuthResponse
// @Failure 400 {object} models.ErrorResponse
// @Router /api/auth/register [post]
func (h *AuthHandler) Register(c *gin.Context) {
	var req models.RegisterRequest
	if !h.BindJSON(c, &req) {
		return
	}

	resp, err := h.authService.Register(c.Request.Context(), &req)
	if err != nil {
		h.BadRequestResponse(c, err.Error())
		return
	}

	h.CreatedResponse(c, resp)
}

// Login godoc
// @Summary Login user
// @Description Login with email and password
// @Tags auth
// @Accept json
// @Produce json
// @Param request body models.LoginRequest true "Login request"
// @Success 200 {object} models.AuthResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Router /api/auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var req models.LoginRequest
	if !h.BindJSON(c, &req) {
		return
	}

	resp, err := h.authService.Login(c.Request.Context(), &req)
	if err != nil {
		h.UnauthorizedResponse(c, err.Error())
		return
	}

	h.SuccessResponse(c, resp)
}

// SendVerificationCode godoc
// @Summary Send verification code
// @Description Send SMS verification code to phone number
// @Tags auth
// @Accept json
// @Produce json
// @Param request body models.SendCodeRequest true "Send code request"
// @Success 200 {object} models.SuccessResponse
// @Failure 400 {object} models.ErrorResponse
// @Router /api/auth/send-code [post]
func (h *AuthHandler) SendVerificationCode(c *gin.Context) {
	var req struct {
		Phone string `json:"phone" binding:"required"`
	}
	if !h.BindJSON(c, &req) {
		return
	}

	if err := h.authService.SendVerificationCode(c.Request.Context(), req.Phone); err != nil {
		h.BadRequestResponse(c, err.Error())
		return
	}

	h.SuccessResponseWithMessage(c, "Verification code sent successfully", nil)
}

// PhoneLogin godoc
// @Summary Login with phone
// @Description Login with phone number and verification code
// @Tags auth
// @Accept json
// @Produce json
// @Param request body models.PhoneLoginRequest true "Phone login request"
// @Success 200 {object} models.AuthResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Router /api/auth/phone/login [post]
func (h *AuthHandler) PhoneLogin(c *gin.Context) {
	var req struct {
		Phone string `json:"phone" binding:"required"`
		Code  string `json:"code" binding:"required"`
	}
	if !h.BindJSON(c, &req) {
		return
	}

	resp, err := h.authService.PhoneLogin(c.Request.Context(), req.Phone, req.Code)
	if err != nil {
		h.UnauthorizedResponse(c, err.Error())
		return
	}

	h.SuccessResponse(c, resp)
}

// SocialLogin godoc
// @Summary Social login
// @Description Login with social provider (Google, Apple, WeChat)
// @Tags auth
// @Accept json
// @Produce json
// @Param request body models.SocialLoginRequest true "Social login request"
// @Success 200 {object} models.AuthResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Router /api/auth/social/login [post]
func (h *AuthHandler) SocialLogin(c *gin.Context) {
	var req struct {
		Provider string `json:"provider" binding:"required"`
		Token    string `json:"token" binding:"required"`
	}
	if !h.BindJSON(c, &req) {
		return
	}

	resp, err := h.authService.SocialLogin(c.Request.Context(), req.Provider, req.Token)
	if err != nil {
		h.UnauthorizedResponse(c, err.Error())
		return
	}

	h.SuccessResponse(c, resp)
}

// RefreshToken godoc
// @Summary Refresh access token
// @Description Refresh access token using refresh token
// @Tags auth
// @Accept json
// @Produce json
// @Param request body models.RefreshTokenRequest true "Refresh token request"
// @Success 200 {object} models.AuthResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Router /api/auth/refresh [post]
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	var req struct {
		RefreshToken string `json:"refresh_token" binding:"required"`
	}
	if !h.BindJSON(c, &req) {
		return
	}

	resp, err := h.authService.RefreshToken(c.Request.Context(), req.RefreshToken)
	if err != nil {
		h.UnauthorizedResponse(c, err.Error())
		return
	}

	h.SuccessResponse(c, resp)
}

// Logout godoc
// @Summary Logout user
// @Description Logout and revoke refresh token
// @Tags auth
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 {object} models.SuccessResponse
// @Failure 401 {object} models.ErrorResponse
// @Router /api/auth/logout [post]
func (h *AuthHandler) Logout(c *gin.Context) {
	token, exists := c.Get("refresh_token")
	if !exists {
		h.SuccessResponseWithMessage(c, "Logged out successfully", nil)
		return
	}

	if err := h.authService.RevokeToken(c.Request.Context(), token.(string)); err != nil {
		h.InternalServerErrorResponse(c, "Failed to revoke token")
		return
	}

	h.SuccessResponseWithMessage(c, "Logged out successfully", nil)
}

// GetCurrentUser godoc
// @Summary Get current user
// @Description Get current authenticated user information
// @Tags auth
// @Produce json
// @Security BearerAuth
// @Success 200 {object} models.User
// @Failure 401 {object} models.ErrorResponse
// @Router /api/auth/me [get]
func (h *AuthHandler) GetCurrentUser(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		h.UnauthorizedResponse(c, "User not found")
		return
	}

	h.SuccessResponse(c, user)
}

// UpdateProfile godoc
// @Summary Update user profile
// @Description Update current user's profile information
// @Tags auth
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body models.UpdateProfileRequest true "Update profile request"
// @Success 200 {object} models.User
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Router /api/auth/profile [put]
func (h *AuthHandler) UpdateProfile(c *gin.Context) {
	userID := h.GetUserIDOrAbort(c)
	if userID == 0 {
		return
	}

	var req models.UpdateProfileRequest
	if !h.BindJSON(c, &req) {
		return
	}

	// TODO: Implement update profile logic
	h.SuccessResponseWithMessage(c, "Profile updated successfully", nil)
}

