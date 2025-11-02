import 'package:flutter/material.dart';

/// 🎨 Gymates 颜色系统
/// 定义应用中使用的所有颜色常量
class GyMatesColors {
  // 主要品牌色
  static const Color primaryGreen = Color(0xFF92E3A9);
  static const Color primaryPurple = Color(0xFF6366F1);
  static const Color accentCyan = Color(0xFF06B6D4);
  
  // 背景色
  static const Color darkBackground = Color(0xFF111827);
  static const Color cardBackground = Color(0xFF1F2937);
  
  // 文本色
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF);
  
  // 渐变
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, primaryPurple],
  );
  
  // 功能色
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningYellow = Color(0xFFFBBF24);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);
}

