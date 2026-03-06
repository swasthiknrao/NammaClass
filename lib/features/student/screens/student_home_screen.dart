import 'package:fl_chart/fl_chart.dart';
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
import '../../../core/widgets/nc_shimmer.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../routing/app_routes.dart';
import '../providers/student_providers.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final attendanceAsync = ref.watch(studentAttendanceProvider);
    final homeworkAsync = ref.watch(studentHomeworkProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.teal, AppColors.primary],
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
                                'Hello, ${user?.name.split(' ').first ?? 'Student'}!',
                                style: AppTypography.headlineMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Class ${user?.classSection ?? '8-A'}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Wallet chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '₹350',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        NcAvatar(
                          name: user?.name ?? 'S',
                          radius: 18,
                          showBorder: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.go(AppRoutes.notifications),
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attendance pie
                  Row(
                    children: [
                      // Pie chart
                      attendanceAsync.when(
                        data: (attendance) {
                          final present = attendance
                              .where((a) => a.status == 'present')
                              .length;
                          final total = attendance
                              .where((a) => a.status != 'holiday')
                              .length;
                          final pct = total > 0 ? present / total : 0.0;
                          return Expanded(
                            child: NcCard(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: PieChart(
                                      PieChartData(
                                        sections: [
                                          PieChartSectionData(
                                            value: pct * 100,
                                            color: AppColors.success,
                                            radius: 12,
                                            title: '',
                                          ),
                                          PieChartSectionData(
                                            value: (1 - pct) * 100,
                                            color: AppColors.background,
                                            radius: 12,
                                            title: '',
                                          ),
                                        ],
                                        centerSpaceRadius: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pct.asPercent,
                                        style: AppTypography.headlineMedium
                                            .copyWith(color: AppColors.success),
                                      ),
                                      Text(
                                        'Attendance',
                                        style: AppTypography.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        loading: () => Expanded(child: NcShimmerStatCard()),
                        error: (e, _) => const SizedBox.shrink(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: NcCard(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.library_books,
                                color: AppColors.teal,
                                size: 28,
                              ),
                              Text(
                                '2',
                                style: AppTypography.headlineMedium.copyWith(
                                  color: AppColors.teal,
                                ),
                              ),
                              Text('Books Due', style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Today's timetable strip
                  Text("Today's Timetable", style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 85,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (MockData.timetable['Monday'] ?? []).length,
                      itemBuilder: (ctx, i) {
                        final p = MockData.timetable['Monday']![i];
                        return Container(
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          width: 90,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(AppSpacing.xs),
                            border: Border(
                              bottom: BorderSide(
                                color: p.subject.subjectColor,
                                width: 3,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                p.subject,
                                style: AppTypography.labelSmall,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
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

                  // Homework due card
                  homeworkAsync.when(
                    data: (diary) {
                      final pending = diary
                          .where((d) => !d.completed)
                          .take(2)
                          .toList();
                      if (pending.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Homework Due',
                            style: AppTypography.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          ...pending.map(
                            (d) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.xs,
                              ),
                              child: NcCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 40,
                                      color: d.subject.subjectColor,
                                      margin: const EdgeInsets.only(
                                        right: AppSpacing.sm,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            d.subject,
                                            style: AppTypography.labelMedium,
                                          ),
                                          Text(
                                            d.homework,
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => NcShimmerCard(),
                    error: (e, _) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
