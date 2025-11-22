import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/3d_components/index.dart';
import '../../core/animations/cartoon_3d_animations.dart' as cartoon_animations;
import '../../models/mate_models.dart';
import '../../models/gym_models.dart';
import '../../services/mate_service.dart';
import '../../services/map_service.dart';
import '../../services/unified_auth_service.dart';
import '../../widgets/partner_card.dart';
import '../../widgets/gym_card.dart';
import '../../widgets/filter_panel.dart';
import 'pages/mate_3d_detail_page.dart';
import '../../../pages/chat/chat_3d_room_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// 🔥 Apple Fitness+ Style Mates Page
/// 
/// Design Features:
/// - 3D swipeable cards (Tinder-style)
/// - 3D action buttons (reject, super like, like)
/// - 3D gym map tab
/// - Filter panel
/// - Location services
/// - Smooth swipe animations

class MatesMainPage3D extends StatefulWidget {
  const MatesMainPage3D({super.key});

  @override
  State<MatesMainPage3D> createState() => _MatesMainPage3DState();
}

class _MatesMainPage3DState extends State<MatesMainPage3D>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UnifiedAuthService _authService = UnifiedAuthService();
  late MateService _mateService;
  final MapService _mapService = MapService();
  final PageController _cardController = PageController();
  
  // 搭子推荐相关
  List<MateProfile> _mates = [];
  bool _isLoadingMates = false;
  MateFilterOptions _filterOptions = MateFilterOptions();
  
  // 健身房相关
  List<Gym> _gyms = [];
  bool _isLoadingGyms = false;
  double _currentLat = 39.9357; // 默认位置（北京三里屯）
  double _currentLng = 116.4475;
  int _gymSearchRadius = 3000;
  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initServices();
    _getUserLocation();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    HapticFeedback.lightImpact();
    if (_tabController.index == 1 && _gyms.isEmpty) {
      _loadNearbyGyms();
    }
  }

  // 初始化服务（获取token）
  Future<void> _initServices() async {
    try {
      final token = await _authService.getAccessToken();
      if (token != null) {
        setState(() {
          _mateService = MateService(token: token);
        });
        _loadMateRecommendations();
      } else {
        _mateService = MateService();
      }
    } catch (e) {
      debugPrint('❌ 初始化服务失败: $e');
      _mateService = MateService();
    }
  }

  // 获取用户位置
  Future<void> _getUserLocation() async {
    try {
      // 检查权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }

      // 获取位置
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentLat = position.latitude;
          _currentLng = position.longitude;
        });

        // 重新加载附近的健身房
        if (_tabController.index == 1) {
          _loadNearbyGyms();
        }
      }
    } catch (e) {
      debugPrint('获取位置失败: $e');
    }
  }

  // 加载搭子推荐
  Future<void> _loadMateRecommendations() async {
    setState(() {
      _isLoadingMates = true;
    });

    try {
      final response = await _mateService.getMateRecommendations(
        filterOptions: _filterOptions,
      );

      if (mounted) {
        setState(() {
          _mates = response.recommendations;
          _isLoadingMates = false;
        });
      }
    } catch (e) {
      debugPrint('❌ 加载推荐搭子失败: $e');
      if (mounted) {
        setState(() {
          _isLoadingMates = false;
        });
        _showError('加载推荐搭子失败: $e');
      }
    }
  }

  // 加载附近健身房
  Future<void> _loadNearbyGyms() async {
    setState(() {
      _isLoadingGyms = true;
    });

    try {
      final response = await _mapService.searchNearbyGyms(
        latitude: _currentLat,
        longitude: _currentLng,
        radius: _gymSearchRadius,
      );

      if (response['success'] == true && response['gyms'] != null) {
        if (mounted) {
          setState(() {
            _gyms = (response['gyms'] as List)
                .map((json) => Gym.fromJson(json))
                .toList();
            _isLoadingGyms = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingGyms = false);
        }
      }
    } catch (e) {
      debugPrint('❌ 加载健身房失败: $e');
      if (mounted) {
        setState(() => _isLoadingGyms = false);
        _showError('加载健身房失败: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
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

  void _showSuccess(String message) {
    if (!mounted) return;
    HapticFeedback.lightImpact();
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

  void _showFilterPanel() {
    HapticFeedback.mediumImpact();
    showModal3D(
      context: context,
      child: FilterPanel(
        initialFilters: _filterOptions,
        onApply: (filters) {
          setState(() {
            _filterOptions = filters;
          });
          Navigator.pop(context);
          _loadMateRecommendations();
        },
        onReset: () {
          setState(() {
            _filterOptions = MateFilterOptions();
          });
        },
      ),
    );
  }

  void _showGymRadiusSelector() {
    HapticFeedback.mediumImpact();
    showModal3D(
      context: context,
      child: Container(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        decoration: BoxDecoration(
          color: AppleFitnessTheme.backgroundPrimary,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: AppleFitnessTheme.spacingL),
              decoration: BoxDecoration(
                color: AppleFitnessTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '搜索范围',
              style: AppleFitnessTheme.titleLarge,
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            _buildRadiusOption(1000, '1公里', '🏃'),
            _buildRadiusOption(3000, '3公里', '🚴'),
            _buildRadiusOption(5000, '5公里', '🚗'),
            SizedBox(height: AppleFitnessTheme.spacingL),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusOption(int radius, String label, String emoji) {
    final isSelected = _gymSearchRadius == radius;
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(label, style: AppleFitnessTheme.bodyMedium),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppleFitnessTheme.primaryBlue)
          : null,
      onTap: () {
        setState(() => _gymSearchRadius = radius);
        Navigator.pop(context);
        _loadNearbyGyms();
      },
    );
  }

  Future<void> _handleSwipe(String action, MateProfile mate) async {
    try {
      switch (action) {
        case 'reject':
          // 拒绝操作：直接跳过，不发送请求
          break;
        case 'like':
          await _mateService.sendMateRequest(mate.id);
          _showSuccess('已发送搭子请求');
          break;
        case 'super_like':
          // 超级喜欢：发送普通请求（API不支持isSuperLike参数）
          await _mateService.sendMateRequest(mate.id);
          _showSuccess('已发送超级喜欢');
          break;
      }
    } catch (e) {
      _showError('操作失败: $e');
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
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMatesTab(),
                  _buildGymMapTab(),
                ],
              ),
            ),
          ],
        ),
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
                  // Title (from old design)
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppleFitnessTheme.spacingS),
                        decoration: BoxDecoration(
                          gradient: AppleFitnessTheme.purpleGradient,
                          borderRadius: AppleFitnessTheme.radiusMedium,
                          boxShadow: AppleFitnessTheme.softShadow(elevation: 2),
                        ),
                        child: const Text(
                          '👥',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      SizedBox(width: AppleFitnessTheme.spacingM),
                      Text(
                        '找搭子',
                        style: AppleFitnessTheme.displaySmall,
                      ),
                    ],
                  ),
                  // Filter button (from old design)
                  Button3D.icon(
                    icon: Icons.tune_rounded,
                    onPressed: _showFilterPanel,
                    size: Button3DSize.medium,
                  ),
                ],
              ),
              SizedBox(height: AppleFitnessTheme.spacingL),
              // 3D Tab切换 (from old design)
              _build3DTabs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DTabs() {
    return Container(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingXS / 2),
      decoration: BoxDecoration(
        color: AppleFitnessTheme.backgroundSecondary,
        borderRadius: AppleFitnessTheme.radiusMedium,
      ),
      child: Row(
        children: [
          _build3DTabButton(0, '搭子推荐', '💪', AppleFitnessTheme.primaryGradient),
          _build3DTabButton(1, '附近健身房', '🏋️', AppleFitnessTheme.purpleGradient),
        ],
      ),
    );
  }
  
  Widget _build3DTabButton(int index, String label, String emoji, LinearGradient gradient) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: cartoon_animations.SlideInAnimation(
        direction: cartoon_animations.SlideDirection.fromBottom,
        delay: Duration(milliseconds: 100 + (index * 100)),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _tabController.animateTo(index);
          },
          child: AnimatedContainer(
            duration: AppleFitnessTheme.durationNormal,
            curve: AppleFitnessTheme.easeInOutCubic,
            padding: EdgeInsets.symmetric(vertical: AppleFitnessTheme.spacingM),
            decoration: BoxDecoration(
              gradient: isSelected ? gradient : null,
              borderRadius: AppleFitnessTheme.radiusMedium,
              boxShadow: isSelected ? AppleFitnessTheme.softShadow(elevation: 4) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                SizedBox(width: AppleFitnessTheme.spacingXS),
                Text(
                  label,
                  style: AppleFitnessTheme.bodyMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppleFitnessTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildMatesTab() {
    if (_isLoadingMates) {
      return _buildLoadingState('正在寻找合适的搭子...', '🔍');
    }

    if (_mates.isEmpty) {
      return _buildEmptyState(
        emoji: '😔',
        title: '暂无推荐搭子',
        message: '试试调整筛选条件',
        actionLabel: '调整筛选',
        actionIcon: Icons.tune_rounded,
        onAction: _showFilterPanel,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMateRecommendations,
      color: AppleFitnessTheme.primaryBlue,
      child: ListView.builder(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        itemCount: _mates.length,
        itemBuilder: (context, index) {
          final mate = _mates[index];
          return cartoon_animations.SlideInAnimation(
            direction: cartoon_animations.SlideDirection.fromBottom,
            delay: Duration(milliseconds: index * 50),
            child: PartnerCard(
              mate: mate,
              onLike: () => _handleSwipe('like', mate),
              onPass: () => _handleSwipe('reject', mate),
              onMessage: () {
                // 跳转到聊天页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Chat3DRoomPage(
                      recipientId: mate.id.toString(),
                      recipientName: mate.name,
                      recipientAvatar: mate.avatar,
                    ),
                  ),
                );
              },
              onTap: () {
                context.push3D(Mate3DDetailPage(mate: mate));
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(String message, String emoji) {
    return cartoon_animations.BounceInAnimation(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cartoon_animations.PulseAnimation(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppleFitnessTheme.purpleGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppleFitnessTheme.softShadow(elevation: 8),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Text(
              message,
              style: AppleFitnessTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppleFitnessTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String emoji,
    required String title,
    required String message,
    required String actionLabel,
    required IconData actionIcon,
    required VoidCallback onAction,
  }) {
    return cartoon_animations.BounceInAnimation(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppleFitnessTheme.purpleGradient,
                shape: BoxShape.circle,
                boxShadow: AppleFitnessTheme.softShadow(elevation: 8),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 56),
                ),
              ),
            ),
            SizedBox(height: AppleFitnessTheme.spacingXL),
            Text(
              title,
              style: AppleFitnessTheme.headlineSmall,
            ),
            SizedBox(height: AppleFitnessTheme.spacingM),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingXL * 2),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppleFitnessTheme.bodyMedium.copyWith(
                  color: AppleFitnessTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: AppleFitnessTheme.spacingXL),
            Button3D.primary(
              text: actionLabel,
              icon: actionIcon,
              onPressed: onAction,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildGymMapTab() {
    if (_isLoadingGyms) {
      return _buildLoadingState('正在搜索附近的健身房...', '🏃');
    }

    if (_gyms.isEmpty) {
      return _buildEmptyState(
        emoji: '🏢',
        title: '附近暂无健身房',
        message: '试试扩大搜索范围',
        actionLabel: '调整范围',
        actionIcon: Icons.tune_rounded,
        onAction: _showGymRadiusSelector,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNearbyGyms,
      color: AppleFitnessTheme.primaryBlue,
      child: Column(
        children: [
          // 统计卡片 (from old design)
          cartoon_animations.BounceInAnimation(
            delay: const Duration(milliseconds: 100),
            child: Container(
              margin: EdgeInsets.all(AppleFitnessTheme.spacingL),
              padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
              decoration: BoxDecoration(
                gradient: AppleFitnessTheme.primaryGradient,
                borderRadius: AppleFitnessTheme.radiusMedium,
                boxShadow: AppleFitnessTheme.softShadow(elevation: 4),
              ),
              child: Row(
                children: [
                  const Text('📍', style: TextStyle(fontSize: 24)),
                  SizedBox(width: AppleFitnessTheme.spacingM),
                  Text(
                    '找到 ${_gyms.length} 家健身房',
                    style: AppleFitnessTheme.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 健身房列表
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingL),
              itemCount: _gyms.length,
              itemBuilder: (context, index) {
                final gym = _gyms[index];
                return cartoon_animations.SlideInAnimation(
                  direction: cartoon_animations.SlideDirection.fromBottom,
                  delay: Duration(milliseconds: index * 50),
                  child: GymCard(
                    gym: gym,
                    onNavigate: () async {
                      // 使用地图应用导航到健身房
                      final url = 'https://maps.google.com/?q=${gym.location.latitude},${gym.location.longitude}';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    },
                    onCall: gym.phone != null && gym.phone!.isNotEmpty
                        ? () async {
                            // 拨打电话
                            final url = 'tel:${gym.phone}';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            }
                          }
                        : null,
                    onTap: () {
                      // 跳转到健身房详情页（暂时显示详情对话框）
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(gym.name),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('地址: ${gym.address}'),
                              if (gym.phone != null) Text('电话: ${gym.phone}'),
                              if (gym.rating != null) Text('评分: ${gym.rating}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('关闭'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


}
