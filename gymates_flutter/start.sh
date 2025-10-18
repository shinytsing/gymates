#!/bin/bash

# 🏋️‍♀️ Gymates Flutter 项目启动脚本
# 自动检测环境并启动项目

echo "🏋️‍♀️ Gymates Flutter 项目启动脚本"
echo "=================================="

# 检查 Flutter 环境
echo "📱 检查 Flutter 环境..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装，请先安装 Flutter SDK"
    echo "   访问: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# 显示 Flutter 版本
flutter --version

# 检查项目目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

# 清理并获取依赖
echo "🧹 清理项目..."
flutter clean

echo "📦 获取依赖..."
flutter pub get

# 检查平台
echo "🔍 检查可用设备..."
flutter devices

# iOS 配置 (仅 macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 配置 iOS..."
    cd ios
    if [ -f "Podfile" ]; then
        pod install
    fi
    cd ..
fi

# 选择运行平台
echo ""
echo "请选择运行平台:"
echo "1) Android"
echo "2) iOS (仅 macOS)"
echo "3) Web"
echo "4) 自动选择第一个可用设备"

read -p "请输入选择 (1-4): " choice

case $choice in
    1)
        echo "🤖 启动 Android 版本..."
        flutter run -d android
        ;;
    2)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "🍎 启动 iOS 版本..."
            flutter run -d ios
        else
            echo "❌ iOS 仅在 macOS 上支持"
            exit 1
        fi
        ;;
    3)
        echo "🌐 启动 Web 版本..."
        flutter run -d web
        ;;
    4)
        echo "🚀 自动启动..."
        flutter run
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo "✅ 启动完成！"
