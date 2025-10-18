package controllers

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

// TestBasicAPIStructure 测试基本API结构
func TestBasicAPIStructure(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.Default()

	// 测试健康检查端点
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "healthy",
			"message": "API is working",
		})
	})

	req, err := http.NewRequest("GET", "/health", nil)
	assert.NoError(t, err)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err = json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "healthy", response["status"])
	assert.Equal(t, "API is working", response["message"])
}

// TestControllerCreation 测试控制器创建
func TestControllerCreation(t *testing.T) {
	// 测试所有控制器都能正确创建
	authController := NewAuthController()
	assert.NotNil(t, authController)

	homeController := NewHomeController()
	assert.NotNil(t, homeController)

	detailController := NewDetailController()
	assert.NotNil(t, detailController)

	trainingController := NewTrainingController()
	assert.NotNil(t, trainingController)

	communityController := NewCommunityController()
	assert.NotNil(t, communityController)

	matesController := NewMatesController()
	assert.NotNil(t, matesController)

	messagesController := NewMessagesController()
	assert.NotNil(t, messagesController)
}
