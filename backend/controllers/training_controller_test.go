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

// TestGetTrainingPlans 测试获取训练计划列表
func TestGetTrainingPlans(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	trainingController := NewTrainingController()
	router.GET("/api/training/plans", trainingController.GetTrainingPlans)

	tests := []struct {
		name           string
		queryParams    string
		expectedStatus int
		expectData     bool
	}{
		{
			name:           "正常获取训练计划",
			queryParams:    "?page=1&limit=10",
			expectedStatus: http.StatusOK,
			expectData:     true,
		},
		{
			name:           "默认参数",
			queryParams:    "",
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
			req, err := http.NewRequest("GET", "/api/training/plans"+tt.queryParams, nil)
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

// TestGetTrainingPlan 测试获取单个训练计划
func TestGetTrainingPlan(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	trainingController := NewTrainingController()
	router.GET("/api/training/plans/:id", trainingController.GetTrainingPlan)

	tests := []struct {
		name           string
		planID         string
		expectedStatus int
	}{
		{
			name:           "正常获取训练计划",
			planID:         "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效ID",
			planID:         "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("GET", "/api/training/plans/"+tt.planID, nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestCreateTrainingPlan 测试创建训练计划
func TestCreateTrainingPlan(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	trainingController := NewTrainingController()
	router.POST("/api/training/plans", trainingController.CreateTrainingPlan)

	tests := []struct {
		name           string
		requestBody    interface{}
		expectedStatus int
		expectSuccess  bool
	}{
		{
			name: "正常创建训练计划",
			requestBody: models.CreateTrainingPlanRequest{
				Name:        "胸肌训练计划",
				Description: "专注于胸肌的强化训练",
				Duration:    45,
				Difficulty:  "intermediate",
				Exercises: []models.Exercise{
					{
						Name:     "平板卧推",
						Sets:     3,
						Reps:     12,
						Weight:   60,
						RestTime: 60,
					},
				},
			},
			expectedStatus: http.StatusCreated,
			expectSuccess:  true,
		},
		{
			name: "缺少必填字段",
			requestBody: models.CreateTrainingPlanRequest{
				Description: "缺少名称",
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

			req, err := http.NewRequest("POST", "/api/training/plans", bytes.NewBuffer(jsonValue))
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

// TestStartWorkoutSession 测试开始训练会话
func TestStartWorkoutSession(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	trainingController := NewTrainingController()
	router.POST("/api/training/sessions", trainingController.StartWorkoutSession)

	tests := []struct {
		name           string
		requestBody    interface{}
		expectedStatus int
		expectSuccess  bool
	}{
		{
			name: "正常开始训练会话",
			requestBody: models.StartWorkoutSessionRequest{
				TrainingPlanID: 1,
			},
			expectedStatus: http.StatusCreated,
			expectSuccess:  true,
		},
		{
			name: "缺少训练计划ID",
			requestBody: models.StartWorkoutSessionRequest{
				TrainingPlanID: 0,
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

			req, err := http.NewRequest("POST", "/api/training/sessions", bytes.NewBuffer(jsonValue))
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

// TestUpdateWorkoutProgress 测试更新训练进度
func TestUpdateWorkoutProgress(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	trainingController := NewTrainingController()
	router.PUT("/api/training/sessions/:id/progress", trainingController.UpdateWorkoutProgress)

	tests := []struct {
		name           string
		sessionID      string
		requestBody    interface{}
		expectedStatus int
	}{
		{
			name:      "正常更新进度",
			sessionID: "1",
			requestBody: models.UpdateWorkoutProgressRequest{
				Progress: 50,
			},
			expectedStatus: http.StatusOK,
		},
		{
			name:      "无效进度值",
			sessionID: "1",
			requestBody: models.UpdateWorkoutProgressRequest{
				Progress: 150, // 超过100%
			},
			expectedStatus: http.StatusBadRequest,
		},
		{
			name:           "无效会话ID",
			sessionID:      "invalid",
			requestBody:    models.UpdateWorkoutProgressRequest{Progress: 50},
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			jsonValue, err := json.Marshal(tt.requestBody)
			assert.NoError(t, err)

			req, err := http.NewRequest("PUT", "/api/training/sessions/"+tt.sessionID+"/progress", bytes.NewBuffer(jsonValue))
			assert.NoError(t, err)
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestCompleteWorkoutSession 测试完成训练会话
func TestCompleteWorkoutSession(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	trainingController := NewTrainingController()
	router.POST("/api/training/sessions/:id/complete", trainingController.CompleteWorkoutSession)

	tests := []struct {
		name           string
		sessionID      string
		expectedStatus int
	}{
		{
			name:           "正常完成训练",
			sessionID:      "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效会话ID",
			sessionID:      "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("POST", "/api/training/sessions/"+tt.sessionID+"/complete", nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestGetWorkoutHistory 测试获取训练历史
func TestGetWorkoutHistory(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	trainingController := NewTrainingController()
	router.GET("/api/training/history", trainingController.GetWorkoutHistory)

	tests := []struct {
		name           string
		queryParams    string
		expectedStatus int
		expectData     bool
	}{
		{
			name:           "正常获取训练历史",
			queryParams:    "?page=1&limit=10",
			expectedStatus: http.StatusOK,
			expectData:     true,
		},
		{
			name:           "默认参数",
			queryParams:    "",
			expectedStatus: http.StatusOK,
			expectData:     true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("GET", "/api/training/history"+tt.queryParams, nil)
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
