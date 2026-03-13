import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../routing/app_routes.dart';

/// Warden dashboard: today's overview, quick stats, pending tasks.
class WardenHomeScreen extends StatelessWidget {
  const WardenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final students = MockData.hostelStudents;
    final visitors = MockData.visitors;
    final outpasses = MockData.hostelOutpasses;
    final activeVisitors = visitors.where((v) => v.checkOutTime == null).length;
    final absentCount = students.where((s) => !s.isPresent).length;
    final presentCount = students.length - absentCount;
    final pendingOutpasses =
        outpasses.where((o) => o.status == 'pending').length;

    return Scaffold(
      appBar: AppBar(title: const Text('Hostel Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            NcCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.night_shelter,
                      size: 36,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${_greeting}',
                          style: AppTypography.titleMedium,
                        ),
                        Text(
                          '${AppFormatters.shortDate(DateTime.now())}  ·  Roll call at 8:00 PM',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Quick stats
            Text('Today\'s Overview', style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Present',
                    value: '$presentCount',
                    color: AppColors.success,
                    icon: Icons.check_circle,
                    onTap: () => context.go(AppRoutes.wardenRollcall),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    label: 'Absent',
                    value: '$absentCount',
                    color: AppColors.error,
                    icon: Icons.cancel,
                    onTap: () => context.go(AppRoutes.wardenRollcall),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Visitors Inside',
                    value: '$activeVisitors',
                    color: AppColors.accent,
                    icon: Icons.person_search,
                    onTap: () => context.go(AppRoutes.wardenVisitors),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    label: 'Outpass Pending',
                    value: '$pendingOutpasses',
                    color: AppColors.warning,
                    icon: Icons.event_busy,
                    onTap: () => context.go(AppRoutes.wardenOutpass),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Pending tasks
            Text('Quick Actions', style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            _QuickActionTile(
              icon: Icons.how_to_reg,
              title: 'Evening Roll Call',
              subtitle: absentCount > 0
                  ? '$absentCount absent – enter reasons'
                  : 'All students accounted',
              color: AppColors.teal,
              onTap: () => context.go(AppRoutes.wardenRollcall),
            ),
            _QuickActionTile(
              icon: Icons.badge,
              title: 'Visitor Log',
              subtitle: activeVisitors > 0
                  ? '$activeVisitors visitor(s) inside'
                  : 'Log check-in / check-out',
              color: AppColors.accent,
              onTap: () => context.go(AppRoutes.wardenVisitors),
            ),
            _QuickActionTile(
              icon: Icons.event_note,
              title: 'Outpass & Leave',
              subtitle: pendingOutpasses > 0
                  ? '$pendingOutpasses request(s) pending'
                  : 'Approve leave requests',
              color: AppColors.warning,
              onTap: () => context.go(AppRoutes.wardenOutpass),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Absent students needing attention
            if (absentCount > 0) ...[
              Text('Absent – Call Parents', style: AppTypography.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tap Roll Call to view details and call parents.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTypography.headlineSmall.copyWith(
                  color: color,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: AppTypography.labelLarge),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
