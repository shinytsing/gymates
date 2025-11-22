import 'package:flutter/material.dart';
import '../../core/3d_components/index.dart';
import '../../services/profile_api_service.dart';

/// 🏆 Apple Fitness+ Style Achievement Detail Page
class Achievement3DDetailPage extends StatefulWidget {
  const Achievement3DDetailPage({super.key});

  @override
  State<Achievement3DDetailPage> createState() => _Achievement3DDetailPageState();
}

class _Achievement3DDetailPageState extends State<Achievement3DDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProfileApiService _apiService = ProfileApiService();
  
  String _selectedCategory = 'all';
  bool _isLoading = true;
  List<AchievementItem> _allAchievements = [];
  List<AchievementItem> _filteredAchievements = [];

  final List<String> _categories = ['all', 'training', 'social', 'streak', 'special'];
  final Map<String, String> _categoryNames = {
    'all': '全部',
    'training': '训练',
    'social': '社交',
    'streak': '连续',
    'special': '特殊',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = _categories[_tabController.index];
        _filterAchievements();
      });
    });
    _loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);
    
    try {
      // Load from backend
      final data = await _apiService.getUserAchievements('1');
      
      if (mounted) {
        setState(() {
          _allAchievements = (data['achievements'] as List?)
                  ?.map((e) => AchievementItem.fromJson(e))
                  .toList() ??
              _generateMockAchievements();
          _filterAchievements();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ 加载成就数据失败: $e');
      if (mounted) {
        setState(() {
          _allAchievements = _generateMockAchievements();
          _filterAchievements();
          _isLoading = false;
        });
      }
    }
  }

  List<AchievementItem> _generateMockAchievements() {
    return List.generate(20, (index) {
      return AchievementItem(
        id: 'achievement_$index',
        name: '成就 ${index + 1}',
        description: '完成 ${(index + 1) * 10} 次训练',
        category: _categories[index % _categories.length],
        icon: Icons.emoji_events,
        isUnlocked: index < 10,
        progress: index < 10 ? 1.0 : (index - 10) / 10,
        unlockedAt: index < 10 ? DateTime.now().subtract(Duration(days: index)) : null,
      );
    });
  }

  void _filterAchievements() {
    if (_selectedCategory == 'all') {
      _filteredAchievements = _allAchievements;
    } else {
      _filteredAchievements = _allAchievements
          .where((a) => a.category == _selectedCategory)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '成就',
          style: AppleFitnessTheme.titleLarge,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppleFitnessTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  return _buildAchievementList(category);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(AppleFitnessTheme.spacingL),
      decoration: BoxDecoration(
        color: AppleFitnessTheme.backgroundSecondary,
        borderRadius: AppleFitnessTheme.radiusMedium,
        boxShadow: AppleFitnessTheme.softShadow(elevation: 2),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          gradient: AppleFitnessTheme.primaryGradient,
          borderRadius: AppleFitnessTheme.radiusMedium,
          boxShadow: AppleFitnessTheme.softShadow(elevation: 4),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppleFitnessTheme.textSecondary,
        tabs: _categories.map((category) {
          return Tab(text: _categoryNames[category]);
        }).toList(),
      ),
    );
  }

  Widget _buildAchievementList(String category) {
    if (_isLoading) {
      return Center(
        child: CircularProgress3D(
          value: 0.0,
          size: 60,
          progressColor: AppleFitnessTheme.primaryBlue,
          showPercentage: false,
        ),
      );
    }

    if (_filteredAchievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: AppleFitnessTheme.textTertiary,
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Text(
              '暂无成就',
              style: AppleFitnessTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAchievements,
      child: ListView.builder(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        itemCount: _filteredAchievements.length,
        itemBuilder: (context, index) {
          final achievement = _filteredAchievements[index];
          return StaggeredAnimation3D(
            index: index,
            child: Padding(
              padding: EdgeInsets.only(bottom: AppleFitnessTheme.spacingM),
              child: Card3D(
                gradient: achievement.isUnlocked
                    ? AppleFitnessTheme.primaryGradient
                    : null,
                backgroundColor: achievement.isUnlocked
                    ? null
                    : AppleFitnessTheme.backgroundSecondary,
                onTap: () {
                  _showAchievementDetail(achievement);
                },
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: achievement.isUnlocked
                          ? AppleFitnessTheme.primaryGradient
                          : null,
                      color: achievement.isUnlocked
                          ? null
                          : AppleFitnessTheme.textTertiary,
                      borderRadius: AppleFitnessTheme.radiusMedium,
                    ),
                    child: Icon(
                      achievement.icon,
                      color: achievement.isUnlocked
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      size: 32,
                    ),
                  ),
                  title: Text(
                    achievement.name,
                    style: AppleFitnessTheme.titleMedium.copyWith(
                      color: achievement.isUnlocked
                          ? Colors.white
                          : AppleFitnessTheme.textPrimary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppleFitnessTheme.spacingXS),
                      Text(
                        achievement.description,
                        style: AppleFitnessTheme.bodySmall.copyWith(
                          color: achievement.isUnlocked
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppleFitnessTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!achievement.isUnlocked && achievement.progress > 0) ...[
                        SizedBox(height: AppleFitnessTheme.spacingXS),
                        LinearProgress3D(
                          value: achievement.progress,
                          height: 4,
                          progressColor: AppleFitnessTheme.primaryBlue,
                          backgroundColor: AppleFitnessTheme.backgroundSecondary,
                        ),
                      ],
                    ],
                  ),
                  trailing: achievement.isUnlocked
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        )
                      : CircularProgress3D(
                          value: achievement.progress,
                          size: 30,
                          strokeWidth: 3,
                          progressColor: AppleFitnessTheme.primaryBlue,
                          showPercentage: false,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAchievementDetail(AchievementItem achievement) {
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
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: achievement.isUnlocked
                    ? AppleFitnessTheme.primaryGradient
                    : null,
                color: achievement.isUnlocked
                    ? null
                    : AppleFitnessTheme.textTertiary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                color: Colors.white,
                size: 50,
              ),
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Text(
              achievement.name,
              style: AppleFitnessTheme.headlineMedium,
            ),
            SizedBox(height: AppleFitnessTheme.spacingM),
            Text(
              achievement.description,
              style: AppleFitnessTheme.bodyMedium.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
              SizedBox(height: AppleFitnessTheme.spacingL),
              Text(
                '解锁时间: ${_formatDate(achievement.unlockedAt!)}',
                style: AppleFitnessTheme.bodySmall.copyWith(
                  color: AppleFitnessTheme.textTertiary,
                ),
              ),
            ],
            SizedBox(height: AppleFitnessTheme.spacingXL),
            Button3D.primary(
              text: '关闭',
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

/// Achievement item model
class AchievementItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final IconData icon;
  final bool isUnlocked;
  final double progress;
  final DateTime? unlockedAt;

  AchievementItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.isUnlocked,
    required this.progress,
    this.unlockedAt,
  });

  factory AchievementItem.fromJson(Map<String, dynamic> json) {
    return AchievementItem(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'all',
      icon: Icons.emoji_events,
      isUnlocked: json['is_unlocked'] ?? false,
      progress: (json['progress'] ?? 0.0).toDouble(),
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'])
          : null,
    );
  }
}

