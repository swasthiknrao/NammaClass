import 'package:flutter/material.dart';

/// Informs child screens that the shell provides a persistent top bar
/// (e.g. desktop MainShell). When true, screens should set appBar: null.
class ShellLayoutScope extends InheritedWidget {
  const ShellLayoutScope({
    super.key,
    required this.hasPersistentTopBar,
    required super.child,
  });

  final bool hasPersistentTopBar;

  static ShellLayoutScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShellLayoutScope>();
  }

  /// Returns null when shell provides top bar; otherwise builds a standard AppBar.
  static PreferredSizeWidget? appBar(
    BuildContext context,
    String title, {
    List<Widget>? actions,
  }) {
    if (maybeOf(context)?.hasPersistentTopBar == true) return null;
    return AppBar(title: Text(title), actions: actions);
  }

  @override
  bool updateShouldNotify(ShellLayoutScope old) =>
      hasPersistentTopBar != old.hasPersistentTopBar;
}
