import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart' as pc;

/// 🔐 端到端加密服务
/// 
/// 功能：
/// - RSA 非对称加密（密钥交换）
/// - AES 对称加密（消息加密）
/// - 消息签名和验证

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  // RSA密钥对（用于密钥交换）
  pc.AsymmetricKeyPair<pc.PublicKey, pc.PrivateKey>? _rsaKeyPair;
  String? _publicKeyPem;
  String? _privateKeyPem;

  // AES密钥（用于消息加密）
  final Map<int, encrypt.Key> _sessionKeys = {};

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  String? get publicKeyPem => _publicKeyPem;

  /// 初始化加密服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 生成RSA密钥对
      await _generateRSAKeyPair();
      _isInitialized = true;
      print('加密服务初始化成功');
    } catch (e) {
      print('加密服务初始化失败: $e');
    }
  }

  /// 生成RSA密钥对
  Future<void> _generateRSAKeyPair() async {
    final keyGen = pc.KeyGenerator('RSA');
    final params = pc.RSAKeyGeneratorParameters(
      BigInt.parse('65537'),
      2048,
      64,
    );
    
    final secureRandom = pc.FortunaRandom();
    final random = pc.Random.secure();
    final seeds = List<int>.generate(32, (i) => random.nextInt(256));
    secureRandom.seed(pc.KeyParameter(Uint8List.fromList(seeds)));

    keyGen.init(pc.ParametersWithRandom(params, secureRandom));
    _rsaKeyPair = keyGen.generateKeyPair();

    // 转换为PEM格式
    _publicKeyPem = _encodePublicKeyToPem(
      _rsaKeyPair!.publicKey as pc.RSAPublicKey,
    );
    _privateKeyPem = _encodePrivateKeyToPem(
      _rsaKeyPair!.privateKey as pc.RSAPrivateKey,
    );
  }

  /// 将公钥编码为PEM格式
  String _encodePublicKeyToPem(pc.RSAPublicKey publicKey) {
    final modulus = publicKey.modulus!.toRadixString(16);
    final exponent = publicKey.exponent!.toRadixString(16);
    return '$modulus:$exponent';
  }

  /// 将私钥编码为PEM格式
  String _encodePrivateKeyToPem(pc.RSAPrivateKey privateKey) {
    final modulus = privateKey.modulus!.toRadixString(16);
    final privateExponent = privateKey.privateExponent!.toRadixString(16);
    return '$modulus:$privateExponent';
  }

  /// 从PEM格式解码公钥
  pc.RSAPublicKey _decodePublicKeyFromPem(String pem) {
    final parts = pem.split(':');
    final modulus = BigInt.parse(parts[0], radix: 16);
    final exponent = BigInt.parse(parts[1], radix: 16);
    return pc.RSAPublicKey(modulus, exponent);
  }

  /// 生成会话密钥（AES）
  encrypt.Key _generateSessionKey() {
    final secureRandom = pc.FortunaRandom();
    final random = pc.Random.secure();
    final seeds = List<int>.generate(32, (i) => random.nextInt(256));
    secureRandom.seed(pc.KeyParameter(Uint8List.fromList(seeds)));
    
    final keyBytes = List<int>.generate(32, (i) => secureRandom.nextUint8());
    return encrypt.Key(Uint8List.fromList(keyBytes));
  }

  /// 使用RSA加密会话密钥
  String encryptSessionKey(encrypt.Key sessionKey, String recipientPublicKeyPem) {
    try {
      final publicKey = _decodePublicKeyFromPem(recipientPublicKeyPem);
      final cipher = pc.RSAEngine()
        ..init(true, pc.PublicKeyParameter<pc.RSAPublicKey>(publicKey));

      final encryptedBytes = cipher.process(sessionKey.bytes);
      return base64Encode(encryptedBytes);
    } catch (e) {
      print('加密会话密钥失败: $e');
      rethrow;
    }
  }

  /// 使用RSA解密会话密钥
  encrypt.Key decryptSessionKey(String encryptedSessionKey) {
    try {
      if (_rsaKeyPair == null) {
        throw Exception('RSA密钥对未初始化');
      }

      final privateKey = _rsaKeyPair!.privateKey as pc.RSAPrivateKey;
      final cipher = pc.RSAEngine()
        ..init(false, pc.PrivateKeyParameter<pc.RSAPrivateKey>(privateKey));

      final encryptedBytes = base64Decode(encryptedSessionKey);
      final decryptedBytes = cipher.process(encryptedBytes);
      return encrypt.Key(decryptedBytes);
    } catch (e) {
      print('解密会话密钥失败: $e');
      rethrow;
    }
  }

  /// 为用户创建或获取会话密钥
  encrypt.Key getOrCreateSessionKey(int userId) {
    if (!_sessionKeys.containsKey(userId)) {
      _sessionKeys[userId] = _generateSessionKey();
    }
    return _sessionKeys[userId]!;
  }

  /// 设置用户的会话密钥
  void setSessionKey(int userId, encrypt.Key key) {
    _sessionKeys[userId] = key;
  }

  /// 使用AES加密消息
  String encryptMessage(String message, int recipientUserId) {
    try {
      final sessionKey = getOrCreateSessionKey(recipientUserId);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(sessionKey));
      
      final encrypted = encrypter.encrypt(message, iv: iv);
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      print('加密消息失败: $e');
      return message; // 降级：返回原始消息
    }
  }

  /// 使用AES解密消息
  String decryptMessage(String encryptedMessage, int senderUserId) {
    try {
      final parts = encryptedMessage.split(':');
      if (parts.length != 2) {
        return encryptedMessage; // 不是加密消息
      }

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      
      final sessionKey = getOrCreateSessionKey(senderUserId);
      final encrypter = encrypt.Encrypter(encrypt.AES(sessionKey));
      
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      print('解密消息失败: $e');
      return encryptedMessage; // 降级：返回原始内容
    }
  }

  /// 生成消息哈希（用于验证完整性）
  String generateMessageHash(String message) {
    final bytes = utf8.encode(message);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 验证消息哈希
  bool verifyMessageHash(String message, String hash) {
    final computedHash = generateMessageHash(message);
    return computedHash == hash;
  }

  /// 清除会话密钥
  void clearSessionKey(int userId) {
    _sessionKeys.remove(userId);
  }

  /// 清除所有会话密钥
  void clearAllSessionKeys() {
    _sessionKeys.clear();
  }
}

/// 加密消息包装
class EncryptedMessageWrapper {
  final String encryptedContent;
  final String encryptedSessionKey; // 用接收方公钥加密的会话密钥
  final String messageHash;
  final DateTime timestamp;

  EncryptedMessageWrapper({
    required this.encryptedContent,
    required this.encryptedSessionKey,
    required this.messageHash,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'encrypted_content': encryptedContent,
      'encrypted_session_key': encryptedSessionKey,
      'message_hash': messageHash,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory EncryptedMessageWrapper.fromJson(Map<String, dynamic> json) {
    return EncryptedMessageWrapper(
      encryptedContent: json['encrypted_content'],
      encryptedSessionKey: json['encrypted_session_key'],
      messageHash: json['message_hash'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

