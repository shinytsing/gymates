// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse _$ApiResponseFromJson(Map<String, dynamic> json) => ApiResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  data: json['data'] as Map<String, dynamic>?,
  error: json['error'] as String?,
  code: (json['code'] as num?)?.toInt(),
  timestamp: json['timestamp'] as String?,
);

Map<String, dynamic> _$ApiResponseToJson(ApiResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'error': instance.error,
      'code': instance.code,
      'timestamp': instance.timestamp,
    };

PaginationParams _$PaginationParamsFromJson(Map<String, dynamic> json) =>
    PaginationParams(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      sort: json['sort'] as String?,
      order: json['order'] as String?,
    );

Map<String, dynamic> _$PaginationParamsToJson(PaginationParams instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'sort': instance.sort,
      'order': instance.order,
    };

PaginationResponse _$PaginationResponseFromJson(Map<String, dynamic> json) =>
    PaginationResponse(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      hasMore: json['has_more'] as bool,
    );

Map<String, dynamic> _$PaginationResponseToJson(PaginationResponse instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'total_pages': instance.totalPages,
      'has_more': instance.hasMore,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  avatar: json['avatar'] as String?,
  bio: json['bio'] as String?,
  location: json['location'] as String?,
  age: (json['age'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toDouble(),
  weight: (json['weight'] as num?)?.toDouble(),
  fitnessGoals: (json['fitness_goals'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  experience: json['experience'] as String?,
  followers: (json['followers'] as num).toInt(),
  following: (json['following'] as num).toInt(),
  posts: (json['posts'] as num).toInt(),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'avatar': instance.avatar,
  'bio': instance.bio,
  'location': instance.location,
  'age': instance.age,
  'height': instance.height,
  'weight': instance.weight,
  'fitness_goals': instance.fitnessGoals,
  'experience': instance.experience,
  'followers': instance.followers,
  'following': instance.following,
  'posts': instance.posts,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirm_password'] as String,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'confirm_password': instance.confirmPassword,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  token: json['token'] as String,
  refreshToken: json['refresh_token'] as String,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'token': instance.token,
      'refresh_token': instance.refreshToken,
    };

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  sets: (json['sets'] as num).toInt(),
  reps: (json['reps'] as num).toInt(),
  weight: (json['weight'] as num?)?.toDouble(),
  duration: (json['duration'] as num?)?.toInt(),
  restTime: (json['rest_time'] as num?)?.toInt(),
  instructions: (json['instructions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  videoUrl: json['video_url'] as String?,
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'sets': instance.sets,
  'reps': instance.reps,
  'weight': instance.weight,
  'duration': instance.duration,
  'rest_time': instance.restTime,
  'instructions': instance.instructions,
  'video_url': instance.videoUrl,
  'image_url': instance.imageUrl,
};

TrainingPlan _$TrainingPlanFromJson(Map<String, dynamic> json) => TrainingPlan(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  difficulty: json['difficulty'] as String,
  duration: (json['duration'] as num).toInt(),
  caloriesBurned: (json['calories_burned'] as num).toInt(),
  exercises: (json['exercises'] as List<dynamic>)
      .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
      .toList(),
  equipment: (json['equipment'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  isPublic: json['is_public'] as bool,
  createdBy: json['created_by'] as String,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$TrainingPlanToJson(TrainingPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'difficulty': instance.difficulty,
      'duration': instance.duration,
      'calories_burned': instance.caloriesBurned,
      'exercises': instance.exercises,
      'equipment': instance.equipment,
      'tags': instance.tags,
      'is_public': instance.isPublic,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) =>
    WorkoutSession(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      userId: json['user_id'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String?,
      status: json['status'] as String,
      progress: (json['progress'] as num).toInt(),
      exercisesCompleted: (json['exercises_completed'] as num).toInt(),
      totalExercises: (json['total_exercises'] as num).toInt(),
      caloriesBurned: (json['calories_burned'] as num).toInt(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$WorkoutSessionToJson(WorkoutSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plan_id': instance.planId,
      'user_id': instance.userId,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'status': instance.status,
      'progress': instance.progress,
      'exercises_completed': instance.exercisesCompleted,
      'total_exercises': instance.totalExercises,
      'calories_burned': instance.caloriesBurned,
      'notes': instance.notes,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  content: json['content'] as String,
  images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
  video: json['video'] as String?,
  location: json['location'] as String?,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  likes: (json['likes'] as num).toInt(),
  comments: (json['comments'] as num).toInt(),
  shares: (json['shares'] as num).toInt(),
  isLiked: json['is_liked'] as bool,
  isBookmarked: json['is_bookmarked'] as bool,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'user': instance.user,
  'content': instance.content,
  'images': instance.images,
  'video': instance.video,
  'location': instance.location,
  'tags': instance.tags,
  'likes': instance.likes,
  'comments': instance.comments,
  'shares': instance.shares,
  'is_liked': instance.isLiked,
  'is_bookmarked': instance.isBookmarked,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: json['id'] as String,
  postId: json['post_id'] as String,
  userId: json['user_id'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  content: json['content'] as String,
  likes: (json['likes'] as num).toInt(),
  isLiked: json['is_liked'] as bool,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'post_id': instance.postId,
  'user_id': instance.userId,
  'user': instance.user,
  'content': instance.content,
  'likes': instance.likes,
  'is_liked': instance.isLiked,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

Mate _$MateFromJson(Map<String, dynamic> json) => Mate(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  fitnessGoals: (json['fitness_goals'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  experience: json['experience'] as String,
  location: json['location'] as String,
  availability: (json['availability'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  bio: json['bio'] as String,
  isMatched: json['is_matched'] as bool,
  matchScore: (json['match_score'] as num).toInt(),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$MateToJson(Mate instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'user': instance.user,
  'fitness_goals': instance.fitnessGoals,
  'experience': instance.experience,
  'location': instance.location,
  'availability': instance.availability,
  'bio': instance.bio,
  'is_matched': instance.isMatched,
  'match_score': instance.matchScore,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
  id: json['id'] as String,
  participants: (json['participants'] as List<dynamic>)
      .map((e) => User.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastMessage: json['last_message'] == null
      ? null
      : Message.fromJson(json['last_message'] as Map<String, dynamic>),
  unreadCount: (json['unread_count'] as num).toInt(),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
  'id': instance.id,
  'participants': instance.participants,
  'last_message': instance.lastMessage,
  'unread_count': instance.unreadCount,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: json['id'] as String,
  chatId: json['chat_id'] as String,
  senderId: json['sender_id'] as String,
  sender: User.fromJson(json['sender'] as Map<String, dynamic>),
  content: json['content'] as String,
  type: json['type'] as String,
  isRead: json['is_read'] as bool,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'chat_id': instance.chatId,
  'sender_id': instance.senderId,
  'sender': instance.sender,
  'content': instance.content,
  'type': instance.type,
  'is_read': instance.isRead,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

HomeItem _$HomeItemFromJson(Map<String, dynamic> json) => HomeItem(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  image: json['image'] as String?,
  category: json['category'] as String,
  tags: json['tags'] as String,
  status: json['status'] as String,
  priority: (json['priority'] as num).toInt(),
  viewCount: (json['view_count'] as num).toInt(),
  likeCount: (json['like_count'] as num).toInt(),
  commentCount: (json['comment_count'] as num).toInt(),
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$HomeItemToJson(HomeItem instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'image': instance.image,
  'category': instance.category,
  'tags': instance.tags,
  'status': instance.status,
  'priority': instance.priority,
  'view_count': instance.viewCount,
  'like_count': instance.likeCount,
  'comment_count': instance.commentCount,
  'user': instance.user,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

DetailItem _$DetailItemFromJson(Map<String, dynamic> json) => DetailItem(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String,
  description: json['description'] as String,
  images: json['images'] as String?,
  videos: json['videos'] as String?,
  files: json['files'] as String?,
  category: json['category'] as String,
  type: json['type'] as String,
  status: json['status'] as String,
  priority: (json['priority'] as num).toInt(),
  viewCount: (json['view_count'] as num).toInt(),
  likeCount: (json['like_count'] as num).toInt(),
  commentCount: (json['comment_count'] as num).toInt(),
  shareCount: (json['share_count'] as num).toInt(),
  tags: json['tags'] as String,
  metadata: json['metadata'] as String?,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  parent: json['parent'],
  children: json['children'] as List<dynamic>,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$DetailItemToJson(DetailItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'description': instance.description,
      'images': instance.images,
      'videos': instance.videos,
      'files': instance.files,
      'category': instance.category,
      'type': instance.type,
      'status': instance.status,
      'priority': instance.priority,
      'view_count': instance.viewCount,
      'like_count': instance.likeCount,
      'comment_count': instance.commentCount,
      'share_count': instance.shareCount,
      'tags': instance.tags,
      'metadata': instance.metadata,
      'user': instance.user,
      'parent': instance.parent,
      'children': instance.children,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
