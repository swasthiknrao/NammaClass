import '../models/user_model.dart';
import '../../domain/entities/nc_feature.dart';
import '../../domain/entities/tenant_profile.dart';
import 'ai_row_scope.dart';
import 'ai_sensitivity_tier.dart';
import 'namma_ai_tool_id.dart';

/// Resolved AI entitlements for the signed-in user — UI hints; **server is authoritative**.
class NammaAiPolicyResolution {
  const NammaAiPolicyResolution({
    required this.maxSensitivity,
    required this.rowScope,
    required this.allowedToolIds,
    required this.enabledModules,
  });

  final AiSensitivityTier maxSensitivity;
  final AiRowScope rowScope;
  final Set<String> allowedToolIds;
  final Set<String> enabledModules;

  bool get hasAnyTools => allowedToolIds.isNotEmpty;
}

/// Role-aware AI policy: composes [UserRole], JWT-style [permissions], and [NcFeature] flags.
abstract final class NammaAiPolicyEngine {
  static NammaAiPolicyResolution resolve({
    required UserModel user,
    required List<String> permissions,
    required TenantProfile tenant,
  }) {
    final tenantFeatures = {
      for (final f in NcFeature.values)
        if (tenant.hasFeature(f)) f,
    };
    final mods = _enabledModules(tenantFeatures);
    final role = user.role;
    final base = _baseForRole(role);
    var tools = <String>{...base.tools};
    final sens = base.sensitivity;
    var scope = base.scope;

    tools = {
      for (final t in tools)
        if (_toolAllowed(t, permissions, mods)) t,
    };

    if (!tenantFeatures.contains(NcFeature.aiInsights)) {
      tools.clear();
    }

    return NammaAiPolicyResolution(
      maxSensitivity: sens,
      rowScope: scope,
      allowedToolIds: tools,
      enabledModules: mods,
    );
  }

  static Set<String> _enabledModules(Set<NcFeature> f) {
    return {
      'academics',
      if (f.contains(NcFeature.transport)) 'transport',
      if (f.contains(NcFeature.hostel)) 'hostel',
      if (f.contains(NcFeature.library)) 'library',
      if (f.contains(NcFeature.canteen)) 'canteen',
      if (f.contains(NcFeature.hrPayroll)) 'hr_payroll',
      if (f.contains(NcFeature.inventory)) 'inventory',
      if (f.contains(NcFeature.eventTicketing)) 'events',
      if (f.contains(NcFeature.complaints)) 'complaints',
    };
  }

  static bool _has(List<String> p, String claim) => p.contains(claim);

  static bool _toolAllowed(String tool, List<String> perms, Set<String> mods) {
    bool need(String c) => _has(perms, c);
    switch (tool) {
      case NammaAiToolId.wardAttendanceSummary:
        return need('students:read') || need('messages:read');
      case NammaAiToolId.myAttendanceSummary:
        return need('students:read');
      case NammaAiToolId.feeAgingSummary:
        return need('fees:read');
      case NammaAiToolId.departmentPerformanceSummary:
        return need('students:read') &&
            (need('web:access') || need('staff:read'));
      case NammaAiToolId.institutionalHealthSnapshot:
        return need('students:read') && need('web:access');
      case NammaAiToolId.libraryOverduesSummary:
        return need('library:read') && mods.contains('library');
      case NammaAiToolId.transportDelaySummary:
        return (need('transport:read') || need('students:read')) &&
            mods.contains('transport');
      case NammaAiToolId.draftNotice:
        return need('web:access') &&
            (need('students:write') ||
                need('support:write') ||
                need('approvals:write'));
      default:
        return false;
    }
  }

  static ({AiSensitivityTier sensitivity, AiRowScope scope, Set<String> tools})
  _baseForRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return (
          sensitivity: AiSensitivityTier.tierConfidential,
          scope: AiRowScope.institution,
          tools: {
            NammaAiToolId.institutionalHealthSnapshot,
            NammaAiToolId.departmentPerformanceSummary,
            NammaAiToolId.feeAgingSummary,
            NammaAiToolId.libraryOverduesSummary,
            NammaAiToolId.transportDelaySummary,
            NammaAiToolId.draftNotice,
          },
        );
      case UserRole.admin:
      case UserRole.support:
        return (
          sensitivity: AiSensitivityTier.tierConfidential,
          scope: AiRowScope.institution,
          tools: {
            NammaAiToolId.institutionalHealthSnapshot,
            NammaAiToolId.departmentPerformanceSummary,
            NammaAiToolId.feeAgingSummary,
            NammaAiToolId.libraryOverduesSummary,
            NammaAiToolId.transportDelaySummary,
            NammaAiToolId.draftNotice,
          },
        );
      case UserRole.principal:
        return (
          sensitivity: AiSensitivityTier.tierInternal,
          scope: AiRowScope.institution,
          tools: {
            NammaAiToolId.institutionalHealthSnapshot,
            NammaAiToolId.departmentPerformanceSummary,
            NammaAiToolId.feeAgingSummary,
            NammaAiToolId.libraryOverduesSummary,
            NammaAiToolId.transportDelaySummary,
            NammaAiToolId.draftNotice,
          },
        );
      case UserRole.hod:
        return (
          sensitivity: AiSensitivityTier.tierInternal,
          scope: AiRowScope.department,
          tools: {
            NammaAiToolId.departmentPerformanceSummary,
            NammaAiToolId.libraryOverduesSummary,
            NammaAiToolId.draftNotice,
          },
        );
      case UserRole.accountant:
        return (
          sensitivity: AiSensitivityTier.tierConfidential,
          scope: AiRowScope.institution,
          tools: {NammaAiToolId.feeAgingSummary},
        );
      case UserRole.teacher:
        return (
          sensitivity: AiSensitivityTier.tierInternal,
          scope: AiRowScope.assignedClass,
          tools: {NammaAiToolId.departmentPerformanceSummary},
        );
      case UserRole.librarian:
        return (
          sensitivity: AiSensitivityTier.tierInternal,
          scope: AiRowScope.campus,
          tools: {NammaAiToolId.libraryOverduesSummary},
        );
      case UserRole.driver:
        return (
          sensitivity: AiSensitivityTier.tierInternal,
          scope: AiRowScope.campus,
          tools: {NammaAiToolId.transportDelaySummary},
        );
      case UserRole.parent:
        return (
          sensitivity: AiSensitivityTier.tierConfidential,
          scope: AiRowScope.ward,
          tools: {NammaAiToolId.wardAttendanceSummary},
        );
      case UserRole.student:
        return (
          sensitivity: AiSensitivityTier.tierInternal,
          scope: AiRowScope.self,
          tools: {NammaAiToolId.myAttendanceSummary},
        );
      case UserRole.staff:
      case UserRole.warden:
      case UserRole.canteenStaff:
        return (
          sensitivity: AiSensitivityTier.tierInternal,
          scope: AiRowScope.self,
          tools: <String>{},
        );
    }
  }
}
