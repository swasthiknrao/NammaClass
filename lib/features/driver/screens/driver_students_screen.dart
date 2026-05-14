import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/driver_provider.dart';
import '../widgets/driver_portal_bar_actions.dart';
import '../widgets/driver_sos_dialog.dart';

class DriverStudentsScreen extends ConsumerStatefulWidget {
  const DriverStudentsScreen({super.key});

  @override
  ConsumerState<DriverStudentsScreen> createState() =>
      _DriverStudentsScreenState();
}

class _DriverStudentsScreenState extends ConsumerState<DriverStudentsScreen> {
  String _trip = 'Morning';

  /// Pickup: boarded; Drop-off: safely dropped.
  String _mode = 'pickup';
  final Map<String, bool> _boarded = {};
  bool _showQrOverlay = false;
  String? _scannedStudentName;

  int _doneCount(Map<String, List<String>> roster) =>
      _boarded.values.where((v) => v).length;

  int _totalExpected(Map<String, List<String>> roster) =>
      roster.values.fold(0, (sum, list) => sum + list.length);

  void _toggle(String name) {
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

  void _openQrStubNote(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.driverQrCameraStubTitle, style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.driverQrCameraStubNote,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _simulateQrScan();
              },
              child: Text(l10n.driverQrSimulateScan),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(Map<String, List<String>> roster) {
    final l10n = AppLocalizations.of(context);
    final bc = _doneCount(roster);
    final tc = _totalExpected(roster);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.driverSubmitBoardingTitle),
        content: Text(l10n.driverSubmitBoardingBody(bc, tc)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final bus = MockData.busInfo;
              MockData.appendDriverTripHistory({
                'id': 'trip-${DateTime.now().millisecondsSinceEpoch}',
                'date': DateTime.now().toIso8601String(),
                'shift': '$_trip ($_mode)',
                'route': '${bus['route'] ?? '—'}',
                'boarded': bc,
                'total': tc,
                'status': l10n.driverTripHistorySubmitted,
              });
              ref.read(dataSyncProvider.notifier).bump();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.driverBoardingReportSubmitted),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(l10n.submit),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roster = ref.watch(driverExpectedRosterProvider);
    final absent = ref.watch(driverAbsentStudentsProvider);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: Text(l10n.driverStudentsBoardingTitle),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                const DriverPortalBarActions(),
                TextButton.icon(
                  onPressed: () => showDriverSosDialog(context, ref),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.emergency, size: 18),
                  label: Text(l10n.driverSosShort),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: AppColors.card,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (absent.isNotEmpty) ...[
                      Text(
                        l10n.driverAbsentSection,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: absent
                            .map(
                              (n) => Chip(
                                label: Text(
                                  n,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    SegmentedButton<String>(
                      selected: {_trip},
                      onSelectionChanged: (v) =>
                          setState(() => _trip = v.first),
                      segments: [
                        ButtonSegment(
                          value: 'Morning',
                          label: Text(l10n.driverMorningTrip),
                        ),
                        ButtonSegment(
                          value: 'Evening',
                          label: Text(l10n.driverEveningTrip),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<String>(
                      selected: {_mode},
                      onSelectionChanged: (v) =>
                          setState(() => _mode = v.first),
                      segments: [
                        ButtonSegment(
                          value: 'pickup',
                          label: Text(l10n.driverPickup),
                        ),
                        ButtonSegment(
                          value: 'dropoff',
                          label: Text(l10n.driverDropoff),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openQrStubNote(context),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text(l10n.driverScanStudentQr),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: roster.length,
                  itemBuilder: (_, i) {
                    final stopName = roster.keys.elementAt(i);
                    final students = roster.values.elementAt(i);
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
                                l10n.driverStopStudentCount(students.length),
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
                            actionLabel: _mode == 'pickup'
                                ? l10n.driverBoardedLabel
                                : l10n.driverDroppedLabel,
                            onToggle: () => _toggle(name),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
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
                        Text(
                          _mode == 'pickup'
                              ? l10n.driverBoardedOk
                              : l10n.driverDroppedOk,
                          style: const TextStyle(
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
                      l10n.driverBoardingFooter(
                        _doneCount(roster),
                        _totalExpected(roster),
                      ),
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => _submit(roster),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: Text(l10n.submit),
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
    required this.actionLabel,
    required this.onToggle,
  });
  final String name;
  final bool isBoarded;
  final String actionLabel;
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
      subtitle: Text(
        actionLabel,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
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
