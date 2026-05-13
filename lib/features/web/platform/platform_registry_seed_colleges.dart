import 'package:flutter/material.dart';

import '../../../core/theme/theme_presets.dart';
import '../../../domain/entities/entitlement_snapshot.dart';
import '../../../domain/entities/nc_feature.dart';
import '../../../domain/entities/registered_college.dart';
import '../../../domain/entities/tenant_profile.dart';

String _hex(Color c) =>
    c.toARGB32().toRadixString(16).toUpperCase().substring(2);

Map<String, dynamic> _collegeProfile({
  required String legalName,
  required String shortCode,
  required String instituteType,
  required String websiteUrl,
  required String contactEmail,
  required String contactPhone,
  required String address,
  required String city,
  required String state,
  required String postalCode,
  required String country,
  required String affiliationBoard,
  int? yearEstablished,
  required String accreditationNotes,
  required String approxEnrollmentBand,
  required String principalName,
  required String billingEmail,
  required String registrarNotes,
  required String taxId,
  String profileTimezone = 'Asia/Kolkata',
  String profileCurrency = 'INR',
}) {
  return {
    'legal_name': legalName,
    'short_code': shortCode,
    'institute_type': instituteType,
    'website_url': websiteUrl,
    'contact_email': contactEmail,
    'contact_phone': contactPhone,
    'address': address,
    'city': city,
    'state': state,
    'postal_code': postalCode,
    'country': country,
    'affiliation_board': affiliationBoard,
    'year_established': ?yearEstablished,
    'accreditation_notes': accreditationNotes,
    'approx_enrollment_band': approxEnrollmentBand,
    'principal_or_head_name': principalName,
    'billing_email': billingEmail,
    'registrar_office_notes': registrarNotes,
    'tax_id_or_gstin': taxId,
    'profile_timezone': profileTimezone,
    'profile_currency': profileCurrency,
  };
}

TenantProfile _tenant({
  required String tenantId,
  required String institutionName,
  required AppThemePreset preset,
  required Set<NcFeature> modulesOn,
  required Map<String, dynamic> collegeProfile,
  Map<String, List<String>>? moduleSubFeatures,
}) {
  final modules = {
    for (final f in NcFeature.values)
      f.key: ModuleEntitlement(enabled: modulesOn.contains(f)),
  };
  final snap = EntitlementSnapshot(
    schemaVersion: 1,
    snapshotVersion: 1,
    tenantId: tenantId,
    modules: modules,
    limits: const EntitlementLimits.empty(),
    integrationAllowlist: const [],
    allowedRoleKeys: const [],
  );
  final intake = <String, dynamic>{
    'college_profile': collegeProfile,
    if (moduleSubFeatures != null && moduleSubFeatures.isNotEmpty)
      'module_sub_features': moduleSubFeatures,
  };
  return TenantProfile(
    tenantId: tenantId,
    institutionName: institutionName,
    logoUrl: '',
    appIconUrl: '',
    primaryHex: _hex(preset.primaryColor),
    accentHex: _hex(preset.accentColor),
    features: modulesOn,
    entitlementSnapshot: snap,
    themeTokens: preset.tokens,
    intake: intake,
    timezone: collegeProfile['profile_timezone'] as String? ?? 'Asia/Kolkata',
    currency: collegeProfile['profile_currency'] as String? ?? 'INR',
    languages: const ['en', 'kn'],
  );
}

