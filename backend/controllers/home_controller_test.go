package controllers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"gymates-backend/models"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

// TestGetHomeList 测试获取首页列表
func TestGetHomeList(t *testing.T) {
	// 设置测试模式
	gin.SetMode(gin.TestMode)

	// 初始化路由
	router := gin.Default()
	homeController := NewHomeController()
	router.GET("/api/home/list", homeController.GetHomeList)

	// 测试用例
	tests := []struct {
		name           string
		queryParams    string
		expectedStatus int
		expectData     bool
	}{
		{
			name:           "正常获取列表",
			queryParams:    "?page=1&limit=10",
			expectedStatus: http.StatusOK,
			expectData:     true,
		},
		{
			name:           "带筛选条件的列表",
			queryParams:    "?page=1&limit=10&category=fitness&keyword=训练",
			expectedStatus: http.StatusOK,
			expectData:     true,
		},
		{
			name:           "无效分页参数",
			queryParams:    "?page=0&limit=0",
			expectedStatus: http.StatusOK, // 应该使用默认值
			expectData:     true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// 创建请求
			req, err := http.NewRequest("GET", "/api/home/list"+tt.queryParams, nil)
			assert.NoError(t, err)

			// 创建响应记录器
			w := httptest.NewRecorder()

			// 执行请求
			router.ServeHTTP(w, req)

			// 检查状态码
			assert.Equal(t, tt.expectedStatus, w.Code)

			// 检查响应格式
			var response models.SuccessResponse
			err = json.Unmarshal(w.Body.Bytes(), &response)
			assert.NoError(t, err)
			assert.True(t, response.Success)

			if tt.expectData {
				assert.NotNil(t, response.Data)
			}
		})
	}
}

// TestAddHomeItem 测试新增首页项
func TestAddHomeItem(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	homeController := NewHomeController()
	router.POST("/api/home/add", homeController.AddHomeItem)

	tests := []struct {
		name           string
		requestBody    interface{}
		expectedStatus int
		expectSuccess  bool
	}{
		{
			name: "正常新增项目",
			requestBody: models.HomeAddRequest{
				Title:       "测试项目",
				Description: "这是一个测试项目",
				Category:    "fitness",
				Priority:    1,
			},
			expectedStatus: http.StatusCreated,
			expectSuccess:  true,
		},
		{
			name: "缺少必填字段",
			requestBody: models.HomeAddRequest{
				Description: "缺少标题",
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

			req, err := http.NewRequest("POST", "/api/home/add", bytes.NewBuffer(jsonValue))
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

// TestUpdateHomeItem 测试更新首页项
func TestUpdateHomeItem(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	homeController := NewHomeController()
	router.PUT("/api/home/update/:id", homeController.UpdateHomeItem)

	tests := []struct {
		name           string
		itemID         string
		requestBody    interface{}
		expectedStatus int
	}{
		{
			name:   "正常更新项目",
			itemID: "1",
			requestBody: models.HomeUpdateRequest{
				Title:       "更新后的标题",
				Description: "更新后的描述",
				Status:      "published",
			},
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效ID",
			itemID:         "invalid",
			requestBody:    models.HomeUpdateRequest{Title: "测试"},
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			jsonValue, err := json.Marshal(tt.requestBody)
			assert.NoError(t, err)

			req, err := http.NewRequest("PUT", "/api/home/update/"+tt.itemID, bytes.NewBuffer(jsonValue))
			assert.NoError(t, err)
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestDeleteHomeItem 测试删除首页项
func TestDeleteHomeItem(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	homeController := NewHomeController()
	router.DELETE("/api/home/delete/:id", homeController.DeleteHomeItem)

	tests := []struct {
		name           string
		itemID         string
		expectedStatus int
	}{
		{
			name:           "正常删除项目",
			itemID:         "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效ID",
			itemID:         "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("DELETE", "/api/home/delete/"+tt.itemID, nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestGetHomeItem 测试获取单个首页项
func TestGetHomeItem(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	homeController := NewHomeController()
	router.GET("/api/home/:id", homeController.GetHomeItem)

	tests := []struct {
		name           string
		itemID         string
		expectedStatus int
	}{
		{
			name:           "正常获取项目",
			itemID:         "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效ID",
			itemID:         "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("GET", "/api/home/"+tt.itemID, nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestLikeHomeItem 测试点赞首页项
func TestLikeHomeItem(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	homeController := NewHomeController()
	router.POST("/api/home/:id/like", homeController.LikeHomeItem)

	tests := []struct {
		name           string
		itemID         string
		expectedStatus int
	}{
		{
			name:           "正常点赞",
			itemID:         "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效ID",
			itemID:         "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("POST", "/api/home/"+tt.itemID+"/like", nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestGetHomeStats 测试获取首页统计
func TestGetHomeStats(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	homeController := NewHomeController()
	router.GET("/api/home/stats", homeController.GetHomeStats)

	req, err := http.NewRequest("GET", "/api/home/stats", nil)
	assert.NoError(t, err)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response models.SuccessResponse
	err = json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.True(t, response.Success)
	assert.NotNil(t, response.Data)
}
