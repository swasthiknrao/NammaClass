import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';

/// Constrains child to [AppConfig.maxContentWidth] and centers on large screens.
class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? AppConfig.maxContentWidth;
    final effectivePadding = padding ?? EdgeInsets.zero;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}
