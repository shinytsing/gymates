import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_card.dart';

class MatesScreen extends ConsumerStatefulWidget {
  const MatesScreen({super.key});

  @override
  ConsumerState<MatesScreen> createState() => _MatesScreenState();
}

class _MatesScreenState extends ConsumerState<MatesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: '搭子',
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: null, // TODO: Implement search
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          itemCount: 5, // Mock data
          itemBuilder: (context, index) {
            return _buildMateCard();
          },
        ),
      ),
    );
  }

  Widget _buildMateCard() {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppSizes.avatarM / 2,
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
                      '健身爱好者',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '25岁 • 北京',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement connect
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                ),
                child: const Text('连接'),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          Text(
            '寻找一起健身的伙伴，主要训练胸肌和背部，希望找到志同道合的朋友一起坚持训练！',
            style: AppTextStyles.bodyMedium,
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Tags
          Wrap(
            spacing: AppSizes.paddingS,
            runSpacing: AppSizes.paddingS,
            children: [
              '胸肌训练',
              '力量训练',
              '健身房',
              '工作日',
            ].map((tag) => _buildTag(tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Text(
        tag,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
