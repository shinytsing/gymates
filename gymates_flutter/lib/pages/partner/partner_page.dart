import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../shared/models/mock_data.dart';

class PartnerPage extends StatefulWidget {
  const PartnerPage({super.key});

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  String? _swipeDirection;
  late AnimationController _cardAnimationController;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _swipeLeft() {
    setState(() {
      _swipeDirection = 'left';
    });
    _cardAnimationController.forward().then((_) {
      // 处理左滑逻辑
      setState(() {
        _swipeDirection = null;
      });
      _cardAnimationController.reset();
    });
  }

  void _swipeRight() {
    setState(() {
      _swipeDirection = 'right';
    });
    _cardAnimationController.forward().then((_) {
      // 处理右滑逻辑
      setState(() {
        _swipeDirection = null;
      });
      _cardAnimationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isIOS),
            _buildTabNavigation(),
            Expanded(
              child: _buildMatesContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isIOS) {
    return Container(
      padding: EdgeInsets.all(GymatesTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: GymatesTheme.getCardShadow(false),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '搭子',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: GymatesTheme.lightTextPrimary,
                  height: 1.2,
                  letterSpacing: isIOS ? -0.5 : 0.0,
                ),
              ),
              SizedBox(height: GymatesTheme.spacing4),
              Text(
                '滑动卡片寻找你的健身伙伴',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: GymatesTheme.lightTextSecondary,
                  height: 1.4,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
          _buildHeaderButton(),
        ],
      ),
    );
  }

