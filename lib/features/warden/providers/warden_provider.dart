import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';

/// Hostel students for warden — mutable for roll call.
final wardenHostelStudentsProvider =
    StateProvider<List<MockHostelStudent>>((ref) {
  return List.from(MockData.hostelStudents);
});

/// Hostel outpass requests — mutable for approve/reject.
final wardenOutpassesProvider =
    StateProvider<List<MockHostelOutpass>>((ref) {
  return List.from(MockData.hostelOutpasses);
});

/// Get hostel student details by name (for visitor screen, etc.).
MockHostelStudent? getHostelStudentByName(String name) {
  for (final s in MockData.hostelStudents) {
    if (s.name == name) return s;
  }
  return null;
}
