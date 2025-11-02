package handlers

import (
	"net/http"
	"strconv"

	"gymates-backend/api/middlewares"
	"gymates-backend/models"
	"gymates-backend/repositories"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

// AuthHandler handles authentication-related requests
type AuthHandler struct {
	userRepo *repositories.UserRepository
}

// NewAuthHandler creates a new auth handler
func NewAuthHandler() *AuthHandler {
	return &AuthHandler{
		userRepo: repositories.NewUserRepository(),
	}
}

// Login handles user login
func (h *AuthHandler) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Find user by email
	user, err := h.userRepo.GetByEmail(req.Email)
	if err != nil {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "邮箱或密码错误",
			Error:   "Invalid credentials",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	// Verify password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "邮箱或密码错误",
			Error:   "Invalid credentials",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	// Generate tokens
	accessToken, err := middlewares.GenerateToken(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成token失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	refreshToken, err := middlewares.GenerateRefreshToken(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成刷新令牌失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// Update last login
	h.userRepo.UpdateLastLogin(user.ID)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "登录成功",
		Data: models.AuthResponse{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
			ExpiresIn:    1800, // 30 minutes
			User:         *user,
		},
	})
}

// Register handles user registration
func (h *AuthHandler) Register(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Check if email already exists
	if _, err := h.userRepo.GetByEmail(req.Email); err == nil {
		c.JSON(http.StatusConflict, models.ErrorResponse{
			Success: false,
			Message: "邮箱已存在",
			Error:   "Email already exists",
			Code:    http.StatusConflict,
		})
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "密码加密失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// Create user
	user := models.User{
		Name:      req.Name,
		Email:     req.Email,
		Password:  string(hashedPassword),
		LoginType: "email",
	}

	if err := h.userRepo.Create(&user); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "创建用户失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// Generate tokens
	accessToken, err := middlewares.GenerateToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成token失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	refreshToken, err := middlewares.GenerateRefreshToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成刷新令牌失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "注册成功",
		Data: models.AuthResponse{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
			ExpiresIn:    1800,
			User:         user,
		},
	})
}

// GetCurrentUser retrieves the current authenticated user
func (h *AuthHandler) GetCurrentUser(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未认证",
			Error:   "Unauthorized",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取用户信息成功",
		Data:    user,
	})
}

// GetUserProfile retrieves a user profile by ID
func (h *AuthHandler) GetUserProfile(c *gin.Context) {
	userIDStr := c.Param("id")
	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的用户ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	user, err := h.userRepo.GetByID(uint(userID))
	if err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "用户不存在",
			Error:   err.Error(),
			Code:    http.StatusNotFound,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取用户信息成功",
		Data:    user,
	})
}

// UpdateProfile updates the current user's profile
func (h *AuthHandler) UpdateProfile(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未认证",
			Error:   "Unauthorized",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	currentUser := user.(*models.User)

	var req models.UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Update user fields
	if req.Name != "" {
		currentUser.Name = req.Name
	}
	if req.Bio != "" {
		currentUser.Bio = req.Bio
	}
	if req.Location != "" {
		currentUser.Location = req.Location
	}
	if req.Age > 0 {
		currentUser.Age = req.Age
	}
	if req.Height > 0 {
		currentUser.Height = req.Height
	}
	if req.Weight > 0 {
		currentUser.Weight = req.Weight
	}
	if req.Goal != "" {
		currentUser.Goal = req.Goal
	}
	if req.Experience != "" {
		currentUser.Experience = req.Experience
	}

	if err := h.userRepo.Update(currentUser); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "更新用户信息失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "更新用户信息成功",
		Data:    currentUser,
	})
}

// Logout handles user logout
func (h *AuthHandler) Logout(c *gin.Context) {
	// In a stateless JWT system, logout is typically handled on the client side
	// Here we can optionally revoke the refresh token
	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "登出成功",
		Data:    nil,
	})
}

