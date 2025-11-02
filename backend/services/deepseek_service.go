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

// DeepSeekService DeepSeek AI服务
type DeepSeekService struct {
	APIKey  string
	BaseURL string
	Client  *http.Client
}

// DeepSeekRequest 请求结构
type DeepSeekRequest struct {
	Model       string        `json:"model"`
	Messages    []ChatMessage `json:"messages"`
	Temperature float64       `json:"temperature,omitempty"`
	MaxTokens   int           `json:"max_tokens,omitempty"`
	Stream      bool          `json:"stream,omitempty"`
}

// DeepSeekResponse 响应结构
type DeepSeekResponse struct {
	ID      string `json:"id"`
	Object  string `json:"object"`
	Created int64  `json:"created"`
	Model   string `json:"model"`
	Choices []struct {
		Index   int         `json:"index"`
		Message ChatMessage `json:"message"`
		Finish  string      `json:"finish_reason"`
	} `json:"choices"`
	Usage struct {
		PromptTokens     int `json:"prompt_tokens"`
		CompletionTokens int `json:"completion_tokens"`
		TotalTokens      int `json:"total_tokens"`
	} `json:"usage"`
}

// NewDeepSeekService 创建DeepSeek服务实例
func NewDeepSeekService() *DeepSeekService {
	apiKey := os.Getenv("DEEPSEEK_API_KEY")
	baseURL := os.Getenv("DEEPSEEK_API_URL")

	if baseURL == "" {
		baseURL = "https://api.deepseek.com/v1"
	}

	return &DeepSeekService{
		APIKey:  apiKey,
		BaseURL: baseURL,
		Client: &http.Client{
			Timeout: 60 * time.Second,
		},
	}
}

// Chat 发送聊天请求
func (s *DeepSeekService) Chat(messages []ChatMessage, temperature float64) (*DeepSeekResponse, error) {
	if s.APIKey == "" {
		return nil, fmt.Errorf("DeepSeek API key not configured")
	}

	// 构建请求
	reqBody := DeepSeekRequest{
		Model:       "deepseek-chat",
		Messages:    messages,
		Temperature: temperature,
		MaxTokens:   2000,
		Stream:      false,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// 创建HTTP请求
	url := fmt.Sprintf("%s/chat/completions", s.BaseURL)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", s.APIKey))

	// 发送请求
	resp, err := s.Client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	// 读取响应
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// 检查HTTP状态码
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API returned status %d: %s", resp.StatusCode, string(body))
	}

	// 解析响应
	var deepseekResp DeepSeekResponse
	if err := json.Unmarshal(body, &deepseekResp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response: %w", err)
	}

	return &deepseekResp, nil
}

// GenerateResponse 生成AI回复（简化接口）
func (s *DeepSeekService) GenerateResponse(userMessage string, systemPrompt string) (string, error) {
	messages := []ChatMessage{}

	// 添加系统提示词
	if systemPrompt != "" {
		messages = append(messages, ChatMessage{
			Role:    "system",
			Content: systemPrompt,
		})
	}

	// 添加用户消息
	messages = append(messages, ChatMessage{
		Role:    "user",
		Content: userMessage,
	})

	// 调用API
	resp, err := s.Chat(messages, 0.7)
	if err != nil {
		return "", err
	}

	// 提取回复内容
	if len(resp.Choices) == 0 {
		return "", fmt.Errorf("no response from API")
	}

	return resp.Choices[0].Message.Content, nil
}

// GenerateFitnessAdvice 生成健身建议
func (s *DeepSeekService) GenerateFitnessAdvice(userProfile map[string]interface{}) (string, error) {
	systemPrompt := `你是一位专业的健身教练AI助手，名叫Gymates AI Coach。
你擅长根据用户的个人信息（年龄、身高、体重、健身目标、经验等）提供个性化的健身建议。
请用友好、专业的语气回复，并提供具体可行的建议。`

	userMessage := fmt.Sprintf(
		"用户信息：\n年龄：%v\n身高：%v cm\n体重：%v kg\n健身目标：%v\n健身经验：%v\n\n请为这位用户提供个性化的健身建议。",
		userProfile["age"],
		userProfile["height"],
		userProfile["weight"],
		userProfile["goal"],
		userProfile["experience"],
	)

	return s.GenerateResponse(userMessage, systemPrompt)
}

// GenerateWorkoutPlan 生成训练计划
func (s *DeepSeekService) GenerateWorkoutPlan(goal string, level string, duration int) (string, error) {
	systemPrompt := `你是一位专业的健身计划制定专家。
请根据用户的健身目标、水平和可用时间，生成一份详细的训练计划。
计划应该包括具体的动作、组数、次数和休息时间。`

	userMessage := fmt.Sprintf(
		"请为以下需求生成一份训练计划：\n目标：%s\n水平：%s\n时长：%d分钟",
		goal,
		level,
		duration,
	)

	return s.GenerateResponse(userMessage, systemPrompt)
}

// AnalyzeWorkoutForm 分析动作姿势
func (s *DeepSeekService) AnalyzeWorkoutForm(exerciseName string, description string) (string, error) {
	systemPrompt := `你是一位专业的健身动作分析专家。
请分析用户描述的动作执行情况，指出可能存在的问题，并给出改进建议。`

	userMessage := fmt.Sprintf(
		"动作名称：%s\n用户描述：%s\n\n请分析这个动作的执行情况并给出专业建议。",
		exerciseName,
		description,
	)

	return s.GenerateResponse(userMessage, systemPrompt)
}

// GenerateNutritionAdvice 生成营养建议
func (s *DeepSeekService) GenerateNutritionAdvice(goal string, weight float64, activityLevel string) (string, error) {
	systemPrompt := `你是一位专业的运动营养师。
请根据用户的健身目标、体重和活动水平，提供个性化的营养建议，包括每日热量摄入、宏量营养素比例等。`

	userMessage := fmt.Sprintf(
		"健身目标：%s\n体重：%.1f kg\n活动水平：%s\n\n请提供营养建议。",
		goal,
		weight,
		activityLevel,
	)

	return s.GenerateResponse(userMessage, systemPrompt)
}

// ChatWithContext 带上下文的聊天
func (s *DeepSeekService) ChatWithContext(messages []ChatMessage) (string, error) {
	resp, err := s.Chat(messages, 0.7)
	if err != nil {
		return "", err
	}

	if len(resp.Choices) == 0 {
		return "", fmt.Errorf("no response from API")
	}

	return resp.Choices[0].Message.Content, nil
}
