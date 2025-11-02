import 'package:flutter/material.dart';
import '../../models/mate_models.dart';
import '../../services/mate_service.dart';
import '../../core/theme/gymates_colors.dart';
import '../chat/chat_page.dart';

/// 搭子详情页面
class MateDetailPage extends StatefulWidget {
  final MateProfile mate;

  const MateDetailPage({
    super.key,
    required this.mate,
  });

  @override
  State<MateDetailPage> createState() => _MateDetailPageState();
}

class _MateDetailPageState extends State<MateDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MateService _mateService = MateService();
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // 顶部AppBar with Hero动画
          _buildSliverAppBar(),

          // 基本信息卡片
          SliverToBoxAdapter(
            child: _buildBasicInfoCard(),
          ),

          // 匹配信息
          SliverToBoxAdapter(
            child: _buildMatchInfoCard(),
          ),

          // Tab标签
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: GyMatesColors.primaryGreen,
                labelColor: GyMatesColors.primaryGreen,
                unselectedLabelColor: Colors.grey[600],
                tabs: const [
                  Tab(text: '资料'),
                  Tab(text: '训练'),
                  Tab(text: '动态'),
                ],
              ),
            ),
          ),

          // Tab内容
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildTrainingTab(),
                _buildActivityTab(),
              ],
            ),
          ),
        ],
      ),

      // 底部操作栏
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.grey[900],
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _handleShare,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: _showMoreOptions,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图片或渐变
            Hero(
              tag: 'mate_avatar_${widget.mate.id}',
              child: widget.mate.avatar != null
                  ? Image.network(
                      widget.mate.avatar!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            GyMatesColors.primaryGreen.withOpacity(0.8),
                            GyMatesColors.primaryGreen.withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 120,
                        color: Colors.white,
                      ),
                    ),
            ),

            // 渐变遮罩
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),

            // 在线状态和匹配度
            Positioned(
              top: 100,
              right: 16,
              child: Column(
                children: [
                  // 在线状态
                  if (widget.mate.isOnline)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // 匹配度
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getMatchScoreColor().withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${widget.mate.matchScore}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
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

  Widget _buildBasicInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 名字和年龄
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.mate.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.mate.age != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.mate.age}岁',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // 位置和距离
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.mate.location ?? '未设置位置',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: GyMatesColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.mate.formattedDistance,
                  style: const TextStyle(
                    color: GyMatesColors.primaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (widget.mate.bio != null && widget.mate.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              widget.mate.bio!,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchInfoCard() {
    final hasCommonInfo = widget.mate.commonGoals.isNotEmpty ||
        widget.mate.commonTypes.isNotEmpty;

    if (!hasCommonInfo) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GyMatesColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: GyMatesColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '你们的共同点',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (widget.mate.commonGoals.isNotEmpty) ...[
            _buildCommonItem(
              '共同健身目标',
              widget.mate.commonGoals,
              Icons.flag,
            ),
            const SizedBox(height: 12),
          ],

          if (widget.mate.commonTypes.isNotEmpty)
            _buildCommonItem(
              '共同训练类型',
              widget.mate.commonTypes,
              Icons.fitness_center,
            ),
        ],
      ),
    );
  }

  Widget _buildCommonItem(String title, List<String> items, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: GyMatesColors.primaryGreen, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items
                    .map((item) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: GyMatesColors.primaryGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: GyMatesColors.primaryGreen.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: GyMatesColors.primaryGreen,
                              fontSize: 13,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoSection(
          '基本信息',
          [
            if (widget.mate.gender != null)
              _buildInfoItem('性别', widget.mate.gender == 'male' ? '男' : '女'),
            if (widget.mate.age != null)
              _buildInfoItem('年龄', '${widget.mate.age}岁'),
            if (widget.mate.height != null)
              _buildInfoItem('身高', '${widget.mate.height?.toStringAsFixed(0)}cm'),
            if (widget.mate.weight != null)
              _buildInfoItem('体重', '${widget.mate.weight?.toStringAsFixed(0)}kg'),
          ],
        ),

        const SizedBox(height: 16),

        _buildInfoSection(
          '健身信息',
          [
            if (widget.mate.goal != null)
              _buildInfoItem('健身目标', widget.mate.goal!),
            if (widget.mate.experience != null)
              _buildInfoItem('经验等级', widget.mate.experience!),
            if (widget.mate.preferredTime != null)
              _buildInfoItem('偏好时间', widget.mate.preferredTime!),
            if (widget.mate.trainingTypes != null)
              _buildInfoItem(
                '训练类型',
                widget.mate.trainingTypes!.join(', '),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrainingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildEmptyState(
          Icons.fitness_center,
          '暂无训练记录',
          '该用户还没有分享训练记录',
        ),
      ],
    );
  }

  Widget _buildActivityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildEmptyState(
          Icons.dynamic_feed,
          '暂无动态',
          '该用户还没有发布动态',
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 发消息按钮
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleMessage,
                icon: const Icon(Icons.message_outlined, size: 20),
                label: const Text('发消息'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: GyMatesColors.primaryGreen,
                  side: const BorderSide(color: GyMatesColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 添加搭子按钮
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isRequesting ? null : _handleAddMate,
                icon: _isRequesting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.person_add, size: 20),
                label: Text(_isRequesting ? '发送中...' : '添加为搭子'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GyMatesColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMatchScoreColor() {
    if (widget.mate.matchScore >= 80) {
      return const Color(0xFF4CAF50);
    } else if (widget.mate.matchScore >= 60) {
      return const Color(0xFF8BC34A);
    } else if (widget.mate.matchScore >= 40) {
      return const Color(0xFFFFC107);
    }
    return Colors.grey;
  }

  void _handleShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中')),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('屏蔽此用户', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 实现屏蔽功能
                },
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.orange),
                title: const Text('举报', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 实现举报功能
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMessage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          mate: widget.mate,
          chatId: widget.mate.id, // 使用mate的ID作为chatId，实际应该是chat表的ID
        ),
      ),
    );
  }

  Future<void> _handleAddMate() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      await _mateService.sendMateRequest(widget.mate.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('搭子请求已发送'),
            backgroundColor: GyMatesColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }
}

// SliverTabBar代理
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.grey[900],
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

