import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/warden_lodge_providers.dart';
import '../widgets/warden_portal_bar_actions.dart';

class WardenConciergeScreen extends ConsumerStatefulWidget {
  const WardenConciergeScreen({super.key});

  @override
  ConsumerState<WardenConciergeScreen> createState() =>
      _WardenConciergeScreenState();
}

class _WardenConciergeScreenState extends ConsumerState<WardenConciergeScreen> {
  final _detail = TextEditingController();

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  void _add(String title, String detail) {
    MockData.appendWardenConciergeLog({
      'at': DateTime.now().toIso8601String(),
      'title': title,
      'detail': detail,
    });
    ref.read(dataSyncProvider.notifier).bump();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final log = ref.watch(wardenConciergeLogProvider);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: Text(l10n.wardenConciergeTitle),
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              actions: const [
                WardenPortalBarActions(),
                SizedBox(width: AppSpacing.sm),
              ],
            ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            l10n.wardenLodgeConciergeSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: Text(l10n.wardenConciergeQuickParentCall),
                onPressed: () => _add(
                  l10n.wardenConciergeQuickParentCall,
                  'Logged from quick template.',
                ),
              ),
              ActionChip(
                label: Text(l10n.wardenConciergeQuickMedicine),
                onPressed: () => _add(
                  l10n.wardenConciergeQuickMedicine,
                  'Verify dosage sticker & student ID.',
                ),
              ),
              ActionChip(
                label: Text(l10n.wardenConciergeQuickMaintenance),
                onPressed: () => _add(
                  l10n.wardenConciergeQuickMaintenance,
                  'Photo sent to estates group (demo).',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _detail,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.wardenConciergeDetailHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: () {
              final t = _detail.text.trim();
              if (t.isEmpty) return;
              _add('Shift note', t);
              _detail.clear();
            },
            icon: const Icon(Icons.add_comment_outlined),
            label: Text(l10n.wardenConciergeAdd),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Log',
            style: AppTypography.titleSmall.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (log.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  l10n.wardenConciergeEmpty,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...log.reversed.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: NcCard(
                  child: ListTile(
                    leading: const Icon(Icons.edit_note, color: AppColors.teal),
                    title: Text('${e['title']}'),
                    subtitle: Text(
                      '${e['detail'] ?? ''}\n${e['at'] ?? ''}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
