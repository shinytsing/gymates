import 'package:flutter/material.dart';
import '../../services/auth_service_enhanced.dart';
import '../../theme/app_theme.dart';

/// 🚀 应用初始化页面
/// 检查登录状态、验证Token、自动跳转
class AppInitPage extends StatefulWidget {
  const AppInitPage({super.key});

  @override
  State<AppInitPage> createState() => _AppInitPageState();
}

class _AppInitPageState extends State<AppInitPage> {
  final _authService = AuthServiceEnhanced();
  String _statusMessage = '正在启动...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // 检查是否已登录
      setState(() => _statusMessage = '检查登录状态...');
      final isLoggedIn = await _authService.isLoggedIn();

      if (!isLoggedIn) {
        // 未登录，跳转到登录页
        _navigateToLogin();
        return;
      }

      // 已登录，检查Token是否有效
      setState(() => _statusMessage = '验证身份信息...');
      
      // 尝试获取当前用户信息
      final user = await _authService.getCurrentUser();
      
      if (user != null) {
        // Token有效，跳转到首页
        setState(() => _statusMessage = '欢迎回来，${user.name}！');
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToHome();
      } else {
        // Token无效，尝试刷新
        setState(() => _statusMessage = '正在刷新登录信息...');
        final refreshed = await _authService.refreshAccessToken();
        
        if (refreshed) {
          // 刷新成功，跳转到首页
          _navigateToHome();
        } else {
          // 刷新失败，需要重新登录
          setState(() => _statusMessage = '登录已过期，请重新登录');
          await Future.delayed(const Duration(seconds: 1));
          _navigateToLogin();
        }
      }
    } catch (e) {
      print('❌ 应用初始化错误: $e');
      setState(() => _statusMessage = '初始化失败');
      await Future.delayed(const Duration(seconds: 1));
      _navigateToLogin();
    }
  }

  /// 跳转到登录页
  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  /// 跳转到首页
  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(height: 40),

                // 应用名称
                const Text(
                  'Gymates',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 12),

                // 副标题
                Text(
                  'Fitness Social App',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 60),

                // 加载指示器
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),

                const SizedBox(height: 24),

                // 状态消息
                Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                const SizedBox(height: 100),

                // 版本信息
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

