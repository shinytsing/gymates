# 🚀 Gymates 快速启动指南

## 📋 项目状态

### ✅ 已完成
- Go 后端服务 (90%)
- Flutter 前端应用 (85%)  
- 训练模块完整实现
- AI 教练服务
- 数据库设计

### ⚠️ 当前问题
- 后端端口配置问题 (正在解决)
- 需要完成路由配置整合

---

## 🎯 项目进度与时间表

**查看详细计划**: [PROJECT_ROADMAP.md](PROJECT_ROADMAP.md)

### 预计上线时间: 2025年1月23日

### 本周任务 (1月2-8日)
1. ✅ 修复后端启动问题
2. ⏳ 完成前端路由配置
3. ⏳ API 完全集成
4. ⏳ 初始化运动库数据
5. ⏳ 第一轮功能测试

---

## 🛠️ 手动启动步骤

### 1. 启动后端服务

```bash
cd backend

# 检查环境配置
cat .env

# 方式1: 直接运行
go run main.go

# 方式2: 编译后运行
go build -o gymates-server main.go
./gymates-server
```

**后端地址**: 
- 开发环境: `http://localhost:3000` 或 `http://localhost:8080`
- 健康检查: `/health`
- API 文档: `/api`

### 2. 启动 Flutter 应用

```bash
cd gymates_flutter

# 检查设备
flutter devices

# 启动到 Android 模拟器
flutter run -d emulator-5554

# 启动到 iOS 模拟器
flutter run -d "iPhone 16 Pro"

# 启动到 macOS
flutter run -d macos
```

---

## 🐛 常见问题解决

### 后端启动失败

**问题**: 端口被占用
```bash
# 查看端口占用
lsof -i :3000
lsof -i :8080

# 杀死占用进程
lsof -ti :3000 | xargs kill -9
lsof -ti :8080 | xargs kill -9
```

**问题**: 数据库错误
```bash
cd backend
rm gymates.db
# 重新启动服务,会自动创建数据库
```

**问题**: 依赖问题
```bash
cd backend
go mod tidy
go build ./...
```

### Flutter 构建失败

**问题**: 依赖问题
```bash
cd gymates_flutter
flutter clean
flutter pub get
```

**问题**: 编译错误
```bash
flutter analyze
dart fix --apply
```

**问题**: 设备未连接
```bash
# Android
flutter emulators
flutter emulators --launch <emulator_id>

# iOS  
open -a Simulator
```

---

## 📝 开发规范

### Git 提交规范
```
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式
refactor: 重构
test: 测试
chore: 构建/工具
```

### 分支策略
- `main`: 生产环境
- `develop`: 开发环境
- `feature/*`: 功能分支
- `fix/*`: 修复分支

---

## 📞 团队协作

### 任务分配
- **后端开发**: Go 服务、API、数据库
- **前端开发**: Flutter UI、状态管理、集成
- **测试**: 功能测试、性能测试
- **DevOps**: 部署、监控、CI/CD

### 每日站会
- 时间: 每天上午 10:00
- 内容: 昨天完成 / 今天计划 / 遇到问题

### 代码审查
- 所有 PR 需要至少 1 人审查
- 确保测试通过
- 遵循代码规范

---

## 🎯 下一步行动

### 今天 (立即执行)
1. 修复后端端口配置问题
2. 确保后端服务稳定运行
3. 测试 Flutter 应用在模拟器上运行
4. 准备运动库初始数据 (100+条)

### 明天
1. 完成所有页面路由配置
2. 集成并测试所有 API  
3. 修复前端 UI bug
4. 开始社区功能完善

### 本周末
- 完成基础功能集成
- 进行第一轮测试
- 准备下周迭代计划

---

## 📊 进度追踪

使用 GitHub Projects 或 Jira 追踪任务进度:

- [ ] 后端稳定性修复
- [ ] 前端路由完善
- [ ] API 集成测试
- [ ] 运动库数据准备
- [ ] 社区功能完善
- [ ] 消息系统实现
- [ ] 性能优化
- [ ] 单元测试覆盖

---

**最后更新**: 2025-01-01 22:30
**负责人**: 开发团队
**当前sprint**: Sprint 1 (1月2-15日)

