import 'package:flutter/material.dart';
import 'modern_login_page_3d.dart';

/// 🎨 现代化登录页面 (3D版本包装)
/// 支持手机号登录（Mock）、微信登录（Mock）、Apple登录（Mock）
class ModernLoginPage extends StatelessWidget {
  const ModernLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModernLoginPage3D();
  }
}
