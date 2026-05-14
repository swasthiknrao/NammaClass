import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/shell_layout_scope.dart';
import '../../providers/admin_providers.dart';

class AdminFacultyDetailScreen extends ConsumerWidget {
  const AdminFacultyDetailScreen({super.key, required this.facultyId});

  final String facultyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(adminStaffProvider);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Team member')),
      backgroundColor: Colors.transparent,
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (staff) {
          final match = staff.where((e) => e.id == facultyId).toList();
          if (match.isEmpty) {
            return const Center(child: Text('Staff member not found'));
          }
          final s = match.first;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name, style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _line('Role', s.role),
                      _line('Department', s.department),
                      if (s.employeeCode != null && s.employeeCode!.isNotEmpty)
                        _line('Employee ID', s.employeeCode!),
                      if (s.campusBlock != null && s.campusBlock!.isNotEmpty)
                        _line('Block / wing', s.campusBlock!),
                      _line('Phone', s.phone),
                      if (s.email != null) _line('Email', s.email!),
                      _line('Status', s.status),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to list'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _line(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(k, style: AppTypography.labelMedium),
          ),
          Expanded(child: Text(v, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}
