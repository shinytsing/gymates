import 'package:flutter/material.dart';
import 'register_page_3d.dart';

/// 📝 注册页面 (3D版本包装)
/// 
/// 设计规范：
/// - 简洁的注册表单
/// - 手机号验证
/// - 密码设置
/// - 确认密码
/// - 服务协议同意

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RegisterPage3D();
  }
}
