# 🏋️ Gymates - 健身社交应用

## 项目简介

Gymates 是一个现代化的健身社交应用，采用 **Flutter + Go** 技术栈开发，提供完整的训练计划、社交互动和 AI 智能教练功能。

## 技术栈

### 前端
- **Flutter 3.x** - 跨平台移动应用框架
- **Provider** - 状态管理
- **Dio** - 网络请求
- **fl_chart** - 数据可视化

### 后端
- **Go 1.21+** - 高性能后端服务
- **Gin** - Web 框架
- **GORM** - ORM 框架
- **SQLite/PostgreSQL** - 数据库

## 项目结构

```
gymates/
├── backend/              # Go 后端服务
│   ├── controllers/      # API 控制器
│   ├── models/          # 数据模型
│   ├── services/        # 业务逻辑
│   ├── routes/          # 路由配置
│   └── main.go          # 入口文件
│
├── gymates_flutter/     # Flutter 前端应用
│   ├── lib/
│   │   ├── screens/     # 页面
│   │   │   └── training/ # 训练模块
│   │   ├── core/        # 核心功能
│   │   ├── shared/      # 共享组件
│   │   └── main.dart    # 入口文件
│   └── pubspec.yaml
│
└── figma/              # Figma 设计文件
```

## 快速开始

### 后端服务

```bash
cd backend
go mod tidy
go run main.go
```

后端服务将在 `http://localhost:3000` 启动

### 前端应用

```bash
cd gymates_flutter
flutter pub get
flutter run
```

## 核心功能

### 🏋️ 训练模块
- ✅ 今日训练计划
- ✅ 训练计划编辑器（支持左滑右滑添加运动）
- ✅ 运动库浏览（带视频和详细说明）
- ✅ 训练历史和统计
- ✅ 进度追踪

### 🤖 AI 教练
- ✅ AI 智能训练计划生成
- ✅ 实时训练反馈
- ✅ 个性化推荐
- ✅ 激励消息

### 👥 社交功能
- 社区动态
- 搭子匹配
- 即时消息
- 成就分享

## API 文档

### 训练相关接口

```
GET  /api/training/exercises           # 获取运动库
GET  /api/training/plans               # 获取训练计划
POST /api/training/plans               # 创建训练计划
GET  /api/training/today               # 获取今日训练
POST /api/training/sessions/start     # 开始训练
GET  /api/training/history             # 获取训练历史
POST /api/training/ai/generate-plan   # AI 生成训练计划
```

完整 API 文档请查看 `backend/README.md`

## 环境变量

创建 `.env` 文件：

```bash
# 数据库
DB_TYPE=sqlite
DB_PATH=gymates.db

# 服务器
PORT=3000
HOST=0.0.0.0

# JWT
JWT_SECRET=your-secret-key

# AI 服务（可选）
OPENAI_API_KEY=your-openai-key
```

## 开发规范

### 前端
- 使用 Provider 进行状态管理
- 所有 API 调用通过 Service 层
- 组件复用优先
- 遵循 Material Design

### 后端
- RESTful API 设计
- 统一的错误处理
- 数据验证
- 事务处理

## 许可证

MIT License

