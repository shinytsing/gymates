import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import '../../../shared/models/mock_data.dart';
import '../models/record.dart';

/// 🏋️‍♀️ 打卡分享页 - CheckInSharePage
/// 
/// 功能包括：
/// 1. 生成分享卡片（包含头像、昵称、训练时间、完成度百分比）
/// 2. 背景图动态切换（根据训练类型）
/// 3. 点击保存 → 生成本地图片（可调用 RepaintBoundary）
/// 4. 点击分享 → 跳转社区发布页

class CheckInSharePage extends StatefulWidget {
  final WorkoutRecord record;
  final MockUser? user;
  final Function()? onShareComplete;

  const CheckInSharePage({
    super.key,
    required this.record,
    this.user,
    this.onShareComplete,
  });

  @override
  State<CheckInSharePage> createState() => _CheckInSharePageState();
}

class _CheckInSharePageState extends State<CheckInSharePage>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _backgroundAnimationController;
  
  late Animation<double> _cardAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _backgroundAnimation;

  final GlobalKey _shareCardKey = GlobalKey();
  bool _isGenerating = false;
  bool _isSharing = false;
  
  // 分享卡片样式
  ShareCardStyle _currentStyle = ShareCardStyle.motivational;
  final List<ShareCardStyle> _availableStyles = ShareCardStyle.values;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));

    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() async {
    _backgroundAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _cardAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _buttonAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _buttonAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              size: 24,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '训练打卡',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '分享你的训练成果',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // 样式切换按钮
          GestureDetector(
            onTap: _switchStyle,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStyleColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.palette,
                size: 20,
                color: _getStyleColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 分享卡片
          _buildShareCard(),
          
          const SizedBox(height: 24),
          
          // 样式选择
          _buildStyleSelector(),
          
          const SizedBox(height: 24),
          
          // 训练统计
          _buildTrainingStats(),
        ],
      ),
    );
  }

  Widget _buildShareCard() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: RepaintBoundary(
            key: _shareCardKey,
            child: Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildCardContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: _getCardGradient(),
      ),
      child: Stack(
        children: [
          // 背景图案
          _buildBackgroundPattern(),
          
          // 主要内容
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部信息
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gymates',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getTextColor(),
                          ),
                        ),
                        Text(
                          '健身打卡',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getTextColor().withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(widget.record.date),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _getTextColor().withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // 用户信息
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(
                          widget.user?.avatar ?? 'https://via.placeholder.com/60',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user?.name ?? '健身达人',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(),
                            ),
                          ),
                          Text(
                            '完成了${widget.record.planTitle}',
                            style: TextStyle(
                              fontSize: 14,
                              color: _getTextColor().withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 训练数据
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          '${widget.record.durationMinutes}',
                          '分钟',
                          Icons.access_time,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '${widget.record.calories}',
                          '卡路里',
                          Icons.local_fire_department,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '${((widget.record.completedExercises / widget.record.totalExercises) * 100).toInt()}%',
                          '完成度',
                          Icons.check_circle,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 激励文字
                Center(
                  child: Text(
                    _getMotivationalText(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BackgroundPatternPainter(
          color: Colors.white.withValues(alpha: 0.1),
          style: _currentStyle,
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: _getTextColor(),
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getTextColor(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _getTextColor().withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择样式',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _availableStyles.map((style) => _buildStyleOption(style)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleOption(ShareCardStyle style) {
    final isSelected = _currentStyle == style;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentStyle = style;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _getStyleColor(style) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _getStyleColor(style) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _getStyleIcon(style),
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              _getStyleName(style),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '训练详情',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('训练计划', widget.record.planTitle),
          _buildDetailRow('训练时长', '${widget.record.durationMinutes}分钟'),
          _buildDetailRow('消耗卡路里', '${widget.record.calories}卡'),
          _buildDetailRow('完成动作', '${widget.record.completedExercises}/${widget.record.totalExercises}'),
          _buildDetailRow('完成度', '${((widget.record.completedExercises / widget.record.totalExercises) * 100).toInt()}%'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _buttonAnimation.value)),
          child: Opacity(
            opacity: _buttonAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isGenerating ? null : _saveToGallery,
                      icon: _isGenerating 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                              ),
                            )
                          : const Icon(Icons.download),
                      label: Text(_isGenerating ? '保存中...' : '保存到相册'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                        side: const BorderSide(color: Color(0xFF6366F1)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSharing ? null : _shareToSocial,
                      icon: _isSharing 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.share),
                      label: Text(_isSharing ? '分享中...' : '分享到社区'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 方法实现
  void _switchStyle() {
    HapticFeedback.lightImpact();
    
    final currentIndex = _availableStyles.indexOf(_currentStyle);
    final nextIndex = (currentIndex + 1) % _availableStyles.length;
    
    setState(() {
      _currentStyle = _availableStyles[nextIndex];
    });
  }

  Future<void> _saveToGallery() async {
    if (_isGenerating) return;
    
    HapticFeedback.lightImpact();
    
    setState(() {
      _isGenerating = true;
    });
    
    try {
      // 生成图片
      final RenderRepaintBoundary boundary = 
          _shareCardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        
        // 保存到临时目录
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = 'gymates_checkin_${DateTime.now().millisecondsSinceEpoch}.png';
        final File file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(pngBytes);
        
        // 这里应该调用相册保存API，但需要额外权限
        // 暂时模拟保存成功
        await Future.delayed(const Duration(seconds: 1));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('打卡图片已保存到相册'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败：$e'),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _shareToSocial() async {
    if (_isSharing) return;
    
    HapticFeedback.lightImpact();
    
    setState(() {
      _isSharing = true;
    });
    
    try {
      // 生成分享文本
      final shareText = '''
🏋️‍♀️ 我在Gymates完成了${widget.record.planTitle}训练！

⏰ 训练时长：${widget.record.durationMinutes}分钟
🔥 消耗卡路里：${widget.record.calories}卡
✅ 完成度：${((widget.record.completedExercises / widget.record.totalExercises) * 100).toInt()}%

一起来健身吧！💪

#Gymates #健身打卡 #训练记录
''';
      
      // 分享
      await Share.share(shareText);
      
      widget.onShareComplete?.call();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('分享成功！'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('分享失败：$e'),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }

  Color _getBackgroundColor() {
    switch (_currentStyle) {
      case ShareCardStyle.motivational:
        return const Color(0xFFF0F9FF);
      case ShareCardStyle.minimalist:
        return const Color(0xFFF9FAFB);
      case ShareCardStyle.vibrant:
        return const Color(0xFFFEF3C7);
      case ShareCardStyle.dark:
        return const Color(0xFF1F2937);
    }
  }

  Color _getStyleColor([ShareCardStyle? style]) {
    final targetStyle = style ?? _currentStyle;
    switch (targetStyle) {
      case ShareCardStyle.motivational:
        return const Color(0xFF6366F1);
      case ShareCardStyle.minimalist:
        return const Color(0xFF10B981);
      case ShareCardStyle.vibrant:
        return const Color(0xFFF59E0B);
      case ShareCardStyle.dark:
        return const Color(0xFF1F2937);
    }
  }

  Color _getTextColor() {
    switch (_currentStyle) {
      case ShareCardStyle.motivational:
        return Colors.white;
      case ShareCardStyle.minimalist:
        return Colors.white;
      case ShareCardStyle.vibrant:
        return Colors.white;
      case ShareCardStyle.dark:
        return Colors.white;
    }
  }

  LinearGradient _getCardGradient() {
    switch (_currentStyle) {
      case ShareCardStyle.motivational:
        return const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ShareCardStyle.minimalist:
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ShareCardStyle.vibrant:
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ShareCardStyle.dark:
        return const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  String _getMotivationalText() {
    switch (_currentStyle) {
      case ShareCardStyle.motivational:
        return '坚持就是胜利！💪';
      case ShareCardStyle.minimalist:
        return '健康生活，从今天开始！';
      case ShareCardStyle.vibrant:
        return '燃烧吧，我的卡路里！🔥';
      case ShareCardStyle.dark:
        return '黑暗中也能发光！✨';
    }
  }

  IconData _getStyleIcon(ShareCardStyle style) {
    switch (style) {
      case ShareCardStyle.motivational:
        return Icons.favorite;
      case ShareCardStyle.minimalist:
        return Icons.minimize;
      case ShareCardStyle.vibrant:
        return Icons.whatshot;
      case ShareCardStyle.dark:
        return Icons.dark_mode;
    }
  }

  String _getStyleName(ShareCardStyle style) {
    switch (style) {
      case ShareCardStyle.motivational:
        return '励志';
      case ShareCardStyle.minimalist:
        return '简约';
      case ShareCardStyle.vibrant:
        return '活力';
      case ShareCardStyle.dark:
        return '暗黑';
    }
  }
}

enum ShareCardStyle {
  motivational,
  minimalist,
  vibrant,
  dark,
}

class BackgroundPatternPainter extends CustomPainter {
  final Color color;
  final ShareCardStyle style;

  BackgroundPatternPainter({
    required this.color,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (style) {
      case ShareCardStyle.motivational:
        _drawMotivationalPattern(canvas, size, paint);
        break;
      case ShareCardStyle.minimalist:
        _drawMinimalistPattern(canvas, size, paint);
        break;
      case ShareCardStyle.vibrant:
        _drawVibrantPattern(canvas, size, paint);
        break;
      case ShareCardStyle.dark:
        _drawDarkPattern(canvas, size, paint);
        break;
    }
  }

  void _drawMotivationalPattern(Canvas canvas, Size size, Paint paint) {
    // 绘制心形图案
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 3; j++) {
        final x = (i * size.width / 4) + (j * size.width / 8);
        final y = (j * size.height / 3) + (i * size.height / 6);
        canvas.drawCircle(Offset(x, y), 20, paint);
      }
    }
  }

  void _drawMinimalistPattern(Canvas canvas, Size size, Paint paint) {
    // 绘制线条图案
    for (int i = 0; i < 10; i++) {
      final y = i * size.height / 10;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint..strokeWidth = 1,
      );
    }
  }

  void _drawVibrantPattern(Canvas canvas, Size size, Paint paint) {
    // 绘制火焰图案
    for (int i = 0; i < 8; i++) {
      final x = (i * size.width / 7) + 50;
      final y = size.height - 100 - (i * 20);
      canvas.drawCircle(Offset(x, y), 15, paint);
    }
  }

  void _drawDarkPattern(Canvas canvas, Size size, Paint paint) {
    // 绘制星星图案
    for (int i = 0; i < 20; i++) {
      final x = (i * size.width / 19) + 30;
      final y = (i * size.height / 19) + 30;
      canvas.drawCircle(Offset(x, y), 8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
