class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = '/api';
  static const String apiBaseUrl = '$baseUrl$apiVersion';
  
  // API Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  
  static const String homeList = '/home/list';
  static const String homeAdd = '/home/add';
  static const String homeUpdate = '/home/update';
  static const String homeDelete = '/home/delete';
  
  static const String trainingPlans = '/training/plans';
  static const String trainingSessions = '/training/sessions';
  
  static const String communityPosts = '/community/posts';
  static const String communityComments = '/community/posts';
  
  static const String matesList = '/mates';
  static const String matesRequests = '/mates/requests';
  
  static const String messagesChats = '/messages/chats';
  static const String messagesSend = '/messages/chats';
  
  static const String detailList = '/detail/list';
  static const String detailSubmit = '/detail/submit';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int maxNameLength = 50;
  static const int maxBioLength = 500;
  static const int maxPostLength = 2000;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Image Sizes
  static const double avatarSize = 40.0;
  static const double largeAvatarSize = 80.0;
  static const double postImageHeight = 200.0;
  
  // Colors
  static const int primaryColorValue = 0xFF007AFF;
  static const int secondaryColorValue = 0xFF5856D6;
  static const int successColorValue = 0xFF34C759;
  static const int warningColorValue = 0xFFFF9500;
  static const int errorColorValue = 0xFFFF3B30;
  static const int backgroundColorValue = 0xFFF2F2F7;
  static const int surfaceColorValue = 0xFFFFFFFF;
  static const int textPrimaryColorValue = 0xFF000000;
  static const int textSecondaryColorValue = 0xFF8E8E93;
}
