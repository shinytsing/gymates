import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/3d_components/index.dart';
import '../../core/animations/cartoon_3d_animations.dart' as cartoon_animations;
import '../../core/theme/cartoon_3d_characters.dart';
import '../../widgets/avatars/fitness_3d_avatar.dart';
import '../../routes/app_routes.dart';

/// 🎯 Apple Fitness+ Style Onboarding Page (3D)
/// 
/// Design Features:
/// - 3D page carousel
/// - 3D avatars with different actions
/// - Smooth page transitions
/// - Apple Fitness+ minimalist style
class OnboardingPage3D extends StatefulWidget {
  const OnboardingPage3D({super.key});

  @override
  State<OnboardingPage3D> createState() => _OnboardingPage3DState();
}

class _OnboardingPage3DState extends State<OnboardingPage3D>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  final int _totalPages = 3;

  final List<OnboardingData3D> _onboardingData = [
    OnboardingData3D(
      title: '找到你的健身搭子',
      subtitle: '与志同道合的朋友一起训练，让健身更有趣',
      action: FitnessAction.running,
      gradient: AppleFitnessTheme.primaryGradient,
    ),
    OnboardingData3D(
      title: 'AI 智能训练计划',
      subtitle: '根据你的目标制定个性化训练方案',
      action: FitnessAction.weightlifting,
      gradient: AppleFitnessTheme.purpleGradient,
    ),
    OnboardingData3D(
      title: '社区分享互动',
      subtitle: '分享你的健身成果，获得鼓励和支持',
      action: FitnessAction.celebrating,
      gradient: AppleFitnessTheme.greenGradient,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previousPage() {
    HapticFeedback.lightImpact();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage == _totalPages - 1) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    _completeOnboarding();
  }

  void _completeOnboarding() {
    AppRoutes.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button3D(
                    text: '跳过',
                    onPressed: _skipOnboarding,
                    type: Button3DType.outline,
                    size: Button3DSize.small,
                  ),
                ],
              ),
            ),
            
            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index], index);
                },
              ),
            ),
            
            // Page Indicator
            Padding(
              padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingXS),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppleFitnessTheme.primaryBlue
                          : AppleFitnessTheme.textQuaternary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom Buttons
            Padding(
              padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: Button3D(
                        text: '上一页',
                        onPressed: _previousPage,
                        type: Button3DType.outline,
                        size: Button3DSize.medium,
                      ),
                    ),
                  if (_currentPage > 0) SizedBox(width: AppleFitnessTheme.spacingM),
                  Expanded(
                    child: Button3D(
                      text: _currentPage == _totalPages - 1 ? '开始使用' : '下一页',
                      onPressed: _nextPage,
                      type: Button3DType.primary,
                      size: Button3DSize.medium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData3D data, int index) {
    return Padding(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingXXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 3D Avatar
          cartoon_animations.BounceInAnimation(
            delay: Duration(milliseconds: 100 + index * 100),
            child: Card3D(
              borderRadius: BorderRadius.circular(100),
              gradient: data.gradient,
              padding: EdgeInsets.all(AppleFitnessTheme.spacingXL),
              child: Fitness3DAvatar(
                size: 150,
                angle: AvatarAngle.front,
                action: data.action,
              ),
            ),
          ),
          
          SizedBox(height: AppleFitnessTheme.spacingXXL),
          
          // Title
          cartoon_animations.SlideInAnimation(
            direction: cartoon_animations.SlideDirection.fromBottom,
            delay: Duration(milliseconds: 200 + index * 100),
            child: Text(
              data.title,
              style: AppleFitnessTheme.titleLarge.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          SizedBox(height: AppleFitnessTheme.spacingL),
          
          // Subtitle
          cartoon_animations.SlideInAnimation(
            direction: cartoon_animations.SlideDirection.fromBottom,
            delay: Duration(milliseconds: 300 + index * 100),
            child: Text(
              data.subtitle,
              style: AppleFitnessTheme.bodyLarge.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// 引导页面数据模型
class OnboardingData3D {
  final String title;
  final String subtitle;
  final FitnessAction action;
  final Gradient gradient;

  OnboardingData3D({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.gradient,
  });
}

