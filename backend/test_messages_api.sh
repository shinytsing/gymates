#!/bin/bash

# 测试消息和通知API接口

BASE_URL="http://localhost:8080"
TOKEN=""  # 需要先登录获取token

echo "🚀 开始测试 Gymates 消息和通知API"
echo "=================================="

# 1. 测试用户登录（获取token）
echo ""
echo "1️⃣ 测试登录..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }')

echo "登录响应: $LOGIN_RESPONSE"

# 提取token（需要jq工具）
if command -v jq &> /dev/null; then
  TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token')
  echo "Token: $TOKEN"
else
  echo "⚠️  请安装jq工具以自动提取token: brew install jq"
  echo "或手动设置 TOKEN 变量"
  exit 1
fi

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ 登录失败，无法获取token"
  exit 1
fi

# 2. 测试获取聊天列表
echo ""
echo "2️⃣ 测试获取聊天列表..."
curl -s -X GET "$BASE_URL/api/messages/chats?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.'

# 3. 测试获取未读消息数量
echo ""
echo "3️⃣ 测试获取未读消息数量..."
curl -s -X GET "$BASE_URL/api/messages/unread" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.'

# 4. 测试创建聊天（假设user_id=2存在）
echo ""
echo "4️⃣ 测试创建聊天..."
CREATE_CHAT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/messages/chats" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "participant_ids": [2]
  }')

echo $CREATE_CHAT_RESPONSE | jq '.'

CHAT_ID=$(echo $CREATE_CHAT_RESPONSE | jq -r '.data.id')

if [ ! -z "$CHAT_ID" ] && [ "$CHAT_ID" != "null" ]; then
  # 5. 测试发送消息
  echo ""
  echo "5️⃣ 测试发送消息到聊天 $CHAT_ID..."
  curl -s -X POST "$BASE_URL/api/messages/chats/$CHAT_ID/messages" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "content": "测试消息",
      "type": "text"
    }' \
    | jq '.'

  # 6. 测试获取聊天消息
  echo ""
  echo "6️⃣ 测试获取聊天 $CHAT_ID 的消息..."
  curl -s -X GET "$BASE_URL/api/messages/chats/$CHAT_ID/messages?page=1&limit=20" \
    -H "Authorization: Bearer $TOKEN" \
    | jq '.'

  # 7. 测试标记消息为已读
  echo ""
  echo "7️⃣ 测试标记聊天 $CHAT_ID 为已读..."
  curl -s -X POST "$BASE_URL/api/messages/chats/$CHAT_ID/read" \
    -H "Authorization: Bearer $TOKEN" \
    | jq '.'
fi

# 8. 测试获取通知列表
echo ""
echo "8️⃣ 测试获取通知列表..."
curl -s -X GET "$BASE_URL/api/notifications?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.'

# 9. 测试获取未读通知数量
echo ""
echo "9️⃣ 测试获取未读通知数量..."
curl -s -X GET "$BASE_URL/api/notifications/unread-count" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.'

# 10. 测试创建通知
echo ""
echo "🔟 测试创建通知..."
CREATE_NOTIF_RESPONSE=$(curl -s -X POST "$BASE_URL/api/notifications" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "title": "测试通知",
    "content": "这是一条测试通知",
    "type": "system"
  }')

echo $CREATE_NOTIF_RESPONSE | jq '.'

NOTIF_ID=$(echo $CREATE_NOTIF_RESPONSE | jq -r '.data.id')

if [ ! -z "$NOTIF_ID" ] && [ "$NOTIF_ID" != "null" ]; then
  # 11. 测试标记单个通知为已读
  echo ""
  echo "1️⃣1️⃣ 测试标记通知 $NOTIF_ID 为已读..."
  curl -s -X POST "$BASE_URL/api/notifications/$NOTIF_ID/read" \
    -H "Authorization: Bearer $TOKEN" \
    | jq '.'
fi

# 12. 测试标记所有通知为已读
echo ""
echo "1️⃣2️⃣ 测试标记所有通知为已读..."
curl -s -X POST "$BASE_URL/api/notifications/read-all" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.'

echo ""
echo "=================================="
echo "✅ 测试完成！"

