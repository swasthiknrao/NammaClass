import 'package:flutter/material.dart';

import '../../shared/messaging/messaging_policy.dart';
import '../../shared/messaging/school_comms_screen.dart';

/// HOD entry to [SchoolCommsScreen] (department-scoped recipients).
class HodCommsScreen extends StatelessWidget {
  const HodCommsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SchoolCommsScreen(access: SchoolCommsAccess.hod);
  }
}
