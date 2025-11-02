import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/mate_models.dart';
import '../../models/gym_models.dart';
import '../../services/mate_service.dart';
import '../../services/map_service.dart';
import '../../services/auth_service_enhanced.dart';
import '../../widgets/partner_card.dart';
import '../../widgets/gym_card.dart';
import '../../widgets/filter_panel.dart';
import '../../theme/gymates_theme.dart';
import '../../core/theme/gymates_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'mate_detail_page.dart';
import '../../services/navigation_service.dart';

/// 🔥 搭子匹配页面 - Tinder风格滑卡设计
/// 
/// 功能特性：
/// - 滑卡式匹配界面（左滑拒绝，右滑喜欢）
/// - 渐变卡片 + 距离标签
/// - 底部操作按钮（拒绝、Super Like、喜欢）
/// - 健身房地图集成
/// - Glassmorphism 设计风格
class MatesPage extends StatefulWidget {
  const MatesPage({super.key});

  @override
  State<MatesPage> createState() => _MatesPageState();
}

class _MatesPageState extends State<MatesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthServiceEnhanced _authService = AuthServiceEnhanced();
  MateService? _mateService;
  MapService? _mapService;

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

  // 初始化服务（获取token）
  Future<void> _initServices() async {
    final token = await _authService.getAccessToken();
    setState(() {
      _mateService = MateService(token: token);
      _mapService = MapService();
    });
    _loadMateRecommendations();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && _gyms.isEmpty) {
      _loadNearbyGyms();
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

      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
      });

      // 重新加载附近的健身房
      if (_tabController.index == 1) {
        _loadNearbyGyms();
      }
    } catch (e) {
      debugPrint('获取位置失败: $e');
    }
  }

  // 加载搭子推荐
  Future<void> _loadMateRecommendations() async {
    if (_mateService == null) {
      debugPrint('⏳ MateService 还未初始化，等待token...');
      return;
    }

    setState(() {
      _isLoadingMates = true;
    });

    try {
      final response = await _mateService!.getMateRecommendations(
        filterOptions: _filterOptions,
      );

      setState(() {
        _mates = response.recommendations;
        _isLoadingMates = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMates = false;
      });
      _showError('加载推荐搭子失败: $e');
    }
  }

  // 加载附近健身房
  Future<void> _loadNearbyGyms() async {
    if (_mapService == null) {
      debugPrint('⏳ MapService 还未初始化，等待token...');
      return;
    }

    setState(() {
      _isLoadingGyms = true;
    });

    try {
      final response = await _mapService!.searchNearbyGyms(
        latitude: _currentLat,
        longitude: _currentLng,
        radius: _gymSearchRadius,
      );

      if (response['success'] == true && response['gyms'] != null) {
        setState(() {
          _gyms = (response['gyms'] as List)
              .map((json) => Gym.fromJson(json))
              .toList();
          _isLoadingGyms = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingGyms = false;
      });
      _showError('加载健身房失败: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterPanel(
        initialFilters: _filterOptions,
        onApply: (filters) {
          setState(() {
            _filterOptions = filters;
          });
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '搜索范围',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            _buildRadiusOption(1000, '1公里'),
            _buildRadiusOption(3000, '3公里'),
            _buildRadiusOption(5000, '5公里'),
            _buildRadiusOption(10000, '10公里'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusOption(int radius, String label) {
    final isSelected = _gymSearchRadius == radius;
    return ListTile(
      leading: Radio<int>(
        value: radius,
        groupValue: _gymSearchRadius,
        activeColor: GyMatesColors.primaryGreen,
        onChanged: (value) {
          setState(() {
            _gymSearchRadius = value!;
          });
          Navigator.pop(context);
          _loadNearbyGyms();
        },
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? GyMatesColors.primaryGreen : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _gymSearchRadius = radius;
        });
        Navigator.pop(context);
        _loadNearbyGyms();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 自定义Header（玻璃态设计）
            _buildGlassHeader(),
            
            // 主内容区
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 搭子推荐页面（滑卡式）
                  _buildMatesTab(),

                  // 附近健身房页面
                  _buildGymsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 玻璃态Header
  Widget _buildGlassHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GymatesTheme.radius20),
        boxShadow: GymatesTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GymatesTheme.radius20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(GymatesTheme.radius20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // 标题行
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: GymatesTheme.socialGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.people_alt,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '找搭子',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: GymatesTheme.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded),
                        color: GymatesTheme.primaryColor,
                        onPressed: _tabController.index == 0
                            ? _showFilterPanel
                            : _showGymRadiusSelector,
                        tooltip: _tabController.index == 0 ? '筛选条件' : '搜索范围',
                      ),
                    ],
                  ),
                ),
                
                // Tab切换
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF6F7FB), Color(0xFFEAEAEA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(GymatesTheme.radius16),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(0, '搭子推荐', Icons.group_rounded),
                      _buildTabButton(1, '附近健身房', Icons.fitness_center_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabController.index = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? GymatesTheme.primaryGradient : null,
            borderRadius: BorderRadius.circular(GymatesTheme.radius12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: GymatesTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : GymatesTheme.lightTextSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : GymatesTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatesTab() {
    if (_isLoadingMates) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            GyMatesColors.primaryGreen,
          ),
        ),
      );
    }

    if (_mates.isEmpty) {
      return _buildEmptyState(
        icon: Icons.group_off,
        title: '暂无推荐搭子',
        message: '试试调整筛选条件',
        action: TextButton.icon(
          onPressed: _showFilterPanel,
          icon: const Icon(Icons.tune),
          label: const Text('调整筛选'),
          style: TextButton.styleFrom(
            foregroundColor: GyMatesColors.primaryGreen,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMateRecommendations,
      color: GyMatesColors.primaryGreen,
      backgroundColor: Colors.grey[900],
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _mates.length,
        itemBuilder: (context, index) {
          final mate = _mates[index];
          return PartnerCard(
            mate: mate,
            onLike: () => _handleLikeMate(mate),
            onPass: () => _handlePassMate(mate),
            onMessage: () => _handleMessageMate(mate),
            onTap: () => _handleViewMateProfile(mate),
          );
        },
      ),
    );
  }

  Widget _buildGymsTab() {
    if (_isLoadingGyms) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            GyMatesColors.primaryGreen,
          ),
        ),
      );
    }

    if (_gyms.isEmpty) {
      return _buildEmptyState(
        icon: Icons.fitness_center,
        title: '附近暂无健身房',
        message: '试试扩大搜索范围',
        action: TextButton.icon(
          onPressed: _showGymRadiusSelector,
          icon: const Icon(Icons.tune),
          label: const Text('调整范围'),
          style: TextButton.styleFrom(
            foregroundColor: GyMatesColors.primaryGreen,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNearbyGyms,
      color: GyMatesColors.primaryGreen,
      backgroundColor: Colors.grey[900],
      child: Column(
        children: [
          // 统计信息
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '找到 ${_gyms.length} 家健身房',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // 健身房列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _gyms.length,
              itemBuilder: (context, index) {
                final gym = _gyms[index];
                return GymCard(
                  gym: gym,
                  onNavigate: () => _handleNavigateToGym(gym),
                  onCall: gym.phone != null && gym.phone!.isNotEmpty
                      ? () => _handleCallGym(gym)
                      : null,
                  onTap: () => _handleViewGymDetails(gym),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: GymatesTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: GymatesTheme.glowShadow,
            ),
            child: Icon(
              icon,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              color: GymatesTheme.lightTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GymatesTheme.lightTextSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 32),
            action,
          ],
        ],
      ),
    );
  }

  // 搭子操作处理
  void _handleLikeMate(MateProfile mate) async {
    if (_mateService == null) {
      _showError('服务未初始化，请稍后再试');
      return;
    }

    try {
      await _mateService!.sendMateRequest(mate.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已发送搭子请求'),
          backgroundColor: GyMatesColors.primaryGreen,
        ),
      );
      // 从列表中移除
      setState(() {
        _mates.remove(mate);
      });
    } catch (e) {
      _showError('发送请求失败: $e');
    }
  }

  void _handlePassMate(MateProfile mate) {
    setState(() {
      _mates.remove(mate);
    });
  }

  void _handleMessageMate(MateProfile mate) {
    // TODO: 跳转到聊天页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('消息功能开发中')),
    );
  }

  void _handleViewMateProfile(MateProfile mate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MateDetailPage(mate: mate),
      ),
    );
  }

  // 健身房操作处理
  void _handleNavigateToGym(Gym gym) {
    NavigationService.navigateTo(
      context: context,
      latitude: gym.location.latitude,
      longitude: gym.location.longitude,
      destinationName: gym.name,
    );
  }

  void _handleCallGym(Gym gym) {
    if (gym.phone != null && gym.phone!.isNotEmpty) {
      NavigationService.makePhoneCall(gym.phone!);
    }
  }

  void _handleViewGymDetails(Gym gym) {
    // TODO: 跳转到健身房详情页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('健身房详情开发中')),
    );
  }
}

