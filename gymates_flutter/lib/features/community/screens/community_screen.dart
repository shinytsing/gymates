import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_card.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  int _selectedTab = 0;
  
  final List<String> _tabs = ['推荐', '关注', '热门'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: '社区',
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: null, // TODO: Implement search
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: AppColors.surface,
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isSelected = _selectedTab == index;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.paddingM,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected 
                                ? AppColors.primary 
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        tab,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected 
                              ? AppColors.primary 
                              : AppColors.textSecondary,
                          fontWeight: isSelected 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // TODO: Implement refresh
                await Future.delayed(const Duration(seconds: 1));
              },
              child: _buildContent(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppNavigation.goToCreatePost(context);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildRecommendedPosts();
      case 1:
        return _buildFollowingPosts();
      case 2:
        return _buildHotPosts();
      default:
        return _buildRecommendedPosts();
    }
  }

  Widget _buildRecommendedPosts() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      itemCount: 10, // Mock data
      itemBuilder: (context, index) {
        return _buildPostCard();
      },
    );
  }

  Widget _buildFollowingPosts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            '还没有关注任何人',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '关注一些健身达人，查看他们的动态',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingL),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement discover users
            },
            child: const Text('发现用户'),
          ),
        ],
      ),
    );
  }

  Widget _buildHotPosts() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      itemCount: 8, // Mock data
      itemBuilder: (context, index) {
        return _buildPostCard();
      },
    );
  }

  Widget _buildPostCard() {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: AppSizes.avatarS / 2,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '健身达人',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '2小时前',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: Implement post options
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Post Content
          Text(
            '今天的胸肌训练太棒了！平板卧推、上斜卧推、飞鸟动作都完成了，感觉肌肉在燃烧🔥',
            style: AppTextStyles.bodyMedium,
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Post Image
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: const Center(
              child: Icon(
                Icons.image,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Post Actions
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.favorite_border,
                  label: '12',
                  onTap: () {
                    // TODO: Implement like
                  },
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: '3',
                  onTap: () {
                    // TODO: Implement comment
                  },
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.share_outlined,
                  label: '分享',
                  onTap: () {
                    // TODO: Implement share
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizes.iconS,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.paddingXS),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
