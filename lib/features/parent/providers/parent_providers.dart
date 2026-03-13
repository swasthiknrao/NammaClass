import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';

// ── Parent providers ────────────────────────────────────────────────────────────

final parentChildProvider = Provider<MockStudent>((ref) {
  return MockData.students.first;
});

final parentTimetableProvider = FutureProvider<Map<String, List<MockPeriod>>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.timetable;
});

final parentAttendanceProvider = FutureProvider<List<MockAttendanceDay>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.attendance;
});

final parentFeesProvider = FutureProvider<List<MockFeeInstallment>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.fees;
});

final parentDiaryProvider = FutureProvider<List<MockDiaryEntry>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.diary;
});

final parentChatThreadsProvider = FutureProvider<List<MockChatThread>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.chatThreads;
});

final parentMessagesProvider = FutureProvider<List<MockMessage>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.messages;
});

final parentNoticesProvider = FutureProvider<List<MockNotice>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.notices;
});

final parentCanteenMenuProvider = FutureProvider<List<MockCanteenItem>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.canteenMenu;
});
