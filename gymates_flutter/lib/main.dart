import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/gymates_theme.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const ProviderScope(
      child: GymatesApp(),
    ),
  );
}

class GymatesApp extends ConsumerWidget {
  const GymatesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Gymates',
      debugShowCheckedModeBanner: false,
      theme: MaterialGymatesTheme.buildTheme(),
      darkTheme: MaterialGymatesTheme.buildDarkTheme(),
      themeMode: ThemeMode.system,
      
      // 路由配置
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.splash,
      
      // 高级配置
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0), // 防止文字缩放
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: GymatesTheme.getBackgroundGradient(
                Theme.of(context).brightness == Brightness.dark
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}