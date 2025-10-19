import 'package:flutter/material.dart';

/// 📊 Mock Data Models for Gymates App
/// 
/// This file contains all mock data structures that match the Figma design
/// and provide realistic data for testing and development.

class MockUser {
  final String id;
  final String name;
  final String avatar;
  final String bio;
  final int age;
  final String location;
  final bool isVerified;
  final int followers;
  final int following;
  final int posts;
  final String joinDate;
  final int workoutDays;
  final int caloriesBurned;
  final int achievements;
  final double rating;
  final List<String> preferences;
  final String goal;
  final String experience;
  final String workoutTime;
  final String distance;
  final bool isOnline;
  final bool isFollowing;
  final String username;

  MockUser({
    required this.id,
    required this.name,
    required this.avatar,
    required this.bio,
    required this.age,
    required this.location,
    required this.isVerified,
    required this.followers,
    required this.following,
    required this.posts,
    required this.joinDate,
    required this.workoutDays,
    required this.caloriesBurned,
    required this.achievements,
    required this.rating,
    required this.preferences,
    required this.goal,
    required this.experience,
    required this.workoutTime,
    required this.distance,
    this.isOnline = false,
    this.isFollowing = false,
    required this.username,
  });
}

class MockPost {
  final String id;
  final MockUser user;
  final String content;
  final String? image;
  final int likes;
  final int comments;
  final int shares;
  final String timeAgo;
  final List<String> tags;
  final bool isLiked;
  final bool isBookmarked;

  MockPost({
    required this.id,
    required this.user,
    required this.content,
    this.image,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.timeAgo,
    required this.tags,
    required this.isLiked,
    required this.isBookmarked,
  });
}

class MockTrainingPlan {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String difficulty;
  final int calories;
  final List<String> exercises;
  final String image;
  final bool isCompleted;
  final double progress;
  final String trainingMode; // 训练模式：五分化、三分化、推拉等
  final List<String> targetMuscles; // 目标肌群
  final List<MockExercise> exerciseDetails; // 详细动作信息
  final String suitableFor; // 适合人群
  final int weeklyFrequency; // 每周训练次数
  final DateTime createdAt;
  final DateTime? lastCompleted;

  MockTrainingPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.calories,
    required this.exercises,
    required this.image,
    required this.isCompleted,
    required this.progress,
    this.trainingMode = '五分化',
    this.targetMuscles = const [],
    this.exerciseDetails = const [],
    this.suitableFor = '中级训练者',
    this.weeklyFrequency = 3,
    required this.createdAt,
    this.lastCompleted,
  });
}

class MockExercise {
  final String id;
  final String name;
  final String description;
  final String muscleGroup;
  final String difficulty;
  final String equipment;
  final String imageUrl;
  final String videoUrl;
  final List<String> instructions;
  final List<String> tips;
  final int sets;
  final int reps;
  final double weight;
  final int restTime; // 休息时间（秒）
  final bool isCompleted;
  final DateTime? completedAt;
  final double maxRM; // 最大重复次数重量
  final String notes;
  final int calories; // 消耗卡路里

  MockExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.difficulty,
    required this.equipment,
    required this.imageUrl,
    required this.videoUrl,
    required this.instructions,
    required this.tips,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.restTime,
    this.isCompleted = false,
    this.completedAt,
    this.maxRM = 0.0,
    this.notes = '',
    this.calories = 50,
  });
}

class MockTrainingMode {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final List<String> targetMuscles;
  final String difficulty;
  final String suitableFor;
  final int weeklyFrequency;
  final int estimatedDuration;
  final List<String> benefits;
  final bool isRecommended;

  MockTrainingMode({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.targetMuscles,
    required this.difficulty,
    required this.suitableFor,
    required this.weeklyFrequency,
    required this.estimatedDuration,
    required this.benefits,
    this.isRecommended = false,
  });
}

class MockMessage {
  final String id;
  final MockUser user;
  final String lastMessage;
  final String time;
  final int unread;
  final String type;

  MockMessage({
    required this.id,
    required this.user,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.type,
  });
}

class MockNotification {
  final String id;
  final String title;
  final String content;
  final String time;
  final String type;
  final bool isUnread;

  MockNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    required this.type,
    required this.isUnread,
  });
}

class MockAchievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String date;
  final bool isUnlocked;
  final int points;

  MockAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.date,
    required this.isUnlocked,
    required this.points,
  });
}

class MockChallenge {
  final String id;
  final String title;
  final String description;
  final String image;
  final int participants;
  final String duration;
  final String difficulty;
  final bool isJoined;
  final double progress;

  MockChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.participants,
    required this.duration,
    required this.difficulty,
    required this.isJoined,
    required this.progress,
  });
}

class MockGym {
  final String id;
  final String name;
  final String address;
  final String image;
  final double rating;
  final int reviews;
  final String distance;
  final List<String> amenities;
  final String priceRange;
  final bool isOpen;

  MockGym({
    required this.id,
    required this.name,
    required this.address,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.amenities,
    required this.priceRange,
    required this.isOpen,
  });
}

/// 🎯 Mock Data Provider
class MockDataProvider {
  static final List<MockUser> users = [
    MockUser(
      id: '1',
      name: '陈雨晨',
      username: 'chenyuchen',
      avatar: 'https://images.unsplash.com/photo-1541338784564-51087dabc0de?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRnZXNzJTIwd29tYW4lMjB0cmFpbmluZyUyMGV4ZXJjaXNlfGVufDF8fHx8MTc1OTUzMDkxMnww&ixlib=rb-4.1.0&q=80&w=400',
      bio: '热爱运动的设计师，希望找到一起坚持健身的伙伴！每周至少4次训练，追求健康生活方式。',
      age: 25,
      location: '北京市',
      isVerified: true,
      followers: 1280,
      following: 456,
      posts: 89,
      joinDate: '2023年1月',
      workoutDays: 156,
      caloriesBurned: 125000,
      achievements: 12,
      rating: 4.8,
      preferences: ['力量训练', '瑜伽', '跑步'],
      goal: '减脂塑形',
      experience: '中级',
      workoutTime: '晚上 7-9点',
      distance: '2.5km',
      isOnline: true,
    ),
    MockUser(
      id: '2',
      name: '张健康',
      username: 'zhangjiankang',
      avatar: 'https://images.unsplash.com/photo-1607286908165-b8b6a2874fc4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRnZXNzJTIwcG9ydHJhaXQlMjBhdGhsZXRlJTIwd29ya291dHxlbnwxfHx8fDE3NTk1MzA5MTV8MA&ixlib=rb-4.1.0&q=80&w=400',
      bio: '健身教练，专注力量训练5年+。喜欢挑战自己，也乐于帮助健身新手。',
      age: 28,
      location: '上海市',
      isVerified: true,
      followers: 2560,
      following: 789,
      posts: 156,
      joinDate: '2022年3月',
      workoutDays: 324,
      caloriesBurned: 280000,
      achievements: 25,
      rating: 4.9,
      preferences: ['力量训练', 'CrossFit', '游泳'],
      goal: '增肌',
      experience: '高级',
      workoutTime: '早上 6-8点',
      distance: '1.8km',
      isOnline: false,
    ),
    MockUser(
      id: '3',
      name: '李小雅',
      username: 'lixiaoya',
      avatar: 'https://images.unsplash.com/photo-1669989179336-b2234d2878df?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRnZXNzJTIwZ3ltJTIwd29ya291dCUyMG1vdGl2YXRpb258ZW58MXx8fHwxNzU5NTMwOTA5fDA&ixlib=rb-4.1.0&q=80&w=400',
      bio: '刚开始健身的大学生，希望找到耐心的健身伙伴一起进步。',
      age: 23,
      location: '广州市',
      isVerified: false,
      followers: 456,
      following: 234,
      posts: 42,
      joinDate: '2024年1月',
      workoutDays: 42,
      caloriesBurned: 45000,
      achievements: 5,
      rating: 4.6,
      preferences: ['瑜伽', '普拉提', '舞蹈'],
      goal: '塑形',
      experience: '初级',
      workoutTime: '下午 2-4点',
      distance: '3.2km',
      isOnline: true,
    ),
  ];

