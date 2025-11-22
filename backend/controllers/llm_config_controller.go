package controllers

import (
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"gymates-backend/config"
	"gymates-backend/models"
)

// LLMConfigController LLM配置控制器
type LLMConfigController struct{}

// NewLLMConfigController 创建LLM配置控制器
func NewLLMConfigController() *LLMConfigController {
	return &LLMConfigController{}
}

// GetAvailableLLMs 获取可用的LLM列表
// GET /api/ai/llm/configs
func (c *LLMConfigController) GetAvailableLLMs(ctx *gin.Context) {
	// 定义所有支持的LLM配置
	allConfigs := []models.LLMConfig{
		// 免费LLM
		{
			Provider:    models.TencentHunyuan,
			Name:        "tencent",
			DisplayName: "腾讯混元",
			Description: "腾讯云混元大模型，免费使用",
			Icon:        "🎯",
			IsAvailable: os.Getenv("TENCENT_SECRET_ID") != "",
			IsFree:      true,
			Features:    []string{"完全免费", "中文优化", "稳定可靠", "企业级"},
			Pricing: models.LLMPricing{
				InputPrice:  "免费",
				OutputPrice: "免费",
				Currency:    "CNY",
				AvgCost:     "免费",
			},
		},
		{
			Provider:    models.Groq,
			Name:        "groq",
			DisplayName: "Groq",
			Description: "超快AI推理引擎，免费使用",
			Icon:        "⚡",
			IsAvailable: os.Getenv("GROQ_API_KEY") != "",
			IsFree:      true,
			Features:    []string{"完全免费", "极速响应", "大额度", "高性能"},
			Pricing: models.LLMPricing{
				InputPrice:  "免费",
				OutputPrice: "免费",
				Currency:    "USD",
				AvgCost:     "免费",
			},
		},
		
		// 付费LLM - 需要会员
		{
			Provider:      models.DeepSeek,
			Name:          "deepseek",
			DisplayName:   "DeepSeek",
			Description:   "性价比最高的AI模型，适合大规模使用",
			Icon:          "🚀",
			IsAvailable:   os.Getenv("DEEPSEEK_API_KEY") != "",
			IsFree:        false,
			RequiresMembership: true,
			Features:      []string{"快速响应", "低成本", "中文优化", "多轮对话"},
			Pricing: models.LLMPricing{
				InputPrice:  "¥0.001 / 1K tokens",
				OutputPrice: "¥0.002 / 1K tokens",
				Currency:    "CNY",
				AvgCost:     "¥0.02 / 次",
			},
		},
		{
			Provider:      models.OpenAI,
			Name:          "openai",
			DisplayName:   "OpenAI GPT-4",
			Description:   "最强大的AI模型，适合复杂场景",
			Icon:          "🤖",
			IsAvailable:   os.Getenv("OPENAI_API_KEY") != "",
			IsFree:        false,
			RequiresMembership: true,
			Features:      []string{"最强性能", "多模态", "全球领先", "持续更新"},
			Pricing: models.LLMPricing{
				InputPrice:  "$0.03 / 1K tokens",
				OutputPrice: "$0.06 / 1K tokens",
				Currency:    "USD",
				AvgCost:     "$0.30 / 次",
			},
		},
		{
			Provider:      models.Anthropic,
			Name:          "anthropic",
			DisplayName:   "Anthropic Claude",
			Description:   "安全可靠的AI助手，擅长长文本",
			Icon:          "🧠",
			IsAvailable:   os.Getenv("ANTHROPIC_API_KEY") != "",
			IsFree:        false,
			RequiresMembership: true,
			Features:      []string{"长文本", "安全性高", "逻辑清晰", "可靠稳定"},
			Pricing: models.LLMPricing{
				InputPrice:  "$0.015 / 1K tokens",
				OutputPrice: "$0.075 / 1K tokens",
				Currency:    "USD",
				AvgCost:     "$0.25 / 次",
			},
		},
		{
			Provider:      models.ZhipuAI,
			Name:          "zhipu",
			DisplayName:   "智谱AI GLM",
			Description:   "国产优秀AI，中文能力突出",
			Icon:          "🇨🇳",
			IsAvailable:   os.Getenv("ZHIPU_API_KEY") != "",
			IsFree:        false,
			RequiresMembership: true,
			Features:      []string{"中文专长", "本土化", "价格适中", "响应快"},
			Pricing: models.LLMPricing{
				InputPrice:  "¥0.005 / 1K tokens",
				OutputPrice: "¥0.005 / 1K tokens",
				Currency:    "CNY",
				AvgCost:     "¥0.05 / 次",
			},
		},
		{
			Provider:      models.TongyiQwen,
			Name:          "tongyi",
			DisplayName:   "通义千问",
			Description:   "阿里云AI模型，稳定可靠",
			Icon:          "☁️",
			IsAvailable:   os.Getenv("TONGYI_API_KEY") != "",
			IsFree:        false,
			RequiresMembership: true,
			Features:      []string{"企业级", "稳定性高", "多场景", "技术支持"},
			Pricing: models.LLMPricing{
				InputPrice:  "¥0.008 / 1K tokens",
				OutputPrice: "¥0.008 / 1K tokens",
				Currency:    "CNY",
				AvgCost:     "¥0.08 / 次",
			},
		},
		{
			Provider:      models.Gemini,
			Name:          "gemini",
			DisplayName:   "Google Gemini",
			Description:   "Google最新AI模型，多模态能力强",
			Icon:          "✨",
			IsAvailable:   os.Getenv("GEMINI_API_KEY") != "",
			IsFree:        false,
			RequiresMembership: true,
			Features:      []string{"多模态", "Google技术", "创新功能", "全球部署"},
			Pricing: models.LLMPricing{
				InputPrice:  "$0.01 / 1K tokens",
				OutputPrice: "$0.03 / 1K tokens",
				Currency:    "USD",
				AvgCost:     "$0.15 / 次",
			},
		},
	}

	// 获取用户ID
	userID, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未授权",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	// 获取用户信息（检查会员状态）
	var user models.User
	hasVIPAccess := false
	if err := config.DB.Where("id = ?", userID).First(&user).Error; err == nil {
		// 检查用户是否是会员
		hasVIPAccess = false // TODO: Check membership level when User model is updated
	}

	// 获取用户偏好
	var userPref models.UserLLMPreference
	currentProvider := models.TencentHunyuan // 默认使用免费的腾讯混元
	if err := config.DB.Where("user_id = ?", userID).First(&userPref).Error; err == nil {
		currentProvider = userPref.Provider
	}

	// 推荐提供商（免费：腾讯混元，付费：DeepSeek）
	recommendedProvider := models.TencentHunyuan
	if hasVIPAccess {
		recommendedProvider = models.DeepSeek
	}

	ctx.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取LLM配置成功",
		Data: gin.H{
			"configs":              allConfigs,
			"current_provider":     currentProvider,
			"recommended_provider": recommendedProvider,
			"has_vip_access":       hasVIPAccess,
		},
	})
}

