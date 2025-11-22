import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import './websocket_service.dart';

/// 📞 WebRTC 实时通话服务
/// 
/// 功能：
/// - 语音通话
/// - 视频通话
/// - 信令处理
/// - 连接管理

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  final WebSocketService _wsService = WebSocketService();
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  
  final List<RTCIceCandidate> _iceCandidates = [];
  
  bool _isInCall = false;
  bool _isVideoCall = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  
  // 流控制器
  final StreamController<MediaStream?> _localStreamController =
      StreamController<MediaStream?>.broadcast();
  final StreamController<MediaStream?> _remoteStreamController =
      StreamController<MediaStream?>.broadcast();
  final StreamController<CallState> _callStateController =
      StreamController<CallState>.broadcast();

  // 获取流
  Stream<MediaStream?> get localStream => _localStreamController.stream;
  Stream<MediaStream?> get remoteStream => _remoteStreamController.stream;
  Stream<CallState> get callState => _callStateController.stream;
  
  // 状态
  bool get isInCall => _isInCall;
  bool get isVideoCall => _isVideoCall;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;

  /// ICE服务器配置
  Map<String, dynamic> get _iceServers => {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
          // 生产环境应使用TURN服务器
          // {
          //   'urls': 'turn:your-turn-server.com:3478',
          //   'username': 'username',
          //   'credential': 'password'
          // }
        ]
      };

  /// 媒体约束配置
  Map<String, dynamic> _getMediaConstraints(bool isVideo) {
    return {
      'audio': true,
      'video': isVideo
          ? {
              'mandatory': {
                'minWidth': '640',
                'minHeight': '480',
                'minFrameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
          : false,
    };
  }

  /// 发起通话
  Future<bool> makeCall({
    required int targetUserId,
    required bool isVideo,
  }) async {
    try {
      _isVideoCall = isVideo;
      
      // 创建本地媒体流
      _localStream = await navigator.mediaDevices.getUserMedia(
        _getMediaConstraints(isVideo),
      );
      _localStreamController.add(_localStream);

      // 创建PeerConnection
      _peerConnection = await createPeerConnection(_iceServers);
      
      // 添加本地流
      _localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });

      // 监听远程流
      _peerConnection?.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteStreamController.add(_remoteStream);
        }
      };

      // 监听ICE候选
      _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
        _wsService.send({
          'type': 'ice_candidate',
          'target_user_id': targetUserId,
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
      };

      // 创建并发送Offer
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      _wsService.send({
        'type': 'call_offer',
        'target_user_id': targetUserId,
        'is_video': isVideo,
        'offer': {
          'type': offer.type,
          'sdp': offer.sdp,
        },
      });

      _isInCall = true;
      _callStateController.add(CallState(
        state: CallStateEnum.calling,
        isVideo: isVideo,
      ));

      print('发起${isVideo ? "视频" : "语音"}通话: $targetUserId');
      return true;
    } catch (e) {
      print('发起通话失败: $e');
      await endCall();
      return false;
    }
  }

  /// 接听通话
  Future<bool> answerCall({
    required Map<String, dynamic> offerData,
    required int callerUserId,
  }) async {
    try {
      final isVideo = offerData['is_video'] ?? false;
      _isVideoCall = isVideo;

      // 创建本地媒体流
      _localStream = await navigator.mediaDevices.getUserMedia(
        _getMediaConstraints(isVideo),
      );
      _localStreamController.add(_localStream);

      // 创建PeerConnection
      _peerConnection = await createPeerConnection(_iceServers);
      
      // 添加本地流
      _localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });

      // 监听远程流
      _peerConnection?.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteStreamController.add(_remoteStream);
        }
      };

      // 监听ICE候选
      _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
        _wsService.send({
          'type': 'ice_candidate',
          'target_user_id': callerUserId,
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
      };

      // 设置远程描述
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(
          offerData['offer']['sdp'],
          offerData['offer']['type'],
        ),
      );

      // 创建并发送Answer
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      _wsService.send({
        'type': 'call_answer',
        'target_user_id': callerUserId,
        'answer': {
          'type': answer.type,
          'sdp': answer.sdp,
        },
      });

      _isInCall = true;
      _callStateController.add(CallState(
        state: CallStateEnum.connected,
        isVideo: isVideo,
      ));

      print('接听${isVideo ? "视频" : "语音"}通话: $callerUserId');
      return true;
    } catch (e) {
      print('接听通话失败: $e');
      await endCall();
      return false;
    }
  }

  /// 处理Answer响应
  Future<void> handleAnswer(Map<String, dynamic> answerData) async {
    try {
      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(
          answerData['answer']['sdp'],
          answerData['answer']['type'],
        ),
      );

      // 添加缓存的ICE候选
      for (var candidate in _iceCandidates) {
        await _peerConnection?.addCandidate(candidate);
      }
      _iceCandidates.clear();

      _callStateController.add(CallState(
        state: CallStateEnum.connected,
        isVideo: _isVideoCall,
      ));

      print('通话已连接');
    } catch (e) {
      print('处理Answer失败: $e');
    }
  }

  /// 处理ICE候选
  Future<void> handleIceCandidate(Map<String, dynamic> candidateData) async {
    try {
      final candidate = RTCIceCandidate(
        candidateData['candidate']['candidate'],
        candidateData['candidate']['sdpMid'],
        candidateData['candidate']['sdpMLineIndex'],
      );

      final remoteDesc = await _peerConnection?.getRemoteDescription();
      if (remoteDesc != null) {
        await _peerConnection?.addCandidate(candidate);
      } else {
        _iceCandidates.add(candidate);
      }
    } catch (e) {
      print('处理ICE候选失败: $e');
    }
  }

  /// 拒绝通话
  Future<void> rejectCall(int callerUserId) async {
    _wsService.send({
      'type': 'call_reject',
      'target_user_id': callerUserId,
    });
    
    _callStateController.add(CallState(
      state: CallStateEnum.rejected,
      isVideo: false,
    ));
  }

  /// 结束通话
  Future<void> endCall() async {
    try {
      // 停止本地流
      _localStream?.getTracks().forEach((track) {
        track.stop();
      });
      _localStream?.dispose();
      _localStream = null;

      // 停止远程流
      _remoteStream?.dispose();
      _remoteStream = null;

      // 关闭连接
      await _peerConnection?.close();
      _peerConnection = null;

      _iceCandidates.clear();
      _isInCall = false;

      _localStreamController.add(null);
      _remoteStreamController.add(null);
      _callStateController.add(CallState(
        state: CallStateEnum.ended,
        isVideo: _isVideoCall,
      ));

      print('通话已结束');
    } catch (e) {
      print('结束通话失败: $e');
    }
  }

  /// 切换静音
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !_isMuted;
    });
    print('静音: $_isMuted');
  }

  /// 切换视频
  Future<void> toggleVideo() async {
    if (!_isVideoCall) return;
    
    _isVideoEnabled = !_isVideoEnabled;
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = _isVideoEnabled;
    });
    print('视频: $_isVideoEnabled');
  }

  /// 切换摄像头
  Future<void> switchCamera() async {
    if (!_isVideoCall || _localStream == null) return;

    final videoTrack = _localStream!.getVideoTracks().first;
    await Helper.switchCamera(videoTrack);
    print('切换摄像头');
  }

  /// 释放资源
  Future<void> dispose() async {
    await endCall();
    await _localStreamController.close();
    await _remoteStreamController.close();
    await _callStateController.close();
  }
}

/// 通话状态枚举
enum CallStateEnum {
  idle,       // 空闲
  calling,    // 呼叫中
  ringing,    // 响铃中
  connected,  // 已连接
  ended,      // 已结束
  rejected,   // 已拒绝
  failed,     // 失败
}

/// 通话状态
class CallState {
  final CallStateEnum state;
  final bool isVideo;
  final String? errorMessage;

  CallState({
    required this.state,
    required this.isVideo,
    this.errorMessage,
  });
}

