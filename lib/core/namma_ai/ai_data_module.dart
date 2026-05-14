/// ERP domains Namma AI tools may touch — aligned with gateway tool registry.
enum AiDataModule {
  academics,
  attendance,
  fees,
  complaints,
  transport,
  hostel,
  library,
  canteen,
  hrPayroll,
  inventory,
  events,
  communications,
  platform,
  analytics,
}

extension AiDataModuleX on AiDataModule {
  String get key => name;
}
