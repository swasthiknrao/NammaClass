import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transition: fade + slide. Use in go_router customTransitionPage.
CustomTransitionPage<void> fadeSlideTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  const duration = Duration(milliseconds: 250);
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.02, 0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      final slide = Tween<Offset>(begin: begin, end: end).animate(
        CurvedAnimation(parent: animation, curve: curve),
      );
      final fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: animation, curve: curve),
      );
      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}
