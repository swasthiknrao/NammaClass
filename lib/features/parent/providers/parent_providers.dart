import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_model.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../auth/providers/auth_provider.dart';

// ── Parent providers ────────────────────────────────────────────────────────────

final parentChildProvider = Provider<MockStudent?>((ref) {
  ref.watch(dataSyncProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null || user.role != UserRole.parent) {
    return null;
  }
  final match = MockData.students.where(
    (s) => s.parentPhone == user.phone || s.parentName == user.name,
  );
  return match.isNotEmpty ? match.first : null;
});

final parentLeaveApplicationsProvider = Provider<List<MockLeaveApplication>>((
  ref,
) {
  ref.watch(dataSyncProvider);
  final child = ref.watch(parentChildProvider);
  if (child == null) return [];
  return MockData.leaveApplications
      .where((l) => l.childName == child.name)
      .toList();
});

final parentTimetableProvider = FutureProvider<Map<String, List<MockPeriod>>>((
  ref,
) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.timetable;
});

final parentAttendanceProvider = FutureProvider<List<MockAttendanceDay>>((
  ref,
) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.attendance;
});

final parentFeesProvider = FutureProvider<List<MockFeeInstallment>>((
  ref,
) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.fees;
});

final parentDiaryProvider = FutureProvider<List<MockDiaryEntry>>((ref) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.diary;
});

final parentChatThreadsProvider = FutureProvider<List<MockChatThread>>((
  ref,
) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.chatThreads;
});

final parentMessagesProvider = FutureProvider<List<MockMessage>>((ref) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.messages;
});

final parentNoticesProvider = FutureProvider<List<MockNotice>>((ref) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.notices;
});

final parentCanteenMenuProvider = FutureProvider<List<MockCanteenItem>>((
  ref,
) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.canteenMenu;
});
