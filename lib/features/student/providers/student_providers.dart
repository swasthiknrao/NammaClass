import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../librarian/providers/library_provider.dart';

final studentTimetableProvider = FutureProvider<Map<String, List<MockPeriod>>>((
  ref,
) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.timetable;
});

final studentHomeworkProvider = FutureProvider<List<MockDiaryEntry>>((
  ref,
) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.diary;
});

final studentAttendanceProvider = FutureProvider<List<MockAttendanceDay>>((
  ref,
) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.attendance;
});

final studentBooksProvider = FutureProvider<List<MockBook>>((ref) async {
  ref.watch(dataSyncProvider);
  final issues = ref.watch(libraryBookIssuesProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.books.map((book) {
    if (book.format == BookFormat.softcopy) return book;
    final issued = issues
        .where((i) => i.bookAccession == book.accessionOrId)
        .length;
    final availableCopies = (book.totalCopies - issued).clamp(
      0,
      book.totalCopies,
    );
    return MockBook(
      id: book.id,
      title: book.title,
      author: book.author,
      category: book.category,
      available: availableCopies > 0,
      issuedTo: book.issuedTo,
      coverUrl: book.coverUrl,
      isbn: book.isbn,
      format: book.format,
      totalCopies: book.totalCopies,
      availableCopies: availableCopies,
      accessionCode: book.accessionCode,
    );
  }).toList();
});

final studentNoticesProvider = FutureProvider<List<MockNotice>>((ref) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.notices;
});
