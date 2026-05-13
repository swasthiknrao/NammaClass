import '../../domain/entities/nc_feature.dart';
import '../../domain/entities/tenant_profile.dart';

/// Sample tenant profiles for development and demo mode.
/// These represent three common institution archetypes that NammaClass serves.
class MockTenantProfiles {
  MockTenantProfiles._();

  /// Full-featured college — all premium modules enabled.
  static final TenantProfile college = TenantProfile(
    tenantId: 'nc_inst_001',
    institutionName: "St. Joseph's College",
    logoUrl: 'https://cdn.nammaclass.in/logos/sjc.png',
    appIconUrl: 'https://cdn.nammaclass.in/icons/sjc_icon.png',
    primaryHex: '1B4F72',
    accentHex: 'E67E22',
    features: {
      NcFeature.transport,
      NcFeature.library,
      NcFeature.canteen,
      NcFeature.hostel,
      NcFeature.onlinePayment,
      NcFeature.aiInsights,
      NcFeature.parentChat,
      NcFeature.complaints,
      NcFeature.hrPayroll,
      NcFeature.polls,
      NcFeature.inventory,
      NcFeature.eventTicketing,
      NcFeature.multiCampus,
    },
    timezone: 'Asia/Kolkata',
    currency: 'INR',
    languages: ['en', 'kn'],
  );

  /// Mid-tier K-12 school — core modules only.
  static final TenantProfile school = TenantProfile(
    tenantId: 'nc_inst_002',
    institutionName: 'Vidyashree Public School',
    logoUrl: 'https://cdn.nammaclass.in/logos/vps.png',
    appIconUrl: 'https://cdn.nammaclass.in/icons/vps_icon.png',
    primaryHex: '1A5276',
    accentHex: 'D4A017',
    features: {
      NcFeature.transport,
      NcFeature.canteen,
      NcFeature.parentChat,
      NcFeature.complaints,
      NcFeature.onlinePayment,
      NcFeature.polls,
    },
    timezone: 'Asia/Kolkata',
    currency: 'INR',
    languages: ['en', 'kn', 'hi'],
  );

  /// Coaching centre — minimal feature set focused on academics.
  static final TenantProfile coaching = TenantProfile(
    tenantId: 'nc_inst_003',
    institutionName: 'Apex Coaching Centre',
    logoUrl: 'https://cdn.nammaclass.in/logos/apex.png',
    appIconUrl: 'https://cdn.nammaclass.in/icons/apex_icon.png',
    primaryHex: '117A65',
    accentHex: 'E74C3C',
    features: {
      NcFeature.canteen,
      NcFeature.complaints,
      NcFeature.lmsIntegration,
    },
    timezone: 'Asia/Kolkata',
    currency: 'INR',
    languages: ['en', 'hi'],
  );

  /// Default demo tenant used when no tenant context is available.
  static TenantProfile get demo => college;

  /// All sample profiles indexed by tenantId — for mock lookup.
  static final Map<String, TenantProfile> byId = {
    college.tenantId: college,
    school.tenantId: school,
    coaching.tenantId: coaching,
  };
}
