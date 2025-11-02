package services

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"sync"
	"time"

	"gymates-backend/config"
	"gymates-backend/models"
)

// SMSService 短信服务
type SMSService struct {
	rateLimiter *RateLimiter
}

// RateLimiter 速率限制器
type RateLimiter struct {
	mu      sync.Mutex
	records map[string][]time.Time
}

var smsService *SMSService
var smsOnce sync.Once

// GetSMSService 获取短信服务单例
func GetSMSService() *SMSService {
	smsOnce.Do(func() {
		smsService = &SMSService{
			rateLimiter: &RateLimiter{
				records: make(map[string][]time.Time),
			},
		}
	})
	return smsService
}

// SendVerificationCode 发送验证码
func (s *SMSService) SendVerificationCode(phone string, codeType string) (string, error) {
	// 检查速率限制
	if !s.rateLimiter.Allow(phone) {
		return "", fmt.Errorf("发送频率过快，请稍后再试")
	}

	// 生成6位数字验证码
	code, err := s.generateCode(6)
	if err != nil {
		return "", fmt.Errorf("生成验证码失败: %v", err)
	}

	// 保存验证码到数据库
	verificationCode := models.VerificationCode{
		Phone:     phone,
		Code:      code,
		Type:      codeType,
		ExpiresAt: time.Now().Add(5 * time.Minute), // 5分钟过期
		IsUsed:    false,
	}

	if err := config.DB.Create(&verificationCode).Error; err != nil {
		return "", fmt.Errorf("保存验证码失败: %v", err)
	}

	// 模拟发送短信（开发环境）
	// 生产环境应该调用实际的短信服务API（如阿里云、腾讯云等）
	fmt.Printf("📱 【模拟短信】手机号: %s, 验证码: %s, 类型: %s (5分钟内有效)\n", phone, code, codeType)

	return code, nil
}

// VerifyCode 验证验证码
func (s *SMSService) VerifyCode(phone string, code string, codeType string) (bool, error) {
	var verificationCode models.VerificationCode

	// 查找最新的未使用的验证码
	err := config.DB.Where(
		"phone = ? AND code = ? AND type = ? AND is_used = false AND expires_at > ?",
		phone, code, codeType, time.Now(),
	).Order("created_at DESC").First(&verificationCode).Error

	if err != nil {
		return false, fmt.Errorf("验证码无效或已过期")
	}

	// 标记验证码为已使用
	now := time.Now()
	verificationCode.IsUsed = true
	verificationCode.UsedAt = &now

	if err := config.DB.Save(&verificationCode).Error; err != nil {
		return false, fmt.Errorf("更新验证码状态失败: %v", err)
	}

	return true, nil
}

// generateCode 生成随机数字验证码
func (s *SMSService) generateCode(length int) (string, error) {
	const digits = "0123456789"
	code := make([]byte, length)

	for i := range code {
		num, err := rand.Int(rand.Reader, big.NewInt(int64(len(digits))))
		if err != nil {
			return "", err
		}
		code[i] = digits[num.Int64()]
	}

	return string(code), nil
}

// Allow 检查是否允许发送（速率限制）
func (rl *RateLimiter) Allow(phone string) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	now := time.Now()
	maxRequests := 3          // 最大请求次数
	window := 1 * time.Minute // 时间窗口

	// 获取该手机号的请求记录
	if records, exists := rl.records[phone]; exists {
		// 清理过期记录
		validRecords := []time.Time{}
		for _, t := range records {
			if now.Sub(t) < window {
				validRecords = append(validRecords, t)
			}
		}
		rl.records[phone] = validRecords

		// 检查是否超过限制
		if len(validRecords) >= maxRequests {
			return false
		}
	}

	// 记录当前请求
	rl.records[phone] = append(rl.records[phone], now)
	return true
}

// CleanExpiredCodes 清理过期的验证码（定时任务）
func (s *SMSService) CleanExpiredCodes() error {
	return config.DB.Where("expires_at < ? OR is_used = true", time.Now().Add(-24*time.Hour)).
		Delete(&models.VerificationCode{}).Error
}

// GetLastCodeSentTime 获取最后一次发送验证码的时间
func (s *SMSService) GetLastCodeSentTime(phone string) (*time.Time, error) {
	var verificationCode models.VerificationCode

	err := config.DB.Where("phone = ?", phone).
		Order("created_at DESC").
		First(&verificationCode).Error

	if err != nil {
		return nil, err
	}

	return &verificationCode.CreatedAt, nil
}
