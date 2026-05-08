/// Tokens + IAM claims returned from auth (OTP or demo).
class AuthCredentials {
  const AuthCredentials({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.tenantId,
    required this.branchId,
    required this.displayName,
    required this.phone,
    required this.roleName,
    required this.permissions,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String tenantId;
  final String? branchId;
  final String displayName;
  final String phone;
  final String roleName;
  final List<String> permissions;
}
