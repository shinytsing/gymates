package config

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"time"

	"gymates-backend/models"

	"gorm.io/driver/mysql"
	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

// DatabaseConfig 数据库配置
type DatabaseConfig struct {
	Type     string
	Host     string
	Port     string
	User     string
	Password string
	Name     string
	SSLMode  string
	Path     string // SQLite专用
}

// AppConfig 应用配置
type AppConfig struct {
	Host        string
	Port        string
	Environment string
	DBType      string
	MockData    bool
}

// GetDatabaseConfig 获取数据库配置
func GetDatabaseConfig() *DatabaseConfig {
	return &DatabaseConfig{
		Type:     getEnv("DB_TYPE", "sqlite"),
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "3306"),
		User:     getEnv("DB_USER", "root"),
		Password: getEnv("DB_PASSWORD", ""),
		Name:     getEnv("DB_NAME", "gymates"),
		SSLMode:  getEnv("DB_SSLMODE", "disable"),
		Path:     getEnv("DB_PATH", "gymates.db"),
	}
}

// GetAppConfig 获取应用配置
func GetAppConfig() *AppConfig {
	return &AppConfig{
		Host:        getEnv("HOST", "0.0.0.0"),
		Port:        getEnv("PORT", "8080"),
		Environment: getEnv("GIN_MODE", "debug"),
		DBType:      getEnv("DB_TYPE", "sqlite"),
		MockData:    getEnvBool("MOCK_DATA", true),
	}
}

// InitDB 初始化数据库
func InitDB() error {
	config := GetDatabaseConfig()
	var err error

	switch config.Type {
	case "mysql":
		DB, err = initMySQL(config)
	case "postgres":
		DB, err = initPostgreSQL(config)
	case "sqlite":
		DB, err = initSQLite(config)
	default:
		return fmt.Errorf("unsupported database type: %s", config.Type)
	}

	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}

	// 自动迁移
	if err := autoMigrate(); err != nil {
		return fmt.Errorf("failed to migrate database: %w", err)
	}

	// 初始化模拟数据
	if GetAppConfig().MockData {
		initMockData()
	}

	log.Printf("✅ Database connected successfully: %s", config.Type)
	return nil
}

// initMySQL 初始化MySQL连接
func initMySQL(config *DatabaseConfig) (*gorm.DB, error) {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		config.User, config.Password, config.Host, config.Port, config.Name)

	return gorm.Open(mysql.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
}

// initPostgreSQL 初始化PostgreSQL连接
func initPostgreSQL(config *DatabaseConfig) (*gorm.DB, error) {
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=%s TimeZone=Asia/Shanghai",
		config.Host, config.User, config.Password, config.Name, config.Port, config.SSLMode)

	return gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
}

