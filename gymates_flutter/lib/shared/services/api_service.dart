import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../models/api_models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Auth endpoints
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        AppConstants.authLogin,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(response.data, (json) => AuthResponse.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        AppConstants.authRegister,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(response.data, (json) => AuthResponse.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }

  // Home endpoints
  Future<ApiResponse<HomeItem>> getHomeList({
    int page = 1,
    int limit = 10,
    String? category,
    String? keyword,
    String? sortBy,
    String? order,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (category != null) queryParams['category'] = category;
      if (keyword != null) queryParams['keyword'] = keyword;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (order != null) queryParams['order'] = order;

      final response = await _dio.get(
        AppConstants.homeList,
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(response.data, (json) => HomeItem.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<HomeItem>> addHomeItem(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        AppConstants.homeAdd,
        data: data,
      );
      return ApiResponse.fromJson(response.data, (json) => HomeItem.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<HomeItem>> updateHomeItem(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${AppConstants.homeUpdate}/$id',
        data: data,
      );
      return ApiResponse.fromJson(response.data, (json) => HomeItem.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<void>> deleteHomeItem(int id) async {
    try {
      final response = await _dio.delete('${AppConstants.homeDelete}/$id');
      return ApiResponse.fromJson(response.data, (json) => HomeItem.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Training endpoints
  Future<ApiResponse<List<TrainingPlan>>> getTrainingPlans({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.trainingPlans,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return ApiResponse.fromJson(response.data, (json) => List<TrainingPlan>.from((json as List).map((x) => TrainingPlan.fromJson(x as Map<String, dynamic>))));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<TrainingPlan>> createTrainingPlan(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        AppConstants.trainingPlans,
        data: data,
      );
      return ApiResponse.fromJson(response.data, (json) => TrainingPlan.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<WorkoutSession>> startWorkoutSession(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        AppConstants.trainingSessions,
        data: data,
      );
      return ApiResponse.fromJson(response.data, (json) => WorkoutSession.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Community endpoints
  Future<ApiResponse<List<Post>>> getCommunityPosts({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (type != null) queryParams['type'] = type;

      final response = await _dio.get(
        AppConstants.communityPosts,
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(response.data, (json) => List<Post>.from((json as List).map((x) => Post.fromJson(x as Map<String, dynamic>))));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<Post>> createPost(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        AppConstants.communityPosts,
        data: data,
      );
      return ApiResponse.fromJson(response.data, (json) => Post.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<void>> likePost(String postId) async {
    try {
      final response = await _dio.post('${AppConstants.communityPosts}/$postId/like');
      return ApiResponse.fromJson(response.data, (json) => HomeItem.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<List<Comment>>> getPostComments(String postId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConstants.communityPosts}/$postId/comments',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return ApiResponse.fromJson(response.data, (json) => List<Comment>.from((json as List).map((x) => Comment.fromJson(x as Map<String, dynamic>))));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<Comment>> createComment(String postId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '${AppConstants.communityPosts}/$postId/comments',
        data: data,
      );
      return ApiResponse.fromJson(response.data, (json) => Comment.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Mates endpoints
  Future<ApiResponse<List<Mate>>> getMates({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.matesList,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return ApiResponse.fromJson(response.data, (json) => (json as List).map((e) => Mate.fromJson(e as Map<String, dynamic>)).toList()));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<void>> sendMateRequest(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        AppConstants.matesRequests,
        data: data,
      );
      return ApiResponse.fromJson(response.data, (json) {});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Messages endpoints
  Future<ApiResponse<List<Chat>>> getChats({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.messagesChats,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return ApiResponse.fromJson(response.data, (json) => (json as List).map((e) => Chat.fromJson(e as Map<String, dynamic>)).toList()));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<List<Message>>> getChatMessages(String chatId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConstants.messagesChats}/$chatId/messages',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return ApiResponse.fromJson(response.data, (json) => (json as List).map((e) => Message.fromJson(e as Map<String, dynamic>)).toList()));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<Message>> sendMessage(String chatId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '${AppConstants.messagesChats}/$chatId/messages',
        data: data,
      );
      return ApiResponse.fromJson(response.data, (json) => Message.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Detail endpoints
  Future<ApiResponse<DetailItem>> getDetailList({
    int page = 1,
    int limit = 10,
    String? category,
    String? type,
    String? keyword,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (category != null) queryParams['category'] = category;
      if (type != null) queryParams['type'] = type;
      if (keyword != null) queryParams['keyword'] = keyword;

      final response = await _dio.get(
        AppConstants.detailList,
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(response.data, (json) => DetailItem.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<DetailItem>> getDetail(int id) async {
    try {
      final response = await _dio.get('${AppConstants.detailList}/$id');
      return ApiResponse.fromJson(response.data, (json) => DetailItem.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<DetailItem>> submitDetail(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        AppConstants.detailSubmit,
        data: data,
      );
      return ApiResponse.fromJson(response.data, (json) => DetailItem.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('网络连接超时，请检查网络设置');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? '请求失败';
        return Exception('请求失败 ($statusCode): $message');
      case DioExceptionType.cancel:
        return Exception('请求已取消');
      case DioExceptionType.connectionError:
        return Exception('网络连接错误，请检查网络设置');
      case DioExceptionType.badCertificate:
        return Exception('证书验证失败');
      case DioExceptionType.unknown:
      default:
        return Exception('未知错误: ${e.message}');
    }
  }
}

// Auth Interceptor
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken != null) {
        try {
          final dio = Dio();
          final response = await dio.post(
            '${AppConstants.apiBaseUrl}${AppConstants.authRefresh}',
            data: {'refresh_token': refreshToken},
          );
          
          if (response.statusCode == 200) {
            final authResponse = AuthResponse.fromJson(response.data['data']);
            await _storage.write(key: AppConstants.tokenKey, value: authResponse.token);
            await _storage.write(key: AppConstants.refreshTokenKey, value: authResponse.refreshToken);
            
            // Retry the original request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer ${authResponse.token}';
            final retryResponse = await Dio().fetch(options);
            handler.resolve(retryResponse);
            return;
          }
        } catch (e) {
          // Refresh failed, clear tokens
          await _storage.delete(key: AppConstants.tokenKey);
          await _storage.delete(key: AppConstants.refreshTokenKey);
          await _storage.delete(key: AppConstants.userKey);
        }
      }
    }
    handler.next(err);
  }
}