/// Demo rows merged into [platform_college_registry.json] on first bootstrap only.
/// Keys mirror the Add college form (`intake.college_profile`).
List<RegisteredCollege> buildPlatformRegistrySeedColleges() {
  final t0 = DateTime.utc(2025, 1, 10);
  final t1 = DateTime.utc(2025, 1, 11);
  final t2 = DateTime.utc(2025, 1, 12);
  final t3 = DateTime.utc(2025, 1, 13);
  final t4 = DateTime.utc(2025, 1, 14);

  return [
    RegisteredCollege(
      profile: _tenant(
        tenantId: 'nc_seed_rv_engineering',
        institutionName: 'RV Institute of Technology (demo)',
        preset: AppThemePresets.oceanBlue,
        modulesOn: {
          NcFeature.library,
          NcFeature.transport,
          NcFeature.lmsIntegration,
          NcFeature.onlinePayment,
          NcFeature.parentChat,
        },
        collegeProfile: _collegeProfile(
          legalName: 'Rashtreeya Vidyalaya College of Engineering Trust',
          shortCode: 'RVIT',
          instituteType: 'Affiliated college / aided',
          websiteUrl: 'https://rvit-demo.nammaclass.example',
          contactEmail: 'registrar@rvit-demo.nammaclass.example',
          contactPhone: '+91 80 6717 8000',
          address: 'Mysore Road, RV Vidyaniketan',
          city: 'Bengaluru',
          state: 'Karnataka',
          postalCode: '560059',
          country: 'India',
          affiliationBoard: 'Visvesvaraya Technological University (VTU)',
          yearEstablished: 1963,
          accreditationNotes: 'NAAC A++ (cycle 4, illustrative)',
          approxEnrollmentBand: '3.2k UG + PG',
          principalName: 'Dr. Meera Krishnan (demo)',
          billingEmail: 'accounts@rvit-demo.nammaclass.example',
          registrarNotes: 'Block A, room 104 · Mon–Fri 10:00–16:00',
          taxId: '29AABCU9603R1ZX',
        ),
        moduleSubFeatures: {
          'library': ['catalog', 'issue_return', 'reservations'],
          'transport': ['parent_live_tracking', 'student_boarding'],
        },
      ),
      users: const [],
      status: CollegeProvisioningStatus.live,
      createdAt: t0,
    ),
    RegisteredCollege(
      profile: _tenant(
        tenantId: 'nc_seed_manipal_health',
        institutionName: 'Manipal Academy of Health Sciences (demo)',
        preset: AppThemePresets.forestGreen,
        modulesOn: {
          NcFeature.hostel,
          NcFeature.canteen,
          NcFeature.onlinePayment,
          NcFeature.multiCampus,
          NcFeature.biometric,
          NcFeature.complaints,
        },
        collegeProfile: _collegeProfile(
          legalName:
              'Manipal Education and Medical Group International India Pvt Ltd',
          shortCode: 'MAHS',
          instituteType: 'Deemed university',
          websiteUrl: 'https://manipal-health-demo.nammaclass.example',
          contactEmail: 'campus.ops@manipal-demo.nammaclass.example',
          contactPhone: '+91 820 257 1200',
          address: 'Madhav Nagar, Manipal campus ring road',
          city: 'Udupi',
          state: 'Karnataka',
          postalCode: '576104',
          country: 'India',
          affiliationBoard: 'Deemed university · UGC 1956f',
          yearEstablished: 1953,
          accreditationNotes: 'NABH entry-level · NBA selected programmes',
          approxEnrollmentBand: '6k+ students across health sciences',
          principalName: 'Dr. Arjun Shetty (demo VC office)',
          billingEmail: 'treasury@manipal-demo.nammaclass.example',
          registrarNotes: 'Central admissions: Gate 3, student services hub',
          taxId: '29AAACM1234E1Z5',
        ),
      ),
      users: const [],
      status: CollegeProvisioningStatus.live,
      createdAt: t1,
    ),
    RegisteredCollege(
      profile: _tenant(
        tenantId: 'nc_seed_govt_poly_dharwad',
        institutionName: 'Government Polytechnic Dharwad (demo)',
        preset: AppThemePresets.midnightSteel,
        modulesOn: {
          NcFeature.library,
          NcFeature.inventory,
          NcFeature.canteen,
          NcFeature.onlinePayment,
        },
        collegeProfile: _collegeProfile(
          legalName: 'Directorate of Technical Education, Karnataka',
          shortCode: 'GPD',
          instituteType: 'Polytechnic / diploma',
          websiteUrl: 'https://gpt-dharwad-demo.nammaclass.example',
          contactEmail: 'principal@gpt-dharwad-demo.nammaclass.example',
          contactPhone: '+91 836 274 2210',
          address: 'PB Road, near Jubilee Circle',
          city: 'Dharwad',
          state: 'Karnataka',
          postalCode: '580001',
          country: 'India',
          affiliationBoard: 'DTE Karnataka · AICTE diploma',
          yearEstablished: 1958,
          accreditationNotes: 'NBA Tier-II workshop cluster (demo label)',
          approxEnrollmentBand: '900 diploma seats',
          principalName: 'Sri. Basavaraj Patil (demo)',
          billingEmail: 'dte-fees@gpt-dharwad-demo.nammaclass.example',
          registrarNotes: 'Scholarship desk: ground floor, counter 2',
          taxId: '',
        ),
      ),
      users: const [],
      status: CollegeProvisioningStatus.live,
      createdAt: t2,
    ),
    RegisteredCollege(
      profile: _tenant(
        tenantId: 'nc_seed_iti_toolroom',
        institutionName: 'Karnataka Tool Room & Training Centre (demo)',
        preset: AppThemePresets.solarOrange,
        modulesOn: {
          NcFeature.transport,
          NcFeature.canteen,
          NcFeature.inventory,
          NcFeature.hrPayroll,
        },
        collegeProfile: _collegeProfile(
          legalName: 'Karnataka Tool Room and Training Centre Society',
          shortCode: 'KITC',
          instituteType: 'ITI / vocational',
          websiteUrl: 'https://kitrc-demo.nammaclass.example',
          contactEmail: 'training@kitrc-demo.nammaclass.example',
          contactPhone: '+91 80 2839 4400',
          address: 'KIADB Industrial Area, Peenya',
          city: 'Bengaluru',
          state: 'Karnataka',
          postalCode: '560058',
          country: 'India',
          affiliationBoard: 'NCVT · DGT apprenticeship',
          yearEstablished: 1995,
          accreditationNotes: 'ISO 9001 toolroom partner (demo)',
          approxEnrollmentBand: '400 trainees + 120 apprentices',
          principalName: 'Shri. Lokesh Rao (demo director)',
          billingEmail: 'projects@kitrc-demo.nammaclass.example',
          registrarNotes: 'Batch intake: Jan & July windows only',
          taxId: '29AAA1234B1C2D3',
          profileCurrency: 'INR',
        ),
      ),
      users: const [],
      status: CollegeProvisioningStatus.inProgress,
      createdAt: t3,
    ),
    RegisteredCollege(
      profile: _tenant(
        tenantId: 'nc_seed_mount_carmel_arts',
        institutionName: 'Mount Carmel College (demo)',
        preset: AppThemePresets.royalPurple,
        modulesOn: {
          NcFeature.parentChat,
          NcFeature.alumni,
          NcFeature.eventTicketing,
          NcFeature.library,
          NcFeature.polls,
        },
        collegeProfile: _collegeProfile(
          legalName: 'Carmel Education Society of Karnataka',
          shortCode: 'MCC',
          instituteType: 'Autonomous college',
          websiteUrl: 'https://mccblr-demo.nammaclass.example',
          contactEmail: 'office@mccblr-demo.nammaclass.example',
          contactPhone: '+91 80 2226 2794',
          address: '58, Palace Road, Vasanth Nagar',
          city: 'Bengaluru',
          state: 'Karnataka',
          postalCode: '560052',
          country: 'India',
          affiliationBoard: 'Bangalore University · autonomous since 2005',
          yearEstablished: 1948,
          accreditationNotes: 'NAAC A+ · DBT star college (demo)',
          approxEnrollmentBand: '2.1k UG women students',
          principalName: 'Dr. Susan Sanny (demo)',
          billingEmail: 'fees@mccblr-demo.nammaclass.example',
          registrarNotes: 'Alumni cell: heritage block, level 2',
          taxId: '29AABCM5678E1Z2',
        ),
      ),
      users: const [],
      status: CollegeProvisioningStatus.live,
      createdAt: t4,
    ),
  ];
}
