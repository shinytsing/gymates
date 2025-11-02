import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

/// 📝 注册页面 - 完全按照 Figma 设计实现
/// 
/// 设计规范：
/// - 简洁的注册表单
/// - 手机号验证
/// - 密码设置
/// - 确认密码
/// - 服务协议同意

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  late AnimationController _formController;
  late Animation<double> _formAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _verificationController = TextEditingController();
  final _authService = AuthService();

  bool _agreedToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _formController.forward();
  }

  @override
  void dispose() {
    _formController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
            color: GymatesTheme.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '注册账号',
          style: TextStyle(
            color: GymatesTheme.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _formAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _formAnimation.value)),
            child: Opacity(
              opacity: _formAnimation.value,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      _buildHeader(),
                      
                      const SizedBox(height: 32),
                      
                      // 表单
                      _buildForm(),
                      
                      const SizedBox(height: 24),
                      
                      // 服务协议
                      _buildTermsAgreement(),
                      
                      const SizedBox(height: 32),
                      
                      // 注册按钮
                      _buildRegisterButton(),
                      
                      const SizedBox(height: 24),
                      
                      // 登录链接
                      _buildLoginLink(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '创建账号',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '请填写以下信息完成注册',
          style: TextStyle(
            fontSize: 16,
            color: GymatesTheme.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // 邮箱
        _buildTextField(
          controller: _emailController,
          label: '邮箱',
          hint: '请输入邮箱地址',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email,
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
        
        const SizedBox(height: 16),
        
        // 用户名
        _buildTextField(
          controller: _usernameController,
          label: '用户名',
          hint: '请输入用户名',
          keyboardType: TextInputType.text,
          prefixIcon: Icons.person,
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
        
        const SizedBox(height: 16),
        
        // 手机号（可选）
        _buildTextField(
          controller: _phoneController,
          label: '手机号（可选）',
          hint: '请输入手机号',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone,
          validator: (value) {
            // 手机号现在是可选的
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                return '请输入正确的手机号';
              }
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // 验证码功能暂时移除，使用邮箱注册
        // TODO: 后续可以添加邮箱验证功能
        
        // 密码
        _buildTextField(
          controller: _passwordController,
          label: '密码',
          hint: '请输入密码',
          obscureText: _obscurePassword,
          prefixIcon: Icons.lock,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: GymatesTheme.lightTextSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
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
        
        const SizedBox(height: 16),
        
        // 确认密码
        _buildTextField(
          controller: _confirmPasswordController,
          label: '确认密码',
          hint: '请再次输入密码',
          obscureText: _obscureConfirmPassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: GymatesTheme.lightTextSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: GymatesTheme.lightTextSecondary,
              fontSize: 16,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: GymatesTheme.lightTextSecondary,
                    size: 20,
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: GymatesTheme.borderColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: GymatesTheme.borderColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: GymatesTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: GymatesTheme.errorColor,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
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
                color: _agreedToTerms 
                    ? GymatesTheme.primaryColor 
                    : GymatesTheme.lightTextSecondary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
              color: _agreedToTerms ? GymatesTheme.primaryColor : Colors.transparent,
            ),
            child: _agreedToTerms
                ? const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: GymatesTheme.lightTextSecondary,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: '我已阅读并同意'),
                TextSpan(
                  text: '《服务协议》',
                  style: TextStyle(
                    color: GymatesTheme.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: '和'),
                TextSpan(
                  text: '《隐私政策》',
                  style: TextStyle(
                    color: GymatesTheme.primaryColor,
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

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _agreedToTerms && !_isLoading ? _handleRegister : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: GymatesTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '注册',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '已有账号？',
            style: TextStyle(
              fontSize: 14,
              color: GymatesTheme.lightTextSecondary,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '立即登录',
              style: TextStyle(
                fontSize: 14,
                color: GymatesTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 验证码功能已移除，使用邮箱直接注册
  // void _sendVerificationCode() { ... }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先同意服务协议'),
          backgroundColor: GymatesTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    try {
      // 调用真实 API 注册
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
        // 注册成功
    ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
        backgroundColor: GymatesTheme.successColor,
            duration: const Duration(seconds: 2),
      ),
    );

        // 延迟跳转
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (!mounted) return;

    // 跳转到主页面
    AppRoutes.pushReplacementNamed(context, AppRoutes.main);
      } else {
        // 注册失败
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: GymatesTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('注册失败: $e'),
          backgroundColor: GymatesTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
