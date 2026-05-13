import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/env_config.dart';
import '../../core/mock/mock_data.dart';
import '../../core/services/app_logger.dart';
import '../../domain/entities/library_entity.dart';
import '../../domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<LibraryBook>> getBooks({String? query, String? category}) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      var books = MockData.books.map(
        (b) => LibraryBook(
          id: b.id,
          title: b.title,
          author: b.author,
          category: b.category,
          totalCopies: b.totalCopies,
          availableCopies: b.availableCopies,
          isbn: b.isbn,
          coverUrl: b.coverUrl,
          accessionCode: b.accessionCode,
          isDigital: b.format.name == 'softcopy',
        ),
      );

      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        books = books.where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q),
        );
      }
      if (category != null && category.isNotEmpty) {
        books = books.where((b) => b.category == category);
      }

      return books.toList();
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/library/books',
        queryParameters: {
          if (query != null) 'query': query,
          if (category != null) 'category': category,
        },
      );
      return (response.data ?? [])
          .map((e) => LibraryBook.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.instance.error('LibraryRepository: getBooks', e, e.stackTrace);
      return [];
    }
  }

  @override
  Future<List<BookIssue>> getIssuesForUser(String borrowerId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return MockData.bookIssues
          .where((i) => i.borrowerId == borrowerId || i.borrowerId == null)
          .map(
            (i) => BookIssue(
              id: i.id,
              bookId: i.bookAccession, // accession code used as book reference
              bookTitle: i.bookTitle,
              borrowerId: i.borrowerId ?? borrowerId,
              borrowerName: i.borrowerName,
              issueDate: i.issueDate,
              dueDate: i.dueDate,
              fineAmountPaise: i.finePaise,
            ),
          )
          .toList();
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/library/issues',
        queryParameters: {'borrowerId': borrowerId},
      );
      return (response.data ?? [])
          .map((e) => BookIssue.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.instance.error(
        'LibraryRepository: getIssuesForUser',
        e,
        e.stackTrace,
      );
      return [];
    }
  }

  @override
  Future<BookIssue> issueBook({
    required String bookId,
    required String borrowerId,
    required DateTime dueDate,
  }) async {
    final id = const Uuid().v4();
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return BookIssue(
        id: id,
        bookId: bookId,
        bookTitle: '',
        borrowerId: borrowerId,
        borrowerName: '',
        issueDate: DateTime.now(),
        dueDate: dueDate,
      );
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/library/issue',
        data: {
          'book_id': bookId,
          'borrower_id': borrowerId,
          'due_date': dueDate.toIso8601String(),
        },
      );
      return BookIssue.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.instance.error('LibraryRepository: issueBook', e, e.stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> returnBook(String issueId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      return;
    }

    try {
      await _dio.patch<void>('/library/issues/$issueId/return');
    } on DioException catch (e) {
      AppLogger.instance.error(
        'LibraryRepository: returnBook',
        e,
        e.stackTrace,
      );
      rethrow;
    }
  }
}
