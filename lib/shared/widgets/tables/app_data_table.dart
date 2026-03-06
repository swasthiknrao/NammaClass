import 'package:flutter/material.dart';

import '../layout/responsive_builder.dart';
import '../cards/app_list_tile_card.dart';

/// Column definition for [AppDataTable].
class AppDataColumn<T> {
  const AppDataColumn({
    required this.label,
    required this.cellBuilder,
    this.flex,
  });

  final String label;
  final Widget Function(T item) cellBuilder;
  final int? flex;
}

/// Responsive data table: table on desktop, cards on mobile.
class AppDataTable<T> extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyMessage = 'No data',
  });

  final List<AppDataColumn<T>> columns;
  final List<T> rows;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, breakpoint, isMobile, isTablet, isDesktop) {
        if (rows.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                emptyMessage,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          );
        }
        if (isMobile) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final item = rows[index];
              return AppListTileCard(
                title: columns.first.cellBuilder(item),
                subtitle: columns.length > 1
                    ? columns[1].cellBuilder(item)
                    : null,
              );
            },
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: columns
                .map((c) => DataColumn(label: Text(c.label)))
                .toList(),
            rows: rows
                .map(
                  (item) => DataRow(
                    cells: columns
                        .map((c) => DataCell(c.cellBuilder(item)))
                        .toList(),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
