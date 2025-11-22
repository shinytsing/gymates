import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/3d_components/index.dart';
import '../../core/animations/cartoon_3d_animations.dart' as cartoon_animations;
import '../../core/animations/page_animations.dart';
import '../../core/theme/cartoon_3d_characters.dart';
import '../../services/unified_auth_service.dart';
import '../../widgets/avatars/fitness_3d_avatar.dart';
import '../../widgets/layouts/page_scaffold_3d.dart';
import '../../routes/app_routes.dart';

/// 📝 Apple Fitness+ Style Register Page (3D)
/// 
/// Design Features:
/// - 3D form inputs
/// - 3D register button
/// - Smooth animations
/// - Apple Fitness+ minimalist style
class RegisterPage3D extends StatefulWidget {
  const RegisterPage3D({super.key});

  @override
  State<RegisterPage3D> createState() => _RegisterPage3DState();
}

class _RegisterPage3DState extends State<RegisterPage3D> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = UnifiedAuthService();

  bool _agreedToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先同意服务协议'),
          backgroundColor: AppleFitnessTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty 
            ? _phoneController.text.trim() 
            : null,
      );

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppleFitnessTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        AppRoutes.pushReplacementNamed(context, AppRoutes.main);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppleFitnessTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('注册失败: $e'),
          backgroundColor: AppleFitnessTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold3D(
      title: '注册账号',
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingXL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppleFitnessTheme.spacingM),
              
              // 3D Avatar
              cartoon_animations.BounceInAnimation(
                delay: const Duration(milliseconds: 100),
                child: Center(
                  child: Fitness3DAvatar(
                    size: 100,
                    angle: AvatarAngle.front,
                    action: FitnessAction.idle,
                  ),
                ),
              ),
              
              SizedBox(height: AppleFitnessTheme.spacingXL),
              
              // Title
              cartoon_animations.SlideInAnimation(
                direction: cartoon_animations.SlideDirection.fromLeft,
                delay: const Duration(milliseconds: 200),
                child: Text(
                  '创建账号',
                  style: AppleFitnessTheme.titleLarge.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              SizedBox(height: AppleFitnessTheme.spacingM),
              
              // Subtitle
              cartoon_animations.SlideInAnimation(
                direction: cartoon_animations.SlideDirection.fromLeft,
                delay: const Duration(milliseconds: 300),
                child: Text(
                  '请填写以下信息完成注册',
                  style: AppleFitnessTheme.bodyLarge.copyWith(
                    color: AppleFitnessTheme.textSecondary,
                  ),
                ),
              ),
              
              SizedBox(height: AppleFitnessTheme.spacingXXL),
              
              // Form Card
              cartoon_animations.SlideInAnimation(
                direction: cartoon_animations.SlideDirection.fromBottom,
                delay: const Duration(milliseconds: 400),
                child: Card3D(
                  padding: EdgeInsets.all(AppleFitnessTheme.spacingXL),
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    children: [
                      // Email
                      Input3D(
                        controller: _emailController,
                        label: '邮箱',
                        hint: '请输入邮箱地址',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入邮箱';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return '请输入正确的邮箱格式';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: AppleFitnessTheme.spacingL),
                      
                      // Username
                      Input3D(
                        controller: _usernameController,
                        label: '用户名',
                        hint: '请输入用户名',
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.person_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入用户名';
                          }
                          if (value.length < 3) {
                            return '用户名至少3个字符';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: AppleFitnessTheme.spacingL),
                      
                      // Phone (optional)
                      Input3D(
                        controller: _phoneController,
                        label: '手机号（可选）',
                        hint: '请输入手机号',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                              return '请输入正确的手机号';
                            }
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: AppleFitnessTheme.spacingL),
                      
                      // Password
                      Input3D(
                        controller: _passwordController,
                        label: '密码',
                        hint: '请输入密码',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outlined,
                        suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        onSuffixTap: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入密码';
                          }
                          if (value.length < 6) {
                            return '密码至少6位';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: AppleFitnessTheme.spacingL),
                      
                      // Confirm Password
                      Input3D(
                        controller: _confirmPasswordController,
                        label: '确认密码',
                        hint: '请再次输入密码',
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icons.lock_outlined,
                        suffixIcon: _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        onSuffixTap: () {
                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请确认密码';
                          }
                          if (value != _passwordController.text) {
                            return '两次输入的密码不一致';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: AppleFitnessTheme.spacingL),
              
              // Terms Agreement
              FadeInAnimation(
                delay: const Duration(milliseconds: 500),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _agreedToTerms = !_agreedToTerms);
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _agreedToTerms 
                                ? AppleFitnessTheme.primaryBlue 
                                : AppleFitnessTheme.textTertiary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          color: _agreedToTerms ? AppleFitnessTheme.primaryBlue : Colors.transparent,
                        ),
                        child: _agreedToTerms
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: AppleFitnessTheme.spacingM),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppleFitnessTheme.bodyMedium.copyWith(
                            color: AppleFitnessTheme.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: '我已阅读并同意'),
                            TextSpan(
                              text: '《服务协议》',
                              style: AppleFitnessTheme.bodyMedium.copyWith(
                                color: AppleFitnessTheme.primaryBlue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: '和'),
                            TextSpan(
                              text: '《隐私政策》',
                              style: AppleFitnessTheme.bodyMedium.copyWith(
                                color: AppleFitnessTheme.primaryBlue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppleFitnessTheme.spacingXXL),
              
              // Register Button
              cartoon_animations.BounceInAnimation(
                delay: const Duration(milliseconds: 600),
                child: SizedBox(
                  width: double.infinity,
                  child: Button3D(
                    text: '注册',
                    onPressed: _agreedToTerms && !_isLoading ? _handleRegister : null,
                    type: Button3DType.primary,
                    isLoading: _isLoading,
                    size: Button3DSize.large,
                  ),
                ),
              ),
              
              SizedBox(height: AppleFitnessTheme.spacingL),
              
              // Login Link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '已有账号？',
                      style: AppleFitnessTheme.bodyMedium.copyWith(
                        color: AppleFitnessTheme.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        '立即登录',
                        style: AppleFitnessTheme.bodyMedium.copyWith(
                          color: AppleFitnessTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

