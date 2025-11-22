import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/3d_components/index.dart';
import '../../core/animations/cartoon_3d_animations.dart' as cartoon_animations;
import '../../shared/models/mock_data.dart';
import '../../shared/widgets/community/post_card.dart';
import '../../services/community_service.dart';
import 'pages/create_3d_post_page.dart';
import 'pages/post_3d_detail_page.dart';

/// 🌟 Apple Fitness+ Style Community Page
/// 
/// Design Features:
/// - 3D tab bar (推荐/附近/活动)
/// - 3D post cards (infinite scroll)
/// - 3D floating create button
/// - Pull to refresh
/// - Smooth animations
/// - Complete interaction features (like, collect, follow, comment)

class CommunityMainPage3D extends StatefulWidget {
  const CommunityMainPage3D({super.key});

  @override
  State<CommunityMainPage3D> createState() => _CommunityMainPage3DState();
}

class _CommunityMainPage3DState extends State<CommunityMainPage3D>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityService _communityService = CommunityService();
  final ScrollController _scrollController = ScrollController();
  
  String _activeTab = 'recommend';
  List<CommunityPost> _posts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _handleTabChange(['recommend', 'nearby', 'gym'][_tabController.index]);
      }
    });
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMorePosts();
      }
    }
  }

  void _handleTabChange(String tab) {
    if (_activeTab == tab) return;
    
    HapticFeedback.lightImpact();
    setState(() {
      _activeTab = tab;
      _posts = [];
      _currentPage = 1;
      _hasMore = true;
    });
    _loadPosts();
  }

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
      
      final List<dynamic> postsData = response['data']?['posts'] ?? [];
      final List<CommunityPost> posts = postsData.map((json) {
        final user = json['user'] ?? {};
        final mediaUrls = _parseMediaUrls(json['images'] ?? json['media_urls'] ?? json['mediaUrls']);
        
        return CommunityPost(
          id: json['id'].toString(),
          userName: user['name'] ?? json['user_name'] ?? json['userName'] ?? '未知用户',
          userAvatar: user['avatar'] ?? json['user_avatar'] ?? json['userAvatar'] ?? '',
          userId: user['id'] ?? json['user_id'] ?? json['userId'] ?? 0,
          content: json['content'] ?? '',
          mediaUrls: mediaUrls,
          mediaType: mediaUrls.isEmpty ? 'text' : (mediaUrls.length == 1 ? 'image' : 'mixed'),
          tags: (json['tags'] ?? []).cast<String>(),
          likes: json['likes'] ?? 0,
          comments: json['comments'] ?? 0,
          collects: json['collects'] ?? json['collections'] ?? 0,
          shares: json['shares'] ?? 0,
          timestamp: _formatTimestamp(json['created_at'] ?? json['timestamp'] ?? ''),
          isLiked: json['is_liked'] ?? json['isLiked'] ?? false,
          isCollected: json['is_collected'] ?? json['isCollected'] ?? false,
          isFollowing: json['is_following'] ?? json['isFollowing'] ?? false,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
          _hasMore = response['data']?['pagination']?['has_more'] ?? (posts.length >= 10);
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading posts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _posts = [];
        });
        _showErrorSnackBar('加载失败: $e');
      }
    }
  }

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
      
      final List<dynamic> postsData = response['data']?['posts'] ?? [];
      final List<CommunityPost> newPosts = postsData.map((json) {
        final user = json['user'] ?? {};
        final mediaUrls = _parseMediaUrls(json['images'] ?? json['media_urls'] ?? json['mediaUrls']);
        
        return CommunityPost(
          id: json['id'].toString(),
          userName: user['name'] ?? json['user_name'] ?? json['userName'] ?? '未知用户',
          userAvatar: user['avatar'] ?? json['user_avatar'] ?? json['userAvatar'] ?? '',
          userId: user['id'] ?? json['user_id'] ?? json['userId'] ?? 0,
          content: json['content'] ?? '',
          mediaUrls: mediaUrls,
          mediaType: mediaUrls.isEmpty ? 'text' : (mediaUrls.length == 1 ? 'image' : 'mixed'),
          tags: (json['tags'] ?? []).cast<String>(),
          likes: json['likes'] ?? 0,
          comments: json['comments'] ?? 0,
          collects: json['collects'] ?? json['collections'] ?? 0,
          shares: json['shares'] ?? 0,
          timestamp: _formatTimestamp(json['created_at'] ?? json['timestamp'] ?? ''),
          isLiked: json['is_liked'] ?? json['isLiked'] ?? false,
          isCollected: json['is_collected'] ?? json['isCollected'] ?? false,
          isFollowing: json['is_following'] ?? json['isFollowing'] ?? false,
        );
      }).toList();
      
      if (mounted) {
        setState(() {
          _posts.addAll(newPosts);
          _isLoadingMore = false;
          _hasMore = response['data']?['pagination']?['has_more'] ?? (newPosts.length >= 10);
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading more posts: $e');
      if (mounted) {
        setState(() {
          _currentPage--;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _handleLike(CommunityPost post) async {
    final postId = int.tryParse(post.id);
    if (postId == null) return;

    HapticFeedback.lightImpact();

    try {
      final isLiked = post.isLiked;
      final success = isLiked 
          ? await _communityService.unlikePost(postId)
          : await _communityService.likePost(postId);
      
      if (success && mounted) {
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
      debugPrint('❌ Error liking post: $e');
      if (mounted) {
        _showErrorSnackBar('操作失败: $e');
      }
    }
  }

  Future<void> _handleCollect(CommunityPost post) async {
    final postId = int.tryParse(post.id);
    if (postId == null) return;

    HapticFeedback.mediumImpact();

    try {
      final isCollected = post.isCollected;
      final success = isCollected
          ? await _communityService.uncollectPost(postId)
          : await _communityService.collectPost(postId);
      
      if (success && mounted) {
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
              isCollected: !isCollected,
              isFollowing: post.isFollowing,
            );
          }
        });
        _showSuccessSnackBar(isCollected ? '已取消收藏' : '已收藏');
      }
    } catch (e) {
      debugPrint('❌ Error collecting post: $e');
      if (mounted) {
        _showErrorSnackBar('操作失败: $e');
      }
    }
  }

  Future<void> _handleFollow(CommunityPost post) async {
    HapticFeedback.mediumImpact();

    try {
      final isFollowing = post.isFollowing;
      final success = isFollowing
          ? await _communityService.unfollowUser(post.userId)
          : await _communityService.followUser(post.userId);
      
      if (success && mounted) {
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
      }
    } catch (e) {
      debugPrint('❌ Error following user: $e');
      if (mounted) {
        _showErrorSnackBar('操作失败: $e');
      }
    }
  }

  void _handleComment(CommunityPost post) {
    HapticFeedback.lightImpact();
    context.push3D(Post3DDetailPage(post: post));
  }

  void _handleShare(CommunityPost post) {
    HapticFeedback.lightImpact();
    // TODO: Implement share
    _showInfoSnackBar('分享功能开发中');
  }

  void _handlePostTap(CommunityPost post) {
    HapticFeedback.lightImpact();
    context.push3D(Post3DDetailPage(post: post));
  }

  void _handleMoreOptions(CommunityPost post) async {
    HapticFeedback.mediumImpact();
    final result = await showActionSheet3D<String>(
      context: context,
      title: '更多操作',
      options: [
        ActionSheetOption(
          text: post.isFollowing ? '取消关注' : '关注',
          value: 'follow',
          icon: Icons.person_add,
        ),
        ActionSheetOption(
          text: '分享',
          value: 'share',
          icon: Icons.share,
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
    
    if (result != null && result != 'cancel') {
      if (result == 'follow') {
        _handleFollow(post);
      } else if (result == 'share') {
        _handleShare(post);
      } else if (result == 'report') {
        // Handle report
      }
    }
  }

  void _handlePublishPost(Map<String, dynamic> postData) {
    _showSuccessSnackBar('发布成功！🎉');
    _loadPosts();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppleFitnessTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppleFitnessTheme.radiusMedium,
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppleFitnessTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppleFitnessTheme.radiusMedium,
        ),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppleFitnessTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppleFitnessTheme.radiusMedium,
        ),
      ),
    );
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
            _buildAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadPosts,
                child: _isLoading && _posts.isEmpty
                    ? Center(
                        child: CircularProgress3D(
                          value: 0.0,
                          size: 60,
                          progressColor: AppleFitnessTheme.primaryBlue,
                          showPercentage: false,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                        itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _posts.length) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                                child: CircularProgress3D(
                                  value: 0.0,
                                  size: 40,
                                  progressColor: AppleFitnessTheme.primaryBlue,
                                  showPercentage: false,
                                ),
                              ),
                            );
                          }
                          return cartoon_animations.SlideInAnimation(
                            direction: cartoon_animations.SlideDirection.fromBottom,
                            delay: Duration(milliseconds: index * 50),
                            child: PostCard(
                              post: _posts[index],
                              onLike: () => _handleLike(_posts[index]),
                              onComment: () => _handleComment(_posts[index]),
                              onCollect: () => _handleCollect(_posts[index]),
                              onFollow: () => _handleFollow(_posts[index]),
                              onTap: () => _handlePostTap(_posts[index]),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Button3D.floating(
        icon: Icons.add,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Create3DPostPage(
                postType: 'moment',
                onPublish: null,
              ),
            ),
          ).then((result) {
            if (result != null) {
              _handlePublishPost(result as Map<String, dynamic>);
            }
          });
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return cartoon_animations.BounceInAnimation(
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        decoration: BoxDecoration(
          color: AppleFitnessTheme.backgroundPrimary,
          boxShadow: AppleFitnessTheme.softShadow(elevation: 2),
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(28),
            bottomRight: const Radius.circular(28),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title with gradient (from old design)
                  ShaderMask(
                    shaderCallback: (bounds) => AppleFitnessTheme.primaryGradient.createShader(bounds),
                    child: const Text(
                      '🌟 社区',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Search button (from old design)
                  Button3D.icon(
                    icon: Icons.search_rounded,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // 显示搜索对话框（暂时使用对话框，后续可以创建独立搜索页面）
                      showSearch(
                        context: context,
                        delegate: _CommunitySearchDelegate(_posts),
                      );
                    },
                    size: Button3DSize.medium,
                  ),
                ],
              ),
              SizedBox(height: AppleFitnessTheme.spacingL),
              // 3D Tab navigation (from old design)
              _build3DTabs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DTabs() {
    final tabs = [
      {'id': 'recommend', 'label': '推荐', 'icon': '🔥'},
      {'id': 'nearby', 'label': '附近', 'icon': '📍'},
      {'id': 'gym', 'label': '健身房', 'icon': '🏋️'},
    ];

    return Row(
      children: tabs.map((tab) {
        final isActive = _activeTab == tab['id'];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingXS / 2),
            child: cartoon_animations.SlideInAnimation(
              direction: cartoon_animations.SlideDirection.fromBottom,
              delay: Duration(milliseconds: 100 + (tabs.indexOf(tab) * 100)),
              child: GestureDetector(
                onTap: () => _handleTabChange(tab['id']!),
                child: AnimatedContainer(
                  duration: AppleFitnessTheme.durationNormal,
                  curve: AppleFitnessTheme.easeInOutCubic,
                  padding: EdgeInsets.symmetric(
                    vertical: AppleFitnessTheme.spacingM,
                  ),
                  decoration: BoxDecoration(
                    gradient: isActive 
                        ? AppleFitnessTheme.primaryGradient
                        : null,
                    color: isActive ? null : AppleFitnessTheme.backgroundSecondary,
                    borderRadius: AppleFitnessTheme.radiusMedium,
                    boxShadow: isActive ? AppleFitnessTheme.softShadow(elevation: 4) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tab['icon']!,
                        style: const TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: AppleFitnessTheme.spacingXS),
                      Text(
                        tab['label']!,
                        style: AppleFitnessTheme.bodyMedium.copyWith(
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                          color: isActive ? Colors.white : AppleFitnessTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 社区搜索委托类
class _CommunitySearchDelegate extends SearchDelegate<CommunityPost?> {
  final List<CommunityPost> _posts;

  _CommunitySearchDelegate(this._posts);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _posts.where((post) {
      return post.content.toLowerCase().contains(query.toLowerCase()) ||
          post.userName.toLowerCase().contains(query.toLowerCase()) ||
          post.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '未找到相关内容',
              style: AppleFitnessTheme.bodyLarge.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final post = results[index];
        return PostCard(
          post: post,
          onTap: () {
            close(context, post);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Post3DDetailPage(post: post),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const SizedBox.shrink();
    }

    final suggestions = _posts.where((post) {
      return post.content.toLowerCase().contains(query.toLowerCase()) ||
          post.userName.toLowerCase().contains(query.toLowerCase()) ||
          post.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).take(5).toList();

    return ListView.builder(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final post = suggestions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: post.userAvatar.isNotEmpty
                ? NetworkImage(post.userAvatar)
                : null,
            child: post.userAvatar.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(post.userName),
          subtitle: Text(
            post.content.length > 50
                ? '${post.content.substring(0, 50)}...'
                : post.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            query = post.content;
            showResults(context);
          },
        );
      },
    );
  }
}


