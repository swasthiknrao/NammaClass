import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_animations.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../routing/app_routes.dart';
import '../providers/admin_providers.dart';

enum StudentSortOption { nameAsc, nameDesc, classThenRoll, rollNo, feeStatus }

enum StaffSortOption { nameAsc, nameDesc, department, role, status }

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _studentSearchController = TextEditingController();
  final _staffSearchController = TextEditingController();

  String? _selectedClassSection;
  String? _selectedFeeStatus;
  StudentSortOption _studentSort = StudentSortOption.classThenRoll;

  String? _selectedDepartment;
  String? _selectedRole;
  String? _selectedStaffStatus;
  StaffSortOption _staffSort = StaffSortOption.nameAsc;

  bool _showStudentFilters = false;
  bool _showStaffFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _studentSearchController.addListener(() => setState(() {}));
    _staffSearchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentSearchController.dispose();
    _staffSearchController.dispose();
    super.dispose();
  }

  List<MockStudent> _filterAndSortStudents(List<MockStudent> students) {
    var list = List<MockStudent>.from(students);

    // Search
    final q = _studentSearchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (s) =>
                s.name.toLowerCase().contains(q) ||
                s.classSection.toLowerCase().contains(q) ||
                s.rollNo.contains(q) ||
                (s.parentName?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    // Filters
    if (_selectedClassSection != null) {
      list = list
          .where((s) => s.classSection == _selectedClassSection)
          .toList();
    }
    if (_selectedFeeStatus != null) {
      list = list.where((s) => s.feeStatus == _selectedFeeStatus).toList();
    }

    // Sort
    switch (_studentSort) {
      case StudentSortOption.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case StudentSortOption.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case StudentSortOption.classThenRoll:
        list.sort((a, b) {
          final c = a.classSection.compareTo(b.classSection);
          return c != 0
              ? c
              : int.tryParse(
                      a.rollNo,
                    )?.compareTo(int.tryParse(b.rollNo) ?? 0) ??
                    a.rollNo.compareTo(b.rollNo);
        });
        break;
      case StudentSortOption.rollNo:
        list.sort(
          (a, b) =>
              int.tryParse(a.rollNo)?.compareTo(int.tryParse(b.rollNo) ?? 0) ??
              a.rollNo.compareTo(b.rollNo),
        );
        break;
      case StudentSortOption.feeStatus:
        list.sort((a, b) => a.feeStatus.compareTo(b.feeStatus));
        break;
    }
    return list;
  }

  List<MockStaffMember> _filterAndSortStaff(List<MockStaffMember> staff) {
    var list = List<MockStaffMember>.from(staff);

    // Search
    final q = _staffSearchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (s) =>
                s.name.toLowerCase().contains(q) ||
                s.role.toLowerCase().contains(q) ||
                s.department.toLowerCase().contains(q) ||
                (s.email?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    // Filters
    if (_selectedDepartment != null) {
      list = list.where((s) => s.department == _selectedDepartment).toList();
    }
    if (_selectedRole != null) {
      list = list.where((s) => s.role == _selectedRole).toList();
    }
    if (_selectedStaffStatus != null) {
      list = list.where((s) => s.status == _selectedStaffStatus).toList();
    }

    // Sort
    switch (_staffSort) {
      case StaffSortOption.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case StaffSortOption.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case StaffSortOption.department:
        list.sort((a, b) => a.department.compareTo(b.department));
        break;
      case StaffSortOption.role:
        list.sort((a, b) => a.role.compareTo(b.role));
        break;
      case StaffSortOption.status:
        list.sort((a, b) => a.status.compareTo(b.status));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(adminStudentsProvider);
    final staffAsync = ref.watch(adminStaffProvider);
    final isDesktop = ScreenSize.isDesktop(context);
    final isTablet = ScreenSize.isTablet(context);
    final isWide = isDesktop || isTablet;

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: const Text('People'),
              bottom: isWide
                  ? null
                  : PreferredSize(
                      preferredSize: const Size.fromHeight(56),
                      child: Container(
                        color: AppColors.primary,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorPadding: const EdgeInsets.all(4),
                            dividerColor: Colors.transparent,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: AppColors.accent,
                            labelStyle: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              shadows: [
                                Shadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 0,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            unselectedLabelStyle: AppTypography.labelLarge
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                  letterSpacing: 0.5,
                                ),
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.school_rounded, size: 22),
                                text: 'Students',
                              ),
                              Tab(
                                icon: Icon(Icons.badge_rounded, size: 22),
                                text: 'Staff',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  tooltip: 'Add Person',
                  onPressed: () => context.push(AppRoutes.adminAddStaff),
                ),
              ],
            ),
      backgroundColor: Colors.transparent,
      body: isWide
          ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _StudentsTab(
                    studentsAsync: studentsAsync,
                    searchController: _studentSearchController,
                    selectedClassSection: _selectedClassSection,
                    selectedFeeStatus: _selectedFeeStatus,
                    studentSort: _studentSort,
                    showFilters: _showStudentFilters,
                    onToggleFilters: () => setState(
                      () => _showStudentFilters = !_showStudentFilters,
                    ),
                    onClassSectionChanged: (v) =>
                        setState(() => _selectedClassSection = v),
                    onFeeStatusChanged: (v) =>
                        setState(() => _selectedFeeStatus = v),
                    onSortChanged: (v) => setState(() => _studentSort = v),
                    filterAndSort: _filterAndSortStudents,
                    isWide: true,
                  ),
                ),
                Container(width: 1, color: AppColors.divider),
                Expanded(
                  flex: 1,
                  child: _StaffTab(
                    staffAsync: staffAsync,
                    searchController: _staffSearchController,
                    selectedDepartment: _selectedDepartment,
                    selectedRole: _selectedRole,
                    selectedStatus: _selectedStaffStatus,
                    staffSort: _staffSort,
                    showFilters: _showStaffFilters,
                    onToggleFilters: () =>
                        setState(() => _showStaffFilters = !_showStaffFilters),
                    onDepartmentChanged: (v) =>
                        setState(() => _selectedDepartment = v),
                    onRoleChanged: (v) => setState(() => _selectedRole = v),
                    onStatusChanged: (v) =>
                        setState(() => _selectedStaffStatus = v),
                    onSortChanged: (v) => setState(() => _staffSort = v),
                    filterAndSort: _filterAndSortStaff,
                    isWide: true,
                  ),
                ),
              ],
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _StudentsTab(
                  studentsAsync: studentsAsync,
                  searchController: _studentSearchController,
                  selectedClassSection: _selectedClassSection,
                  selectedFeeStatus: _selectedFeeStatus,
                  studentSort: _studentSort,
                  showFilters: _showStudentFilters,
                  onToggleFilters: () => setState(
                    () => _showStudentFilters = !_showStudentFilters,
                  ),
                  onClassSectionChanged: (v) =>
                      setState(() => _selectedClassSection = v),
                  onFeeStatusChanged: (v) =>
                      setState(() => _selectedFeeStatus = v),
                  onSortChanged: (v) => setState(() => _studentSort = v),
                  filterAndSort: _filterAndSortStudents,
                  isWide: false,
                ),
                _StaffTab(
                  staffAsync: staffAsync,
                  searchController: _staffSearchController,
                  selectedDepartment: _selectedDepartment,
                  selectedRole: _selectedRole,
                  selectedStatus: _selectedStaffStatus,
                  staffSort: _staffSort,
                  showFilters: _showStaffFilters,
                  onToggleFilters: () =>
                      setState(() => _showStaffFilters = !_showStaffFilters),
                  onDepartmentChanged: (v) =>
                      setState(() => _selectedDepartment = v),
                  onRoleChanged: (v) => setState(() => _selectedRole = v),
                  onStatusChanged: (v) =>
                      setState(() => _selectedStaffStatus = v),
                  onSortChanged: (v) => setState(() => _staffSort = v),
                  filterAndSort: _filterAndSortStaff,
                  isWide: false,
                ),
              ],
            ),
    );
  }
}

