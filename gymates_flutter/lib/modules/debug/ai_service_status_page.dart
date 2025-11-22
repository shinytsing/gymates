import 'package:flutter/material.dart';
import 'ai_service_status_page_3d.dart';

/// 🤖 AI服务状态页面 (3D版本包装)
/// 
/// 显示当前AI服务状态，允许用户切换AI服务提供商
class AIServiceStatusPage extends StatelessWidget {
  const AIServiceStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AIServiceStatusPage3D();
  }
}
