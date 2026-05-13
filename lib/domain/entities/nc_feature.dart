/// Feature flags — every institution subscribes to a subset of these.
/// Navigation tabs, routes, and widgets gate themselves on this enum.
enum NcFeature {
  /// School bus tracking, GPS, driver app
  transport,

  /// Hostel management, room allocation, roll-call
  hostel,

  /// Library catalog, issue/return, reservations
  library,

  /// Canteen ordering, student wallet, nutritional tracking
  canteen,

  /// Biometric punch-in/out for attendance
  biometric,

  /// AI-powered face-recognition attendance
  faceRecognition,

  /// LMS / e-learning integration
  lmsIntegration,

  /// WhatsApp bot notifications
  whatsappBot,

  /// AI-powered analytics and insights dashboard
  aiInsights,

  /// Online fee payment gateway
  onlinePayment,

  /// Event ticketing and campus event management
  eventTicketing,

  /// Inventory and asset management
  inventory,

  /// HR payroll processing
  hrPayroll,

  /// Multi-campus / multi-branch support
  multiCampus,

  /// Teacher–parent direct chat
  parentChat,

  /// Student and parent complaints portal
  complaints,

  /// Live polls and surveys
  polls,

  /// Alumni tracking and engagement
  alumni,
}

/// Extension for convenient JSON string ↔ enum conversion.
extension NcFeatureX on NcFeature {
  /// Snake-case string matching API/JSON field values.
  String get key => switch (this) {
    NcFeature.transport => 'transport',
    NcFeature.hostel => 'hostel',
    NcFeature.library => 'library',
    NcFeature.canteen => 'canteen',
    NcFeature.biometric => 'biometric',
    NcFeature.faceRecognition => 'face_recognition',
    NcFeature.lmsIntegration => 'lms_integration',
    NcFeature.whatsappBot => 'whatsapp_bot',
    NcFeature.aiInsights => 'ai_insights',
    NcFeature.onlinePayment => 'online_payment',
    NcFeature.eventTicketing => 'event_ticketing',
    NcFeature.inventory => 'inventory',
    NcFeature.hrPayroll => 'hr_payroll',
    NcFeature.multiCampus => 'multi_campus',
    NcFeature.parentChat => 'parent_chat',
    NcFeature.complaints => 'complaints',
    NcFeature.polls => 'polls',
    NcFeature.alumni => 'alumni',
  };

  static NcFeature? fromKey(String key) {
    for (final f in NcFeature.values) {
      if (f.key == key) return f;
    }
    return null;
  }
}
