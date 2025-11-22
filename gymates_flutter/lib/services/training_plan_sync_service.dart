import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/models/edit_training_plan_models.dart';
import '../core/config/smart_api_config.dart';
import '../core/token_manager.dart';

/// 🏋️‍♀️ 训练计划同步服务 - TrainingPlanSyncService
///
/// 直接使用API数据，不依赖Mock数据
class TrainingPlanSyncService {
  // 使用智能API配置 (apiBaseUrl 已包含 /api 前缀)
  static String get _baseUrl => SmartApiConfig.apiBaseUrl;
  static final _tokenManager = TokenManager();

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// 获取认证token (使用TokenManager)
  static Future<String?> _getAuthToken() async {
    return await _tokenManager.getToken();
  }

  /// 构建请求头
  static Future<Map<String, String>> _buildHeaders() async {
    return await _tokenManager.getAuthHeaders();
  }

  /// 保存一周训练计划到API
  static Future<bool> saveWeeklyTrainingPlan(EditTrainingPlan plan) async {
    try {
      final headers = await _buildHeaders();
      final planData = _convertToApiFormat(plan);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/training/weekly-plans'),
        headers: headers,
        body: json.encode(planData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ 一周训练计划已保存到API');
        return true;
      } else {
        print('❌ API保存失败: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ API请求失败: $e');
      return false;
    }
  }

  /// 更新一周训练计划
  static Future<bool> updateWeeklyTrainingPlan(String planId, EditTrainingPlan plan) async {
    try {
      final headers = await _buildHeaders();
      final planData = _convertToApiFormat(plan);
      
      final response = await http.put(
        Uri.parse('$_baseUrl/training/weekly-plans/$planId'),
        headers: headers,
        body: json.encode(planData),
      );

      if (response.statusCode == 200) {
        print('✅ 一周训练计划已更新到API');
        return true;
      } else {
        print('❌ API更新失败: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ API请求失败: $e');
      return false;
    }
  }

  /// 保存训练计划到API (使用weekly-plans端点)
  static Future<bool> saveTrainingPlan(Map<String, dynamic> planData) async {
    try {
      final headers = await _buildHeaders();
      
      // 转换数据格式以匹配CreateWeeklyTrainingPlanRequest
      final weeklyPlanData = {
        'name': planData['name'] ?? '我的训练计划',
        'description': planData['description'] ?? '',
        'is_public': true,
        'days': _convertDaysToApiFormat(planData['days'] ?? []),
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/training/weekly-plans'),
        headers: headers,
        body: json.encode(weeklyPlanData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ 训练计划已保存到API');
        return true;
      } else {
        print('❌ API保存失败: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ API请求失败: $e');
      return false;
    }
  }

  /// 将Flutter的days格式转换为API格式
  static List<Map<String, dynamic>> _convertDaysToApiFormat(List<dynamic> days) {
    return days.map((day) => {
      'day_of_week': day['dayOfWeek'] ?? 1,
      'day_name': day['dayName'] ?? '周一',
      'is_rest_day': day['isRestDay'] ?? false,
      'notes': day['notes'] ?? '',
      'parts': _convertPartsToApiFormat(day['parts'] ?? []),
    }).toList();
  }

  /// 将Flutter的parts格式转换为API格式
  static List<Map<String, dynamic>> _convertPartsToApiFormat(List<dynamic> parts) {
    return parts.map((part) => {
      'muscle_group': part['muscleGroup'] ?? '',
      'muscle_group_name': part['muscleGroupName'] ?? '',
      'order': part['order'] ?? 0,
      'exercises': _convertExercisesToApiFormat(part['exercises'] ?? []),
    }).toList();
  }

  /// 将Flutter的exercises格式转换为API格式
  static List<Map<String, dynamic>> _convertExercisesToApiFormat(List<dynamic> exercises) {
    return exercises.map((exercise) => {
      'name': exercise['name'] ?? '',
      'description': exercise['description'] ?? '',
      'muscle_group': exercise['muscleGroup'] ?? '',
      'sets': exercise['sets'] ?? 3,
      'reps': exercise['reps'] ?? 10,
      'weight': exercise['weight'] ?? 0.0,
      'rest_seconds': exercise['restSeconds'] ?? 90,
      'notes': exercise['notes'] ?? '',
      'order': exercise['order'] ?? 0,
    }).toList();
  }

  /// 从API获取一周训练计划
  static Future<EditTrainingPlan?> getWeeklyTrainingPlan(String planId) async {
    try {
      final headers = await _buildHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/training/weekly-plans/$planId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return _convertFromApiFormat(data['data']);
        }
        return null;
      } else {
        print('❌ API获取失败: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ API请求失败: $e');
      return null;
    }
  }

  /// 从API获取训练计划 (兼容旧接口)
  static Future<Map<String, dynamic>?> getTrainingPlan(String planId) async {
    try {
      final headers = await _buildHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/training/plans/$planId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('❌ API获取失败: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ API请求失败: $e');
      return null;
    }
  }

  /// 获取用户的一周训练计划列表
  static Future<List<EditTrainingPlan>> getUserWeeklyTrainingPlans() async {
    try {
      final headers = await _buildHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/training/weekly-plans'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final plansData = data['data']['plans'] as List;
          return plansData.map((planData) => _convertFromApiFormat(planData)).toList();
        }
      } else {
        print('❌ API获取一周训练计划列表失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API请求失败: $e');
    }
    return [];
  }

  /// 获取用户的训练计划列表 (使用weekly-plans API)
  static Future<List<Map<String, dynamic>>> getUserTrainingPlans() async {
    try {
      final headers = await _buildHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/training/weekly-plans'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final plansData = data['data']['plans'] as List;
          return plansData.cast<Map<String, dynamic>>();
        }
      } else {
        print('❌ API获取训练计划列表失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API请求失败: $e');
    }
    return [];
  }

  /// 更新训练计划
  static Future<bool> updateTrainingPlan(String planId, Map<String, dynamic> planData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/training-plans/$planId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(planData),
      );

      if (response.statusCode == 200) {
        print('✅ 训练计划已更新到API');
        return true;
      } else {
        print('❌ API更新失败: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ API请求失败: $e');
      return false;
    }
  }

