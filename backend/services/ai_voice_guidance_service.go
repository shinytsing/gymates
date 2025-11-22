package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"

	"gymates-backend/models"
)

// AIVoiceGuidanceService AI语音指导服务
type AIVoiceGuidanceService struct {
	llmService *AITrainingPlanService
	ttsAPIKey  string
	ttsAPIURL  string
	ttsProvider string // "openai", "azure", "google", "aliyun"
	httpClient *http.Client
}

// NewAIVoiceGuidanceService 创建AI语音指导服务
func NewAIVoiceGuidanceService() *AIVoiceGuidanceService {
	ttsAPIKey := os.Getenv("TTS_API_KEY")
	if ttsAPIKey == "" {
		ttsAPIKey = os.Getenv("OPENAI_API_KEY") // 使用OpenAI的TTS
	}
	
	ttsProvider := os.Getenv("TTS_PROVIDER")
	if ttsProvider == "" {
		ttsProvider = "openai"
	}
	
	ttsAPIURL := os.Getenv("TTS_API_URL")
	if ttsAPIURL == "" {
		switch ttsProvider {
		case "openai":
			ttsAPIURL = "https://api.openai.com/v1/audio/speech"
		case "azure":
			ttsAPIURL = "https://YOUR_REGION.tts.speech.microsoft.com/cognitiveservices/v1"
		case "aliyun":
			ttsAPIURL = "https://nls-gateway.cn-shanghai.aliyuncs.com/stream/v1/tts"
		default:
			ttsAPIURL = "https://api.openai.com/v1/audio/speech"
		}
	}
	
	return &AIVoiceGuidanceService{
		llmService:  NewAITrainingPlanService(),
		ttsAPIKey:   ttsAPIKey,
		ttsAPIURL:   ttsAPIURL,
		ttsProvider: ttsProvider,
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// GenerateExerciseGuidance 生成动作指导文本和语音
func (s *AIVoiceGuidanceService) GenerateExerciseGuidance(exercise models.Exercise) (*models.VoiceGuidance, error) {
	// 1. 使用LLM生成详细指导文本
	guidanceText, err := s.generateGuidanceText(exercise)
	if err != nil {
		// 使用默认模板
		guidanceText = s.getDefaultGuidanceText(exercise)
	}
	
	// 2. 生成语音URL（如果配置了TTS）
	speechURL := ""
	if s.ttsAPIKey != "" {
		speechURL, err = s.generateSpeech(guidanceText)
		if err != nil {
			fmt.Printf("⚠️ 生成语音失败: %v\n", err)
		}
	}
	
	// 3. 生成倒计时提示
	countdownPrompts := s.generateCountdownPrompts(exercise)
	
	// 4. 生成休息提示
	restPrompts := s.generateRestPrompts(exercise)
	
	return &models.VoiceGuidance{
		ExerciseID:       exercise.ID,
		ExerciseName:     exercise.Name,
		GuidanceText:     guidanceText,
		SpeechURL:        speechURL,
		CountdownPrompts: countdownPrompts,
		RestPrompts:      restPrompts,
		Duration:         s.calculateDuration(exercise),
		CreatedAt:        time.Now(),
	}, nil
}

// GenerateRealTimeCorrection 生成实时纠正建议
func (s *AIVoiceGuidanceService) GenerateRealTimeCorrection(
	exercise models.Exercise,
	sensorData map[string]interface{},
) (*models.CorrectionAdvice, error) {
	// 构建提示词
	prompt := s.buildCorrectionPrompt(exercise, sensorData)
	
	// 调用LLM生成纠正建议
	response, err := s.llmService.callLLMAPI(prompt)
	if err != nil {
		return s.getDefaultCorrection(exercise), nil
	}
	
	// 解析响应
	correction := s.parseCorrectionResponse(response)
	
	// 生成语音
	if s.ttsAPIKey != "" && correction.CorrectionText != "" {
		speechURL, _ := s.generateSpeech(correction.CorrectionText)
		correction.SpeechURL = speechURL
	}
	
	return correction, nil
}

// GenerateTrainingSummary 生成训练总结
func (s *AIVoiceGuidanceService) GenerateTrainingSummary(
	userID uint,
	sessionData models.TrainingSessionData,
) (*models.TrainingSummaryResponse, error) {
	// 构建提示词
	prompt := s.buildSummaryPrompt(userID, sessionData)
	
	// 调用LLM生成总结
	response, err := s.llmService.callLLMAPI(prompt)
	if err != nil {
		return s.getDefaultSummary(sessionData), nil
	}
	
	// 解析响应
	summary := s.parseSummaryResponse(response)
	
	// 生成语音
	if s.ttsAPIKey != "" && summary.OverallSummary != "" {
		speechURL, _ := s.generateSpeech(summary.OverallSummary)
		summary.SpeechURL = speechURL
	}
	
	return summary, nil
}

// generateGuidanceText 使用LLM生成指导文本
func (s *AIVoiceGuidanceService) generateGuidanceText(exercise models.Exercise) (string, error) {
	prompt := fmt.Sprintf(`作为专业健身教练，请为以下动作生成详细的语音指导文本：

动作名称: %s
动作描述: %s
目标肌群: %s
组数: %d
次数: %d
重量: %.1f kg
休息时间: %d 秒

请生成简洁、清晰的语音指导文本，包括：
1. 动作要领（2-3句话）
2. 呼吸方法（1句话）
3. 常见错误提醒（1-2句话）
4. 安全提示（1句话）

要求：
- 使用口语化表达，适合语音播报
- 每句话不超过20个字
- 总长度控制在150字以内
- 直接输出文本，不要标题和序号

示例格式：
保持背部挺直，双脚与肩同宽。下蹲时吸气，起身时呼气。注意膝盖不要超过脚尖。保持核心收紧，避免腰部受伤。`,
		exercise.Name,
		exercise.Description,
		exercise.MuscleGroup,
		exercise.Sets,
		exercise.Reps,
		exercise.Weight,
		exercise.RestSeconds,
	)
	
	return s.llmService.callLLMAPI(prompt)
}

// getDefaultGuidanceText 获取默认指导文本
func (s *AIVoiceGuidanceService) getDefaultGuidanceText(exercise models.Exercise) string {
	templates := map[string]string{
		"chest": "保持肩胛骨收紧，下放时吸气，推起时呼气。注意控制动作速度，避免肩部代偿。保持核心稳定。",
		"back":  "保持背部挺直，收紧肩胛骨。拉起时呼气，下放时吸气。注意使用背部发力，避免手臂代偿。",
		"legs":  "保持背部挺直，核心收紧。下蹲时吸气，起身时呼气。注意膝盖与脚尖方向一致，避免内扣。",
		"shoulders": "保持核心稳定，避免借力。推起时呼气，下放时吸气。注意肩部发力，避免耸肩。",
		"arms":  "保持肘关节稳定，专注目标肌群。收缩时呼气，伸展时吸气。注意控制动作幅度。",
	}
	
	if text, ok := templates[exercise.MuscleGroup]; ok {
		return text
	}
	
	return fmt.Sprintf("准备开始%s训练。保持正确姿势，注意呼吸节奏。完成%d组，每组%d次。",
		exercise.Name, exercise.Sets, exercise.Reps)
}

// generateSpeech 生成语音
func (s *AIVoiceGuidanceService) generateSpeech(text string) (string, error) {
	if s.ttsAPIKey == "" {
		return "", fmt.Errorf("TTS API密钥未配置")
	}
	
	switch s.ttsProvider {
	case "openai":
		return s.generateSpeechWithOpenAI(text)
	case "azure":
		return s.generateSpeechWithAzure(text)
	case "aliyun":
		return s.generateSpeechWithAliyun(text)
	default:
		return "", fmt.Errorf("不支持的TTS提供商: %s", s.ttsProvider)
	}
}

// generateSpeechWithOpenAI 使用OpenAI TTS生成语音
func (s *AIVoiceGuidanceService) generateSpeechWithOpenAI(text string) (string, error) {
	reqBody := map[string]interface{}{
		"model": "tts-1",
		"input": text,
		"voice": "alloy", // 可选: alloy, echo, fable, onyx, nova, shimmer
		"speed": 1.0,
	}
	
	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return "", err
	}
	
	req, err := http.NewRequest("POST", s.ttsAPIURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", err
	}
	
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", s.ttsAPIKey))
	
	resp, err := s.httpClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("TTS API返回错误: %d, %s", resp.StatusCode, string(body))
	}
	
	// 读取音频数据并保存（实际应用中应该保存到云存储）
	// 这里返回一个模拟的URL
	timestamp := time.Now().Unix()
	audioURL := fmt.Sprintf("https://cdn.gymates.com/audio/guidance_%d.mp3", timestamp)
	
	return audioURL, nil
}

