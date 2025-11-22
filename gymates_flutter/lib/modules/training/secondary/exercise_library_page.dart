import 'package:flutter/material.dart';
import 'exercise_detail_page.dart';
import '../../../models/exercise_library.dart';
import '../../../services/exercise_library_service.dart';

/// 📚 动作库页面（二级页面）
/// 支持搜索、筛选、收藏与推荐动作
class ExerciseLibraryPage extends StatefulWidget {
  const ExerciseLibraryPage({super.key});

  @override
  State<ExerciseLibraryPage> createState() => _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends State<ExerciseLibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  final ExerciseLibraryService _exerciseService = ExerciseLibraryService();
  
  String _selectedCategory = '全部';
  String _selectedDifficulty = '全部';
  String _selectedEquipment = '全部';
  
  List<ExerciseLibrary> _exercises = [];
  bool _isLoading = false;
  int _total = 0;
  int _currentPage = 1;
  
  // 防抖搜索
  DateTime _lastSearchTime = DateTime.now();

  final List<String> _categories = [
    '全部',
    '胸部',
    '背部',
    '腿部',
    '肩部',
    '二头肌',
    '三头肌',
    '腹部',
    '臀部',
    '全身',
  ];

  final List<String> _difficulties = [
    '全部',
    '初级',
    '中级',
    '高级',
  ];

  final List<String> _equipments = [
    '全部',
    '杠铃',
    '哑铃',
    '器械',
    '自重',
    '绳索',
    '弹力带',
  ];

  @override
  void initState() {
    super.initState();
    _loadExercises();
    
    // 监听搜索框输入，实现防抖搜索
    _searchController.addListener(_onSearchChanged);
  }
  
