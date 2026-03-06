import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';

final studentTimetableProvider = FutureProvider<Map<String, List<MockPeriod>>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return MockData.timetable;
});

final studentHomeworkProvider = FutureProvider<List<MockDiaryEntry>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 700));
  return MockData.diary;
});

final studentAttendanceProvider = FutureProvider<List<MockAttendanceDay>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return MockData.attendance;
});

final studentBooksProvider = FutureProvider<List<MockBook>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 800));
  return MockData.books;
});

final studentNoticesProvider = FutureProvider<List<MockNotice>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return MockData.notices;
});
