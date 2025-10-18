# Gymates Backend API 文档

## 概述

这是Gymates健身社交应用的Go后端API，提供完整的RESTful接口支持前端应用。

## 快速开始

### 1. 环境要求

- Go 1.21+
- SQLite/MySQL/PostgreSQL
- Git

### 2. 安装和运行

```bash
# 克隆项目
git clone <repository-url>
cd gymates/backend

# 安装依赖
go mod tidy

# 配置环境变量
cp env.example .env
# 编辑 .env 文件设置数据库连接

# 运行服务
go run main.go
```

服务将在 `http://localhost:3000` 启动

### 3. 健康检查

```bash
curl http://localhost:3000/health
```

## API 接口文档

### 认证接口

#### 用户登录
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

#### 用户注册
```http
POST /api/auth/register
Content-Type: application/json

{
  "name": "用户名",
  "email": "user@example.com",
  "password": "password123"
}
```

### 首页接口

#### 获取列表
```http
GET /api/home/list?page=1&limit=10&category=fitness&keyword=训练
```

**查询参数：**
- `page`: 页码 (默认: 1)
- `limit`: 每页数量 (默认: 10, 最大: 100)
- `category`: 分类筛选
- `status`: 状态筛选 (active/inactive)
- `keyword`: 关键词搜索
- `sort_by`: 排序字段 (created_at/title/view_count/like_count)
- `order`: 排序方向 (asc/desc)

**响应示例：**
```json
{
  "success": true,
  "message": "获取列表成功",
  "data": {
    "items": [
      {
        "id": 1,
        "title": "胸肌训练计划",
        "description": "强化胸部肌肉的训练方案",
        "image": "https://example.com/image.jpg",
        "category": "fitness",
        "tags": "胸肌,力量训练",
        "status": "active",
        "priority": 1,
        "view_count": 100,
        "like_count": 25,
        "comment_count": 8,
        "user": {
          "id": 1,
          "name": "健身达人",
          "email": "user@example.com",
          "avatar": "https://example.com/avatar.jpg"
        },
        "created_at": "2024-01-01T00:00:00Z",
        "updated_at": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 100,
      "total_pages": 10,
      "has_more": true
    }
  }
}
```

#### 新增项目
```http
POST /api/home/add
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "新训练计划",
  "description": "训练描述",
  "image": "https://example.com/image.jpg",
  "category": "fitness",
  "tags": "训练,健身",
  "priority": 1
}
```

#### 更新项目
```http
PUT /api/home/update/1
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "更新后的标题",
  "description": "更新后的描述",
  "status": "active"
}
```

#### 删除项目
```http
DELETE /api/home/delete/1
Authorization: Bearer <token>
```

#### 获取详情
```http
GET /api/home/1
```

#### 点赞项目
```http
POST /api/home/1/like
Authorization: Bearer <token>
```

#### 获取统计
```http
GET /api/home/stats
```

### 训练接口

#### 获取训练计划列表
```http
GET /api/training/plans?page=1&limit=10
```

#### 创建训练计划
```http
POST /api/training/plans
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "胸肌训练",
  "description": "强化胸部肌肉",
  "exercises": [
    {
      "name": "平板卧推",
      "sets": 3,
      "reps": 12,
      "weight": 60,
      "rest_time": 60,
      "instructions": "保持背部挺直",
      "order": 1
    }
  ],
  "duration": 45,
  "calories_burned": 300,
  "difficulty": "intermediate",
  "is_public": true
}
```

#### 开始训练会话
```http
POST /api/training/sessions
Authorization: Bearer <token>
Content-Type: application/json

{
  "training_plan_id": 1
}
```

#### 更新训练进度
```http
PUT /api/training/sessions/1/progress
Authorization: Bearer <token>
Content-Type: application/json

{
  "progress": 50
}
```

#### 完成训练会话
```http
POST /api/training/sessions/1/complete
Authorization: Bearer <token>
```

### 社区接口

#### 获取帖子列表
```http
GET /api/community/posts?page=1&limit=10&type=following
```

#### 创建帖子
```http
POST /api/community/posts
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "今天的训练太棒了！",
  "images": ["https://example.com/image1.jpg"],
  "type": "text"
}
```

