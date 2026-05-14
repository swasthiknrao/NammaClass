import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/messaging/messaging_policy.dart';
import '../../shared/messaging/school_comms_screen.dart';

/// School ops use [SchoolCommsAccess.admin]; principal uses a separate lens.
class BroadcastScreen extends ConsumerWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final access = role == UserRole.principal
        ? SchoolCommsAccess.principal
        : SchoolCommsAccess.admin;
    return SchoolCommsScreen(access: access);
  }
}
