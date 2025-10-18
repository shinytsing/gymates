#!/bin/bash

# Gymates Backend API 测试脚本

BASE_URL="http://localhost:3000/api"

echo "🚀 开始测试 Gymates Backend API"
echo "=================================="

# 测试健康检查
echo "1. 测试健康检查..."
curl -s "$BASE_URL/../health" | jq '.' || echo "健康检查失败"
echo ""

# 测试用户注册
echo "2. 测试用户注册..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试用户",
    "email": "test@gymates.com",
    "password": "password123"
  }')

echo "$REGISTER_RESPONSE" | jq '.' || echo "注册失败"
echo ""

# 测试用户登录
echo "3. 测试用户登录..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@gymates.com",
    "password": "password123"
  }')

echo "$LOGIN_RESPONSE" | jq '.' || echo "登录失败"

# 提取token
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.token // empty')
if [ -z "$TOKEN" ]; then
  echo "❌ 无法获取token，停止测试"
  exit 1
fi

echo "✅ 获取到token: ${TOKEN:0:20}..."
echo ""

# 测试获取首页列表
echo "4. 测试获取首页列表..."
curl -s "$BASE_URL/home/list?page=1&limit=5" | jq '.' || echo "获取列表失败"
echo ""

# 测试创建首页项目
echo "5. 测试创建首页项目..."
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/home/add" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "测试训练计划",
    "description": "这是一个测试的训练计划",
    "category": "fitness",
    "tags": "测试,训练,健身",
    "priority": 1
  }')

echo "$CREATE_RESPONSE" | jq '.' || echo "创建项目失败"

# 提取项目ID
ITEM_ID=$(echo "$CREATE_RESPONSE" | jq -r '.data.item.id // empty')
if [ -z "$ITEM_ID" ]; then
  echo "❌ 无法获取项目ID"
else
  echo "✅ 创建项目成功，ID: $ITEM_ID"
  echo ""

  # 测试获取项目详情
  echo "6. 测试获取项目详情..."
  curl -s "$BASE_URL/home/$ITEM_ID" | jq '.' || echo "获取详情失败"
  echo ""

  # 测试点赞项目
  echo "7. 测试点赞项目..."
  curl -s -X POST "$BASE_URL/home/$ITEM_ID/like" \
    -H "Authorization: Bearer $TOKEN" | jq '.' || echo "点赞失败"
  echo ""

  # 测试更新项目
  echo "8. 测试更新项目..."
  curl -s -X PUT "$BASE_URL/home/update/$ITEM_ID" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
      "title": "更新后的训练计划",
      "description": "这是更新后的描述"
    }' | jq '.' || echo "更新失败"
  echo ""

  # 测试删除项目
  echo "9. 测试删除项目..."
  curl -s -X DELETE "$BASE_URL/home/delete/$ITEM_ID" \
    -H "Authorization: Bearer $TOKEN" | jq '.' || echo "删除失败"
  echo ""
fi

# 测试获取统计
echo "10. 测试获取统计..."
curl -s "$BASE_URL/home/stats" | jq '.' || echo "获取统计失败"
echo ""

# 测试获取训练计划
echo "11. 测试获取训练计划..."
curl -s "$BASE_URL/training/plans" | jq '.' || echo "获取训练计划失败"
echo ""

# 测试获取社区帖子
echo "12. 测试获取社区帖子..."
curl -s "$BASE_URL/community/posts?page=1&limit=5" | jq '.' || echo "获取帖子失败"
echo ""

# 测试详情接口
echo "13. 测试获取详情列表..."
curl -s "$BASE_URL/detail/list?page=1&limit=5" | jq '.' || echo "获取详情列表失败"
echo ""

# 测试创建详情
echo "14. 测试创建详情..."
DETAIL_RESPONSE=$(curl -s -X POST "$BASE_URL/detail/submit" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "测试详情",
    "content": "这是一个测试的详情内容",
    "description": "详情描述",
    "type": "post",
    "category": "fitness",
    "tags": ["测试", "详情", "健身"],
    "status": "published"
  }')

echo "$DETAIL_RESPONSE" | jq '.' || echo "创建详情失败"

# 提取详情ID
DETAIL_ID=$(echo "$DETAIL_RESPONSE" | jq -r '.data.item.id // empty')
if [ -z "$DETAIL_ID" ]; then
  echo "❌ 无法获取详情ID"
else
  echo "✅ 创建详情成功，ID: $DETAIL_ID"
  echo ""

  # 测试获取详情
  echo "15. 测试获取详情..."
  curl -s "$BASE_URL/detail/$DETAIL_ID" | jq '.' || echo "获取详情失败"
  echo ""

  # 测试点赞详情
  echo "16. 测试点赞详情..."
  curl -s -X POST "$BASE_URL/detail/$DETAIL_ID/like" \
    -H "Authorization: Bearer $TOKEN" | jq '.' || echo "点赞失败"
  echo ""

  # 测试分享详情
  echo "17. 测试分享详情..."
  curl -s -X POST "$BASE_URL/detail/$DETAIL_ID/share" \
    -H "Authorization: Bearer $TOKEN" | jq '.' || echo "分享失败"
  echo ""

  # 测试更新详情
  echo "18. 测试更新详情..."
  curl -s -X PUT "$BASE_URL/detail/update/$DETAIL_ID" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
      "title": "更新后的详情",
      "content": "这是更新后的内容"
    }' | jq '.' || echo "更新失败"
  echo ""

  # 测试删除详情
  echo "19. 测试删除详情..."
  curl -s -X DELETE "$BASE_URL/detail/delete/$DETAIL_ID" \
    -H "Authorization: Bearer $TOKEN" | jq '.' || echo "删除失败"
  echo ""
fi

# 测试帖子详情接口
echo "20. 测试帖子详情接口..."
curl -s "$BASE_URL/post-detail/list?page=1&limit=5" | jq '.' || echo "获取帖子详情失败"
echo ""

# 测试用户资料详情接口
echo "21. 测试用户资料详情接口..."
curl -s "$BASE_URL/profile-detail/list?page=1&limit=5" | jq '.' || echo "获取用户资料详情失败"
echo ""

# 测试成就详情接口
echo "22. 测试成就详情接口..."
curl -s "$BASE_URL/achievement-detail/list?page=1&limit=5" | jq '.' || echo "获取成就详情失败"
echo ""

# 测试训练详情接口
echo "23. 测试训练详情接口..."
curl -s "$BASE_URL/training-detail/list?page=1&limit=5" | jq '.' || echo "获取训练详情失败"
echo ""

echo "🎉 API测试完成！"
echo "=================================="
echo "如果看到以上所有测试都返回了JSON数据，说明API工作正常！"
echo ""
echo "💡 提示："
echo "- 确保后端服务正在运行 (go run main.go)"
echo "- 确保安装了jq工具用于JSON格式化"
echo "- 如果某些测试失败，请检查数据库连接和依赖"
