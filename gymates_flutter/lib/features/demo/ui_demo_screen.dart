import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/enhanced_theme.dart';
import '../../core/animations/page_animations.dart';
import '../../shared/widgets/enhanced_components.dart';
import '../../shared/widgets/enhanced_navigation.dart';
import '../../core/utils/responsive.dart';

/// Demo screen showcasing all enhanced UI components and animations
class UIDemoScreen extends StatefulWidget {
  const UIDemoScreen({super.key});

  @override
  State<UIDemoScreen> createState() => _UIDemoScreenState();
}

class _UIDemoScreenState extends State<UIDemoScreen>
    with TickerProviderStateMixin {
  late AnimationController _demoController;
  late Animation<double> _demoAnimation;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _demoController = AnimationController(
      duration: AppDurations.slow,
      vsync: this,
    );
    _demoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _demoController,
      curve: AppCurves.easeOut,
    ));
    _demoController.forward();
  }

  @override
  void dispose() {
    _demoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: EnhancedAppBar(
        title: 'UI组件演示',
        actions: [
          AnimatedScaleContainer(
            scale: 0.9,
            child: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _showInfoDialog();
              },
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _demoAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _demoAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSizes.spacingL),
                  _buildTabSelector(),
                  const SizedBox(height: AppSizes.spacingL),
                  _buildContent(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return FrostedGlassContainer(
      padding: const EdgeInsets.all(AppSizes.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gymates UI 组件库',
            style: AppTextStyles.headlineLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            '展示所有增强的UI组件、动画效果和交互设计',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            children: [
              _buildFeatureChip('Material 3', AppColors.primary),
              const SizedBox(width: AppSizes.spacingS),
              _buildFeatureChip('流畅动画', AppColors.secondary),
              const SizedBox(width: AppSizes.spacingS),
              _buildFeatureChip('响应式设计', AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingS,
        vertical: AppSizes.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return EnhancedTabBar(
      tabs: const ['组件', '动画', '主题', '响应式'],
      controller: TabController(length: 4, vsync: this, initialIndex: _selectedTab),
      onTap: (index) {
        setState(() {
          _selectedTab = index;
        });
      },
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildComponentsDemo();
      case 1:
        return _buildAnimationsDemo();
      case 2:
        return _buildThemeDemo();
      case 3:
        return _buildResponsiveDemo();
      default:
        return _buildComponentsDemo();
    }
  }

  Widget _buildComponentsDemo() {
    return StaggeredAnimation(
      children: [
        _buildSectionTitle('按钮组件'),
        _buildButtonDemo(),
        const SizedBox(height: AppSizes.spacingL),
        _buildSectionTitle('输入框组件'),
        _buildTextFieldDemo(),
        const SizedBox(height: AppSizes.spacingL),
        _buildSectionTitle('卡片组件'),
        _buildCardDemo(),
        const SizedBox(height: AppSizes.spacingL),
        _buildSectionTitle('导航组件'),
        _buildNavigationDemo(),
      ],
    );
  }

  Widget _buildAnimationsDemo() {
    return StaggeredAnimation(
      children: [
        _buildSectionTitle('页面转场动画'),
        _buildPageTransitionDemo(),
        const SizedBox(height: AppSizes.spacingL),
        _buildSectionTitle('交互动画'),
        _buildInteractionDemo(),
        const SizedBox(height: AppSizes.spacingL),
        _buildSectionTitle('加载动画'),
        _buildLoadingDemo(),
      ],
    );
  }

  Widget _buildThemeDemo() {
    return StaggeredAnimation(
      children: [
        _buildSectionTitle('颜色系统'),
        _buildColorDemo(),
        const SizedBox(height: AppSizes.spacingL),
        _buildSectionTitle('字体系统'),
        _buildTypographyDemo(),
        const SizedBox(height: AppSizes.spacingL),
        _buildSectionTitle('阴影系统'),
        _buildShadowDemo(),
      ],
    );
  }

  Widget _buildResponsiveDemo() {
    return StaggeredAnimation(
      children: [
        _buildSectionTitle('响应式布局'),
        _buildResponsiveLayoutDemo(),
        const SizedBox(height: AppSizes.spacingL),
        _buildSectionTitle('屏幕适配'),
        _buildScreenAdaptationDemo(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildButtonDemo() {
    return EnhancedCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: EnhancedButton(
                  text: '主要按钮',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('主要按钮被点击')),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: EnhancedButton(
                  text: '次要按钮',
                  isSecondary: true,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            children: [
              Expanded(
                child: EnhancedButton(
                  text: '轮廓按钮',
                  isOutlined: true,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                  },
                ),
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: EnhancedButton(
                  text: '带图标',
                  icon: Icons.favorite,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          EnhancedButton(
            text: '加载状态',
            isLoading: true,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldDemo() {
    return EnhancedCard(
      child: Column(
        children: [
          const EnhancedTextField(
            label: '邮箱地址',
            hintText: '请输入您的邮箱',
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: AppSizes.spacingM),
          const EnhancedTextField(
            label: '密码',
            hintText: '请输入密码',
            prefixIcon: Icons.lock_outlined,
            obscureText: true,
          ),
          const SizedBox(height: AppSizes.spacingM),
          const EnhancedTextField(
            label: '带错误提示',
            hintText: '输入错误内容',
            errorText: '这是一个错误提示',
            prefixIcon: Icons.error_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildCardDemo() {
    return Column(
      children: [
        EnhancedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '普通卡片',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                '这是一个普通的卡片组件，具有圆角、阴影和点击效果。',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacingM),
        FrostedGlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '毛玻璃卡片',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                '这是一个毛玻璃效果的卡片，具有背景模糊和半透明效果。',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationDemo() {
    return EnhancedCard(
      child: Column(
        children: [
          Text(
            '导航组件演示',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.fitness_center, '训练', AppColors.primary),
              _buildNavItem(Icons.people, '社区', AppColors.secondary),
              _buildNavItem(Icons.group, '搭子', AppColors.success),
              _buildNavItem(Icons.message, '消息', AppColors.warning),
              _buildNavItem(Icons.person, '我的', AppColors.info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, Color color) {
    return AnimatedScaleContainer(
      scale: 0.9,
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.spacingS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppSizes.iconM,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXS),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageTransitionDemo() {
    return EnhancedCard(
      child: Column(
        children: [
          Text(
            '页面转场动画',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSizes.spacingM),
          Wrap(
            spacing: AppSizes.spacingS,
            runSpacing: AppSizes.spacingS,
            children: [
              _buildAnimationButton('滑动进入', () {
                // Demo slide animation
              }),
              _buildAnimationButton('缩放进入', () {
                // Demo scale animation
              }),
              _buildAnimationButton('淡入效果', () {
                // Demo fade animation
              }),
              _buildAnimationButton('弹性效果', () {
                // Demo bounce animation
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionDemo() {
    return EnhancedCard(
      child: Column(
        children: [
          Text(
            '交互动画',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            children: [
              Expanded(
                child: PulseAnimation(
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.spacingM),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: BounceAnimation(
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.spacingM),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDemo() {
    return EnhancedCard(
      child: Column(
        children: [
          Text(
            '加载动画',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const LoadingAnimation(
                size: 32,
                color: AppColors.primary,
              ),
              const LoadingAnimation(
                size: 32,
                color: AppColors.secondary,
              ),
              const LoadingAnimation(
                size: 32,
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationButton(String text, VoidCallback onPressed) {
    return AnimatedScaleContainer(
      scale: 0.95,
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildColorDemo() {
    return EnhancedCard(
      child: Column(
        children: [
          Text(
            '颜色系统',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSizes.spacingM),
          Wrap(
            spacing: AppSizes.spacingS,
            runSpacing: AppSizes.spacingS,
            children: [
              _buildColorSwatch('主色', AppColors.primary),
              _buildColorSwatch('次要色', AppColors.secondary),
              _buildColorSwatch('成功色', AppColors.success),
              _buildColorSwatch('警告色', AppColors.warning),
              _buildColorSwatch('错误色', AppColors.error),
              _buildColorSwatch('信息色', AppColors.info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            boxShadow: AppShadows.medium,
          ),
        ),
        const SizedBox(height: AppSizes.spacingXS),
        Text(
          name,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTypographyDemo() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '字体系统',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            'Display Large',
            style: AppTextStyles.displayLarge,
          ),
          Text(
            'Headline Medium',
            style: AppTextStyles.headlineMedium,
          ),
          Text(
            'Title Large',
            style: AppTextStyles.titleLarge,
          ),
          Text(
            'Body Large',
            style: AppTextStyles.bodyLarge,
          ),
          Text(
            'Label Medium',
            style: AppTextStyles.labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildShadowDemo() {
    return EnhancedCard(
      child: Column(
        children: [
          Text(
            '阴影系统',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildShadowExample('小阴影', AppShadows.small),
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: _buildShadowExample('中阴影', AppShadows.medium),
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: _buildShadowExample('大阴影', AppShadows.large),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShadowExample(String name, List<BoxShadow> shadow) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            boxShadow: shadow,
          ),
        ),
        const SizedBox(height: AppSizes.spacingXS),
        Text(
          name,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildResponsiveLayoutDemo() {
    return EnhancedCard(
      child: Column(
        children: [
          Text(
            '响应式布局',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSizes.spacingM),
          ResponsiveGridView(
            children: List.generate(6, (index) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Center(
                  child: Text(
                    'Item ${index + 1}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenAdaptationDemo() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '屏幕适配信息',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSizes.spacingM),
          ResponsiveBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '屏幕尺寸: ${constraints.maxWidth.toInt()} x ${constraints.maxHeight.toInt()}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    '设备类型: ${ResponsiveHelper.isMobile(context) ? '手机' : ResponsiveHelper.isTablet(context) ? '平板' : '桌面'}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    '网格列数: ${ResponsiveHelper.getGridColumns(context)}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于UI组件库'),
        content: const Text(
          '这是Gymates应用的增强UI组件库，包含：\n\n'
          '• Material 3设计系统\n'
          '• 流畅的动画效果\n'
          '• 响应式布局\n'
          '• 毛玻璃效果\n'
          '• 触觉反馈\n'
          '• 无障碍支持',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
