import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../models/user_achievement_data.dart';
import '../../../core/theme/gymates_colors.dart';

/// 🎴 成就卡片分享组件
/// 
/// 功能：
/// - 生成精美的成就卡片图片
/// - 支持分享到社交媒体
/// - 显示用户统计数据和徽章

class AchievementShareCard extends StatefulWidget {
  final UserAchievementData userData;

  const AchievementShareCard({
    super.key,
    required this.userData,
  });

  @override
  State<AchievementShareCard> createState() => _AchievementShareCardState();
}

class _AchievementShareCardState extends State<AchievementShareCard> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 卡片内容
            RepaintBoundary(
              key: _cardKey,
              child: _buildShareCardContent(),
            ),
            
            // 按钮区域
            _buildActions(),
          ],
        ),
      ),
    );
  }

  /// 构建分享卡片内容
  Widget _buildShareCardContent() {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GyMatesColors.primaryGreen,
            GyMatesColors.primaryPurple,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // 背景装饰图案
          _buildBackgroundPattern(),
          
          // 主要内容
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部Logo和标题
                _buildHeader(),
                
                const SizedBox(height: 24),
                
                // 用户信息
                _buildUserInfo(),
                
                const SizedBox(height: 24),
                
                // 统计数据网格
                _buildStatsGrid(),
                
                const SizedBox(height: 24),
                
                // 成就徽章
                _buildBadges(),
                
                const SizedBox(height: 20),
                
                // 底部标语
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 背景装饰图案
  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _PatternPainter(),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return Row(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gymates',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '健身社交平台',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const Spacer(),
        // 日期
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _formatDate(DateTime.now()),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建用户信息
  Widget _buildUserInfo() {
    return Row(
      children: [
        // 头像
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              widget.userData.avatar,
              style: const TextStyle(fontSize: 30),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.userData.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.userData.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              if (widget.userData.fitnessGoal != null)
                Text(
                  '目标：${widget.userData.fitnessGoal}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建统计数据网格
  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: '💪',
                  label: '训练次数',
                  value: '${widget.userData.totalSessions}',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '⏱️',
                  label: '训练时长',
                  value: '${widget.userData.totalHours.toStringAsFixed(0)}h',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: '🔥',
                  label: '消耗卡路里',
                  value: '${(widget.userData.totalCalories / 1000).toStringAsFixed(1)}K',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '🏆',
                  label: '解锁徽章',
                  value: '${widget.userData.unlockedBadges}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 单个统计项
  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  /// 构建徽章
  Widget _buildBadges() {
    final badges = widget.userData.badges
        .where((badge) => badge.isUnlocked)
        .take(5)
        .toList();

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最新成就',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: badges.map((badge) {
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建底部
  Widget _buildFooter() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '坚持训练 ${widget.userData.consecutiveDays} 天',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: Colors.grey[300]!,
                ),
              ),
              child: const Text(
                '取消',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _shareCard,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.share, size: 18),
              label: Text(
                _isGenerating ? '生成中...' : '分享',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: GyMatesColors.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 分享卡片
  Future<void> _shareCard() async {
    if (_isGenerating) return;

    setState(() => _isGenerating = true);

    try {
      // 生成图片
      final imageBytes = await _captureCard();
      
      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/achievement_card.png');
      await file.writeAsBytes(imageBytes);

      // 分享
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '我在 Gymates 的健身成就 💪',
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ 分享失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  /// 捕获卡片为图片
  Future<Uint8List> _captureCard() async {
    try {
      RenderRepaintBoundary boundary = _cardKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData!.buffer.asUint8List();
    } catch (e) {
      throw Exception('生成图片失败: $e');
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

/// 背景图案绘制器
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 绘制网格
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }

    // 绘制圆形装饰
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      40,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.8),
      60,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

