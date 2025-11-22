import 'package:flutter/material.dart';
import 'settings_3d_page.dart';

/// ⚙️ 设置页面 (Apple Fitness+ Style)
/// 
/// 功能特性：
/// - 通知设置（推送、声音、振动）
/// - 界面设置（语言、主题）
/// - 账号与安全（密码、隐私、管理）
/// - 关于（关于我们、用户协议、隐私政策）
/// - Apple Fitness+ 极简3D风格设计
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Settings3DPage();
  }
}
