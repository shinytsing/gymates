import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../services/llm_config_service.dart';
import '../../models/llm_config_model.dart';
import 'membership_purchase_page.dart';

/// 🤖 LLM滑动选择器页面
/// 
/// 功能：
/// 1. 滑动浏览所有LLM
/// 2. 免费LLM直接使用
/// 3. 付费LLM提示开通会员
/// 4. 流畅的滑动动画

class LLMSelectorSwipePage extends StatefulWidget {
  const LLMSelectorSwipePage({super.key});

  @override
  State<LLMSelectorSwipePage> createState() => _LLMSelectorSwipePageState();
}

class _LLMSelectorSwipePageState extends State<LLMSelectorSwipePage> {
  final _llmService = LLMConfigService();
  final _pageController = PageController(viewportFraction: 0.85);
  
  List<LLMConfig> _llmConfigs = [];
  String _currentProvider = 'tencent';
  String _recommendedProvider = 'tencent';
  bool _hasVIPAccess = false;
  bool _isLoading = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLLMConfigs();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLLMConfigs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _llmService.getAvailableLLMs();
      setState(() {
        _llmConfigs = response.configs;
        _currentProvider = response.currentProvider;
        _recommendedProvider = response.recommendedProvider;
        _hasVIPAccess = response.hasVIPAccess;
        _isLoading = false;
        
        // 定位到当前选中的LLM
        _currentIndex = _llmConfigs.indexWhere(
          (config) => config.provider == _currentProvider
        );
        if (_currentIndex < 0) _currentIndex = 0;
      });
      
      // 跳转到当前选中的页面
      if (_llmConfigs.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pageController.hasClients) {
            _pageController.jumpToPage(_currentIndex);
          }
        });
      }
    } catch (e) {
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

  Future<void> _selectLLM(LLMConfig config) async {
    // 检查是否需要会员
    if (config.requiresMembership && !_hasVIPAccess) {
      _showMembershipRequired(config);
      return;
    }

    // 检查是否可用
    if (!config.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('该AI教练暂时不可用'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _llmService.setUserLLMProvider(config.provider);
      
      setState(() {
        _currentProvider = config.provider;
      });
      
      HapticFeedback.mediumImpact();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('已切换到 ${config.displayName}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('切换失败: $e')),
        );
      }
    }
  }

  void _showMembershipRequired(LLMConfig config) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: GymatesTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '开通会员使用 ${config.displayName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '升级会员即可使用所有高级AI教练',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('稍后再说'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToMembership();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GymatesTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('立即开通'),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _navigateToMembership() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MembershipPurchasePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.darkBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: GymatesTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              if (!_hasVIPAccess) _buildFreeTrialBanner(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _buildLLMCarousel(),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🤖 选择AI教练',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '左右滑动浏览',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!_hasVIPAccess)
            OutlinedButton.icon(
              onPressed: _navigateToMembership,
              icon: const Icon(Icons.workspace_premium, size: 16),
              label: const Text('开通会员'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFreeTrialBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '🎯 腾讯混元 和 ⚡ Groq 完全免费使用',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLLMCarousel() {
    if (_llmConfigs.isEmpty) {
      return const Center(
        child: Text(
          '暂无可用的AI教练',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
        HapticFeedback.selectionClick();
      },
      itemCount: _llmConfigs.length,
      itemBuilder: (context, index) {
        return _buildLLMCard(_llmConfigs[index], index);
      },
    );
  }

  Widget _buildLLMCard(LLMConfig config, int index) {
    final isActive = index == _currentIndex;
    final isSelected = config.provider == _currentProvider;
    
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectLLM(config),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 图标和标签
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: config.isFree
                              ? LinearGradient(
                                  colors: [Colors.green[400]!, Colors.teal[400]!],
                                )
                              : GymatesTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            config.icon,
                            style: const TextStyle(fontSize: 56),
                          ),
                        ),
                      ),
                      if (config.isFree)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green[600]!, Colors.teal[600]!],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '免费',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isSelected)
                        Positioned(
                          bottom: -5,
                          right: -5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 名称
                  Text(
                    config.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 描述
                  Text(
                    config.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 特性标签
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: config.features.take(4).map((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: config.isFree
                              ? Colors.green.withValues(alpha: 0.1)
                              : GymatesTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 11,
                            color: config.isFree
                                ? Colors.green[700]
                                : GymatesTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  
                  // 价格
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          config.isFree ? Icons.check_circle : Icons.attach_money,
                          size: 20,
                          color: config.isFree ? Colors.green : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          config.pricing.avgCost,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: config.isFree ? Colors.green[700] : const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (config.requiresMembership && !_hasVIPAccess) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            size: 16,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '需要会员',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    if (_llmConfigs.isEmpty) return const SizedBox();
    
    final currentConfig = _llmConfigs[_currentIndex];
    final isSelected = currentConfig.provider == _currentProvider;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // 指示器
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _llmConfigs.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == _currentIndex ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == _currentIndex
                        ? GymatesTheme.primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 选择按钮
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isSelected ? null : () => _selectLLM(currentConfig),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Colors.grey[300]
                      : (currentConfig.isFree
                          ? Colors.green
                          : GymatesTheme.primaryColor),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: isSelected ? 0 : 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected)
                      const Icon(Icons.check_circle, size: 20)
                    else if (currentConfig.requiresMembership && !_hasVIPAccess)
                      const Icon(Icons.workspace_premium, size: 20)
                    else
                      const Icon(Icons.auto_awesome, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      isSelected
                          ? '当前使用'
                          : (currentConfig.requiresMembership && !_hasVIPAccess
                              ? '开通会员使用'
                              : '选择此教练'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

