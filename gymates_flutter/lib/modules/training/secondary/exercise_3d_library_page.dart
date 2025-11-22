import 'package:flutter/material.dart';
import '../../../core/3d_components/index.dart';
import '../../../models/exercise_library.dart';
import '../../../services/exercise_library_service.dart';
import 'exercise_detail_page.dart';

/// 📚 Apple Fitness+ Style Exercise Library Page
/// 
/// Design Features:
/// - 3D floating search bar
/// - 3D filter tag cloud
/// - 3D exercise card grid (2 columns)
/// - 3D flip card effect on tap
/// - Infinite scroll loading
/// - Favorite animation (heart pop)
/// - Smooth transitions

class Exercise3DLibraryPage extends StatefulWidget {
  const Exercise3DLibraryPage({super.key});

  @override
  State<Exercise3DLibraryPage> createState() => _Exercise3DLibraryPageState();
}

class _Exercise3DLibraryPageState extends State<Exercise3DLibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  final ExerciseLibraryService _exerciseService = ExerciseLibraryService();
  final ScrollController _scrollController = ScrollController();
  
  String _selectedCategory = '全部';
  String _selectedDifficulty = '全部';
  String _selectedEquipment = '全部';
  
  List<ExerciseLibrary> _exercises = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _total = 0;
  int _currentPage = 1;
  
  DateTime _lastSearchTime = DateTime.now();
  final Set<String> _favorites = {};

  final List<String> _categories = [
    '全部', '胸部', '背部', '腿部', '肩部',
    '二头肌', '三头肌', '腹部', '臀部', '全身',
  ];

  final List<String> _difficulties = ['全部', '初级', '中级', '高级'];

  final List<String> _equipments = [
    '全部', '杠铃', '哑铃', '器械', '自重', '绳索', '弹力带',
  ];

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final now = DateTime.now();
    if (now.difference(_lastSearchTime).inMilliseconds > 500) {
      _lastSearchTime = now;
      _currentPage = 1;
      _loadExercises();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadExercises() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _exercises.clear();
    });

    try {
      final result = await _exerciseService.getExercises(
        page: 1,
        limit: 20,
        muscleGroup: _selectedCategory == '全部' ? null : _selectedCategory,
        difficulty: _selectedDifficulty == '全部' ? null : _selectedDifficulty,
        equipment: _selectedEquipment == '全部' ? null : _selectedEquipment,
        search: _searchController.text.trim().isEmpty 
            ? null 
            : _searchController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _exercises = result.data;
          _total = result.total;
          _currentPage = 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('加载失败: $e');
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _exercises.length >= _total) return;

    setState(() => _isLoadingMore = true);

    try {
      final result = await _exerciseService.getExercises(
        page: _currentPage + 1,
        limit: 20,
        muscleGroup: _selectedCategory == '全部' ? null : _selectedCategory,
        difficulty: _selectedDifficulty == '全部' ? null : _selectedDifficulty,
        equipment: _selectedEquipment == '全部' ? null : _selectedEquipment,
        search: _searchController.text.trim().isEmpty 
            ? null 
            : _searchController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _exercises.addAll(result.data);
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
  }

  void _showError(String message) {
    showAlertDialog3D(
      context: context,
      title: '提示',
      message: message,
      confirmText: '确定',
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
        child: SafeArea(
          child: Column(
            children: [
              // Header with search
              _buildHeader(),
              
              // Filter tags
              _buildFilterSection(),
              
              // Exercise grid
              Expanded(
                child: _buildExerciseGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and title
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(width: AppleFitnessTheme.spacingS),
              Text(
                '动作库',
                style: AppleFitnessTheme.headlineMedium,
              ),
              const Spacer(),
              Text(
                '$_total 个动作',
                style: AppleFitnessTheme.bodyMedium.copyWith(
                  color: AppleFitnessTheme.textSecondary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppleFitnessTheme.spacingL),
          
          // Search bar
          SearchInput3D(
            controller: _searchController,
            hint: '搜索动作名称...',
            autofocus: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category filter
        _buildFilterRow(
          title: '部位',
          items: _categories,
          selectedItem: _selectedCategory,
          onSelected: (value) {
            setState(() => _selectedCategory = value);
            _loadExercises();
          },
        ),
        
        // Difficulty filter
        _buildFilterRow(
          title: '难度',
          items: _difficulties,
          selectedItem: _selectedDifficulty,
          onSelected: (value) {
            setState(() => _selectedDifficulty = value);
            _loadExercises();
          },
        ),
        
        // Equipment filter
        _buildFilterRow(
          title: '器械',
          items: _equipments,
          selectedItem: _selectedEquipment,
          onSelected: (value) {
            setState(() => _selectedEquipment = value);
            _loadExercises();
          },
        ),
        
        SizedBox(height: AppleFitnessTheme.spacingM),
      ],
    );
  }

  Widget _buildFilterRow({
    required String title,
    required List<String> items,
    required String selectedItem,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingL),
          child: Text(
            title,
            style: AppleFitnessTheme.labelMedium.copyWith(
              color: AppleFitnessTheme.textSecondary,
            ),
          ),
        ),
        SizedBox(height: AppleFitnessTheme.spacingS),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingL),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = item == selectedItem;
              
              return Padding(
                padding: EdgeInsets.only(right: AppleFitnessTheme.spacingS),
                child: _buildFilterChip(
                  label: item,
                  isSelected: isSelected,
                  onTap: () => onSelected(item),
                ),
              );
            },
          ),
        ),
        SizedBox(height: AppleFitnessTheme.spacingM),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppleFitnessTheme.durationFast,
        curve: AppleFitnessTheme.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppleFitnessTheme.primaryGradient : null,
          color: isSelected ? null : AppleFitnessTheme.backgroundSecondary,
          borderRadius: AppleFitnessTheme.radiusSmall,
          boxShadow: isSelected 
              ? AppleFitnessTheme.softShadow(elevation: 4)
              : null,
        ),
        child: Text(
          label,
          style: AppleFitnessTheme.labelMedium.copyWith(
            color: isSelected 
                ? Colors.white 
                : AppleFitnessTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseGrid() {
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

    if (_exercises.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _exercises.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _exercises.length) {
          return Center(
            child: CircularProgress3D(
              value: 0.0,
              size: 40,
              progressColor: AppleFitnessTheme.primaryBlue,
              showPercentage: false,
            ),
          );
        }
        
        final exercise = _exercises[index];
        return StaggeredAnimation3D(
          index: index,
          child: _buildExerciseCard(exercise),
        );
      },
    );
  }

  Widget _buildExerciseCard(ExerciseLibrary exercise) {
    final isFavorite = _favorites.contains(exercise.id);
    final gradient = _getGradientForMuscle(exercise.part);

    return Card3D(
      gradient: gradient,
      onTap: () => _navigateToDetail(exercise),
      child: Stack(
        children: [
          // Content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(AppleFitnessTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Difficulty badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: AppleFitnessTheme.radiusSmall,
                    ),
                    child: Text(
                      exercise.levelText,
                      style: AppleFitnessTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Exercise name
                  Text(
                    exercise.name,
                    style: AppleFitnessTheme.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: AppleFitnessTheme.spacingXS),
                  
                  // Muscle group
                  Text(
                    exercise.part,
                    style: AppleFitnessTheme.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  
                  SizedBox(height: AppleFitnessTheme.spacingS),
                  
                  // Equipment
                  if (exercise.equipment.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            exercise.equipment,
                            style: AppleFitnessTheme.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          
          // Favorite button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _toggleFavorite(exercise.id.toString()),
              child: AnimatedContainer(
                duration: AppleFitnessTheme.durationFast,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isFavorite
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite 
                      ? AppleFitnessTheme.primaryPink
                      : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppleFitnessTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 50,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingL),
            
            Text(
              '没有找到相关动作',
              style: AppleFitnessTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingS),
            
            Text(
              '试试调整筛选条件',
              style: AppleFitnessTheme.bodyMedium.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingXL),
            
            Button3D.primary(
              text: '清除筛选',
              icon: Icons.clear_all,
              onPressed: _clearFilters,
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradientForMuscle(String muscleGroup) {
    final gradients = {
      '胸部': AppleFitnessTheme.workoutGradients['strength']!,
      '背部': AppleFitnessTheme.workoutGradients['yoga']!,
      '腿部': AppleFitnessTheme.workoutGradients['cycling']!,
      '肩部': AppleFitnessTheme.workoutGradients['treadmill']!,
      '二头肌': AppleFitnessTheme.workoutGradients['core']!,
      '三头肌': AppleFitnessTheme.workoutGradients['dance']!,
      '腹部': AppleFitnessTheme.workoutGradients['hiit']!,
      '臀部': AppleFitnessTheme.workoutGradients['rowing']!,
    };
    
    return gradients[muscleGroup] ?? AppleFitnessTheme.primaryGradient;
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = '全部';
      _selectedDifficulty = '全部';
      _selectedEquipment = '全部';
      _searchController.clear();
    });
    _loadExercises();
  }

  void _navigateToDetail(ExerciseLibrary exercise) {
    context.push3D(ExerciseDetailPage(exercise: exercise));
  }
}

