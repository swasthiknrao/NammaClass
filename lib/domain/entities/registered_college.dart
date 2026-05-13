import 'package:flutter/foundation.dart';

import 'nc_feature.dart';
import 'tenant_profile.dart';

/// Super Admin registry row: one institution + optional known users.
@immutable
class RegisteredCollege {
  const RegisteredCollege({
    required this.profile,
    required this.users,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  final TenantProfile profile;
  final List<CollegeInstitutionUser> users;
  final CollegeProvisioningStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  String get tenantId => profile.tenantId;

  int get enabledModuleCount =>
      NcFeature.values.where(profile.hasFeature).length;

  RegisteredCollege copyWith({
    TenantProfile? profile,
    List<CollegeInstitutionUser>? users,
    CollegeProvisioningStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegisteredCollege(
      profile: profile ?? this.profile,
      users: users ?? this.users,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'profile': profile.toJson(),
    'users': users.map((e) => e.toJson()).toList(),
    'status': _statusToWire(status),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory RegisteredCollege.fromJson(Map<String, dynamic> json) {
    return RegisteredCollege(
      profile: TenantProfile.fromJson(
        Map<String, dynamic>.from(json['profile'] as Map),
      ),
      users: (json['users'] as List<dynamic>? ?? [])
          .map(
            (e) => CollegeInstitutionUser.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      status: _statusFromWire(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }
}

String _statusToWire(CollegeProvisioningStatus s) => switch (s) {
  CollegeProvisioningStatus.pending => 'pending',
  CollegeProvisioningStatus.inProgress => 'in_progress',
  CollegeProvisioningStatus.live => 'live',
};

CollegeProvisioningStatus _statusFromWire(String? raw) {
  switch (raw) {
    case 'pending':
      return CollegeProvisioningStatus.pending;
    case 'in_progress':
    case 'inProgress':
      return CollegeProvisioningStatus.inProgress;
    case 'live':
      return CollegeProvisioningStatus.live;
    default:
      return CollegeProvisioningStatus.live;
  }
}

@immutable
class CollegeInstitutionUser {
  const CollegeInstitutionUser({
    required this.name,
    required this.email,
    required this.role,
    this.status = 'Active',
  });

  final String name;
  final String email;
  final String role;
  final String status;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'role': role,
    'status': status,
  };

  factory CollegeInstitutionUser.fromJson(Map<String, dynamic> json) {
    return CollegeInstitutionUser(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
    );
  }
}

enum CollegeProvisioningStatus { pending, inProgress, live }
