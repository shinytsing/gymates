package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"gymates-backend/config"
	"gymates-backend/middleware"
	"gymates-backend/routes"
	"gymates-backend/services"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// 加载环境变量
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// 初始化数据库
	if err := config.InitDB(); err != nil {
		log.Fatal("Failed to initialize database:", err)
	}

	// 初始化AI服务
	services.InitAIServices()
	log.Println("🤖 AI Services initialized")

	// 设置Gin模式
	if os.Getenv("GIN_MODE") == "release" {
		gin.SetMode(gin.ReleaseMode)
	}

	// 创建Gin引擎
	r := gin.New()

	// 添加中间件
	setupMiddleware(r)

	// 设置路由
	routes.SetupRoutes(r)

	// 获取配置
	port := config.GetPort()
	host := config.GetHost()

	// 启动信息
	log.Printf("🚀 Gymates Backend Server Starting...")
	log.Printf("📍 Host: %s", host)
	log.Printf("🔌 Port: %s", port)
	log.Printf("🌐 API Base URL: http://%s:%s/api", host, port)
	log.Printf("🏥 Health Check: http://%s:%s/health", host, port)
	log.Printf("📚 API Docs: http://%s:%s/api", host, port)
	log.Printf("🗄️  Database: %s", config.GetDBType())
	log.Printf("🔧 Environment: %s", config.GetEnvironment())
	log.Printf("=====================================")

	// 启动服务器
	server := &http.Server{
		Addr:           fmt.Sprintf("%s:%s", host, port),
		Handler:        r,
		ReadTimeout:    30 * time.Second,
		WriteTimeout:   30 * time.Second,
		MaxHeaderBytes: 1 << 20, // 1MB
	}

	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal("Failed to start server:", err)
	}
}

// setupMiddleware 设置中间件
func setupMiddleware(r *gin.Engine) {
	// 恢复中间件
	r.Use(gin.Recovery())

	// 日志中间件
	r.Use(gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		return fmt.Sprintf("[%s] %s %s %d %s %s %s\n",
			param.TimeStamp.Format("2006/01/02 15:04:05"),
			param.ClientIP,
			param.Method,
			param.StatusCode,
			param.Latency,
			param.Path,
			param.ErrorMessage,
		)
	}))

	// CORS中间件
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"}, // 生产环境应该限制具体域名
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// 请求ID中间件
	r.Use(middleware.RequestIDMiddleware())

	// 限流中间件
	r.Use(middleware.RateLimitMiddleware())

	// 错误处理中间件
	r.Use(middleware.ErrorHandlerMiddleware())
}
