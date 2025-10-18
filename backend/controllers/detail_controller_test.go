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

// TestGetDetailList 测试获取详情列表
func TestGetDetailList(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	detailController := NewDetailController()
	router.GET("/api/detail/list", detailController.GetDetailList)

	tests := []struct {
		name           string
		queryParams    string
		expectedStatus int
		expectData     bool
	}{
		{
			name:           "正常获取详情列表",
			queryParams:    "?page=1&limit=10",
			expectedStatus: http.StatusOK,
			expectData:     true,
		},
		{
			name:           "带类型筛选",
			queryParams:    "?page=1&limit=10&type=post&category=fitness",
			expectedStatus: http.StatusOK,
			expectData:     true,
		},
		{
			name:           "带关键词搜索",
			queryParams:    "?page=1&limit=10&keyword=训练",
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
			req, err := http.NewRequest("GET", "/api/detail/list"+tt.queryParams, nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

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

// TestGetDetail 测试获取单个详情
func TestGetDetail(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	detailController := NewDetailController()
	router.GET("/api/detail/:id", detailController.GetDetail)

	tests := []struct {
		name           string
		detailID       string
		expectedStatus int
	}{
		{
			name:           "正常获取详情",
			detailID:       "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效ID",
			detailID:       "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("GET", "/api/detail/"+tt.detailID, nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestSubmitDetail 测试提交详情
func TestSubmitDetail(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	detailController := NewDetailController()
	router.POST("/api/detail/submit", detailController.SubmitDetail)

	tests := []struct {
		name           string
		requestBody    interface{}
		expectedStatus int
		expectSuccess  bool
	}{
		{
			name: "正常提交详情",
			requestBody: models.DetailSubmitRequest{
				Title:       "测试详情",
				Content:     "这是测试内容",
				Description: "测试描述",
				Type:        "post",
				Category:    "fitness",
				Tags:        []string{"测试", "详情"},
			},
			expectedStatus: http.StatusCreated,
			expectSuccess:  true,
		},
		{
			name: "缺少必填字段",
			requestBody: models.DetailSubmitRequest{
				Content: "缺少标题和类型",
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

			req, err := http.NewRequest("POST", "/api/detail/submit", bytes.NewBuffer(jsonValue))
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

// TestUpdateDetail 测试更新详情
func TestUpdateDetail(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	detailController := NewDetailController()
	router.PUT("/api/detail/update/:id", detailController.UpdateDetail)

	tests := []struct {
		name           string
		detailID       string
		requestBody    interface{}
		expectedStatus int
	}{
		{
			name:     "正常更新详情",
			detailID: "1",
			requestBody: models.DetailUpdateRequest{
				Title:       "更新后的标题",
				Content:     "更新后的内容",
				Description: "更新后的描述",
			},
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效ID",
			detailID:       "invalid",
			requestBody:    models.DetailUpdateRequest{Title: "测试"},
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			jsonValue, err := json.Marshal(tt.requestBody)
			assert.NoError(t, err)

			req, err := http.NewRequest("PUT", "/api/detail/update/"+tt.detailID, bytes.NewBuffer(jsonValue))
			assert.NoError(t, err)
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestDeleteDetail 测试删除详情
func TestDeleteDetail(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	detailController := NewDetailController()
	router.DELETE("/api/detail/delete/:id", detailController.DeleteDetail)

	tests := []struct {
		name           string
		detailID       string
		expectedStatus int
	}{
		{
			name:           "正常删除详情",
			detailID:       "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效ID",
			detailID:       "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("DELETE", "/api/detail/delete/"+tt.detailID, nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestLikeDetail 测试点赞详情
func TestLikeDetail(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	detailController := NewDetailController()
	router.POST("/api/detail/:id/like", detailController.LikeDetail)

	tests := []struct {
		name           string
		detailID       string
		expectedStatus int
	}{
		{
			name:           "正常点赞",
			detailID:       "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效ID",
			detailID:       "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("POST", "/api/detail/"+tt.detailID+"/like", nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestShareDetail 测试分享详情
func TestShareDetail(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	detailController := NewDetailController()
	router.POST("/api/detail/:id/share", detailController.ShareDetail)

	tests := []struct {
		name           string
		detailID       string
		expectedStatus int
	}{
		{
			name:           "正常分享",
			detailID:       "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效ID",
			detailID:       "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("POST", "/api/detail/"+tt.detailID+"/share", nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestGetDetailStats 测试获取详情统计
func TestGetDetailStats(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	detailController := NewDetailController()
	router.GET("/api/detail/stats", detailController.GetDetailStats)

	req, err := http.NewRequest("GET", "/api/detail/stats", nil)
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
