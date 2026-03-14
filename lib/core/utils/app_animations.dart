import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// NammaClass animation constants and helpers — Phase 4C.
class AppAnimations {
  AppAnimations._();

  static const Duration pageTransition = Duration(milliseconds: 200);
  static const Duration cardHover = Duration(milliseconds: 150);
  static const Duration buttonPress = Duration(milliseconds: 100);
  static const Duration listStaggerItem = Duration(milliseconds: 40);
  static const Duration modalOpen = Duration(milliseconds: 180);
  static const Duration toast = Duration(seconds: 3);
  static const Duration drawerOpen = Duration(milliseconds: 250);

  static const Curve pageCurve = Curves.easeOut;
  static const Curve modalCurve = Curves.easeOut;

  /// Page transition: fade + slight slide
  static Widget pageTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.02, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: pageCurve)),
        child: child,
      ),
    );
  }

  /// Haptic feedback for button press
  static void buttonPressHaptic() {
    HapticFeedback.lightImpact();
  }

  /// Stagger delay for list item at index
  static Duration staggerDelay(int index) =>
      Duration(milliseconds: index * listStaggerItem.inMilliseconds);
}
