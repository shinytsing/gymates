package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	// 简单的健康检查
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "healthy",
			"timestamp": time.Now().Format(time.RFC3339),
			"version":   "1.0.0",
		})
	})

	// 简单的API测试
	r.GET("/api/test", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "API is working",
			"time":    time.Now().Format(time.RFC3339),
		})
	})

	fmt.Println("🚀 Simple test server starting on port 8080...")
	fmt.Println("📍 Health check: http://localhost:8080/health")
	fmt.Println("📍 API test: http://localhost:8080/api/test")

	r.Run(":8080")
}
