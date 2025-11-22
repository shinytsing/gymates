import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/3d_components/index.dart';
import '../../core/animations/cartoon_3d_animations.dart' as cartoon_animations;
import '../../core/config/smart_api_config.dart';
import '../../widgets/layouts/page_scaffold_3d.dart';

/// 🤖 Apple Fitness+ Style AI Service Status Page (3D)
/// 
/// Design Features:
/// - 3D status cards
/// - 3D service provider cards
/// - Smooth animations
/// - Apple Fitness+ minimalist style
class AIServiceStatusPage3D extends StatefulWidget {
  const AIServiceStatusPage3D({super.key});

  @override
  State<AIServiceStatusPage3D> createState() => _AIServiceStatusPage3DState();
}

class _AIServiceStatusPage3DState extends State<AIServiceStatusPage3D> {
  String _currentProvider = 'unknown';
  List<String> _availableProviders = [];
  Map<String, bool> _serviceStatus = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServiceStatus();
  }

  Future<void> _loadServiceStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${SmartApiConfig.apiBaseUrl}/ai/status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _currentProvider = data['data']['current_provider'] ?? 'unknown';
            _availableProviders = List<String>.from(data['data']['available_providers'] ?? []);
            _serviceStatus = Map<String, bool>.from(data['data']['service_status'] ?? {});
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? '获取服务状态失败';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'HTTP ${response.statusCode}';
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
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'provider': provider}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() => _currentProvider = provider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已切换到 $provider'),
              backgroundColor: AppleFitnessTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('切换失败: $e'),
          backgroundColor: AppleFitnessTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      );
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
        return AppleFitnessTheme.primaryPurple;
      case 'tencent_hunyuan':
        return AppleFitnessTheme.primaryBlue;
      case 'deepseek':
        return AppleFitnessTheme.primaryOrange;
      default:
        return AppleFitnessTheme.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold3D(
      title: 'AI服务状态',
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadServiceStatus,
        ),
      ],
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppleFitnessTheme.primaryBlue),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppleFitnessTheme.error,
                      ),
                      SizedBox(height: AppleFitnessTheme.spacingL),
                      Text(
                        _errorMessage!,
                        style: AppleFitnessTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppleFitnessTheme.spacingL),
                      Button3D(
                        text: '重试',
                        onPressed: _loadServiceStatus,
                        type: Button3DType.primary,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                  child: Column(
                    children: [
                      // Current Service
                      cartoon_animations.SlideInAnimation(
                        direction: cartoon_animations.SlideDirection.fromLeft,
                        delay: const Duration(milliseconds: 100),
                        child: Card3D(
                          padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                          borderRadius: BorderRadius.circular(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '当前服务',
                                style: AppleFitnessTheme.titleMedium,
                              ),
                              SizedBox(height: AppleFitnessTheme.spacingM),
                              Row(
                                children: [
                                  Icon(
                                    _getProviderIcon(_currentProvider),
                                    color: _getProviderColor(_currentProvider),
                                    size: 32,
                                  ),
                                  SizedBox(width: AppleFitnessTheme.spacingM),
                                  Expanded(
                                    child: Text(
                                      _currentProvider,
                                      style: AppleFitnessTheme.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: AppleFitnessTheme.spacingL),
                      
                      // Available Services
                      cartoon_animations.SlideInAnimation(
                        direction: cartoon_animations.SlideDirection.fromRight,
                        delay: const Duration(milliseconds: 200),
                        child: Card3D(
                          padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                          borderRadius: BorderRadius.circular(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '可用服务',
                                style: AppleFitnessTheme.titleMedium,
                              ),
                              SizedBox(height: AppleFitnessTheme.spacingM),
                              ..._availableProviders.map((provider) => Padding(
                                    padding: EdgeInsets.only(bottom: AppleFitnessTheme.spacingM),
                                    child: Button3D(
                                      text: provider,
                                      icon: _getProviderIcon(provider),
                                      onPressed: () => _switchProvider(provider),
                                      type: _currentProvider == provider 
                                          ? Button3DType.primary 
                                          : Button3DType.outline,
                                      size: Button3DSize.medium,
                                    ),
                                  )),
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

