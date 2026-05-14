import 'package:flutter/material.dart';

import '../../../core/models/user_model.dart';
import '../../../core/namma_ai/ai_row_scope.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Explains who the AI is acting for (UX only; server enforces scope).
class NammaAiScopeChipBar extends StatelessWidget {
  const NammaAiScopeChipBar({
    super.key,
    required this.role,
    required this.rowScope,
    required this.tenantName,
    this.branchLabel,
    this.wardHint,
  });

  final UserRole role;
  final AiRowScope rowScope;
  final String tenantName;
  final String? branchLabel;
  final String? wardHint;

  @override
  Widget build(BuildContext context) {
    final scopeLabel = switch (rowScope) {
      AiRowScope.self => 'Personal',
      AiRowScope.ward => 'Ward-linked',
      AiRowScope.assignedClass => 'My classes',
      AiRowScope.department => 'Department',
      AiRowScope.campus => 'Campus',
      AiRowScope.institution => 'Institution',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          Chip(
            avatar: const Icon(Icons.verified_user_outlined, size: 18),
            label: Text(role.roleLabel, style: AppTypography.labelMedium),
          ),
          Chip(
            avatar: const Icon(Icons.filter_alt_outlined, size: 18),
            label: Text(scopeLabel, style: AppTypography.labelMedium),
          ),
          Chip(
            avatar: const Icon(Icons.apartment_outlined, size: 18),
            label: Text(
              tenantName,
              style: AppTypography.labelMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (branchLabel != null && branchLabel!.isNotEmpty)
            Chip(
              label: Text(
                'Branch: $branchLabel',
                style: AppTypography.labelMedium,
              ),
            ),
          if (wardHint != null && wardHint!.isNotEmpty)
            Chip(label: Text(wardHint!, style: AppTypography.labelMedium)),
        ],
      ),
    );
  }
}

extension _RoleLabel on UserRole {
  String get roleLabel => UserModel.roleDisplayLabel(this);
}
