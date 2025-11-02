package services

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/go-redis/redis/v8"
)

var (
	redisClient *redis.Client
	ctx         = context.Background()
)

// InitRedis 初始化Redis连接
func InitRedis(addr, password string, db int) error {
	redisClient = redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: password,
		DB:       db,
	})

	// 测试连接
	_, err := redisClient.Ping(ctx).Result()
	if err != nil {
		return fmt.Errorf("failed to connect to Redis: %w", err)
	}

	fmt.Println("✅ Redis connected successfully")
	return nil
}

// GetRedisClient 获取Redis客户端
func GetRedisClient() *redis.Client {
	return redisClient
}

// RedisService Redis服务
type RedisService struct{}

// NewRedisService 创建Redis服务
func NewRedisService() *RedisService {
	return &RedisService{}
}

// 缓存键前缀
const (
	PrefixMateRecommendations = "mate:recommendations:"
	PrefixUserProfile         = "user:profile:"
	PrefixGymSearch           = "gym:search:"
	PrefixOnlineUsers         = "online:users"
	PrefixChatMessages        = "chat:messages:"
)

// SetMateRecommendations 缓存搭子推荐
func (rs *RedisService) SetMateRecommendations(userID uint, data interface{}, ttl time.Duration) error {
	key := fmt.Sprintf("%s%d", PrefixMateRecommendations, userID)
	return rs.Set(key, data, ttl)
}

// GetMateRecommendations 获取搭子推荐缓存
func (rs *RedisService) GetMateRecommendations(userID uint, dest interface{}) error {
	key := fmt.Sprintf("%s%d", PrefixMateRecommendations, userID)
	return rs.Get(key, dest)
}

// SetUserProfile 缓存用户资料
func (rs *RedisService) SetUserProfile(userID uint, data interface{}, ttl time.Duration) error {
	key := fmt.Sprintf("%s%d", PrefixUserProfile, userID)
	return rs.Set(key, data, ttl)
}

// GetUserProfile 获取用户资料缓存
func (rs *RedisService) GetUserProfile(userID uint, dest interface{}) error {
	key := fmt.Sprintf("%s%d", PrefixUserProfile, userID)
	return rs.Get(key, dest)
}

// InvalidateUserProfile 使用户资料缓存失效
func (rs *RedisService) InvalidateUserProfile(userID uint) error {
	key := fmt.Sprintf("%s%d", PrefixUserProfile, userID)
	return rs.Delete(key)
}

// SetGymSearch 缓存健身房搜索结果
func (rs *RedisService) SetGymSearch(lat, lng float64, radius int, data interface{}, ttl time.Duration) error {
	key := fmt.Sprintf("%s%.4f:%.4f:%d", PrefixGymSearch, lat, lng, radius)
	return rs.Set(key, data, ttl)
}

// GetGymSearch 获取健身房搜索缓存
func (rs *RedisService) GetGymSearch(lat, lng float64, radius int, dest interface{}) error {
	key := fmt.Sprintf("%s%.4f:%.4f:%d", PrefixGymSearch, lat, lng, radius)
	return rs.Get(key, dest)
}

// AddOnlineUser 添加在线用户
func (rs *RedisService) AddOnlineUser(userID uint) error {
	return redisClient.SAdd(ctx, PrefixOnlineUsers, userID).Err()
}

// RemoveOnlineUser 移除在线用户
func (rs *RedisService) RemoveOnlineUser(userID uint) error {
	return redisClient.SRem(ctx, PrefixOnlineUsers, userID).Err()
}

// GetOnlineUsers 获取所有在线用户
func (rs *RedisService) GetOnlineUsers() ([]string, error) {
	return redisClient.SMembers(ctx, PrefixOnlineUsers).Result()
}

// IsUserOnline 检查用户是否在线
func (rs *RedisService) IsUserOnline(userID uint) (bool, error) {
	return redisClient.SIsMember(ctx, PrefixOnlineUsers, userID).Result()
}

// StoreChatMessage 存储聊天消息（用于离线消息）
func (rs *RedisService) StoreChatMessage(chatID uint, message interface{}) error {
	key := fmt.Sprintf("%s%d", PrefixChatMessages, chatID)
	data, err := json.Marshal(message)
	if err != nil {
		return err
	}

	// 使用List存储，保留最近100条消息
	pipe := redisClient.Pipeline()
	pipe.LPush(ctx, key, data)
	pipe.LTrim(ctx, key, 0, 99)           // 只保留最近100条
	pipe.Expire(ctx, key, 7*24*time.Hour) // 7天过期

	_, err = pipe.Exec(ctx)
	return err
}

// GetChatMessages 获取聊天消息
func (rs *RedisService) GetChatMessages(chatID uint, limit int) ([]string, error) {
	key := fmt.Sprintf("%s%d", PrefixChatMessages, chatID)
	return redisClient.LRange(ctx, key, 0, int64(limit-1)).Result()
}

// 通用方法

// Set 设置缓存
func (rs *RedisService) Set(key string, value interface{}, ttl time.Duration) error {
	data, err := json.Marshal(value)
	if err != nil {
		return err
	}
	return redisClient.Set(ctx, key, data, ttl).Err()
}

// Get 获取缓存
func (rs *RedisService) Get(key string, dest interface{}) error {
	val, err := redisClient.Get(ctx, key).Result()
	if err != nil {
		return err
	}
	return json.Unmarshal([]byte(val), dest)
}

// Delete 删除缓存
func (rs *RedisService) Delete(key string) error {
	return redisClient.Del(ctx, key).Err()
}

// Exists 检查键是否存在
func (rs *RedisService) Exists(key string) (bool, error) {
	n, err := redisClient.Exists(ctx, key).Result()
	return n > 0, err
}

// SetWithExpire 设置带过期时间的缓存
func (rs *RedisService) SetWithExpire(key string, value interface{}, seconds int) error {
	return rs.Set(key, value, time.Duration(seconds)*time.Second)
}

// Increment 递增计数器
func (rs *RedisService) Increment(key string) (int64, error) {
	return redisClient.Incr(ctx, key).Result()
}

// Decrement 递减计数器
func (rs *RedisService) Decrement(key string) (int64, error) {
	return redisClient.Decr(ctx, key).Result()
}

// SetNX 只在键不存在时设置
func (rs *RedisService) SetNX(key string, value interface{}, ttl time.Duration) (bool, error) {
	data, err := json.Marshal(value)
	if err != nil {
		return false, err
	}
	return redisClient.SetNX(ctx, key, data, ttl).Result()
}

// TTL 获取键的剩余生存时间
func (rs *RedisService) TTL(key string) (time.Duration, error) {
	return redisClient.TTL(ctx, key).Result()
}

// Expire 设置键的过期时间
func (rs *RedisService) Expire(key string, ttl time.Duration) error {
	return redisClient.Expire(ctx, key, ttl).Err()
}

// FlushDB 清空当前数据库（慎用）
func (rs *RedisService) FlushDB() error {
	return redisClient.FlushDB(ctx).Err()
}