  static final List<MockPost> posts = [
    MockPost(
      id: '1',
      user: users[0],
      content: '今天完成了45分钟的力量训练，感觉棒极了！💪 坚持就是胜利！',
      image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWlnaHQlMjB0cmFpbmluZyUyMGd5bSUyMHdvcmtvdXR8ZW58MXx8fHwxNzU5NTMwOTE4fDA&ixlib=rb-4.1.0&q=80&w=400',
      likes: 128,
      comments: 23,
      shares: 8,
      timeAgo: '2小时前',
      tags: ['力量训练', '健身'],
      isLiked: false,
      isBookmarked: false,
    ),
    MockPost(
      id: '2',
      user: users[1],
      content: '清晨的瑜伽练习，让身心都得到了放松。Namaste 🙏',
      image: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b2dhJTIwd29ya291dCUyMGV4ZXJjaXNlfGVufDF8fHx8MTc1OTUzMDkxOXww&ixlib=rb-4.1.0&q=80&w=400',
      likes: 89,
      comments: 15,
      shares: 12,
      timeAgo: '4小时前',
      tags: ['瑜伽', '冥想'],
      isLiked: true,
      isBookmarked: true,
    ),
    MockPost(
      id: '3',
      user: users[2],
      content: '完成了10公里晨跑，今天的配速比昨天快了30秒！🏃‍♀️',
      image: 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxydW5uaW5nJTIwZXhlcmNpc2UlMjBmaXRuZXNzJTIwd29ya291dHxlbnwxfHx8fDE3NTk1MzA5MjB8MA&ixlib=rb-4.1.0&q=80&w=400',
      likes: 156,
      comments: 31,
      shares: 19,
      timeAgo: '6小时前',
      tags: ['跑步', '有氧运动'],
      isLiked: false,
      isBookmarked: false,
    ),
  ];

  static final List<MockTrainingMode> trainingModes = [
    MockTrainingMode(
      id: '1',
      name: '五分化训练',
      description: '每天专注训练一个肌群，适合有经验的训练者',
      icon: '🏋️‍♂️',
      color: '#6366F1',
      targetMuscles: ['胸肌', '背部', '腿部', '肩部', '手臂'],
      difficulty: '高级',
      suitableFor: '有经验训练者',
      weeklyFrequency: 5,
      estimatedDuration: 60,
      benefits: ['肌肉充分恢复', '训练强度高', '专注度强'],
      isRecommended: true,
    ),
    MockTrainingMode(
      id: '2',
      name: '三分化训练',
      description: '推拉腿训练模式，平衡训练与恢复',
      icon: '💪',
      color: '#10B981',
      targetMuscles: ['推肌群', '拉肌群', '腿部'],
      difficulty: '中级',
      suitableFor: '中级训练者',
      weeklyFrequency: 3,
      estimatedDuration: 75,
      benefits: ['恢复时间充足', '训练效率高', '适合大部分人群'],
      isRecommended: true,
    ),
    MockTrainingMode(
      id: '3',
      name: '推拉训练',
      description: '推拉动作交替，适合时间有限的训练者',
      icon: '🔄',
      color: '#F59E0B',
      targetMuscles: ['推肌群', '拉肌群'],
      difficulty: '中级',
      suitableFor: '时间有限者',
      weeklyFrequency: 4,
      estimatedDuration: 45,
      benefits: ['时间灵活', '动作简单', '容易坚持'],
      isRecommended: false,
    ),
    MockTrainingMode(
      id: '4',
      name: '全身训练',
      description: '每次训练全身肌群，适合初学者',
      icon: '🌟',
      color: '#8B5CF6',
      targetMuscles: ['全身'],
      difficulty: '初级',
      suitableFor: '初学者',
      weeklyFrequency: 3,
      estimatedDuration: 50,
      benefits: ['简单易学', '全身发展', '恢复快速'],
      isRecommended: false,
    ),
  ];

