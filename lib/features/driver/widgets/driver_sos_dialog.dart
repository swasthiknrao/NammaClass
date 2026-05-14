import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

Future<void> showDriverSosDialog(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  String category = 'medical';
  final noteCtrl = TextEditingController();

  bool? send;
  String noteText = '';
  try {
    send = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: AppColors.error,
          title: Text(
            l10n.driverSosDialogTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.driverSosCategoryLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _catChip(
                      ctx,
                      label: l10n.driverSosCategoryMedical,
                      selected: category == 'medical',
                      onTap: () => setLocal(() => category = 'medical'),
                    ),
                    _catChip(
                      ctx,
                      label: l10n.driverSosCategoryBreakdown,
                      selected: category == 'breakdown',
                      onTap: () => setLocal(() => category = 'breakdown'),
                    ),
                    _catChip(
                      ctx,
                      label: l10n.driverSosCategorySecurity,
                      selected: category == 'security',
                      onTap: () => setLocal(() => category = 'security'),
                    ),
                    _catChip(
                      ctx,
                      label: l10n.driverSosCategoryOther,
                      selected: category == 'other',
                      onTap: () => setLocal(() => category = 'other'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: l10n.driverSosNoteLabel,
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.error,
              ),
              child: Text(l10n.driverSosSend),
            ),
          ],
        ),
      ),
    );
  } finally {
    noteText = noteCtrl.text.trim();
    noteCtrl.dispose();
  }

  if (send == true && context.mounted) {
    MockData.mergeBusInfo({
      'last_sos_category': category,
      'last_sos_note': noteText,
      'last_sos_at': DateTime.now().toIso8601String(),
    });
    ref.read(dataSyncProvider.notifier).bump();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.driverSosSentSnack),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

Widget _catChip(
  BuildContext context, {
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return Material(
    color: selected ? Colors.white : Colors.white.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.error : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}
