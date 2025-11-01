#!/bin/bash

cd "$(dirname "$0")/backend"

echo "🔧 检查环境..."
if [ ! -f ".env" ]; then
    echo "❌ .env 文件不存在"
    exit 1
fi

echo "📦 检查依赖..."
go mod tidy

echo "🗄️ 检查数据库..."
if [ ! -f "gymates.db" ]; then
    echo "📝 初始化数据库..."
    sqlite3 gymates.db "VACUUM;"
fi

echo "🚀 启动后端服务..."
go run main.go


