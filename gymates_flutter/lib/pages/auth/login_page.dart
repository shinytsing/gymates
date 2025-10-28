import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../routes/app_routes.dart';

/// 🔐 登录页面 - 完全按照 Figma 设计实现
/// 
/// 设计规范：
/// - 背景图片 + 渐变遮罩
/// - 一键登录按钮
/// - 其他手机号登录
/// - 服务协议同意
/// - 社交登录 (Apple, WeChat)

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  
  late Animation<double> _logoAnimation;
  late Animation<double> _contentAnimation;

  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _contentController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // 背景图片
            _buildBackgroundImage(),
            
            // 渐变遮罩
            _buildGradientOverlay(),
            
            // 内容
            _buildContent(isIOS),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwY291cGxlJTIwd29ya291dCUyMHRvZ2V0aGVyfGVufDF8fHx8MTc1OTYzOTc0NHww&ixlib=rb-4.1.0&q=80&w=1080',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color(0x33000000),
            Color(0x99000000),
          ],
          stops: [0.0, 0.2, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent(bool isIOS) {
    return SafeArea(
      child: Column(
        children: [
          // 状态栏
          _buildStatusBar(),
          
          // 品牌区域
          Expanded(
            child: _buildBrandSection(isIOS),
          ),
          
          // 登录区域
          _buildLoginSection(isIOS),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '09:49',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Container(
                width: 16,
                height: 8,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Container(
                  width: 8,
                  height: 6,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '47',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSection(bool isIOS) {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _logoAnimation.value)),
          child: Opacity(
            opacity: _logoAnimation.value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isIOS ? Colors.white : GymatesTheme.primaryColor,
                      borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '💪',
                        style: TextStyle(
                          fontSize: 32,
                          color: isIOS ? GymatesTheme.primaryColor : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App Name
                  const Text(
                    'Gymates',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Tagline
                  const Text(
                    '寻找你的健身搭子',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Phone Display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '166****3484',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '认证服务由中国联通通信提供',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
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
      },
    );
  }

  Widget _buildLoginSection(bool isIOS) {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // 一键登录按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agreedToTerms ? _handleQuickLogin : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isIOS ? Colors.white : const Color(0xFF10B981),
                        foregroundColor: isIOS ? Colors.black : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                        ),
                      ),
                      child: const Text(
                        '一键登录',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 其他手机号登录
                  TextButton(
                    onPressed: _handlePhoneLogin,
                    child: const Text(
                      '其他手机号登录',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 服务协议
                  _buildTermsAgreement(),
                  
                  const SizedBox(height: 24),
                  
                  // 社交登录
                  _buildSocialLogin(isIOS),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermsAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _agreedToTerms = !_agreedToTerms;
            });
          },
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
              color: _agreedToTerms ? Colors.white : Colors.transparent,
            ),
            child: _agreedToTerms
                ? const Icon(
                    Icons.check,
                    size: 12,
                    color: GymatesTheme.primaryColor,
                  )
                : null,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
              children: [
                TextSpan(text: '已阅读并同意'),
                TextSpan(
                  text: '《服务协议》',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: '、'),
                TextSpan(
                  text: '《用户隐私政策》',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: '和'),
                TextSpan(
                  text: '《第三方信息共享清单》',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin(bool isIOS) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Apple Login
        GestureDetector(
          onTap: () => _handleSocialLogin('apple'),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isIOS 
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.apple,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        
        const SizedBox(width: 32),
        
        // WeChat Login
        GestureDetector(
          onTap: () => _handleSocialLogin('wechat'),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isIOS 
                  ? Colors.white.withValues(alpha: 0.2)
                  : const Color(0xFF10B981).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.chat,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  void _handleQuickLogin() {
    HapticFeedback.lightImpact();
    // TODO: 实现一键登录逻辑
    AppRoutes.pushReplacementNamed(context, AppRoutes.main);
  }

  void _handlePhoneLogin() {
    HapticFeedback.lightImpact();
    // TODO: 跳转到手机号登录页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('手机号登录功能待实现'),
        backgroundColor: GymatesTheme.primaryColor,
      ),
    );
  }

  void _handleSocialLogin(String provider) {
    HapticFeedback.lightImpact();
    // TODO: 实现社交登录逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider登录功能待实现'),
        backgroundColor: GymatesTheme.primaryColor,
      ),
    );
  }
}