  static final List<MockExercise> exercises = [
    MockExercise(
      id: '1',
      name: '卧推',
      description: '经典胸部训练动作，发展胸肌厚度',
      muscleGroup: '胸部',
      difficulty: '中级',
      equipment: '杠铃',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      videoUrl: 'https://example.com/bench-press.mp4',
      instructions: [
        '平躺在卧推凳上，双脚踩地',
        '握住杠铃，双手间距略宽于肩',
        '缓慢下降至胸部，然后推起',
        '保持核心稳定，动作流畅'
      ],
      tips: [
        '保持肩胛骨稳定',
        '控制下降速度',
        '呼吸配合动作'
      ],
      sets: 4,
      reps: 8,
      weight: 60.0,
      restTime: 120,
      maxRM: 80.0,
      calories: 60,
    ),
    MockExercise(
      id: '2',
      name: '深蹲',
      description: '腿部训练之王，发展下肢力量',
      muscleGroup: '腿部',
      difficulty: '中级',
      equipment: '杠铃',
      imageUrl: 'https://images.unsplash.com/photo-1534258936925-c58bed479fcb?w=400',
      videoUrl: 'https://example.com/squat.mp4',
      instructions: [
        '双脚与肩同宽站立',
        '杠铃放在肩膀上',
        '下蹲至大腿平行地面',
        '起身至起始位置'
      ],
      tips: [
        '保持背部挺直',
        '膝盖与脚尖方向一致',
        '重心在脚后跟'
      ],
      sets: 4,
      reps: 10,
      weight: 80.0,
      restTime: 180,
      maxRM: 100.0,
      calories: 80,
    ),
    MockExercise(
      id: '3',
      name: '硬拉',
      description: '全身复合动作，发展后链肌群',
      muscleGroup: '背部',
      difficulty: '高级',
      equipment: '杠铃',
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b84efcf1dbf6?w=400',
      videoUrl: 'https://example.com/deadlift.mp4',
      instructions: [
        '双脚与肩同宽站立',
        '弯腰握住杠铃',
        '保持背部挺直，拉起杠铃',
        '杠铃贴近身体上升'
      ],
      tips: [
        '保持核心稳定',
        '杠铃轨迹垂直',
        '避免圆背'
      ],
      sets: 3,
      reps: 5,
      weight: 100.0,
      restTime: 240,
      maxRM: 120.0,
      calories: 100,
    ),
    MockExercise(
      id: '4',
      name: '引体向上',
      description: '背部训练经典动作',
      muscleGroup: '背部',
      difficulty: '中级',
      equipment: '单杠',
      imageUrl: 'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?w=400',
      videoUrl: 'https://example.com/pullup.mp4',
      instructions: [
        '双手握住单杠，宽握',
        '身体悬垂，核心收紧',
        '拉起身体至下巴过杠',
        '缓慢下降至起始位置'
      ],
      tips: [
        '避免摆动',
        '控制下降速度',
        '肩胛骨主动收缩'
      ],
      sets: 3,
      reps: 8,
      weight: 0.0,
      restTime: 120,
      maxRM: 0.0,
      calories: 40,
    ),
  ];

