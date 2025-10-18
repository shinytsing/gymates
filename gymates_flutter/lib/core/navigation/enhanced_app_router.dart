import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/auth_provider.dart';
import '../../features/auth/screens/enhanced_login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/training/screens/enhanced_training_screen.dart';
import '../../features/community/screens/community_screen.dart';
import '../../features/community/screens/create_post_screen.dart';
import '../../features/mates/screens/mates_screen.dart';
import '../../features/messages/screens/messages_screen.dart';
import '../../features/messages/screens/chat_detail_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../shared/widgets/enhanced_navigation.dart';
import '../../core/animations/page_animations.dart';

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
  static const String messages = '/main/messages';
  static const String chatDetail = '/main/messages/chat';
  static const String profile = '/main/profile';
  static const String editProfile = '/main/profile/edit';
}

// Enhanced Router configuration with custom transitions
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
      // Auth routes with custom transitions
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const EnhancedLoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlidePageRoute(
              child: child,
              direction: SlideDirection.rightToLeft,
            ).transitionsBuilder(context, animation, secondaryAnimation, child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlidePageRoute(
              child: child,
              direction: SlideDirection.rightToLeft,
            ).transitionsBuilder(context, animation, secondaryAnimation, child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadePageRoute(child: child).transitionsBuilder(
              context, animation, secondaryAnimation, child);
          },
        ),
      ),
      
      // Main app with enhanced navigation
      ShellRoute(
        builder: (context, state, child) {
          return EnhancedMainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.main,
            name: 'main',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const EnhancedTrainingScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadePageRoute(child: child).transitionsBuilder(
                  context, animation, secondaryAnimation, child);
              },
            ),
            routes: [
              // Training routes
              GoRoute(
                path: 'training',
                name: 'training',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const EnhancedTrainingScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadePageRoute(child: child).transitionsBuilder(
                      context, animation, secondaryAnimation, child);
                  },
                ),
              ),
              
              // Community routes
              GoRoute(
                path: 'community',
                name: 'community',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const CommunityScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlidePageRoute(
                      child: child,
                      direction: SlideDirection.leftToRight,
                    ).transitionsBuilder(context, animation, secondaryAnimation, child);
                  },
                ),
                routes: [
                  GoRoute(
                    path: 'create-post',
                    name: 'create-post',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      child: const CreatePostScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return ScalePageRoute(child: child).transitionsBuilder(
                          context, animation, secondaryAnimation, child);
                      },
                    ),
                  ),
                ],
              ),
              
              // Mates routes
              GoRoute(
                path: 'mates',
                name: 'mates',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const MatesScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlidePageRoute(
                      child: child,
                      direction: SlideDirection.leftToRight,
                    ).transitionsBuilder(context, animation, secondaryAnimation, child);
                  },
                ),
              ),
              
              // Messages routes
              GoRoute(
                path: 'messages',
                name: 'messages',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const MessagesScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlidePageRoute(
                      child: child,
                      direction: SlideDirection.leftToRight,
                    ).transitionsBuilder(context, animation, secondaryAnimation, child);
                  },
                ),
                routes: [
                  GoRoute(
                    path: 'chat/:chatId',
                    name: 'chat-detail',
                    pageBuilder: (context, state) {
                      final chatId = state.pathParameters['chatId']!;
                      final userName = state.uri.queryParameters['userName'] ?? 'Unknown';
                      return CustomTransitionPage(
                        child: ChatDetailScreen(chatId: chatId, userName: userName),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlidePageRoute(
                            child: child,
                            direction: SlideDirection.bottomToTop,
                          ).transitionsBuilder(context, animation, secondaryAnimation, child);
                        },
                      );
                    },
                  ),
                ],
              ),
              
              // Profile routes
              GoRoute(
                path: 'profile',
                name: 'profile',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const ProfileScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlidePageRoute(
                      child: child,
                      direction: SlideDirection.leftToRight,
                    ).transitionsBuilder(context, animation, secondaryAnimation, child);
                  },
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'edit-profile',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      child: const EditProfileScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return ScalePageRoute(child: child).transitionsBuilder(
                          context, animation, secondaryAnimation, child);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSizes.spacingL),
              Text(
                '页面未找到',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                '错误路径: ${state.matchedLocation}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.spacingL),
              EnhancedButton(
                text: '返回首页',
                onPressed: () => context.go(AppRoutes.main),
                width: 200,
              ),
            ],
          ),
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
