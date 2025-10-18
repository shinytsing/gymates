package config

import (
	"os"
	"testing"
)

// TestConfig 测试配置
type TestConfig struct {
	DBType     string
	DBPath     string
	DBUser     string
	DBPassword string
	DBHost     string
	DBPort     string
	DBName     string
	Host       string
	Port       string
	GinMode    string
	JWTSecret  string
}

// GetTestConfig 获取测试配置
func GetTestConfig() *TestConfig {
	return &TestConfig{
		DBType:     getEnvTest("DB_TYPE", "sqlite"),
		DBPath:     getEnvTest("DB_PATH", ":memory:"),
		DBUser:     getEnvTest("DB_USER", "test"),
		DBPassword: getEnvTest("DB_PASSWORD", "test"),
		DBHost:     getEnvTest("DB_HOST", "localhost"),
		DBPort:     getEnvTest("DB_PORT", "3306"),
		DBName:     getEnvTest("DB_NAME", "test_gymates"),
		Host:       getEnvTest("HOST", "localhost"),
		Port:       getEnvTest("PORT", "3001"),
		GinMode:    getEnvTest("GIN_MODE", "test"),
		JWTSecret:  getEnvTest("JWT_SECRET", "test-secret-key-for-testing-only"),
	}
}

// SetupTestEnvironment 设置测试环境
func SetupTestEnvironment() {
	config := GetTestConfig()

	// 设置环境变量
	os.Setenv("DB_TYPE", config.DBType)
	os.Setenv("DB_PATH", config.DBPath)
	os.Setenv("DB_USER", config.DBUser)
	os.Setenv("DB_PASSWORD", config.DBPassword)
	os.Setenv("DB_HOST", config.DBHost)
	os.Setenv("DB_PORT", config.DBPort)
	os.Setenv("DB_NAME", config.DBName)
	os.Setenv("HOST", config.Host)
	os.Setenv("PORT", config.Port)
	os.Setenv("GIN_MODE", config.GinMode)
	os.Setenv("JWT_SECRET", config.JWTSecret)
}

// CleanupTestEnvironment 清理测试环境
func CleanupTestEnvironment() {
	// 清理环境变量
	os.Unsetenv("DB_TYPE")
	os.Unsetenv("DB_PATH")
	os.Unsetenv("DB_USER")
	os.Unsetenv("DB_PASSWORD")
	os.Unsetenv("DB_HOST")
	os.Unsetenv("DB_PORT")
	os.Unsetenv("DB_NAME")
	os.Unsetenv("HOST")
	os.Unsetenv("PORT")
	os.Unsetenv("GIN_MODE")
	os.Unsetenv("JWT_SECRET")
}

// TestMain 测试主函数
func TestMain(m *testing.M) {
	// 设置测试环境
	SetupTestEnvironment()

	// 运行测试
	code := m.Run()

	// 清理测试环境
	CleanupTestEnvironment()

	os.Exit(code)
}

// getEnv 获取环境变量，如果不存在则返回默认值
func getEnvTest(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
