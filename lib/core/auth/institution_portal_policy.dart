import '../models/user_model.dart';
import 'portal_capabilities.dart';

/// Splits **school admin** (operations / HR / master data) from **principal**
/// (leadership: visibility, approvals, comms, guardian contact — not roster HR).
///
/// Admin path deny rules are delegated to [PrincipalPortalPolicy] (see
/// [portal_capabilities.dart] matrix).
abstract final class InstitutionPortalPolicy {
  static bool isPrincipalForbiddenAdminPath(String path) =>
      PrincipalPortalPolicy.shouldRedirectPrincipalFromAdmin(path);

  static bool isPrincipal(UserRole? role) =>
      PrincipalPortalPolicy.isPrincipal(role);
}
