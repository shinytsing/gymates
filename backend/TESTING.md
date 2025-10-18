# Go 后端测试文档

## 🧪 测试框架概述

本项目使用 Go 标准测试框架 `testing` 包，配合 `httptest` 进行 HTTP 请求模拟测试。

### 测试依赖

```go
import (
    "net/http"
    "net/http/httptest"
    "testing"
    "encoding/json"
    "bytes"
    
    "github.com/gin-gonic/gin"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
)
```

## 📁 测试文件结构

```
backend/
├── controllers/
│   ├── auth_controller_test.go      # 认证控制器测试
│   ├── home_controller_test.go      # 首页控制器测试
│   ├── detail_controller_test.go    # 详情控制器测试
│   ├── training_controller_test.go  # 训练控制器测试
│   ├── community_controller_test.go # 社区控制器测试
│   ├── integration_test.go          # 集成测试
│   └── test_helpers.go              # 测试辅助函数
├── config/
│   └── test_config.go               # 测试配置
└── run_tests.sh                     # 测试运行脚本
```

## 🔬 单元测试

### 1. 认证接口测试

#### 用户登录测试
```go
func TestLogin(t *testing.T) {
    // 测试正常登录
    // 测试无效邮箱格式
    // 测试密码太短
    // 测试空请求体
}
```

#### 用户注册测试
```go
func TestRegister(t *testing.T) {
    // 测试正常注册
    // 测试用户名太短
    // 测试无效邮箱格式
    // 测试密码太短
}
```

### 2. 首页接口测试

#### 获取首页列表测试
```go
func TestGetHomeList(t *testing.T) {
    // 测试正常获取列表
    // 测试带筛选条件的列表
    // 测试无效分页参数
}
```

#### 新增首页项测试
```go
func TestAddHomeItem(t *testing.T) {
    // 测试正常新增项目
    // 测试缺少必填字段
    // 测试空请求体
}
```

### 3. 详情接口测试

#### 获取详情列表测试
```go
func TestGetDetailList(t *testing.T) {
    // 测试正常获取详情列表
    // 测试带类型筛选
    // 测试带关键词搜索
}
```

#### 提交详情测试
```go
func TestSubmitDetail(t *testing.T) {
    // 测试正常提交详情
    // 测试缺少必填字段
    // 测试空请求体
}
```

### 4. 训练接口测试

#### 获取训练计划测试
```go
func TestGetTrainingPlans(t *testing.T) {
    // 测试正常获取训练计划
    // 测试默认参数
    // 测试无效分页参数
}
```

#### 创建训练计划测试
```go
func TestCreateTrainingPlan(t *testing.T) {
    // 测试正常创建训练计划
    // 测试缺少必填字段
    // 测试空请求体
}
```

### 5. 社区接口测试

#### 获取帖子列表测试
```go
func TestGetPosts(t *testing.T) {
    // 测试正常获取帖子列表
    // 测试带类型筛选
    // 测试带关键词搜索
}
```

#### 创建帖子测试
```go
func TestCreatePost(t *testing.T) {
    // 测试正常创建文本帖子
    // 测试正常创建图片帖子
    // 测试缺少必填字段
    // 测试内容太长
}
```

## 🔗 集成测试

### 用户注册登录流程测试
```go
func TestIntegration(t *testing.T) {
    // 1. 注册用户
    // 2. 登录用户
    // 3. 验证token
}
```

### 训练计划创建和使用流程测试
```go
func TestTrainingPlanFlow(t *testing.T) {
    // 1. 创建训练计划
    // 2. 获取训练计划列表
    // 3. 开始训练会话
    // 4. 更新训练进度
    // 5. 完成训练会话
}
```

### 社区帖子创建和互动流程测试
```go
func TestCommunityFlow(t *testing.T) {
    // 1. 创建帖子
    // 2. 获取帖子列表
    // 3. 点赞帖子
    // 4. 添加评论
    // 5. 删除评论
}
```

## 🛠️ 测试辅助函数

### 测试环境设置
```go
func TestMain(m *testing.M) {
    // 设置测试环境变量
    // 初始化测试数据库
    // 运行测试
    // 清理资源
}
```

### 测试路由设置
```go
func setupTestRouter() *gin.Engine {
    // 创建测试路由
    // 注册所有测试端点
    // 返回路由实例
}
```

### 测试数据创建
```go
func createTestUser() *models.User
func createTestHomeItem() *models.HomeItem
func createTestDetailItem() *models.DetailItem
func createTestPost() *models.Post
func createTestTrainingPlan() *models.TrainingPlan
```

## 🚀 运行测试

### 1. 运行所有测试
```bash
cd backend
./run_tests.sh
```

### 2. 运行单元测试
```bash
go test ./controllers -v
```

### 3. 运行集成测试
```bash
go test ./controllers -v -run TestIntegration
```

### 4. 运行性能测试
```bash
go test ./controllers -v -bench=. -benchmem
```

### 5. 运行竞态检测
```bash
go test ./controllers -v -race
```

### 6. 生成覆盖率报告
```bash
go test ./... -v -cover -coverprofile=coverage.out
go tool cover -html=coverage.out -o coverage.html
```

## 📊 测试覆盖率

### 覆盖率目标
- 单元测试覆盖率: ≥ 80%
- 集成测试覆盖率: ≥ 70%
- 整体测试覆盖率: ≥ 75%

### 覆盖率报告
```bash
# 生成覆盖率报告
go test ./... -cover -coverprofile=coverage.out

# 查看覆盖率统计
go tool cover -func=coverage.out

# 生成HTML报告
go tool cover -html=coverage.out -o coverage.html
```

## 🔍 测试最佳实践

### 1. 测试命名
- 测试函数名以 `Test` 开头
- 测试用例名描述测试场景
- 使用 `t.Run()` 组织子测试

### 2. 测试数据
- 使用内存数据库进行测试
- 每个测试使用独立的数据
- 测试后清理测试数据

### 3. 错误处理
- 测试各种错误情况
- 验证错误响应格式
- 检查错误状态码

### 4. 性能测试
- 使用 `testing.B` 进行性能测试
- 测试并发安全性
- 监控内存使用情况

## 🐛 调试测试

### 1. 详细输出
```bash
go test -v ./controllers
```

### 2. 单个测试
```bash
go test -v -run TestLogin ./controllers
```

### 3. 测试超时
```bash
go test -timeout 30s ./controllers
```

### 4. 并行测试
```bash
go test -parallel 4 ./controllers
```

## 📈 持续集成

### GitHub Actions 配置
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
        with:
          go-version: 1.21
      - run: go test ./... -v -cover
```

## 🎯 测试策略

### 1. 测试金字塔
- 单元测试 (70%)
- 集成测试 (20%)
- 端到端测试 (10%)

### 2. 测试优先级
1. 核心业务逻辑
2. API接口
3. 数据库操作
4. 错误处理
5. 性能关键路径

### 3. 测试维护
- 定期更新测试用例
- 保持测试代码简洁
- 及时修复失败的测试
- 监控测试覆盖率变化
