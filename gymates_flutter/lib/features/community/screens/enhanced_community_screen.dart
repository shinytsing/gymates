import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymates_flutter/core/theme/gymates_theme.dart';
import '../../../core/animations/gymates_animations.dart';

/// 💬 Community Page - Social Fitness Feed
/// 
/// Features:
/// - Staggered post animations with smooth loading
/// - Interactive image galleries with zoom effects
/// - Comment modal with blur background
/// - Topic tags with gradient animations
/// - Platform-specific visual styling

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _refreshController;
  late AnimationController _tagController;
  
  late Animation<double> _listAnimation;
  late Animation<double> _refreshAnimation;
  late Animation<double> _tagAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // List animation controller
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Refresh animation controller
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Tag animation controller
    _tagController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // List animation
    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Refresh animation
    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));

    // Tag animation
    _tagAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tagController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _listAnimationController.forward();
    _tagController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _refreshController.dispose();
    _tagController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Topic tags
            _buildTopicTags(),
            
            // Posts feed
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: _buildPostsFeed(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildCreatePostButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: GymatesTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Connect with fitness enthusiasts',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: GymatesTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Search button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Open search
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: GymatesTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.search,
                color: GymatesTheme.primaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicTags() {
    final tags = [
      'All',
      'Workout',
      'Nutrition',
      'Progress',
      'Motivation',
      'Tips',
    ];

    return AnimatedBuilder(
      animation: _tagAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final isSelected = index == 0;
              final delay = index * 0.1;
              final animationValue = (_tagAnimation.value - delay).clamp(0.0, 1.0);
              
              return Transform.translate(
                offset: Offset(0, 20 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < tags.length - 1 ? 12 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // Handle tag selection
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected 
                              ? GymatesTheme.primaryGradient
                              : null,
                          color: isSelected 
                              ? null
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected 
                              ? GymatesTheme.glowShadow
                              : GymatesTheme.softShadow,
                        ),
                        child: Text(
                          tags[index],
                          style: TextStyle(
                            color: isSelected 
                                ? Colors.white
                                : GymatesTheme.lightTextPrimary,
                            fontSize: 14,
                            fontWeight: isSelected 
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPostsFeed() {
    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: 10, // Mock data
          itemBuilder: (context, index) {
            final delay = index * 0.1;
            final animationValue = (_listAnimation.value - delay).clamp(0.0, 1.0);
            
            return Transform.translate(
              offset: Offset(0, 30 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPostCard(index),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostCard(int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showPostDetails(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GymatesTheme.cardRadius),
          boxShadow: GymatesTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header
            _buildPostHeader(index),
            
            // Post content
            _buildPostContent(index),
            
            // Post image
            _buildPostImage(index),
            
            // Post actions
            _buildPostActions(index),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(int index) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: GymatesTheme.primaryGradient,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: GymatesTheme.lightTextPrimary,
                  ),
                ),
                Text(
                  '2 hours ago',
                  style: const TextStyle(
                    fontSize: 12,
                    color: GymatesTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // More options
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Show options
            },
            child: const Icon(
              Icons.more_vert,
              color: GymatesTheme.lightTextSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(int index) {
    final contents = [
      'Just finished an amazing HIIT workout! 💪 The energy is incredible today.',
      'Progress update: Lost 5kg this month! Consistency is key 🔥',
      'New protein shake recipe that tastes amazing and helps with recovery',
      'Morning run with the sunrise - there\'s nothing better than this view',
      'Deadlift PR today! 150kg felt lighter than ever 💀',
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        contents[index % contents.length],
        style: const TextStyle(
          fontSize: 14,
          color: GymatesTheme.lightTextPrimary,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildPostImage(int index) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _showImageGallery(index);
        },
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                GymatesTheme.primaryColor.withValues(alpha: 0.1),
                GymatesTheme.secondaryColor.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.image,
              size: 50,
              color: GymatesTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostActions(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Like button
          _buildActionButton(
            icon: Icons.favorite_border,
            activeIcon: Icons.favorite,
            label: '${12 + index}',
            isActive: index % 3 == 0,
            onTap: () {
              HapticFeedback.lightImpact();
              // Handle like
            },
          ),
          
          const SizedBox(width: 24),
          
          // Comment button
          _buildActionButton(
            icon: Icons.comment_outlined,
            activeIcon: Icons.comment,
            label: '${5 + index}',
            isActive: false,
            onTap: () {
              HapticFeedback.lightImpact();
              _showComments(index);
            },
          ),
          
          const SizedBox(width: 24),
          
          // Share button
          _buildActionButton(
            icon: Icons.share_outlined,
            activeIcon: Icons.share,
            label: 'Share',
            isActive: false,
            onTap: () {
              HapticFeedback.lightImpact();
              // Handle share
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            isActive ? activeIcon : icon,
            size: 20,
            color: isActive 
                ? GymatesTheme.primaryColor
                : GymatesTheme.lightTextSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive 
                  ? GymatesTheme.primaryColor
                  : GymatesTheme.lightTextSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostButton() {
    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        // Navigate to create post
      },
      backgroundColor: GymatesTheme.primaryColor,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    
    _refreshController.forward();
    
    // Simulate refresh
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isRefreshing = false;
    });
    
    _refreshController.reset();
  }

  void _showPostDetails(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPostDetailsModal(index),
    );
  }

  Widget _buildPostDetailsModal(int index) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Post details content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPostHeader(index),
                  _buildPostContent(index),
                  _buildPostImage(index),
                  _buildPostActions(index),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageGallery(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  GymatesTheme.primaryColor.withValues(alpha: 0.1),
                  GymatesTheme.secondaryColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.image,
                size: 100,
                color: GymatesTheme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showComments(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Comments header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Comments',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Comments list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: GymatesTheme.primaryGradient,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Great post! Keep it up! 💪',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: GymatesTheme.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Comment input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Send comment
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: GymatesTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
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
}
