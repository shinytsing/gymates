import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

/// 📹 视频服务
/// 
/// 功能：
/// - 录制视频消息
/// - 播放视频
/// - 视频预览

class VideoService {
  static final VideoService _instance = VideoService._internal();
  factory VideoService() => _instance;
  VideoService._internal();

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  VideoPlayerController? _playerController;
  
  bool _isRecording = false;
  bool _isInitialized = false;
  
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  
  final StreamController<RecordingState> _recordingStateController =
      StreamController<RecordingState>.broadcast();

  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;
  CameraController? get cameraController => _cameraController;
  VideoPlayerController? get playerController => _playerController;
  
  Stream<RecordingState> get recordingStateStream => _recordingStateController.stream;

  /// 请求相机权限
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// 请求麦克风权限
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// 初始化相机
  Future<bool> initializeCamera({bool useFrontCamera = false}) async {
    try {
      // 检查权限
      if (!await requestCameraPermission() || !await requestMicrophonePermission()) {
        print('相机或麦克风权限被拒绝');
        return false;
      }

      // 获取可用相机
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        print('没有可用的相机');
        return false;
      }

      // 选择相机（前置或后置）
      final camera = _cameras!.firstWhere(
        (camera) => useFrontCamera
            ? camera.lensDirection == CameraLensDirection.front
            : camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      // 初始化相机控制器
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      _isInitialized = true;
      
      print('相机初始化成功');
      return true;
    } catch (e) {
      print('初始化相机失败: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// 切换相机（前置/后置）
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      return;
    }

    final isFrontCamera = _cameraController?.description.lensDirection ==
        CameraLensDirection.front;
    
    await disposeCamera();
    await initializeCamera(useFrontCamera: !isFrontCamera);
  }

  /// 开始录制视频
  Future<String?> startRecording() async {
    try {
      if (!_isInitialized || _cameraController == null) {
        print('相机未初始化');
        return null;
      }

      if (_isRecording) {
        print('已经在录制中');
        return null;
      }

      await _cameraController!.startVideoRecording();
      _isRecording = true;
      _recordingDuration = 0;

      // 开始计时
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration++;
        _recordingStateController.add(RecordingState(
          isRecording: true,
          duration: _recordingDuration,
        ));
      });

      _recordingStateController.add(RecordingState(isRecording: true));
      
      print('开始录制视频');
      return 'recording';
    } catch (e) {
      print('开始录制视频失败: $e');
      _isRecording = false;
      return null;
    }
  }

  /// 停止录制视频
  Future<VideoRecordingResult?> stopRecording() async {
    try {
      if (!_isRecording || _cameraController == null) {
        return null;
      }

      final XFile videoFile = await _cameraController!.stopVideoRecording();
      _recordingTimer?.cancel();
      _isRecording = false;

      _recordingStateController.add(RecordingState(isRecording: false));

      final file = File(videoFile.path);
      final fileSize = await file.length();
      
      print('录制完成: ${videoFile.path}, 时长: $_recordingDuration秒, 大小: $fileSize字节');
      
      return VideoRecordingResult(
        filePath: videoFile.path,
        duration: _recordingDuration,
        fileSize: fileSize,
      );
    } catch (e) {
      print('停止录制视频失败: $e');
      _isRecording = false;
      _recordingStateController.add(RecordingState(isRecording: false));
      return null;
    }
  }

  /// 取消录制
  Future<void> cancelRecording() async {
    try {
      if (_isRecording && _cameraController != null) {
        final XFile videoFile = await _cameraController!.stopVideoRecording();
        _recordingTimer?.cancel();
        _isRecording = false;
        _recordingStateController.add(RecordingState(isRecording: false));

        // 删除录制的文件
        final file = File(videoFile.path);
        if (await file.exists()) {
          await file.delete();
        }
        
        print('录制已取消');
      }
    } catch (e) {
      print('取消录制失败: $e');
    }
  }

  /// 初始化视频播放器
  Future<bool> initializePlayer(String videoPath, {bool isUrl = false}) async {
    try {
      // 释放之前的播放器
      await disposePlayer();

      if (isUrl) {
        _playerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));
      } else {
        _playerController = VideoPlayerController.file(File(videoPath));
      }

      await _playerController!.initialize();
      
      print('视频播放器初始化成功');
      return true;
    } catch (e) {
      print('初始化视频播放器失败: $e');
      return false;
    }
  }

  /// 播放视频
  Future<void> play() async {
    try {
      await _playerController?.play();
    } catch (e) {
      print('播放视频失败: $e');
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    try {
      await _playerController?.pause();
    } catch (e) {
      print('暂停播放失败: $e');
    }
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      await _playerController?.pause();
      await _playerController?.seekTo(Duration.zero);
    } catch (e) {
      print('停止播放失败: $e');
    }
  }

  /// 设置播放位置
  Future<void> seekTo(Duration position) async {
    try {
      await _playerController?.seekTo(position);
    } catch (e) {
      print('设置播放位置失败: $e');
    }
  }

  /// 释放相机资源
  Future<void> disposeCamera() async {
    _recordingTimer?.cancel();
    await _cameraController?.dispose();
    _cameraController = null;
    _isInitialized = false;
  }

  /// 释放播放器资源
  Future<void> disposePlayer() async {
    await _playerController?.dispose();
    _playerController = null;
  }

  /// 释放所有资源
  Future<void> dispose() async {
    await disposeCamera();
    await disposePlayer();
    await _recordingStateController.close();
  }
}

/// 录制状态
class RecordingState {
  final bool isRecording;
  final int duration;

  RecordingState({
    required this.isRecording,
    this.duration = 0,
  });
}

/// 视频录制结果
class VideoRecordingResult {
  final String filePath;
  final int duration;
  final int fileSize;

  VideoRecordingResult({
    required this.filePath,
    required this.duration,
    required this.fileSize,
  });
}

