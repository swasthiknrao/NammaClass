import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../auth/providers/auth_provider.dart';

final staffAttendanceProvider = FutureProvider<List<MockStaffAttendanceDay>>(
  (ref) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final empId = ref.watch(currentUserProvider)?.employeeId;
    if (empId == null) return [];
    return MockData.staffAttendance
        .where((d) => d.employeeId == null || d.employeeId == empId)
        .toList();
  },
);

final staffPayslipsProvider = FutureProvider<List<MockPayslip>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  final empId = ref.watch(currentUserProvider)?.employeeId;
  if (empId == null) return [];
  return MockData.payslips
      .where((p) => p.employeeId == null || p.employeeId == empId)
      .toList();
});

final staffTrainingsProvider = FutureProvider<List<MockTraining>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  final empId = ref.watch(currentUserProvider)?.employeeId;
  if (empId == null) return [];
  return MockData.trainings
      .where((t) => t.employeeId == null || t.employeeId == empId)
      .toList();
});
