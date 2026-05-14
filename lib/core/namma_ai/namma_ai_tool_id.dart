/// Stable tool ids — must match [services/namma_ai_gateway/src/tools/registry.ts].
abstract final class NammaAiToolId {
  static const wardAttendanceSummary = 'ward_attendance_summary';
  static const myAttendanceSummary = 'my_attendance_summary';
  static const feeAgingSummary = 'fee_aging_summary';
  static const departmentPerformanceSummary = 'department_performance_summary';
  static const institutionalHealthSnapshot = 'institutional_health_snapshot';
  static const libraryOverduesSummary = 'library_overdues_summary';
  static const transportDelaySummary = 'transport_delay_summary';
  static const draftNotice = 'draft_notice';
}
