import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';

/// 📞 帮助与反馈页面
/// 
/// 功能：
/// - 常见问题
/// - 联系客服
/// - 意见反馈
/// - 使用指南

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _activeTab = 'faq';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      appBar: AppBar(
        title: const Text('帮助与反馈'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: GymatesTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        boxShadow: GymatesTheme.softShadow,
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
    );
  }

  Widget _buildTabButton(String tab, String label) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _activeTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: GymatesTheme.spacing12,
          horizontal: GymatesTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: isActive ? GymatesTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(GymatesTheme.radius8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : GymatesTheme.lightTextSecondary,
          ),
          textAlign: TextAlign.center,
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
      padding: const EdgeInsets.all(GymatesTheme.spacing16),
      itemCount: 6,
      itemBuilder: (context, index) => _buildFAQItem(index),
    );
  }

  Widget _buildFAQItem(int index) {
    final faqs = [
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

    return Container(
      margin: const EdgeInsets.only(bottom: GymatesTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        boxShadow: GymatesTheme.softShadow,
      ),
      child: ExpansionTile(
        title: Text(
          faqs[index]['question']!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faqs[index]['answer']!,
              style: const TextStyle(
                fontSize: 14,
                color: GymatesTheme.lightTextSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContact() {
    return Padding(
      padding: const EdgeInsets.all(GymatesTheme.spacing16),
      child: Column(
        children: [
          _buildContactCard(
            '在线客服',
            '7x24小时在线服务',
            Icons.chat,
            Colors.blue,
            () => _showContactDialog('在线客服'),
          ),
          const SizedBox(height: GymatesTheme.spacing16),
          _buildContactCard(
            '电话客服',
            '400-888-8888',
            Icons.phone,
            Colors.green,
            () => _showContactDialog('电话客服'),
          ),
          const SizedBox(height: GymatesTheme.spacing16),
          _buildContactCard(
            '邮件支持',
            'support@gymates.com',
            Icons.email,
            Colors.orange,
            () => _showContactDialog('邮件支持'),
          ),
          const SizedBox(height: GymatesTheme.spacing16),
          _buildContactCard(
            '微信客服',
            'Gymates_Service',
            Icons.wechat,
            Colors.green,
            () => _showContactDialog('微信客服'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        child: Container(
          padding: const EdgeInsets.all(GymatesTheme.spacing20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(GymatesTheme.radius12),
            boxShadow: GymatesTheme.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(GymatesTheme.radius8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: GymatesTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: GymatesTheme.spacing4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: GymatesTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: GymatesTheme.lightTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    return Padding(
      padding: const EdgeInsets.all(GymatesTheme.spacing16),
      child: Column(
        children: [
          _buildFeedbackCard(
            '功能建议',
            '告诉我们你希望添加的新功能',
            Icons.lightbulb_outline,
            Colors.amber,
            () => _showFeedbackDialog('功能建议'),
          ),
          const SizedBox(height: GymatesTheme.spacing16),
          _buildFeedbackCard(
            '问题反馈',
            '报告使用中遇到的问题',
            Icons.bug_report_outlined,
            Colors.red,
            () => _showFeedbackDialog('问题反馈'),
          ),
          const SizedBox(height: GymatesTheme.spacing16),
          _buildFeedbackCard(
            '体验评价',
            '分享你的使用体验',
            Icons.star_outline,
            Colors.orange,
            () => _showFeedbackDialog('体验评价'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        child: Container(
          padding: const EdgeInsets.all(GymatesTheme.spacing20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(GymatesTheme.radius12),
            boxShadow: GymatesTheme.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(GymatesTheme.radius8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: GymatesTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: GymatesTheme.spacing4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: GymatesTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: GymatesTheme.lightTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('联系$type'),
        content: Text('正在为您连接$type，请稍候...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type),
        content: Text('感谢您的$type，我们会认真考虑您的建议！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
