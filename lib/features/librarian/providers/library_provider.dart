import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';

/// Info returned when looking up a borrower (student or staff).
class LibraryBorrowerInfo {
  const LibraryBorrowerInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.info,
    required this.currentIssuesCount,
    required this.hasOverdue,
    required this.pendingFinePaise,
  });

  final String id;
  final String name;
  final LibraryBorrowerType type;
  final String info; // class section or department
  final int currentIssuesCount;
  final bool hasOverdue;
  final int pendingFinePaise;

  static const int maxStudentIssues = 3;
  static const int maxStaffIssues = 5;

  bool get canBorrow =>
      (type == LibraryBorrowerType.student &&
          currentIssuesCount < maxStudentIssues) ||
      (type == LibraryBorrowerType.staff &&
          currentIssuesCount < maxStaffIssues);

  bool get hasBlockingFine => hasOverdue && pendingFinePaise > 0;
}

/// Mutable book issues for librarian — supports add and remove.
class LibraryBookIssuesNotifier extends StateNotifier<List<MockBookIssue>> {
  LibraryBookIssuesNotifier(this._ref) : super(List.from(MockData.bookIssues)) {
    _ref.listen<int>(dataSyncProvider, (_, __) {
      state = List.from(MockData.bookIssues);
    });
  }

  final Ref _ref;

  void addIssue(MockBookIssue issue) {
    state = [...state, issue];
    _persistAndNotify();
  }

  void removeIssue(String issueId) {
    state = state.where((i) => i.id != issueId).toList();
    _persistAndNotify();
  }

  void replaceAll(List<MockBookIssue> issues) {
    state = List.from(issues);
    _persistAndNotify();
  }

  void _persistAndNotify() {
    MockData.bookIssues
      ..clear()
      ..addAll(state);
    _ref.read(dataSyncProvider.notifier).bump();
  }
}

final libraryBookIssuesProvider =
    StateNotifierProvider<LibraryBookIssuesNotifier, List<MockBookIssue>>(
      (ref) => LibraryBookIssuesNotifier(ref),
    );

/// Lookup borrower by ID, roll number, or employee code.
/// Returns null if not found.
LibraryBorrowerInfo? lookupBorrower(String query, List<MockBookIssue> issues) {
  if (query.trim().isEmpty) return null;
  final q = query.trim().toLowerCase();

  // Try student
  for (final s in MockData.students) {
    if (s.id.toLowerCase() == q ||
        s.rollNo == query.trim() ||
        s.id.replaceAll('s', '').padLeft(2, '0') == query.trim()) {
      final borrowerIssues = issues.where(
        (i) => i.borrowerId == s.id || i.studentName == s.name,
      );
      final overdueIssues = borrowerIssues.where((i) => i.isOverdue);
      final pendingFine = overdueIssues.fold<int>(
        0,
        (sum, i) => sum + i.finePaise,
      );
      return LibraryBorrowerInfo(
        id: s.id,
        name: s.name,
        type: LibraryBorrowerType.student,
        info: s.classSection,
        currentIssuesCount: borrowerIssues.length,
        hasOverdue: overdueIssues.isNotEmpty,
        pendingFinePaise: pendingFine,
      );
    }
  }

  // Try staff (by id: st01, st02, or partial match)
  for (final s in MockData.staff) {
    if (s.id.toLowerCase() == q ||
        s.id.replaceAll('st', '').padLeft(2, '0') == query.trim() ||
        s.name.toLowerCase().contains(q)) {
      final borrowerIssues = issues
          .where(
            (i) =>
                i.borrowerType == LibraryBorrowerType.staff &&
                (i.borrowerId == s.id || i.studentName == s.name),
          )
          .toList();
      final overdueIssues = borrowerIssues.where((i) => i.isOverdue);
      final pendingFine = overdueIssues.fold<int>(
        0,
        (sum, i) => sum + i.finePaise,
      );
      return LibraryBorrowerInfo(
        id: s.id,
        name: s.name,
        type: LibraryBorrowerType.staff,
        info: s.department,
        currentIssuesCount: borrowerIssues.length,
        hasOverdue: overdueIssues.isNotEmpty,
        pendingFinePaise: pendingFine,
      );
    }
  }

  return null;
}

/// Lookup book by accession code, ISBN, or ID.
MockBook? lookupBook(String query) {
  if (query.trim().isEmpty) return null;
  final q = query.trim().toLowerCase();

  for (final b in MockData.books) {
    if (b.id.toLowerCase() == q ||
        b.accessionOrId
            .toLowerCase()
            .replaceAll('-', '')
            .contains(q.replaceAll('-', '')) ||
        (b.isbn != null && b.isbn!.toLowerCase().contains(q)) ||
        b.title.toLowerCase().contains(q)) {
      return b;
    }
  }
  return null;
}

/// Find an active issue by book accession or barcode scan.
MockBookIssue? lookupIssueByBook(
  String accessionOrId,
  List<MockBookIssue> issues,
) {
  if (accessionOrId.trim().isEmpty) return null;
  final q = accessionOrId.trim().toLowerCase();

  for (final i in issues) {
    if (i.bookAccession
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .contains(q.replaceAll('-', '').replaceAll(' ', ''))) {
      return i;
    }
  }
  return null;
}

/// Count of currently issued copies for a book (by accession).
int issuedCountForBook(String bookAccessionOrId, List<MockBookIssue> issues) {
  final norm = bookAccessionOrId
      .toLowerCase()
      .replaceAll('-', '')
      .replaceAll(' ', '');
  return issues.where((i) {
    final issueNorm = i.bookAccession
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll(' ', '');
    return issueNorm.contains(norm) || norm.contains(issueNorm);
  }).length;
}
