# 🏗️ Gymates 健身社交应用完整原型

## 📱 项目概述

这是一个现代化健身社交 App「Gymates」的完整交互原型，支持 iOS (375x812) 与 Android (360x800) 双端，自动适配两种系统视觉语言（iOS Human Interface Guidelines / Material Design 3.0）。

## 🎨 整体设计规范

### 主色调
- **主色调**：#6366F1 (Indigo-500)
- **背景色**：浅色模式 #F9FAFB / 深色模式 #111827
- **文字主色**：#1F2937
- **次要文字**：#6B7280

### 视觉规范
- **圆角**：卡片 12px，按钮 8px，头像 50%
- **阴影**：统一柔和投影 (0px 4px 8px rgba(0,0,0,0.1))
- **间距**：页面边距 16px，组件间距 8/12/16px
- **字体**：标题 18px，副标题 16px，正文 14px，说明 12px

### 动画规范
- **页面切换**：滑动
- **Tab切换**：淡入淡出
- **按钮点击**：缩放反馈
- **弹窗**：底部上滑出现

## 🧭 导航结构

底部导航栏 (BottomNavigationBar) 共 5 个 Tab：

1. **🏋️‍♀️ 训练（TrainingPage）**
2. **💬 社区（CommunityPage）**
3. **🤝 搭子（PartnerPage）**
4. **📩 消息（MessagesPage）**
5. **👤 我的（ProfilePage）**

中央 Tab 改为「搭子」，不再使用加号按钮。点击不同 Tab 页面时采用淡入过渡动画。

## 📱 主要页面原型设计

### 1️⃣ 训练页 (TrainingPage)

#### 结构模块：
- **今日训练计划卡片 (TodayPlanCard)**
  - 今日主题（如"上肢力量训练"）
  - 训练时间（45分钟）
  - 动作数量（5个动作）
  - 按钮「开始训练」

- **AI智能推荐 (AIPlanGenerator)**
  - 说明文字：「根据您的数据生成个性化训练计划」
  - 按钮「生成训练计划」

- **训练历史 (TrainingHistoryList)**
  - 若无记录则显示「暂无训练记录，开始您的第一次训练吧」
  - 支持滚动加载

- **数据统计区**
  - 本周训练次数、消耗卡路里、目标完成率

- **打卡日历 (CheckinCalendar)**
- **成就徽章网格 (AchievementGrid)**
- **进度图表 (ProgressChart)**

### 2️⃣ 社区页 (CommunityPage)

#### 模块：
- **顶部切换**：关注 / 推荐 / 热门 / 挑战
- **动态流 (FeedList)**
  - 帖子卡片 (PostCard)：头像、昵称、配图、点赞、评论、分享按钮
- **话题标签 (TopicTags)**
- **挑战卡片区 (ChallengeCards)**：展示官方健身挑战
- **搭子团队列表**：显示附近/推荐搭子团队
- **搜索栏 (UserSearchBar)**：搜索用户、话题、健身房
- **健身房列表 + 评价区（GymList + GymReview）**

### 3️⃣ 搭子页 (PartnerPage)

#### 搭子匹配系统 (PartnerMatch)
- **Tinder风格滑动卡片 (SwipeCard)**：头像、昵称、运动偏好、健身时间段
- **左滑「跳过」，右滑「感兴趣」动画**
- **匹配成功弹窗**：「🎉 你与XXX匹配成功！一起训练吧！」

#### 搭子详情页 (PartnerDetail)
- 显示详细信息：身高、体重、训练类型、活跃时间、匹配度百分比
- 按钮：「发起搭子邀请」

#### 匹配偏好设置 (PreferenceSetting)
- 性别偏好 / 时间段 / 运动类型筛选

### 4️⃣ 消息页 (MessagesPage)

#### 模块：
- **系统通知 (SystemNotificationItem)**
- **聊天列表 (MessageListItem)**：头像、用户名、最后一条消息、未读标识
- **聊天详情页 (ChatBubble)** 支持：文字、图片、语音、视频消息
- **新消息浮动按钮**：「发起聊天」

### 5️⃣ 我的页 (ProfilePage)

#### 模块：
- **个人信息头部 (ProfileHeader)**
  - 头像、昵称、简介
  - 粉丝 / 关注数
  - 按钮：「编辑资料」

- **功能卡片区 (FunctionCard)**
  - 我的训练数据
  - 我的社区
  - 消息中心
  - 设置 / 帮助 / 关于

- **统计组件 (StatsWidget)**
  - 展示训练天数、卡路里、成就数

## 🧍‍♂️ 登录注册流程

### 🔑 登录页 (LoginPage)

#### 视觉：居中卡片布局 + 品牌 LOGO（Gymates）

#### 功能项：
- 手机号一键登录（验证码）
- 微信登录
- Apple 一键登录（iOS端专属）
- 隐私协议与用户协议链接
- 登录按钮置底
- 次要文字：「还没有账号？去注册」

### 🧾 注册页 (RegisterPage)

#### 两步注册流程：

**Step 1：基础信息填写**
- 昵称
- 性别
- 城市

**Step 2：健身档案设置**
- 身高（cm）
- 体重（kg）
- 运动年限（年）
- 训练目标（单选：减脂 / 增肌 / 塑形）

自动计算 BMI 并显示提示（如"理想范围内"、"建议增加肌肉"）

完成后跳转至「训练主页」。

## ⚙️ 交互逻辑

- 所有按钮、卡片均可点击并有轻微缩放动画
- 滚动区域支持懒加载与下拉刷新
- 弹出层自底部滑入
- 页面切换保留状态（状态保存）
- 数据展示区使用占位符，可替换真实数据

## 🧠 技术实现

