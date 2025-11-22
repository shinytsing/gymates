import 'package:flutter/material.dart';
import '../../../core/3d_components/index.dart';
import '../../../shared/models/mock_data.dart';

/// 📱 Apple Fitness+ Style Post Detail Page
/// 
/// Design Features:
/// - 3D author card (floating header)
/// - 3D image carousel (swipe with indicators)
/// - 3D action buttons (like, comment, share)
/// - 3D comment list (nested replies)
/// - 3D comment input (floating bottom)
/// - Smooth scroll animations

class Post3DDetailPage extends StatefulWidget {
  final CommunityPost post;

  const Post3DDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<Post3DDetailPage> createState() => _Post3DDetailPageState();
}

class _Post3DDetailPageState extends State<Post3DDetailPage>
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PageController _imagePageController = PageController();
  
  bool _isLiked = false;
  bool _isBookmarked = false;
  int _likeCount = 0;
  int _commentCount = 0;
  int _currentImageIndex = 0;
  double _scrollOffset = 0;
  
  late AnimationController _likeController;
  late AnimationController _bookmarkController;
  late Animation<double> _likeScale;
  late Animation<double> _bookmarkScale;
  
  final List<Comment3D> _comments = [
    Comment3D(
      id: '1',
      userName: 'Alice',
      userAvatar: null,
      content: '太棒了！我也在坚持训练，一起加油！',
      time: '2小时前',
      likes: 12,
      isLiked: false,
    ),
    Comment3D(
      id: '2',
      userName: 'Bob',
      userAvatar: null,
      content: '动作很标准，学习了！',
      time: '3小时前',
      likes: 8,
      isLiked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _isLiked = widget.post.isLiked;
    _isBookmarked = widget.post.isBookmarked;
    _likeCount = widget.post.likes;
    _commentCount = widget.post.comments;
    
    _likeController = AnimationController(
      duration: AppleFitnessTheme.durationFast,
      vsync: this,
    );
    
    _bookmarkController = AnimationController(
      duration: AppleFitnessTheme.durationFast,
      vsync: this,
    );
    
    _likeScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeController,
        curve: Curves.easeInOut,
      ),
    );
    
    _bookmarkScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _bookmarkController,
        curve: Curves.easeInOut,
      ),
    );
    
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _imagePageController.dispose();
    _likeController.dispose();
    _bookmarkController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    
    _likeController.forward().then((_) => _likeController.reverse());
  }

  Future<void> _toggleBookmark() async {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    
    _bookmarkController.forward().then((_) => _bookmarkController.reverse());
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.insert(
        0,
        Comment3D(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userName: '我',
          userAvatar: null,
          content: text,
          time: '刚刚',
          likes: 0,
          isLiked: false,
        ),
      );
      _commentCount++;
    });
    
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppleFitnessTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final opacity = (_scrollOffset / 200).clamp(0.0, 1.0);
    
    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        decoration: BoxDecoration(
          color: AppleFitnessTheme.backgroundPrimary.withValues(alpha: opacity),
          boxShadow: opacity > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05 * opacity),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            Opacity(
              opacity: opacity,
              child: Text(
                widget.post.user.name,
                style: AppleFitnessTheme.titleMedium,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showMoreOptions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          _buildAuthorSection(),
          
          // Images
          if (widget.post.images != null && widget.post.images!.isNotEmpty)
            _buildImageSection(),
          
          // Actions
          _buildActionSection(),
          
          // Content
          _buildContentSection(),
          
          // Tags
          if (widget.post.tags.isNotEmpty)
            _buildTagsSection(),
          
          // Stats
          _buildStatsSection(),
          
          // Comments
          _buildCommentsSection(),
          
          SizedBox(height: AppleFitnessTheme.spacingXXL),
        ],
      ),
    );
  }

  Widget _buildAuthorSection() {
    return Padding(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      child: FadeIn3D(
        child: Card3D(
          useFrostedGlass: true,
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppleFitnessTheme.primaryGradient,
                ),
                child: CircleAvatar(
                        backgroundImage: NetworkImage(widget.post.user.avatar),
                      ),
              ),
              SizedBox(width: AppleFitnessTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.user.name,
                      style: AppleFitnessTheme.titleMedium,
                    ),
                    Text(
                      widget.post.timeAgo,
                      style: AppleFitnessTheme.bodySmall.copyWith(
                        color: AppleFitnessTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Button3D.primary(
                text: '关注',
                icon: Icons.add,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final images = widget.post.images!;
    
    return FadeIn3D(
      delay: const Duration(milliseconds: 100),
      child: Column(
        children: [
          SizedBox(
            height: 400,
            child: PageView.builder(
              controller: _imagePageController,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppleFitnessTheme.spacingL,
                  ),
                  child: Card3D(
                    elevation: 8,
                    child: Image.network(
                      images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          if (images.length > 1) ...[
            SizedBox(height: AppleFitnessTheme.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return AnimatedContainer(
                  duration: AppleFitnessTheme.durationFast,
                  width: _currentImageIndex == index ? 24 : 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(
                    horizontal: AppleFitnessTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    gradient: _currentImageIndex == index
                        ? AppleFitnessTheme.primaryGradient
                        : null,
                    color: _currentImageIndex == index
                        ? null
                        : AppleFitnessTheme.textTertiary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Padding(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      child: FadeIn3D(
        delay: const Duration(milliseconds: 200),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _likeScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _likeScale.value,
                  child: child,
                );
              },
              child: Button3D(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                backgroundColor: _isLiked
                    ? AppleFitnessTheme.primaryPink
                    : AppleFitnessTheme.backgroundSecondary,
                foregroundColor: _isLiked ? Colors.white : AppleFitnessTheme.textPrimary,
                enableGlow: _isLiked,
                onPressed: _toggleLike,
              ),
            ),
            SizedBox(width: AppleFitnessTheme.spacingM),
            Button3D(
              icon: Icons.comment,
              backgroundColor: AppleFitnessTheme.backgroundSecondary,
              foregroundColor: AppleFitnessTheme.textPrimary,
              onPressed: () {
                // Focus comment input
              },
            ),
            SizedBox(width: AppleFitnessTheme.spacingM),
            Button3D(
              icon: Icons.share,
              backgroundColor: AppleFitnessTheme.backgroundSecondary,
              foregroundColor: AppleFitnessTheme.textPrimary,
              onPressed: _sharePost,
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _bookmarkScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bookmarkScale.value,
                  child: child,
                );
              },
              child: Button3D(
                icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                backgroundColor: _isBookmarked
                    ? AppleFitnessTheme.primaryBlue
                    : AppleFitnessTheme.backgroundSecondary,
                foregroundColor: _isBookmarked ? Colors.white : AppleFitnessTheme.textPrimary,
                enableGlow: _isBookmarked,
                onPressed: _toggleBookmark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      child: FadeIn3D(
        delay: const Duration(milliseconds: 300),
        child: Card3D(
          useFrostedGlass: true,
          child: Text(
            widget.post.content,
            style: AppleFitnessTheme.bodyLarge,
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingL),
      child: FadeIn3D(
        delay: const Duration(milliseconds: 400),
        child: Wrap(
          spacing: AppleFitnessTheme.spacingS,
          runSpacing: AppleFitnessTheme.spacingS,
          children: widget.post.tags.map((tag) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppleFitnessTheme.spacingM,
                vertical: AppleFitnessTheme.spacingS,
              ),
              decoration: BoxDecoration(
                gradient: AppleFitnessTheme.primaryGradient,
                borderRadius: AppleFitnessTheme.radiusSmall,
              ),
              child: Text(
                tag,
                style: AppleFitnessTheme.labelMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      child: FadeIn3D(
        delay: const Duration(milliseconds: 500),
        child: Card3D(
          useFrostedGlass: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.favorite,
                count: _likeCount,
                label: '点赞',
              ),
              _buildStatItem(
                icon: Icons.comment,
                count: _commentCount,
                label: '评论',
              ),
              _buildStatItem(
                icon: Icons.share,
                count: widget.post.shares,
                label: '分享',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppleFitnessTheme.primaryBlue,
          size: 24,
        ),
        SizedBox(height: AppleFitnessTheme.spacingXS),
        Text(
          count.toString(),
          style: AppleFitnessTheme.titleLarge.copyWith(
            color: AppleFitnessTheme.primaryBlue,
          ),
        ),
        Text(
          label,
          style: AppleFitnessTheme.bodySmall.copyWith(
            color: AppleFitnessTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Padding(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '评论 ($_commentCount)',
            style: AppleFitnessTheme.titleLarge,
          ),
          SizedBox(height: AppleFitnessTheme.spacingM),
          ..._comments.asMap().entries.map((entry) {
            final index = entry.key;
            final comment = entry.value;
            return StaggeredAnimation3D(
              index: index,
              child: _buildCommentItem(comment),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment3D comment) {
    return Card3D(
      useFrostedGlass: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppleFitnessTheme.primaryGradient,
            ),
            child: comment.userAvatar != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(comment.userAvatar!),
                  )
                : const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          SizedBox(width: AppleFitnessTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: AppleFitnessTheme.labelLarge,
                    ),
                    SizedBox(width: AppleFitnessTheme.spacingS),
                    Text(
                      comment.time,
                      style: AppleFitnessTheme.bodySmall.copyWith(
                        color: AppleFitnessTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppleFitnessTheme.spacingXS),
                Text(
                  comment.content,
                  style: AppleFitnessTheme.bodyMedium,
                ),
                SizedBox(height: AppleFitnessTheme.spacingS),
                Row(
                  children: [
                    Icon(
                      comment.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: comment.isLiked
                          ? AppleFitnessTheme.primaryPink
                          : AppleFitnessTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comment.likes.toString(),
                      style: AppleFitnessTheme.bodySmall.copyWith(
                        color: AppleFitnessTheme.textSecondary,
                      ),
                    ),
                    SizedBox(width: AppleFitnessTheme.spacingM),
                    Text(
                      '回复',
                      style: AppleFitnessTheme.bodySmall.copyWith(
                        color: AppleFitnessTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
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
              child: Input3D(
                controller: _commentController,
                hint: '说点什么...',
                maxLines: 4,
                onSubmitted: (_) => _sendComment(),
              ),
            ),
            SizedBox(width: AppleFitnessTheme.spacingM),
            Button3D(
              icon: Icons.send,
              backgroundColor: _commentController.text.trim().isNotEmpty
                  ? AppleFitnessTheme.primaryBlue
                  : AppleFitnessTheme.backgroundSecondary,
              foregroundColor: _commentController.text.trim().isNotEmpty
                  ? Colors.white
                  : AppleFitnessTheme.textTertiary,
              enableGlow: _commentController.text.trim().isNotEmpty,
              onPressed: _sendComment,
            ),
          ],
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
          text: '分享',
          value: 'share',
          icon: Icons.share,
        ),
        ActionSheetOption(
          text: '复制链接',
          value: 'copy',
          icon: Icons.link,
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

  void _sharePost() {
    // TODO: Implement share
  }
}

/// Comment model for 3D post detail
class Comment3D {
  final String id;
  final String userName;
  final String? userAvatar;
  final String content;
  final String time;
  final int likes;
  bool isLiked;

  Comment3D({
    required this.id,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.time,
    required this.likes,
    this.isLiked = false,
  });
}

