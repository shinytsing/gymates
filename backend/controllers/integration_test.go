package controllers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"gymates-backend/config"
	"gymates-backend/models"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

// TestIntegration 集成测试
func TestIntegration(t *testing.T) {
	// 设置测试模式
	gin.SetMode(gin.TestMode)

	// 初始化测试数据库
	err := config.InitDB()
	assert.NoError(t, err)

	// 创建路由
	router := gin.Default()
	// 手动设置路由
	setupTestRouter()

	// 测试用户注册和登录流程
	t.Run("用户注册登录流程", func(t *testing.T) {
		// 1. 注册用户
		registerData := models.RegisterRequest{
			Name:     "测试用户",
			Email:    "test@gymates.com",
			Password: "password123",
		}
		registerJSON, _ := json.Marshal(registerData)

		registerReq, _ := http.NewRequest("POST", "/api/auth/register", bytes.NewBuffer(registerJSON))
		registerReq.Header.Set("Content-Type", "application/json")
		registerW := httptest.NewRecorder()
		router.ServeHTTP(registerW, registerReq)

		assert.Equal(t, http.StatusCreated, registerW.Code)

		// 2. 登录用户
		loginData := models.LoginRequest{
			Email:    "test@gymates.com",
			Password: "password123",
		}
		loginJSON, _ := json.Marshal(loginData)

		loginReq, _ := http.NewRequest("POST", "/api/auth/login", bytes.NewBuffer(loginJSON))
		loginReq.Header.Set("Content-Type", "application/json")
		loginW := httptest.NewRecorder()
		router.ServeHTTP(loginW, loginReq)

		assert.Equal(t, http.StatusOK, loginW.Code)

		var loginResponse map[string]interface{}
		json.Unmarshal(loginW.Body.Bytes(), &loginResponse)
		assert.True(t, loginResponse["success"].(bool))

		// 提取token
		data := loginResponse["data"].(map[string]interface{})
		token := data["token"].(string)
		assert.NotEmpty(t, token)
	})

	// 测试训练计划创建和使用流程
	t.Run("训练计划流程", func(t *testing.T) {
		// 1. 创建训练计划
		planData := models.CreateTrainingPlanRequest{
			Name:        "测试训练计划",
			Description: "这是一个测试训练计划",
			Duration:    30,
			Difficulty:  "beginner",
			Exercises: []models.Exercise{
				{
					Name:     "俯卧撑",
					Sets:     3,
					Reps:     10,
					Weight:   0,
					RestTime: 60,
				},
			},
		}
		planJSON, _ := json.Marshal(planData)

		planReq, _ := http.NewRequest("POST", "/api/training/plans", bytes.NewBuffer(planJSON))
		planReq.Header.Set("Content-Type", "application/json")
		planW := httptest.NewRecorder()
		router.ServeHTTP(planW, planReq)

		assert.Equal(t, http.StatusCreated, planW.Code)

		// 2. 获取训练计划列表
		listReq, _ := http.NewRequest("GET", "/api/training/plans?page=1&limit=10", nil)
		listW := httptest.NewRecorder()
		router.ServeHTTP(listW, listReq)

		assert.Equal(t, http.StatusOK, listW.Code)

		var listResponse models.SuccessResponse
		json.Unmarshal(listW.Body.Bytes(), &listResponse)
		assert.True(t, listResponse.Success)
	})

	// 测试社区帖子创建和互动流程
	t.Run("社区帖子流程", func(t *testing.T) {
		// 1. 创建帖子
		postData := models.CreatePostRequest{
			Content: "今天训练很累，但是很有成就感！",
			Type:    "text",
		}
		postJSON, _ := json.Marshal(postData)

		postReq, _ := http.NewRequest("POST", "/api/community/posts", bytes.NewBuffer(postJSON))
		postReq.Header.Set("Content-Type", "application/json")
		postW := httptest.NewRecorder()
		router.ServeHTTP(postW, postReq)

		assert.Equal(t, http.StatusCreated, postW.Code)

		// 2. 获取帖子列表
		postsReq, _ := http.NewRequest("GET", "/api/community/posts?page=1&limit=10", nil)
		postsW := httptest.NewRecorder()
		router.ServeHTTP(postsW, postsReq)

		assert.Equal(t, http.StatusOK, postsW.Code)

		var postsResponse models.SuccessResponse
		json.Unmarshal(postsW.Body.Bytes(), &postsResponse)
		assert.True(t, postsResponse.Success)
	})

	// 测试详情页面创建和管理流程
	t.Run("详情页面流程", func(t *testing.T) {
		// 1. 创建详情
		detailData := models.DetailSubmitRequest{
			Title:       "测试详情",
			Content:     "这是测试内容",
			Description: "测试描述",
			Type:        "post",
			Category:    "fitness",
			Tags:        []string{"测试", "详情"},
		}
		detailJSON, _ := json.Marshal(detailData)

		detailReq, _ := http.NewRequest("POST", "/api/detail/submit", bytes.NewBuffer(detailJSON))
		detailReq.Header.Set("Content-Type", "application/json")
		detailW := httptest.NewRecorder()
		router.ServeHTTP(detailW, detailReq)

		assert.Equal(t, http.StatusCreated, detailW.Code)

		// 2. 获取详情列表
		detailsReq, _ := http.NewRequest("GET", "/api/detail/list?page=1&limit=10", nil)
		detailsW := httptest.NewRecorder()
		router.ServeHTTP(detailsW, detailsReq)

		assert.Equal(t, http.StatusOK, detailsW.Code)

		var detailsResponse models.SuccessResponse
		json.Unmarshal(detailsW.Body.Bytes(), &detailsResponse)
		assert.True(t, detailsResponse.Success)
	})
}

