import 'package:flutter/material.dart';
import '../../core/3d_components/index.dart';
import '../../core/animations/cartoon_3d_animations.dart' as cartoon_animations;
import '../../core/config/smart_api_config.dart';
import '../../widgets/layouts/page_scaffold_3d.dart';

/// 🧪 Apple Fitness+ Style API Config Test Page (3D)
/// 
/// Design Features:
/// - 3D info cards
/// - 3D test buttons
/// - Smooth animations
/// - Apple Fitness+ minimalist style
class ApiConfigTestPage3D extends StatelessWidget {
  const ApiConfigTestPage3D({super.key});

  Widget _buildInfoRow(String label, dynamic value) {
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
              value.toString(),
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
    final envInfo = SmartApiConfig.getEnvironmentInfo();
    
    return PageScaffold3D(
      title: 'API配置测试',
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Environment Info
            cartoon_animations.SlideInAnimation(
              direction: cartoon_animations.SlideDirection.fromLeft,
              delay: const Duration(milliseconds: 100),
              child: Card3D(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🌍 环境信息',
                      style: AppleFitnessTheme.titleMedium,
                    ),
                    SizedBox(height: AppleFitnessTheme.spacingL),
                    _buildInfoRow('平台', envInfo['platform']),
                    _buildInfoRow('是否Web', envInfo['isWeb']),
                    _buildInfoRow('是否Android', envInfo['isAndroid']),
                    _buildInfoRow('是否iOS', envInfo['isIOS']),
                    Divider(color: AppleFitnessTheme.textQuaternary),
                    _buildInfoRow('API地址', SmartApiConfig.baseUrl),
                    _buildInfoRow('API基础URL', SmartApiConfig.apiBaseUrl),
                    _buildInfoRow('WebSocket URL', SmartApiConfig.wsBaseUrl),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingL),
            
            // Test Functions
            cartoon_animations.SlideInAnimation(
              direction: cartoon_animations.SlideDirection.fromRight,
              delay: const Duration(milliseconds: 200),
              child: Card3D(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔧 测试功能',
                      style: AppleFitnessTheme.titleMedium,
                    ),
                    SizedBox(height: AppleFitnessTheme.spacingL),
                    Button3D(
                      text: '测试API连接',
                      icon: Icons.cloud_outlined,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('API连接测试功能待实现'),
                            backgroundColor: AppleFitnessTheme.info,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

