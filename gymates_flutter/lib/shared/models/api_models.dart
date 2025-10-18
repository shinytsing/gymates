import 'package:json_annotation/json_annotation.dart';

part 'api_models.g.dart';

// Base API Response
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final int? code;
  @JsonKey(name: 'timestamp')
  final String? timestamp;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.code,
    this.timestamp,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      ApiResponse<T>(
        success: json['success'] as bool,
        message: json['message'] as String?,
        data: json['data'] != null ? fromJsonT(json['data']) : null,
        error: json['error'] as String?,
        code: json['code'] as int?,
        timestamp: json['timestamp'] as String?,
      );
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) => {
        'success': success,
        'message': message,
        'data': data != null ? toJsonT(data as T) : null,
        'error': error,
        'code': code,
        'timestamp': timestamp,
      };
}

// Pagination
@JsonSerializable()
class PaginationParams {
  final int page;
  final int limit;
  final String? sort;
  final String? order;

  PaginationParams({
    required this.page,
    required this.limit,
    this.sort,
    this.order,
  });

  factory PaginationParams.fromJson(Map<String, dynamic> json) =>
      _$PaginationParamsFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationParamsToJson(this);
}

@JsonSerializable()
class PaginationResponse {
  final int page;
  final int limit;
  final int total;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'has_more')
  final bool hasMore;

  PaginationResponse({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory PaginationResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationResponseToJson(this);
}

// User Model
@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? bio;
  final String? location;
  final int? age;
  final double? height;
  final double? weight;
  @JsonKey(name: 'fitness_goals')
  final List<String>? fitnessGoals;
  final String? experience;
  final int followers;
  final int following;
  final int posts;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.bio,
    this.location,
    this.age,
    this.height,
    this.weight,
    this.fitnessGoals,
    this.experience,
    required this.followers,
    required this.following,
    required this.posts,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// Auth Models
@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final User user;
  final String token;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.token,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

// Training Models
@JsonSerializable()
class Exercise {
  final String id;
  final String name;
  final String? description;
  final int sets;
  final int reps;
  final double? weight;
  final int? duration;
  @JsonKey(name: 'rest_time')
  final int? restTime;
  final List<String>? instructions;
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    required this.sets,
    required this.reps,
    this.weight,
    this.duration,
    this.restTime,
    this.instructions,
    this.videoUrl,
    this.imageUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}

@JsonSerializable()
class TrainingPlan {
  final String id;
  final String name;
  final String description;
  final String category;
  final String difficulty;
  final int duration;
  @JsonKey(name: 'calories_burned')
  final int caloriesBurned;
  final List<Exercise> exercises;
  final List<String> equipment;
  final List<String> tags;
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @JsonKey(name: 'created_by')
  final String createdBy;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  TrainingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.caloriesBurned,
    required this.exercises,
    required this.equipment,
    required this.tags,
    required this.isPublic,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrainingPlan.fromJson(Map<String, dynamic> json) =>
      _$TrainingPlanFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingPlanToJson(this);
}

@JsonSerializable()
class WorkoutSession {
  final String id;
  @JsonKey(name: 'plan_id')
  final String planId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String? endTime;
  final String status;
  final int progress;
  @JsonKey(name: 'exercises_completed')
  final int exercisesCompleted;
  @JsonKey(name: 'total_exercises')
  final int totalExercises;
  @JsonKey(name: 'calories_burned')
  final int caloriesBurned;
  final String? notes;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  WorkoutSession({
    required this.id,
    required this.planId,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.progress,
    required this.exercisesCompleted,
    required this.totalExercises,
    required this.caloriesBurned,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutSessionToJson(this);
}

// Community Models
@JsonSerializable()
class Post {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final User user;
  final String content;
  final List<String>? images;
  final String? video;
  final String? location;
  final List<String> tags;
  final int likes;
  final int comments;
  final int shares;
  @JsonKey(name: 'is_liked')
  final bool isLiked;
  @JsonKey(name: 'is_bookmarked')
  final bool isBookmarked;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  Post({
    required this.id,
    required this.userId,
    required this.user,
    required this.content,
    this.images,
    this.video,
    this.location,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
    required this.isBookmarked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class Comment {
  final String id;
  @JsonKey(name: 'post_id')
  final String postId;
  @JsonKey(name: 'user_id')
  final String userId;
  final User user;
  final String content;
  final int likes;
  @JsonKey(name: 'is_liked')
  final bool isLiked;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.user,
    required this.content,
    required this.likes,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

// Mates Models
@JsonSerializable()
class Mate {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final User user;
  @JsonKey(name: 'fitness_goals')
  final List<String> fitnessGoals;
  final String experience;
  final String location;
  final List<String> availability;
  final String bio;
  @JsonKey(name: 'is_matched')
  final bool isMatched;
  @JsonKey(name: 'match_score')
  final int matchScore;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  Mate({
    required this.id,
    required this.userId,
    required this.user,
    required this.fitnessGoals,
    required this.experience,
    required this.location,
    required this.availability,
    required this.bio,
    required this.isMatched,
    required this.matchScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Mate.fromJson(Map<String, dynamic> json) => _$MateFromJson(json);
  Map<String, dynamic> toJson() => _$MateToJson(this);
}

// Messages Models
@JsonSerializable()
class Chat {
  final String id;
  final List<User> participants;
  @JsonKey(name: 'last_message')
  final Message? lastMessage;
  @JsonKey(name: 'unread_count')
  final int unreadCount;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  Chat({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
  Map<String, dynamic> toJson() => _$ChatToJson(this);
}

@JsonSerializable()
class Message {
  final String id;
  @JsonKey(name: 'chat_id')
  final String chatId;
  @JsonKey(name: 'sender_id')
  final String senderId;
  final User sender;
  final String content;
  final String type;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.sender,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

// Home/Detail Models
@JsonSerializable()
class HomeItem {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String category;
  final String tags;
  final String status;
  final int priority;
  @JsonKey(name: 'view_count')
  final int viewCount;
  @JsonKey(name: 'like_count')
  final int likeCount;
  @JsonKey(name: 'comment_count')
  final int commentCount;
  final User user;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  HomeItem({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.category,
    required this.tags,
    required this.status,
    required this.priority,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HomeItem.fromJson(Map<String, dynamic> json) =>
      _$HomeItemFromJson(json);
  Map<String, dynamic> toJson() => _$HomeItemToJson(this);
}

@JsonSerializable()
class DetailItem {
  final int id;
  final String title;
  final String content;
  final String description;
  final String? images;
  final String? videos;
  final String? files;
  final String category;
  final String type;
  final String status;
  final int priority;
  @JsonKey(name: 'view_count')
  final int viewCount;
  @JsonKey(name: 'like_count')
  final int likeCount;
  @JsonKey(name: 'comment_count')
  final int commentCount;
  @JsonKey(name: 'share_count')
  final int shareCount;
  final String tags;
  final String? metadata;
  final User user;
  final dynamic parent;
  final List<dynamic> children;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  DetailItem({
    required this.id,
    required this.title,
    required this.content,
    required this.description,
    this.images,
    this.videos,
    this.files,
    required this.category,
    required this.type,
    required this.status,
    required this.priority,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.tags,
    this.metadata,
    required this.user,
    this.parent,
    required this.children,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DetailItem.fromJson(Map<String, dynamic> json) =>
      _$DetailItemFromJson(json);
  Map<String, dynamic> toJson() => _$DetailItemToJson(this);
}