// generateSpeechWithAzure 使用Azure TTS生成语音
func (s *AIVoiceGuidanceService) generateSpeechWithAzure(text string) (string, error) {
	// Azure TTS实现（需要配置Azure订阅密钥）
	// 这里返回模拟URL
	timestamp := time.Now().Unix()
	return fmt.Sprintf("https://cdn.gymates.com/audio/guidance_%d.mp3", timestamp), nil
}

// generateSpeechWithAliyun 使用阿里云TTS生成语音
func (s *AIVoiceGuidanceService) generateSpeechWithAliyun(text string) (string, error) {
	// 阿里云TTS实现（需要配置AccessKey）
	// 这里返回模拟URL
	timestamp := time.Now().Unix()
	return fmt.Sprintf("https://cdn.gymates.com/audio/guidance_%d.mp3", timestamp), nil
}

// generateCountdownPrompts 生成倒计时提示
func (s *AIVoiceGuidanceService) generateCountdownPrompts(exercise models.Exercise) []string {
	prompts := []string{
		fmt.Sprintf("准备开始%s", exercise.Name),
		"3",
		"2",
		"1",
		"开始！",
	}
	
	// 添加中途提示
	if exercise.Reps > 5 {
		prompts = append(prompts, fmt.Sprintf("还剩%d次", exercise.Reps/2))
	}
	
	prompts = append(prompts, "最后一次，加油！")
	prompts = append(prompts, "完成！")
	
	return prompts
}

