#!/bin/bash

# Gymates AI 和地图服务 API 测试脚本
# 使用说明: ./test_new_apis.sh

BASE_URL="http://localhost:3000"
TOKEN=""  # 如果需要认证，请在这里填写 token

echo "🧪 Gymates AI 和地图服务 API 测试"
echo "========================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试函数
test_api() {
    local name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    
    echo -e "${BLUE}🔍 测试: $name${NC}"
    echo "   Endpoint: $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $TOKEN")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $TOKEN" \
            -d "$data")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
        echo -e "   ${GREEN}✓ 成功 (HTTP $http_code)${NC}"
        echo "   响应: $(echo $body | python3 -m json.tool 2>/dev/null || echo $body | head -c 100)"
    else
        echo -e "   ${RED}✗ 失败 (HTTP $http_code)${NC}"
        echo "   错误: $body"
    fi
    echo ""
}

# 检查服务器是否运行
echo "🔍 检查服务器状态..."
health_check=$(curl -s "$BASE_URL/health")
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 服务器正在运行${NC}"
    echo ""
else
    echo -e "${RED}✗ 服务器未运行或无法连接${NC}"
    echo "请先启动后端服务器: cd backend && ./gymates-server"
    exit 1
fi

# ========================================
# AI 聊天服务测试
# ========================================
echo "==========================================��
echo "🤖 AI 聊天服务测试"
echo "=========================================="
echo ""

# 注意: AI 服务需要认证，如果没有 token，这些测试会失败
# 你可以先注册/登录获取 token

# 1. 基础聊天
test_api "基础 AI 聊天" "POST" "/api/ai/chat" '{
    "message": "你好，我是一个健身新手，应该从哪里开始？",
    "system_prompt": "你是一位专业的健身教练"
}'

# 2. 获取健身建议
test_api "获取个性化健身建议" "POST" "/api/ai/fitness-advice" '{
    "age": 25,
    "height": 175,
    "weight": 70,
    "goal": "增肌",
    "experience": "初学者"
}'

# 3. 生成训练计划
test_api "生成训练计划" "POST" "/api/ai/workout-plan" '{
    "goal": "增肌",
    "level": "intermediate",
    "duration": 45
}'

# 4. 分析动作姿势
test_api "分析动作姿势" "POST" "/api/ai/analyze-form" '{
    "exercise_name": "深蹲",
    "description": "我在做深蹲时膝盖会向内扣，腰部感觉不太舒服"
}'

# 5. 获取营养建议
test_api "获取营养建议" "POST" "/api/ai/nutrition-advice" '{
    "goal": "增肌",
    "weight": 70,
    "activity_level": "moderate"
}'

# ========================================
# 地图服务测试
# ========================================
echo "=========================================="
echo "🗺️  高德地图服务测试"
echo "=========================================="
echo ""

# 6. 地理编码
test_api "地理编码" "POST" "/api/map/geocode" '{
    "address": "北京市朝阳区三里屯"
}'

# 7. 搜索附近健身房 (以北京三里屯为例)
test_api "搜索附近健身房" "POST" "/api/map/gyms/nearby" '{
    "latitude": 39.9357,
    "longitude": 116.4475,
    "radius": 3000
}'

# 8. 计算距离
test_api "计算距离" "POST" "/api/map/distance" '{
    "origin_lat": 39.9042,
    "origin_lng": 116.4074,
    "destination_lat": 39.9357,
    "destination_lng": 116.4475
}'

# 9. 按城市搜索健身房
test_api "按城市搜索健身房" "GET" "/api/map/gyms/city?city=北京&page=1&page_size=5" ""

# ========================================
# 其他核心 API 测试
# ========================================
echo "=========================================="
echo "🏠 其他核心 API 测试"
echo "=========================================="
echo ""

# 10. 健康检查
test_api "健康检查" "GET" "/health" ""

# 11. 获取训练计划列表
test_api "获取训练计划列表" "GET" "/api/training/plans" ""

# 12. 搜索运动动作
test_api "搜索运动动作" "GET" "/api/training/exercises/search?keyword=深蹲&muscle_group=legs" ""

# ========================================
# 测试总结
# ========================================
echo "=========================================="
echo "📊 测试完成"
echo "=========================================="
echo ""
echo "💡 注意事项:"
echo "   1. AI 服务和部分 API 需要用户认证（token）"
echo "   2. 如需完整测试，请先注册/登录获取 token"
echo "   3. 高德地图服务可能需要有效的网络连接"
echo ""
echo "🔑 获取 token 的步骤:"
echo "   1. 注册: curl -X POST $BASE_URL/api/auth/register -H 'Content-Type: application/json' -d '{\"email\":\"test@example.com\",\"password\":\"password123\",\"name\":\"测试用户\"}'"
echo "   2. 登录: curl -X POST $BASE_URL/api/auth/login -H 'Content-Type: application/json' -d '{\"email\":\"test@example.com\",\"password\":\"password123\"}'"
echo "   3. 将返回的 token 填入本脚本开头的 TOKEN 变量"
echo ""
echo "🚀 启动服务器:"
echo "   cd backend && ./gymates-server"
echo ""

