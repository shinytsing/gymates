#!/bin/bash

# Gymates Backend 启动脚本

echo "🚀 启动 Gymates Backend 服务"
echo "================================"

# 检查Go是否安装
if ! command -v go &> /dev/null; then
    echo "❌ Go 未安装，请先安装 Go 1.21+"
    exit 1
fi

# 检查Go版本
GO_VERSION=$(go version | cut -d' ' -f3 | sed 's/go//')
REQUIRED_VERSION="1.21"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$GO_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "❌ Go 版本过低，需要 $REQUIRED_VERSION+，当前版本: $GO_VERSION"
    exit 1
fi

echo "✅ Go 版本检查通过: $GO_VERSION"

# 检查是否存在.env文件
if [ ! -f ".env" ]; then
    echo "📝 创建环境配置文件..."
    cp env.example .env
    echo "✅ 已创建 .env 文件，请根据需要修改配置"
    echo "💡 默认配置："
    echo "   - 数据库: SQLite (gymates.db)"
    echo "   - 端口: 3000"
    echo "   - 模拟数据: 开启"
    echo "   - JWT密钥: 默认密钥（生产环境请修改）"
fi

# 安装依赖
echo "📦 安装Go依赖..."
go mod tidy

if [ $? -ne 0 ]; then
    echo "❌ 依赖安装失败"
    exit 1
fi

echo "✅ 依赖安装完成"

# 检查端口是否被占用
PORT=${PORT:-3000}
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  端口 $PORT 已被占用"
    echo "请修改 .env 文件中的 PORT 配置或停止占用端口的进程"
    exit 1
fi

echo "✅ 端口 $PORT 可用"

# 启动服务
echo "🎯 启动服务在端口 $PORT..."
echo "📖 API文档: http://localhost:$PORT/api"
echo "🏥 健康检查: http://localhost:$PORT/health"
echo ""
echo "按 Ctrl+C 停止服务"
echo "================================"

go run main.go
