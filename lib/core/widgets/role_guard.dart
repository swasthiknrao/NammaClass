import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Hides [child] when current user's role is not in [allowedRoles].
/// Use for role-scoped UI sections.
class RoleGuard extends ConsumerWidget {
  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  final Set<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    if (role == null || !allowedRoles.contains(role)) {
      return fallback ?? const SizedBox.shrink();
    }
    return child;
  }
}
