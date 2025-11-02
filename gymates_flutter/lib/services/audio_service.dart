import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

/// 🎤 音频服务
/// 
/// 功能：
/// - 录音（语音消息）
/// - 播放音频
/// - 音频文件管理

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  String? _currentRecordingPath;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  
  bool _isRecording = false;
  bool _isPlaying = false;
  
  // 播放状态流
  final StreamController<AudioPlayerState> _playerStateController = 
      StreamController<AudioPlayerState>.broadcast();
  
  // 录音状态流
  final StreamController<RecordingState> _recordingStateController = 
      StreamController<RecordingState>.broadcast();

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  int get recordingDuration => _recordingDuration;
  
  Stream<AudioPlayerState> get playerStateStream => _playerStateController.stream;
  Stream<RecordingState> get recordingStateStream => _recordingStateController.stream;

  /// 初始化音频服务
  Future<void> initialize() async {
    // 监听播放器状态
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      _playerStateController.add(AudioPlayerState(
        isPlaying: _isPlaying,
        state: state,
      ));
    });

    _player.onDurationChanged.listen((duration) {
      _playerStateController.add(AudioPlayerState(
        isPlaying: _isPlaying,
        duration: duration,
      ));
    });

    _player.onPositionChanged.listen((position) {
      _playerStateController.add(AudioPlayerState(
        isPlaying: _isPlaying,
        position: position,
      ));
    });
  }

  /// 请求麦克风权限
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// 开始录音
  Future<String?> startRecording() async {
    try {
      // 检查权限
      if (!await requestMicrophonePermission()) {
        print('麦克风权限被拒绝');
        return null;
      }

      // 停止当前播放
      await stopPlaying();

      // 创建临时文件
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/audio_message_$timestamp.m4a';

      // 开始录音
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

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
      
      print('开始录音: $_currentRecordingPath');
      return _currentRecordingPath;
    } catch (e) {
      print('开始录音失败: $e');
      _isRecording = false;
      return null;
    }
  }

  /// 停止录音
  Future<RecordingResult?> stopRecording() async {
    try {
      if (!_isRecording) {
        return null;
      }

      final path = await _recorder.stop();
      _recordingTimer?.cancel();
      _isRecording = false;

      _recordingStateController.add(RecordingState(isRecording: false));

      if (path != null && await File(path).exists()) {
        final file = File(path);
        final fileSize = await file.length();
        
        print('录音完成: $path, 时长: $_recordingDuration秒, 大小: $fileSize字节');
        
        return RecordingResult(
          filePath: path,
          duration: _recordingDuration,
          fileSize: fileSize,
        );
      }

      return null;
    } catch (e) {
      print('停止录音失败: $e');
      _isRecording = false;
      _recordingStateController.add(RecordingState(isRecording: false));
      return null;
    }
  }

  /// 取消录音
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        _recordingTimer?.cancel();
        _isRecording = false;
        _recordingStateController.add(RecordingState(isRecording: false));

        // 删除临时文件
        if (_currentRecordingPath != null) {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
        
        print('录音已取消');
      }
    } catch (e) {
      print('取消录音失败: $e');
    }
  }

  /// 播放音频
  Future<void> playAudio(String audioPath, {bool isUrl = false}) async {
    try {
      await stopPlaying();

      if (isUrl) {
        await _player.play(UrlSource(audioPath));
      } else {
        await _player.play(DeviceFileSource(audioPath));
      }

      print('开始播放: $audioPath');
    } catch (e) {
      print('播放音频失败: $e');
    }
  }

  /// 暂停播放
  Future<void> pausePlaying() async {
    try {
      await _player.pause();
    } catch (e) {
      print('暂停播放失败: $e');
    }
  }

  /// 恢复播放
  Future<void> resumePlaying() async {
    try {
      await _player.resume();
    } catch (e) {
      print('恢复播放失败: $e');
    }
  }

  /// 停止播放
  Future<void> stopPlaying() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      print('停止播放失败: $e');
    }
  }

  /// 设置播放位置
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      print('设置播放位置失败: $e');
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    _recordingTimer?.cancel();
    await _recorder.dispose();
    await _player.dispose();
    await _playerStateController.close();
    await _recordingStateController.close();
  }
}

/// 音频播放器状态
class AudioPlayerState {
  final bool isPlaying;
  final PlayerState? state;
  final Duration? duration;
  final Duration? position;

  AudioPlayerState({
    required this.isPlaying,
    this.state,
    this.duration,
    this.position,
  });
}

/// 录音状态
class RecordingState {
  final bool isRecording;
  final int duration;

  RecordingState({
    required this.isRecording,
    this.duration = 0,
  });
}

/// 录音结果
class RecordingResult {
  final String filePath;
  final int duration;
  final int fileSize;

  RecordingResult({
    required this.filePath,
    required this.duration,
    required this.fileSize,
  });
}

