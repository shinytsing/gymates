#!/bin/bash

# 🏗️ Gymates 健身社交应用完整原型启动脚本
# 
# 这是一个现代化健身社交 App「Gymates」的完整交互原型
# 支持 iOS (375x812) 与 Android (360x800) 双端
# 自动适配两种系统视觉语言（iOS Human Interface Guidelines / Material Design 3.0）
# 
# 🎨 整体设计规范：
# - 主色调：#6366F1 (Indigo-500)
# - 背景色：浅色模式 #F9FAFB / 深色模式 #111827
# - 文字主色：#1F2937
# - 次要文字：#6B7280
# - 圆角：卡片 12px，按钮 8px，头像 50%
# - 阴影：统一柔和投影 (0px 4px 8px rgba(0,0,0,0.1))
# - 间距：页面边距 16px，组件间距 8/12/16px
# - 字体：标题 18px，副标题 16px，正文 14px，说明 12px
# 
# 🧭 导航结构：
# 底部导航栏 (BottomNavigationBar) 共 5 个 Tab：
# 🏋️‍♀️ 训练（TrainingPage）
# 💬 社区（CommunityPage）
# 🤝 搭子（PartnerPage）
# 📩 消息（MessagesPage）
# 👤 我的（ProfilePage）

echo "🏗️ 启动 Gymates 健身社交应用完整原型..."
echo ""

# 检查 Flutter 环境
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装，请先安装 Flutter SDK"
    exit 1
fi

# 检查 Flutter 版本
FLUTTER_VERSION=$(flutter --version | head -n 1)
echo "📱 Flutter 版本: $FLUTTER_VERSION"

# 进入项目目录
cd /Users/gaojie/Desktop/gymates/gymates_flutter

# 检查项目依赖
echo ""
echo "📦 检查项目依赖..."
flutter pub get

# 检查代码格式
echo ""
echo "🎨 检查代码格式..."
flutter analyze

# 清理构建缓存
echo ""
echo "🧹 清理构建缓存..."
flutter clean
flutter pub get

# 选择运行平台
echo ""
echo "📱 选择运行平台:"
echo "1. iOS 模拟器 (375x812)"
echo "2. Android 模拟器 (360x800)"
echo "3. 同时运行 iOS 和 Android"
echo "4. Web 浏览器"
echo "5. 桌面应用"

read -p "请选择 (1-5): " choice

case $choice in
    1)
        echo ""
        echo "🍎 启动 iOS 模拟器..."
        flutter run -d ios
        ;;
    2)
        echo ""
        echo "🤖 启动 Android 模拟器..."
        flutter run -d android
        ;;
    3)
        echo ""
        echo "📱 同时启动 iOS 和 Android 模拟器..."
        flutter run -d ios &
        flutter run -d android &
        wait
        ;;
    4)
        echo ""
        echo "🌐 启动 Web 浏览器..."
        flutter run -d web
        ;;
    5)
        echo ""
        echo "🖥️ 启动桌面应用..."
        flutter run -d macos
        ;;
    *)
        echo "❌ 无效选择，默认启动 iOS 模拟器..."
        flutter run -d ios
        ;;
esac

echo ""
echo "✅ Gymates 健身社交应用原型启动完成！"
echo ""
echo "🎯 应用功能说明："
echo "   🏋️‍♀️ 训练页 - 今日训练计划、AI智能推荐、训练历史、打卡日历、成就徽章"
echo "   💬 社区页 - 动态流、官方挑战、话题标签、健身房列表"
echo "   🤝 搭子页 - Tinder风格滑动匹配、搭子详情、匹配偏好设置"
echo "   📩 消息页 - 系统通知、聊天列表、新消息浮动按钮"
echo "   👤 我的页 - 个人信息头部、功能卡片区、统计组件、设置选项"
echo ""
echo "🔑 登录注册流程："
echo "   📱 手机号一键登录（验证码）"
echo "   💬 微信登录"
echo "   🍎 Apple 一键登录（iOS端专属）"
echo "   📝 两步注册流程（基础信息 + 健身档案）"
echo ""
echo "🎨 设计特色："
echo "   ✨ 支持 iOS Human Interface Guidelines 和 Android Material Design 3.0"
echo "   🎭 流畅的页面切换动画和组件动画"
echo "   📱 响应式设计，适配不同屏幕尺寸"
echo "   🌙 支持深色模式和浅色模式"
echo "   🎯 统一的视觉语言和交互体验"
echo ""
echo "🚀 享受您的健身社交之旅！"
