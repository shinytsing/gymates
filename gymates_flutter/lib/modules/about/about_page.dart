import 'package:flutter/material.dart';
import 'about_page_3d.dart';

/// ℹ️ 关于我们页面 (3D版本包装)
/// 
/// 功能：
/// - 应用信息
/// - 版本信息
/// - 团队介绍
/// - 隐私政策
/// - 用户协议

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AboutPage3D();
  }
}
