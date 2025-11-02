import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import '../../../services/video_service.dart';

/// 📹 视频消息组件
/// 
/// 显示视频消息气泡并支持播放

class VideoMessageWidget extends StatefulWidget {
  final String videoUrl;
  final int duration;
  final String? thumbnailUrl;
  final bool isMine;

  const VideoMessageWidget({
    super.key,
    required this.videoUrl,
    required this.duration,
    this.thumbnailUrl,
    this.isMine = false,
  });

  @override
  State<VideoMessageWidget> createState() => _VideoMessageWidgetState();
}

class _VideoMessageWidgetState extends State<VideoMessageWidget> {
  final VideoService _videoService = VideoService();
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _videoService.disposePlayer();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    final success = await _videoService.initializePlayer(
      widget.videoUrl,
      isUrl: true,
    );
    
    if (success) {
      setState(() {
        _controller = _videoService.playerController;
        _isInitialized = true;
      });

      _controller?.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
          });
        }
      });
    }
  }

  void _togglePlay() {
    if (_controller == null) return;

    if (_isPlaying) {
      _videoService.pause();
    } else {
      _videoService.play();
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 全屏播放
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              videoUrl: widget.videoUrl,
            ),
          ),
        );
      },
      child: Container(
        width: 240,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 视频预览或缩略图
            if (_isInitialized && _controller != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: VideoPlayer(_controller!),
              )
            else if (widget.thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
                ),
              )
            else
              _buildPlaceholder(),
            
            // 播放按钮
            Center(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
            
            // 时长标签
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(widget.duration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.videocam,
          color: Colors.white54,
          size: 48,
        ),
      ),
    );
  }
}

/// 📹 视频录制界面
class VideoRecorderWidget extends StatefulWidget {
  final Function(String filePath, int duration) onRecordComplete;
  final VoidCallback? onCancel;

  const VideoRecorderWidget({
    super.key,
    required this.onRecordComplete,
    this.onCancel,
  });

  @override
  State<VideoRecorderWidget> createState() => _VideoRecorderWidgetState();
}

class _VideoRecorderWidgetState extends State<VideoRecorderWidget> {
  final VideoService _videoService = VideoService();
  bool _isInitialized = false;
  bool _isRecording = false;
  int _recordingDuration = 0;
  StreamSubscription? _recordingSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _recordingSubscription?.cancel();
    _videoService.disposeCamera();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final success = await _videoService.initializeCamera();
    if (mounted) {
      setState(() => _isInitialized = success);
    }

    if (!success) {
      widget.onCancel?.call();
    }

    // 监听录制状态
    _recordingSubscription = _videoService.recordingStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isRecording = state.isRecording;
          _recordingDuration = state.duration;
        });
      }
    });
  }

  Future<void> _startRecording() async {
    await _videoService.startRecording();
  }

  Future<void> _stopRecording() async {
    final result = await _videoService.stopRecording();
    if (result != null) {
      widget.onRecordComplete(result.filePath, result.duration);
    }
  }

  Future<void> _cancelRecording() async {
    await _videoService.cancelRecording();
    widget.onCancel?.call();
  }

  Future<void> _switchCamera() async {
    await _videoService.switchCamera();
    setState(() {});
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _videoService.cameraController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 相机预览
            SizedBox.expand(
              child: CameraPreview(_videoService.cameraController!),
            ),
            
            // 顶部工具栏
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // 关闭按钮
                    IconButton(
                      onPressed: _isRecording ? null : _cancelRecording,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    // 录制时长
                    if (_isRecording)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(_recordingDuration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    // 切换相机
                    IconButton(
                      onPressed: _isRecording ? null : _switchCamera,
                      icon: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 底部控制栏
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 占位（保持对齐）
                      const SizedBox(width: 70),
                      
                      // 录制/停止按钮
                      GestureDetector(
                        onTap: _isRecording ? _stopRecording : _startRecording,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: _isRecording ? 32 : 64,
                              height: _isRecording ? 32 : 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(
                                  _isRecording ? 4 : 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // 完成按钮（录制时显示）
                      if (_isRecording)
                        GestureDetector(
                          onTap: _stopRecording,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 70),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isRecording ? '点击 ✓ 完成录制' : '点击红点开始录制',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📹 视频播放器全屏界面
class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final VideoService _videoService = VideoService();
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _videoService.disposePlayer();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    final success = await _videoService.initializePlayer(
      widget.videoUrl,
      isUrl: true,
    );
    
    if (success) {
      setState(() {
        _controller = _videoService.playerController;
        _isInitialized = true;
      });

      _controller?.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
          });
        }
      });

      // 自动播放
      _videoService.play();
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      _videoService.pause();
    } else {
      _videoService.play();
    }
    _resetHideControlsTimer();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _resetHideControlsTimer();
    }
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 视频播放器
            if (_isInitialized && _controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            
            // 控制层
            if (_showControls) ...[
              // 顶部工具栏
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
              
              // 播放/暂停按钮
              Center(
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
              ),
              
              // 底部进度条
              if (_controller != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFF6366F1),
                          bufferedColor: Colors.white30,
                          backgroundColor: Colors.white10,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

