import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_model.dart';
import '../../../core/namma_ai/ai_row_scope.dart';
import '../../../core/namma_ai/ai_sensitivity_tier.dart';
import '../../../core/namma_ai/namma_ai_policy_engine.dart';
import '../../../domain/entities/nc_feature.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tenant/providers/tenant_provider.dart';

/// Effective Namma AI policy for the current session.
final nammaAiPolicyProvider = Provider.autoDispose<NammaAiPolicyResolution>((
  ref,
) {
  final user = ref.watch(currentUserProvider);
  final perms = ref.watch(demoPermissionsProvider);
  final tenant = ref.watch(tenantProfileProvider);
  if (user == null) {
    return const NammaAiPolicyResolution(
      maxSensitivity: AiSensitivityTier.tierPublic,
      rowScope: AiRowScope.self,
      allowedToolIds: {},
      enabledModules: {},
    );
  }
  return NammaAiPolicyEngine.resolve(
    user: user,
    permissions: perms,
    tenant: tenant,
  );
});

/// JSON context sent to Namma AI Gateway (must stay in sync with gateway `policy.js`).
final nammaAiContextMapProvider = Provider.autoDispose<Map<String, dynamic>>((
  ref,
) {
  final user = ref.watch(currentUserProvider);
  final tenant = ref.watch(tenantProfileProvider);
  final perms = ref.watch(demoPermissionsProvider);
  final policy = ref.watch(nammaAiPolicyProvider);
  if (user == null) return {};

  final features = <String>[
    for (final f in NcFeature.values)
      if (tenant.hasFeature(f)) f.key,
  ];

  final wardIds = <String>[];
  if (user.role == UserRole.parent && user.studentId != null) {
    wardIds.add(user.studentId!);
  }

  final map = <String, dynamic>{
    'user_id': user.id,
    'tenant_id': tenant.tenantId,
    'role': user.role.name,
    'permissions': perms,
    'features': features,
    'branch_id': user.branchId,
    'ward_student_ids': wardIds,
    'department_ids': <String>[],
    'allowed_tool_ids': policy.allowedToolIds.toList(),
  };
  if (user.role == UserRole.student && user.studentId != null) {
    map['student_entity_id'] = user.studentId;
  }
  return map;
});
