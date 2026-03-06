import 'package:flutter/material.dart';

import '../../../shared/widgets/cards/app_stat_card.dart';
import '../../../shared/widgets/feedback/app_skeleton_list.dart';
import '../../../shared/widgets/layout/constrained_content.dart';
import '../../../shared/widgets/layout/responsive_builder.dart';
import '../../../shared/widgets/tables/app_data_table.dart';

class _MockRow {
  _MockRow(this.name, this.role, this.status);
  final String name;
  final String role;
  final String status;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  final List<_MockRow> _rows = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _loading = false;
          _rows.addAll([
            _MockRow('Alice', 'Admin', 'Active'),
            _MockRow('Bob', 'User', 'Active'),
            _MockRow('Carol', 'User', 'Inactive'),
          ]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ConstrainedContent(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: ResponsiveBuilder(
          builder: (context, breakpoint, isMobile, isTablet, isDesktop) {
            final statColumns = isDesktop ? 4 : (isTablet ? 2 : 1);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: statColumns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: const [
                      AppStatCard(
                        label: 'Total users',
                        value: '1,234',
                        icon: Icon(Icons.people_outline),
                      ),
                      AppStatCard(
                        label: 'Active',
                        value: '892',
                        icon: Icon(Icons.check_circle_outline),
                      ),
                      AppStatCard(
                        label: 'Pending',
                        value: '42',
                        icon: Icon(Icons.schedule),
                      ),
                      AppStatCard(
                        label: 'Completed',
                        value: '300',
                        icon: Icon(Icons.done_all),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Recent activity', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (_loading)
                    const AppSkeletonList(itemCount: 3)
                  else
                    AppDataTable<_MockRow>(
                      columns: [
                        AppDataColumn<_MockRow>(
                          label: 'Name',
                          cellBuilder: (r) => Text(r.name),
                        ),
                        AppDataColumn<_MockRow>(
                          label: 'Role',
                          cellBuilder: (r) => Text(r.role),
                        ),
                        AppDataColumn<_MockRow>(
                          label: 'Status',
                          cellBuilder: (r) => Text(r.status),
                        ),
                      ],
                      rows: _rows,
                      emptyMessage: 'No data',
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
