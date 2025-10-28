import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enhanced_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/enhanced_components.dart';
import '../../../core/animations/page_animations.dart';
import '../../../shared/widgets/loading_overlay.dart';

/// Enhanced Login Screen with Figma-inspired design
class EnhancedLoginScreen extends ConsumerStatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  ConsumerState<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends ConsumerState<EnhancedLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoAnimation;
  late Animation<double> _formAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: AppDurations.slower,
      vsync: this,
    );
    _formController = AnimationController(
      duration: AppDurations.slow,
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: AppCurves.easeOutBack,
    ));

    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: AppCurves.easeOut,
    ));

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _logoController.dispose();
    _formController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.lightImpact();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      final success = await ref.read(authNotifierProvider.notifier).login(email, password);
      
      if (success && mounted) {
        HapticFeedback.mediumImpact();
        AppNavigation.goToMain(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final screenSize = MediaQuery.of(context).size;
    
    return LoadingOverlay(
      isLoading: authState.isLoading,
      loadingText: '正在登录...',
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.spacingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenSize.height * 0.08),
                    
                    // Logo Section with Animation
                    AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoAnimation.value,
                          child: FadeTransition(
                            opacity: _logoAnimation,
                            child: _buildLogoSection(),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: screenSize.height * 0.06),
                    
                    // Form Section with Animation
                    AnimatedBuilder(
                      animation: _formAnimation,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _formAnimation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _formController,
                              curve: AppCurves.easeOut,
                            )),
                            child: _buildFormSection(authState),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: screenSize.height * 0.04),
                    
                    // Footer Section
                    AnimatedBuilder(
                      animation: _formAnimation,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _formAnimation,
                          child: _buildFooterSection(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // App Logo with Glassmorphism
        FrostedGlassContainer(
          width: 100,
          height: 100,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 50,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
        
        const SizedBox(height: AppSizes.spacingL),
        
        // App Title
        Text(
          'Gymates',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        
        const SizedBox(height: AppSizes.spacingS),
        
        // Subtitle
        Text(
          '健身社交平台',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Text
        Text(
          '欢迎回来',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: AppSizes.spacingS),
        
        Text(
          '请登录您的账户',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: AppSizes.spacingXL),
        
        // Error Message
        if (authState.error != null)
          FadeInAnimation(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: EnhancedCard(
                child: Row(
                  children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: AppSizes.iconM,
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: Text(
                      authState.error!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        if (authState.error != null) const SizedBox(height: AppSizes.spacingL),
        
        // Email Field
        EnhancedTextField(
          controller: _emailController,
          labelText: '邮箱地址',
          hintText: '请输入您的邮箱',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(Icons.email_outlined),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入邮箱';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return '请输入有效的邮箱地址';
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppSizes.spacingL),
        
        // Password Field
        EnhancedTextField(
          controller: _passwordController,
          labelText: '密码',
          hintText: '请输入您的密码',
          obscureText: _obscurePassword,
          prefixIcon: Icon(Icons.lock_outlined),
          suffixIcon: AnimatedScaleContainer(
            scale: 0.9,
            onTap: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            child: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
              size: AppSizes.iconM,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入密码';
            }
            if (value.length < 6) {
              return '密码至少需要6位字符';
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppSizes.spacingM),
        
        // Remember Me & Forgot Password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Remember Me
            AnimatedScaleContainer(
              scale: 0.95,
              onTap: () {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _rememberMe ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: _rememberMe ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                    ),
                    child: _rememberMe
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.textOnPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSizes.spacingS),
                  Text(
                    '记住我',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Forgot Password
            AnimatedScaleContainer(
              scale: 0.95,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('忘记密码功能即将推出'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                );
              },
              child: Text(
                '忘记密码？',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSizes.spacingXL),
        
        // Login Button
        EnhancedButton(
          text: '登录',
          onPressed: _handleLogin,
          isLoading: authState.isLoading,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildFooterSection() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            const Expanded(
              child: Divider(
                color: AppColors.border,
                thickness: 0.5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
              child: Text(
                '或',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Expanded(
              child: Divider(
                color: AppColors.border,
                thickness: 0.5,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSizes.spacingL),
        
        // Social Login Buttons
        Row(
          children: [
            Expanded(
              child: EnhancedButton(
                text: 'Google',
                type: ButtonType.secondary,
                icon: Icons.g_mobiledata,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Google登录功能即将推出'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSizes.spacingM),
            Expanded(
              child: EnhancedButton(
                text: 'Apple',
                isSecondary: true,
                icon: Icons.apple,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Apple登录功能即将推出'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSizes.spacingXL),
        
        // Register Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '还没有账号？',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AnimatedScaleContainer(
              scale: 0.95,
              onTap: () {
                AppNavigation.goToRegister(context);
              },
              child: Text(
                '立即注册',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