#### 点赞帖子
```http
POST /api/community/posts/1/like
Authorization: Bearer <token>
```

#### 获取评论
```http
GET /api/community/posts/1/comments?page=1&limit=10
```

#### 创建评论
```http
POST /api/community/posts/1/comments
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "很棒的训练！"
}
```

### 搭子接口

#### 获取搭子列表
```http
GET /api/mates?page=1&limit=10
Authorization: Bearer <token>
```

#### 发送搭子请求
```http
POST /api/mates/requests
Authorization: Bearer <token>
Content-Type: application/json

{
  "mate_id": 2
}
```

#### 接受搭子请求
```http
POST /api/mates/requests/1/accept
Authorization: Bearer <token>
```

#### 拒绝搭子请求
```http
POST /api/mates/requests/1/reject
Authorization: Bearer <token>
```

#### 移除搭子
```http
DELETE /api/mates/1
Authorization: Bearer <token>
```

### 消息接口

#### 获取聊天列表
```http
GET /api/messages/chats?page=1&limit=10
Authorization: Bearer <token>
```

### 详情接口

#### 获取详情列表
```http
GET /api/detail/list?page=1&limit=10&type=post&category=fitness
```

**查询参数：**
- `page`: 页码 (默认: 1)
- `limit`: 每页数量 (默认: 10, 最大: 100)
- `category`: 分类筛选
- `type`: 类型筛选 (post, profile, chat, achievement, training, mates)
- `status`: 状态筛选 (draft/published)
- `keyword`: 关键词搜索
- `user_id`: 用户ID筛选
- `parent_id`: 父级ID筛选
- `sort_by`: 排序字段 (created_at/title/view_count/like_count)
- `order`: 排序方向 (asc/desc)

**响应示例：**
```json
{
  "success": true,
  "message": "获取列表成功",
  "data": {
    "items": [
      {
        "id": 1,
        "title": "胸肌训练详情",
        "content": "详细的训练内容...",
        "description": "训练描述",
        "images": "image1.jpg,image2.jpg",
        "videos": "video1.mp4",
        "files": "plan.pdf",
        "category": "fitness",
        "type": "post",
        "status": "published",
        "priority": 1,
        "view_count": 50,
        "like_count": 10,
        "comment_count": 3,
        "share_count": 2,
        "tags": "胸肌,训练,健身",
        "metadata": "{\"difficulty\":\"intermediate\"}",
        "user": {
          "id": 1,
          "name": "健身达人",
          "email": "user@example.com",
          "avatar": "avatar.jpg"
        },
        "parent": null,
        "children": [],
        "created_at": "2024-01-01T00:00:00Z",
        "updated_at": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 100,
      "total_pages": 10,
      "has_more": true
    }
  }
}
```

#### 获取详情
```http
GET /api/detail/1
```

#### 提交详情
```http
POST /api/detail/submit
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "新训练详情",
  "content": "详细的训练内容",
  "description": "训练描述",
  "images": ["image1.jpg", "image2.jpg"],
  "videos": ["video1.mp4"],
  "files": ["plan.pdf"],
  "category": "fitness",
  "type": "post",
  "status": "published",
  "priority": 1,
  "tags": ["训练", "健身", "胸肌"],
  "metadata": "{\"difficulty\":\"intermediate\"}",
  "parent_id": null
}
```

#### 更新详情
```http
PUT /api/detail/update/1
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "更新后的标题",
  "content": "更新后的内容",
  "status": "published"
}
```

#### 删除详情
```http
DELETE /api/detail/delete/1
Authorization: Bearer <token>
```

#### 点赞详情
```http
POST /api/detail/1/like
Authorization: Bearer <token>
```

#### 分享详情
```http
POST /api/detail/1/share
Authorization: Bearer <token>
```

#### 获取详情统计
```http
GET /api/detail/stats
```

### 专项详情接口

#### 帖子详情
```http
GET /api/post-detail/list?page=1&limit=10
POST /api/post-detail/submit
PUT /api/post-detail/update/:id
DELETE /api/post-detail/delete/:id
```

