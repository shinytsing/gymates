import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../core/theme/gymates_theme.dart';
import '../../core/animations/gymates_animations.dart';
import '../../shared/widgets/enhanced_components.dart';

/// 🏋️‍♀️ Training Page - Dynamic Workout Experience
/// 
/// Features:
/// - Animated workout cards with smooth transitions
/// - Progress rings with energy animations
/// - Achievement badges with 3D effects
/// - Platform-specific visual styling
/// - Interactive elements with haptic feedback

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _progressController;
  late AnimationController _breathingController;
  
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Card animation controller
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Breathing animation controller
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );

    // Card animations
    _cardSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 0.75, // 75% progress
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    // Breathing animation
    _breathingAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() async {
    // Start progress animation
    _progressController.forward();
    
    // Start breathing animation
    _breathingController.repeat(reverse: true);
    
    // Start card animations with delay
    await Future.delayed(const Duration(milliseconds: 200));
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _progressController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: 24),
              
              // Today's Progress Card
              _buildProgressCard(),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              _buildQuickActions(),
              
              const SizedBox(height: 24),
              
              // Workout Plans
              _buildWorkoutPlans(),
              
              const SizedBox(height: 24),
              
              // Achievements
              _buildAchievements(),
            ],
          ),
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
                'Good Morning!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: GymatesTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ready to crush your goals?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: GymatesTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        // Profile avatar with animation
        AnimatedBuilder(
          animation: _breathingAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _breathingAnimation.value,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: GymatesTheme.primaryGradient,
                  boxShadow: GymatesTheme.glowShadow,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlideAnimation.value),
          child: Opacity(
            opacity: _cardFadeAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: GymatesTheme.primaryGradient,
                borderRadius: BorderRadius.circular(GymatesTheme.cardRadius),
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
                              'Today\'s Progress',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You\'re doing great!',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Animated progress ring
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              children: [
                                // Background ring
                                CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: 6,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                                // Progress ring
                                CircularProgressIndicator(
                                  value: _progressAnimation.value,
                                  strokeWidth: 6,
                                  backgroundColor: Colors.transparent,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                                // Center text
                                Center(
                                  child: Text(
                                    '${(_progressAnimation.value * 100).round()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Start workout button
                  _buildStartWorkoutButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartWorkoutButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        // Navigate to workout
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GymatesTheme.buttonRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_arrow,
              color: GymatesTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Start Workout',
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

  Widget _buildQuickActions() {
    final actions = [
      QuickAction(
        icon: Icons.timer,
        title: 'Quick Workout',
        subtitle: '15 min',
        color: const Color(0xFF10B981),
      ),
      QuickAction(
        icon: Icons.fitness_center,
        title: 'Strength',
        subtitle: '45 min',
        color: const Color(0xFFF59E0B),
      ),
      QuickAction(
        icon: Icons.directions_run,
        title: 'Cardio',
        subtitle: '30 min',
        color: const Color(0xFFEF4444),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < actions.length - 1 ? 16 : 0,
                ),
                child: _buildQuickActionCard(actions[index], index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(QuickAction action, int index) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlideAnimation.value * (index + 1) * 0.3),
          child: Opacity(
            opacity: _cardFadeAnimation.value,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Handle action
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(GymatesTheme.cardRadius),
                  boxShadow: GymatesTheme.softShadow,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: action.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action.icon,
                        color: action.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      action.subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: GymatesTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Plans',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildWorkoutPlanCard(index),
          );
        }),
      ],
    );
  }

  Widget _buildWorkoutPlanCard(int index) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlideAnimation.value * (index + 1) * 0.2),
          child: Opacity(
            opacity: _cardFadeAnimation.value,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Navigate to workout plan
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(GymatesTheme.cardRadius),
                  boxShadow: GymatesTheme.softShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: GymatesTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Body Workout',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: GymatesTheme.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '45 minutes • Intermediate',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: GymatesTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: GymatesTheme.lightTextSecondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Achievements',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < 4 ? 16 : 0,
                ),
                child: _buildAchievementBadge(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(int index) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlideAnimation.value * (index + 1) * 0.1),
          child: Opacity(
            opacity: _cardFadeAnimation.value,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Show achievement details
              },
              child: Container(
                width: 80,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: GymatesTheme.energyGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: GymatesTheme.glowShadow,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Week ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🎯 Quick Action Model
class QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}