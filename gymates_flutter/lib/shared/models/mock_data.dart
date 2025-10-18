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
