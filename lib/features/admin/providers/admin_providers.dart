import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import 'staff_notifier.dart';

final adminDashboardKpisProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return Map<String, dynamic>.from(MockData.dashboardKpis);
});

final adminStudentsProvider = FutureProvider<List<MockStudent>>((ref) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.students;
});

/// Staff list with add support. Used by WebStaffScreen and PeopleScreen.
final adminStaffProvider = Provider<AsyncValue<List<MockStaffMember>>>((ref) {
  return ref.watch(staffNotifierProvider);
});

final adminNoticesProvider = FutureProvider<List<MockNotice>>((ref) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.notices;
});

// Approvals mock
class MockApproval {
  const MockApproval({
    required this.id,
    required this.type,
    required this.requestedBy,
    required this.details,
    required this.date,
    required this.status,
  });
  final String id;
  final String type;
  final String requestedBy;
  final String details;
  final DateTime date;
  final String status;
}

final adminApprovalsProvider = FutureProvider<List<MockApproval>>((ref) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return [];
});
