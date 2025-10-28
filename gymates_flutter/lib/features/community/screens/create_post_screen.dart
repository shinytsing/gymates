import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_text_field.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement publish post
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('发布功能即将推出')),
      );
      AppNavigation.goBack(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '发布动态',
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => AppNavigation.goBack(context),
        ),
        actions: [
          TextButton(
            onPressed: _handlePublish,
            child: const Text('发布'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              Row(
                children: [
                  CircleAvatar(
                    radius: AppSizes.avatarS / 2,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
                          '现在',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.paddingL),
              
              // Content Input
              CustomTextField(
                controller: _contentController,
                label: '分享你的健身心得',
                hintText: '今天训练了什么？有什么收获？',
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入内容';
                  }
                  if (value.trim().length < 10) {
                    return '内容至少需要10个字符';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSizes.paddingL),
              
              // Add Media
              Text(
                '添加媒体',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingM),
              
              Row(
                children: [
                  Expanded(
                    child: _buildMediaOption(
                      icon: Icons.photo_camera,
                      label: '拍照',
                      onTap: () {
                        // TODO: Implement camera
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: _buildMediaOption(
                      icon: Icons.photo_library,
                      label: '相册',
                      onTap: () {
                        // TODO: Implement gallery
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: _buildMediaOption(
                      icon: Icons.videocam,
                      label: '视频',
                      onTap: () {
                        // TODO: Implement video
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.paddingL),
              
              // Tags
              Text(
                '添加标签',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingM),
              
              Wrap(
                spacing: AppSizes.paddingS,
                runSpacing: AppSizes.paddingS,
                children: [
                  '健身',
                  '训练',
                  '胸肌',
                  '有氧',
                  '力量',
                  '瑜伽',
                ].map((tag) => _buildTagChip(tag)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: AppSizes.iconL,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              label,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement add tag
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          '#$tag',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
