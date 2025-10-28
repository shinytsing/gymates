import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';

// Auth State
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null && token != null;

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._apiService, this._storage) : super(const AuthState()) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final token = await _storage.read(key: AppConstants.tokenKey);
      final userJson = await _storage.read(key: AppConstants.userKey);
      
      if (token != null && userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        state = state.copyWith(
          user: user,
          token: token,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);
      
      if (response.success && response.data != null) {
        final authResponse = response.data!;
        
        // Save tokens and user data
        await _storage.write(key: AppConstants.tokenKey, value: authResponse.token);
        await _storage.write(key: AppConstants.refreshTokenKey, value: authResponse.refreshToken);
        await _storage.write(key: AppConstants.userKey, value: jsonEncode(authResponse.user.toJson()));
        
        state = state.copyWith(
          user: authResponse.user,
          token: authResponse.token,
          isLoading: false,
        );
        
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? '登录失败',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String confirmPassword) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      final response = await _apiService.register(request);
      
      if (response.success && response.data != null) {
        final authResponse = response.data!;
        
        // Save tokens and user data
        await _storage.write(key: AppConstants.tokenKey, value: authResponse.token);
        await _storage.write(key: AppConstants.refreshTokenKey, value: authResponse.refreshToken);
        await _storage.write(key: AppConstants.userKey, value: jsonEncode(authResponse.user.toJson()));
        
        state = state.copyWith(
          user: authResponse.user,
          token: authResponse.token,
          isLoading: false,
        );
        
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? '注册失败',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
      state = const AuthState();
    } catch (e) {
      // Even if logout fails on server, clear local data
      state = const AuthState();
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final apiServiceProvider = Provider<ApiService>((ref) {
  final apiService = ApiService();
  apiService.init();
  return apiService;
});

final storageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storage = ref.watch(storageProvider);
  return AuthNotifier(apiService, storage);
});

// Convenience providers
final userProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).error;
});
