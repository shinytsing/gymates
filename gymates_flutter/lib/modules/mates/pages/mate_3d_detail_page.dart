import 'package:flutter/material.dart';
import '../../../core/3d_components/index.dart';
import '../../../models/mate_models.dart';
import '../../../services/mate_service.dart';
import '../../../pages/chat/chat_3d_room_page.dart';

/// 👥 Apple Fitness+ Style Mate Detail Page
/// 
/// Design Features:
/// - 3D floating avatar (rotation + scale)
/// - 3D info cards (folding expand)
/// - 3D tag cloud (3D layout)
/// - 3D chat button (pulse breathing)
/// - 3D quick actions (follow, block, report)
/// - Smooth scrolling effects

class Mate3DDetailPage extends StatefulWidget {
  final MateProfile mate;

  const Mate3DDetailPage({
    super.key,
    required this.mate,
  });

  @override
  State<Mate3DDetailPage> createState() => _Mate3DDetailPageState();
}

class _Mate3DDetailPageState extends State<Mate3DDetailPage>
    with TickerProviderStateMixin {
  final MateService _mateService = MateService();
  final ScrollController _scrollController = ScrollController();
  
  bool _isFollowing = false;
  bool _isRequesting = false;
  double _scrollOffset = 0;
  
  late AnimationController _avatarController;
  late Animation<double> _avatarRotation;

  @override
  void initState() {
    super.initState();
    
    _avatarController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _avatarRotation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeInOut),
    );
    
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    
    _checkFollowStatus();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkFollowStatus() async {
    // TODO: Check if already following
    setState(() {
      _isFollowing = false;
    });
  }

  Future<void> _toggleFollow() async {
    setState(() => _isRequesting = true);
    
    try {
      if (_isFollowing) {
        // Unfollow not supported, just remove from list
        // await _mateService.removeMate(widget.mate.id);
      } else {
        await _mateService.sendMateRequest(widget.mate.id);
      }
      
      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
          _isRequesting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRequesting = false);
        showAlertDialog3D(
          context: context,
          title: '操作失败',
          message: e.toString(),
          confirmText: '确定',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppleFitnessTheme.backgroundGradient,
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildHeader(),
            _buildAvatarSection(),
            _buildBasicInfo(),
            _buildMatchInfo(),
            _buildInterestsSection(),
            _buildStatsSection(),
            _buildGallerySection(),
            SliverToBoxAdapter(
              child: SizedBox(height: AppleFitnessTheme.spacingXXL),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    final opacity = (_scrollOffset / 200).clamp(0.0, 1.0);
    
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: AppleFitnessTheme.backgroundPrimary.withValues(alpha: opacity),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Opacity(
        opacity: opacity,
        child: Text(
          widget.mate.name,
          style: AppleFitnessTheme.titleLarge,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        child: AnimatedBuilder(
          animation: _avatarRotation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(_avatarRotation.value * 0.5)
                ..rotateZ(_avatarRotation.value * 0.2),
              child: child,
            );
          },
          child: Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppleFitnessTheme.primaryGradient,
                boxShadow: AppleFitnessTheme.softGlow(
                  AppleFitnessTheme.primaryBlue,
                  intensity: 0.5,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 66,
                backgroundImage: widget.mate.avatar != null && widget.mate.avatar!.isNotEmpty
                    ? NetworkImage(widget.mate.avatar!)
                    : null,
                child: widget.mate.avatar == null || widget.mate.avatar!.isEmpty
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingL),
        child: FadeIn3D(
          child: Card3D(
            useFrostedGlass: true,
            child: Column(
              children: [
                Text(
                  widget.mate.name,
                  style: AppleFitnessTheme.displaySmall,
                ),
                SizedBox(height: AppleFitnessTheme.spacingS),
                Text(
                  '${widget.mate.age}岁 · ${widget.mate.gender}',
                  style: AppleFitnessTheme.bodyLarge.copyWith(
                    color: AppleFitnessTheme.textSecondary,
                  ),
                ),
                if (widget.mate.location != null) ...[
                  SizedBox(height: AppleFitnessTheme.spacingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppleFitnessTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.mate.location!,
                        style: AppleFitnessTheme.bodyMedium.copyWith(
                          color: AppleFitnessTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.mate.bio != null) ...[
                  SizedBox(height: AppleFitnessTheme.spacingL),
                  Text(
                    widget.mate.bio!,
                    style: AppleFitnessTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        child: Card3D(
          gradient: AppleFitnessTheme.primaryGradient,
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: AppleFitnessTheme.spacingS),
                  Text(
                    '匹配度',
                    style: AppleFitnessTheme.titleLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppleFitnessTheme.spacingL),
              CircularProgress3D(
                value: widget.mate.matchScore / 100,
                size: 120,
                strokeWidth: 12,
                progressColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                centerWidget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.mate.matchScore}%',
                      style: AppleFitnessTheme.displayMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppleFitnessTheme.spacingL),
              Text(
                '你们有很多共同兴趣',
                style: AppleFitnessTheme.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsSection() {
    final interests = widget.mate.trainingTypes ?? ['力量训练', '有氧运动', '瑜伽'];
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '兴趣标签',
              style: AppleFitnessTheme.titleLarge,
            ),
            SizedBox(height: AppleFitnessTheme.spacingM),
            Wrap(
              spacing: AppleFitnessTheme.spacingS,
              runSpacing: AppleFitnessTheme.spacingS,
              children: interests.asMap().entries.map((entry) {
                final index = entry.key;
                final interest = entry.value;
                return StaggeredAnimation3D(
                  index: index,
                  delay: const Duration(milliseconds: 50),
                  child: _buildInterestTag(interest),
                );
              }).toList(),
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestTag(String interest) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppleFitnessTheme.spacingM,
        vertical: AppleFitnessTheme.spacingS,
      ),
      decoration: BoxDecoration(
        gradient: AppleFitnessTheme.primaryGradient,
        borderRadius: AppleFitnessTheme.radiusSmall,
        boxShadow: AppleFitnessTheme.softShadow(elevation: 4),
      ),
      child: Text(
        interest,
        style: AppleFitnessTheme.labelMedium.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '训练数据',
              style: AppleFitnessTheme.titleLarge,
            ),
            SizedBox(height: AppleFitnessTheme.spacingM),
            Card3D(
              useFrostedGlass: true,
              child: Column(
                children: [
                  _buildStatRow(
                    label: '训练天数',
                    value: '128',
                    unit: '天',
                    icon: Icons.calendar_today,
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingL),
                  _buildStatRow(
                    label: '完成训练',
                    value: '256',
                    unit: '次',
                    icon: Icons.check_circle,
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingL),
                  _buildStatRow(
                    label: '训练时长',
                    value: '320',
                    unit: '小时',
                    icon: Icons.timer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppleFitnessTheme.spacingS),
          decoration: BoxDecoration(
            gradient: AppleFitnessTheme.primaryGradient,
            borderRadius: AppleFitnessTheme.radiusSmall,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(width: AppleFitnessTheme.spacingM),
        Expanded(
          child: Text(
            label,
            style: AppleFitnessTheme.bodyMedium,
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppleFitnessTheme.titleLarge.copyWith(
                  color: AppleFitnessTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: AppleFitnessTheme.bodySmall.copyWith(
                  color: AppleFitnessTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGallerySection() {
    // Mock gallery images
    final images = List.generate(6, (index) => null);
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '训练相册',
              style: AppleFitnessTheme.titleLarge,
            ),
            SizedBox(height: AppleFitnessTheme.spacingM),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Card3D(
                  gradient: AppleFitnessTheme.workoutGradients.values.elementAt(
                    index % AppleFitnessTheme.workoutGradients.length,
                  ),
                  onTap: () {},
                  child: Center(
                    child: Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Button3D.primary(
                text: '发消息',
                icon: Icons.message,
                size: Button3DSize.large,
                onPressed: _openChat,
              ),
            ),
            SizedBox(width: AppleFitnessTheme.spacingM),
            Button3D(
              icon: _isFollowing ? Icons.favorite : Icons.favorite_border,
              backgroundColor: _isFollowing 
                  ? AppleFitnessTheme.primaryPink
                  : AppleFitnessTheme.backgroundSecondary,
              foregroundColor: _isFollowing 
                  ? Colors.white
                  : AppleFitnessTheme.textPrimary,
              enableGlow: _isFollowing,
              onPressed: _isRequesting ? null : _toggleFollow,
            ),
          ],
        ),
      ),
    );
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chat3DRoomPage(
          recipientId: widget.mate.id.toString(),
          recipientName: widget.mate.name,
          recipientAvatar: widget.mate.avatar,
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showActionSheet3D(
      context: context,
      title: '更多操作',
      options: [
        ActionSheetOption(
          text: '分享资料',
          value: 'share',
          icon: Icons.share,
        ),
        ActionSheetOption(
          text: '屏蔽',
          value: 'block',
          icon: Icons.block,
        ),
        ActionSheetOption(
          text: '举报',
          value: 'report',
          icon: Icons.report,
          isDestructive: true,
        ),
      ],
      cancelOption: ActionSheetOption(
        text: '取消',
        value: 'cancel',
      ),
    );
  }
}

