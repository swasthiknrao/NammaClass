import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../routing/app_routes.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.teal,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Good Morning, Rajesh!',
                style: AppTypography.titleMedium.copyWith(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.teal,
                      AppColors.teal.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Today's attendance card
                NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Today\'s Attendance',
                                  style: AppTypography.titleSmall,
                                ),
                                Text(
                                  'Checked in at 8:32 AM ✓ | Duration: 4h 12m',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () =>
                              context.go(AppRoutes.staffAttendance),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.error.withValues(
                              alpha: 0.1,
                            ),
                            foregroundColor: AppColors.error,
                          ),
                          icon: const Icon(Icons.logout, size: 16),
                          label: const Text('Check Out'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Leave balance
                Text('Leave Balance', style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        '8/12',
                        'CL',
                        AppColors.primary,
                        () => context.go(AppRoutes.staffLeaves),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _MiniStatCard(
                        '6/12',
                        'SL',
                        AppColors.teal,
                        () => context.go(AppRoutes.staffLeaves),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _MiniStatCard(
                        '15/30',
                        'EL',
                        AppColors.accent,
                        () => context.go(AppRoutes.staffLeaves),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Food / Canteen card
                NcCard(
                  onTap: () => context.go(AppRoutes.staffCanteen),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Canteen & Food',
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Order meals, manage subscriptions',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Pending tasks
                Text('Pending Tasks', style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                _PendingTaskCard(
                  'Leave Approvals',
                  '2 pending',
                  Icons.how_to_reg_outlined,
                  AppColors.warning,
                ),
                const SizedBox(height: AppSpacing.xs),
                _PendingTaskCard(
                  'Diary Entries',
                  '1 pending',
                  Icons.edit_note_outlined,
                  AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),

                // Upcoming leave
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_available,
                        color: AppColors.teal,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Your leave is approved for 10–12 Mar',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Staff notices
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Staff Notices', style: AppTypography.titleSmall),
                    TextButton(onPressed: () {}, child: const Text('View All')),
                  ],
                ),
                ..._staffNotices.map((n) => _NoticeListTile(n)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

const _staffNotices = [
  ('Payroll for March 2026 has been processed', 'HR Dept', 'Mar 5'),
  (
    'Mandatory CPD training on Mar 15 — attendance required',
    'Principal',
    'Mar 3',
  ),
  ('Updated leave policy effective April 1, 2026', 'Admin', 'Mar 1'),
];

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard(this.value, this.label, this.color, this.onTap);
  final String value;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
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
    );
  }
}

class _PendingTaskCard extends StatelessWidget {
  const _PendingTaskCard(this.title, this.subtitle, this.icon, this.color);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMedium),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _NoticeListTile extends StatelessWidget {
  const _NoticeListTile(this.notice);
  final (String, String, String) notice;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(
        Icons.info_outline,
        color: AppColors.primary,
        size: 18,
      ),
      title: Text(notice.$1, style: AppTypography.bodySmall),
      subtitle: Text(
        '${notice.$2} · ${notice.$3}',
        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
