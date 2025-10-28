import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/smart_api_config.dart';

/// 🤖 AI服务状态页面
/// 
/// 显示当前AI服务状态，允许用户切换AI服务提供商
class AIServiceStatusPage extends StatefulWidget {
  const AIServiceStatusPage({super.key});

  @override
  _AIServiceStatusPageState createState() => _AIServiceStatusPageState();
}

class _AIServiceStatusPageState extends State<AIServiceStatusPage> {
  String _currentProvider = 'unknown';
  List<String> _availableProviders = [];
  Map<String, bool> _serviceStatus = {};
  final Map<String, int> _servicePriority = {};
  final List<Map<String, dynamic>> _servicesWithPriority = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServiceStatus();
  }

  Future<void> _loadServiceStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${SmartApiConfig.apiBaseUrl}/ai/status'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _currentProvider = data['data']['current_provider'] ?? 'unknown';
            _availableProviders = List<String>.from(data['data']['available_providers'] ?? []);
            _serviceStatus = Map<String, bool>.from(data['data']['service_status'] ?? {});
            _isLoading = false;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? '获取服务状态失败';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '网络错误: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _switchProvider(String provider) async {
    try {
      final response = await http.post(
        Uri.parse('${SmartApiConfig.apiBaseUrl}/ai/switch-provider'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'provider': provider,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _currentProvider = provider;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已切换到 $provider'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('切换失败: ${data['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('切换失败: HTTP ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('切换失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getProviderDisplayName(String provider) {
    switch (provider) {
      case 'groq':
        return 'Groq AI';
      case 'tencent_hunyuan':
        return '腾讯混元';
      case 'deepseek':
        return 'DeepSeek AI';
      default:
        return provider;
    }
  }

  IconData _getProviderIcon(String provider) {
    switch (provider) {
      case 'groq':
        return Icons.speed;
      case 'tencent_hunyuan':
        return Icons.cloud;
      case 'deepseek':
        return Icons.psychology;
      default:
        return Icons.smart_toy;
    }
  }

  Color _getProviderColor(String provider) {
    switch (provider) {
      case 'groq':
        return Colors.purple;
      case 'tencent_hunyuan':
        return Colors.blue;
      case 'deepseek':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'AI服务状态 (调试)',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2A2A2A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadServiceStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadServiceStatus,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 当前服务状态
                      _buildCurrentServiceCard(),
                      const SizedBox(height: 16),
                      
                      // 可用服务列表
                      _buildAvailableServicesCard(),
                      const SizedBox(height: 16),
                      
                      // 服务状态详情
                      _buildServiceStatusCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCurrentServiceCard() {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getProviderIcon(_currentProvider),
                  color: _getProviderColor(_currentProvider),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '当前AI服务',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getProviderColor(_currentProvider).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getProviderColor(_currentProvider),
                  width: 1,
                ),
              ),
              child: Text(
                _getProviderDisplayName(_currentProvider),
                style: TextStyle(
                  color: _getProviderColor(_currentProvider),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableServicesCard() {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '可用AI服务',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._availableProviders.map((provider) => _buildProviderTile(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderTile(String provider) {
    final isCurrent = provider == _currentProvider;
    final isAvailable = _serviceStatus[provider] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getProviderIcon(provider),
          color: isAvailable 
              ? _getProviderColor(provider)
              : Colors.grey,
        ),
        title: Text(
          _getProviderDisplayName(provider),
          style: TextStyle(
            color: isCurrent ? Colors.white : Colors.white70,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          isCurrent ? '当前使用' : (isAvailable ? '可用' : '不可用'),
          style: TextStyle(
            color: isAvailable ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
        trailing: isCurrent
            ? const Icon(Icons.check_circle, color: Colors.green)
            : isAvailable
                ? IconButton(
                    icon: const Icon(Icons.swap_horiz, color: Colors.blue),
                    onPressed: () => _switchProvider(provider),
                  )
                : const Icon(Icons.block, color: Colors.grey),
        tileColor: isCurrent 
            ? _getProviderColor(provider).withValues(alpha: 0.1)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isCurrent 
                ? _getProviderColor(provider)
                : Colors.transparent,
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceStatusCard() {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '服务状态详情',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._serviceStatus.entries.map((entry) => _buildStatusItem(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String provider, bool isAvailable) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getProviderDisplayName(provider),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            isAvailable ? '在线' : '离线',
            style: TextStyle(
              color: isAvailable ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
