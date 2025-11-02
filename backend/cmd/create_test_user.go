package main

import (
	"fmt"
	"log"
	"os"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// User 用户模型（简化版，与models中的结构匹配）
type User struct {
	ID       uint   `gorm:"primaryKey"`
	Name     string `gorm:"size:100;not null"`
	Email    string `gorm:"size:100;uniqueIndex"`
	Password string `gorm:"size:255"`
}

func main() {
	// 连接数据库
	dbPath := "gymates.db"
	if _, err := os.Stat(dbPath); os.IsNotExist(err) {
		fmt.Printf("❌ 数据库文件不存在: %s\n", dbPath)
		fmt.Println("请先启动后端服务初始化数据库")
		os.Exit(1)
	}

	db, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		log.Fatalf("❌ 连接数据库失败: %v", err)
	}

	// 加密密码
	password := "123456"
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		log.Fatalf("❌ 密码加密失败: %v", err)
	}

	// 测试用户信息
	testUsers := []struct {
		name  string
		email string
	}{
		{"测试用户", "test@gymates.com"},
		{"Demo用户", "demo@gymates.com"},
		{"张三", "zhangsan@gymates.com"},
	}

	fmt.Println("🔧 正在创建测试用户...")
	fmt.Println("")

	for _, u := range testUsers {
		// 检查用户是否已存在
		var existingUser User
		result := db.Where("email = ?", u.email).First(&existingUser)
		
		if result.Error == nil {
			fmt.Printf("⚠️  用户已存在: %s (%s)\n", u.name, u.email)
			fmt.Printf("   密码: %s\n", password)
			fmt.Println("")
			continue
		}

		// 创建新用户
		user := User{
			Name:     u.name,
			Email:    u.email,
			Password: string(hashedPassword),
		}

		if err := db.Create(&user).Error; err != nil {
			fmt.Printf("❌ 创建用户失败 %s: %v\n", u.name, err)
			continue
		}

		fmt.Printf("✅ 用户创建成功:\n")
		fmt.Printf("   姓名: %s\n", u.name)
		fmt.Printf("   邮箱: %s\n", u.email)
		fmt.Printf("   密码: %s\n", password)
		fmt.Println("")
	}

	fmt.Println("✨ 完成！")
	fmt.Println("")
	fmt.Println("📝 测试账号信息:")
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	for i, u := range testUsers {
		fmt.Printf("账号 %d:\n", i+1)
		fmt.Printf("  邮箱: %s\n", u.email)
		fmt.Printf("  密码: %s\n", password)
		fmt.Println("")
	}
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
}