class _StudentsTab extends StatelessWidget {
  const _StudentsTab({
    required this.studentsAsync,
    required this.searchController,
    required this.selectedClassSection,
    required this.selectedFeeStatus,
    required this.studentSort,
    required this.showFilters,
    required this.onToggleFilters,
    required this.onClassSectionChanged,
    required this.onFeeStatusChanged,
    required this.onSortChanged,
    required this.filterAndSort,
    this.isWide = false,
  });

  final AsyncValue<List<MockStudent>> studentsAsync;
  final bool isWide;
  final TextEditingController searchController;
  final String? selectedClassSection;
  final String? selectedFeeStatus;
  final StudentSortOption studentSort;
  final bool showFilters;
  final VoidCallback onToggleFilters;
  final ValueChanged<String?> onClassSectionChanged;
  final ValueChanged<String?> onFeeStatusChanged;
  final ValueChanged<StudentSortOption> onSortChanged;
  final List<MockStudent> Function(List<MockStudent>) filterAndSort;

  @override
  Widget build(BuildContext context) {
    return studentsAsync.when(
      loading: () =>
          const Padding(padding: EdgeInsets.all(16), child: NcShimmerList()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (students) {
        final classSections =
            students.map((s) => s.classSection).toSet().toList()..sort();
        final feeStatuses = students.map((s) => s.feeStatus).toSet().toList()
          ..sort();

        final filtered = filterAndSort(students);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SearchBar(
                          controller: searchController,
                          hintText: 'Search by name, class, roll…',
                          leading: const Icon(Icons.search),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 16),
                          ),
                          backgroundColor: const WidgetStatePropertyAll(
                            AppColors.card,
                          ),
                          elevation: const WidgetStatePropertyAll(0),
                          side: const WidgetStatePropertyAll(
                            BorderSide(color: AppColors.divider),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      IconButton.filledTonal(
                        onPressed: onToggleFilters,
                        icon: Icon(
                          showFilters
                              ? Icons.filter_alt
                              : Icons.filter_alt_outlined,
                          color: showFilters
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        tooltip: showFilters ? 'Hide filters' : 'Show filters',
                      ),
                      PopupMenuButton<StudentSortOption>(
                        tooltip: 'Sort',
                        icon: const Icon(Icons.sort),
                        onSelected: onSortChanged,
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: StudentSortOption.classThenRoll,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.class_),
                              title: Text('Class & Roll'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: StudentSortOption.nameAsc,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.arrow_upward),
                              title: Text('Name A–Z'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: StudentSortOption.nameDesc,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.arrow_downward),
                              title: Text('Name Z–A'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: StudentSortOption.rollNo,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.numbers),
                              title: Text('Roll No'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: StudentSortOption.feeStatus,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.account_balance_wallet),
                              title: Text('Fee Status'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (showFilters) ...[
                    const SizedBox(height: AppSpacing.sm),
                    if (selectedClassSection != null ||
                        selectedFeeStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: TextButton.icon(
                          onPressed: () {
                            onClassSectionChanged(null);
                            onFeeStatusChanged(null);
                          },
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Clear filters'),
                        ),
                      ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Class',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: selectedClassSection == null,
                                onSelected: (_) => onClassSectionChanged(null),
                              ),
                              ...classSections.map(
                                (c) => FilterChip(
                                  label: Text(c),
                                  selected: selectedClassSection == c,
                                  onSelected: (_) => onClassSectionChanged(c),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Fee Status',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: selectedClassSection == null,
                                onSelected: (_) => onClassSectionChanged(null),
                              ),
                              ...feeStatuses.map(
                                (f) => FilterChip(
                                  label: Text(f),
                                  selected: selectedFeeStatus == f,
                                  onSelected: (_) => onFeeStatusChanged(f),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (selectedClassSection != null ||
                        selectedFeeStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: TextButton.icon(
                          onPressed: () {
                            onClassSectionChanged(null);
                            onFeeStatusChanged(null);
                          },
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear filters'),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                '${filtered.length} student${filtered.length == 1 ? '' : 's'}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No students match your filters',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Try adjusting search or filters',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    )
                  : isWide
                  ? LayoutBuilder(
                      builder: (ctx, constraints) {
                        final crossCount = constraints.maxWidth > 800
                            ? 4
                            : constraints.maxWidth > 500
                            ? 3
                            : 2;
                        return GridView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossCount,
                                mainAxisSpacing: AppSpacing.sm,
                                crossAxisSpacing: AppSpacing.sm,
                                childAspectRatio: 1.1,
                              ),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final s = filtered[i];
                            return _StudentCard(student: s)
                                .animate()
                                .fadeIn(
                                  duration: 260.ms,
                                  delay: AppAnimations.staggerDelay(i % 12),
                                )
                                .slideY(
                                  begin: 0.03,
                                  end: 0,
                                  curve: Curves.easeOut,
                                );
                          },
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      itemBuilder: (ctx, i) {
                        final s = filtered[i];
                        return _StudentTile(student: s, index: i);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});

  final MockStudent student;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NcAvatar(name: student.name, radius: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            student.name,
            style: AppTypography.labelLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${student.classSection} • ${student.rollNo}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          NcChip(
            label: student.feeStatus,
            selected: student.feeStatus == 'paid',
            color: student.feeStatus == 'paid'
                ? AppColors.success
                : student.feeStatus == 'overdue'
                ? AppColors.error
                : AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student, required this.index});

  final MockStudent student;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: ListTile(
            tileColor: index % 2 == 0 ? AppColors.card : AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            leading: NcAvatar(name: student.name, radius: 20),
            title: Text(student.name, style: AppTypography.labelMedium),
            subtitle: Text(
              '${student.classSection} • Roll: ${student.rollNo}',
              style: AppTypography.bodySmall,
            ),
            trailing: NcChip(
              label: student.feeStatus,
              selected: student.feeStatus == 'paid',
              color: student.feeStatus == 'paid'
                  ? AppColors.success
                  : student.feeStatus == 'overdue'
                  ? AppColors.error
                  : AppColors.warning,
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 260.ms, delay: AppAnimations.staggerDelay(index % 12))
        .slideY(begin: 0.03, end: 0, curve: Curves.easeOut);
  }
}

class _StaffTab extends StatelessWidget {
  const _StaffTab({
    required this.staffAsync,
    required this.searchController,
    required this.selectedDepartment,
    required this.selectedRole,
    required this.selectedStatus,
    required this.staffSort,
    required this.showFilters,
    required this.onToggleFilters,
    required this.onDepartmentChanged,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
    required this.filterAndSort,
    this.isWide = false,
  });

  final AsyncValue<List<MockStaffMember>> staffAsync;
  final bool isWide;
  final TextEditingController searchController;
  final String? selectedDepartment;
  final String? selectedRole;
  final String? selectedStatus;
  final StaffSortOption staffSort;
  final bool showFilters;
  final VoidCallback onToggleFilters;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<StaffSortOption> onSortChanged;
  final List<MockStaffMember> Function(List<MockStaffMember>) filterAndSort;

  @override
  Widget build(BuildContext context) {
    return staffAsync.when(
      loading: () =>
          const Padding(padding: EdgeInsets.all(16), child: NcShimmerList()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (staff) {
        final departments = staff.map((s) => s.department).toSet().toList()
          ..sort();
        final roles = staff.map((s) => s.role).toSet().toList()..sort();
        final statuses = staff.map((s) => s.status).toSet().toList()..sort();

        final filtered = filterAndSort(staff);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SearchBar(
                          controller: searchController,
                          hintText: 'Search by name, role, department…',
                          leading: const Icon(Icons.search),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 16),
                          ),
                          backgroundColor: const WidgetStatePropertyAll(
                            AppColors.card,
                          ),
                          elevation: const WidgetStatePropertyAll(0),
                          side: const WidgetStatePropertyAll(
                            BorderSide(color: AppColors.divider),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      IconButton.filledTonal(
                        onPressed: onToggleFilters,
                        icon: Icon(
                          showFilters
                              ? Icons.filter_alt
                              : Icons.filter_alt_outlined,
                          color: showFilters
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        tooltip: showFilters ? 'Hide filters' : 'Show filters',
                      ),
                      PopupMenuButton<StaffSortOption>(
                        tooltip: 'Sort',
                        icon: const Icon(Icons.sort),
                        onSelected: onSortChanged,
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: StaffSortOption.nameAsc,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.arrow_upward),
                              title: Text('Name A–Z'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: StaffSortOption.nameDesc,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.arrow_downward),
                              title: Text('Name Z–A'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: StaffSortOption.department,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.business),
                              title: Text('Department'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: StaffSortOption.role,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.badge),
                              title: Text('Role'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: StaffSortOption.status,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.check_circle),
                              title: Text('Status'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (showFilters) ...[
                    const SizedBox(height: AppSpacing.sm),
                    if (selectedDepartment != null ||
                        selectedRole != null ||
                        selectedStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: TextButton.icon(
                          onPressed: () {
                            onDepartmentChanged(null);
                            onRoleChanged(null);
                            onStatusChanged(null);
                          },
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Clear filters'),
                        ),
                      ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Department',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: selectedDepartment == null,
                                onSelected: (_) => onDepartmentChanged(null),
                              ),
                              ...departments.map(
                                (d) => FilterChip(
                                  label: Text(d),
                                  selected: selectedDepartment == d,
                                  onSelected: (_) => onDepartmentChanged(d),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Role',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: selectedRole == null,
                                onSelected: (_) => onRoleChanged(null),
                              ),
                              ...roles.map(
                                (r) => FilterChip(
                                  label: Text(r),
                                  selected: selectedRole == r,
                                  onSelected: (_) => onRoleChanged(r),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Status',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: selectedStatus == null,
                                onSelected: (_) => onStatusChanged(null),
                              ),
                              ...statuses.map(
                                (s) => FilterChip(
                                  label: Text(s),
                                  selected: selectedStatus == s,
                                  onSelected: (_) => onStatusChanged(s),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (selectedDepartment != null ||
                        selectedRole != null ||
                        selectedStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: TextButton.icon(
                          onPressed: () {
                            onDepartmentChanged(null);
                            onRoleChanged(null);
                            onStatusChanged(null);
                          },
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear filters'),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                '${filtered.length} staff member${filtered.length == 1 ? '' : 's'}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 64,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No staff match your filters',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Try adjusting search or filters',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    )
                  : isWide
                  ? LayoutBuilder(
                      builder: (ctx, constraints) {
                        final crossCount = constraints.maxWidth > 800
                            ? 4
                            : constraints.maxWidth > 500
                            ? 3
                            : 2;
                        return GridView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossCount,
                                mainAxisSpacing: AppSpacing.sm,
                                crossAxisSpacing: AppSpacing.sm,
                                childAspectRatio: 1.1,
                              ),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final s = filtered[i];
                            return _StaffCard(staff: s)
                                .animate()
                                .fadeIn(
                                  duration: 260.ms,
                                  delay: AppAnimations.staggerDelay(i % 12),
                                )
                                .slideY(
                                  begin: 0.03,
                                  end: 0,
                                  curve: Curves.easeOut,
                                );
                          },
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      itemBuilder: (ctx, i) {
                        final s = filtered[i];
                        return _StaffTile(staff: s, index: i);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.staff});

  final MockStaffMember staff;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NcAvatar(name: staff.name, radius: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            staff.name,
            style: AppTypography.labelLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${staff.role} • ${staff.department}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          NcChip(
            label: staff.status,
            selected: staff.status == 'active',
            color: staff.status == 'active'
                ? AppColors.success
                : AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({required this.staff, required this.index});

  final MockStaffMember staff;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: ListTile(
            tileColor: index % 2 == 0 ? AppColors.card : AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            leading: NcAvatar(name: staff.name, radius: 20),
            title: Text(staff.name, style: AppTypography.labelMedium),
            subtitle: Text(
              '${staff.role} • ${staff.department}',
              style: AppTypography.bodySmall,
            ),
            trailing: NcChip(
              label: staff.status,
              selected: staff.status == 'active',
              color: staff.status == 'active'
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 260.ms, delay: AppAnimations.staggerDelay(index % 12))
        .slideY(begin: 0.03, end: 0, curve: Curves.easeOut);
  }
}
