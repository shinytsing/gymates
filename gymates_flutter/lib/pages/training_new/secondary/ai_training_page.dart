import 'package:flutter/material.dart';
import '../../../screens/training/ai_coach_screen.dart';

/// 🤖 AI教练模式页面（二级页面）
/// AI推荐计划生成、AI陪练（语音指导）、AI训练总结
/// 
/// 这是一个包装器，直接使用重构后的 AICoachScreen
class AITrainingPage extends StatelessWidget {
  const AITrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AICoachScreen();
  }
}
