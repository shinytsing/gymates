import 'package:flutter/material.dart';
import '../services/map_service.dart';
import '../models/gym_models.dart';
import '../core/theme/gymates_colors.dart';

/// 健身房搜索页面
class GymSearchPage extends StatefulWidget {
  const GymSearchPage({super.key});

  @override
  State<GymSearchPage> createState() => _GymSearchPageState();
}

class _GymSearchPageState extends State<GymSearchPage> {
  final MapService _mapService = MapService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Gym> _gyms = [];
  bool _isLoading = false;
  String _searchMode = 'nearby'; // 'nearby' 或 'city'
  
  // 默认位置（北京三里屯）
  final double _currentLat = 39.9357;
  final double _currentLng = 116.4475;
  int _searchRadius = 3000; // 3公里

  @override
  void initState() {
    super.initState();
    _searchNearbyGyms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchNearbyGyms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _mapService.searchNearbyGyms(
        latitude: _currentLat,
        longitude: _currentLng,
        radius: _searchRadius,
      );

      if (response['success'] == true && response['gyms'] != null) {
        setState(() {
          _gyms = (response['gyms'] as List)
              .map((json) => Gym.fromJson(json))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('搜索失败：$e');
    }
  }

  Future<void> _searchByCity(String city) async {
    if (city.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _mapService.searchGymsByCity(
        city: city,
        page: 1,
        pageSize: 20,
      );

      if (response['success'] == true && response['gyms'] != null) {
        setState(() {
          _gyms = (response['gyms'] as List)
              .map((json) => Gym.fromJson(json))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('搜索失败：$e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showRadiusSelector() {
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
    final isSelected = _searchRadius == radius;
    return ListTile(
      leading: Radio<int>(
        value: radius,
        groupValue: _searchRadius,
        activeColor: GyMatesColors.primaryGreen,
        onChanged: (value) {
          setState(() {
            _searchRadius = value!;
          });
          Navigator.pop(context);
          _searchNearbyGyms();
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
          _searchRadius = radius;
        });
        Navigator.pop(context);
        _searchNearbyGyms();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Row(
          children: [
            Icon(Icons.location_on, color: GyMatesColors.primaryGreen),
            SizedBox(width: 8),
            Text(
              '找健身房',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: _showRadiusSelector,
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Column(
              children: [
                // 搜索模式切换
                Row(
                  children: [
                    Expanded(
                      child: _buildModeButton(
                        '附近',
                        'nearby',
                        Icons.near_me,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModeButton(
                        '按城市',
                        'city',
                        Icons.location_city,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 搜索框
                if (_searchMode == 'city')
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '输入城市名称...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[850],
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: GyMatesColors.primaryGreen,
                        ),
                        onPressed: () => _searchByCity(_searchController.text),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _searchByCity,
                  ),
              ],
            ),
          ),

          // 结果统计
          if (_gyms.isNotEmpty)
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GyMatesColors.primaryGreen,
                      ),
                    ),
                  )
                : _gyms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 64,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '附近暂无健身房',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _gyms.length,
                        itemBuilder: (context, index) {
                          return _buildGymCard(_gyms[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, String mode, IconData icon) {
    final isSelected = _searchMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _searchMode = mode;
          if (mode == 'nearby') {
            _searchNearbyGyms();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? GyMatesColors.primaryGreen
              : Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? GyMatesColors.primaryGreen
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGymCard(Gym gym) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 名称和距离
          Row(
            children: [
              Expanded(
                child: Text(
                  gym.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: GyMatesColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_walk,
                      color: GyMatesColors.primaryGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      gym.formattedDistance,
                      style: const TextStyle(
                        color: GyMatesColors.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 地址
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  gym.address,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          if (gym.phone != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  gym.phone!,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: 导航功能
                  },
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('导航'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GyMatesColors.primaryGreen,
                    side: const BorderSide(
                      color: GyMatesColors.primaryGreen,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: 查看详情
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('详情'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GyMatesColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

