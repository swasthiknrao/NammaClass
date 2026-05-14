import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_async_error.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/widgets/notification_icon_button.dart';
import '../../../shared/widgets/layout/constrained_content.dart';
import '../../../shared/widgets/layout/responsive_builder.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../domain/entities/nc_feature.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/tenant/providers/tenant_provider.dart';
import '../../../routing/app_routes.dart';
import '../../namma_ai/providers/namma_ai_panel_provider.dart';
import '../providers/parent_providers.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  static const _weekdays = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final tenant = ref.watch(tenantProfileProvider);
    final child = ref.watch(parentChildProvider);
    final feesAsync = ref.watch(parentFeesProvider);
    final noticesAsync = ref.watch(parentNoticesProvider);
    final timetableAsync = ref.watch(parentTimetableProvider);
    final attendanceAsync = ref.watch(parentAttendanceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          if (ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar != true)
            // SliverAppBar with greeting
            SliverAppBar(
              expandedHeight: 140,
              floating: true,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.primaryGradient,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good ${_greeting()}!',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  user?.name ?? 'Parent',
                                  style: AppTypography.headlineLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  AppConstants.schoolName,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          NcAvatar(
                            name: user?.name ?? 'P',
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
            child: ResponsiveBuilder(
              builder: (context, breakpoint, isMobile, isTablet, isDesktop) {
                if (isDesktop) {
                  return _ParentHomeDesktopLayout(
                    child: child,
                    feesAsync: feesAsync,
                    noticesAsync: noticesAsync,
                    timetableAsync: timetableAsync,
                    attendanceAsync: attendanceAsync,
                    weekdays: _weekdays,
                  );
                }
                final padding = isMobile ? AppSpacing.sm : AppSpacing.md;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.child_care,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              child != null
                                  ? '${child.name} • ${child.classSection}'
                                  : 'No student linked — ask admin to add your child.',
                              style: child != null
                                  ? AppTypography.labelLarge.copyWith(
                                      color: AppColors.primary,
                                    )
                                  : AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                            ),
                          ),
                          if (child != null)
                            NcStatusChip(
                              type: child.attendancePercent >= 0.85
                                  ? NcChipType.present
                                  : NcChipType.absent,
                              label: child.attendancePercent.asPercent,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    feesAsync.when(
                      data: (fees) {
                        final overdue = fees
                            .where((f) => f.status == 'overdue')
                            .toList();
                        if (overdue.isEmpty) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber,
                                color: AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${overdue.length} overdue fee installment(s). Please clear dues.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.go(AppRoutes.parentFees),
                                child: const Text('Pay Now'),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const NcShimmerBox(height: 50, radius: 8),
                      error: (e, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Text(
                        'Quick Actions',
                        style: AppTypography.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;
                          final itemWidth = w.isFinite
                              ? (w - (4 * 8)) / 5
                              : 64.0;
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _QuickAction(
                                Icons.calendar_month,
                                'Attendance',
                                AppColors.primary,
                                () => context.go(AppRoutes.parentAttendance),
                                itemWidth,
                              ),
                              _QuickAction(
                                Icons.payments,
                                'Fees',
                                AppColors.error,
                                () => context.go(AppRoutes.parentFees),
                                itemWidth,
                              ),
                              _QuickAction(
                                Icons.book,
                                'Diary',
                                AppColors.teal,
                                () => context.go(AppRoutes.parentDiary),
                                itemWidth,
                              ),
                              _QuickAction(
                                Icons.chat,
                                'Chat',
                                AppColors.accent,
                                () => context.go(AppRoutes.parentChatList),
                                itemWidth,
                              ),
                              _QuickAction(
                                Icons.event_busy,
                                'Leave',
                                AppColors.warning,
                                () => context.go(AppRoutes.parentLeaveApply),
                                itemWidth,
                              ),
                              if (tenant.hasFeature(NcFeature.aiInsights))
                                _QuickAction(
                                  Icons.auto_awesome,
                                  'Namma AI',
                                  AppColors.accent,
                                  () => ref
                                      .read(nammaAiPanelProvider.notifier)
                                      .open(),
                                  itemWidth,
                                ),
                              _QuickAction(
                                Icons.directions_bus,
                                'Bus',
                                AppColors.warning,
                                () => context.go(AppRoutes.parentBus),
                                itemWidth,
                              ),
                              _QuickAction(
                                Icons.campaign,
                                'Notices',
                                AppColors.primary,
                                () => context.go(AppRoutes.parentNotices),
                                itemWidth,
                              ),
                              _QuickAction(
                                Icons.restaurant,
                                'Canteen',
                                AppColors.success,
                                () => context.go(AppRoutes.parentCanteen),
                                itemWidth,
                              ),
                              _QuickAction(
                                Icons.hotel,
                                'Hostel',
                                AppColors.teal,
                                () => context.go(AppRoutes.hostel),
                                itemWidth,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: NcCard(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B4F72), Color(0xFF117A65)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => context.go(AppRoutes.parentBus),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.directions_bus,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (MockData.busInfo['route'] ?? '—')
                                        .toString(),
                                    style: AppTypography.labelLarge.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    (MockData.busInfo['busNumber'] ?? '—')
                                        .toString(),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${MockData.busInfo['etaMinutes'] ?? '—'} min',
                                  style: AppTypography.headlineMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'ETA',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: _TodaysTimetableSection(
                        timetableAsync: timetableAsync,
                        attendanceAsync: attendanceAsync,
                        weekdays: _weekdays,
                        sectionTitle: "Child's schedule today",
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Notices',
                            style: AppTypography.headlineSmall,
                          ),
                          TextButton(
                            onPressed: () =>
                                context.go(AppRoutes.parentNotices),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                    ),
                    noticesAsync.when(
                      data: (notices) => Column(
                        children: notices
                            .take(3)
                            .map((n) => _NoticePreview(notice: n))
                            .toList(),
                      ),
                      loading: () => Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: NcShimmerList(itemCount: 3),
                      ),
                      error: (e, _) => const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: NcAsyncError(message: 'Unable to load notices'),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}

// ── Desktop layout: bento-style grid ─────────────────────────────────────────

class _ParentHomeDesktopLayout extends StatelessWidget {
  const _ParentHomeDesktopLayout({
    required this.child,
    required this.feesAsync,
    required this.noticesAsync,
    required this.timetableAsync,
    required this.attendanceAsync,
    required this.weekdays,
  });

  final MockStudent? child;
  final AsyncValue<List<MockFeeInstallment>> feesAsync;
  final AsyncValue<List<MockNotice>> noticesAsync;
  final AsyncValue<Map<String, List<MockPeriod>>> timetableAsync;
  final AsyncValue<List<MockAttendanceDay>> attendanceAsync;
  final List<String> weekdays;

  @override
  Widget build(BuildContext context) {
    return ConstrainedContent(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero: child info + attendance
            _DesktopHeroCard(child: child),
            const SizedBox(height: AppSpacing.lg),

            // Fee alert
            feesAsync.when(
              data: (fees) {
                final overdue = fees
                    .where((f) => f.status == 'overdue')
                    .toList();
                if (overdue.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: _DesktopFeeAlert(overdueCount: overdue.length),
                );
              },
              loading: () => const NcShimmerBox(height: 56, radius: 12),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Bento grid
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final useNarrow = w < 1000;
                return useNarrow
                    ? _DesktopNarrowLayout(
                        timetableAsync: timetableAsync,
                        attendanceAsync: attendanceAsync,
                        noticesAsync: noticesAsync,
                        weekdays: weekdays,
                      )
                    : _DesktopWideLayout(
                        timetableAsync: timetableAsync,
                        attendanceAsync: attendanceAsync,
                        noticesAsync: noticesAsync,
                        weekdays: weekdays,
                      );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _DesktopHeroCard extends StatelessWidget {
  const _DesktopHeroCard({required this.child});
  final MockStudent? child;

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.card,
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(
          'No student record linked to your account yet.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    final c = child!;
    final isPresent = c.attendancePercent >= 0.85;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.9),
            AppColors.teal,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              c.name.substring(0, 1).toUpperCase(),
              style: AppTypography.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${c.classSection} • ${AppConstants.schoolName}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: (isPresent ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPresent ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  c.attendancePercent.asPercent,
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'attendance',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopFeeAlert extends StatelessWidget {
  const _DesktopFeeAlert({required this.overdueCount});
  final int overdueCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(AppRoutes.parentFees),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.errorBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  '$overdueCount overdue fee installment(s). Please clear dues.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Pay Now',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopWideLayout extends StatelessWidget {
  const _DesktopWideLayout({
    required this.timetableAsync,
    required this.attendanceAsync,
    required this.noticesAsync,
    required this.weekdays,
  });

  final AsyncValue<Map<String, List<MockPeriod>>> timetableAsync;
  final AsyncValue<List<MockAttendanceDay>> attendanceAsync;
  final AsyncValue<List<MockNotice>> noticesAsync;
  final List<String> weekdays;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Quick Actions + Bus
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DesktopQuickActionsGrid(),
              const SizedBox(height: AppSpacing.lg),
              _DesktopBusCard(),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        // Right: Schedule + Notices
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TodaysTimetableSection(
                timetableAsync: timetableAsync,
                attendanceAsync: attendanceAsync,
                weekdays: weekdays,
                sectionTitle: "Child's schedule today",
              ),
              const SizedBox(height: AppSpacing.lg),
              _DesktopNoticesSection(noticesAsync: noticesAsync),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopNarrowLayout extends StatelessWidget {
  const _DesktopNarrowLayout({
    required this.timetableAsync,
    required this.attendanceAsync,
    required this.noticesAsync,
    required this.weekdays,
  });

  final AsyncValue<Map<String, List<MockPeriod>>> timetableAsync;
  final AsyncValue<List<MockAttendanceDay>> attendanceAsync;
  final AsyncValue<List<MockNotice>> noticesAsync;
  final List<String> weekdays;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DesktopQuickActionsGrid(),
        const SizedBox(height: AppSpacing.lg),
        _DesktopBusCard(),
        const SizedBox(height: AppSpacing.lg),
        _TodaysTimetableSection(
          timetableAsync: timetableAsync,
          attendanceAsync: attendanceAsync,
          weekdays: weekdays,
          sectionTitle: "Child's schedule today",
        ),
        const SizedBox(height: AppSpacing.lg),
        _DesktopNoticesSection(noticesAsync: noticesAsync),
      ],
    );
  }
}

class _DesktopQuickActionsGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = ref.watch(tenantProfileProvider);
    var actions = <(IconData, String, Color, String)>[
      (
        Icons.calendar_month,
        'Attendance',
        AppColors.primary,
        AppRoutes.parentAttendance,
      ),
      (Icons.payments, 'Fees', AppColors.error, AppRoutes.parentFees),
      (Icons.book, 'Diary', AppColors.teal, AppRoutes.parentDiary),
      (Icons.chat, 'Chat', AppColors.accent, AppRoutes.parentChatList),
      (
        Icons.event_busy,
        'Leave',
        AppColors.warning,
        AppRoutes.parentLeaveApply,
      ),
      (Icons.directions_bus, 'Bus', AppColors.warning, AppRoutes.parentBus),
      (Icons.campaign, 'Notices', AppColors.primary, AppRoutes.parentNotices),
      (Icons.restaurant, 'Canteen', AppColors.success, AppRoutes.parentCanteen),
      (Icons.hotel, 'Hostel', AppColors.teal, AppRoutes.hostel),
    ];
    if (tenant.hasFeature(NcFeature.aiInsights)) {
      actions.add((
        Icons.auto_awesome,
        'Namma AI',
        AppColors.accent,
        AppRoutes.nammaAi,
      ));
    }
    return NcCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bolt, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: actions.map((a) {
              return _DesktopQuickActionTile(
                icon: a.$1,
                label: a.$2,
                color: a.$3,
                route: a.$4,
                onPressed: a.$4 == AppRoutes.nammaAi
                    ? () => ref.read(nammaAiPanelProvider.notifier).open()
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DesktopQuickActionTile extends StatelessWidget {
  const _DesktopQuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
    this.onPressed,
  });
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed ?? () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopBusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(AppRoutes.parentBus),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF1B4F72), Color(0xFF117A65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (MockData.busInfo['route'] ?? '—').toString(),
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (MockData.busInfo['busNumber'] ?? '—').toString(),
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${MockData.busInfo['etaMinutes'] ?? '—'} min',
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'ETA',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopNoticesSection extends StatelessWidget {
  const _DesktopNoticesSection({required this.noticesAsync});
  final AsyncValue<List<MockNotice>> noticesAsync;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.campaign,
                      color: AppColors.accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Notices',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.parentNotices),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          noticesAsync.when(
            data: (notices) => Column(
              children: notices
                  .take(3)
                  .map((n) => _NoticePreview(notice: n))
                  .toList(),
            ),
            loading: () => const NcShimmerList(itemCount: 3),
            error: (e, _) =>
                const NcAsyncError(message: 'Unable to load notices'),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(this.icon, this.label, this.color, this.onTap, this.size);
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: size,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoticePreview extends StatelessWidget {
  const _NoticePreview({required this.notice});
  final MockNotice notice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: NcCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            if (!notice.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: AppSpacing.xs),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    style: AppTypography.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppFormatters.timeAgo(notice.date),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            NcChip(label: notice.category, selected: false),
          ],
        ),
      ),
    );
  }
}

// ── Today's Timetable: child's schedule + attendance (Present/Absent) ───────────

class _TodaysTimetableSection extends StatelessWidget {
  const _TodaysTimetableSection({
    required this.timetableAsync,
    required this.attendanceAsync,
    required this.weekdays,
    this.sectionTitle = "Today's schedule",
  });

  final AsyncValue<Map<String, List<MockPeriod>>> timetableAsync;
  final AsyncValue<List<MockAttendanceDay>> attendanceAsync;
  final List<String> weekdays;
  final String sectionTitle;

  @override
  Widget build(BuildContext context) {
    return timetableAsync.when(
      loading: () => const NcShimmerCard(),
      error: (_, __) => const SizedBox.shrink(),
      data: (timetable) {
        final now = DateTime.now();
        final todayName = weekdays[now.weekday];
        final periods = timetable[todayName] ?? [];
        if (periods.isEmpty) {
          return NcCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    "No classes scheduled for $todayName",
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.today_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        todayName,
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  sectionTitle,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            attendanceAsync.when(
              data: (attendanceList) {
                MockAttendanceDay? todayRecord;
                for (final a in attendanceList) {
                  if (a.date.year == now.year &&
                      a.date.month == now.month &&
                      a.date.day == now.day) {
                    todayRecord = a;
                    break;
                  }
                }
                return _TimetablePeriodList(
                  periods: periods,
                  todayRecord: todayRecord,
                  now: now,
                );
              },
              loading: () => _TimetablePeriodList(
                periods: periods,
                todayRecord: null,
                now: now,
              ),
              error: (_, __) => _TimetablePeriodList(
                periods: periods,
                todayRecord: null,
                now: now,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TimetablePeriodList extends StatelessWidget {
  const _TimetablePeriodList({
    required this.periods,
    required this.todayRecord,
    required this.now,
  });

  final List<MockPeriod> periods;
  final MockAttendanceDay? todayRecord;
  final DateTime now;

  bool _isPeriodOver(String endTime) {
    final parts = endTime.split(':');
    if (parts.length < 2) return false;
    final now = this.now;
    final endHour = int.tryParse(parts[0]) ?? 0;
    final endMin = int.tryParse(parts[1]) ?? 0;
    final end = DateTime(now.year, now.month, now.day, endHour, endMin);
    return now.isAfter(end);
  }

  String _periodAttendanceStatus(MockPeriod p) {
    if (todayRecord == null) return 'pending';
    if (todayRecord!.status == 'holiday') return 'holiday';
    if (todayRecord!.status == 'leave') return 'leave';
    if (todayRecord!.status == 'absent') return 'absent';
    if (todayRecord!.status == 'present' &&
        todayRecord!.periods.contains(p.subject)) {
      return 'present';
    }
    return 'absent';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: periods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final p = periods[i];
        final status = _periodAttendanceStatus(p);
        final isOver = _isPeriodOver(p.endTime);
        return _PeriodCard(period: p, attendanceStatus: status, isOver: isOver);
      },
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.period,
    required this.attendanceStatus,
    required this.isOver,
  });

  final MockPeriod period;
  final String attendanceStatus;
  final bool isOver;

  @override
  Widget build(BuildContext context) {
    final color = period.subject.subjectColor;
    Color statusBg;
    Color statusFg;
    String statusText;
    IconData statusIcon;

    switch (attendanceStatus) {
      case 'present':
        statusBg = AppColors.successBg;
        statusFg = AppColors.success;
        statusText = 'Present';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'absent':
        statusBg = AppColors.errorBg;
        statusFg = AppColors.error;
        statusText = 'Absent';
        statusIcon = Icons.cancel_rounded;
        break;
      case 'leave':
        statusBg = AppColors.leaveBg;
        statusFg = AppColors.purple;
        statusText = 'Leave';
        statusIcon = Icons.event_busy_rounded;
        break;
      case 'holiday':
        statusBg = AppColors.warningBg;
        statusFg = AppColors.warning;
        statusText = 'Holiday';
        statusIcon = Icons.celebration_rounded;
        break;
      default:
        statusBg = AppColors.background;
        statusFg = AppColors.textSecondary;
        statusText = 'Pending';
        statusIcon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${period.period}',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      period.subject,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        period.subject.subjectCode,
                        style: AppTypography.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${period.startTime} – ${period.endTime} · ${period.teacher}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: statusFg.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusFg),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: AppTypography.labelSmall.copyWith(
                    color: statusFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isOver) ...[
            const SizedBox(width: 6),
            Text(
              'Over',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