// initSQLite 初始化SQLite连接
func initSQLite(config *DatabaseConfig) (*gorm.DB, error) {
	return gorm.Open(sqlite.Open(config.Path), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
}

// autoMigrate 自动迁移数据库表
func autoMigrate() error {
	return DB.AutoMigrate(
		&models.User{},
		&models.TrainingPlan{},
		&models.Exercise{},
		&models.WorkoutSession{},
		&models.Post{},
		&models.Comment{},
		&models.PostLike{},
		&models.Mate{},
		&models.Chat{},
		&models.Message{},
		&models.ChatParticipant{},
		&models.Achievement{},
		&models.Notification{},
		&models.HomeItem{},          // 添加首页数据项
		&models.DetailItem{},        // 添加详情数据项
		&models.PostDetail{},        // 添加帖子详情
		&models.ProfileDetail{},     // 添加用户资料详情
		&models.ChatDetail{},        // 添加聊天详情
		&models.AchievementDetail{}, // 添加成就详情
	)
}

// initMockData 初始化模拟数据
func initMockData() {
	log.Println("🔄 Initializing mock data...")

	// 检查是否已有数据
	var userCount int64
	DB.Model(&models.User{}).Count(&userCount)
	if userCount > 0 {
		log.Println("📊 Mock data already exists, skipping initialization")
		return
	}

	// 创建模拟用户
	users := []models.User{
		{
			ID:         1,
			Name:       "健身达人小王",
			Email:      "xiaowang@gymates.com",
			Password:   "$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi", // password
			Avatar:     "", // Empty avatar to avoid network errors
			Bio:        "热爱健身，追求健康生活",
			Location:   "北京市朝阳区",
			Age:        25,
			Height:     175.5,
			Weight:     70.0,
			Goal:       "增肌",
			Experience: "3年",
		},
		{
			ID:         2,
			Name:       "瑜伽女神小李",
			Email:      "xiaoli@gymates.com",
			Password:   "$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi", // password
			Avatar:     "", // Empty avatar to avoid network errors
			Bio:        "瑜伽教练，专注身心平衡",
			Location:   "上海市浦东新区",
			Age:        28,
			Height:     165.0,
			Weight:     55.0,
			Goal:       "塑形",
			Experience: "5年",
		},
		{
			ID:         3,
			Name:       "跑步爱好者小张",
			Email:      "xiaozhang@gymates.com",
			Password:   "$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi", // password
			Avatar:     "", // Empty avatar to avoid network errors
			Bio:        "马拉松跑者，享受跑步的快乐",
			Location:   "广州市天河区",
			Age:        30,
			Height:     180.0,
			Weight:     75.0,
			Goal:       "减脂",
			Experience: "2年",
		},
	}

	for _, user := range users {
		DB.Create(&user)
	}

	// 创建模拟训练计划
	trainingPlans := []models.TrainingPlan{
		{
			ID:             1,
			UserID:         1,
			Name:           "胸肌强化训练",
			Description:    "专注于胸肌的强化训练计划",
			Duration:       45,
			CaloriesBurned: 350,
			Difficulty:     "intermediate",
		},
		{
			ID:             2,
			UserID:         2,
			Name:           "瑜伽基础课程",
			Description:    "适合初学者的瑜伽基础课程",
			Duration:       60,
			CaloriesBurned: 200,
			Difficulty:     "beginner",
		},
		{
			ID:             3,
			UserID:         3,
			Name:           "跑步训练计划",
			Description:    "提升跑步耐力和速度的训练计划",
			Duration:       30,
			CaloriesBurned: 400,
			Difficulty:     "advanced",
		},
	}

	for _, plan := range trainingPlans {
		DB.Create(&plan)
	}

	// 创建模拟帖子
	posts := []models.Post{
		{
			ID:       1,
			UserID:   1,
			Content:  "今天的胸肌训练太棒了！感觉肌肉在燃烧🔥",
			Images:   "https://via.placeholder.com/400x300/FF6B6B/FFFFFF?text=胸肌训练",
			Type:     "image",
			Likes:    15,
			Comments: 8,
			Shares:   3,
		},
		{
			ID:       2,
			UserID:   2,
			Content:  "清晨的瑜伽练习，让身心都得到了放松🧘‍♀️",
			Images:   "https://via.placeholder.com/400x300/4ECDC4/FFFFFF?text=瑜伽练习",
			Type:     "image",
			Likes:    22,
			Comments: 12,
			Shares:   5,
		},
		{
			ID:       3,
			UserID:   3,
			Content:  "完成了10公里跑步，感觉棒极了！🏃‍♂️",
			Images:   "https://via.placeholder.com/400x300/45B7D1/FFFFFF?text=跑步",
			Type:     "image",
			Likes:    18,
			Comments: 6,
			Shares:   2,
		},
	}

	for _, post := range posts {
		DB.Create(&post)
	}

	// 创建模拟首页数据
	homeItems := []models.HomeItem{
		{
			Title:        "胸肌训练指南",
			Description:  "详细的胸肌训练方法和技巧",
			Image:        "https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=胸肌训练",
			Category:     "fitness",
			Status:       "published",
			Priority:     1,
			ViewCount:    150,
			LikeCount:    25,
			CommentCount: 8,
			Tags:         "胸肌,训练,健身,指南",
			UserID:       1,
		},
		{
			Title:        "瑜伽基础动作",
			Description:  "适合初学者的瑜伽基础动作教学",
			Image:        "https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=瑜伽基础",
			Category:     "yoga",
			Status:       "published",
			Priority:     2,
			ViewCount:    200,
			LikeCount:    35,
			CommentCount: 12,
			Tags:         "瑜伽,基础,动作,教学",
			UserID:       2,
		},
	}

	for _, item := range homeItems {
		DB.Create(&item)
	}

	log.Println("✅ Mock data initialized successfully")
}

// GetDB 获取数据库实例
func GetDB() *gorm.DB {
	return DB
}

// GetPort 获取端口
func GetPort() string {
	return getEnv("PORT", "8080")
}

// GetHost 获取主机
func GetHost() string {
	return getEnv("HOST", "0.0.0.0")
}

// GetDBType 获取数据库类型
func GetDBType() string {
	return getEnv("DB_TYPE", "sqlite")
}

// GetEnvironment 获取环境
func GetEnvironment() string {
	return getEnv("GIN_MODE", "debug")
}

// getEnv 获取环境变量，如果不存在则返回默认值
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// getEnvBool 获取布尔型环境变量
func getEnvBool(key string, defaultValue bool) bool {
	if value := os.Getenv(key); value != "" {
		if parsed, err := strconv.ParseBool(value); err == nil {
			return parsed
		}
	}
	return defaultValue
}

// GetAPIVersion 获取API版本
func GetAPIVersion() string {
	return getEnv("API_VERSION", "v1")
}

// GetJWTSecret 获取JWT密钥
func GetJWTSecret() string {
	secret := getEnv("JWT_SECRET", "gymates-secret-key")
	if secret == "gymates-secret-key" {
		log.Println("⚠️  Warning: Using default JWT secret. Please set JWT_SECRET environment variable in production.")
	}
	return secret
}

// GetJWTExpiration 获取JWT过期时间
func GetJWTExpiration() time.Duration {
	hours := getEnv("JWT_EXPIRATION_HOURS", "24")
	if parsed, err := strconv.Atoi(hours); err == nil {
		return time.Duration(parsed) * time.Hour
	}
	return 24 * time.Hour
}

// IsProduction 判断是否为生产环境
func IsProduction() bool {
	return getEnv("GIN_MODE", "debug") == "release"
}

// GetCORSOrigins 获取CORS允许的源
func GetCORSOrigins() []string {
	origins := getEnv("CORS_ORIGINS", "*")
	if origins == "*" {
		return []string{"*"}
	}
	// 这里可以解析逗号分隔的域名列表
	return []string{origins}
}
