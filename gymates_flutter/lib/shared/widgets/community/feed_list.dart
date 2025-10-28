import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/gymates_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/models/mock_data.dart';

/// 📱 动态列表 - FeedList
/// 
/// 基于Figma设计的社区动态列表组件
/// 显示用户发布的动态，支持点赞、评论、分享

class FeedList extends StatefulWidget {
  final List<MockPost> posts;

  const FeedList({
    super.key,
    required this.posts,
  });

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _itemAnimationController;
  
  late Animation<double> _listFadeAnimation;
  late Animation<double> _itemAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // 列表动画控制器
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 项目动画控制器
    _itemAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 列表淡入动画
    _listFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 项目动画
    _itemAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _itemAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    // 开始列表动画
    _listAnimationController.forward();
    
    // 延迟开始项目动画
    await Future.delayed(const Duration(milliseconds: 200));
    _itemAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _itemAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _listFadeAnimation.value,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.posts.length,
            itemBuilder: (context, index) {
              final post = widget.posts[index];
              final animationDelay = index * 0.1;
              
              return AnimatedBuilder(
                animation: _itemAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _itemAnimation.value)),
                    child: Opacity(
                      opacity: _itemAnimation.value,
                      child: _buildPostItem(post, index),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPostItem(MockPost post, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // 导航到帖子详情页
        AppRoutes.pushNamed(
          context,
          AppRoutes.postDetail,
          arguments: {
            'post': post,
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: index == widget.posts.length - 1 ? 0 : 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息
            _buildUserInfo(post),
            
            // 帖子内容
            _buildPostContent(post),
            
            // 互动按钮
            _buildInteractionButtons(post),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(MockPost post) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 用户头像
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showUserProfile(post.user);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(post.user.avatar),
                  fit: BoxFit.cover,
                ),
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
                  post.user.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  post.timeAgo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          
          // 关注按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _toggleFollow(post.user);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: post.user.isFollowing ? const Color(0xFFE5E7EB) : GymatesTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                post.user.isFollowing ? '已关注' : '关注',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: post.user.isFollowing ? const Color(0xFF6B7280) : Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 更多选项
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showMoreOptions(post);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.more_horiz,
                size: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(MockPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文字内容
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              height: 1.5,
            ),
          ),
          
          // 标签
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: post.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          // 图片
          if (post.image != null) ...[
            const SizedBox(height: 12),
            _buildPostImage(post.image!),
          ],
        ],
      ),
    );
  }

  Widget _buildPostImage(String imageUrl) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showImagePreview(imageUrl);
      },
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionButtons(MockPost post) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 点赞按钮
          _buildInteractionButton(
            post.isLiked ? Icons.favorite : Icons.favorite_border,
            post.likes.toString(),
            post.isLiked ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
            () => _toggleLike(post),
          ),
          
          const SizedBox(width: 24),
          
          // 评论按钮
          _buildInteractionButton(
            Icons.comment_outlined,
            post.comments.toString(),
            const Color(0xFF6B7280),
            () => _showComments(post),
          ),
          
          const SizedBox(width: 24),
          
          // 分享按钮
          _buildInteractionButton(
            Icons.share_outlined,
            post.shares.toString(),
            const Color(0xFF6B7280),
            () => _sharePost(post),
          ),
          
          const Spacer(),
          
          // 收藏按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _toggleBookmark(post);
            },
            child: Icon(
              post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 20,
              color: post.isBookmarked ? const Color(0xFF6366F1) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String count, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike(MockPost post) {
    setState(() {
      // 这里应该更新数据模型
      // post.isLiked = !post.isLiked;
      // post.likes += post.isLiked ? 1 : -1;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(post.isLiked ? '取消点赞' : '点赞成功'),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }

  void _toggleFollow(MockUser user) {
    setState(() {
      // 这里应该更新数据模型
      // user.isFollowing = !user.isFollowing;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(user.isFollowing ? '取消关注' : '关注成功'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _showUserProfile(MockUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 用户信息
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.avatar),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@${user.username}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProfileStat('关注', '${user.following}'),
                      _buildProfileStat('粉丝', '${user.followers}'),
                      _buildProfileStat('帖子', '${user.posts}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  void _showComments(MockPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 标题
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '评论 (${post.comments})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            
            // 评论列表
            Expanded(
              child: Center(
                child: Text(
                  '评论功能待实现',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost(MockPost post) {
    // 实现分享功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('分享帖子: ${post.content.substring(0, 20)}...'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _toggleBookmark(MockPost post) {
    setState(() {
      // 这里应该更新数据模型
      // post.isBookmarked = !post.isBookmarked;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(post.isBookmarked ? '取消收藏' : '收藏成功'),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }

  void _showMoreOptions(MockPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 选项
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOptionItem(Icons.report, '举报', () => _reportPost(post)),
                  _buildOptionItem(Icons.block, '屏蔽用户', () => _blockUser(post.user)),
                  _buildOptionItem(Icons.copy, '复制链接', () => _copyLink(post)),
                  _buildOptionItem(Icons.share, '分享到其他平台', () => _shareToOtherPlatforms(post)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6B7280)),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1F2937),
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // 图片
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            
            // 关闭按钮
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reportPost(MockPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('举报帖子'),
        content: const Text('请选择举报原因：'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('举报已提交，我们会尽快处理'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  void _blockUser(MockUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('屏蔽用户'),
        content: Text('确定要屏蔽 ${user.name} 吗？屏蔽后将不再看到该用户的帖子。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已屏蔽 ${user.name}'),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _copyLink(MockPost post) {
    // 复制链接到剪贴板
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('链接已复制到剪贴板'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _shareToOtherPlatforms(MockPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '分享到其他平台',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSharePlatform('微信', Icons.wechat, () {}),
                  _buildSharePlatform('微博', Icons.share, () {}),
                  _buildSharePlatform('QQ', Icons.share, () {}),
                  _buildSharePlatform('更多', Icons.more_horiz, () {}),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSharePlatform(String name, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享到$name'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
