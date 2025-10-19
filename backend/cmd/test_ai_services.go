package main

import (
	"fmt"
	"log"
	"os"

	"gymates-backend/services"
)

func main() {
	// 设置环境变量（用于测试）
	os.Setenv("GROQ_API_KEY", "gsk_your_groq_api_key_here")
	os.Setenv("TENCENT_SECRET_ID", "100032618506_100032618506_16a17a3a4bc2eba0534e7b25c4363fc8")
	os.Setenv("TENCENT_SECRET_KEY", "sk-O5tVxVeCGTtSgPlaHMuPe9CdmgEUuy2d79yK5rf5Rp5qsI3m")

	// 初始化AI服务
	services.InitAIServices()
	aiManager := services.GetAIManager()

	if aiManager == nil {
		log.Fatal("Failed to initialize AI manager")
	}

	// 显示服务状态
	fmt.Println("🤖 AI服务状态检查")
	fmt.Println("==================")

	// 获取当前提供商
	currentProvider := aiManager.GetCurrentProvider()
	fmt.Printf("当前提供商: %s\n", currentProvider)

	// 获取服务优先级信息
	servicesWithPriority := aiManager.GetAvailableServicesWithPriority()
	fmt.Println("服务优先级:")
	for _, service := range servicesWithPriority {
		statusText := "❌ 不可用"
		if service.Available {
			statusText = "✅ 可用"
		}
		fmt.Printf("  %s (优先级: %d): %s\n", service.Provider, service.Priority, statusText)
	}

	// 获取服务状态
	serviceStatus := aiManager.GetServiceStatus()
	fmt.Println("服务状态:")
	for provider, status := range serviceStatus {
		statusText := "❌ 不可用"
		if status {
			statusText = "✅ 可用"
		}
		fmt.Printf("  %s: %s\n", provider, statusText)
	}

	// 测试聊天功能
	fmt.Println("\n💬 测试AI聊天功能")
	fmt.Println("==================")

	messages := []services.ChatMessage{
		{
			Role:    "system",
			Content: "你是一位专业的AI健身教练，请用中文回复。",
		},
		{
			Role:    "user",
			Content: "我想练胸肌，有什么建议吗？",
		},
	}

	response, err := aiManager.Chat(messages)
	if err != nil {
		fmt.Printf("❌ 聊天测试失败: %v\n", err)
	} else {
		fmt.Printf("✅ 聊天测试成功\n")
		if len(response.Choices) > 0 {
			fmt.Printf("回复: %s\n", response.Choices[0].Message.Content)
		} else {
			fmt.Printf("回复: 无回复内容\n")
		}
		fmt.Printf("使用提供商: %s\n", aiManager.GetCurrentProvider())
	}

	// 测试自动切换功能
	fmt.Println("\n🔄 测试自动切换功能")
	fmt.Println("==================")

	// 测试多次聊天，观察自动切换
	for i := 0; i < 3; i++ {
		fmt.Printf("\n第 %d 次聊天测试:\n", i+1)
		response, err := aiManager.Chat(messages)
		if err != nil {
			fmt.Printf("❌ 聊天失败: %v\n", err)
		} else {
			fmt.Printf("✅ 聊天成功，使用服务: %s\n", aiManager.GetCurrentProvider())
			if len(response.Choices) > 0 {
				fmt.Printf("回复: %s\n", response.Choices[0].Message.Content)
			} else {
				fmt.Printf("回复: 无回复内容\n")
			}
		}
	}

	fmt.Println("\n🎉 AI服务测试完成！")
}
