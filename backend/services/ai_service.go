package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"
)

// AIProvider 定义AI服务提供商类型
type AIProvider string

const (
	ProviderGroq           AIProvider = "groq"
	ProviderTencentHunyuan AIProvider = "tencent_hunyuan"
	ProviderDeepSeek       AIProvider = "deepseek"
)

// AIConfig AI服务配置
type AIConfig struct {
	Provider    AIProvider    `json:"provider"`
	APIKey      string        `json:"api_key"`
	BaseURL     string        `json:"base_url"`
	Model       string        `json:"model"`
	MaxTokens   int           `json:"max_tokens"`
	Temperature float64       `json:"temperature"`
	Timeout     time.Duration `json:"timeout"`
}

// ChatMessage 聊天消息结构
type ChatMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

// ChatRequest 聊天请求结构
type ChatRequest struct {
	Messages    []ChatMessage `json:"messages"`
	Model       string        `json:"model,omitempty"`
	MaxTokens   int           `json:"max_tokens,omitempty"`
	Temperature float64       `json:"temperature,omitempty"`
	Stream      bool          `json:"stream,omitempty"`
}

// ChatResponse 聊天响应结构
type ChatResponse struct {
	ID      string `json:"id"`
	Object  string `json:"object"`
	Created int64  `json:"created"`
	Model   string `json:"model"`
	Choices []struct {
		Index   int `json:"index"`
		Message struct {
			Role    string `json:"role"`
			Content string `json:"content"`
		} `json:"message"`
		FinishReason string `json:"finish_reason"`
	} `json:"choices"`
	Usage struct {
		PromptTokens     int `json:"prompt_tokens"`
		CompletionTokens int `json:"completion_tokens"`
		TotalTokens      int `json:"total_tokens"`
	} `json:"usage"`
}

// TencentHunyuanRequest 腾讯混元请求结构
type TencentHunyuanRequest struct {
	Model       string        `json:"model"`
	Messages    []ChatMessage `json:"messages"`
	Temperature float64       `json:"temperature"`
	MaxTokens   int           `json:"max_tokens"`
	Stream      bool          `json:"stream"`
}

// TencentHunyuanResponse 腾讯混元响应结构
type TencentHunyuanResponse struct {
	ID      string `json:"id"`
	Object  string `json:"object"`
	Created int64  `json:"created"`
	Model   string `json:"model"`
	Choices []struct {
		Index   int `json:"index"`
		Message struct {
			Role    string `json:"role"`
			Content string `json:"content"`
		} `json:"message"`
		FinishReason string `json:"finish_reason"`
	} `json:"choices"`
	Usage struct {
		PromptTokens     int `json:"prompt_tokens"`
		CompletionTokens int `json:"completion_tokens"`
		TotalTokens      int `json:"total_tokens"`
	} `json:"usage"`
}

// AIService AI服务接口
type AIService interface {
	Chat(messages []ChatMessage) (*ChatResponse, error)
	GetProvider() AIProvider
	IsAvailable() bool
}

// GroqService Groq AI服务实现
type GroqService struct {
	config AIConfig
	client *http.Client
}

