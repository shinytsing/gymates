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

// TestGetPosts 测试获取帖子列表
func TestGetPosts(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	communityController := NewCommunityController()
	router.GET("/api/community/posts", communityController.GetPosts)

	tests := []struct {
		name           string
		queryParams    string
		expectedStatus int
		expectData     bool
	}{
		{
			name:           "正常获取帖子列表",
			queryParams:    "?page=1&limit=10",
			expectedStatus: http.StatusOK,
			expectData:     true,
		},
		{
			name:           "带类型筛选",
			queryParams:    "?page=1&limit=10&type=image",
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
			name:           "默认参数",
			queryParams:    "",
			expectedStatus: http.StatusOK,
			expectData:     true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("GET", "/api/community/posts"+tt.queryParams, nil)
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

// TestGetPost 测试获取单个帖子
func TestGetPost(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	communityController := NewCommunityController()
	router.GET("/api/community/posts/:id", communityController.GetPost)

	tests := []struct {
		name           string
		postID         string
		expectedStatus int
	}{
		{
			name:           "正常获取帖子",
			postID:         "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效ID",
			postID:         "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("GET", "/api/community/posts/"+tt.postID, nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestCreatePost 测试创建帖子
func TestCreatePost(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	communityController := NewCommunityController()
	router.POST("/api/community/posts", communityController.CreatePost)

	tests := []struct {
		name           string
		requestBody    interface{}
		expectedStatus int
		expectSuccess  bool
	}{
		{
			name: "正常创建文本帖子",
			requestBody: models.CreatePostRequest{
				Content: "今天训练很累，但是很有成就感！",
				Type:    "text",
			},
			expectedStatus: http.StatusCreated,
			expectSuccess:  true,
		},
		{
			name: "正常创建图片帖子",
			requestBody: models.CreatePostRequest{
				Content: "分享今天的训练照片",
				Type:    "image",
				Images:  []string{"https://example.com/image.jpg"},
			},
			expectedStatus: http.StatusCreated,
			expectSuccess:  true,
		},
		{
			name: "缺少必填字段",
			requestBody: models.CreatePostRequest{
				Type: "text",
				// 缺少content
			},
			expectedStatus: http.StatusBadRequest,
			expectSuccess:  false,
		},
		{
			name: "内容太长",
			requestBody: models.CreatePostRequest{
				Content: "这是一个非常长的内容..." + string(make([]byte, 1000)), // 超过1000字符
				Type:    "text",
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

			req, err := http.NewRequest("POST", "/api/community/posts", bytes.NewBuffer(jsonValue))
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

// TestLikePost 测试点赞帖子
func TestLikePost(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	communityController := NewCommunityController()
	router.POST("/api/community/posts/:id/like", communityController.LikePost)

	tests := []struct {
		name           string
		postID         string
		expectedStatus int
	}{
		{
			name:           "正常点赞",
			postID:         "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效ID",
			postID:         "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("POST", "/api/community/posts/"+tt.postID+"/like", nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestUnlikePost 测试取消点赞
func TestUnlikePost(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	communityController := NewCommunityController()
	router.DELETE("/api/community/posts/:id/like", communityController.UnlikePost)

	tests := []struct {
		name           string
		postID         string
		expectedStatus int
	}{
		{
			name:           "正常取消点赞",
			postID:         "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效ID",
			postID:         "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("DELETE", "/api/community/posts/"+tt.postID+"/like", nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// TestGetComments 测试获取评论
func TestGetComments(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	communityController := NewCommunityController()
	router.GET("/api/community/posts/:id/comments", communityController.GetComments)

	tests := []struct {
		name           string
		postID         string
		queryParams    string
		expectedStatus int
		expectData     bool
	}{
		{
			name:           "正常获取评论",
			postID:         "1",
			queryParams:    "?page=1&limit=10",
			expectedStatus: http.StatusOK,
			expectData:     true,
		},
		{
			name:           "默认参数",
			postID:         "1",
			queryParams:    "",
			expectedStatus: http.StatusOK,
			expectData:     true,
		},
		{
			name:           "无效帖子ID",
			postID:         "invalid",
			queryParams:    "?page=1&limit=10",
			expectedStatus: http.StatusBadRequest,
			expectData:     false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("GET", "/api/community/posts/"+tt.postID+"/comments"+tt.queryParams, nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			if tt.expectData {
				var response models.SuccessResponse
				err = json.Unmarshal(w.Body.Bytes(), &response)
				assert.NoError(t, err)
				assert.True(t, response.Success)
				assert.NotNil(t, response.Data)
			}
		})
	}
}

// TestAddComment 测试添加评论
func TestAddComment(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	communityController := NewCommunityController()
	router.POST("/api/community/posts/:id/comments", communityController.CreateComment)

	tests := []struct {
		name           string
		postID         string
		requestBody    interface{}
		expectedStatus int
		expectSuccess  bool
	}{
		{
			name:   "正常添加评论",
			postID: "1",
			requestBody: models.AddCommentRequest{
				Content: "很棒的训练！",
			},
			expectedStatus: http.StatusCreated,
			expectSuccess:  true,
		},
		{
			name:   "评论内容为空",
			postID: "1",
			requestBody: models.AddCommentRequest{
				Content: "",
			},
			expectedStatus: http.StatusBadRequest,
			expectSuccess:  false,
		},
		{
			name:           "无效帖子ID",
			postID:         "invalid",
			requestBody:    models.AddCommentRequest{Content: "测试评论"},
			expectedStatus: http.StatusBadRequest,
			expectSuccess:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			jsonValue, err := json.Marshal(tt.requestBody)
			assert.NoError(t, err)

			req, err := http.NewRequest("POST", "/api/community/posts/"+tt.postID+"/comments", bytes.NewBuffer(jsonValue))
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

// TestDeleteComment 测试删除评论
func TestDeleteComment(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()
	communityController := NewCommunityController()
	router.DELETE("/api/community/comments/:id", communityController.CreateComment)

	tests := []struct {
		name           string
		commentID      string
		expectedStatus int
	}{
		{
			name:           "正常删除评论",
			commentID:      "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效评论ID",
			commentID:      "invalid",
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("DELETE", "/api/community/comments/"+tt.commentID, nil)
			assert.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}
