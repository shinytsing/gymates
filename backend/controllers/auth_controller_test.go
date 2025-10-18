package controllers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"gymates-backend/models"
)

// TestLogin 测试用户登录
func TestLogin(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	authController := NewAuthController()
	router.POST("/api/auth/login", authController.Login)

	tests := []struct {
		name           string
		requestBody    interface{}
		expectedStatus int
		expectSuccess  bool
	}{
		{
			name: "正常登录",
			requestBody: models.LoginRequest{
				Email:    "test@gymates.com",
				Password: "password123",
			},
			expectedStatus: http.StatusOK,
			expectSuccess:  true,
		},
		{
			name: "无效邮箱格式",
			requestBody: models.LoginRequest{
				Email:    "invalid-email",
				Password: "password123",
			},
			expectedStatus: http.StatusBadRequest,
			expectSuccess:  false,
		},
		{
			name: "密码太短",
			requestBody: models.LoginRequest{
				Email:    "test@gymates.com",
				Password: "123",
			},
			expectedStatus: http.StatusBadRequest,
			expectSuccess:  false,
		},
		{
			name:           "空请求体",
			requestBody:    nil,
			expectedStatus: http.StatusBadRequest,
			expectSuccess:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var jsonValue []byte
			var err error

			if tt.requestBody != nil {
				jsonValue, err = json.Marshal(tt.requestBody)
				assert.NoError(t, err)
			}

			req, err := http.NewRequest("POST", "/api/auth/login", bytes.NewBuffer(jsonValue))
			assert.NoError(t, err)
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			var response map[string]interface{}
			err = json.Unmarshal(w.Body.Bytes(), &response)
			assert.NoError(t, err)

			if tt.expectSuccess {
				assert.True(t, response["success"].(bool))
			} else {
				assert.False(t, response["success"].(bool))
			}
		})
	}
}

// TestRegister 测试用户注册
func TestRegister(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	authController := NewAuthController()
	router.POST("/api/auth/register", authController.Register)

	tests := []struct {
		name           string
		requestBody    interface{}
		expectedStatus int
		expectSuccess  bool
	}{
		{
			name: "正常注册",
			requestBody: models.RegisterRequest{
				Name:     "测试用户",
				Email:    "newuser@gymates.com",
				Password: "password123",
			},
			expectedStatus: http.StatusCreated,
			expectSuccess:  true,
		},
		{
			name: "用户名太短",
			requestBody: models.RegisterRequest{
				Name:     "ab",
				Email:    "test@gymates.com",
				Password: "password123",
			},
			expectedStatus: http.StatusBadRequest,
			expectSuccess:  false,
		},
		{
			name: "无效邮箱格式",
			requestBody: models.RegisterRequest{
				Name:     "测试用户",
				Email:    "invalid-email",
				Password: "password123",
			},
			expectedStatus: http.StatusBadRequest,
			expectSuccess:  false,
		},
		{
			name: "密码太短",
			requestBody: models.RegisterRequest{
				Name:     "测试用户",
				Email:    "test@gymates.com",
				Password: "123",
			},
			expectedStatus: http.StatusBadRequest,
			expectSuccess:  false,
		},
		{
			name:           "空请求体",
			requestBody:    nil,
			expectedStatus: http.StatusBadRequest,
			expectSuccess:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var jsonValue []byte
			var err error

			if tt.requestBody != nil {
				jsonValue, err = json.Marshal(tt.requestBody)
				assert.NoError(t, err)
			}

			req, err := http.NewRequest("POST", "/api/auth/register", bytes.NewBuffer(jsonValue))
			assert.NoError(t, err)
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			var response map[string]interface{}
			err = json.Unmarshal(w.Body.Bytes(), &response)
			assert.NoError(t, err)

			if tt.expectSuccess {
				assert.True(t, response["success"].(bool))
			} else {
				assert.False(t, response["success"].(bool))
			}
		})
	}
}

// TestGetCurrentUser 测试获取当前用户
func TestGetCurrentUser(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	authController := NewAuthController()
	router.GET("/api/auth/me", authController.GetCurrentUser)

	// 测试无认证token的情况
	t.Run("无认证token", func(t *testing.T) {
		req, err := http.NewRequest("GET", "/api/auth/me", nil)
		assert.NoError(t, err)

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	// 测试无效token的情况
	t.Run("无效token", func(t *testing.T) {
		req, err := http.NewRequest("GET", "/api/auth/me", nil)
		assert.NoError(t, err)
		req.Header.Set("Authorization", "Bearer invalid-token")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})
}

// TestUpdateProfile 测试更新用户资料
func TestUpdateProfile(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	authController := NewAuthController()
	router.PUT("/api/auth/profile", authController.UpdateProfile)

	tests := []struct {
		name           string
		requestBody    interface{}
		expectedStatus int
		expectSuccess  bool
	}{
		{
			name: "正常更新资料",
			requestBody: map[string]interface{}{
				"name":     "更新后的用户名",
				"bio":      "更新后的个人简介",
				"location": "北京市",
				"age":      25,
			},
			expectedStatus: http.StatusOK,
			expectSuccess:  true,
		},
		{
			name:           "空请求体",
			requestBody:    nil,
			expectedStatus: http.StatusBadRequest,
			expectSuccess:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var jsonValue []byte
			var err error

			if tt.requestBody != nil {
				jsonValue, err = json.Marshal(tt.requestBody)
				assert.NoError(t, err)
			}

			req, err := http.NewRequest("PUT", "/api/auth/profile", bytes.NewBuffer(jsonValue))
			assert.NoError(t, err)
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			var response map[string]interface{}
			err = json.Unmarshal(w.Body.Bytes(), &response)
			assert.NoError(t, err)

			if tt.expectSuccess {
				assert.True(t, response["success"].(bool))
			} else {
				assert.False(t, response["success"].(bool))
			}
		})
	}
}

// TestLogout 测试用户登出
func TestLogout(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	authController := NewAuthController()
	router.POST("/api/auth/logout", authController.Logout)

	req, err := http.NewRequest("POST", "/api/auth/logout", nil)
	assert.NoError(t, err)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response models.SuccessResponse
	err = json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.True(t, response.Success)
}

// TestGetUserProfile 测试获取用户资料
func TestGetUserProfile(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	authController := NewAuthController()
	router.GET("/api/users/:id", authController.GetUserProfile)

	tests := []struct {
		name           string
		userID         string
		expectedStatus int
	}{
		{
			name:           "正常获取用户资料",
			userID:         "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效用户ID",
			userID:         "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("GET", "/api/users/"+tt.userID, nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestGetUserStats 测试获取用户统计
func TestGetUserStats(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	authController := NewAuthController()
	router.GET("/api/profile/stats", authController.GetUserStats)

	// 测试无认证token的情况
	t.Run("无认证token", func(t *testing.T) {
		req, err := http.NewRequest("GET", "/api/profile/stats", nil)
		assert.NoError(t, err)

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})
}
