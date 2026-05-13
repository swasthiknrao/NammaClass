import '../entities/staff_entity.dart';

/// Contract for staff directory and payroll data.
abstract class StaffRepository {
  /// Returns all staff members, optionally filtered by [department] or [query].
  Future<List<StaffMember>> getStaff({String? department, String? query});

  /// Returns the staff member with [staffId].
  Future<StaffMember> getStaffById(String staffId);

  /// Returns payslips for [staffId], newest first.
  Future<List<Payslip>> getPayslips(String staffId);
}
