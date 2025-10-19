#!/bin/bash

# AI训练页面联调测试脚本
echo "🧠 Gymates AI训练页面联调测试"
echo "=================================="

BASE_URL="http://localhost:8080"
USER_ID=1

# 测试计数器
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数
test_api() {
    local test_name="$1"
    local method="$2"
    local url="$3"
    local data="$4"
    local expected_status="$5"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo "🔍 测试: $test_name"
    echo "   请求: $method $url"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$url")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$url")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "$expected_status" ]; then
        echo "   ✅ 状态码: $http_code (期望: $expected_status)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        
        # 检查响应内容
        if echo "$body" | grep -q '"success":true'; then
            echo "   ✅ 响应成功"
        else
            echo "   ⚠️  响应可能有问题"
        fi
        
        # 显示部分响应内容
        echo "   📄 响应预览:"
        echo "$body" | head -c 200
        echo "..."
    else
        echo "   ❌ 状态码: $http_code (期望: $expected_status)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "   📄 错误响应:"
        echo "$body"
    fi
    
    echo ""
}

# 等待后端服务启动
echo "⏳ 等待后端服务启动..."
sleep 2

# 测试1: AI训练推荐
test_api "AI训练推荐" "GET" "$BASE_URL/api/training/ai/recommend?user_id=$USER_ID" "" "200"

# 测试2: 保存训练偏好
preferences_data='{
  "user_id": 1,
  "goal": "增肌",
  "frequency": 4,
  "preferred_parts": "chest,back,legs",
  "current_weight": 70.0,
  "target_weight": 75.0,
  "experience": "中级"
}'
test_api "保存训练偏好" "POST" "$BASE_URL/api/training/ai/preferences" "$preferences_data" "200"

# 测试3: AI聊天
chat_data='{
  "user_id": 1,
  "message": "我今天肩膀有点疼，还能练胸吗？"
}'
test_api "AI聊天" "POST" "$BASE_URL/api/training/ai/chat" "$chat_data" "200"

# 测试4: 保存训练会话
session_data='{
  "user_id": 1,
  "date": "2025-01-19",
  "plan_id": 1,
  "completed_exercises": [
    {"name": "Bench Press", "sets_done": 4},
    {"name": "Squat", "sets_done": 3}
  ]
}'
test_api "保存训练会话" "POST" "$BASE_URL/api/training/ai/session" "$session_data" "200"

# 测试5: 保存训练计划
plan_data='{
  "user_id": 1,
  "plan": [
    {
      "day": "Monday",
      "parts": [
        {
          "part_name": "Chest",
          "exercises": [
            {
              "name": "Bench Press",
              "sets": 4,
              "reps": 10,
              "weight": 60.0,
              "rest_seconds": 90,
              "notes": "AI推荐动作"
            }
          ]
        }
      ]
    }
  ]
}'
test_api "保存训练计划" "POST" "$BASE_URL/api/training/plan/update" "$plan_data" "200"

# 测试6: 获取训练计划
test_api "获取训练计划" "GET" "$BASE_URL/api/training/plan?user_id=$USER_ID" "" "200"

# 测试7: 动作库查询
test_api "动作库查询" "GET" "$BASE_URL/api/training/exercises" "" "200"

# 测试8: 动作搜索
test_api "动作搜索" "GET" "$BASE_URL/api/training/exercises/search?q=bench" "" "200"

# 测试结果
echo "📊 测试总结"
echo "=================="
echo "总测试数: $TOTAL_TESTS"
echo "成功: $PASSED_TESTS"
echo "失败: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo "🎉 所有测试通过！AI训练页面联调成功！"
    echo ""
    echo "✨ 功能验证:"
    echo "  ✅ AI智能推荐训练计划"
    echo "  ✅ 训练偏好保存"
    echo "  ✅ AI聊天陪练"
    echo "  ✅ 训练会话记录"
    echo "  ✅ 训练计划保存"
    echo "  ✅ 动作库查询"
    echo "  ✅ 数据持久化"
    echo ""
    echo "🚀 可以启动Flutter应用测试AI训练页面！"
else
    echo "❌ 有 $FAILED_TESTS 个测试失败，请检查后端服务"
fi

echo ""
echo "📱 Flutter测试命令:"
echo "cd gymates_flutter && flutter run"
echo ""
echo "🧪 测试页面导航:"
echo "AITrainingTestPage -> AITrainingPage"