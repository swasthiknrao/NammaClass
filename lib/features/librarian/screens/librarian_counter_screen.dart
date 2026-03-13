import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_card.dart';
import '../providers/library_provider.dart';

class LibrarianCounterScreen extends ConsumerStatefulWidget {
  const LibrarianCounterScreen({super.key});

  @override
  ConsumerState<LibrarianCounterScreen> createState() => _LibrarianCounterScreenState();
}

class _LibrarianCounterScreenState extends ConsumerState<LibrarianCounterScreen> {
  String _mode = 'Issue';
  LibraryBorrowerInfo? _borrower;
  MockBook? _selectedBook;
  MockBookIssue? _scannedIssue;
  final _borrowerCtrl = TextEditingController();
  final _bookCtrl = TextEditingController();
  String? _lookupError;

  static int _issueIdCounter = 100;

  void _onModeChange(String mode) {
    setState(() {
      _mode = mode;
      _borrower = null;
      _selectedBook = null;
      _scannedIssue = null;
      _borrowerCtrl.clear();
      _bookCtrl.clear();
      _lookupError = null;
    });
  }

  void _onBorrowerGo() {
    final issues = ref.read(libraryBookIssuesProvider);
    final info = lookupBorrower(_borrowerCtrl.text, issues);
    setState(() {
      _lookupError = null;
      if (info != null) {
        _borrower = info;
        if (info.hasBlockingFine) {
          _showFineWarning(info);
        }
      } else {
        _borrower = null;
        _lookupError = 'Borrower not found. Try student ID, roll no, or staff ID.';
      }
    });
  }

