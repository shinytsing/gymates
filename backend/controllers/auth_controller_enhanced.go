package controllers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gymates-backend/config"
	"gymates-backend/middleware"
	"gymates-backend/models"
	"gymates-backend/services"
)

// EnhancedAuthController 增强认证控制器
type EnhancedAuthController struct {
	smsService *services.SMSService
}

// NewEnhancedAuthController 创建增强认证控制器
func NewEnhancedAuthController() *EnhancedAuthController {
	return &EnhancedAuthController{
		smsService: services.GetSMSService(),
	}
}

// SendVerificationCode 发送验证码
func (ac *EnhancedAuthController) SendVerificationCode(c *gin.Context) {
	var req models.SendCodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 发送验证码
	code, err := ac.smsService.SendVerificationCode(req.Phone, req.Type)
	if err != nil {
		c.JSON(http.StatusTooManyRequests, models.ErrorResponse{
			Success: false,
			Message: err.Error(),
			Error:   "Send code failed",
			Code:    http.StatusTooManyRequests,
		})
		return
	}

	// 开发环境返回验证码，生产环境不应该返回
	response := gin.H{
		"sent_at":    time.Now(),
		"expires_in": 300, // 5分钟
	}

	// 仅在开发环境返回验证码
	if config.DB.Name() == "sqlite" { // 简单判断开发环境
		response["code"] = code // 仅用于测试
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "验证码已发送",
		Data:    response,
	})
}

// PhoneLogin 手机号登录
func (ac *EnhancedAuthController) PhoneLogin(c *gin.Context) {
	var req models.PhoneLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 跳过验证码验证（开发模式）
	// valid, err := ac.smsService.VerifyCode(req.Phone, req.Code, "login")
	// if err != nil || !valid {
	// 	c.JSON(http.StatusUnauthorized, models.ErrorResponse{
	// 		Success: false,
	// 		Message: "验证码无效或已过期",
	// 		Error:   "Invalid verification code",
	// 		Code:    http.StatusUnauthorized,
	// 	})
	// 	return
	// }

	// 查找用户
	var user models.User
	err := config.DB.Where("phone = ?", req.Phone).First(&user).Error
	if err != nil {
		// 用户不存在，自动注册
		user = models.User{
			Phone:     req.Phone,
			Name:      "用户" + req.Phone[len(req.Phone)-4:], // 使用手机号后4位
			LoginType: "phone",
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
	}

	// 更新最后登录时间
	now := time.Now()
	user.LastLoginAt = &now
	config.DB.Save(&user)

	// 生成token和refresh token
	accessToken, err := middleware.GenerateToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成访问令牌失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	refreshToken, err := middleware.GenerateRefreshToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成刷新令牌失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "登录成功",
		Data: models.AuthResponse{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
			ExpiresIn:    1800, // 30分钟
			User:         user,
		},
	})
}

// PhoneRegister 手机号注册
func (ac *EnhancedAuthController) PhoneRegister(c *gin.Context) {
	var req models.PhoneRegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 验证验证码
	valid, err := ac.smsService.VerifyCode(req.Phone, req.Code, "register")
	if err != nil || !valid {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "验证码无效或已过期",
			Error:   "Invalid verification code",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	// 检查手机号是否已存在
	var existingUser models.User
	if err := config.DB.Where("phone = ?", req.Phone).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusConflict, models.ErrorResponse{
			Success: false,
			Message: "手机号已注册",
			Error:   "Phone already exists",
			Code:    http.StatusConflict,
		})
		return
	}

	// 创建用户
	user := models.User{
		Phone:     req.Phone,
		Name:      req.Name,
		LoginType: "phone",
	}

	// 如果提供了密码，则加密存储
	if req.Password != "" {
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
		user.Password = string(hashedPassword)
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

	// 生成token和refresh token
	accessToken, err := middleware.GenerateToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成访问令牌失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	refreshToken, err := middleware.GenerateRefreshToken(&user)
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
			ExpiresIn:    1800, // 30分钟
			User:         user,
		},
	})
}

