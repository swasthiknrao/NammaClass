import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Deterministic 6-digit temp PIN for mock onboarding (same as legacy add-user).
String adminGeneratedTempPin(String name, String phone) {
  final h = Object.hash(name, phone);
  return '${100000 + h.abs() % 900000}';
}

Future<void> showAdminUserCreatedDialog(
  BuildContext context, {
  required String roleLabel,
  required String name,
  required String phone,
  required String email,
  required String pin,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('User created'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$roleLabel · $name', style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Share this temporary PIN once; ask them to change it on first login.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _CopyRow(label: 'Phone', value: phone),
            _CopyRow(label: 'Email', value: email),
            _CopyRow(label: 'Temporary PIN', value: pin, mono: true),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({required this.label, required this.value, this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTypography.labelMedium),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: mono ? 'JetBrainsMono' : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            tooltip: 'Copy',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$label copied')));
            },
          ),
        ],
      ),
    );
  }
}