// generateRestPrompts 生成休息提示
func (s *AIVoiceGuidanceService) generateRestPrompts(exercise models.Exercise) []string {
	restTime := exercise.RestSeconds
	
	prompts := []string{
		fmt.Sprintf("休息%d秒", restTime),
		"放松肌肉，调整呼吸",
	}
	
	if restTime >= 60 {
		prompts = append(prompts, "还剩30秒")
	}
	
	if restTime >= 30 {
		prompts = append(prompts, "还剩10秒")
	}
	
	prompts = append(prompts, "准备下一组")
	
	return prompts
}

// buildCorrectionPrompt 构建纠正提示词
func (s *AIVoiceGuidanceService) buildCorrectionPrompt(
	exercise models.Exercise,
	sensorData map[string]interface{},
) string {
	return fmt.Sprintf(`作为专业健身教练，根据传感器数据分析用户动作并给出纠正建议：

动作名称: %s
目标肌群: %s

传感器数据:
%v

请分析用户动作是否标准，如果有问题请给出简短的纠正建议（不超过30字）。
如果动作标准，请给予鼓励（不超过15字）。

直接输出建议文本，不要其他说明。`,
		exercise.Name,
		exercise.MuscleGroup,
		sensorData,
	)
}

// parseCorrectionResponse 解析纠正响应
func (s *AIVoiceGuidanceService) parseCorrectionResponse(response string) *models.CorrectionAdvice {
	return &models.CorrectionAdvice{
		CorrectionText: response,
		Severity:       "info", // 可以根据关键词判断严重程度
		Timestamp:      time.Now(),
	}
}

// getDefaultCorrection 获取默认纠正建议
func (s *AIVoiceGuidanceService) getDefaultCorrection(exercise models.Exercise) *models.CorrectionAdvice {
	return &models.CorrectionAdvice{
		CorrectionText: "保持动作标准，注意呼吸节奏",
		Severity:       "info",
		Timestamp:      time.Now(),
	}
}

// buildSummaryPrompt 构建总结提示词
func (s *AIVoiceGuidanceService) buildSummaryPrompt(
	userID uint,
	sessionData models.TrainingSessionData,
) string {
	return fmt.Sprintf(`作为专业健身教练，请为用户生成本次训练总结：

训练时长: %d 分钟
完成动作数: %d
总组数: %d
总次数: %d
消耗卡路里: %d

完成的动作:
%v

请生成：
1. 总体评价（30字以内）
2. 优点（20字以内）
3. 改进建议（30字以内）
4. 下次训练建议（20字以内）

以JSON格式输出：
{
  "overall": "总体评价",
  "strengths": "优点",
  "improvements": "改进建议",
  "next_recommendation": "下次建议"
}`,
		sessionData.Duration,
		len(sessionData.CompletedExercises),
		sessionData.TotalSets,
		sessionData.TotalReps,
		sessionData.CaloriesBurned,
		sessionData.CompletedExercises,
	)
}

// parseSummaryResponse 解析总结响应
func (s *AIVoiceGuidanceService) parseSummaryResponse(response string) *models.TrainingSummaryResponse {
	var summary models.TrainingSummaryResponse
	
	// 尝试解析JSON
	if err := json.Unmarshal([]byte(response), &summary); err != nil {
		// 解析失败，使用默认值
		summary.OverallSummary = "训练完成得很好！"
		summary.Strengths = "保持了良好的训练状态"
		summary.Improvements = "可以适当增加训练强度"
		summary.NextRecommendation = "建议明天休息，后天继续训练"
	}
	
	summary.Rating = 4
	summary.Timestamp = time.Now()
	
	return &summary
}

// getDefaultSummary 获取默认总结
func (s *AIVoiceGuidanceService) getDefaultSummary(sessionData models.TrainingSessionData) *models.TrainingSummaryResponse {
	return &models.TrainingSummaryResponse{
		OverallSummary:     fmt.Sprintf("完成了%d个动作的训练，表现不错！", len(sessionData.CompletedExercises)),
		Strengths:          "训练态度认真，动作完成度高",
		Improvements:       "可以尝试增加训练强度或重量",
		NextRecommendation: "建议休息1-2天后继续训练",
		Rating:             4,
		Timestamp:          time.Now(),
	}
}

// calculateDuration 计算动作总时长
func (s *AIVoiceGuidanceService) calculateDuration(exercise models.Exercise) int {
	// 估算时长：每次动作3秒 + 休息时间
	actionTime := exercise.Sets * exercise.Reps * 3
	restTime := exercise.Sets * exercise.RestSeconds
	return actionTime + restTime
}

