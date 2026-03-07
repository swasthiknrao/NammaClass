import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';

final staffAttendanceProvider = FutureProvider<List<MockStaffAttendanceDay>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.staffAttendance;
});

final staffPayslipsProvider = FutureProvider<List<MockPayslip>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.payslips;
});

final staffTrainingsProvider = FutureProvider<List<MockTraining>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.trainings;
});
