import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../shared/widgets/community/feed_tabs.dart';
import '../../shared/widgets/community/post_card.dart';
import '../../shared/widgets/community/create_post_button.dart';
import '../../shared/models/mock_data.dart';
import '../../services/community_service.dart';
import 'create_post_page.dart';

/// 🌟 CommunityPage - 社交健身动态广场
/// 
/// 功能特性：
/// - 三个Tab：推荐/附近动态/健身房活动
/// - 无限滚动加载 + 下拉刷新
/// - 浮动发帖按钮 (渐变圆形按钮)
/// - 完整的互动功能（点赞、评论、收藏、关注）
/// - 位置服务集成（附近Tab显示距离）
/// - Glassmorphism 设计风格
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final CommunityService _communityService = CommunityService();
  final ScrollController _scrollController = ScrollController();
  
  String _activeTab = 'recommend'; // 默认推荐Tab
  List<CommunityPost> _posts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 解析媒体URL（可能是字符串或数组）
  List<String> _parseMediaUrls(dynamic media) {
    if (media == null) return [];
    if (media is String) return media.isEmpty ? [] : [media];
    if (media is List) return media.cast<String>();
    return [];
  }

  /// 格式化时间戳
  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dateTime);
      
      if (diff.inMinutes < 1) return '刚刚';
      if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
      if (diff.inDays < 1) return '${diff.inHours}小时前';
      if (diff.inDays < 7) return '${diff.inDays}天前';
      return '${dateTime.month}月${dateTime.day}日';
    } catch (e) {
      return timestamp;
    }
  }

  /// 监听滚动事件，实现无限加载
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMorePosts();
      }
    }
  }

  /// 加载帖子列表
  Future<void> _loadPosts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      final response = await _communityService.getPosts(
        tab: _activeTab,
        page: _currentPage,
        limit: 10,
      );
      
      // 修复：后端返回 data.posts，不是直接 data
      final List<dynamic> postsData = response['data']['posts'] ?? [];
      final List<CommunityPost> posts = postsData.map((json) {
        // 处理用户信息（可能在 user 对象中）
        final user = json['user'] ?? {};
        
        return CommunityPost(
          id: json['id'].toString(),
          userName: user['name'] ?? json['user_name'] ?? json['userName'] ?? '未知用户',
          userAvatar: user['avatar'] ?? json['user_avatar'] ?? json['userAvatar'] ?? '',
          userId: user['id'] ?? json['user_id'] ?? json['userId'] ?? 0,
          content: json['content'] ?? '',
          mediaUrls: _parseMediaUrls(json['images'] ?? json['media_urls'] ?? json['mediaUrls']),
          mediaType: json['type'] ?? json['media_type'] ?? json['mediaType'] ?? 'text',
          tags: (json['tags'] ?? []).cast<String>(),
          likes: json['likes'] ?? 0,
          comments: json['comments'] ?? 0,
          collects: json['collects'] ?? 0,
          shares: json['shares'] ?? 0,
          timestamp: _formatTimestamp(json['created_at'] ?? json['timestamp'] ?? ''),
          isLiked: json['is_liked'] ?? json['isLiked'] ?? false,
          isCollected: json['is_collected'] ?? json['isCollected'] ?? false,
          isFollowing: json['is_following'] ?? json['isFollowing'] ?? false,
        );
      }).toList();

      setState(() {
        _posts = posts;
        _isLoading = false;
        _hasMore = response['data']['pagination']?['has_more'] ?? (posts.length >= 10);
      });
    } catch (e) {
      print('❌ Error loading posts: $e');
      setState(() {
        _isLoading = false;
        _posts = [];
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 加载更多帖子
  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final response = await _communityService.getPosts(
        tab: _activeTab,
        page: _currentPage,
        limit: 10,
      );
      
      // 修复：后端返回 data.posts，不是直接 data
      final List<dynamic> postsData = response['data']['posts'] ?? [];
      final List<CommunityPost> newPosts = postsData.map((json) {
        // 处理用户信息（可能在 user 对象中）
        final user = json['user'] ?? {};
        
        return CommunityPost(
          id: json['id'].toString(),
          userName: user['name'] ?? json['user_name'] ?? json['userName'] ?? '未知用户',
          userAvatar: user['avatar'] ?? json['user_avatar'] ?? json['userAvatar'] ?? '',
          userId: user['id'] ?? json['user_id'] ?? json['userId'] ?? 0,
          content: json['content'] ?? '',
          mediaUrls: _parseMediaUrls(json['images'] ?? json['media_urls'] ?? json['mediaUrls']),
          mediaType: json['type'] ?? json['media_type'] ?? json['mediaType'] ?? 'text',
          tags: (json['tags'] ?? []).cast<String>(),
          likes: json['likes'] ?? 0,
          comments: json['comments'] ?? 0,
          collects: json['collects'] ?? 0,
          shares: json['shares'] ?? 0,
          timestamp: _formatTimestamp(json['created_at'] ?? json['timestamp'] ?? ''),
          isLiked: json['is_liked'] ?? json['isLiked'] ?? false,
          isCollected: json['is_collected'] ?? json['isCollected'] ?? false,
          isFollowing: json['is_following'] ?? json['isFollowing'] ?? false,
        );
      }).toList();
      
      setState(() {
        _posts.addAll(newPosts);
        _isLoadingMore = false;
        _hasMore = response['data']['pagination']?['has_more'] ?? (newPosts.length >= 10);
      });
    } catch (e) {
      print('❌ Error loading more posts: $e');
      setState(() {
        _currentPage--; // 回退页码
        _isLoadingMore = false;
      });
    }
  }

  /// 下拉刷新
  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    await _loadPosts();
  }

  /// 切换Tab
  void _handleTabChange(String tab) {
    if (_activeTab == tab) return;
    
    setState(() {
      _activeTab = tab;
      _posts = [];
    });
    
    _loadPosts();
  }

  /// 处理发帖
  void _handleCreatePost(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostPage(
          postType: type,
          onBack: () => Navigator.pop(context),
          onPublish: _handlePublishPost,
        ),
      ),
    );
  }

  /// 发布帖子
  void _handlePublishPost(Map<String, dynamic> postData) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('发布成功！'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
    
    // 刷新列表
    _handleRefresh();
  }

  /// 处理点赞
  Future<void> _handleLike(CommunityPost post) async {
    final postId = int.tryParse(post.id);
    if (postId == null) return;

    try {
      final isLiked = post.isLiked;
      final success = isLiked 
          ? await _communityService.unlikePost(postId)
          : await _communityService.likePost(postId);
      
      if (success) {
        setState(() {
          final index = _posts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            _posts[index] = CommunityPost(
              id: post.id,
              userName: post.userName,
              userAvatar: post.userAvatar,
              userId: post.userId,
              content: post.content,
              mediaUrls: post.mediaUrls,
              mediaType: post.mediaType,
              tags: post.tags,
              likes: isLiked ? post.likes - 1 : post.likes + 1,
              comments: post.comments,
              collects: post.collects,
              shares: post.shares,
              timestamp: post.timestamp,
              isLiked: !isLiked,
              isCollected: post.isCollected,
              isFollowing: post.isFollowing,
            );
          }
        });
      }
    } catch (e) {
      print('❌ Error liking post: $e');
    }
  }

  /// 处理评论
  void _handleComment(CommunityPost post) {
    // TODO: 打开评论页面
    print('Comment on post: ${post.id}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('查看 ${post.userName} 的帖子评论'),
        action: SnackBarAction(
          label: '关闭',
          onPressed: () {},
        ),
      ),
    );
  }

  /// 处理收藏
  Future<void> _handleCollect(CommunityPost post) async {
    final postId = int.tryParse(post.id);
    if (postId == null) return;

    try {
      final isCollected = post.isCollected;
      final success = isCollected
          ? await _communityService.uncollectPost(postId)
          : await _communityService.collectPost(postId);
      
      if (success) {
        setState(() {
          final index = _posts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            _posts[index] = CommunityPost(
              id: post.id,
              userName: post.userName,
              userAvatar: post.userAvatar,
              userId: post.userId,
              content: post.content,
              mediaUrls: post.mediaUrls,
              mediaType: post.mediaType,
              tags: post.tags,
              likes: post.likes,
              comments: post.comments,
              collects: isCollected ? post.collects - 1 : post.collects + 1,
              shares: post.shares,
              timestamp: post.timestamp,
              isLiked: post.isLiked,
              isCollected: !isCollected,
              isFollowing: post.isFollowing,
            );
          }
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isCollected ? '取消收藏' : '已收藏'),
              backgroundColor: GymatesTheme.primaryColor,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error collecting post: $e');
    }
  }

  /// 处理关注
  Future<void> _handleFollow(CommunityPost post) async {
    try {
      final isFollowing = post.isFollowing;
      final success = isFollowing
          ? await _communityService.unfollowUser(post.userId)
          : await _communityService.followUser(post.userId);
      
      if (success) {
        setState(() {
          final index = _posts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            _posts[index] = CommunityPost(
              id: post.id,
              userName: post.userName,
              userAvatar: post.userAvatar,
              userId: post.userId,
              content: post.content,
              mediaUrls: post.mediaUrls,
              mediaType: post.mediaType,
              tags: post.tags,
              likes: post.likes,
              comments: post.comments,
              collects: post.collects,
              shares: post.shares,
              timestamp: post.timestamp,
              isLiked: post.isLiked,
              isCollected: post.isCollected,
              isFollowing: !isFollowing,
            );
          }
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFollowing ? '已取消关注' : '已关注 ${post.userName}'),
              backgroundColor: GymatesTheme.primaryColor,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error following user: $e');
    }
  }

  /// 处理帖子点击
  void _handlePostTap(CommunityPost post) {
    // TODO: 打开帖子详情页
    print('Open post detail: ${post.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 头部
                _buildHeader(),
                
                // 内容区
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
            
            // 浮动发帖按钮
            CreatePostButton(
              onCreatePost: _handleCreatePost,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '社区',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: GymatesTheme.lightTextPrimary,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              // 搜索按钮
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: 打开搜索页面
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.search,
                    size: 22,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Tab导航
          FeedTabs(
            activeTab: _activeTab,
            onTabChange: _handleTabChange,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _posts.isEmpty) {
      return _buildLoadingState();
    }

    if (_posts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: GymatesTheme.primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return _buildLoadingMoreIndicator();
          }

          return PostCard(
            post: _posts[index],
            onLike: () => _handleLike(_posts[index]),
            onComment: () => _handleComment(_posts[index]),
            onCollect: () => _handleCollect(_posts[index]),
            onFollow: () => _handleFollow(_posts[index]),
            onTap: () => _handlePostTap(_posts[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: GymatesTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            '加载中...',
            style: TextStyle(
              fontSize: 14,
              color: GymatesTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String hint;
    IconData icon;
    
    switch (_activeTab) {
      case 'recommend':
        message = '暂无推荐内容';
        hint = '下拉刷新或关注更多健身达人';
        icon = Icons.explore_outlined;
        break;
      case 'nearby':
        message = '附近暂无动态';
        hint = '成为第一个在这里分享健身成果的人';
        icon = Icons.location_on_outlined;
        break;
      case 'gym':
        message = '附近暂无健身房活动';
        hint = '探索更多健身房或组织活动';
        icon = Icons.fitness_center_outlined;
        break;
      default:
        message = '暂无内容';
        hint = '下拉刷新试试';
        icon = Icons.inbox_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: GymatesTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: GymatesTheme.glowShadow,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: GymatesTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              hint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: GymatesTheme.lightTextSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: _hasMore
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: GymatesTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '加载更多...',
                  style: TextStyle(
                    fontSize: 14,
                    color: GymatesTheme.lightTextSecondary,
                  ),
                ),
              ],
            )
          : Text(
              '没有更多内容了',
              style: TextStyle(
                fontSize: 14,
                color: GymatesTheme.lightTextSecondary,
              ),
            ),
    );
  }
}

