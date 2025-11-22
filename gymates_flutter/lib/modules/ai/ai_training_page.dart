import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../theme/gymates_theme.dart';
import '../../animations/gymates_animations.dart';

/// 🤖 AI 训练页 AITrainingPage - 流动渐变 + 微粒漂浮 + 电弧光特效
/// 
/// 严格按照 Figma 设计实现：
/// - 背景：流动渐变 + 微粒漂浮 + 电弧光特效
/// - AI卡片：从底部滑入 + 模糊扩散展开
/// - 波形动画：Lottie 动态音浪 + 光带流动
/// - "生成训练"按钮：长按能量环充能 + 爆发动画
/// - 动态 AI 语音回复：打字机式输出 + 光晕闪烁
/// - 动画节奏控制：呼吸频率 2.8s，线性渐变循环

class AITrainingPage extends StatefulWidget {
  const AITrainingPage({super.key});

  @override
  State<AITrainingPage> createState() => _AITrainingPageState();
}

class _AITrainingPageState extends State<AITrainingPage>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late AnimationController _waveformController;
  late AnimationController _cardController;
  late AnimationController _breathingController;
  late AnimationController _energyRingController;
  late AnimationController _typewriterController;
  
  late Animation<double> _gradientAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _waveformAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _energyRingAnimation;
  late Animation<double> _typewriterAnimation;

  bool _isListening = false;
  bool _isGenerating = false;
  bool _isCharging = false;
  final String _aiResponse = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // 渐变动画控制器
    _gradientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    // 粒子动画控制器
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // 波形动画控制器
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // 卡片动画控制器
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 呼吸动画控制器
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );
    
    // 能量环控制器
    _energyRingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // 打字机控制器
    _typewriterController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 渐变动画
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    // 粒子动画
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));

    // 波形动画
    _waveformAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveformController,
      curve: Curves.easeInOut,
    ));

    // 卡片动画
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    ));

    // 呼吸动画
    _breathingAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    // 能量环动画
    _energyRingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _energyRingController,
      curve: Curves.easeInOutCubic,
    ));

    // 打字机动画
    _typewriterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typewriterController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    // 开始渐变动画
    _gradientController.repeat();
    
    // 开始粒子动画
    _particleController.repeat();
    
    // 开始呼吸动画
    _breathingController.repeat(reverse: true);
    
    // 开始卡片动画，带延迟
    await Future.delayed(const Duration(milliseconds: 500));
    _cardController.forward();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    _waveformController.dispose();
    _cardController.dispose();
    _breathingController.dispose();
    _energyRingController.dispose();
    _typewriterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 流动渐变背景 + 微粒漂浮 + 电弧光特效
          _buildDynamicBackground(),
          
          // 主内容
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(GymatesTheme.spacing16),
              child: Column(
                children: [
                  // 头部
                  _buildHeader(),
                  
                  const SizedBox(height: 40),
                  
                  // AI 能量环中心
                  _buildAIEnergyCenter(),
                  
                  const SizedBox(height: 40),
                  
                  // 语音输入区域
                  _buildVoiceInputSection(),
                  
                  const SizedBox(height: 40),
                  
                  // AI 生成内容（从底部滑入 + 模糊扩散展开）
                  _buildAIGeneratedContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicBackground() {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1),
                const Color(0xFF8B5CF6),
                const Color(0xFFA855F7),
                const Color(0xFF06B6D4),
              ],
              stops: [
                0.0,
                0.3 + (_gradientAnimation.value * 0.2),
                0.7 + (_gradientAnimation.value * 0.2),
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              // 微粒漂浮
              _buildParticleSystem(),
              // 电弧光特效
              _buildElectricEffects(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticleSystem() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildElectricEffects() {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ElectricEffectPainter(_gradientAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Training',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: GymatesTheme.spacing8),
              Text(
                'Your personal AI trainer',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        // 设置按钮
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // 打开设置
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(GymatesTheme.radius12),
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIEnergyCenter() {
    return Center(
      child: AnimatedBuilder(
        animation: _breathingAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _breathingAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 外层能量环
                _buildEnergyRing(200, 0.8, _energyRingAnimation.value),
                
                // 中层能量环
                _buildEnergyRing(150, 0.6, _energyRingAnimation.value * 0.7),
                
                // 内层能量环
                _buildEnergyRing(100, 0.4, _energyRingAnimation.value * 0.5),
                
                // 中心内容
                _buildCenterContent(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnergyRing(double size, double progress, double animationValue) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // 背景环
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 4,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          // 动画进度环
          CircularProgressIndicator(
            value: progress * animationValue,
            strokeWidth: 4,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getEnergyRingColor(progress),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEnergyRingColor(double progress) {
    if (progress > 0.7) return const Color(0xFF06B6D4);
    if (progress > 0.4) return const Color(0xFFA855F7);
    return const Color(0xFF6366F1);
  }

  Widget _buildCenterContent() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.fitness_center,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildVoiceInputSection() {
    return Column(
      children: [
        Text(
          'Tell me what you want to train',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: GymatesTheme.spacing24),
        
        // 语音输入按钮
        GestureDetector(
          onTap: _toggleListening,
          child: AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breathingAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening 
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: GymatesTheme.spacing16),
        
        // 波形动画（Lottie 动态音浪 + 光带流动）
        if (_isListening) _buildVoiceWaveform(),
        
        const SizedBox(height: GymatesTheme.spacing24),
        
        // 快速建议
        _buildQuickSuggestions(),
      ],
    );
  }

  Widget _buildVoiceWaveform() {
    return AnimatedBuilder(
      animation: _waveformAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 60,
          width: 200,
          child: CustomPaint(
            painter: VoiceWaveformPainter(_waveformAnimation.value),
            size: const Size(200, 60),
          ),
        );
      },
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions = [
      'Full body workout',
      'Cardio session',
      'Strength training',
      'Yoga flow',
    ];

    return Wrap(
      spacing: GymatesTheme.spacing12,
      runSpacing: GymatesTheme.spacing12,
      children: suggestions.map((suggestion) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _generateWorkout(suggestion);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GymatesTheme.spacing16,
              vertical: GymatesTheme.spacing8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              suggestion,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAIGeneratedContent() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _cardAnimation.value)),
          child: Opacity(
            opacity: _cardAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Generated Workout',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: GymatesTheme.spacing16),
                
                // AI 卡片（从底部滑入 + 模糊扩散展开）
                _buildAIWorkoutCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAIWorkoutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GymatesTheme.spacing20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(GymatesTheme.radius16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: GymatesTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(GymatesTheme.radius12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: GymatesTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full Body HIIT',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '30 minutes • High intensity',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: GymatesTheme.spacing16),
          
          // 训练步骤
          ...List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: GymatesTheme.spacing8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: GymatesTheme.spacing12),
                  Expanded(
                    child: Text(
                      'Exercise ${index + 1} - 45 seconds',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: GymatesTheme.spacing20),
          
          // "生成训练"按钮（长按能量环充能 + 爆发动画）
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return GestureDetector(
      onLongPressStart: (_) {
        setState(() {
          _isCharging = true;
        });
        _energyRingController.forward();
        HapticFeedback.mediumImpact();
      },
      onLongPressEnd: (_) {
        setState(() {
          _isCharging = false;
        });
        _energyRingController.reset();
        _showBurstAnimation();
      },
      onTap: () {
        HapticFeedback.mediumImpact();
        // 开始训练
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: GymatesTheme.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isCharging) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    GymatesTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: GymatesTheme.spacing8),
            ],
            Text(
              _isCharging ? 'Charging...' : 'Start Workout',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GymatesTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });
    
    if (_isListening) {
      _waveformController.repeat();
    } else {
      _waveformController.stop();
    }
    
    HapticFeedback.mediumImpact();
  }

  void _generateWorkout(String suggestion) {
    setState(() {
      _isGenerating = true;
    });
    
    // 模拟 AI 生成
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isGenerating = false;
      });
      _cardController.forward();
      
      // 开始打字机效果
      _typewriterController.forward();
    });
    
    HapticFeedback.lightImpact();
  }

  void _showBurstAnimation() {
    // 显示爆发动画
    GymatesAnimations.createParticleExplosion(
      child: Container(),
    );
  }
}

/// 🎵 语音波形绘制器
class VoiceWaveformPainter extends CustomPainter {
  final double animationValue;
  
  VoiceWaveformPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final centerY = size.height / 2;
    final barWidth = 4.0;
    final spacing = 6.0;
    
    for (int i = 0; i < 20; i++) {
      final x = i * (barWidth + spacing);
      final height = (math.sin(animationValue * 2 * math.pi + i * 0.5) * 20 + 20).abs();
      
      canvas.drawRect(
        Rect.fromLTWH(x, centerY - height / 2, barWidth, height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// 🎨 粒子系统绘制器
class ParticlePainter extends CustomPainter {
  final double animationValue;
  
  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    
    for (int i = 0; i < 20; i++) {
      final x = (random.nextDouble() * size.width);
      final y = (random.nextDouble() * size.height);
      final radius = 2 + (random.nextDouble() * 3);
      
      final offsetY = math.sin(animationValue * 2 * math.pi + i) * 20;
      final opacity = 0.1 + (math.sin(animationValue * 2 * math.pi + i) * 0.1);
      
      paint.color = Colors.white.withValues(alpha: opacity.clamp(0.0, 0.2));
      
      canvas.drawCircle(
        Offset(x, y + offsetY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// ⚡ 电弧光特效绘制器
class ElectricEffectPainter extends CustomPainter {
  final double animationValue;
  
  ElectricEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final random = math.Random(123);
    
    for (int i = 0; i < 5; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final endX = startX + (random.nextDouble() - 0.5) * 100;
      final endY = startY + (random.nextDouble() - 0.5) * 100;
      
      final path = Path();
      path.moveTo(startX, startY);
      
      // 创建电弧效果
      for (int j = 0; j < 3; j++) {
        final midX = startX + (endX - startX) * (j + 1) / 4;
        final midY = startY + (endY - startY) * (j + 1) / 4 + 
                     (random.nextDouble() - 0.5) * 20;
        path.lineTo(midX, midY);
      }
      
      path.lineTo(endX, endY);
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
