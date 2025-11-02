/// 用户相关数据模型

library;

/// 用户模型（简化版，用于认证）
class UserModel {
  final int id;
  final String email;
  final String username;
  final String? phone;
  final String? avatar;
  final String? bio;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.phone,
    this.avatar,
    this.bio,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      bio: json['bio'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

