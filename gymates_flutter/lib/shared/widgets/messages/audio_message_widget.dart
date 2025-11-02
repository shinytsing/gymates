import 'package:flutter/material.dart';
import 'dart:async';
import '../../../services/audio_service.dart';

/// 🎤 语音消息组件
/// 
/// 功能：
/// - 显示语音消息气泡
/// - 播放/暂停控制
/// - 播放进度显示
/// - 时长显示

class AudioMessageWidget extends StatefulWidget {
  final String audioUrl;
  final int duration;
  final bool isMine;
  final VoidCallback? onPlayComplete;

  const AudioMessageWidget({
    super.key,
    required this.audioUrl,
    required this.duration,
    this.isMine = false,
    this.onPlayComplete,
  });

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _totalDuration = Duration(seconds: widget.duration);
    
    // 监听播放状态
    _stateSubscription = _audioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.isPlaying;
          if (state.position != null) {
            _currentPosition = state.position!;
          }
          if (state.duration != null) {
            _totalDuration = state.duration!;
          }
        });
        
        // 播放完成回调
        if (state.state == PlayerState.completed) {
          widget.onPlayComplete?.call();
        }
      }
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioService.pausePlaying();
    } else {
      await _audioService.playAudio(widget.audioUrl, isUrl: true);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalDuration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 播放/暂停按钮
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.isMine
                    ? Colors.white.withOpacity(0.3)
                    : const Color(0xFF6366F1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.isMine ? Colors.white : const Color(0xFF6366F1),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 波形和时长
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 播放进度条
                Stack(
                  children: [
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: widget.isMine
                            ? Colors.white.withOpacity(0.3)
                            : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: widget.isMine
                              ? Colors.white
                              : const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 时长显示
                Text(
                  _isPlaying
                      ? '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}'
                      : _formatDuration(_totalDuration),
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isMine
                        ? Colors.white.withOpacity(0.8)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎙️ 录音界面组件
class AudioRecorderWidget extends StatefulWidget {
  final Function(String filePath, int duration) onRecordComplete;
  final VoidCallback? onCancel;

  const AudioRecorderWidget({
    super.key,
    required this.onRecordComplete,
    this.onCancel,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget>
    with SingleTickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  bool _isRecording = false;
  int _recordingDuration = 0;
  StreamSubscription? _recordingSubscription;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _startRecording();
  }

  @override
  void dispose() {
    _recordingSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final path = await _audioService.startRecording();
    if (path != null) {
      setState(() => _isRecording = true);
      
      // 监听录音状态
      _recordingSubscription = _audioService.recordingStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isRecording = state.isRecording;
            _recordingDuration = state.duration;
          });
        }
      });
    } else {
      // 权限被拒绝或录音失败
      widget.onCancel?.call();
    }
  }

  Future<void> _stopRecording() async {
    final result = await _audioService.stopRecording();
    if (result != null) {
      widget.onRecordComplete(result.filePath, result.duration);
    }
  }

  Future<void> _cancelRecording() async {
    await _audioService.cancelRecording();
    widget.onCancel?.call();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部拖动条
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            
            // 录音状态提示
            Text(
              _isRecording ? '正在录音...' : '准备中...',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 32),
            
            // 录音动画和时长
            Stack(
              alignment: Alignment.center,
              children: [
                // 外圈动画
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      width: 160 + (_animationController.value * 40),
                      height: 160 + (_animationController.value * 40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6366F1).withOpacity(
                          0.1 - (_animationController.value * 0.05),
                        ),
                      ),
                    );
                  },
                ),
                // 中圈
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                  ),
                ),
                // 内圈（麦克风图标）
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6366F1),
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 录音时长
            Text(
              _formatDuration(_recordingDuration),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 48),
            
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 取消按钮
                GestureDetector(
                  onTap: _cancelRecording,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFFEF4444),
                      size: 32,
                    ),
                  ),
                ),
                // 完成按钮
                GestureDetector(
                  onTap: _isRecording ? _stopRecording : null,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE5E7EB),
                    ),
                    child: Icon(
                      Icons.check,
                      color: _isRecording ? Colors.white : const Color(0xFF9CA3AF),
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 提示文字
            const Text(
              '点击 ✓ 完成录音，点击 ✕ 取消',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

