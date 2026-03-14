import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/launch_utils.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/widgets/nc_bottom_sheet.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/teacher_providers.dart';

class MyStudentsScreen extends ConsumerWidget {
  const MyStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(teacherStudentsProvider);
    final classes = ['8-A', '8-B', '9-A', '9-B', '10-A'];

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: const Text('My Students'),
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.transparent,
            ),
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          _HeroHeader(
            classes: classes,
            showTabs: studentsAsync.valueOrNull != null,
          ),
          studentsAsync.when(
            loading: () => const Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: NcShimmerList(),
              ),
            ),
            error: (e, _) => Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Error: $e',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            data: (students) => Expanded(
              child: DefaultTabController(
                length: classes.length,
                child: Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: _SearchBar(),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: classes.map((cls) {
                          final filtered = students
                              .where((s) => s.classSection == cls)
                              .toList();
                          return _StudentList(
                            students: filtered,
                            emptyMessage:
                                'No students in $cls',
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.classes, this.showTabs = true});
  final List<String> classes;
  final bool showTabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.92),
            AppColors.teal.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'My Students',
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (showTabs) ...[
                const SizedBox(height: AppSpacing.lg),
                TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.8),
                labelStyle: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                dividerColor: Colors.transparent,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                tabs: classes.map((c) => Tab(text: c)).toList(),
              ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: SearchBar(
        hintText: 'Search students…',
        leading: Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
          size: 22,
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        backgroundColor: const WidgetStatePropertyAll(AppColors.card),
        elevation: const WidgetStatePropertyAll(0),
        side: WidgetStatePropertyAll(
          BorderSide(color: AppColors.divider.withValues(alpha: 0.6)),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _StudentList extends StatelessWidget {
  const _StudentList({
    required this.students,
    required this.emptyMessage,
  });
  final List<MockStudent> students;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              emptyMessage,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: students.length,
      itemBuilder: (ctx, i) {
        final s = students[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _StudentCard(student: s),
        );
      },
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});
  final MockStudent student;

  Color _performanceColor(double pct) {
    if (pct >= 0.85) return AppColors.success;
    if (pct >= 0.75) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final pct = student.attendancePercent;
    final percentInt = (pct * 100).round();
    final perfColor = _performanceColor(pct);

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () => _showStudentSheet(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              NcAvatar(name: student.name, radius: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Roll: ${student.rollNo}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Circular progress + percentage badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            value: pct,
                            strokeWidth: 4,
                            backgroundColor: perfColor.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(perfColor),
                          ),
                        ),
                        Icon(
                          pct >= 0.85 ? Icons.trending_up_rounded : Icons.trending_flat_rounded,
                          size: 18,
                          color: perfColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: perfColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: perfColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      '$percentInt%',
                      style: AppTypography.labelLarge.copyWith(
                        color: perfColor,
                        fontWeight: FontWeight.w700,
                      ),
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

  void _showStudentSheet(BuildContext context) {
    final s = student;
    NcBottomSheet.show(
      context,
      title: s.name,
      initialChildSize: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            NcAvatar(name: s.name, radius: 40),
            const SizedBox(height: AppSpacing.md),
            _InfoRow('Class', s.classSection),
            _InfoRow('Roll No', s.rollNo),
            _InfoRow(
              'Attendance',
              '${(s.attendancePercent * 100).round()}%',
            ),
            _InfoRow('Fee Status', s.feeStatus.toUpperCase()),
            if (s.parentName != null) _InfoRow('Parent', s.parentName!),
            if (s.parentPhone != null) ...[
              _InfoRow('Parent Phone', s.parentPhone!),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchTel(
                        context,
                        phone: s.parentPhone!,
                        fallbackSnackBar: 'Cannot launch dialer',
                      ),
                      icon: const Icon(Icons.call, size: 16),
                      label: const Text('Call Parent'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Messaging coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('Message'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(value, style: AppTypography.labelMedium),
        ],
      ),
    );
  }
}