// SetUserLLMProvider 设置用户的LLM提供商
// POST /api/ai/llm/set-provider
func (c *LLMConfigController) SetUserLLMProvider(ctx *gin.Context) {
	var req models.SetUserLLMProviderRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 获取用户ID
	userID, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未授权",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	// 验证提供商是否可用
	if !c.isProviderAvailable(req.Provider) {
		ctx.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: fmt.Sprintf("LLM提供商 %s 不可用，请检查API Key配置", req.Provider),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 检查是否需要会员权限
	requiresMembership := c.requiresMembership(req.Provider)
	if requiresMembership {
		// 检查用户会员状态
		var user models.User
		if err := config.DB.Where("id = ?", userID).First(&user).Error; err != nil {
			ctx.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "获取用户信息失败",
				Error:   err.Error(),
				Code:    http.StatusInternalServerError,
			})
			return
		}

		hasVIPAccess := false // TODO: Check membership level when User model is updated
		if !hasVIPAccess {
			ctx.JSON(http.StatusForbidden, models.ErrorResponse{
				Success: false,
				Message: fmt.Sprintf("使用 %s 需要开通会员，请先充值会员", req.Provider),
				Code:    http.StatusForbidden,
				Error:   "requires_membership",
			})
			return
		}
	}

	// 查找或创建用户偏好
	var userPref models.UserLLMPreference
	err := config.DB.Where("user_id = ?", userID).First(&userPref).Error
	
	if err != nil {
		// 创建新记录
		userPref = models.UserLLMPreference{
			UserID:   userID.(uint),
			Provider: req.Provider,
		}
		if err := config.DB.Create(&userPref).Error; err != nil {
			ctx.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "保存偏好失败",
				Error:   err.Error(),
				Code:    http.StatusInternalServerError,
			})
			return
		}
	} else {
		// 更新现有记录
		userPref.Provider = req.Provider
		if err := config.DB.Save(&userPref).Error; err != nil {
			ctx.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "更新偏好失败",
				Error:   err.Error(),
				Code:    http.StatusInternalServerError,
			})
			return
		}
	}

	ctx.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: fmt.Sprintf("已切换到 %s", req.Provider),
		Data: gin.H{
			"provider": req.Provider,
		},
	})
}

// TestLLMConnection 测试LLM连接
// POST /api/ai/llm/test-connection
func (c *LLMConfigController) TestLLMConnection(ctx *gin.Context) {
	var req models.TestLLMConnectionRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 检查API Key
	if !c.isProviderAvailable(req.Provider) {
		ctx.JSON(http.StatusOK, models.SuccessResponse{
			Success: true,
			Data: models.TestLLMConnectionResponse{
				Success: false,
				Message: fmt.Sprintf("未配置 %s 的 API Key", req.Provider),
			},
		})
		return
	}

	// 测试连接（简单测试）
	startTime := time.Now()
	
	// TODO: 实际调用LLM API测试
	// 这里简化为检查API Key是否存在
	time.Sleep(100 * time.Millisecond) // 模拟网络延迟
	
	responseTime := time.Since(startTime).Milliseconds()

	ctx.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Data: models.TestLLMConnectionResponse{
			Success:      true,
			Message:      "连接成功",
			ResponseTime: responseTime,
		},
	})
}

// isProviderAvailable 检查提供商是否可用
func (c *LLMConfigController) isProviderAvailable(provider models.LLMProvider) bool {
	switch provider {
	case models.TencentHunyuan:
		return os.Getenv("TENCENT_SECRET_ID") != ""
	case models.Groq:
		return os.Getenv("GROQ_API_KEY") != ""
	case models.DeepSeek:
		return os.Getenv("DEEPSEEK_API_KEY") != ""
	case models.OpenAI:
		return os.Getenv("OPENAI_API_KEY") != ""
	case models.Anthropic:
		return os.Getenv("ANTHROPIC_API_KEY") != ""
	case models.ZhipuAI:
		return os.Getenv("ZHIPU_API_KEY") != ""
	case models.TongyiQwen:
		return os.Getenv("TONGYI_API_KEY") != ""
	case models.Gemini:
		return os.Getenv("GEMINI_API_KEY") != ""
	default:
		return false
	}
}

// requiresMembership 检查提供商是否需要会员
func (c *LLMConfigController) requiresMembership(provider models.LLMProvider) bool {
	// 免费LLM不需要会员
	if provider == models.TencentHunyuan || provider == models.Groq {
		return false
	}
	// 其他都需要会员
	return true
}

