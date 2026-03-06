import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';

final adminDashboardKpisProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 800));
  return Map<String, dynamic>.from(MockData.dashboardKpis);
});

final adminStudentsProvider = FutureProvider<List<MockStudent>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 700));
  return MockData.students;
});

final adminStaffProvider = FutureProvider<List<MockStaffMember>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return MockData.staff;
});

final adminNoticesProvider = FutureProvider<List<MockNotice>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
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
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    MockApproval(
      id: 'ap01',
      type: 'Leave Request',
      requestedBy: 'Priya Sharma',
      details: 'Leave for 2 days — March 7-8 (Personal)',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      status: 'pending',
    ),
    MockApproval(
      id: 'ap02',
      type: 'Fee Waiver',
      requestedBy: 'Parent of Manoj Singh',
      details: 'Term 3 fee waiver request — Financial hardship',
      date: DateTime.now().subtract(const Duration(hours: 6)),
      status: 'pending',
    ),
    MockApproval(
      id: 'ap03',
      type: 'TC Request',
      requestedBy: 'Parent of Tejas Patil',
      details: 'Transfer certificate — relocating to Pune',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'pending',
    ),
    MockApproval(
      id: 'ap04',
      type: 'Leave Request',
      requestedBy: 'Mohan Raj',
      details: '1 day leave — March 10 (Medical)',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'approved',
    ),
    MockApproval(
      id: 'ap05',
      type: 'Canteen Access',
      requestedBy: 'Parent of Zaheer Hussain',
      details: 'Canteen wallet top-up approval ₹1000',
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: 'approved',
    ),
    MockApproval(
      id: 'ap06',
      type: 'Event Permission',
      requestedBy: 'Kavitha Menon',
      details: 'Off-campus cultural event — March 15',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'rejected',
    ),
  ];
});
