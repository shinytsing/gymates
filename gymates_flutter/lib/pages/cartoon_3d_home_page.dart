import 'package:flutter/material.dart';
import '../core/theme/cartoon_3d_theme.dart';
import '../core/theme/cartoon_3d_characters.dart';
import '../core/animations/cartoon_3d_animations.dart';
import '../shared/widgets/cartoon_3d_widgets.dart';

/// 🎨 3D卡通风格主页
/// 
/// 展示新的3D卡通设计风格,包含:
/// - 卡通角色形象
/// - 3D卡片和按钮
/// - 流畅的动画效果
/// - 丰富的视觉元素

class Cartoon3DHomePage extends StatefulWidget {
  const Cartoon3DHomePage({super.key});

  @override
  State<Cartoon3DHomePage> createState() => _Cartoon3DHomePageState();
}

class _Cartoon3DHomePageState extends State<Cartoon3DHomePage> {
  int _currentNavIndex = 0;
  final bool _showCelebration = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cartoon3DTheme.lightBg,
      body: SafeArea(
        child: AnimatedGradientBackground(
          colors: const [
            Cartoon3DTheme.lightBg,
            Cartoon3DTheme.mediumBg,
            Cartoon3DTheme.lightBg,
          ],
          duration: const Duration(seconds: 5),
          child: CustomScrollView(
            slivers: [
              // 顶部栏
              _buildAppBar(),
              
              // 主要内容
              SliverPadding(
                padding: const EdgeInsets.all(Cartoon3DTheme.space16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 欢迎区域 + 角色
                    _buildWelcomeSection(),
                    const SizedBox(height: Cartoon3DTheme.space24),
                    
                    // 今日统计卡片
                    _buildStatsSection(),
                    const SizedBox(height: Cartoon3DTheme.space24),
                    
                    // 快速动作
                    _buildQuickActions(),
                    const SizedBox(height: Cartoon3DTheme.space24),
                    
                    // 训练计划
                    _buildTrainingPlans(),
                    const SizedBox(height: Cartoon3DTheme.space24),
                    
                    // 成就徽章
                    _buildAchievements(),
                    const SizedBox(height: Cartoon3DTheme.space24),
                    
                    // 社区动态
                    _buildCommunityFeed(),
                    const SizedBox(height: Cartoon3DTheme.space80),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // 浮动动作按钮
      floatingActionButton: Cartoon3DFAB(
        icon: Icons.add,
        onPressed: () {},
        gradient: Cartoon3DTheme.rainbow3DGradient,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // 底部导航栏
      bottomNavigationBar: Cartoon3DBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        items: const [
          Cartoon3DBottomNavItem(
            icon: Icons.home_rounded,
            label: '首页',
            gradient: Cartoon3DTheme.primary3DGradient,
          ),
          Cartoon3DBottomNavItem(
            icon: Icons.fitness_center_rounded,
            label: '训练',
            gradient: Cartoon3DTheme.purple3DGradient,
          ),
          Cartoon3DBottomNavItem(
            icon: Icons.people_rounded,
            label: '社区',
            gradient: Cartoon3DTheme.teal3DGradient,
          ),
          Cartoon3DBottomNavItem(
            icon: Icons.person_rounded,
            label: '我的',
            gradient: Cartoon3DTheme.rainbow3DGradient,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Cartoon3DTheme.glassCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Cartoon3DTheme.space20,
              vertical: Cartoon3DTheme.space16,
            ),
            child: Row(
              children: [
                // 头像
                BounceInAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: const Cartoon3DAvatar(
                    initials: 'GY',
                    size: 48,
                    gradient: Cartoon3DTheme.primary3DGradient,
                    hasGlow: true,
                  ),
                ),
                
                const SizedBox(width: Cartoon3DTheme.space12),
                
                // 问候语
                Expanded(
                  child: SlideInAnimation(
                    delay: const Duration(milliseconds: 200),
                    direction: SlideDirection.fromLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '你好! 💪',
                          style: const TextStyle(
                            color: Cartoon3DTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '准备好今天的训练了吗?',
                          style: TextStyle(
                            color: Cartoon3DTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 通知按钮
                SlideInAnimation(
                  delay: const Duration(milliseconds: 300),
                  direction: SlideDirection.fromRight,
                  child: Container(
                    padding: const EdgeInsets.all(Cartoon3DTheme.space12),
                    decoration: BoxDecoration(
                      color: Cartoon3DTheme.cardBg,
                      borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusS),
                      boxShadow: Cartoon3DTheme.cartoon3DShadow,
                    ),
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_rounded,
                          color: Cartoon3DTheme.primaryVibrant,
                          size: 24,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Cartoon3DTheme.errorOrange,
                              shape: BoxShape.circle,
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
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 400),
      child: Cartoon3DCard(
        gradient: Cartoon3DTheme.primary3DGradient,
        padding: const EdgeInsets.all(Cartoon3DTheme.space24),
        child: Row(
          children: [
            // 文字内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今日目标',
                    style: TextStyle(
                      color: Cartoon3DTheme.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Cartoon3DTheme.space8),
                  const Text(
                    '完成3组训练',
                    style: TextStyle(
                      color: Cartoon3DTheme.textLight,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Cartoon3DTheme.space12),
                  
                  // 进度条
                  const Cartoon3DProgressBar(
                    progress: 0.6,
                    height: 8,
                    backgroundColor: Colors.white24,
                  ),
                  const SizedBox(height: Cartoon3DTheme.space8),
                  
                  Text(
                    '已完成 60% 💪',
                    style: TextStyle(
                      color: Cartoon3DTheme.textLight.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: Cartoon3DTheme.space16),
            
            // 角色形象
            const PulseAnimation(
              child: Cartoon3DCharacter(
                action: FitnessAction.celebrating,
                emotion: CharacterEmotion.motivated,
                size: 120,
                animated: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SlideInAnimation(
          delay: const Duration(milliseconds: 500),
          child: const Text(
            '今日数据 📊',
            style: TextStyle(
              color: Cartoon3DTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: Cartoon3DTheme.space16),
        
        Row(
          children: [
            Expanded(
              child: BounceInAnimation(
                delay: const Duration(milliseconds: 600),
                child: const Cartoon3DStatCard(
                  title: '消耗卡路里',
                  value: '458',
                  subtitle: 'kcal',
                  icon: Icons.local_fire_department_rounded,
                  gradient: Cartoon3DTheme.primary3DGradient,
                ),
              ),
            ),
            const SizedBox(width: Cartoon3DTheme.space16),
            Expanded(
              child: BounceInAnimation(
                delay: const Duration(milliseconds: 700),
                child: const Cartoon3DStatCard(
                  title: '训练时长',
                  value: '45',
                  subtitle: '分钟',
                  icon: Icons.timer_rounded,
                  gradient: Cartoon3DTheme.purple3DGradient,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Cartoon3DTheme.space16),
        
        Row(
          children: [
            Expanded(
              child: BounceInAnimation(
                delay: const Duration(milliseconds: 800),
                child: const Cartoon3DStatCard(
                  title: '活动步数',
                  value: '8,234',
                  subtitle: '步',
                  icon: Icons.directions_walk_rounded,
                  gradient: Cartoon3DTheme.teal3DGradient,
                ),
              ),
            ),
            const SizedBox(width: Cartoon3DTheme.space16),
            Expanded(
              child: BounceInAnimation(
                delay: const Duration(milliseconds: 900),
                child: Cartoon3DStatCard(
                  title: '连续天数',
                  value: '12',
                  subtitle: '天 🔥',
                  icon: Icons.emoji_events_rounded,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Cartoon3DTheme.energyOrange,
                      Cartoon3DTheme.sunnyYellow,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SlideInAnimation(
          delay: const Duration(milliseconds: 1000),
          child: const Text(
            '快速开始 🚀',
            style: TextStyle(
              color: Cartoon3DTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: Cartoon3DTheme.space16),
        
        Wrap(
          spacing: Cartoon3DTheme.space12,
          runSpacing: Cartoon3DTheme.space12,
          children: [
            BounceInAnimation(
              delay: const Duration(milliseconds: 1100),
              child: Cartoon3DChip(
                label: '🏃 跑步',
                selected: true,
                gradient: Cartoon3DTheme.primary3DGradient,
                onTap: () {},
              ),
            ),
            BounceInAnimation(
              delay: const Duration(milliseconds: 1200),
              child: Cartoon3DChip(
                label: '💪 力量训练',
                onTap: () {},
              ),
            ),
            BounceInAnimation(
              delay: const Duration(milliseconds: 1300),
              child: Cartoon3DChip(
                label: '🧘 瑜伽',
                onTap: () {},
              ),
            ),
            BounceInAnimation(
              delay: const Duration(milliseconds: 1400),
              child: Cartoon3DChip(
                label: '🚴 骑行',
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrainingPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SlideInAnimation(
              delay: const Duration(milliseconds: 1500),
              child: const Text(
                '训练计划 📝',
                style: TextStyle(
                  color: Cartoon3DTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SlideInAnimation(
              delay: const Duration(milliseconds: 1600),
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  '查看全部',
                  style: TextStyle(
                    color: Cartoon3DTheme.primaryVibrant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Cartoon3DTheme.space16),
        
        BounceInAnimation(
          delay: const Duration(milliseconds: 1700),
          child: Cartoon3DListTile(
            title: '全身燃脂训练',
            subtitle: '30分钟 · 中等强度',
            leading: Container(
              padding: const EdgeInsets.all(Cartoon3DTheme.space12),
              decoration: BoxDecoration(
                gradient: Cartoon3DTheme.primary3DGradient,
                borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusS),
                boxShadow: Cartoon3DTheme.glowingShadow(
                  Cartoon3DTheme.primaryVibrant,
                ),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: Cartoon3DTheme.textLight,
              ),
            ),
            trailing: const Icon(
              Icons.play_circle_fill_rounded,
              color: Cartoon3DTheme.primaryVibrant,
              size: 32,
            ),
            onTap: () {},
          ),
        ),
        const SizedBox(height: Cartoon3DTheme.space12),
        
        BounceInAnimation(
          delay: const Duration(milliseconds: 1800),
          child: Cartoon3DListTile(
            title: '核心力量强化',
            subtitle: '20分钟 · 高强度',
            leading: Container(
              padding: const EdgeInsets.all(Cartoon3DTheme.space12),
              decoration: BoxDecoration(
                gradient: Cartoon3DTheme.purple3DGradient,
                borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusS),
                boxShadow: Cartoon3DTheme.glowingShadow(
                  Cartoon3DTheme.secondaryPurple,
                ),
              ),
              child: const Icon(
                Icons.accessibility_new_rounded,
                color: Cartoon3DTheme.textLight,
              ),
            ),
            trailing: const Icon(
              Icons.play_circle_fill_rounded,
              color: Cartoon3DTheme.secondaryPurple,
              size: 32,
            ),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SlideInAnimation(
          delay: const Duration(milliseconds: 1900),
          child: const Text(
            '成就徽章 🏆',
            style: TextStyle(
              color: Cartoon3DTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: Cartoon3DTheme.space16),
        
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (context, index) => 
                const SizedBox(width: Cartoon3DTheme.space12),
            itemBuilder: (context, index) {
              final gradients = [
                Cartoon3DTheme.primary3DGradient,
                Cartoon3DTheme.purple3DGradient,
                Cartoon3DTheme.teal3DGradient,
                const LinearGradient(
                  colors: [
                    Cartoon3DTheme.energyOrange,
                    Cartoon3DTheme.sunnyYellow,
                  ],
                ),
                Cartoon3DTheme.rainbow3DGradient,
              ];
              
              return BounceInAnimation(
                delay: Duration(milliseconds: 2000 + index * 100),
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: gradients[index],
                    borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusM),
                    boxShadow: Cartoon3DTheme.glowingShadow(
                      Cartoon3DTheme.primaryVibrant,
                    ),
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Cartoon3DTheme.textLight,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SlideInAnimation(
              delay: const Duration(milliseconds: 2500),
              child: const Text(
                '社区动态 👥',
                style: TextStyle(
                  color: Cartoon3DTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SlideInAnimation(
              delay: const Duration(milliseconds: 2600),
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  '查看更多',
                  style: TextStyle(
                    color: Cartoon3DTheme.primaryVibrant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Cartoon3DTheme.space16),
        
        BounceInAnimation(
          delay: const Duration(milliseconds: 2700),
          child: Cartoon3DCard(
            padding: const EdgeInsets.all(Cartoon3DTheme.space16),
            floating: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Cartoon3DAvatar(
                      initials: 'JD',
                      size: 40,
                      gradient: Cartoon3DTheme.teal3DGradient,
                    ),
                    const SizedBox(width: Cartoon3DTheme.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'John Doe',
                            style: TextStyle(
                              color: Cartoon3DTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '2小时前',
                            style: TextStyle(
                              color: Cartoon3DTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.more_horiz_rounded,
                      color: Cartoon3DTheme.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: Cartoon3DTheme.space12),
                
                const Text(
                  '今天完成了第一次5公里跑步!感觉太棒了! 🏃‍♂️💪',
                  style: TextStyle(
                    color: Cartoon3DTheme.textPrimary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: Cartoon3DTheme.space12),
                
                Row(
                  children: [
                    _buildActionButton(Icons.favorite_rounded, '128'),
                    const SizedBox(width: Cartoon3DTheme.space16),
                    _buildActionButton(Icons.chat_bubble_rounded, '23'),
                    const SizedBox(width: Cartoon3DTheme.space16),
                    _buildActionButton(Icons.share_rounded, '分享'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Cartoon3DTheme.textSecondary,
        ),
        const SizedBox(width: Cartoon3DTheme.space4),
        Text(
          label,
          style: const TextStyle(
            color: Cartoon3DTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

