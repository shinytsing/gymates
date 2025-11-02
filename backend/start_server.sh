#!/bin/bash

# Gymates Backend Server Startup Script
# 启动优化后的Gymates后端服务器

echo "🚀 Starting Gymates Backend Server..."
echo "======================================"

# 检查Go是否安装
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed. Please install Go first."
    exit 1
fi

# 进入backend目录
cd "$(dirname "$0")"

# 检查.env文件
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Using environment variables..."
fi

# 编译服务器
echo "📦 Building server..."
go build -o gymates-server cmd/server.go

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"
echo ""
echo "🌐 Starting server..."
echo "======================================"

# 启动服务器
./gymates-server

# 清理
rm -f gymates-server

