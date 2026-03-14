import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/widgets/notification_icon_button.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../routing/app_routes.dart';

class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    final today = _dayName();
    final periods = MockData.timetable[today] ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          if (ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar != true)
            SliverAppBar(
              expandedHeight: 130,
              floating: true,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good morning!',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  user?.name ?? 'Teacher',
                                  style: AppTypography.headlineLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  user?.classSection != null
                                      ? 'Class Teacher — ${user!.classSection}'
                                      : 'Teacher',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          NcAvatar(
                            name: user?.name ?? 'T',
                            radius: 22,
                            showBorder: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [const NotificationIconButton(iconColor: Colors.white)],
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stat cards
                  Row(
                    children: [
                      _StatCard(
                        'Students',
                        '35',
                        Icons.groups,
                        AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StatCard(
                        'Present',
                        '32',
                        Icons.check_circle,
                        AppColors.success,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StatCard(
                        'Pending HW',
                        '3',
                        Icons.assignment_late,
                        AppColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Today's schedule strip
                  Text("Today's Schedule", style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: periods.length,
                      itemBuilder: (ctx, i) {
                        final p = periods[i];
                        return Container(
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          width: 110,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                            border: Border(
                              left: BorderSide(
                                color: p.subject.subjectColor,
                                width: 3,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Period ${p.period}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                p.subject,
                                style: AppTypography.labelMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                p.startTime,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Pending tasks banner
                  NcCard(
                    color: AppColors.warningBg,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.pending_actions,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '3 diary entries pending for today',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.teacherDiary),
                          child: const Text('Fill'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Attendance reminder
                  NcCard(
                    color: AppColors.errorBg,
                    child: Row(
                      children: [
                        const Icon(Icons.how_to_reg, color: AppColors.error),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Attendance for Period 1 not marked yet',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.go(AppRoutes.teacherAttendance),
                          child: const Text('Mark'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.teacherAttendance),
        icon: const Icon(Icons.how_to_reg),
        label: const Text('Mark Attendance'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  String _dayName() {
    const days = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[DateTime.now().weekday];
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NcCard(
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(color: color),
            ),
            Text(
              label,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