#### 用户资料详情
```http
GET /api/profile-detail/list?page=1&limit=10
POST /api/profile-detail/submit
PUT /api/profile-detail/update/:id
DELETE /api/profile-detail/delete/:id
```

#### 聊天详情
```http
GET /api/chat-detail/list?page=1&limit=10
POST /api/chat-detail/submit
PUT /api/chat-detail/update/:id
DELETE /api/chat-detail/delete/:id
```

#### 成就详情
```http
GET /api/achievement-detail/list?page=1&limit=10
POST /api/achievement-detail/submit
PUT /api/achievement-detail/update/:id
DELETE /api/achievement-detail/delete/:id
```

#### 训练详情
```http
GET /api/training-detail/list?page=1&limit=10
POST /api/training-detail/submit
PUT /api/training-detail/update/:id
DELETE /api/training-detail/delete/:id
```

#### 搭子详情
```http
GET /api/mates-detail/list?page=1&limit=10
POST /api/mates-detail/submit
PUT /api/mates-detail/update/:id
DELETE /api/mates-detail/delete/:id
```

#### 创建聊天
```http
POST /api/messages/chats
Authorization: Bearer <token>
Content-Type: application/json

{
  "participant_ids": [2, 3]
}
```

#### 获取消息
```http
GET /api/messages/chats/1/messages?page=1&limit=20
Authorization: Bearer <token>
```

#### 发送消息
```http
POST /api/messages/chats/1/messages
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "你好！",
  "type": "text"
}
```

#### 标记已读
```http
PUT /api/messages/chats/1/read
Authorization: Bearer <token>
```

## 错误处理

所有接口都遵循统一的错误响应格式：

```json
{
  "success": false,
  "message": "错误描述",
  "error": "详细错误信息",
  "code": 400
}
```

### 常见状态码

- `200`: 成功
- `201`: 创建成功
- `400`: 请求参数错误
- `401`: 未认证
- `403`: 权限不足
- `404`: 资源不存在
- `409`: 数据冲突
- `422`: 数据验证失败
- `500`: 服务器内部错误

## 数据库支持

支持多种数据库：

### SQLite (默认)
```env
DB_TYPE=sqlite
DB_PATH=gymates.db
```

### MySQL
```env
DB_TYPE=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=password
DB_NAME=gymates
```

### PostgreSQL
```env
DB_TYPE=postgres
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=gymates
DB_SSLMODE=disable
```

## 开发说明

### 项目结构

```
backend/
├── main.go                 # 主入口文件
├── go.mod                  # Go模块文件
├── env.example            # 环境变量示例
├── config/
│   └── database.go        # 数据库配置
├── models/
│   ├── models.go          # 数据模型
│   ├── dto.go            # 请求响应结构
│   └── home.go           # 首页相关模型
├── controllers/
│   ├── auth_controller.go    # 认证控制器
│   ├── training_controller.go # 训练控制器
│   ├── community_controller.go # 社区控制器
│   ├── mates_controller.go    # 搭子控制器
│   ├── messages_controller.go # 消息控制器
│   └── homeController.go     # 首页控制器
├── middleware/
│   └── auth.go           # 认证中间件
└── routes/
    ├── routes.go         # 主路由
    └── home.go          # 首页路由
```

### 添加新接口

1. 在 `models/` 中定义数据模型
2. 在 `controllers/` 中实现业务逻辑
3. 在 `routes/` 中配置路由
4. 更新数据库迁移

### 测试接口

使用curl或Postman测试接口：

```bash
# 测试登录
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@gymates.com","password":"password123"}'

# 测试获取列表
curl http://localhost:3000/api/home/list?page=1&limit=10

# 测试创建项目（需要token）
curl -X POST http://localhost:3000/api/home/add \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your-token>" \
  -d '{"title":"测试项目","description":"测试描述"}'
```

## 部署

### Docker部署

```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod tidy && go build -o main .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
COPY --from=builder /app/.env .
CMD ["./main"]
```

### 生产环境配置

1. 设置 `GIN_MODE=release`
2. 使用强密码和JWT密钥
3. 配置HTTPS
4. 设置数据库连接池
5. 添加日志记录
6. 配置监控和告警

## 许可证

MIT License
