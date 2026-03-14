import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../providers/parent_providers.dart';

class ParentDiaryScreen extends ConsumerWidget {
  const ParentDiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryAsync = ref.watch(parentDiaryProvider);
    final isWide =
        ScreenSize.isDesktop(context) || ScreenSize.isTablet(context);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Daily Diary & Homework')),
      backgroundColor: Colors.transparent,
      body: diaryAsync.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(16), child: NcShimmerList()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) {
          final child = ref.watch(parentChildProvider);
          return isWide
              ? _DesktopDiaryLayout(child: child, entries: entries)
              : _MobileDiaryLayout(entries: entries);
        },
      ),
    );
  }
}

// ── Desktop layout ───────────────────────────────────────────────────────────

class _DesktopDiaryLayout extends StatelessWidget {
  const _DesktopDiaryLayout({required this.child, required this.entries});
  final MockStudent child;
  final List<MockDiaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final dates = <DateTime>[];
    for (var d = 6; d >= 0; d--) {
      dates.add(DateTime.now().subtract(Duration(days: d)));
    }
    final todayEntries = entries.where((e) => e.date.isToday).length;
    final completedCount = entries.where((e) => e.completed).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero + stats row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _DiaryHeroBanner(child: child)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: _DiaryStatCard(
                        icon: Icons.today_rounded,
                        value: todayEntries.toString(),
                        label: 'Today',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _DiaryStatCard(
                        icon: Icons.check_circle_rounded,
                        value: completedCount.toString(),
                        label: 'Completed',
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Date strip — creative chips
          _CreativeDateStrip(dates: dates),
          const SizedBox(height: AppSpacing.lg),
          // Entries grid
          _DiaryEntriesGrid(entries: entries),
        ],
      ),
    );
  }
}

class _DiaryHeroBanner extends StatelessWidget {
  const _DiaryHeroBanner({required this.child});
  final MockStudent child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
            AppColors.teal,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Daily Diary & Homework',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${child.name} • ${child.classSection}',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
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

class _DiaryStatCard extends StatelessWidget {
  const _DiaryStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTypography.headlineMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
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

class _CreativeDateStrip extends StatelessWidget {
  const _CreativeDateStrip({required this.dates});
  final List<DateTime> dates;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: dates.map((d) {
          final isSelected = d.isToday;
          final dayName = _dayName(d.weekday);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, AppColors.teal],
                            )
                          : null,
                      color: isSelected ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.divider.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dayName,
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppFormatters.formatShortDate(d),
                          style: AppTypography.labelMedium.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _dayName(int weekday) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return names[weekday - 1];
  }
}

class _DiaryEntriesGrid extends StatelessWidget {
  const _DiaryEntriesGrid({required this.entries});
  final List<MockDiaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries.map((e) {
        final subjectColor = e.subject.subjectColor;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _DesktopDiaryCard(entry: e, subjectColor: subjectColor),
        );
      }).toList(),
    );
  }
}

class _DesktopDiaryCard extends StatelessWidget {
  const _DesktopDiaryCard({required this.entry, required this.subjectColor});
  final MockDiaryEntry entry;
  final Color subjectColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: subjectColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: subjectColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          leading: Container(
            width: 5,
            height: 48,
            decoration: BoxDecoration(
              color: subjectColor,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: subjectColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          title: Text(
            entry.subject,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            AppFormatters.formatDate(entry.date),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entry.hasAttachment)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.attach_file_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              if (entry.hasAttachment) const SizedBox(width: 8),
              if (entry.completed)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: AppColors.divider.withValues(alpha: 0.5)),
                  _DiarySection(
                    'Classwork',
                    entry.classwork,
                    Icons.menu_book_rounded,
                    subjectColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DiarySection(
                    'Homework',
                    entry.homework,
                    Icons.assignment_rounded,
                    subjectColor,
                  ),
                  if (entry.dueDate != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_rounded,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Due: ${AppFormatters.formatDate(entry.dueDate!)}',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mobile layout ───────────────────────────────────────────────────────────

class _MobileDiaryLayout extends StatelessWidget {
  const _MobileDiaryLayout({required this.entries});
  final List<MockDiaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final dates = <DateTime>[];
    for (var d = 6; d >= 0; d--) {
      dates.add(DateTime.now().subtract(Duration(days: d)));
    }

    return Column(
      children: [
        // Date strip
        Container(
          height: 70,
          color: AppColors.card,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            itemCount: dates.length,
            itemBuilder: (ctx, i) {
              final d = dates[i];
              final isSelected = d.isToday;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.primary, AppColors.teal],
                              )
                            : null,
                        color: isSelected ? null : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.divider,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppFormatters.formatShortDate(d),
                            style: AppTypography.labelMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: entries.length,
            itemBuilder: (ctx, i) {
              final e = entries[i];
              final subjectColor = e.subject.subjectColor;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: NcCard(
                  padding: EdgeInsets.zero,
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: subjectColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      title: Text(e.subject, style: AppTypography.labelLarge),
                      subtitle: Text(
                        AppFormatters.formatDate(e.date),
                        style: AppTypography.bodySmall,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (e.hasAttachment)
                            const Icon(
                              Icons.attach_file,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          if (e.completed)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 16,
                            ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              _DiarySection(
                                'Classwork',
                                e.classwork,
                                Icons.menu_book,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _DiarySection(
                                'Homework',
                                e.homework,
                                Icons.assignment,
                              ),
                              if (e.dueDate != null) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.event,
                                      size: 14,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Due: ${AppFormatters.formatDate(e.dueDate!)}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DiarySection extends StatelessWidget {
  const _DiarySection(this.title, this.content, this.icon, [this.accentColor]);
  final String title;
  final String content;
  final IconData icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final iconColor = accentColor ?? AppColors.textSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(content, style: AppTypography.bodyMedium),
      ],
    );
  }
}