  void _showFineWarning(LibraryBorrowerInfo info) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pending Fine'),
        content: Text(
          '${info.name} has ${AppFormatters.formatPaise(info.pendingFinePaise)} pending fine. Proceed or collect fine first?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Collect Fine'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Issue Anyway'),
          ),
        ],
      ),
    );
  }

  void _onBookGo() {
    if (_borrower == null && _mode == 'Issue') return;
    final issues = ref.read(libraryBookIssuesProvider);

    if (_mode == 'Return' || _mode == 'Renew') {
      final issue = lookupIssueByBook(_bookCtrl.text, issues);
      setState(() {
        _lookupError = null;
        if (issue != null) {
          _scannedIssue = issue;
          _borrower = null;
          _selectedBook = null;
        } else {
          _scannedIssue = null;
          _lookupError = 'No active issue found for this book.';
        }
      });
      return;
    }

    // Issue mode: lookup book
    final book = lookupBook(_bookCtrl.text);
    if (book == null) {
      setState(() {
        _selectedBook = null;
        _lookupError = 'Book not found. Try accession code or title.';
      });
      return;
    }

    final issued = issuedCountForBook(book.accessionOrId, issues);
    final canIssue = book.format == BookFormat.softcopy ||
        issued < book.totalCopies;
    if (!canIssue) {
      setState(() {
        _selectedBook = null;
        _lookupError = 'All copies of this book are currently issued.';
      });
      return;
    }

    setState(() {
      _lookupError = null;
      _selectedBook = book;
    });
  }

  void _simulateScan() {
    if (_mode == 'Return' || _mode == 'Renew') {
      _bookCtrl.text = ref.read(libraryBookIssuesProvider).isNotEmpty
          ? ref.read(libraryBookIssuesProvider).first.bookAccession
          : 'ACC-0042';
      _onBookGo();
    } else {
      if (_borrower == null) {
        _borrowerCtrl.text = 's01';
        _onBorrowerGo();
      } else {
        _bookCtrl.text = 'ACC-0003';
        _onBookGo();
      }
    }
  }

  void _confirmIssue() {
    if (_borrower == null || _selectedBook == null) return;
    final dueDate = DateTime.now().add(const Duration(days: 14));
    final issue = MockBookIssue(
      id: 'bi${_issueIdCounter++}',
      studentName: _borrower!.name,
      studentClass: _borrower!.info,
      bookTitle: _selectedBook!.title,
      bookAccession: _selectedBook!.accessionOrId,
      issueDate: DateTime.now(),
      dueDate: dueDate,
      isOverdue: false,
      borrowerType: _borrower!.type,
      borrowerId: _borrower!.id,
    );
    ref.read(libraryBookIssuesProvider.notifier).addIssue(issue);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Issued! Return by: ${AppFormatters.shortDate(dueDate)}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    setState(() {
      _borrower = null;
      _selectedBook = null;
      _borrowerCtrl.clear();
      _bookCtrl.clear();
    });
  }

  void _confirmReturn() {
    if (_scannedIssue == null) return;
    ref.read(libraryBookIssuesProvider.notifier).removeIssue(_scannedIssue!.id);
    final hadFine = _scannedIssue!.finePaise > 0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hadFine
              ? 'Book returned. Fine to collect: ${AppFormatters.formatPaise(_scannedIssue!.finePaise)}'
              : 'Book returned successfully!',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    setState(() {
      _scannedIssue = null;
      _bookCtrl.clear();
    });
  }

  void _confirmRenew() {
    if (_scannedIssue == null) return;
    final newDue = DateTime.now().add(const Duration(days: 14));
    final updated = MockBookIssue(
      id: _scannedIssue!.id,
      studentName: _scannedIssue!.studentName,
      studentClass: _scannedIssue!.studentClass,
      bookTitle: _scannedIssue!.bookTitle,
      bookAccession: _scannedIssue!.bookAccession,
      issueDate: _scannedIssue!.issueDate,
      dueDate: newDue,
      isOverdue: false,
      finePaise: 0,
      borrowerType: _scannedIssue!.borrowerType,
      borrowerId: _scannedIssue!.borrowerId,
    );
    ref.read(libraryBookIssuesProvider.notifier).replaceAll(
      ref.read(libraryBookIssuesProvider).map((i) {
        if (i.id == _scannedIssue!.id) return updated;
        return i;
      }).toList(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Renewed! New due date: ${AppFormatters.shortDate(newDue)}'),
        backgroundColor: AppColors.success,
      ),
    );
    setState(() {
      _scannedIssue = null;
      _bookCtrl.clear();
    });
  }

  @override
  void dispose() {
    _borrowerCtrl.dispose();
    _bookCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final issues = ref.watch(libraryBookIssuesProvider);
    final today = DateTime.now();
    final issuedToday = issues
        .where((i) =>
            i.issueDate.year == today.year &&
            i.issueDate.month == today.month &&
            i.issueDate.day == today.day)
        .length;
    final overdueCount = issues.where((i) => i.isOverdue).length;
    final finesTotal =
        issues.where((i) => i.isOverdue).fold<int>(0, (s, i) => s + i.finePaise);

    return Scaffold(
      appBar: AppBar(title: const Text('Library Counter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatChip('Issued Today', '$issuedToday', AppColors.primary),
                _StatChip('Active', '${issues.length}', AppColors.teal),
                _StatChip('Overdue', '$overdueCount', AppColors.error),
                _StatChip('Fines', AppFormatters.formatPaise(finesTotal), AppColors.warning),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<String>(
              selected: {_mode},
              onSelectionChanged: (v) => _onModeChange(v.first),
              segments: const [
                ButtonSegment(value: 'Issue', label: Text('Issue')),
                ButtonSegment(value: 'Return', label: Text('Return')),
                ButtonSegment(value: 'Renew', label: Text('Renew')),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: _simulateScan,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: CustomPaint(
                  painter: _ScanFramePainter(),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _mode == 'Issue'
                              ? _borrower == null
                                  ? 'Scan student/staff card'
                                  : 'Scan book barcode'
                              : 'Scan book barcode',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Tap to simulate',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_mode == 'Issue') ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _borrowerCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Borrower ID / Roll / Staff ID',
                        hintText: 'e.g. s01, 01, st01',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  FilledButton(
                    onPressed: _onBorrowerGo,
                    child: const Text('Go'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _bookCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Book accession / title',
                        hintText: 'e.g. ACC-0042',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  FilledButton(
                    onPressed: _onBookGo,
                    child: const Text('Go'),
                  ),
                ],
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _bookCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Book accession',
                        hintText: 'Scan or enter',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  FilledButton(onPressed: _onBookGo, child: const Text('Go')),
                ],
              ),
            if (_lookupError != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _lookupError!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),

            if (_mode == 'Issue') ...[
              if (_borrower != null)
                NcCard(
                  child: Row(
                    children: [
                      NcAvatar(name: _borrower!.name, radius: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_borrower!.name, style: AppTypography.titleSmall),
                            Text(
                              '${_borrower!.info}  ·  ${_borrower!.currentIssuesCount} issued  ·  ${_borrower!.hasOverdue ? "Overdue" : "No fines"}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: AppColors.success),
                    ],
                  ),
                ),
              if (_selectedBook != null) ...[
                if (_borrower != null) const SizedBox(height: AppSpacing.sm),
                NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_selectedBook!.title, style: AppTypography.titleSmall),
                          const SizedBox(width: AppSpacing.xs),
                          if (_selectedBook!.format == BookFormat.softcopy)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Digital',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.teal,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '${_selectedBook!.author}  ·  ${_selectedBook!.accessionOrId}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_borrower != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _borrower!.canBorrow ? _confirmIssue : null,
                      style: FilledButton.styleFrom(backgroundColor: AppColors.deepPurple),
                      child: Text(
                        _borrower!.canBorrow
                            ? 'Issue Book'
                            : 'Max issues reached',
                      ),
                    ),
                  ),
                ],
              ],
            ],

            if ((_mode == 'Return' || _mode == 'Renew') && _scannedIssue != null) ...[
              NcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_scannedIssue!.bookTitle, style: AppTypography.titleSmall),
                    Text(
                      'Borrower: ${_scannedIssue!.borrowerName} | ${_scannedIssue!.borrowerInfo}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Due: ${AppFormatters.shortDate(_scannedIssue!.dueDate)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_scannedIssue!.isOverdue) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber, color: AppColors.error, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Overdue | Fine: ${AppFormatters.formatPaise(_scannedIssue!.finePaise)}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    if (_mode == 'Return')
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _confirmReturn,
                          style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                          child: const Text('Confirm Return'),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _confirmRenew,
                          style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                          child: const Text('Renew (+14 days)'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                color: color,
                fontFamily: 'JetBrainsMono',
              ),
            ),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const cornerLen = 20.0;
    const margin = 24.0;
    final rect = Rect.fromLTRB(margin, margin, size.width - margin, size.height - margin);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + cornerLen, rect.top), paint);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left, rect.top + cornerLen), paint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right - cornerLen, rect.top), paint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right, rect.top + cornerLen), paint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + cornerLen, rect.bottom), paint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left, rect.bottom - cornerLen), paint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right - cornerLen, rect.bottom), paint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right, rect.bottom - cornerLen), paint);
  }

  @override
  bool shouldRepaint(_ScanFramePainter _) => false;
}
