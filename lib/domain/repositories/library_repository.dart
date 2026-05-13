import '../entities/library_entity.dart';

/// Contract for library catalog and issue operations.
abstract class LibraryRepository {
  /// Returns the full book catalog, optionally filtered by [query] and [category].
  Future<List<LibraryBook>> getBooks({String? query, String? category});

  /// Returns active and past issue records for [borrowerId].
  Future<List<BookIssue>> getIssuesForUser(String borrowerId);

  /// Librarian: issues [bookId] to [borrowerId].
  Future<BookIssue> issueBook({
    required String bookId,
    required String borrowerId,
    required DateTime dueDate,
  });

  /// Librarian: records the return of the book for [issueId].
  Future<void> returnBook(String issueId);
}
