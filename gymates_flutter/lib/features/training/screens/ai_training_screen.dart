import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../core/theme/gymates_theme.dart';
import '../../core/animations/gymates_animations.dart';

/// 🤖 AI Training Page - Futuristic Workout Experience
/// 
/// Features:
/// - Dynamic gradient background with flowing colors
/// - Animated energy rings with breathing effects
/// - Voice waveform animations
/// - AI generation cards with smooth transitions
/// - Platform-specific visual effects

class AITrainingScreen extends StatefulWidget {
  const AITrainingScreen({super.key});

  @override
  State<AITrainingScreen> createState() => _AITrainingScreenState();
}

class _AITrainingScreenState extends State<AITrainingScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _energyRingController;
  late AnimationController _waveformController;
  late AnimationController _cardController;
  late AnimationController _breathingController;
  
  late Animation<double> _gradientAnimation;
  late Animation<double> _energyRingAnimation;
  late Animation<double> _waveformAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _breathingAnimation;

  bool _isListening = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Gradient animation controller
    _gradientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    // Energy ring animation controller
    _energyRingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Waveform animation controller
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Card animation controller
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Breathing animation controller
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );

    // Gradient animation
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    // Energy ring animation
    _energyRingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _energyRingController,
      curve: Curves.easeInOutCubic,
    ));

    // Waveform animation
    _waveformAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveformController,
      curve: Curves.easeInOut,
    ));

    // Card animation
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
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
    // Start gradient animation
    _gradientController.repeat();
    
    // Start energy ring animation
    _energyRingController.forward();
    
    // Start breathing animation
    _breathingController.repeat(reverse: true);
    
    // Start card animation with delay
    await Future.delayed(const Duration(milliseconds: 500));
    _cardController.forward();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _energyRingController.dispose();
    _waveformController.dispose();
    _cardController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic gradient background
          _buildGradientBackground(),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  const SizedBox(height: 40),
                  
                  // Energy ring center
                  _buildEnergyRingCenter(),
                  
                  const SizedBox(height: 40),
                  
                  // Voice input section
                  _buildVoiceInputSection(),
                  
                  const SizedBox(height: 40),
                  
                  // AI generated content
                  _buildAIGeneratedContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
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
              const SizedBox(height: 8),
              Text(
                'Your personal AI trainer',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        // Settings button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // Open settings
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
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

  Widget _buildEnergyRingCenter() {
    return Center(
      child: AnimatedBuilder(
        animation: _breathingAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _breathingAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer energy ring
                _buildEnergyRing(200, 0.8, _energyRingAnimation.value),
                
                // Middle energy ring
                _buildEnergyRing(150, 0.6, _energyRingAnimation.value * 0.7),
                
                // Inner energy ring
                _buildEnergyRing(100, 0.4, _energyRingAnimation.value * 0.5),
                
                // Center content
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
          // Background ring
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 4,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          // Animated progress ring
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
        color: Colors.white.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
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
        const SizedBox(height: 24),
        
        // Voice input button
        GestureDetector(
          onTap: _toggleListening,
          child: AnimatedBuilder(
            animation: _waveformAnimation,
            builder: (context, child) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening 
                      ? Colors.white.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
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
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Voice waveform visualization
        if (_isListening) _buildVoiceWaveform(),
        
        const SizedBox(height: 24),
        
        // Quick suggestions
        _buildQuickSuggestions(),
      ],
    );
  }

  Widget _buildVoiceWaveform() {
    return AnimatedBuilder(
      animation: _waveformAnimation,
      builder: (context, child) {
        return Container(
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
      spacing: 12,
      runSpacing: 12,
      children: suggestions.map((suggestion) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _generateWorkout(suggestion);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
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
                const SizedBox(height: 16),
                
                // Workout card
                _buildWorkoutCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
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
          const SizedBox(height: 16),
          
          // Workout steps
          ...List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
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
                  const SizedBox(width: 12),
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
          
          const SizedBox(height: 20),
          
          // Start button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              // Start workout
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Start Workout',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
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
    
    // Simulate AI generation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isGenerating = false;
      });
      _cardController.forward();
    });
    
    HapticFeedback.lightImpact();
  }
}

/// 🎵 Voice Waveform Painter
class VoiceWaveformPainter extends CustomPainter {
  final double animationValue;
  
  VoiceWaveformPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
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
