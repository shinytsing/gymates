import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../pages/training/training_page.dart';
import '../../features/community/screens/community_screen.dart';
import '../../features/community/screens/create_post_screen.dart';
import '../../features/mates/screens/mates_screen.dart';
import '../../features/messages/screens/messages_screen.dart';
import '../../features/messages/screens/chat_detail_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../shared/widgets/main_navigation.dart';

// Route paths
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String main = '/main';
  static const String training = '/main/training';
  static const String community = '/main/community';
  static const String createPost = '/main/community/create-post';
  static const String mates = '/main/mates';
  static const String partner = '/main/partner';
  static const String messages = '/main/messages';
  static const String chatDetail = '/main/messages/chat';
  static const String profile = '/main/profile';
  static const String editProfile = '/main/profile/edit';
}

// Router configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  
  return GoRouter(
    initialLocation: authState.isAuthenticated ? AppRoutes.main : AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      
      // Don't redirect if still loading
      if (isLoading) return null;
      
      // Redirect to login if not authenticated
      if (!isAuthenticated && !state.matchedLocation.startsWith('/login') && 
          !state.matchedLocation.startsWith('/register') && 
          !state.matchedLocation.startsWith('/onboarding')) {
        return AppRoutes.login;
      }
      
      // Redirect to main if authenticated and on auth screens
      if (isAuthenticated && (state.matchedLocation == AppRoutes.login || 
          state.matchedLocation == AppRoutes.register || 
          state.matchedLocation == AppRoutes.onboarding)) {
        return AppRoutes.main;
      }
      
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Main app with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.main,
            name: 'main',
            builder: (context, state) => const TrainingPage(),
            routes: [
              // Training routes
              GoRoute(
                path: 'training',
                name: 'training',
                builder: (context, state) => const TrainingPage(),
              ),
              
              // Community routes
              GoRoute(
                path: 'community',
                name: 'community',
                builder: (context, state) => const CommunityScreen(),
                routes: [
                  GoRoute(
                    path: 'create-post',
                    name: 'create-post',
                    builder: (context, state) => const CreatePostScreen(),
                  ),
                ],
              ),
              
              // Mates routes
              GoRoute(
                path: 'mates',
                name: 'mates',
                builder: (context, state) => const MatesScreen(),
              ),
              
              // Messages routes
              GoRoute(
                path: 'messages',
                name: 'messages',
                builder: (context, state) => const MessagesScreen(),
                routes: [
                  GoRoute(
                    path: 'chat/:chatId',
                    name: 'chat-detail',
                    builder: (context, state) {
                      final chatId = state.pathParameters['chatId']!;
                      final userName = state.uri.queryParameters['userName'] ?? 'Unknown';
                      return ChatDetailScreen(chatId: chatId, userName: userName);
                    },
                  ),
                ],
              ),
              
              // Profile routes
              GoRoute(
                path: 'profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'edit-profile',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '页面未找到',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '错误路径: ${state.matchedLocation}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.main),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Navigation helpers
class AppNavigation {
  static void goToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }
  
  static void goToRegister(BuildContext context) {
    context.go(AppRoutes.register);
  }
  
  static void goToOnboarding(BuildContext context) {
    context.go(AppRoutes.onboarding);
  }
  
  static void goToMain(BuildContext context) {
    context.go(AppRoutes.main);
  }
  
  static void goToTraining(BuildContext context) {
    context.go(AppRoutes.training);
  }
  
  static void goToCommunity(BuildContext context) {
    context.go(AppRoutes.community);
  }
  
  static void goToCreatePost(BuildContext context) {
    context.go(AppRoutes.createPost);
  }
  
  static void goToMates(BuildContext context) {
    context.go(AppRoutes.mates);
  }
  
  static void goToMessages(BuildContext context) {
    context.go(AppRoutes.messages);
  }
  
  static void goToChatDetail(BuildContext context, String chatId, String userName) {
    context.go('${AppRoutes.chatDetail}/$chatId?userName=$userName');
  }
  
  static void goToProfile(BuildContext context) {
    context.go(AppRoutes.profile);
  }
  
  static void goToEditProfile(BuildContext context) {
    context.go(AppRoutes.editProfile);
  }
  
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.main);
    }
  }
}
