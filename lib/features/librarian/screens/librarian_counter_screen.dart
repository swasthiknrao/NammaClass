import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_card.dart';

class LibrarianCounterScreen extends ConsumerStatefulWidget {
  const LibrarianCounterScreen({super.key});

  @override
  ConsumerState<LibrarianCounterScreen> createState() =>
      _LibrarianCounterScreenState();
}

class _LibrarianCounterScreenState
    extends ConsumerState<LibrarianCounterScreen> {
  String _mode = 'Issue';
  bool _studentScanned = false;
  bool _bookScanned = false;
  MockBookIssue? _scannedIssue;
  final _manualCtrl = TextEditingController();

  void _simulateScan() {
    if (_mode == 'Return') {
      setState(() {
        _scannedIssue = MockData.bookIssues.first;
      });
    } else {
      if (!_studentScanned) {
        setState(() => _studentScanned = true);
        if (_scannedIssue != null && _scannedIssue!.isOverdue) {
          _showFineWarning();
        }
      } else {
        setState(() => _bookScanned = true);
      }
    }
  }

  void _showFineWarning() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pending Fine'),
        content: const Text(
          'This student has ₹25 pending fine. Proceed or collect fine first?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
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

  void _confirmIssue() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Issued! Return by: ${AppFormatters.shortDate(DateTime.now().add(const Duration(days: 14)))}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    setState(() {
      _studentScanned = false;
      _bookScanned = false;
    });
  }

  void _confirmReturn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Book returned successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
    setState(() => _scannedIssue = null);
  }

  @override
  void dispose() {
    _manualCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library Counter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick stats
            Row(
              children: [
                _StatChip('Issued Today', '12', AppColors.primary),
                _StatChip('Returned', '8', AppColors.success),
                _StatChip('Fines', '₹45', AppColors.error),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Mode toggle
            SegmentedButton<String>(
              selected: {_mode},
              onSelectionChanged: (v) => setState(() {
                _mode = v.first;
                _studentScanned = false;
                _bookScanned = false;
                _scannedIssue = null;
              }),
              segments: const [
                ButtonSegment(value: 'Issue', label: Text('Issue')),
                ButtonSegment(value: 'Return', label: Text('Return')),
                ButtonSegment(value: 'Renew', label: Text('Renew')),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Scan area placeholder
            GestureDetector(
              onTap: _simulateScan,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    width: 2,
                    style: BorderStyle.solid,
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
                          size: 48,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _mode == 'Issue'
                              ? _studentScanned
                                    ? 'Now scan the book barcode'
                                    : 'Scan student card QR'
                              : 'Scan book barcode',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to simulate scan',
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

            // Manual entry
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter student ID or accession number',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                FilledButton(
                  onPressed: () => _simulateScan(),
                  child: const Text('Go'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Issue flow
            if (_mode == 'Issue') ...[
              if (_studentScanned)
                NcCard(
                  child: Row(
                    children: [
                      const NcAvatar(name: 'Arjun Kumar', radius: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arjun Kumar',
                              style: AppTypography.titleSmall,
                            ),
                            Text(
                              'Class 8-A  ·  2 books issued  ·  No pending fines',
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
              if (_bookScanned) ...[
                const SizedBox(height: AppSpacing.sm),
                NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wings of Fire', style: AppTypography.titleSmall),
                      Text(
                        'By A.P.J. Abdul Kalam  ·  ACC-0042',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _confirmIssue,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.deepPurple,
                    ),
                    child: const Text('Issue Book'),
                  ),
                ),
              ],
            ],

            // Return flow
            if (_mode == 'Return' && _scannedIssue != null) ...[
              NcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _scannedIssue!.bookTitle,
                      style: AppTypography.titleSmall,
                    ),
                    Text(
                      'Borrower: ${_scannedIssue!.studentName} | ${_scannedIssue!.studentClass}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Issued: ${AppFormatters.shortDate(_scannedIssue!.issueDate)}  ·  Due: ${AppFormatters.shortDate(_scannedIssue!.dueDate)}',
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
                            const Icon(
                              Icons.warning_amber,
                              color: AppColors.error,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Overdue by ${DateTime.now().difference(_scannedIssue!.dueDate).inDays} days | Fine: ${AppFormatters.currency(_scannedIssue!.finePaise)}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _confirmReturn,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.teal,
                        ),
                        child: const Text('Confirm Return'),
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

    final rect = Rect.fromLTRB(
      margin,
      margin,
      size.width - margin,
      size.height - margin,
    );

    // Draw corner indicators
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLen, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + cornerLen),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - cornerLen, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLen),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLen, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - cornerLen),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - cornerLen, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLen),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ScanFramePainter _) => false;
}
