import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/3d_components/index.dart';
import '../../core/animations/cartoon_3d_animations.dart' as cartoon_animations;
import '../../widgets/layouts/page_scaffold_3d.dart';

/// 📞 Apple Fitness+ Style Help Page (3D)
/// 
/// Design Features:
/// - 3D tab navigation
/// - 3D FAQ cards
/// - 3D contact cards
/// - Smooth animations
/// - Apple Fitness+ minimalist style
class HelpPage3D extends StatefulWidget {
  const HelpPage3D({super.key});

  @override
  State<HelpPage3D> createState() => _HelpPage3DState();
}

class _HelpPage3DState extends State<HelpPage3D> {
  String _activeTab = 'faq';

  final List<Map<String, String>> _faqs = [
    {
      'question': '如何开始我的第一次训练？',
      'answer': '在训练页面选择适合你的训练计划，点击"开始训练"即可开始。建议新手从基础训练开始。'
    },
    {
      'question': '如何找到健身搭子？',
      'answer': '在搭子页面可以浏览附近的健身伙伴，系统会根据你的健身偏好为你推荐合适的搭子。'
    },
    {
      'question': '如何记录训练数据？',
      'answer': '训练完成后，系统会自动记录你的训练数据。你也可以在个人页面查看详细的训练统计。'
    },
    {
      'question': '如何获得成就徽章？',
      'answer': '完成特定的训练目标或连续训练天数即可获得相应的成就徽章，在成就页面可以查看所有徽章。'
    },
    {
      'question': '如何修改个人信息？',
      'answer': '在个人页面点击"编辑资料"即可修改你的头像、昵称、健身目标等信息。'
    },
    {
      'question': '如何联系客服？',
      'answer': '你可以通过本页面的"联系客服"功能或发送邮件至 support@gymates.com 联系我们。'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return PageScaffold3D(
      title: '帮助与反馈',
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      child: Column(
        children: [
          // Tab Bar
          cartoon_animations.BounceInAnimation(
            delay: const Duration(milliseconds: 100),
            child: Container(
              margin: EdgeInsets.all(AppleFitnessTheme.spacingL),
              decoration: BoxDecoration(
                color: AppleFitnessTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('faq', '常见问题'),
                  ),
                  Expanded(
                    child: _buildTabButton('contact', '联系客服'),
                  ),
                  Expanded(
                    child: _buildTabButton('feedback', '意见反馈'),
                  ),
                ],
              ),
            ),
          ),
          
          // Tab Content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, String label) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _activeTab = tab);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppleFitnessTheme.spacingM),
        decoration: BoxDecoration(
          color: isActive ? AppleFitnessTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppleFitnessTheme.bodyMedium.copyWith(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.white : AppleFitnessTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 'faq':
        return _buildFAQ();
      case 'contact':
        return _buildContact();
      case 'feedback':
        return _buildFeedback();
      default:
        return _buildFAQ();
    }
  }

  Widget _buildFAQ() {
    return ListView.builder(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      itemCount: _faqs.length,
      itemBuilder: (context, index) {
        return cartoon_animations.SlideInAnimation(
          direction: cartoon_animations.SlideDirection.fromLeft,
          delay: Duration(milliseconds: 100 + index * 50),
          child: Card3D(
            padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
            borderRadius: BorderRadius.circular(28),
            margin: EdgeInsets.only(bottom: AppleFitnessTheme.spacingM),
            child: ExpansionTile(
              title: Text(
                _faqs[index]['question']!,
                style: AppleFitnessTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(AppleFitnessTheme.spacingM),
                  child: Text(
                    _faqs[index]['answer']!,
                    style: AppleFitnessTheme.bodyMedium.copyWith(
                      color: AppleFitnessTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContact() {
    final contacts = [
      {'title': '在线客服', 'subtitle': '7x24小时在线服务', 'icon': Icons.chat_outlined, 'color': AppleFitnessTheme.primaryBlue},
      {'title': '电话客服', 'subtitle': '400-888-8888', 'icon': Icons.phone_outlined, 'color': AppleFitnessTheme.primaryGreen},
      {'title': '邮件支持', 'subtitle': 'support@gymates.com', 'icon': Icons.email_outlined, 'color': AppleFitnessTheme.primaryOrange},
      {'title': '微信客服', 'subtitle': 'Gymates_Service', 'icon': Icons.wechat, 'color': AppleFitnessTheme.primaryGreen},
    ];

    return ListView.builder(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        return cartoon_animations.SlideInAnimation(
          direction: cartoon_animations.SlideDirection.fromRight,
          delay: Duration(milliseconds: 100 + index * 50),
          child: Card3D(
            padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
            borderRadius: BorderRadius.circular(28),
            margin: EdgeInsets.only(bottom: AppleFitnessTheme.spacingM),
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${contacts[index]['title']}功能待实现'),
                  backgroundColor: AppleFitnessTheme.info,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (contacts[index]['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    contacts[index]['icon'] as IconData,
                    color: contacts[index]['color'] as Color,
                  ),
                ),
                SizedBox(width: AppleFitnessTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contacts[index]['title'] as String,
                        style: AppleFitnessTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppleFitnessTheme.spacingXS),
                      Text(
                        contacts[index]['subtitle'] as String,
                        style: AppleFitnessTheme.bodySmall.copyWith(
                          color: AppleFitnessTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppleFitnessTheme.textTertiary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedback() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      child: Column(
        children: [
          cartoon_animations.SlideInAnimation(
            direction: cartoon_animations.SlideDirection.fromBottom,
            delay: const Duration(milliseconds: 100),
            child: Card3D(
              padding: EdgeInsets.all(AppleFitnessTheme.spacingXL),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '意见反馈',
                    style: AppleFitnessTheme.titleMedium,
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingL),
                  Text(
                    '我们非常重视您的意见和建议，请告诉我们您的想法。',
                    style: AppleFitnessTheme.bodyMedium.copyWith(
                      color: AppleFitnessTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingL),
                  Button3D(
                    text: '提交反馈',
                    icon: Icons.send_outlined,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('反馈功能待实现'),
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
    );
  }
}