// RefreshToken 刷新访问令牌
func (ac *EnhancedAuthController) RefreshToken(c *gin.Context) {
	var req models.RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 验证刷新令牌
	user, err := middleware.ValidateRefreshToken(req.RefreshToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "刷新令牌无效或已过期",
			Error:   err.Error(),
			Code:    http.StatusUnauthorized,
		})
		return
	}

	// 生成新的访问令牌
	accessToken, err := middleware.GenerateToken(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成访问令牌失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 可选：生成新的刷新令牌（旋转刷新令牌策略）
	// 旧的刷新令牌保持有效，或者可以选择撤销旧令牌
	newRefreshToken, err := middleware.GenerateRefreshToken(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成刷新令牌失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 撤销旧的刷新令牌
	_ = middleware.RevokeRefreshToken(req.RefreshToken)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "令牌刷新成功",
		Data: models.AuthResponse{
			AccessToken:  accessToken,
			RefreshToken: newRefreshToken,
			ExpiresIn:    1800, // 30分钟
			User:         *user,
		},
	})
}

// SocialLogin 社交登录（Apple, Google, 微信）
func (ac *EnhancedAuthController) SocialLogin(c *gin.Context) {
	var req models.SocialLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 这里应该验证 AccessToken 的有效性
	// 对于Apple，需要验证 identityToken
	// 对于Google，需要验证 idToken
	// 对于微信，需要验证 code 并换取 access_token

	// 简化实现：直接使用提供的用户信息（生产环境必须验证）
	if req.UserInfo == nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "缺少用户信息",
			Error:   "User info required",
			Code:    http.StatusBadRequest,
		})
		return
	}

	var user models.User
	var socialID string
	var socialIDField string

	switch req.Provider {
	case "apple":
		socialID = req.UserInfo.ID
		socialIDField = "apple_id"
	case "google":
		socialID = req.UserInfo.ID
		socialIDField = "google_id"
	case "wechat":
		socialID = req.UserInfo.ID
		socialIDField = "wechat_id"
	default:
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "不支持的登录方式",
			Error:   "Unsupported provider",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 查找或创建用户
	err := config.DB.Where(socialIDField+" = ?", socialID).First(&user).Error
	if err != nil {
		// 用户不存在，创建新用户
		user = models.User{
			Name:      req.UserInfo.Name,
			Email:     req.UserInfo.Email,
			Avatar:    req.UserInfo.Avatar,
			LoginType: req.Provider,
		}

		switch req.Provider {
		case "apple":
			user.AppleID = socialID
		case "google":
			user.GoogleID = socialID
		case "wechat":
			user.WechatID = socialID
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
	}

	// 更新最后登录时间
	now := time.Now()
	user.LastLoginAt = &now
	config.DB.Save(&user)

	// 生成token和refresh token
	accessToken, err := middleware.GenerateToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成访问令牌失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	refreshToken, err := middleware.GenerateRefreshToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成刷新令牌失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "登录成功",
		Data: models.AuthResponse{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
			ExpiresIn:    1800, // 30分钟
			User:         user,
		},
	})
}

// GuestLogin 游客登录
func (ac *EnhancedAuthController) GuestLogin(c *gin.Context) {
	// 创建游客用户
	user := models.User{
		Name:      "游客" + time.Now().Format("150405"),
		IsGuest:   true,
		LoginType: "guest",
	}

	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "创建游客失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 生成token和refresh token
	accessToken, err := middleware.GenerateToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成访问令牌失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	refreshToken, err := middleware.GenerateRefreshToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "生成刷新令牌失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "游客登录成功",
		Data: models.AuthResponse{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
			ExpiresIn:    1800, // 30分钟
			User:         user,
		},
	})
}

// RevokeToken 撤销令牌（登出）
func (ac *EnhancedAuthController) RevokeToken(c *gin.Context) {
	var req models.RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		// 如果没有提供刷新令牌，也算登出成功
		c.JSON(http.StatusOK, models.SuccessResponse{
			Success: true,
			Message: "登出成功",
		})
		return
	}

	// 撤销刷新令牌
	if err := middleware.RevokeRefreshToken(req.RefreshToken); err != nil {
		// 即使撤销失败，也返回成功（客户端已清除token）
		c.JSON(http.StatusOK, models.SuccessResponse{
			Success: true,
			Message: "登出成功",
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "登出成功",
	})
}
