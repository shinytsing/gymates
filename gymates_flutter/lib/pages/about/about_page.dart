import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';

/// ℹ️ 关于我们页面
/// 
/// 功能：
/// - 应用信息
/// - 版本信息
/// - 团队介绍
/// - 隐私政策
/// - 用户协议

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
        title: const Text('关于我们'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GymatesTheme.spacing16),
          child: Column(
            children: [
              _buildAppInfo(),
              const SizedBox(height: GymatesTheme.spacing24),
              _buildVersionInfo(),
              const SizedBox(height: GymatesTheme.spacing24),
              _buildTeamInfo(),
              const SizedBox(height: GymatesTheme.spacing24),
              _buildLegalInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(GymatesTheme.spacing24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GymatesTheme.primaryColor,
            GymatesTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(GymatesTheme.radius16),
        boxShadow: GymatesTheme.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(GymatesTheme.radius16),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: GymatesTheme.spacing16),
          const Text(
            'Gymates',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: GymatesTheme.spacing8),
          const Text(
            '你的专属健身社交平台',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: GymatesTheme.spacing16),
          const Text(
            '让健身不再孤单，与志同道合的伙伴一起追求健康生活',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(GymatesTheme.spacing20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GymatesTheme.radius16),
        boxShadow: GymatesTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '版本信息',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: GymatesTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: GymatesTheme.spacing16),
          _buildInfoRow('应用版本', '1.0.0'),
          _buildInfoRow('构建版本', '2024.12.10'),
          _buildInfoRow('更新时间', '2024年12月10日'),
          _buildInfoRow('应用大小', '45.2 MB'),
          const SizedBox(height: GymatesTheme.spacing16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showUpdateDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GymatesTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GymatesTheme.radius8),
                ),
              ),
              child: const Text('检查更新'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo() {
    return Container(
      padding: const EdgeInsets.all(GymatesTheme.spacing20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GymatesTheme.radius16),
        boxShadow: GymatesTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '开发团队',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: GymatesTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: GymatesTheme.spacing16),
          _buildTeamMember('产品经理', '张小明', '负责产品规划和用户体验设计'),
          _buildTeamMember('技术负责人', '李华', '负责技术架构和核心功能开发'),
          _buildTeamMember('UI设计师', '王美丽', '负责界面设计和交互体验'),
          _buildTeamMember('后端工程师', '刘强', '负责服务器端开发和API设计'),
          _buildTeamMember('测试工程师', '陈静', '负责质量保证和测试管理'),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String role, String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GymatesTheme.spacing16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: GymatesTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(GymatesTheme.radius8),
            ),
            child: Icon(
              Icons.person,
              color: GymatesTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: GymatesTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: GymatesTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: GymatesTheme.spacing4),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 14,
                    color: GymatesTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: GymatesTheme.spacing4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: GymatesTheme.lightTextSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalInfo() {
    return Container(
      padding: const EdgeInsets.all(GymatesTheme.spacing20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GymatesTheme.radius16),
        boxShadow: GymatesTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '法律信息',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: GymatesTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: GymatesTheme.spacing16),
          _buildLegalItem('用户协议', Icons.description_outlined, () => _showLegalDialog('用户协议')),
          _buildLegalItem('隐私政策', Icons.privacy_tip_outlined, () => _showLegalDialog('隐私政策')),
          _buildLegalItem('服务条款', Icons.rule_outlined, () => _showLegalDialog('服务条款')),
          _buildLegalItem('免责声明', Icons.warning_outlined, () => _showLegalDialog('免责声明')),
        ],
      ),
    );
  }

  Widget _buildLegalItem(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(GymatesTheme.radius8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: GymatesTheme.spacing12,
            horizontal: GymatesTheme.spacing8,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: GymatesTheme.lightTextSecondary,
                size: 20,
              ),
              const SizedBox(width: GymatesTheme.spacing12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: GymatesTheme.lightTextPrimary,
                  ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GymatesTheme.spacing12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: GymatesTheme.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: GymatesTheme.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('检查更新'),
        content: const Text('当前已是最新版本！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showLegalDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('$title内容正在完善中，敬请期待...'),
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