  Widget _buildHeaderButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showRecommendationSettings();
      },
      child: Container(
        padding: EdgeInsets.all(GymatesTheme.spacing12),
        decoration: BoxDecoration(
          color: GymatesTheme.lightBackground,
          borderRadius: BorderRadius.circular(GymatesTheme.radius12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.settings,
          size: 20,
          color: GymatesTheme.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GymatesTheme.spacing16,
        vertical: GymatesTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton(0, '推荐'),
          SizedBox(width: GymatesTheme.spacing16),
          _buildTabButton(1, '健身房见'),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: GymatesTheme.spacing16,
          vertical: GymatesTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? GymatesTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: GymatesTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : GymatesTheme.lightTextSecondary,
            height: 1.2,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMatesContent() {
    return Container(
      padding: EdgeInsets.all(GymatesTheme.spacing16),
      child: Column(
        children: [
          Expanded(
            child: _buildSwipeCard(MockData.mates[0], true),
          ),
          SizedBox(height: GymatesTheme.spacing24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSwipeCard(MateData mate, bool isIOS) {
    return SizedBox(
      height: 500,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _swipeDirection = details.delta.dx > 0 ? 'right' : 'left';
          });
        },
        onPanEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond.dx;
          final distance = details.velocity.pixelsPerSecond.dx.abs();
          
          if (distance > 500 || velocity.abs() > 1000) {
            if (velocity > 0) {
              _swipeRight();
            } else {
              _swipeLeft();
            }
          } else {
            setState(() {
              _swipeDirection = null;
            });
          }
        },
        child: AnimatedBuilder(
          animation: _cardAnimationController,
          builder: (context, child) {
            return Transform.translate(
              offset: _swipeDirection == 'left' 
                ? Offset(-300 * _cardAnimationController.value, 0)
                : _swipeDirection == 'right'
                ? Offset(300 * _cardAnimationController.value, 0)
                : Offset.zero,
              child: Transform.rotate(
                angle: _swipeDirection == 'left' 
                  ? -0.1 * _cardAnimationController.value
                  : _swipeDirection == 'right'
                  ? 0.1 * _cardAnimationController.value
                  : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
                    child: Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          child: Image.network(
                            mate.avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: GymatesTheme.primaryGradient,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                                stops: const [0.0, 0.3, 1.0],
                              ),
                            ),
                          ),
                        ),
                        
                        // Content
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: EdgeInsets.all(GymatesTheme.spacing24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name and Match Rate
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${mate.name}, ${mate.age}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.2,
                                        letterSpacing: isIOS ? -0.5 : 0.0,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: GymatesTheme.spacing12,
                                        vertical: GymatesTheme.spacing4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '${mate.matchRate}%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          height: 1.2,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: GymatesTheme.spacing8),
                                
                                // Preferences
                                Wrap(
                                  spacing: GymatesTheme.spacing8,
                                  runSpacing: GymatesTheme.spacing4,
                                  children: mate.preferences.map((pref) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: GymatesTheme.spacing12,
                                        vertical: GymatesTheme.spacing4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        pref,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          height: 1.2,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                
                                SizedBox(height: GymatesTheme.spacing12),
                                
                                // Bio
                                Text(
                                  mate.bio,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.4,
                                    letterSpacing: 0.0,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // More button
                        Positioned(
                          top: GymatesTheme.spacing16,
                          right: GymatesTheme.spacing16,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _showMateDetails(mate);
                            },
                            child: Container(
                              padding: EdgeInsets.all(GymatesTheme.spacing8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.more_horiz,
                                size: 16,
                                color: GymatesTheme.lightTextSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: GymatesTheme.spacing32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.close,
            color: Colors.red,
            onTap: _swipeLeft,
            size: 70,
          ),
          SizedBox(width: GymatesTheme.spacing32),
          _buildActionButton(
            icon: Icons.favorite,
            color: Colors.pink,
            onTap: _swipeRight,
            size: 70,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 60,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: size * 0.4,
          color: color,
        ),
      ),
    );
  }

  void _showRecommendationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(GymatesTheme.radius16),
            topRight: Radius.circular(GymatesTheme.radius16),
          ),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: EdgeInsets.only(top: GymatesTheme.spacing12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 标题
            Padding(
              padding: EdgeInsets.all(GymatesTheme.spacing20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '推荐设置',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: GymatesTheme.lightTextPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: GymatesTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // 设置内容
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: GymatesTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettingSection(
                      '年龄范围',
                      '18-25岁',
                      Icons.person,
                    ),
                    SizedBox(height: GymatesTheme.spacing16),
                    _buildSettingSection(
                      '距离范围',
                      '5公里内',
                      Icons.location_on,
                    ),
                    SizedBox(height: GymatesTheme.spacing16),
                    _buildSettingSection(
                      '健身目标',
                      '增肌、减脂',
                      Icons.fitness_center,
                    ),
                    SizedBox(height: GymatesTheme.spacing16),
                    _buildSettingSection(
                      '训练时间',
                      '19:00-21:00',
                      Icons.access_time,
                    ),
                    SizedBox(height: GymatesTheme.spacing16),
                    _buildSettingSection(
                      '健身经验',
                      '中级',
                      Icons.star,
                    ),
                    SizedBox(height: GymatesTheme.spacing32),
                    
                    // 保存按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // 保存设置逻辑
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GymatesTheme.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: GymatesTheme.spacing16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(GymatesTheme.radius12),
                          ),
                        ),
                        child: Text(
                          '保存设置',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  Widget _buildSettingSection(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(GymatesTheme.spacing16),
      decoration: BoxDecoration(
        color: GymatesTheme.lightBackground,
        borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: GymatesTheme.primaryColor,
            size: 20,
          ),
          SizedBox(width: GymatesTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: GymatesTheme.lightTextPrimary,
                  ),
                ),
                SizedBox(height: GymatesTheme.spacing4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: GymatesTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: GymatesTheme.lightTextSecondary,
          ),
        ],
      ),
    );
  }

  void _showMateDetails(MateData mate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(GymatesTheme.radius16),
            topRight: Radius.circular(GymatesTheme.radius16),
          ),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: EdgeInsets.only(top: GymatesTheme.spacing12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 标题
            Padding(
              padding: EdgeInsets.all(GymatesTheme.spacing20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '详细信息',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: GymatesTheme.lightTextPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: GymatesTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // 详细信息内容
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: GymatesTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头像和基本信息
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                mate.avatar,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: GymatesTheme.primaryGradient,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: GymatesTheme.spacing16),
                          Text(
                            '${mate.name}, ${mate.age}岁',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: GymatesTheme.lightTextPrimary,
                            ),
                          ),
                          SizedBox(height: GymatesTheme.spacing8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: GymatesTheme.spacing12,
                              vertical: GymatesTheme.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${mate.matchRate}% 匹配度',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: GymatesTheme.spacing24),
                    
                    // 详细信息卡片
                    _buildDetailCard('📍 距离', mate.distance, Icons.location_on),
                    SizedBox(height: GymatesTheme.spacing12),
                    _buildDetailCard('⏰ 训练时间', mate.workoutTime, Icons.access_time),
                    SizedBox(height: GymatesTheme.spacing12),
                    _buildDetailCard('🎯 健身目标', mate.goal, Icons.flag),
                    SizedBox(height: GymatesTheme.spacing12),
                    _buildDetailCard('💪 健身经验', mate.experience, Icons.star),
                    SizedBox(height: GymatesTheme.spacing12),
                    _buildDetailCard('⭐ 评分', '${mate.rating}/5.0', Icons.star_rate),
                    SizedBox(height: GymatesTheme.spacing12),
                    _buildDetailCard('🏋️ 训练次数', '${mate.workouts}次', Icons.fitness_center),
                    
                    SizedBox(height: GymatesTheme.spacing16),
                    
                    // 健身偏好
                    Text(
                      '健身偏好',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: GymatesTheme.spacing8),
                    Wrap(
                      spacing: GymatesTheme.spacing8,
                      runSpacing: GymatesTheme.spacing8,
                      children: mate.preferences.map((pref) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: GymatesTheme.spacing12,
                            vertical: GymatesTheme.spacing4,
                          ),
                          decoration: BoxDecoration(
                            color: GymatesTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: GymatesTheme.primaryColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            pref,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: GymatesTheme.primaryColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    SizedBox(height: GymatesTheme.spacing16),
                    
                    // 个人简介
                    Text(
                      '个人简介',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: GymatesTheme.spacing8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(GymatesTheme.spacing16),
                      decoration: BoxDecoration(
                        color: GymatesTheme.lightBackground,
                        borderRadius: BorderRadius.circular(GymatesTheme.radius12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        mate.bio,
                        style: TextStyle(
                          fontSize: 14,
                          color: GymatesTheme.lightTextSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: GymatesTheme.spacing24),
                    
                    // 操作按钮
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _swipeLeft();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: GymatesTheme.spacing16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(GymatesTheme.radius12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close, color: Colors.white),
                                SizedBox(width: GymatesTheme.spacing8),
                                Text(
                                  '不喜欢',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: GymatesTheme.spacing12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _swipeRight();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              padding: EdgeInsets.symmetric(vertical: GymatesTheme.spacing16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(GymatesTheme.radius12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite, color: Colors.white),
                                SizedBox(width: GymatesTheme.spacing8),
                                Text(
                                  '喜欢',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: GymatesTheme.spacing32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(GymatesTheme.spacing16),
      decoration: BoxDecoration(
        color: GymatesTheme.lightBackground,
        borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: GymatesTheme.primaryColor,
            size: 20,
          ),
          SizedBox(width: GymatesTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: GymatesTheme.lightTextSecondary,
                  ),
                ),
                SizedBox(height: GymatesTheme.spacing4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: GymatesTheme.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}