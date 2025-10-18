# 🏋️‍♀️ Gymates Flutter - 健身社交应用

## 📱 项目简介

Gymates 是一个现代化的健身社交应用，使用 Flutter 开发，支持 iOS 和 Android 平台。应用提供完整的健身训练、社区互动、AI 训练建议和社交功能。

## ✨ 主要功能

- 🏋️‍♀️ **训练管理**: 个性化训练计划、进度跟踪
- 🤖 **AI 训练**: 智能训练建议和指导
- 👥 **社区互动**: 分享健身成果、交流经验
- 💬 **社交功能**: 寻找健身搭子、消息聊天
- 🏆 **成就系统**: 徽章收集、打卡挑战
- 📊 **数据分析**: 训练数据统计和可视化

## 🚀 快速开始

### 环境要求

- Flutter 3.8.0 或更高版本
- Dart 3.0.0 或更高版本
- Android Studio / Xcode
- iOS 14.0+ / Android API 21+

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd gymates_flutter
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **iOS 配置** (仅 macOS)
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **运行项目**

   **Android:**
   ```bash
   flutter run
   # 或指定设备
   flutter run -d <device-id>
   ```

   **iOS:**
   ```bash
   flutter run
   # 或指定设备
   flutter run -d <device-id>
   ```

## 📁 项目结构

```
lib/
├── main.dart                 # 应用入口
├── theme/                    # 主题配置
│   └── gymates_theme.dart   # 主主题文件
├── routes/                   # 路由配置
│   └── app_routes.dart      # 应用路由
├── pages/                    # 页面组件
│   ├── training/            # 训练页面
│   ├── community/           # 社区页面
│   ├── partner/             # 搭子页面
│   ├── messages/            # 消息页面
│   ├── profile/             # 个人页面
│   └── achievements/        # 成就页面
├── animations/              # 动画组件
│   └── gymates_animations.dart
├── shared/                  # 共享组件
│   └── widgets/
│       └── enhanced_components.dart
└── assets/                  # 资源文件
    ├── images/             # 图片资源
    ├── icons/              # 图标资源
    ├── animations/         # 动画资源
    └── fonts/              # 字体资源
```

## 🎨 设计系统

### 颜色规范
- **主色**: #6366F1 (Indigo)
- **辅助色**: #A855F7 (Purple)
- **强调色**: #06B6D4 (Cyan)
- **背景色**: #F9FAFB (Light Gray)
- **文本色**: #111827 (Dark Gray)

### 组件规范
- **圆角**: 8dp (输入框), 12dp (按钮), 16dp (卡片)
- **间距**: 基于 8dp 网格系统
- **阴影**: 柔光阴影 blurRadius: 15
- **动画**: 300ms 标准过渡时间

## 🔧 开发指南

### 代码规范
- 使用 Dart 官方代码规范
- 组件命名使用 PascalCase
- 文件命名使用 snake_case
- 添加适当的注释和文档

### 状态管理
- 使用 Riverpod 进行状态管理
- Provider 用于依赖注入
- 遵循单一职责原则

### 动画实现
- 使用 Flutter 内置动画 API
- 支持 60fps 流畅动画
- 提供触觉反馈

## 📱 平台支持

### Android
- **最低版本**: API 21 (Android 5.0)
- **目标版本**: API 34 (Android 14)
- **架构**: ARM64, ARMv7, x86_64

### iOS
- **最低版本**: iOS 14.0
- **目标版本**: iOS 17.0
- **架构**: ARM64

## 🚀 构建发布

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🐛 故障排除

### 常见问题

1. **依赖冲突**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **iOS 构建失败**
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   ```

3. **Android 构建失败**
   - 检查 Android SDK 版本
   - 更新 Gradle 和 Kotlin 版本

### 调试模式
```bash
flutter run --debug
```

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📞 联系方式

- 项目链接: [https://github.com/username/gymates-flutter](https://github.com/username/gymates-flutter)
- 问题反馈: [Issues](https://github.com/username/gymates-flutter/issues)

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者和设计师！

---

**注意**: 这是一个演示项目，部分功能可能需要后端 API 支持。请根据实际需求进行相应的配置和开发。