import 'package:flutter/material.dart';
import '../../services/unified_auth_service.dart';
import '../../core/theme/gymates_colors.dart';

/// 🎨 现代化登录页面
/// 支持手机号登录（Mock）、微信登录（Mock）、Apple登录（Mock）
class ModernLoginPage extends StatefulWidget {
  const ModernLoginPage({super.key});

  @override
  State<ModernLoginPage> createState() => _ModernLoginPageState();
}

class _ModernLoginPageState extends State<ModernLoginPage> {
  final _authService = UnifiedAuthService();
  bool _isLoading = false;

  /// 手机号登录（Mock版本，点击即登录）
  Future<void> _phoneLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.mockPhoneLogin();

    setState(() => _isLoading = false);

      if (result.success && result.user != null) {
        _showMessage('欢迎，${result.user!.name}！');
        // 延迟一下让用户看到成功消息
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _navigateToHome();
        }
    } else {
      _showMessage(result.message, isError: true);
    }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('登录失败: $e', isError: true);
    }
  }

  /// Apple登录（Mock版本）
  Future<void> _appleLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.mockAppleLogin();

    setState(() => _isLoading = false);

      if (result.success && result.user != null) {
        _showMessage('欢迎，${result.user!.name}！');
        // 延迟一下让用户看到成功消息
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
      _navigateToHome();
        }
    } else {
      _showMessage(result.message, isError: true);
    }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('登录失败: $e', isError: true);
    }
  }

  /// 微信登录（Mock版本）
  Future<void> _wechatLogin() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);

    try {
      final result = await _authService.mockWeChatLogin();

    setState(() => _isLoading = false);

      if (result.success && result.user != null) {
        _showMessage('欢迎，${result.user!.name}！');
        // 延迟一下让用户看到成功消息
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
      _navigateToHome();
        }
    } else {
      _showMessage(result.message, isError: true);
    }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('登录失败: $e', isError: true);
        }
  }

  /// 显示消息
  void _showMessage(String message, {bool isError = false}) {
    // 如果是多行错误消息（包含换行符），使用Dialog显示
    if (isError && message.contains('\n')) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              const Text('登录失败'),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: isError ? 4 : 2),
        ),
      );
    }
  }

  /// 导航到首页
  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
  }
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
              GyMatesColors.primaryPurple,
              GyMatesColors.primaryPurple.withOpacity(0.8),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Logo 和标题
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 50,
                        color: GyMatesColors.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Gymates',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '嗨，欢迎回来\n开始你的训练吧！',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // 登录表单
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                  child: Column(
                    children: [
                        const SizedBox(height: 40),
                        
                        // 手机号登录按钮（Mock版本，一键登录）
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _phoneLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GyMatesColors.primaryPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.phone, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          '手机号登录',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                          ],
                        ),
                      ),
                          ),
                        ),

                        const SizedBox(height: 24),

                      // 社交登录
                      _buildSocialLogin(),

                        const SizedBox(height: 40),
                    ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// 社交登录
  Widget _buildSocialLogin() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
            '或使用以下方式登录',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Apple登录
              _socialLoginButton(
                icon: Icons.apple,
                label: 'Apple',
                onTap: _appleLogin,
              ),
              // 微信登录
              _socialLoginButton(
                icon: Icons.wechat,
                label: '微信',
                color: Colors.green,
                onTap: _wechatLogin,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 社交登录按钮
  Widget _socialLoginButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    final bool isButtonLoading = _isLoading && 
        (label == 'Apple' || label == '微信');
    
    return InkWell(
      onTap: isButtonLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isButtonLoading ? Colors.grey[200]! : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isButtonLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color ?? GyMatesColors.primaryPurple,
                      ),
                    ),
                  )
                : Icon(icon, size: 36, color: color ?? Colors.black87),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isButtonLoading ? Colors.grey : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

