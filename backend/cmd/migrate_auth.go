package main

import (
	"fmt"
	"log"

	"gymates-backend/config"
	"gymates-backend/models"
)

// 认证系统数据库迁移脚本
// 运行方式: go run cmd/migrate_auth.go

func main() {
	fmt.Println("🔧 开始迁移认证系统数据库...")

	// 初始化数据库连接
	if err := config.InitDatabase(); err != nil {
		log.Fatalf("❌ 数据库连接失败: %v", err)
	}

	// 自动迁移新增的认证相关表
	fmt.Println("📊 正在创建/更新数据表...")

	err := config.DB.AutoMigrate(
		&models.User{},             // 用户表（更新字段）
		&models.VerificationCode{}, // 验证码表（新增）
		&models.RefreshToken{},     // 刷新令牌表（新增）
	)

	if err != nil {
		log.Fatalf("❌ 数据迁移失败: %v", err)
	}

	fmt.Println("✅ 数据表创建/更新成功！")

	// 显示表信息
	showTableInfo()

	fmt.Println("\n🎉 认证系统数据库迁移完成！")
	fmt.Println("\n📝 新增功能:")
	fmt.Println("   - 手机号登录（User.Phone字段）")
	fmt.Println("   - 社交登录（User.AppleID/GoogleID/WechatID字段）")
	fmt.Println("   - 游客模式（User.IsGuest字段）")
	fmt.Println("   - 验证码系统（VerificationCode表）")
	fmt.Println("   - 刷新令牌（RefreshToken表）")
	fmt.Println("\n🚀 现在可以使用新的认证功能了！")
}

func showTableInfo() {
	fmt.Println("\n📋 数据表信息:")

	// 统计用户数
	var userCount int64
	config.DB.Model(&models.User{}).Count(&userCount)
	fmt.Printf("   - users: %d 条记录\n", userCount)

	// 统计验证码数
	var codeCount int64
	config.DB.Model(&models.VerificationCode{}).Count(&codeCount)
	fmt.Printf("   - verification_codes: %d 条记录\n", codeCount)

	// 统计刷新令牌数
	var tokenCount int64
	config.DB.Model(&models.RefreshToken{}).Count(&tokenCount)
	fmt.Printf("   - refresh_tokens: %d 条记录\n", tokenCount)
}
