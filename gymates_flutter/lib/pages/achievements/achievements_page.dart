import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../theme/gymates_theme.dart';
import '../../animations/gymates_animations.dart';
import '../../shared/widgets/enhanced_components.dart';

/// 🏆 成就系统 AchievementsPage - 3D 翻转 + 发光边框 + 进度光带
/// 
/// 严格按照 Figma 设计实现：
/// - 成就卡片：3D 翻转 + 发光边框 + 进度光带
/// - 解锁动画：徽章漂浮 → 光线爆发 → 缓缓下落入槽
/// - 点击播放：粒子环绕 + 背景音乐淡入
/// - 动态打卡成功效果：
///   - 按下"打卡"按钮 → 能量环聚合 → 爆发成闪光特效
///   - 弹出「今日打卡成功」提示，徽章自动飘入收藏墙
///   - 触觉反馈 + 音效提示（短促振动）

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _unlockController;
  late AnimationController _particleController;
  late AnimationController _checkInController;
  late AnimationController _flipController;
  
  late Animation<double> _cardAnimation;
  late Animation<double> _unlockAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _checkInAnimation;
  late Animation<double> _flipAnimation;

  bool _isCheckingIn = false;
  bool _showSuccessAnimation = false;
  int _selectedAchievementIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // 卡片动画控制器
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 解锁动画控制器
    _unlockController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // 粒子动画控制器
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // 打卡动画控制器
    _checkInController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // 翻转动画控制器
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 卡片动画
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 解锁动画
    _unlockAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _unlockController,
      curve: Curves.easeOutCubic,
    ));

    // 粒子动画
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));

    // 打卡动画
    _checkInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkInController,
      curve: Curves.easeOutCubic,
    ));

    // 翻转动画
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutCubic,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _unlockController.dispose();
    _particleController.dispose();
    _checkInController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // 主内容
            SingleChildScrollView(
              padding: const EdgeInsets.all(GymatesTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头部
                  _buildHeader(),
                  
                  const SizedBox(height: GymatesTheme.spacing24),
                  
                  // 今日打卡区域
                  _buildTodayCheckIn(),
                  
                  const SizedBox(height: GymatesTheme.spacing24),
                  
                  // 成就网格
                  _buildAchievementsGrid(),
                  
                  const SizedBox(height: GymatesTheme.spacing24),
                  
                  // 进度统计
                  _buildProgressStats(),
                ],
              ),
            ),
            
            // 成功动画覆盖层
            if (_showSuccessAnimation) _buildSuccessOverlay(),
          ],
        ),
      ),
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
                'Achievements',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: GymatesTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: GymatesTheme.spacing4),
              Text(
                'Track your fitness journey',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GymatesTheme.lightTextSecondary,
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
              color: GymatesTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(GymatesTheme.radius12),
            ),
            child: const Icon(
              Icons.settings,
              color: GymatesTheme.primaryColor,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayCheckIn() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _cardAnimation.value)),
          child: Opacity(
            opacity: _cardAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(GymatesTheme.spacing24),
              decoration: BoxDecoration(
                gradient: GymatesTheme.primaryGradient,
                borderRadius: BorderRadius.circular(GymatesTheme.radius16),
                boxShadow: GymatesTheme.platformShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Check-in',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: GymatesTheme.spacing8),
                            Text(
                              'Keep your streak alive!',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 打卡状态指示器
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GymatesTheme.spacing20),
                  // 打卡按钮（能量环聚合 + 爆发成闪光特效）
                  _buildCheckInButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckInButton() {
    return GestureDetector(
      onTap: _handleCheckIn,
      child: AnimatedBuilder(
        animation: _checkInAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: GymatesTheme.spacing16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(GymatesTheme.radius12),
              boxShadow: [
                BoxShadow(
                  color: GymatesTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20 * _checkInAnimation.value,
                  spreadRadius: 5 * _checkInAnimation.value,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isCheckingIn) ...[
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
                  _isCheckingIn ? 'Checking in...' : 'Check In Today',
                  style: TextStyle(
                    color: GymatesTheme.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Achievements',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: GymatesTheme.spacing16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: GymatesTheme.spacing16,
            mainAxisSpacing: GymatesTheme.spacing16,
            childAspectRatio: 1.0,
          ),
          itemCount: 8, // Mock data
          itemBuilder: (context, index) {
            return _buildAchievementCard(index);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementCard(int index) {
    final isUnlocked = index < 5; // Mock unlocked achievements
    final isSelected = _selectedAchievementIndex == index;
    
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        final delay = index * 0.1;
        final animationValue = (_cardAnimation.value - delay).clamp(0.0, 1.0);
        
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _selectAchievement(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(GymatesTheme.spacing16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(GymatesTheme.radius16),
                  boxShadow: isSelected 
                      ? GymatesTheme.glowShadow
                      : GymatesTheme.softShadow,
                  border: isSelected 
                      ? Border.all(
                          color: GymatesTheme.primaryColor,
                          width: 2,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 成就图标（3D 翻转 + 发光边框）
                    _buildAchievementIcon(index, isUnlocked),
                    
                    const SizedBox(height: GymatesTheme.spacing12),
                    
                    // 成就标题
                    Text(
                      'Achievement ${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: GymatesTheme.spacing4),
                    
                    // 进度光带
                    _buildProgressBar(index, isUnlocked),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementIcon(int index, bool isUnlocked) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_flipAnimation.value * math.pi),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isUnlocked 
                  ? GymatesTheme.primaryGradient
                  : LinearGradient(
                      colors: [
                        Colors.grey.withOpacity(0.3),
                        Colors.grey.withOpacity(0.1),
                      ],
                    ),
              boxShadow: isUnlocked 
                  ? GymatesTheme.glowShadow
                  : null,
            ),
            child: Icon(
              isUnlocked ? Icons.emoji_events : Icons.lock,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(int index, bool isUnlocked) {
    final progress = isUnlocked ? 1.0 : (index * 0.2).clamp(0.0, 1.0);
    
    return Container(
      width: double.infinity,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.grey.withOpacity(0.2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: GymatesTheme.primaryGradient,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStats() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _cardAnimation.value)),
          child: Opacity(
            opacity: _cardAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(GymatesTheme.spacing20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GymatesTheme.radius16),
                boxShadow: GymatesTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: GymatesTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: GymatesTheme.spacing16),
                  
                  // 统计项目
                  _buildStatItem('Total Achievements', '8', '12'),
                  _buildStatItem('Current Streak', '15', 'days'),
                  _buildStatItem('Completion Rate', '67', '%'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String title, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GymatesTheme.spacing12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: GymatesTheme.lightTextSecondary,
              ),
            ),
          ),
          Text(
            '$value $unit',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: GymatesTheme.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: AnimatedBuilder(
          animation: _unlockAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _unlockAnimation.value,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(GymatesTheme.spacing24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(GymatesTheme.radius16),
                  boxShadow: GymatesTheme.platformShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 成功图标
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: GymatesTheme.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    
                    const SizedBox(height: GymatesTheme.spacing16),
                    
                    // 成功文本
                    Text(
                      'Check-in Successful!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: GymatesTheme.spacing8),
                    
                    Text(
                      'Your streak continues!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: GymatesTheme.lightTextSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: GymatesTheme.spacing20),
                    
                    // 关闭按钮
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showSuccessAnimation = false;
                        });
                        _unlockController.reset();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: GymatesTheme.spacing12,
                        ),
                        decoration: BoxDecoration(
                          gradient: GymatesTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(GymatesTheme.radius12),
                        ),
                        child: const Text(
                          'Continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectAchievement(int index) {
    setState(() {
      _selectedAchievementIndex = index;
    });
    
    // 触发翻转动画
    _flipController.forward().then((_) {
      _flipController.reverse();
    });
    
    // 触发粒子环绕动画
    _particleController.forward().then((_) {
      _particleController.reset();
    });
  }

  void _handleCheckIn() async {
    setState(() {
      _isCheckingIn = true;
    });
    
    // 触觉反馈
    HapticFeedback.mediumImpact();
    
    // 能量环聚合动画
    _checkInController.forward();
    
    // 模拟打卡过程
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isCheckingIn = false;
      _showSuccessAnimation = true;
    });
    
    // 触发解锁动画
    _unlockController.forward();
    
    // 触觉反馈 + 音效提示
    HapticFeedback.heavyImpact();
  }
}
