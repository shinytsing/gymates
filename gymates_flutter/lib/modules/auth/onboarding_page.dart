import 'package:flutter/material.dart';
import 'onboarding_page_3d.dart';

/// 🎯 引导页面 (3D版本包装)
/// 
/// 设计规范：
/// - 多页引导轮播
/// - 精美的插图和动画
/// - 引导用户了解核心功能
/// - 平滑的页面切换

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPage3D();
  }
}