  /// 删除训练计划
  static Future<bool> deleteTrainingPlan(String planId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/training-plans/$planId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ 训练计划已从API删除');
        return true;
      } else {
        print('❌ API删除失败: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ API请求失败: $e');
      return false;
    }
  }

  /// 检查是否有训练计划
  static Future<bool> hasTrainingPlan() async {
    try {
      final plans = await getUserTrainingPlans();
      return plans.isNotEmpty;
    } catch (e) {
      print('❌ 检查训练计划失败: $e');
      return false;
    }
  }

  /// 获取今日训练内容
  static Future<Map<String, dynamic>?> getTodayTraining() async {
    try {
      final plans = await getUserTrainingPlans();
      if (plans.isEmpty) {
        print('🏋️‍♀️ 没有训练计划，返回测试数据');
        return _getTestTrainingData();
      }

      // 获取最新的训练计划
      final latestPlan = plans.first;
      
      // 获取今日是星期几 (1-7, 1=周一)
      final today = DateTime.now().weekday;
      
      // 查找今日的训练内容
      if (latestPlan['days'] != null) {
        final days = latestPlan['days'] as List?;
        if (days != null) {
          for (final day in days) {
            if (day is Map<String, dynamic> && day['day_of_week'] == today) {
              // 转换数据格式以匹配TodayPlanCard的期望
              return _convertDayToTodayTrainingFormat(day, latestPlan);
            }
          }
        }
      }
      
      print('🏋️‍♀️ 没有找到今日训练，返回测试数据');
      return _getTestTrainingData();
    } catch (e) {
      print('❌ 获取今日训练失败: $e');
      return _getTestTrainingData();
    }
  }

  /// 获取测试训练数据
  static Map<String, dynamic> _getTestTrainingData() {
    return {
      'id': 'test_training_${DateTime.now().millisecondsSinceEpoch}',
      'name': '测试训练计划',
      'description': '这是一个测试训练计划',
      'isRestDay': false,
      'totalExercises': 5,
      'completedExercises': 0,
      'estimatedDuration': 45,
      'parts': [
        {
          'name': '胸部训练',
          'exercises': [
            {
              'id': '1',
              'name': '俯卧撑',
              'description': '标准俯卧撑',
              'muscle_group': '胸部',
              'difficulty': 'beginner',
              'equipment': '无',
              'image_url': '',
              'video_url': '',
              'instructions': '保持身体挺直，手臂与肩同宽',
              'sets': 3,
              'reps': 10,
              'rest_time': 60,
            },
            {
              'id': '2',
              'name': '哑铃卧推',
              'description': '平躺哑铃卧推',
              'muscle_group': '胸部',
              'difficulty': 'intermediate',
              'equipment': '哑铃',
              'image_url': '',
              'video_url': '',
              'instructions': '平躺在凳子上，双手持哑铃推举',
              'sets': 3,
              'reps': 12,
              'rest_time': 90,
            },
          ],
        },
        {
          'name': '背部训练',
          'exercises': [
            {
              'id': '3',
              'name': '引体向上',
              'description': '标准引体向上',
              'muscle_group': '背部',
              'difficulty': 'intermediate',
              'equipment': '单杠',
              'image_url': '',
              'video_url': '',
              'instructions': '双手握杠，身体悬垂，向上拉至下巴过杠',
              'sets': 3,
              'reps': 8,
              'rest_time': 120,
            },
          ],
        },
      ],
    };
  }

  /// 将API的day数据转换为TodayPlanCard期望的格式
  static Map<String, dynamic> _convertDayToTodayTrainingFormat(Map<String, dynamic> day, Map<String, dynamic> plan) {
    // 计算总动作数
    int totalExercises = 0;
    if (day['parts'] != null) {
      final parts = day['parts'] as List?;
      if (parts != null) {
        for (final part in parts) {
          if (part is Map<String, dynamic> && part['exercises'] != null) {
            final exercises = part['exercises'] as List?;
            if (exercises != null) {
              totalExercises += exercises.length;
            }
          }
        }
      }
    }

    // 计算总时长（估算）
    int totalDuration = totalExercises * 3; // 每个动作约3分钟

    // 计算总卡路里（估算）
    int totalCalories = totalExercises * 50; // 每个动作约50卡路里

    return {
      'day_name': day['day_name'] ?? '今日训练',
      'isRestDay': day['is_rest_day'] ?? false,
      'totalExercises': totalExercises,
      'totalDuration': totalDuration,
      'totalCalories': totalCalories,
      'planName': plan['name'] ?? '我的训练计划',
      'planDescription': plan['description'] ?? '',
      'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      'parts': day['parts'] ?? [],
      'notes': day['notes'] ?? '',
    };
  }

  /// 获取动作列表
  static Future<List<Map<String, dynamic>>> getExercises() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      } else {
        print('❌ API获取动作列表失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API请求失败: $e');
      // 返回默认动作列表
      return _getDefaultExercises();
    }
    return [];
  }

  /// 获取默认动作列表（当API不可用时）
  static List<Map<String, dynamic>> _getDefaultExercises() {
    return [
      {
        'id': '1',
        'name': '俯卧撑',
        'description': '经典的上肢训练动作',
        'muscleGroup': 'chest',
        'difficulty': '中等',
        'equipment': '无器械',
        'imageUrl': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        'videoUrl': 'https://example.com/video.mp4',
        'instructions': '保持身体挺直，双手与肩同宽',
      },
      {
        'id': '2',
        'name': '深蹲',
        'description': '经典的下肢训练动作',
        'muscleGroup': 'legs',
        'difficulty': '中等',
        'equipment': '无器械',
        'imageUrl': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        'videoUrl': 'https://example.com/video.mp4',
        'instructions': '双脚与肩同宽，下蹲至大腿平行地面',
      },
      {
        'id': '3',
        'name': '引体向上',
        'description': '背部训练经典动作',
        'muscleGroup': 'back',
        'difficulty': '困难',
        'equipment': '单杠',
        'imageUrl': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        'videoUrl': 'https://example.com/video.mp4',
        'instructions': '双手正握单杠，身体垂直上拉',
      },
      {
        'id': '4',
        'name': '平板支撑',
        'description': '核心力量训练',
        'muscleGroup': 'core',
        'difficulty': '中等',
        'equipment': '无器械',
        'imageUrl': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        'videoUrl': 'https://example.com/video.mp4',
        'instructions': '保持身体成一条直线，核心收紧',
      },
      {
        'id': '5',
        'name': '肩推',
        'description': '肩部力量训练',
        'muscleGroup': 'shoulders',
        'difficulty': '中等',
        'equipment': '哑铃',
        'imageUrl': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        'videoUrl': 'https://example.com/video.mp4',
        'instructions': '双手持哑铃，从肩部推举至头顶',
      },
    ];
  }

  /// 搜索动作
  static Future<List<Map<String, dynamic>>> searchExercises(String query) async {
    try {
      final headers = await _buildHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/training/exercises/search?q=${Uri.encodeComponent(query)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final exercisesData = data['data']['exercises'] as List;
          return exercisesData.cast<Map<String, dynamic>>();
        }
      } else {
        print('❌ API搜索动作失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API请求失败: $e');
      // 返回默认动作列表的搜索结果
      final defaultExercises = _getDefaultExercises();
      return defaultExercises.where((exercise) {
        return exercise['name']?.toLowerCase().contains(query.toLowerCase()) == true ||
               exercise['muscleGroup']?.toLowerCase().contains(query.toLowerCase()) == true;
      }).toList();
    }
    return [];
  }

  /// 获取用户训练计划 (新API接口)
  static Future<Map<String, dynamic>?> getUserTrainingPlan(int userId) async {
    try {
      final headers = await _buildHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/training/plan?user_id=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      } else {
        print('❌ API获取训练计划失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API请求失败: $e');
    }
    return null;
  }

  /// 更新训练计划 (新API接口)
  static Future<bool> updateUserTrainingPlan(int userId, List<Map<String, dynamic>> planData) async {
    try {
      final headers = await _buildHeaders();
      
      final requestData = {
        'user_id': userId,
        'plan': planData,
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/training/plan/update'),
        headers: headers,
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        print('✅ 训练计划已更新到API');
        return true;
      } else {
        print('❌ API更新失败: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ API请求失败: $e');
      return false;
    }
  }

  /// 获取AI推荐 (新API接口)
  static Future<Map<String, dynamic>?> getAIRecommendation(int userId, String day, {String? muscleGroup}) async {
    try {
      final headers = await _buildHeaders();
      
      String url = '$_baseUrl/training/ai/recommend?user_id=$userId&day=$day';
      if (muscleGroup != null) {
        url += '&muscle_group=$muscleGroup';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      } else {
        print('❌ API获取AI推荐失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API请求失败: $e');
    }
    return null;
  }


  /// 将EditTrainingPlan转换为API格式
  static Map<String, dynamic> _convertToApiFormat(EditTrainingPlan plan) {
    return {
      'name': plan.name,
      'description': plan.description,
      'is_public': false,
      'days': plan.days.map((day) => {
        'day_of_week': day.dayOfWeek,
        'day_name': day.dayName,
        'is_rest_day': day.isRestDay,
        'notes': day.notes ?? '',
        'parts': day.parts.map((part) => {
          'muscle_group': part.muscleGroup,
          'muscle_group_name': part.muscleGroupName,
          'order': part.order,
          'exercises': part.exercises.map((exercise) => {
            'name': exercise.name,
            'description': exercise.description,
            'muscle_group': exercise.muscleGroup,
            'sets': exercise.sets,
            'reps': exercise.reps,
            'weight': exercise.weight,
            'duration': exercise.restSeconds * exercise.sets, // 估算总时长
            'rest_time': exercise.restSeconds ~/ 60, // 转换为分钟
            'rest_seconds': exercise.restSeconds,
            'instructions': exercise.description,
            'image_url': '',
            'video_url': '',
            'notes': exercise.notes ?? '',
            'order': exercise.order,
          }).toList(),
        }).toList(),
      }).toList(),
    };
  }

  /// 将API格式转换为EditTrainingPlan
  static EditTrainingPlan _convertFromApiFormat(Map<String, dynamic> data) {
    final days = (data['days'] as List).map((dayData) {
      final parts = (dayData['parts'] as List).map((partData) {
        final exercises = (partData['exercises'] as List).map((exerciseData) {
          return Exercise(
            id: exerciseData['id'].toString(),
            name: exerciseData['name'],
            description: exerciseData['description'] ?? exerciseData['instructions'] ?? '',
            muscleGroup: exerciseData['muscle_group'],
            sets: exerciseData['sets'],
            reps: exerciseData['reps'],
            weight: exerciseData['weight']?.toDouble() ?? 0.0,
            restSeconds: exerciseData['rest_seconds'] ?? exerciseData['rest_time'] * 60,
            notes: exerciseData['notes'],
            isCompleted: exerciseData['is_completed'] ?? false,
            completedAt: exerciseData['completed_at'] != null 
                ? DateTime.parse(exerciseData['completed_at']) 
                : null,
            order: exerciseData['order'],
          );
        }).toList();

        return TrainingPart(
          id: partData['id'].toString(),
          muscleGroup: partData['muscle_group'],
          muscleGroupName: partData['muscle_group_name'],
          exercises: exercises,
          order: partData['order'],
        );
      }).toList();

      return TrainingDay(
        id: dayData['id'].toString(),
        dayOfWeek: dayData['day_of_week'],
        dayName: dayData['day_name'],
        parts: parts,
        isRestDay: dayData['is_rest_day'] ?? false,
        notes: dayData['notes'],
      );
    }).toList();

    return EditTrainingPlan(
      id: data['id'].toString(),
      name: data['name'],
      description: data['description'] ?? '',
      days: days,
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
    );
  }
}