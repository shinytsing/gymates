import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/3d_components/index.dart';
import '../../core/animations/cartoon_3d_animations.dart' as cartoon_animations;
import '../../core/theme/cartoon_3d_characters.dart';
import '../../widgets/avatars/fitness_3d_avatar.dart';
import '../../widgets/layouts/page_scaffold_3d.dart';

/// ℹ️ Apple Fitness+ Style About Page (3D)
/// 
/// Design Features:
/// - 3D app info card
/// - 3D version info card
/// - 3D team info cards
/// - Smooth animations
/// - Apple Fitness+ minimalist style
class AboutPage3D extends StatefulWidget {
  const AboutPage3D({super.key});

  @override
  State<AboutPage3D> createState() => _AboutPage3DState();
}

class _AboutPage3DState extends State<AboutPage3D> {
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppleFitnessTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppleFitnessTheme.bodyMedium.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppleFitnessTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold3D(
      title: '关于我们',
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        child: Column(
          children: [
            // App Info
            cartoon_animations.BounceInAnimation(
              delay: const Duration(milliseconds: 100),
              child: Card3D(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingXXL),
                borderRadius: BorderRadius.circular(28),
                gradient: AppleFitnessTheme.primaryGradient,
                child: Column(
                  children: [
                    Fitness3DAvatar(
                      size: 100,
                      angle: AvatarAngle.front,
                      action: FitnessAction.celebrating,
                    ),
                    SizedBox(height: AppleFitnessTheme.spacingL),
                    Text(
                      'Gymates',
                      style: AppleFitnessTheme.titleLarge.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppleFitnessTheme.spacingM),
                    Text(
                      '你的专属健身社交平台',
                      style: AppleFitnessTheme.bodyLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppleFitnessTheme.spacingM),
                    Text(
                      '让健身不再孤单，与志同道合的伙伴一起追求健康生活',
                      style: AppleFitnessTheme.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingL),
            
            // Version Info
            cartoon_animations.SlideInAnimation(
              direction: cartoon_animations.SlideDirection.fromLeft,
              delay: const Duration(milliseconds: 200),
              child: Card3D(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '版本信息',
                      style: AppleFitnessTheme.titleMedium,
                    ),
                    SizedBox(height: AppleFitnessTheme.spacingL),
                    _buildInfoRow('应用版本', '1.0.0'),
                    _buildInfoRow('构建版本', '2024.12.10'),
                    _buildInfoRow('更新时间', '2024年12月10日'),
                    _buildInfoRow('应用大小', '45.2 MB'),
                    SizedBox(height: AppleFitnessTheme.spacingL),
                    SizedBox(
                      width: double.infinity,
                      child: Button3D(
                        text: '检查更新',
                        icon: Icons.update_outlined,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('已是最新版本'),
                              backgroundColor: AppleFitnessTheme.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                          );
                        },
                        type: Button3DType.primary,
                        size: Button3DSize.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingL),
            
            // Team Info
            cartoon_animations.SlideInAnimation(
              direction: cartoon_animations.SlideDirection.fromRight,
              delay: const Duration(milliseconds: 300),
              child: Card3D(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '开发团队',
                      style: AppleFitnessTheme.titleMedium,
                    ),
                    SizedBox(height: AppleFitnessTheme.spacingL),
                    _buildTeamMember('产品经理', '张小明', '负责产品规划和用户体验设计'),
                    _buildTeamMember('技术负责人', '李华', '负责技术架构和核心功能开发'),
                    _buildTeamMember('UI设计师', '王美丽', '负责界面设计和交互体验'),
                    _buildTeamMember('后端工程师', '刘强', '负责服务器端开发和API设计'),
                    _buildTeamMember('测试工程师', '陈静', '负责质量保证和测试管理'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingL),
            
            // Legal Info
            cartoon_animations.SlideInAnimation(
              direction: cartoon_animations.SlideDirection.fromBottom,
              delay: const Duration(milliseconds: 400),
              child: Card3D(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.description_outlined, color: AppleFitnessTheme.primaryBlue),
                      title: Text('用户协议', style: AppleFitnessTheme.bodyMedium),
                      trailing: Icon(Icons.chevron_right, color: AppleFitnessTheme.textTertiary),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('用户协议功能待实现'),
                            backgroundColor: AppleFitnessTheme.info,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(color: AppleFitnessTheme.textQuaternary),
                    ListTile(
                      leading: Icon(Icons.privacy_tip_outlined, color: AppleFitnessTheme.primaryBlue),
                      title: Text('隐私政策', style: AppleFitnessTheme.bodyMedium),
                      trailing: Icon(Icons.chevron_right, color: AppleFitnessTheme.textTertiary),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('隐私政策功能待实现'),
                            backgroundColor: AppleFitnessTheme.info,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(String role, String name, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppleFitnessTheme.spacingM),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppleFitnessTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.person_outline,
              color: AppleFitnessTheme.primaryBlue,
            ),
          ),
          SizedBox(width: AppleFitnessTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppleFitnessTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppleFitnessTheme.spacingXS),
                Text(
                  role,
                  style: AppleFitnessTheme.bodySmall.copyWith(
                    color: AppleFitnessTheme.textSecondary,
                  ),
                ),
                SizedBox(height: AppleFitnessTheme.spacingXS),
                Text(
                  description,
                  style: AppleFitnessTheme.bodySmall.copyWith(
                    color: AppleFitnessTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

