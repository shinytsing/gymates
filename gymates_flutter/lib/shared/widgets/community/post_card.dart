import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/gymates_theme.dart';
import '../../../shared/models/mock_data.dart';

/// 📄 PostCard - 社区帖子卡片组件
/// 
/// 功能：
/// - 用户头像、昵称、发布时间
/// - 帖子内容（文本/图片/视频）
/// - 标签显示
/// - 互动按钮（点赞、评论、收藏、关注）
/// - 支持多种内容类型
class PostCard extends StatefulWidget {
  final CommunityPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onCollect;
  final VoidCallback? onFollow;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onCollect,
    this.onFollow,
    this.onTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    HapticFeedback.lightImpact();
    setState(() {
      _isLiked = !_isLiked;
    });
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    widget.onLike?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息栏
            _buildUserHeader(),

            // 帖子内容
            _buildContent(),

            // 媒体内容（图片/视频）
            if (widget.post.mediaUrls.isNotEmpty) _buildMediaPreview(),

            // 标签
            if (widget.post.tags.isNotEmpty) _buildTags(),

            // 互动栏
            _buildInteractionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 用户头像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(widget.post.userAvatar),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: GymatesTheme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.userName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      widget.post.timestamp,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    if (widget.post.distance != null) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        widget.post.distance!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 关注按钮
          if (!widget.post.isFollowing)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onFollow?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: GymatesTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '关注',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.post.content,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Color(0xFF374151),
        ),
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMediaPreview() {
    final mediaCount = widget.post.mediaUrls.length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: mediaCount == 1
            ? _buildSingleMedia(widget.post.mediaUrls.first)
            : _buildMediaGrid(),
      ),
    );
  }

  Widget _buildSingleMedia(String url) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFF3F4F6),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Color(0xFFD1D5DB),
                  ),
                ),
              );
            },
          ),
          if (widget.post.mediaType == 'video')
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    final urls = widget.post.mediaUrls.take(4).toList();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: urls.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              urls[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFF3F4F6),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 32,
                    color: Color(0xFFD1D5DB),
                  ),
                );
              },
            ),
            if (index == 3 && widget.post.mediaUrls.length > 4)
              Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Text(
                    '+${widget.post.mediaUrls.length - 4}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.post.tags.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: GymatesTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '#$tag',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: GymatesTheme.primaryColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInteractionBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 点赞
          Expanded(
            child: _buildInteractionButton(
              icon: _isLiked ? Icons.favorite : Icons.favorite_border,
              label: _formatCount(widget.post.likes + (_isLiked ? 1 : 0)),
              color: _isLiked ? Colors.red : const Color(0xFF6B7280),
              onTap: _handleLike,
              animation: _likeAnimation,
            ),
          ),

          // 评论
          Expanded(
            child: _buildInteractionButton(
              icon: Icons.chat_bubble_outline,
              label: _formatCount(widget.post.comments),
              color: const Color(0xFF6B7280),
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onComment?.call();
              },
            ),
          ),

          // 收藏
          Expanded(
            child: _buildInteractionButton(
              icon: widget.post.isCollected
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              label: _formatCount(widget.post.collects),
              color: widget.post.isCollected
                  ? GymatesTheme.primaryColor
                  : const Color(0xFF6B7280),
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onCollect?.call();
              },
            ),
          ),

          // 分享
          Expanded(
            child: _buildInteractionButton(
              icon: Icons.share_outlined,
              label: _formatCount(widget.post.shares),
              color: const Color(0xFF6B7280),
              onTap: () {
                HapticFeedback.lightImpact();
                // TODO: 实现分享功能
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    Animation<double>? animation,
  }) {
    Widget iconWidget = Icon(icon, size: 20, color: color);
    
    if (animation != null) {
      iconWidget = ScaleTransition(
        scale: animation,
        child: iconWidget,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}w';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

