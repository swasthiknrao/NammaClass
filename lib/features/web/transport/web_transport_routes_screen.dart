import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';

class WebTransportRoutesScreen extends ConsumerStatefulWidget {
  const WebTransportRoutesScreen({super.key});

  @override
  ConsumerState<WebTransportRoutesScreen> createState() =>
      _WebTransportRoutesScreenState();
}

class _WebTransportRoutesScreenState
    extends ConsumerState<WebTransportRoutesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  final _routes = [
    ('Route 3 — Jayanagar', 6, 34, 'KA-01-MH-2345', 'Venkat Reddy'),
    ('Route 7 — Koramangala', 8, 42, 'KA-01-MB-6789', 'Raju Sharma'),
    ('Route 12 — Whitefield', 10, 38, 'KA-01-MC-3456', 'Mohan Das'),
  ];

  final _vehicles = [
    (
      'KA-01-MH-2345',
      'Mini Bus',
      45,
      'Route 3',
      '2027-05-14',
      '2026-09-01',
      'Active',
    ),
    (
      'KA-01-MB-6789',
      'Mini Bus',
      45,
      'Route 7',
      '2026-08-22',
      '2026-11-15',
      'Active',
    ),
    (
      'KA-01-MC-3456',
      'Mini Bus',
      42,
      'Route 12',
      '2025-12-01',
      '2026-07-30',
      'Active',
    ),
  ];

  final _drivers = [
    (
      'Venkat Reddy',
      '9900112233',
      'KA-DL-2345-2025',
      '2028-07-14',
      'KA-01-MH-2345',
      'Active',
    ),
    (
      'Raju Sharma',
      '9900223344',
      'KA-DL-6789-2023',
      '2026-05-20',
      'KA-01-MB-6789',
      'Expiring Soon',
    ),
    (
      'Mohan Das',
      '9900334455',
      'KA-DL-3456-2024',
      '2027-11-11',
      'KA-01-MC-3456',
      'Active',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transport — Routes & Fleet',
                style: AppTypography.headlineMedium,
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add Route'),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Routes'),
            Tab(text: 'Vehicles'),
            Tab(text: 'Drivers'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _RoutesTable(_routes),
              _VehiclesTable(_vehicles),
              _DriversTable(_drivers),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoutesTable extends StatelessWidget {
  const _RoutesTable(this.routes);
  final List<(String, int, int, String, String)> routes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: NcCard(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              color: AppColors.background,
              child: Row(
                children: const [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Route',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Stops',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Students',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Vehicle',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Driver',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Actions',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            ...routes.map(
              (r) => Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(r.$1, style: AppTypography.labelMedium),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('${r.$2}', style: AppTypography.bodyMedium),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('${r.$3}', style: AppTypography.bodyMedium),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        r.$4,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(r.$5, style: AppTypography.bodySmall),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.map_outlined, size: 18),
                            onPressed: () {},
                            tooltip: 'View Route',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () {},
                            tooltip: 'Edit',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehiclesTable extends StatelessWidget {
  const _VehiclesTable(this.vehicles);
  final List<(String, String, int, String, String, String, String)> vehicles;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: NcCard(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              color: AppColors.background,
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Vehicle No',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Type',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Capacity',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Insurance Expiry',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'PUC Expiry',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            ...vehicles.map((v) {
              final insExpiring = v.$5.contains('2026');
              return Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        v.$1,
                        style: AppTypography.labelMedium.copyWith(
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ),
                    Expanded(flex: 2, child: Text(v.$2)),
                    Expanded(flex: 2, child: Text('${v.$3} seats')),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Text(v.$5),
                          if (insExpiring) const SizedBox(width: 4),
                          if (insExpiring)
                            const Icon(
                              Icons.warning_amber,
                              color: AppColors.warning,
                              size: 16,
                            ),
                        ],
                      ),
                    ),
                    Expanded(flex: 3, child: Text(v.$6)),
                    Expanded(
                      flex: 2,
                      child: NcChip(label: v.$7, color: AppColors.success),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DriversTable extends StatelessWidget {
  const _DriversTable(this.drivers);
  final List<(String, String, String, String, String, String)> drivers;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: NcCard(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              color: AppColors.background,
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Driver',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Phone',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Licence No',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Expiry',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Vehicle',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            ...drivers.map(
              (d) => Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(d.$1, style: AppTypography.labelMedium),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(d.$2, style: AppTypography.bodySmall),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        d.$3,
                        style: AppTypography.bodySmall.copyWith(
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ),
                    Expanded(flex: 2, child: Text(d.$4)),
                    Expanded(
                      flex: 3,
                      child: Text(
                        d.$5,
                        style: AppTypography.bodySmall.copyWith(
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: NcChip(
                        label: d.$6,
                        color: d.$6 == 'Active'
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
