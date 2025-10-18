#!/bin/bash

# Go 测试运行脚本
# 用于运行所有测试并生成测试报告

echo "🧪 开始运行 Go 测试..."

# 设置测试环境变量
export DB_TYPE=sqlite
export DB_PATH=:memory:
export GIN_MODE=test
export JWT_SECRET=test-secret-key

# 进入后端目录
cd "$(dirname "$0")"

# 检查 Go 是否安装
if ! command -v go &> /dev/null; then
    echo "❌ Go 未安装，请先安装 Go"
    exit 1
fi

echo "📋 Go 版本: $(go version)"

# 安装测试依赖
echo "📦 安装测试依赖..."
go mod tidy

# 安装 testify 测试框架
go get github.com/stretchr/testify/assert
go get github.com/stretchr/testify/mock

# 运行单元测试
echo "🔬 运行单元测试..."
go test ./controllers -v -cover

# 运行集成测试
echo "🔗 运行集成测试..."
go test ./controllers -v -run TestIntegration

# 运行所有测试并生成覆盖率报告
echo "📊 生成测试覆盖率报告..."
go test ./... -v -cover -coverprofile=coverage.out

# 生成 HTML 覆盖率报告
if command -v go &> /dev/null; then
    go tool cover -html=coverage.out -o coverage.html
    echo "📈 覆盖率报告已生成: coverage.html"
fi

# 运行性能测试
echo "⚡ 运行性能测试..."
go test ./controllers -v -bench=. -benchmem

# 运行竞态检测
echo "🔍 运行竞态检测..."
go test ./controllers -v -race

# 运行测试并显示详细输出
echo "📝 运行所有测试..."
go test ./... -v

# 检查测试结果
if [ $? -eq 0 ]; then
    echo "✅ 所有测试通过！"
else
    echo "❌ 部分测试失败"
    exit 1
fi

echo "🎉 测试完成！"