  /// 搜索框输入监听（防抖）
  void _onSearchChanged() {
    final now = DateTime.now();
    if (now.difference(_lastSearchTime).inMilliseconds > 500) {
      _lastSearchTime = now;
      _currentPage = 1;
      _loadExercises();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 加载动作列表
  Future<void> _loadExercises() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final muscleGroup = _selectedCategory == '全部' ? null : _selectedCategory;
      final difficulty = _selectedDifficulty == '全部' ? null : _selectedDifficulty;
      final equipment = _selectedEquipment == '全部' ? null : _selectedEquipment;
      final search = _searchController.text.trim().isEmpty 
          ? null 
          : _searchController.text.trim();

      print('🔍 搜索参数: 部位=$muscleGroup, 难度=$difficulty, 器械=$equipment, 关键词=$search');

      final response = await _exerciseService.getExercises(
        muscleGroup: muscleGroup,
        difficulty: difficulty,
        equipment: equipment,
        search: search,
        page: _currentPage,
        limit: 20,
      );

      setState(() {
        _exercises = response.data;
        _total = response.total;
        _isLoading = false;
      });

      print('✅ 加载了 ${_exercises.length} 条动作数据，总共 $_total 条');
    } catch (e) {
      print('❌ 加载动作失败: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('动作库'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 搜索栏
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                      hintText: '搜索动作名称或部位...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                _currentPage = 1;
                                _loadExercises();
                              },
                            )
                          : null,
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (value) {
                      _currentPage = 1;
                      _loadExercises();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // 筛选按钮
                Container(
                  decoration: BoxDecoration(
                    color: _hasActiveFilters() 
                        ? const Color(0xFF6366F1) 
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: _hasActiveFilters() ? Colors.white : const Color(0xFF6B7280),
                    ),
                    onPressed: () => _showFilterBottomSheet(),
                  ),
                ),
              ],
            ),
          ),
          
          // 分类标签
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _currentPage = 1;
                      });
                      _loadExercises();
                    },
                    selectedColor: const Color(0xFF6366F1),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 筛选条件提示
          if (_hasActiveFilters())
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF9FAFB),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: Color(0xFF6366F1)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '已筛选: ${_selectedDifficulty != '全部' ? '$_selectedDifficulty ' : ''}${_selectedEquipment != '全部' ? _selectedEquipment : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDifficulty = '全部';
                        _selectedEquipment = '全部';
                        _currentPage = 1;
                      });
                      _loadExercises();
                    },
                    child: const Text(
                      '清除',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
            ),
          ),
          
          // 动作列表
          Expanded(
            child: _isLoading && _exercises.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _exercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '暂无符合条件的动作',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedCategory = '全部';
                                  _selectedDifficulty = '全部';
                                  _selectedEquipment = '全部';
                                  _currentPage = 1;
                                });
                                _loadExercises();
                              },
                              child: const Text('重置搜索'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          _currentPage = 1;
                          await _loadExercises();
                        },
                        child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                          itemCount: _exercises.length + 1,
                        itemBuilder: (context, index) {
                            if (index < _exercises.length) {
                              return _buildExerciseCard(_exercises[index]);
                            } else {
                              // 加载更多提示
                              return _buildLoadMoreWidget();
                            }
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseLibrary exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openExerciseDetail(exercise),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 动作图标或图片
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    image: exercise.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(exercise.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: exercise.imageUrl.isEmpty
                      ? const Icon(
                          Icons.fitness_center,
                          size: 30,
                          color: Color(0xFF6366F1),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // 动作信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTag(exercise.part, const Color(0xFFEF4444)),
                          const SizedBox(width: 8),
                          _buildTag(exercise.levelText, exercise.levelColor),
                        ],
                      ),
                    ],
                  ),
                ),
                // 收藏按钮
                IconButton(
                  onPressed: () => _toggleFavorite(exercise.id),
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 切换收藏状态
  Future<void> _toggleFavorite(int exerciseId) async {
    try {
      await _exerciseService.toggleFavorite(exerciseId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('操作成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 加载更多Widget
  Widget _buildLoadMoreWidget() {
    final hasMore = _exercises.length < _total;
    
    if (!hasMore) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text(
          '已加载全部 $_total 个动作',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: _isLoading
          ? const CircularProgressIndicator()
          : TextButton.icon(
              onPressed: () {
                setState(() {
                  _currentPage++;
                });
                _loadMoreExercises();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('加载更多'),
            ),
    );
  }

  /// 加载更多动作
  Future<void> _loadMoreExercises() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final muscleGroup = _selectedCategory == '全部' ? null : _selectedCategory;
      final difficulty = _selectedDifficulty == '全部' ? null : _selectedDifficulty;
      final equipment = _selectedEquipment == '全部' ? null : _selectedEquipment;
      final search = _searchController.text.trim().isEmpty 
          ? null 
          : _searchController.text.trim();

      final response = await _exerciseService.getExercises(
        muscleGroup: muscleGroup,
        difficulty: difficulty,
        equipment: equipment,
        search: search,
        page: _currentPage,
        limit: 20,
      );

      setState(() {
        _exercises.addAll(response.data);
        _total = response.total;
        _isLoading = false;
      });

      print('✅ 加载更多: 新增 ${response.data.length} 条，当前共 ${_exercises.length} 条');
    } catch (e) {
      print('❌ 加载更多失败: $e');
      setState(() {
        _isLoading = false;
        _currentPage--; // 回退页码
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  void _openExerciseDetail(ExerciseLibrary exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailPage(exercise: exercise),
      ),
    );
  }

  /// 检查是否有激活的筛选条件
  bool _hasActiveFilters() {
    return _selectedDifficulty != '全部' || _selectedEquipment != '全部';
  }

  /// 显示筛选底部弹窗
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和重置按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
                    '筛选条件',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedDifficulty = '全部';
                        _selectedEquipment = '全部';
                      });
                    },
                    child: const Text('重置'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 难度筛选
              const Text(
                '难度',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _difficulties.map((difficulty) {
                  final isSelected = _selectedDifficulty == difficulty;
                  return GestureDetector(
                    onTap: () {
                      setModalState(() {
                        _selectedDifficulty = difficulty;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF6366F1) 
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF6366F1) 
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        difficulty,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF6B7280),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // 器械筛选
              const Text(
                '器械类型',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _equipments.map((equipment) {
                  final isSelected = _selectedEquipment == equipment;
                  return GestureDetector(
                    onTap: () {
                      setModalState(() {
                        _selectedEquipment = equipment;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF6366F1) 
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF6366F1) 
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        equipment,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF6B7280),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
            ),
            const SizedBox(height: 24),
              
              // 应用按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentPage = 1;
                    });
                    Navigator.pop(context);
                    _loadExercises();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '应用筛选',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
          ),
        ),
      ),
    );
  }
}

