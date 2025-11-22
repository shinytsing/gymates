package controllers

import (
	"fmt"
	"net/http"
	"strings"

	"gymates-backend/services"

	"github.com/gin-gonic/gin"
)

// TranslationController 翻译控制器
type TranslationController struct {
	aiService *services.AIServiceManager
}

// NewTranslationController 创建翻译控制器
func NewTranslationController() *TranslationController {
	return &TranslationController{
		aiService: services.GetAIManager(),
	}
}

// TranslateExerciseNameRequest 翻译请求
type TranslateExerciseNameRequest struct {
	Name string `json:"name" binding:"required"`
}

// TranslateExerciseNameResponse 翻译响应
type TranslateExerciseNameResponse struct {
	Success     bool   `json:"success"`
	OriginalName string `json:"original_name"`
	TranslatedName string `json:"translated_name"`
	Message     string `json:"message"`
}

// TranslateExerciseName 翻译动作名称
// @Summary 翻译动作名称
// @Tags 翻译
// @Param body body TranslateExerciseNameRequest true "动作名称"
// @Success 200 {object} TranslateExerciseNameResponse
// @Router /api/translation/exercise-name [post]
func (ctrl *TranslationController) TranslateExerciseName(c *gin.Context) {
	var req TranslateExerciseNameRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, TranslateExerciseNameResponse{
			Success: false,
			Message: "请求参数错误",
		})
		return
	}

	// 构建翻译提示词
	prompt := fmt.Sprintf(`请将以下健身动作名称翻译成简洁的中文，只返回翻译结果，不要任何解释：

动作名称：%s

翻译要求：
1. 保持专业的健身术语
2. 简洁明了，不超过8个字
3. 只返回中文翻译，不要英文原文
4. 如果包含器械名称，保留器械名称的翻译

示例：
- Cable Fly Middle Chest → 绳索飞鸟（中胸）
- Alternating dumbbell hammer curl → 哑铃交替锤式弯举
- Tricep Pushdown on Cable → 绳索三头下压

现在请翻译：%s`, req.Name, req.Name)

	// 调用AI服务
	messages := []services.ChatMessage{
		{
			Role:    "user",
			Content: prompt,
		},
	}

	response, err := ctrl.aiService.Chat(messages)
	if err != nil {
		c.JSON(http.StatusInternalServerError, TranslateExerciseNameResponse{
			Success: false,
			OriginalName: req.Name,
			Message: fmt.Sprintf("翻译失败: %v", err),
		})
		return
	}

	// 清理翻译结果
	var translatedName string
	if len(response.Choices) > 0 {
		translatedName = strings.TrimSpace(response.Choices[0].Message.Content)
		translatedName = strings.Trim(translatedName, "\"'")
	} else {
		translatedName = req.Name
	}

	c.JSON(http.StatusOK, TranslateExerciseNameResponse{
		Success: true,
		OriginalName: req.Name,
		TranslatedName: translatedName,
		Message: "翻译成功",
	})
}

// BatchTranslateExerciseNamesRequest 批量翻译请求
type BatchTranslateExerciseNamesRequest struct {
	Names []string `json:"names" binding:"required"`
}

// BatchTranslateExerciseNamesResponse 批量翻译响应
type BatchTranslateExerciseNamesResponse struct {
	Success bool `json:"success"`
	Translations map[string]string `json:"translations"`
	Message string `json:"message"`
}

// BatchTranslateExerciseNames 批量翻译动作名称
// @Summary 批量翻译动作名称
// @Tags 翻译
// @Param body body BatchTranslateExerciseNamesRequest true "动作名称列表"
// @Success 200 {object} BatchTranslateExerciseNamesResponse
// @Router /api/translation/exercise-names/batch [post]
func (ctrl *TranslationController) BatchTranslateExerciseNames(c *gin.Context) {
	var req BatchTranslateExerciseNamesRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, BatchTranslateExerciseNamesResponse{
			Success: false,
			Message: "请求参数错误",
		})
		return
	}

	// 限制批量翻译数量
	if len(req.Names) > 50 {
		c.JSON(http.StatusBadRequest, BatchTranslateExerciseNamesResponse{
			Success: false,
			Message: "一次最多翻译50个动作名称",
		})
		return
	}

	// 构建批量翻译提示词
	namesList := strings.Join(req.Names, "\n")
	prompt := fmt.Sprintf(`请将以下健身动作名称翻译成简洁的中文，每行一个翻译结果，保持顺序：

%s

翻译要求：
1. 保持专业的健身术语
2. 简洁明了，每个不超过8个字
3. 只返回中文翻译，每行一个
4. 不要序号，不要英文原文
5. 保持原有顺序`, namesList)

	messages := []services.ChatMessage{
		{
			Role:    "user",
			Content: prompt,
		},
	}

	response, err := ctrl.aiService.Chat(messages)
	if err != nil {
		c.JSON(http.StatusInternalServerError, BatchTranslateExerciseNamesResponse{
			Success: false,
			Message: fmt.Sprintf("翻译失败: %v", err),
		})
		return
	}

	// 解析翻译结果
	translations := make(map[string]string)
	var content string
	if len(response.Choices) > 0 {
		content = response.Choices[0].Message.Content
	}
	lines := strings.Split(strings.TrimSpace(content), "\n")
	
	for i, name := range req.Names {
		if i < len(lines) {
			translatedName := strings.TrimSpace(lines[i])
			translatedName = strings.Trim(translatedName, "\"'")
			translations[name] = translatedName
		} else {
			translations[name] = name // 如果翻译不够，保留原名
		}
	}

	c.JSON(http.StatusOK, BatchTranslateExerciseNamesResponse{
		Success: true,
		Translations: translations,
		Message: "批量翻译成功",
	})
}

