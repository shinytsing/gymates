# 👤 个人中心页面 - 使用指南

## 📋 概述

全新重构的个人中心页面，提供完整的用户身份和成就展示功能。

## ✨ 核心功能

### 1. 用户信息头部 (`UserHeader`)
- **头像展示**：支持网络图片和emoji占位符
- **认证标识**：显示用户认证和会员标识
- **基本信息**：昵称、健身目标、简介
- **社交数据**：粉丝、关注、动态数量
- **编辑入口**：快速进入个人资料编辑

### 2. 成就面板 (`AchievementPanel`)
- **训练统计**：
  - 💪 训练次数
  - ⏱️ 训练时长
  - 🔥 消耗卡路里
  - 📉 体重变化
- **成就徽章**：
  - 显示已解锁徽章
  - 进度条展示解锁进度
  - 点击查看所有徽章
- **分享功能**：
  - 生成精美的成就卡片
  - 一键分享到社交媒体

### 3. 我的内容 (`MyContentSection`)
- **我的动态**：查看发布的所有动态
- **训练计划**：管理个人训练计划
- **收藏的帖子**：查看收藏内容
- **我的伙伴**：查看健身伙伴列表
- **会员中心**：（高级用户）查看会员权益

### 4. 设置与工具 (`SettingsSection`)
- **通知设置**：管理推送通知
- **隐私设置**：控制内容可见性
- **语言设置**：切换应用语言
- **设备绑定**：管理绑定设备
- **权限控制**：管理应用权限
- **意见反馈**：提交问题反馈
- **帮助中心**：查看使用指南
- **关于应用**：查看版本信息
- **退出登录**：安全退出账号

## 🎨 主题支持

### 亮色模式
- 清新的渐变色头部
- 白色卡片设计
- 柔和的阴影效果

### 深色模式
- 深色背景
- 高对比度文本
- 绿色主题色

## 🚀 使用方式

### 基本使用

```dart
import 'package:gymates_flutter/pages/profile/profile_page.dart';

// 在导航中使用
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ProfilePage(),
  ),
);
```

### 集成到底部导航

```dart
BottomNavigationBar(
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
    BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: '训练'),
    BottomNavigationBarItem(icon: Icon(Icons.people), label: '社区'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
  ],
  onTap: (index) {
    if (index == 3) {
      // 显示个人中心
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ),
      );
    }
  },
);
```

### 使用主题提供者

```dart
import 'package:provider/provider.dart';
import 'package:gymates_flutter/core/theme/theme_provider.dart';
import 'package:gymates_flutter/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final themeProvider = ThemeProvider();
  await themeProvider.init();
  
  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: ProfilePage(),
        );
      },
    );
  }
}
```

## 📦 数据模型

### UserAchievementData
用户完整数据模型，包含：
- 基本信息（姓名、头像、简介等）
- 社交数据（粉丝、关注、动态）
- 训练统计（次数、时长、卡路里、体重）
- 成就徽章列表
- 个人记录
- 会员信息

```dart
// 使用模拟数据
final userData = UserAchievementData.mockData();

// 从API获取
final userData = UserAchievementData.fromJson(jsonData);
```

## 🎯 核心组件

### 1. UserHeader - 用户头部
```dart
UserHeader(
  userData: userData,
  onEditProfile: () {
    // 编辑个人资料
  },
  onFollowersClick: () {
    // 查看粉丝
  },
  onFollowingClick: () {
    // 查看关注
  },
  onPostsClick: () {
    // 查看动态
  },
)
```

### 2. AchievementPanel - 成就面板
```dart
AchievementPanel(
  userData: userData,
  onShareAchievement: () {
    // 分享成就
  },
  onViewAllBadges: () {
    // 查看所有徽章
  },
)
```

### 3. MyContentSection - 我的内容
```dart
MyContentSection(
  userData: userData,
  onMyPosts: () {
    // 我的动态
  },
  onMyPlans: () {
    // 我的计划
  },
  onSavedPosts: () {
    // 收藏的帖子
  },
  onPartners: () {
    // 我的伙伴
  },
  onMemberCenter: () {
    // 会员中心
  },
)
```

### 4. SettingsSection - 设置区域
```dart
SettingsSection(
  onNotifications: () {},
  onPrivacy: () {},
  onLanguage: () {},
  onDeviceBinding: () {},
  onPermissions: () {},
  onFeedback: () {},
  onHelp: () {},
  onAbout: () {},
  onLogout: () {
    // 退出登录
  },
)
```

### 5. AchievementShareCard - 成就分享卡片
```dart
showDialog(
  context: context,
  builder: (context) => AchievementShareCard(
    userData: userData,
  ),
);
```

## 🎨 自定义样式

所有颜色都在 `GyMatesColors` 中定义：
- `primaryGreen`: #92E3A9
- `primaryPurple`: #6366F1
- `accentCyan`: #06B6D4
- `darkBackground`: #111827
- `cardBackground`: #1F2937

## 📱 响应式设计

页面自动适配不同屏幕尺寸：
- 手机竖屏
- 手机横屏
- 平板设备

## ⚡ 性能优化

- 使用 `RepaintBoundary` 优化重绘
- 懒加载图片
- 动画使用硬件加速
- 列表使用 `ListView.builder`

## 🔧 依赖包

```yaml
dependencies:
  flutter:
    sdk: flutter
  share_plus: ^7.0.0          # 分享功能
  path_provider: ^2.0.0       # 文件路径
  shared_preferences: ^2.0.0  # 本地存储
  provider: ^6.0.0            # 状态管理
```

## 📝 待实现功能

- [ ] 连接真实API接口
- [ ] 成就徽章动画效果
- [ ] 数据统计图表
- [ ] 成就卡片更多模板
- [ ] 离线数据缓存
- [ ] 多语言支持
- [ ] 无障碍功能

## 🐛 已知问题

暂无

## 📧 反馈

如有问题或建议，请联系开发团队。

---

**版本**: 2.0.0  
**最后更新**: 2025-11-02  
**维护者**: Gymates Development Team

