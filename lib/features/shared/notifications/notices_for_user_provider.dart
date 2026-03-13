import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/librarian/providers/library_provider.dart';
import 'notification_service.dart';

/// Issue IDs that the user has dismissed from library overdue notices.
final libraryOverdueDismissedProvider =
    StateProvider<Set<String>>((ref) => {});

/// Borrower IDs for the current user (from MockData students/staff by name).
String? _currentUserBorrowerId(String? userName) {
  if (userName == null || userName.isEmpty) return null;
  for (final s in MockData.students) {
    if (s.name == userName) return s.id;
  }
  for (final s in MockData.staff) {
    if (s.name == userName) return s.id;
  }
  return null;
}

/// Merged notices for the current user: global notices + borrower-specific +
/// library overdue notices (converted from active issues).
final noticesForCurrentUserProvider = Provider<List<MockNotice>>((ref) {
  final user = ref.watch(currentUserProvider);
  final mainNotices = ref.watch(notificationServiceProvider);
  final issues = ref.watch(libraryBookIssuesProvider);
  final dismissed = ref.watch(libraryOverdueDismissedProvider);

  final borrowerId = user != null ? _currentUserBorrowerId(user.name) : null;
  final userName = user?.name;

  // Filter main notices: show if targetUserId is null (global) or matches
  final filtered = mainNotices.where((n) {
    if (n.targetUserId == null) return true;
    return n.targetUserId == borrowerId || n.targetUserId == userName;
  }).toList();

  // Add library overdue notices for this borrower
  final overdueNotices = <MockNotice>[];
  for (final i in issues) {
    if (!i.isOverdue) continue;
    if (dismissed.contains(i.id)) continue;
    final matches = (borrowerId != null && i.borrowerId == borrowerId) ||
        (userName != null && i.studentName == userName);
    if (matches) {
      overdueNotices.add(MockNotice(
        id: 'lib_overdue_${i.id}',
        title: 'Library book overdue: ${i.bookTitle}',
        body:
            'Please return "${i.bookTitle}" (${i.bookAccession}). '
            'Due date was ${i.dueDate.day}/${i.dueDate.month}/${i.dueDate.year}. '
            'Fine: ${AppFormatters.formatPaise(i.finePaise)}',
        date: i.dueDate,
        category: 'Library',
        isRead: false,
        targetUserId: borrowerId ?? userName,
      ));
    }
  }

  final merged = [...filtered, ...overdueNotices];
  merged.sort((a, b) => b.date.compareTo(a.date));
  return merged;
});
