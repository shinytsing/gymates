import 'package:flutter/material.dart';
import '../../core/theme/apple_fitness_theme.dart';
import '../bars/appbar_3d.dart';

/// 📄 Page Scaffold 3D Component
/// 
/// Apple Fitness+ style page scaffold with consistent layout.
/// 
/// Usage:
/// ```dart
/// PageScaffold3D(
///   title: 'Training',
///   showAppBar: true,
///   child: YourContent(),
/// )
/// ```

class PageScaffold3D extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget child;
  final bool showAppBar;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final bool useSafeArea;
  final FloatingActionButton? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;

  const PageScaffold3D({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    required this.child,
    this.showAppBar = true,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
    this.backgroundGradient,
    this.useSafeArea = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppleFitnessTheme.backgroundPrimary,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        decoration: backgroundGradient != null
            ? BoxDecoration(gradient: backgroundGradient)
            : null,
        child: Column(
          children: [
            if (showAppBar)
              AppBar3D(
                title: title,
                subtitle: subtitle,
                leading: leading,
                actions: actions,
              ),
            Expanded(
              child: useSafeArea
                  ? SafeArea(
                      child: child,
                    )
                  : child,
            ),
          ],
        ),
      ),
    );
  }
}

