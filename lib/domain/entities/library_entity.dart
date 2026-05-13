/// Physical or digital book in the library catalog.
class LibraryBook {
  const LibraryBook({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.totalCopies,
    required this.availableCopies,
    this.isbn,
    this.coverUrl,
    this.accessionCode,
    this.isDigital = false,
  });

  final String id;
  final String title;
  final String author;
  final String category;
  final int totalCopies;
  final int availableCopies;
  final String? isbn;
  final String? coverUrl;
  final String? accessionCode;

  /// True for e-books / soft copies.
  final bool isDigital;

  bool get isAvailable => availableCopies > 0;

  String get displayAccession =>
      accessionCode ??
      'ACC-${id.replaceAll(RegExp(r'\D'), '').padLeft(4, '0')}';

  factory LibraryBook.fromJson(Map<String, dynamic> json) => LibraryBook(
    id: json['id'] as String,
    title: json['title'] as String,
    author: json['author'] as String,
    category: (json['category'] as String?) ?? 'General',
    totalCopies: (json['total_copies'] as int?) ?? 1,
    availableCopies: (json['available_copies'] as int?) ?? 0,
    isbn: json['isbn'] as String?,
    coverUrl: json['cover_url'] as String?,
    accessionCode: json['accession_code'] as String?,
    isDigital: (json['is_digital'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'category': category,
    'total_copies': totalCopies,
    'available_copies': availableCopies,
    'isbn': isbn,
    'cover_url': coverUrl,
    'accession_code': accessionCode,
    'is_digital': isDigital,
  };
}

/// A book issue record — one book borrowed by one user.
class BookIssue {
  const BookIssue({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.borrowerId,
    required this.borrowerName,
    required this.issueDate,
    required this.dueDate,
    this.returnDate,
    this.fineAmountPaise = 0,
  });

  final String id;
  final String bookId;
  final String bookTitle;
  final String borrowerId;
  final String borrowerName;
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? returnDate;

  /// Fine in paise (1/100 of INR). Computed server-side.
  final int fineAmountPaise;

  bool get isOverdue => returnDate == null && DateTime.now().isAfter(dueDate);

  bool get isReturned => returnDate != null;

  factory BookIssue.fromJson(Map<String, dynamic> json) => BookIssue(
    id: json['id'] as String,
    bookId: json['book_id'] as String,
    bookTitle: (json['book_title'] as String?) ?? '',
    borrowerId: json['borrower_id'] as String,
    borrowerName: (json['borrower_name'] as String?) ?? '',
    issueDate: DateTime.parse(json['issue_date'] as String),
    dueDate: DateTime.parse(json['due_date'] as String),
    returnDate: json['return_date'] != null
        ? DateTime.parse(json['return_date'] as String)
        : null,
    fineAmountPaise: (json['fine_amount_paise'] as int?) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'book_id': bookId,
    'book_title': bookTitle,
    'borrower_id': borrowerId,
    'borrower_name': borrowerName,
    'issue_date': issueDate.toIso8601String(),
    'due_date': dueDate.toIso8601String(),
    'return_date': returnDate?.toIso8601String(),
    'fine_amount_paise': fineAmountPaise,
  };
}
