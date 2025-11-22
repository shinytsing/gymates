import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../services/llm_config_service.dart';
import '../../models/llm_config_model.dart';

/// 🤖 LLM智能教练选择器页面
/// 
/// 功能：
/// 1. 展示所有可用的LLM提供商
/// 2. 显示每个LLM的特点和价格
/// 3. 支持切换LLM提供商
/// 4. 测试连接功能

class LLMSelectorPage extends StatefulWidget {
  const LLMSelectorPage({super.key});

  @override
  State<LLMSelectorPage> createState() => _LLMSelectorPageState();
}

class _LLMSelectorPageState extends State<LLMSelectorPage> {
  final _llmService = LLMConfigService();
  
  List<LLMConfig> _llmConfigs = [];
  String _currentProvider = 'deepseek';
  String _recommendedProvider = 'deepseek';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadLLMConfigs();
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
        _isLoading = false;
      });
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

  Future<void> _switchProvider(String provider) async {
    try {
      await _llmService.setUserLLMProvider(provider);
      
      setState(() {
        _currentProvider = provider;
      });
      
      HapticFeedback.mediumImpact();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('已切换到 ${_getLLMName(provider)}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('切换失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getLLMName(String provider) {
    final config = _llmConfigs.firstWhere(
      (c) => c.provider == provider,
      orElse: () => _llmConfigs.first,
    );
    return config.displayName;
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
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _buildLLMList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
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
                  '🤖 AI健身教练',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '选择您的专属AI教练',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLLMList() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 推荐标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GymatesTheme.primaryColor.withValues(alpha: 0.1),
                  GymatesTheme.secondaryColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GymatesTheme.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: GymatesTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '推荐使用 ${_getLLMName(_recommendedProvider)} - 性价比最高',
                    style: const TextStyle(
                      fontSize: 13,
                      color: GymatesTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // LLM列表
          ..._llmConfigs.map((config) => _buildLLMCard(config)),
        ],
      ),
    );
  }

  Widget _buildLLMCard(LLMConfig config) {
    final isSelected = _currentProvider == config.provider;
    final isRecommended = _recommendedProvider == config.provider;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? GymatesTheme.primaryColor.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? GymatesTheme.primaryColor
              : const Color(0xFFE5E7EB),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: GymatesTheme.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: config.isAvailable
              ? () => _switchProvider(config.provider)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部：图标、名称、状态
                Row(
                  children: [
                    // 图标
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: config.isAvailable
                            ? GymatesTheme.primaryGradient
                            : LinearGradient(
                                colors: [
                                  Colors.grey[300]!,
                                  Colors.grey[400]!,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          config.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // 名称和描述
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                config.displayName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: config.isAvailable
                                      ? const Color(0xFF1F2937)
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                              if (isRecommended) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: GymatesTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '推荐',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            config.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: config.isAvailable
                                  ? const Color(0xFF6B7280)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 选中标识
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: GymatesTheme.primaryColor,
                        size: 28,
                      )
                    else if (!config.isAvailable)
                      const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF9CA3AF),
                        size: 24,
                      ),
                  ],
                ),
                
                if (config.isAvailable) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  
                  // 特性标签
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: config.features.map((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: GymatesTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 11,
                            color: GymatesTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 价格信息
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '平均成本: ${config.pricing.avgCost}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${config.pricing.inputPrice} (输入) / ${config.pricing.outputPrice} (输出)',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '未配置 API Key，请联系管理员',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
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
    );
  }
}

