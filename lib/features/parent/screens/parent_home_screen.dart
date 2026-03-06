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
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../routing/app_routes.dart';
import '../providers/parent_providers.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final child = ref.watch(parentChildProvider);
    final feesAsync = ref.watch(parentFeesProvider);
    final noticesAsync = ref.watch(parentNoticesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),

                // Child selector chip
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.child_care,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        child.name,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        ' • ${child.classSection}',
                        style: AppTypography.bodySmall,
                      ),
                      const Spacer(),
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

                // Fee alert banner
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
                            onPressed: () => context.go(AppRoutes.parentFees),
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

                // Quick actions grid
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Text(
                    'Quick Actions',
                    style: AppTypography.headlineSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    children: [
                      _QuickAction(
                        Icons.calendar_month,
                        'Attendance',
                        AppColors.primary,
                        () => context.go(AppRoutes.parentAttendance),
                      ),
                      _QuickAction(
                        Icons.payments,
                        'Fees',
                        AppColors.error,
                        () => context.go(AppRoutes.parentFees),
                      ),
                      _QuickAction(
                        Icons.book,
                        'Diary',
                        AppColors.teal,
                        () => context.go(AppRoutes.parentDiary),
                      ),
                      _QuickAction(
                        Icons.chat,
                        'Chat',
                        AppColors.accent,
                        () => context.go(AppRoutes.parentChatList),
                      ),
                      _QuickAction(
                        Icons.directions_bus,
                        'Bus',
                        AppColors.warning,
                        () => context.go(AppRoutes.parentBus),
                      ),
                      _QuickAction(
                        Icons.campaign,
                        'Notices',
                        AppColors.primary,
                        () => context.go(AppRoutes.parentNotices),
                      ),
                      _QuickAction(
                        Icons.restaurant,
                        'Canteen',
                        AppColors.success,
                        () => context.go(AppRoutes.parentCanteen),
                      ),
                      _QuickAction(
                        Icons.hotel,
                        'Hostel',
                        AppColors.teal,
                        () => context.go(AppRoutes.hostel),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Bus ETA card
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
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
                                MockData.busInfo['route'] as String,
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                MockData.busInfo['busNumber'] as String,
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
                              '${MockData.busInfo['etaMinutes']} min',
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

                // Today's timetable strip
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Classes",
                        style: AppTypography.headlineSmall,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    itemCount: 5,
                    itemBuilder: (ctx, i) {
                      final periods = MockData.timetable['Monday'] ?? [];
                      if (i >= periods.length) return const SizedBox.shrink();
                      final p = periods[i];
                      return Container(
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
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
                              p.subject,
                              style: AppTypography.labelMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${p.startTime} – ${p.endTime}',
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

                // Notices preview
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Notices',
                        style: AppTypography.headlineSmall,
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.parentNotices),
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
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: NcShimmerList(itemCount: 3),
                  ),
                  error: (e, _) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 100),
              ],
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

class _QuickAction extends StatelessWidget {
  const _QuickAction(this.icon, this.label, this.color, this.onTap);
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
