package controllers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gymates-backend/config"
	"gymates-backend/middleware"
	"gymates-backend/models"
)

// AuthController 认证控制器
type AuthController struct{}

// NewAuthController 创建认证控制器
func NewAuthController() *AuthController {
	return &AuthController{}
}

// Login 用户登录
func (ac *AuthController) Login(c *gin.Context) {
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

	// 查找用户
	var user models.User
	if err := config.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "邮箱或密码错误",
			Error:   "Invalid credentials",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	// 验证密码
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "邮箱或密码错误",
			Error:   "Invalid credentials",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	// 生成token
	token, err := middleware.GenerateToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成token失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "登录成功",
		Data: models.AuthResponse{
			Token: token,
			User:  user,
		},
	})
}

// Register 用户注册
func (ac *AuthController) Register(c *gin.Context) {
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

	// 检查邮箱是否已存在
	var existingUser models.User
	if err := config.DB.Where("email = ?", req.Email).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusConflict, models.ErrorResponse{
			Success: false,
			Message: "邮箱已存在",
			Error:   "Email already exists",
			Code:    http.StatusConflict,
		})
		return
	}

	// 加密密码
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

	// 创建用户
	user := models.User{
		Name:     req.Name,
		Email:    req.Email,
		Password: string(hashedPassword),
	}

	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "创建用户失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 生成token
	token, err := middleware.GenerateToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成token失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "注册成功",
		Data: models.AuthResponse{
			Token: token,
			User:  user,
		},
	})
}

// GetCurrentUser 获取当前用户信息
func (ac *AuthController) GetCurrentUser(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "用户未认证",
			Error:   "User not authenticated",
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

// UpdateProfile 更新用户资料
func (ac *AuthController) UpdateProfile(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "用户未认证",
			Error:   "User not authenticated",
			Code:    http.StatusUnauthorized,
		})
		return
	}

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

	currentUser := user.(*models.User)

	// 更新用户信息
	updates := make(map[string]interface{})
	if req.Name != "" {
		updates["name"] = req.Name
	}
	if req.Bio != "" {
		updates["bio"] = req.Bio
	}
	if req.Location != "" {
		updates["location"] = req.Location
	}
	if req.Age > 0 {
		updates["age"] = req.Age
	}
	if req.Height > 0 {
		updates["height"] = req.Height
	}
	if req.Weight > 0 {
		updates["weight"] = req.Weight
	}
	if req.Goal != "" {
		updates["goal"] = req.Goal
	}
	if req.Experience != "" {
		updates["experience"] = req.Experience
	}

	if err := config.DB.Model(currentUser).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "更新用户资料失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 重新获取用户信息
	if err := config.DB.First(currentUser, currentUser.ID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取用户信息失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "更新用户资料成功",
		Data:    currentUser,
	})
}

// Logout 用户登出
func (ac *AuthController) Logout(c *gin.Context) {
	// 在实际应用中，可以将token加入黑名单
	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "登出成功",
	})
}

// GetUserProfile 获取用户公开资料
func (ac *AuthController) GetUserProfile(c *gin.Context) {
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

	var user models.User
	if err := config.DB.First(&user, uint(userID)).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "用户不存在",
			Error:   "User not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 不返回敏感信息
	user.Password = ""

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取用户资料成功",
		Data:    user,
	})
}

// GetUserStats 获取用户统计
func (ac *AuthController) GetUserStats(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "用户未认证",
			Error:   "User not authenticated",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	currentUser := user.(*models.User)

	var stats struct {
		TotalPosts       int64 `json:"total_posts"`
		TotalWorkouts    int64 `json:"total_workouts"`
		TotalMates       int64 `json:"total_mates"`
		TotalAchievements int64 `json:"total_achievements"`
		TotalLikes       int64 `json:"total_likes"`
		TotalComments    int64 `json:"total_comments"`
	}

	// 统计用户帖子数
	config.DB.Model(&models.Post{}).Where("user_id = ?", currentUser.ID).Count(&stats.TotalPosts)

	// 统计用户训练会话数
	config.DB.Model(&models.WorkoutSession{}).Where("user_id = ?", currentUser.ID).Count(&stats.TotalWorkouts)

	// 统计用户搭子数
	config.DB.Model(&models.Mate{}).Where("user_id = ? AND status = ?", currentUser.ID, "accepted").Count(&stats.TotalMates)

	// 统计用户成就数
	config.DB.Model(&models.Achievement{}).Where("user_id = ?", currentUser.ID).Count(&stats.TotalAchievements)

	// 统计用户获得的点赞数
	config.DB.Model(&models.Post{}).Where("user_id = ?", currentUser.ID).Select("COALESCE(SUM(like_count), 0)").Scan(&stats.TotalLikes)

	// 统计用户获得的评论数
	config.DB.Model(&models.Post{}).Where("user_id = ?", currentUser.ID).Select("COALESCE(SUM(comment_count), 0)").Scan(&stats.TotalComments)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取用户统计成功",
		Data:    stats,
	})
}
