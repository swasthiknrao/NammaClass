import 'package:flutter/material.dart';

import '../../../shared/widgets/layout/adaptive_scaffold.dart';

/// Root layout: nav rail / bottom nav and child outlet.
class ShellScreen extends StatelessWidget {
  const ShellScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(child: child);
  }
}
