import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_empty_state.dart';

class LibrarianReservationsScreen extends ConsumerStatefulWidget {
  const LibrarianReservationsScreen({super.key});

  @override
  ConsumerState<LibrarianReservationsScreen> createState() =>
      _LibrarianReservationsScreenState();
}

class _LibrarianReservationsScreenState
    extends ConsumerState<LibrarianReservationsScreen> {
  String _filter = 'pending';
  final List<MockReservation> _reservations = MockData.reservations;

  List<MockReservation> get _filtered {
    if (_filter == 'all') return _reservations;
    return _reservations.where((r) => r.status == _filter).toList();
  }

  void _markReady(MockReservation r) {
    setState(() => r.status = 'ready');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${r.studentName} notified: "${r.bookTitle}" is ready for collection.',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _cancel(MockReservation r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Reservation'),
        content: Text('Cancel reservation for ${r.studentName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => r.status = 'cancelled');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reservation cancelled.'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ready':
        return AppColors.success;
      case 'expired':
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservations')),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['all', 'pending', 'ready', 'expired'].map((f) {
                  final selected = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: FilterChip(
                      label: Text(f[0].toUpperCase() + f.substring(1)),
                      selected: selected,
                      onSelected: (_) => setState(() => _filter = f),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: _filtered.isEmpty
                ? const NcEmptyState(
                    title: 'No reservations',
                    subtitle: 'No reservations in this category.',
                    icon: Icons.bookmark_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) => _ReservationCard(
                      reservation: _filtered[i],
                      statusColor: _statusColor(_filtered[i].status),
                      onMarkReady: _filtered[i].status == 'pending'
                          ? () => _markReady(_filtered[i])
                          : null,
                      onCancel: _filtered[i].status == 'pending'
                          ? () => _cancel(_filtered[i])
                          : null,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.statusColor,
    this.onMarkReady,
    this.onCancel,
  });

  final MockReservation reservation;
  final Color statusColor;
  final VoidCallback? onMarkReady;
  final VoidCallback? onCancel;

  String _expiryLabel() {
    final diff = reservation.expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'Expired ${diff.inHours.abs()}h ago';
    final hours = diff.inHours;
    return hours < 2
        ? 'Expires in ${diff.inMinutes}m ⚠'
        : 'Expires in ${hours}h';
  }

  @override
  Widget build(BuildContext context) {
    final expiryStr = _expiryLabel();
    final isExpiringSoon = expiryStr.contains('⚠');
    return NcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reservation.bookTitle,
                  style: AppTypography.titleSmall,
                ),
              ),
              NcStatusChip(
                label: reservation.status.toUpperCase(),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'ACC: ${reservation.bookAccession}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.person,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${reservation.studentName} | ${reservation.studentClass}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            expiryStr,
            style: AppTypography.bodySmall.copyWith(
              color: isExpiringSoon
                  ? AppColors.warning
                  : AppColors.textSecondary,
            ),
          ),
          if (onMarkReady != null || onCancel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (onMarkReady != null)
                  Expanded(
                    child: FilledButton(
                      onPressed: onMarkReady,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Mark Ready'),
                    ),
                  ),
                if (onMarkReady != null && onCancel != null)
                  const SizedBox(width: AppSpacing.xs),
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
