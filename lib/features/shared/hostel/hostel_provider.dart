import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../auth/providers/auth_provider.dart';

/// Current user's hostel room info (for students).
/// Returns null if user is not a hostel student.
final hostelMyRoomProvider = Provider<MockHostelStudent?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final match = MockData.hostelStudents
      .where(
        (h) =>
            h.name == user.name ||
            (user.studentId != null && h.id == user.studentId),
      )
      .toList();
  return match.isNotEmpty ? match.first : null;
});