// TestAPIConsistency API一致性测试
func TestAPIConsistency(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	setupTestRouter()

	// 测试所有API端点返回格式一致性
	endpoints := []struct {
		method string
		path   string
		body   interface{}
	}{
		{"GET", "/api/home/list", nil},
		{"GET", "/api/detail/list", nil},
		{"GET", "/api/training/plans", nil},
		{"GET", "/api/community/posts", nil},
		{"GET", "/api/home/stats", nil},
		{"GET", "/api/detail/stats", nil},
	}

	for _, endpoint := range endpoints {
		t.Run("API格式一致性_"+endpoint.method+"_"+endpoint.path, func(t *testing.T) {
			var req *http.Request
			var err error

			if endpoint.body != nil {
				jsonData, _ := json.Marshal(endpoint.body)
				req, err = http.NewRequest(endpoint.method, endpoint.path, bytes.NewBuffer(jsonData))
				req.Header.Set("Content-Type", "application/json")
			} else {
				req, err = http.NewRequest(endpoint.method, endpoint.path, nil)
			}

			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			// 检查响应格式
			var response map[string]interface{}
			err = json.Unmarshal(w.Body.Bytes(), &response)
			assert.NoError(t, err)

			// 所有API都应该有success字段
			_, hasSuccess := response["success"]
			assert.True(t, hasSuccess, "API响应缺少success字段: %s", endpoint.path)

			// 所有API都应该有message字段
			_, hasMessage := response["message"]
			assert.True(t, hasMessage, "API响应缺少message字段: %s", endpoint.path)
		})
	}
}

// TestErrorHandling 错误处理测试
func TestErrorHandling(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	setupTestRouter()

	// 测试各种错误情况
	errorTests := []struct {
		name           string
		method         string
		path           string
		body           interface{}
		expectedStatus int
	}{
		{
			name:           "无效路由",
			method:         "GET",
			path:           "/api/invalid/route",
			body:           nil,
			expectedStatus: http.StatusNotFound,
		},
		{
			name:           "无效JSON",
			method:         "POST",
			path:           "/api/auth/login",
			body:           "invalid json",
			expectedStatus: http.StatusBadRequest,
		},
		{
			name:           "缺少必填字段",
			method:         "POST",
			path:           "/api/auth/register",
			body:           models.RegisterRequest{Name: "测试"}, // 缺少email和password
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range errorTests {
		t.Run(tt.name, func(t *testing.T) {
			var req *http.Request
			var err error

			if tt.body != nil {
				if bodyStr, ok := tt.body.(string); ok {
					req, err = http.NewRequest(tt.method, tt.path, bytes.NewBufferString(bodyStr))
				} else {
					jsonData, _ := json.Marshal(tt.body)
					req, err = http.NewRequest(tt.method, tt.path, bytes.NewBuffer(jsonData))
					req.Header.Set("Content-Type", "application/json")
				}
			} else {
				req, err = http.NewRequest(tt.method, tt.path, nil)
			}

			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			// 检查错误响应格式
			var response map[string]interface{}
			err = json.Unmarshal(w.Body.Bytes(), &response)
			assert.NoError(t, err)

			// 错误响应应该有success字段且为false
			success, hasSuccess := response["success"].(bool)
			if hasSuccess {
				assert.False(t, success, "错误响应success应该为false")
			}
		})
	}
}