// NewGroqService 创建Groq服务
func NewGroqService() *GroqService {
	apiKey := os.Getenv("GROQ_API_KEY")
	if apiKey == "" {
		apiKey = "gsk_your_groq_api_key_here" // 默认值，实际使用时需要设置环境变量
	}

	return &GroqService{
		config: AIConfig{
			Provider:    ProviderGroq,
			APIKey:      apiKey,
			BaseURL:     "https://api.groq.com/openai/v1",
			Model:       "llama3-8b-8192",
			MaxTokens:   2048,
			Temperature: 0.7,
			Timeout:     30 * time.Second,
		},
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// Chat 发送聊天请求到Groq
func (g *GroqService) Chat(messages []ChatMessage) (*ChatResponse, error) {
	reqBody := ChatRequest{
		Messages:    messages,
		Model:       g.config.Model,
		MaxTokens:   g.config.MaxTokens,
		Temperature: g.config.Temperature,
		Stream:      false,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("marshal request failed: %v", err)
	}

	req, err := http.NewRequest("POST", g.config.BaseURL+"/chat/completions", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("create request failed: %v", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+g.config.APIKey)

	resp, err := g.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("groq api error: %d, %s", resp.StatusCode, string(body))
	}

	var chatResp ChatResponse
	if err := json.NewDecoder(resp.Body).Decode(&chatResp); err != nil {
		return nil, fmt.Errorf("decode response failed: %v", err)
	}

	return &chatResp, nil
}

// GetProvider 获取服务提供商
func (g *GroqService) GetProvider() AIProvider {
	return g.config.Provider
}

// IsAvailable 检查服务是否可用
func (g *GroqService) IsAvailable() bool {
	return g.config.APIKey != ""
}

// TencentHunyuanService 腾讯混元AI服务实现
type TencentHunyuanService struct {
	config AIConfig
	client *http.Client
}

// NewTencentHunyuanService 创建腾讯混元服务
func NewTencentHunyuanService() *TencentHunyuanService {
	secretId := os.Getenv("TENCENT_SECRET_ID")
	secretKey := os.Getenv("TENCENT_SECRET_KEY")

	if secretId == "" {
		secretId = "100032618506_100032618506_16a17a3a4bc2eba0534e7b25c4363fc8"
	}
	if secretKey == "" {
		secretKey = "sk-O5tVxVeCGTtSgPlaHMuPe9CdmgEUuy2d79yK5rf5Rp5qsI3m"
	}

	return &TencentHunyuanService{
		config: AIConfig{
			Provider:    ProviderTencentHunyuan,
			APIKey:      secretKey, // 使用secretKey作为APIKey
			BaseURL:     "https://hunyuan.tencentcloudapi.com",
			Model:       "hunyuan-lite",
			MaxTokens:   2048,
			Temperature: 0.7,
			Timeout:     30 * time.Second,
		},
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// Chat 发送聊天请求到腾讯混元
func (t *TencentHunyuanService) Chat(messages []ChatMessage) (*ChatResponse, error) {
	reqBody := TencentHunyuanRequest{
		Model:       t.config.Model,
		Messages:    messages,
		Temperature: t.config.Temperature,
		MaxTokens:   t.config.MaxTokens,
		Stream:      false,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("marshal request failed: %v", err)
	}

	req, err := http.NewRequest("POST", t.config.BaseURL+"/chat/completions", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("create request failed: %v", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+t.config.APIKey)

	resp, err := t.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("tencent hunyuan api error: %d, %s", resp.StatusCode, string(body))
	}

	var chatResp ChatResponse
	if err := json.NewDecoder(resp.Body).Decode(&chatResp); err != nil {
		return nil, fmt.Errorf("decode response failed: %v", err)
	}

	return &chatResp, nil
}

// GetProvider 获取服务提供商
func (t *TencentHunyuanService) GetProvider() AIProvider {
	return t.config.Provider
}

// IsAvailable 检查服务是否可用
func (t *TencentHunyuanService) IsAvailable() bool {
	return t.config.APIKey != ""
}

// AIServiceManager AI服务管理器
type AIServiceManager struct {
	services map[AIProvider]AIService
	current  AIProvider
}

// NewAIServiceManager 创建AI服务管理器
func NewAIServiceManager() *AIServiceManager {
	manager := &AIServiceManager{
		services: make(map[AIProvider]AIService),
	}

	// 初始化所有可用的AI服务
	groqService := NewGroqService()
	if groqService.IsAvailable() {
		manager.services[ProviderGroq] = groqService
	}

	tencentService := NewTencentHunyuanService()
	if tencentService.IsAvailable() {
		manager.services[ProviderTencentHunyuan] = tencentService
	}

	// 设置默认服务（优先级：Groq > 腾讯混元）
	if _, exists := manager.services[ProviderGroq]; exists {
		manager.current = ProviderGroq
	} else if _, exists := manager.services[ProviderTencentHunyuan]; exists {
		manager.current = ProviderTencentHunyuan
	}

	return manager
}

// Chat 发送聊天请求
func (m *AIServiceManager) Chat(messages []ChatMessage) (*ChatResponse, error) {
	// 定义服务优先级顺序：Groq优先，腾讯混元兜底
	priorityOrder := []AIProvider{ProviderGroq, ProviderTencentHunyuan}

	var lastErr error

	// 按优先级顺序尝试服务
	for _, provider := range priorityOrder {
		if service, exists := m.services[provider]; exists {
			resp, err := service.Chat(messages)
			if err == nil {
				// 成功则更新当前服务并返回
				m.current = provider
				return resp, nil
			}
			lastErr = err
			// 静默失败，继续尝试下一个服务
		}
	}

	// 所有服务都失败
	return nil, fmt.Errorf("所有AI服务都不可用，最后错误: %v", lastErr)
}

// SwitchProvider 切换AI服务提供商
func (m *AIServiceManager) SwitchProvider(provider AIProvider) error {
	if _, exists := m.services[provider]; !exists {
		return fmt.Errorf("provider %s not available", provider)
	}
	m.current = provider
	return nil
}

// GetAvailableProviders 获取所有可用的提供商
func (m *AIServiceManager) GetAvailableProviders() []AIProvider {
	var providers []AIProvider
	for provider := range m.services {
		providers = append(providers, provider)
	}
	return providers
}

// GetCurrentProvider 获取当前使用的提供商
func (m *AIServiceManager) GetCurrentProvider() AIProvider {
	return m.current
}

// GetServicePriority 获取服务优先级信息
func (m *AIServiceManager) GetServicePriority() map[string]int {
	priority := make(map[string]int)
	priorityOrder := []AIProvider{ProviderGroq, ProviderTencentHunyuan}

	for i, provider := range priorityOrder {
		priority[string(provider)] = i + 1
	}

	return priority
}

// GetAvailableServicesWithPriority 获取可用服务及其优先级
func (m *AIServiceManager) GetAvailableServicesWithPriority() []struct {
	Provider  string
	Priority  int
	Available bool
} {
	var services []struct {
		Provider  string
		Priority  int
		Available bool
	}

	priorityOrder := []AIProvider{ProviderGroq, ProviderTencentHunyuan}

	for i, provider := range priorityOrder {
		_, exists := m.services[provider]
		services = append(services, struct {
			Provider  string
			Priority  int
			Available bool
		}{
			Provider:  string(provider),
			Priority:  i + 1,
			Available: exists,
		})
	}

	return services
}

// GetServiceStatus 获取服务状态
func (m *AIServiceManager) GetServiceStatus() map[AIProvider]bool {
	status := make(map[AIProvider]bool)
	for provider, service := range m.services {
		status[provider] = service.IsAvailable()
	}
	return status
}

// 全局AI服务管理器实例
var GlobalAIManager *AIServiceManager

// InitAIServices 初始化AI服务
func InitAIServices() {
	GlobalAIManager = NewAIServiceManager()
}

// GetAIManager 获取AI管理器实例
func GetAIManager() *AIServiceManager {
	if GlobalAIManager == nil {
		InitAIServices()
	}
	return GlobalAIManager
}