### 文件结构
```
lib/
├── gymates_prototype_app.dart          # 主应用入口
├── pages/
│   ├── training/training_page.dart     # 训练页
│   ├── community/community_page.dart   # 社区页
│   ├── partner/partner_page.dart       # 搭子页
│   ├── messages/messages_page.dart     # 消息页
│   ├── profile/profile_page.dart       # 我的页
│   └── auth/auth_pages.dart            # 登录注册页
├── theme/gymates_theme.dart           # 主题配置
├── animations/gymates_animations.dart  # 动画配置
└── start_gymates_prototype.sh         # 启动脚本
```

### 核心特性
- **平台适配**：自动检测 iOS/Android 平台，应用对应的设计语言
- **响应式设计**：支持不同屏幕尺寸，确保在各种设备上都有良好体验
- **动画系统**：流畅的页面切换、组件动画和交互反馈
- **主题系统**：支持浅色/深色模式，统一的视觉语言
- **状态管理**：使用 Riverpod 进行状态管理
- **导航系统**：基于 PageView 的底部导航，支持平滑切换

## 🚀 快速开始

### 1. 环境要求
- Flutter SDK 3.8.0+
- Dart 3.0+
- iOS 模拟器或 Android 模拟器

### 2. 安装依赖
```bash
cd gymates_flutter
flutter pub get
```

### 3. 运行应用
```bash
# 使用启动脚本
chmod +x start_gymates_prototype.sh
./start_gymates_prototype.sh

# 或直接运行
flutter run
```

### 4. 选择平台
- iOS 模拟器 (375x812)
- Android 模拟器 (360x800)
- Web 浏览器
- 桌面应用

## 🎯 功能演示

### 训练页功能
- ✅ 今日训练计划展示
- ✅ AI智能推荐系统
- ✅ 训练历史记录
- ✅ 数据统计展示
- ✅ 打卡日历
- ✅ 成就徽章系统

### 社区页功能
- ✅ 动态流展示
- ✅ 官方挑战卡片
- ✅ 话题标签系统
- ✅ 搜索功能
- ✅ 互动按钮（点赞、评论、分享）

### 搭子页功能
- ✅ Tinder风格滑动匹配
- ✅ 搭子详情展示
- ✅ 匹配成功弹窗
- ✅ 匹配偏好设置

### 消息页功能
- ✅ 系统通知
- ✅ 聊天列表
- ✅ 未读消息标识
- ✅ 新消息浮动按钮

### 我的页功能
- ✅ 个人信息展示
- ✅ 统计数据展示
- ✅ 功能卡片导航
- ✅ 设置选项

### 登录注册功能
- ✅ 手机号验证码登录
- ✅ 第三方登录（微信、Apple）
- ✅ 两步注册流程
- ✅ BMI自动计算
- ✅ 协议链接

## 🎨 设计亮点

### 1. 平台原生体验
- **iOS**：遵循 Human Interface Guidelines，使用 Cupertino 组件
- **Android**：遵循 Material Design 3.0，使用 Material 组件
- **自适应**：根据平台自动切换设计语言

### 2. 流畅动画
- **页面切换**：滑动 + 淡入淡出效果
- **组件动画**：缩放、旋转、弹性动画
- **交互反馈**：触觉反馈 + 视觉反馈
- **加载动画**：骨架屏 + 进度指示器

### 3. 响应式布局
- **屏幕适配**：支持不同尺寸屏幕
- **内容布局**：自适应内容高度
- **导航适配**：底部导航栏适配不同平台

### 4. 主题系统
- **浅色模式**：清新明亮的视觉体验
- **深色模式**：护眼的深色主题
- **自动切换**：跟随系统主题设置

## 📊 性能优化

### 1. 渲染优化
- 使用 `const` 构造函数减少重建
- 合理使用 `AnimatedBuilder` 避免不必要的重建
- 列表使用 `ListView.builder` 实现懒加载

### 2. 内存优化
- 及时释放动画控制器
- 使用 `AutomaticKeepAliveClientMixin` 保持页面状态
- 合理管理图片资源

### 3. 交互优化
- 防抖处理避免重复点击
- 异步操作使用 `Future` 避免阻塞UI
- 错误处理确保应用稳定性

## 🔧 自定义配置

### 主题自定义
```dart
// 修改主色调
static const Color primaryColor = Color(0xFF6366F1);

// 修改圆角
static const double radius12 = 12.0;

// 修改间距
static const double spacing16 = 16.0;
```

### 动画自定义
```dart
// 修改动画持续时间
static const Duration normalDuration = Duration(milliseconds: 300);

// 修改动画曲线
static const Curve easeInOut = Curves.easeInOut;
```

## 📱 支持平台

- ✅ **iOS** (375x812) - iPhone 12/13/14 尺寸
- ✅ **Android** (360x800) - 标准 Android 设备尺寸
- ✅ **Web** - 浏览器访问
- ✅ **macOS** - 桌面应用
- ✅ **Windows** - 桌面应用
- ✅ **Linux** - 桌面应用

## 🎉 总结

Gymates 健身社交应用完整原型是一个功能丰富、设计精美的现代化移动应用，完美展示了：

1. **完整的功能模块**：训练、社区、搭子、消息、个人中心
2. **流畅的用户体验**：动画、交互、导航
3. **平台原生体验**：iOS 和 Android 双端适配
4. **现代化设计**：Material Design 3.0 和 Human Interface Guidelines
5. **可扩展架构**：模块化设计，易于维护和扩展

这个原型可以作为实际产品开发的基础，也可以作为设计展示和用户测试的工具。所有代码都经过精心设计，确保代码质量和可维护性。

🚀 **开始您的健身社交之旅吧！**
