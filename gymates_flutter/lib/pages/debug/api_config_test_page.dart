import 'package:flutter/material.dart';
import '../../core/config/smart_api_config.dart';

/// 🧪 API配置测试页面
/// 
/// 用于测试和验证智能API配置系统
class ApiConfigTestPage extends StatelessWidget {
  const ApiConfigTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API配置测试'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🌍 环境信息',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('平台', SmartApiConfig.getEnvironmentInfo()['platform']),
                    _buildInfoRow('是否Web', SmartApiConfig.getEnvironmentInfo()['isWeb']),
                    _buildInfoRow('是否Android', SmartApiConfig.getEnvironmentInfo()['isAndroid']),
                    _buildInfoRow('是否iOS', SmartApiConfig.getEnvironmentInfo()['isIOS']),
                    const Divider(),
                    _buildInfoRow('API地址', SmartApiConfig.baseUrl),
                    _buildInfoRow('API基础URL', SmartApiConfig.apiBaseUrl),
                    _buildInfoRow('WebSocket URL', SmartApiConfig.wsBaseUrl),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '🔧 测试功能',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    SmartApiConfig.printEnvironmentInfo();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('环境信息已打印到控制台')),
                    );
                  },
                  child: const Text('打印环境信息'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    SmartApiConfig.resetCache();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('缓存已重置')),
                    );
                  },
                  child: const Text('重置缓存'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 测试自定义URL
                SmartApiConfig.setCustomUrl('http://test.example.com:9999');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已设置自定义URL: http://test.example.com:9999')),
                );
              },
              child: const Text('设置自定义URL'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
