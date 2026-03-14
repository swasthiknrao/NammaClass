import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../providers/driver_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_avatar.dart';

class DriverStudentsScreen extends ConsumerStatefulWidget {
  const DriverStudentsScreen({super.key});

  @override
  ConsumerState<DriverStudentsScreen> createState() =>
      _DriverStudentsScreenState();
}

class _DriverStudentsScreenState extends ConsumerState<DriverStudentsScreen> {
  String _trip = 'Morning';
  final Map<String, bool> _boarded = {};
  bool _showQrOverlay = false;
  String? _scannedStudentName;

  int _boardedCount(Map<String, List<String>> stopGroups) =>
      _boarded.values.where((v) => v).length;
  int _totalCount(Map<String, List<String>> stopGroups) =>
      stopGroups.values.fold(0, (sum, list) => sum + list.length);

  void _toggleBoarded(String name) {
    setState(() => _boarded[name] = !(_boarded[name] ?? false));
  }

  void _simulateQrScan() {
    setState(() {
      _showQrOverlay = true;
      _scannedStudentName = 'Arjun Kumar';
      _boarded['Arjun Kumar'] = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showQrOverlay = false);
    });
  }

  void _submit(Map<String, List<String>> stopGroups) {
    final bc = _boardedCount(stopGroups);
    final tc = _totalCount(stopGroups);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Boarding Report'),
        content: Text('$bc of $tc students boarded. Submit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Boarding report submitted!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stopGroups = ref.watch(driverStopStudentsProvider);
    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: const Text('Student Boarding'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                TextButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text(
                        'SOS',
                        style: TextStyle(color: AppColors.error),
                      ),
                      content: const Text('Send emergency alert?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Send SOS'),
                        ),
                      ],
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.emergency, size: 18),
                  label: const Text('SOS'),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
      body: Stack(
        children: [
          Column(
            children: [
              // Trip selector + QR scan
              Container(
                color: AppColors.card,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    SegmentedButton<String>(
                      selected: {_trip},
                      onSelectionChanged: (v) =>
                          setState(() => _trip = v.first),
                      segments: const [
                        ButtonSegment(
                          value: 'Morning',
                          label: Text('Morning Trip'),
                        ),
                        ButtonSegment(
                          value: 'Evening',
                          label: Text('Evening Trip'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _simulateQrScan,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan Student QR Card'),
                      ),
                    ),
                  ],
                ),
              ),

              // Student list grouped by stop
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: stopGroups.length,
                  itemBuilder: (_, i) {
                    final stopName = stopGroups.keys.elementAt(i);
                    final students = stopGroups.values.elementAt(i);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: AppColors.background,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xs,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppColors.teal,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  stopName,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.teal,
                                  ),
                                ),
                              ),
                              Text(
                                '${students.length} students',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...students.map(
                          (name) => _StudentBoardingTile(
                            name: name,
                            isBoarded: _boarded[name] ?? false,
                            onToggle: () => _toggleBoarded(name),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          // QR scan overlay
          if (_showQrOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(AppSpacing.xl),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NcAvatar(name: _scannedStudentName ?? '', radius: 40),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _scannedStudentName ?? '',
                          style: AppTypography.headlineMedium,
                        ),
                        Text(
                          'Class 8-A',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Boarded ✓',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Summary footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              color: AppColors.card,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Boarded: ${_boardedCount(stopGroups)} / ${_totalCount(stopGroups)} students',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => _submit(stopGroups),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentBoardingTile extends StatelessWidget {
  const _StudentBoardingTile({
    required this.name,
    required this.isBoarded,
    required this.onToggle,
  });
  final String name;
  final bool isBoarded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      leading: NcAvatar(name: name, radius: 22),
      title: Text(name, style: AppTypography.bodyLarge),
      trailing: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 32,
          decoration: BoxDecoration(
            color: isBoarded ? AppColors.success : AppColors.divider,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: isBoarded
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: isBoarded
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.success,
                        )
                      : const Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.textSecondary,
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
