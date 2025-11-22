import 'package:flutter/material.dart';

/// 🎬 Apple Fitness+ Style Page Transitions
/// 
/// Design Principles:
/// - Smooth and natural (easeInOutCubic)
/// - Subtle 3D depth effects
/// - Respectful of system preferences
/// - Not distracting from content

/// 🔄 Push 3D Transition (slide from right with subtle depth)
class Push3DTransition extends PageRouteBuilder {
  final Widget page;
  
  Push3DTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            
            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
        );
}

/// 🔙 Pop 3D Transition (slide to right with subtle depth)
class Pop3DTransition extends PageRouteBuilder {
  final Widget page;
  
  Pop3DTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            
            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
        );
}

/// 🎭 Modal 3D Transition (slide from bottom with fade)
class Modal3DTransition extends PageRouteBuilder {
  final Widget page;
  
  Modal3DTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            final slideTween = Tween(begin: begin, end: end);
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            
            return SlideTransition(
              position: slideTween.animate(curvedAnimation),
              child: FadeTransition(
                opacity: fadeTween.animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

/// 🌊 Fade 3D Transition (fade with subtle scale)
class Fade3DTransition extends PageRouteBuilder {
  final Widget page;
  
  Fade3DTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0);
            final scaleTween = Tween<double>(begin: 0.95, end: 1.0);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );
            
            return FadeTransition(
              opacity: fadeTween.animate(curvedAnimation),
              child: ScaleTransition(
                scale: scaleTween.animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

/// 🔄 Scale 3D Transition (zoom in/out effect)
class Scale3DTransition extends PageRouteBuilder {
  final Widget page;
  final bool reverse;
  
  Scale3DTransition({required this.page, this.reverse = false})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleTween = Tween<double>(
              begin: reverse ? 1.2 : 0.8,
              end: 1.0,
            );
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            
            return FadeTransition(
              opacity: fadeTween.animate(curvedAnimation),
              child: ScaleTransition(
                scale: scaleTween.animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

/// 🎬 Helper functions for easy navigation with 3D transitions
extension Navigation3D on BuildContext {
  /// Push page with 3D transition
  Future<T?> push3D<T>(Widget page) {
    return Navigator.of(this).push<T>(
      Push3DTransition(page: page) as Route<T>,
    );
  }
  
  /// Push replacement with 3D transition
  Future<T?> pushReplacement3D<T, TO>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(
      Push3DTransition(page: page) as Route<T>,
    );
  }
  
  /// Present modal with 3D transition
  Future<T?> presentModal3D<T>(Widget page) {
    return Navigator.of(this).push<T>(
      Modal3DTransition(page: page) as Route<T>,
    );
  }
  
  /// Fade to page with 3D transition
  Future<T?> fadeTo3D<T>(Widget page) {
    return Navigator.of(this).push<T>(
      Fade3DTransition(page: page) as Route<T>,
    );
  }
  
  /// Scale to page with 3D transition
  Future<T?> scaleTo3D<T>(Widget page, {bool reverse = false}) {
    return Navigator.of(this).push<T>(
      Scale3DTransition(page: page, reverse: reverse) as Route<T>,
    );
  }
}

