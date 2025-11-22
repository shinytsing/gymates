import 'dart:convert';
import 'package:flutter/material.dart';

/// 动作库模型
class ExerciseLibrary {
  final int id;
  final String name;
  final String? nameZh; // 中文名称
  final String part; // 肌肉群
  final String level; // 难度级别
  final String type; // 动作类型
  final String equipment; // 器械
  final List<String> tags;
  final String description;
  final List<String> instructions;
  final String imageUrl;
  final String? videoUrl;
  final String muscleGroups;
  final int estimatedCalories;
  final int estimatedDuration;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExerciseLibrary({
    required this.id,
    required this.name,
    this.nameZh,
    required this.part,
    required this.level,
    required this.type,
    required this.equipment,
    required this.tags,
    required this.description,
    required this.instructions,
    required this.imageUrl,
    this.videoUrl,
    required this.muscleGroups,
    required this.estimatedCalories,
    required this.estimatedDuration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseLibrary.fromJson(Map<String, dynamic> json) {
    // 解析 tags
    List<String> tagsList = [];
    if (json['tags'] != null && json['tags'].isNotEmpty) {
      try {
        tagsList = List<String>.from(jsonDecode(json['tags']));
      } catch (e) {
        tagsList = [];
      }
    }

    // 解析 instructions
    List<String> instructionsList = [];
    if (json['instructions'] != null && json['instructions'].isNotEmpty) {
      try {
        instructionsList = List<String>.from(jsonDecode(json['instructions']));
      } catch (e) {
        instructionsList = [];
      }
    }

    return ExerciseLibrary(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameZh: json['name_zh'],
      part: json['part'] ?? '',
      level: json['level'] ?? 'intermediate',
      type: json['type'] ?? 'strength',
      equipment: json['equipment'] ?? '',
      tags: tagsList,
      description: json['description'] ?? '',
      instructions: instructionsList,
      imageUrl: json['image_url'] ?? '',
      videoUrl: json['video_url'],
      muscleGroups: json['muscle_groups'] ?? '',
      estimatedCalories: json['estimated_calories'] ?? 0,
      estimatedDuration: json['estimated_duration'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'part': part,
      'level': level,
      'type': type,
      'equipment': equipment,
      'tags': jsonEncode(tags),
      'description': description,
      'instructions': jsonEncode(instructions),
      'image_url': imageUrl,
      'video_url': videoUrl,
      'muscle_groups': muscleGroups,
      'estimated_calories': estimatedCalories,
      'estimated_duration': estimatedDuration,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 获取难度级别的中文显示
  String get levelText {
    switch (level) {
      case 'beginner':
        return '初级';
      case 'intermediate':
        return '中级';
      case 'advanced':
        return '高级';
      default:
        return level;
    }
  }

  /// 获取难度级别的颜色
  Color get levelColor {
    switch (level) {
      case 'beginner':
        return const Color(0xFF10B981); // 绿色
      case 'intermediate':
        return const Color(0xFFF59E0B); // 黄色
      case 'advanced':
        return const Color(0xFFEF4444); // 红色
      default:
        return const Color(0xFF6B7280); // 灰色
    }
  }

  /// 获取类型的中文显示
  String get typeText {
    switch (type) {
      case 'strength':
        return '力量';
      case 'cardio':
        return '有氧';
      case 'flexibility':
        return '柔韧';
      case 'balance':
        return '平衡';
      default:
        return type;
    }
  }

  /// 获取动作名称的中文显示
  /// 优先使用数据库中的中文名称，如果没有则使用英文原名
  String get displayName {
    // 如果有中文名称且不为空，使用中文名称
    if (nameZh != null && nameZh!.isNotEmpty) {
      return nameZh!;
    }
    
    // 否则返回英文原名
    return name;
  }
}

/// 动作库响应模型
class ExerciseLibraryResponse {
  final bool success;
  final List<ExerciseLibrary> data;
  final int total;
  final int page;
  final int limit;

  ExerciseLibraryResponse({
    required this.success,
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory ExerciseLibraryResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseLibraryResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List?)
              ?.map((e) => ExerciseLibrary.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
    );
  }
}

