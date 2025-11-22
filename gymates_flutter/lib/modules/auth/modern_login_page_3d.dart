import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/3d_components/index.dart';
import '../../core/animations/cartoon_3d_animations.dart' as cartoon_animations;
import '../../core/theme/cartoon_3d_characters.dart';
import '../../services/unified_auth_service.dart';
import '../../widgets/avatars/fitness_3d_avatar.dart';
import '../../widgets/layouts/page_scaffold_3d.dart';

/// 🎨 Apple Fitness+ Style Modern Login Page (3D)
/// 
/// Design Features:
/// - 3D avatar display
/// - 3D login buttons with gradients
/// - Smooth animations
/// - Apple Fitness+ minimalist style
class ModernLoginPage3D extends StatefulWidget {
  const ModernLoginPage3D({super.key});

  @override
  State<ModernLoginPage3D> createState() => _ModernLoginPage3DState();
}

class _ModernLoginPage3DState extends State<ModernLoginPage3D> {
  final _authService = UnifiedAuthService();
  bool _isLoading = false;

  /// 手机号登录（Mock版本，点击即登录）
  Future<void> _phoneLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await _authService.mockPhoneLogin();
      setState(() => _isLoading = false);

      if (result.success && result.user != null) {
        _showMessage('欢迎，${result.user!.name}！');
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
    HapticFeedback.mediumImpact();

    try {
      final result = await _authService.mockAppleLogin();
      setState(() => _isLoading = false);

      if (result.success && result.user != null) {
        _showMessage('欢迎，${result.user!.name}！');
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
    HapticFeedback.mediumImpact();

    try {
      final result = await _authService.mockWeChatLogin();
      setState(() => _isLoading = false);

      if (result.success && result.user != null) {
        _showMessage('欢迎，${result.user!.name}！');
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppleFitnessTheme.error : AppleFitnessTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  /// 导航到首页
  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold3D(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            
            // 3D Avatar
            cartoon_animations.BounceInAnimation(
              delay: const Duration(milliseconds: 100),
              child: Fitness3DAvatar(
                size: 120,
                angle: AvatarAngle.front,
                action: FitnessAction.idle,
              ),
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingXL),
            
            // Title
            cartoon_animations.BounceInAnimation(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Gymates',
                style: AppleFitnessTheme.titleLarge.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingM),
            
            // Subtitle
            cartoon_animations.BounceInAnimation(
              delay: const Duration(milliseconds: 300),
              child: Text(
                '嗨，欢迎回来\n开始你的训练吧！',
                textAlign: TextAlign.center,
                style: AppleFitnessTheme.bodyLarge.copyWith(
                  color: AppleFitnessTheme.textSecondary,
                ),
              ),
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingXXL),
            
            // Login Card
            cartoon_animations.SlideInAnimation(
              direction: cartoon_animations.SlideDirection.fromBottom,
              delay: const Duration(milliseconds: 400),
              child: Card3D(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingXL),
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  children: [
                    // 手机号登录按钮
                    SizedBox(
                      width: double.infinity,
                      child: Button3D(
                        text: '手机号登录',
                        icon: Icons.phone_outlined,
                        onPressed: _isLoading ? null : _phoneLogin,
                        type: Button3DType.primary,
                        isLoading: _isLoading,
                        size: Button3DSize.large,
                      ),
                    ),
                    
                    SizedBox(height: AppleFitnessTheme.spacingL),
                    
                    // 社交登录分隔线
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppleFitnessTheme.textQuaternary)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingM),
                          child: Text(
                            '或使用以下方式登录',
                            style: AppleFitnessTheme.bodySmall.copyWith(
                              color: AppleFitnessTheme.textTertiary,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppleFitnessTheme.textQuaternary)),
                      ],
                    ),
                    
                    SizedBox(height: AppleFitnessTheme.spacingL),
                    
                    // 社交登录按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Button3D(
                            text: 'Apple',
                            icon: Icons.apple,
                            onPressed: _isLoading ? null : () => _appleLogin(),
                            type: Button3DType.outline,
                            size: Button3DSize.medium,
                          ),
                        ),
                        SizedBox(width: AppleFitnessTheme.spacingM),
                        Expanded(
                          child: Button3D(
                            text: '微信',
                            icon: Icons.wechat,
                            onPressed: _isLoading ? null : () => _wechatLogin(),
                            type: Button3DType.outline,
                            size: Button3DSize.medium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

