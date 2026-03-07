import 'package:flutter/material.dart';

import '../../../core/services/audit_log.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_empty_state.dart';

/// Dev/admin-only screen to view recent security audit events.
/// Shows login, logout, and other sensitive actions (no tokens or PII).
class WebSecurityLogScreen extends StatefulWidget {
  const WebSecurityLogScreen({super.key});

  @override
  State<WebSecurityLogScreen> createState() => _WebSecurityLogScreenState();
}

class _WebSecurityLogScreenState extends State<WebSecurityLogScreen> {
  @override
  Widget build(BuildContext context) {
    final events = AuditLog.instance.events.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Log'),
        actions: [
          if (events.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                AuditLog.instance.clear();
                setState(() {});
              },
              tooltip: 'Clear log',
            ),
        ],
      ),
      body: events.isEmpty
          ? const NcEmptyState(
              title: 'No Events',
              body: 'Security events (login, logout) will appear here.',
              illustration: NcIllustration.general,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: events.length,
              itemBuilder: (context, i) {
                final e = events[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _actionColor(
                        e.action,
                      ).withValues(alpha: 0.2),
                      child: Icon(
                        _actionIcon(e.action),
                        color: _actionColor(e.action),
                        size: 20,
                      ),
                    ),
                    title: Text(e.action, style: AppTypography.labelLarge),
                    subtitle: Text(
                      '${e.timestamp.toIso8601String()}${e.role != null ? ' · ${e.role}' : ''}${e.userId != null ? ' · ${e.userId}' : ''}${e.details != null ? '\n${e.details}' : ''}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _actionColor(String action) {
    if (action.contains('login')) return AppColors.success;
    if (action.contains('logout')) return AppColors.textSecondary;
    return AppColors.primary;
  }

  IconData _actionIcon(String action) {
    if (action.contains('login')) return Icons.login;
    if (action.contains('logout')) return Icons.logout;
    return Icons.security;
  }
}
