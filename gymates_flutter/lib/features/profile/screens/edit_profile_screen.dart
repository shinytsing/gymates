import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: Load user data
    _nameController.text = '健身达人';
    _bioController.text = '热爱健身，追求健康生活';
    _locationController.text = '北京';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement save profile
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
      AppNavigation.goBack(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '编辑资料',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppNavigation.goBack(context),
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            children: [
              // Avatar Section
              _buildAvatarSection(),
              
              const SizedBox(height: AppSizes.paddingL),
              
              // Form Fields
              CustomTextField(
                controller: _nameController,
                label: '姓名',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入姓名';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSizes.paddingM),
              
              CustomTextField(
                controller: _bioController,
                label: '个人简介',
                hintText: '介绍一下自己吧',
                maxLines: 3,
                maxLength: 200,
                validator: (value) {
                  if (value != null && value.length > 200) {
                    return '简介不能超过200个字符';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSizes.paddingM),
              
              CustomTextField(
                controller: _locationController,
                label: '所在城市',
                hintText: '请输入所在城市',
                prefixIcon: Icons.location_on_outlined,
              ),
              
              const SizedBox(height: AppSizes.paddingL),
              
              // Additional Info
              _buildAdditionalInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return CustomCard(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: AppSizes.avatarXL / 2,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingXS),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            '点击更换头像',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '健身信息',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: AppSizes.paddingM),
          
          // Age
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: '年龄',
                  hintText: '25',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.cake_outlined,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: CustomTextField(
                  label: '身高 (cm)',
                  hintText: '175',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.height,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Weight
          CustomTextField(
            label: '体重 (kg)',
            hintText: '70',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.monitor_weight_outlined,
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Fitness Goals
          Text(
            '健身目标',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Wrap(
            spacing: AppSizes.paddingS,
            runSpacing: AppSizes.paddingS,
            children: [
              '增肌',
              '减脂',
              '塑形',
              '增强体质',
              '提高耐力',
            ].map((goal) => _buildGoalChip(goal)).toList(),
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Experience Level
          Text(
            '健身经验',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            children: [
              '新手',
              '初级',
              '中级',
              '高级',
            ].map((level) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXS),
                child: _buildExperienceChip(level),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalChip(String goal) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement goal selection
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          goal,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceChip(String level) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement experience selection
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          level,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
