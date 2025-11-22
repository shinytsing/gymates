package models

// LLMProvider LLM提供商枚举
type LLMProvider string

const (
	// 免费LLM
	TencentHunyuan LLMProvider = "tencent"
	Groq           LLMProvider = "groq"
	
	// 付费LLM
	DeepSeek   LLMProvider = "deepseek"
	OpenAI     LLMProvider = "openai"
	Anthropic  LLMProvider = "anthropic"
	ZhipuAI    LLMProvider = "zhipu"
	TongyiQwen LLMProvider = "tongyi"
	Gemini     LLMProvider = "gemini"
)

// LLMConfig LLM配置
type LLMConfig struct {
	Provider           LLMProvider `json:"provider"`
	Name               string      `json:"name"`
	DisplayName        string      `json:"display_name"`
	Description        string      `json:"description"`
	Icon               string      `json:"icon"`
	IsAvailable        bool        `json:"is_available"`
	IsFree             bool        `json:"is_free"`              // 是否免费
	RequiresMembership bool        `json:"requires_membership"`  // 是否需要会员
	Features           []string    `json:"features"`
	Pricing            LLMPricing  `json:"pricing"`
}

// LLMPricing LLM价格信息
type LLMPricing struct {
	InputPrice  string `json:"input_price"`   // 输入价格描述
	OutputPrice string `json:"output_price"`  // 输出价格描述
	Currency    string `json:"currency"`      // 货币单位
	AvgCost     string `json:"avg_cost"`      // 平均成本
}

// UserLLMPreference 用户LLM偏好
type UserLLMPreference struct {
	ID        uint        `json:"id" gorm:"primaryKey"`
	UserID    uint        `json:"user_id" gorm:"index"`
	Provider  LLMProvider `json:"provider"`
	CreatedAt int64       `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt int64       `json:"updated_at" gorm:"autoUpdateTime"`
}

// GetLLMConfigsRequest 获取LLM配置列表请求
type GetLLMConfigsRequest struct{}

// GetLLMConfigsResponse 获取LLM配置列表响应
type GetLLMConfigsResponse struct {
	Configs          []LLMConfig `json:"configs"`
	CurrentProvider  LLMProvider `json:"current_provider"`
	RecommendedProvider LLMProvider `json:"recommended_provider"`
}

// SetUserLLMProviderRequest 设置用户LLM提供商请求
type SetUserLLMProviderRequest struct {
	Provider LLMProvider `json:"provider" binding:"required"`
}

// TestLLMConnectionRequest 测试LLM连接请求
type TestLLMConnectionRequest struct {
	Provider LLMProvider `json:"provider" binding:"required"`
}

// TestLLMConnectionResponse 测试LLM连接响应
type TestLLMConnectionResponse struct {
	Success     bool   `json:"success"`
	Message     string `json:"message"`
	ResponseTime int64  `json:"response_time_ms"` // 响应时间（毫秒）
}