  static final List<MockTrainingPlan> trainingPlans = [
    MockTrainingPlan(
      id: '1',
      title: '今日力量训练',
      description: '全身力量训练，包含胸、背、腿、肩部训练',
      duration: '45分钟',
      difficulty: '中级',
      calories: 350,
      exercises: ['卧推', '深蹲', '硬拉', '引体向上'],
      image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWlnaHQlMjB0cmFpbmluZyUyMGd5bSUyMHdvcmtvdXR8ZW58MXx8fHwxNzU5NTMwOTE4fDA&ixlib=rb-4.1.0&q=80&w=400',
      isCompleted: false,
      progress: 0.0,
      trainingMode: '五分化',
      targetMuscles: ['胸部', '背部', '腿部', '肩部'],
      exerciseDetails: exercises,
      suitableFor: '中级训练者',
      weeklyFrequency: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    MockTrainingPlan(
      id: '2',
      title: '瑜伽放松',
      description: '舒缓的瑜伽练习，帮助放松身心',
      duration: '30分钟',
      difficulty: '初级',
      calories: 120,
      exercises: ['下犬式', '猫式', '婴儿式', '冥想'],
      image: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b2dhJTIwd29ya291dCUyMGV4ZXJjaXNlfGVufDF8fHx8MTc1OTUzMDkxOXww&ixlib=rb-4.1.0&q=80&w=400',
      isCompleted: true,
      progress: 1.0,
      trainingMode: '全身训练',
      targetMuscles: ['全身'],
      exerciseDetails: [],
      suitableFor: '初学者',
      weeklyFrequency: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      lastCompleted: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static final List<MockMessage> messages = [
    MockMessage(
      id: '1',
      user: users[1],
      lastMessage: '今天的训练计划我已经发给你了，记得按时完成哦',
      time: '10:30',
      unread: 2,
      type: 'text',
    ),
    MockMessage(
      id: '2',
      user: users[0],
      lastMessage: '明天早上7点公园见，准时出发！',
      time: '昨天',
      unread: 0,
      type: 'group',
    ),
    MockMessage(
      id: '3',
      user: users[2],
      lastMessage: '感谢你的瑜伽指导，进步很大！',
      time: '周一',
      unread: 0,
      type: 'text',
    ),
  ];

  static final List<MockNotification> notifications = [
    MockNotification(
      id: '1',
      title: '训练提醒',
      content: '距离今日训练计划还有30分钟',
      time: '1小时前',
      type: 'reminder',
      isUnread: true,
    ),
    MockNotification(
      id: '2',
      title: '挑战更新',
      content: '你参与的"30天俯卧撑挑战"有新进展',
      time: '3小时前',
      type: 'challenge',
      isUnread: true,
    ),
    MockNotification(
      id: '3',
      title: '点赞通知',
      content: '用户"健身达人小王"点赞了你的动态',
      time: '1天前',
      type: 'like',
      isUnread: false,
    ),
  ];

  static final List<MockAchievement> achievements = [
    MockAchievement(
      id: '1',
      title: '健身新手',
      description: '完成第一次训练',
      icon: '🏆',
      date: '2024-01-15',
      isUnlocked: true,
      points: 100,
    ),
    MockAchievement(
      id: '2',
      title: '坚持达人',
      description: '连续训练7天',
      icon: '🔥',
      date: '2024-01-22',
      isUnlocked: true,
      points: 200,
    ),
    MockAchievement(
      id: '3',
      title: '力量之王',
      description: '完成100次俯卧撑',
      icon: '💪',
      date: '',
      isUnlocked: false,
      points: 500,
    ),
  ];

  static final List<MockChallenge> challenges = [
    MockChallenge(
      id: '1',
      title: '30天俯卧撑挑战',
      description: '每天完成30个俯卧撑，坚持30天',
      image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWlnaHQlMjB0cmFpbmluZyUyMGd5bSUyMHdvcmtvdXR8ZW58MXx8fHwxNzU5NTMwOTE4fDA&ixlib=rb-4.1.0&q=80&w=400',
      participants: 1250,
      duration: '30天',
      difficulty: '中级',
      isJoined: true,
      progress: 0.6,
    ),
    MockChallenge(
      id: '2',
      title: '5公里跑步挑战',
      description: '完成5公里跑步挑战',
      image: 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxydW5uaW5nJTIwZXhlcmNpc2UlMjBmaXRnZXNzJTIwd29ya291dHxlbnwxfHx8fDE3NTk1MzA5MjB8MA&ixlib=rb-4.1.0&q=80&w=400',
      participants: 890,
      duration: '1天',
      difficulty: '初级',
      isJoined: false,
      progress: 0.0,
    ),
  ];

  static final List<MockGym> gyms = [
    MockGym(
      id: '1',
      name: '健身中心A',
      address: '北京市朝阳区',
      image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWlnaHQlMjB0cmFpbmluZyUyMGd5bSUyMHdvcmtvdXR8ZW58MXx8fHwxNzU5NTMwOTE4fDA&ixlib=rb-4.1.0&q=80&w=400',
      rating: 4.8,
      reviews: 256,
      distance: '1.2km',
      amenities: ['器械齐全', '淋浴', '停车'],
      priceRange: '¥200-300/月',
      isOpen: true,
    ),
    MockGym(
      id: '2',
      name: '瑜伽馆B',
      address: '北京市海淀区',
      image: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b2dhJTIwd29ya291dCUyMGV4ZXJjaXNlfGVufDF8fHx8MTc1OTUzMDkxOXww&ixlib=rb-4.1.0&q=80&w=400',
      rating: 4.6,
      reviews: 189,
      distance: '2.1km',
      amenities: ['瑜伽垫', '更衣室', '茶水'],
      priceRange: '¥150-250/月',
      isOpen: true,
    ),
  ];
}

class MateData {
  final int id;
  final String name;
  final int age;
  final String avatar;
  final String distance;
  final int matchRate;
  final String workoutTime;
  final List<String> preferences;
  final String goal;
  final String experience;
  final String bio;
  final double rating;
  final int workouts;

  MateData({
    required this.id,
    required this.name,
    required this.age,
    required this.avatar,
    required this.distance,
    required this.matchRate,
    required this.workoutTime,
    required this.preferences,
    required this.goal,
    required this.experience,
    required this.bio,
    required this.rating,
    required this.workouts,
  });
}

class MockData {
  static final List<MateData> mates = [
    MateData(
      id: 1,
      name: '小明',
      age: 25,
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      distance: '2.5km',
      matchRate: 85,
      workoutTime: '19:00-21:00',
      preferences: ['力量训练', '有氧运动', '瑜伽'],
      goal: '增肌',
      experience: '中级',
      bio: '热爱健身的年轻人，希望找到志同道合的健身伙伴一起进步！',
      rating: 4.8,
      workouts: 156,
    ),
    MateData(
      id: 2,
      name: '小红',
      age: 23,
      avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400',
      distance: '1.8km',
      matchRate: 92,
      workoutTime: '18:00-20:00',
      preferences: ['瑜伽', '普拉提', '有氧运动'],
      goal: '塑形',
      experience: '初级',
      bio: '刚开始健身的小白，希望有经验的朋友指导！',
      rating: 4.6,
      workouts: 45,
    ),
    MateData(
      id: 3,
      name: '小李',
      age: 28,
      avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      distance: '3.2km',
      matchRate: 78,
      workoutTime: '20:00-22:00',
      preferences: ['力量训练', '拳击', '游泳'],
      goal: '减脂',
      experience: '高级',
      bio: '健身老手，擅长各种训练方式，可以指导新手！',
      rating: 4.9,
      workouts: 312,
    ),
  ];
}

/// 🏋️‍♀️ 训练计划编辑数据模型 - Training Plan Edit Models
/// 
/// 支持一周7天的训练计划编辑功能

/// 训练计划编辑模型
class EditTrainingPlan {
  final String id;
  final String name;
  final String description;
  final List<TrainingDay> days;
  final DateTime createdAt;
  final DateTime updatedAt;

  EditTrainingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.days,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'days': days.map((day) => day.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory EditTrainingPlan.fromJson(Map<String, dynamic> json) {
    return EditTrainingPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      days: (json['days'] as List).map((day) => TrainingDay.fromJson(day)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// 复制并更新
  EditTrainingPlan copyWith({
    String? name,
    String? description,
    List<TrainingDay>? days,
  }) {
    return EditTrainingPlan(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      days: days ?? this.days,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// 训练日模型
class TrainingDay {
  final String id;
  final int dayOfWeek; // 1-7 (周一-周日)
  final String dayName;
  final List<TrainingPart> parts;
  final bool isRestDay;
  final String? notes;

  TrainingDay({
    required this.id,
    required this.dayOfWeek,
    required this.dayName,
    required this.parts,
    this.isRestDay = false,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'dayName': dayName,
      'parts': parts.map((part) => part.toJson()).toList(),
      'isRestDay': isRestDay,
      'notes': notes,
    };
  }

  factory TrainingDay.fromJson(Map<String, dynamic> json) {
    return TrainingDay(
      id: json['id'],
      dayOfWeek: json['dayOfWeek'],
      dayName: json['dayName'],
      parts: (json['parts'] as List).map((part) => TrainingPart.fromJson(part)).toList(),
      isRestDay: json['isRestDay'] ?? false,
      notes: json['notes'],
    );
  }

  /// 复制并更新
  TrainingDay copyWith({
    List<TrainingPart>? parts,
    bool? isRestDay,
    String? notes,
  }) {
    return TrainingDay(
      id: id,
      dayOfWeek: dayOfWeek,
      dayName: dayName,
      parts: parts ?? this.parts,
      isRestDay: isRestDay ?? this.isRestDay,
      notes: notes ?? this.notes,
    );
  }

  /// 获取总训练时间（分钟）
  int get totalDuration {
    return parts.fold(0, (total, part) => total + part.totalDuration);
  }

  /// 获取总动作数
  int get totalExercises {
    return parts.fold(0, (total, part) => total + part.exercises.length);
  }
}

/// 训练部位模型
class TrainingPart {
  final String id;
  final String muscleGroup;
  final String muscleGroupName;
  final List<Exercise> exercises;
  final int order;

  TrainingPart({
    required this.id,
    required this.muscleGroup,
    required this.muscleGroupName,
    required this.exercises,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'muscleGroup': muscleGroup,
      'muscleGroupName': muscleGroupName,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'order': order,
    };
  }

  factory TrainingPart.fromJson(Map<String, dynamic> json) {
    return TrainingPart(
      id: json['id'],
      muscleGroup: json['muscleGroup'],
      muscleGroupName: json['muscleGroupName'],
      exercises: (json['exercises'] as List).map((exercise) => Exercise.fromJson(exercise)).toList(),
      order: json['order'],
    );
  }

  /// 复制并更新
  TrainingPart copyWith({
    List<Exercise>? exercises,
  }) {
    return TrainingPart(
      id: id,
      muscleGroup: muscleGroup,
      muscleGroupName: muscleGroupName,
      exercises: exercises ?? this.exercises,
      order: order,
    );
  }

  /// 获取部位总训练时间（分钟）
  int get totalDuration {
    return exercises.fold(0, (total, exercise) {
      return total + (exercise.sets * exercise.reps * 2) + (exercise.sets * exercise.restSeconds ~/ 60);
    });
  }
}

/// 动作模型（扩展版）
class Exercise {
  final String id;
  final String name;
  final String description;
  final String muscleGroup;
  final int sets;
  final int reps;
  final double weight;
  final int restSeconds;
  final String? notes;
  final bool isCompleted;
  final DateTime? completedAt;
  final int order;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.restSeconds,
    this.notes,
    this.isCompleted = false,
    this.completedAt,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscleGroup': muscleGroup,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'restSeconds': restSeconds,
      'notes': notes,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'order': order,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      muscleGroup: json['muscleGroup'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight'].toDouble(),
      restSeconds: json['restSeconds'],
      notes: json['notes'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      order: json['order'],
    );
  }

  /// 复制并更新
  Exercise copyWith({
    String? name,
    String? description,
    int? sets,
    int? reps,
    double? weight,
    int? restSeconds,
    String? notes,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Exercise(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      muscleGroup: muscleGroup,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      order: order,
    );
  }

  /// 获取动作总时间（分钟）
  int get totalDuration {
    return (sets * reps * 2) + (sets * restSeconds ~/ 60);
  }
}

/// 肌肉群常量
class MuscleGroups {
  static const Map<String, String> groups = {
    'chest': '胸部',
    'back': '背部',
    'legs': '腿部',
    'shoulders': '肩部',
    'arms': '手臂',
    'core': '核心',
    'cardio': '有氧',
  };

  static const Map<String, String> icons = {
    'chest': '💪',
    'back': '🏋️',
    'legs': '🦵',
    'shoulders': '🤸',
    'arms': '💪',
    'core': '🔥',
    'cardio': '❤️',
  };

  static const Map<String, Color> colors = {
    'chest': Color(0xFF6366F1),
    'back': Color(0xFF8B5CF6),
    'legs': Color(0xFF10B981),
    'shoulders': Color(0xFFF59E0B),
    'arms': Color(0xFFEF4444),
    'core': Color(0xFFEC4899),
    'cardio': Color(0xFF06B6D4),
  };
}

/// 星期常量
class WeekDays {
  static const List<String> dayNames = [
    '周一', '周二', '周三', '周四', '周五', '周六', '周日'
  ];

  static const List<String> dayNamesEn = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
}
