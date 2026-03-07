import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';

/// Simulated async providers for web portal screens.
/// Replace Future.delayed with real API calls when backend is ready.

// ── Admissions ────────────────────────────────────────────────────────────────

final webAdmissionEnquiriesProvider =
    FutureProvider<List<MockAdmissionEnquiry>>((ref) async {
      await Future.delayed(const Duration(milliseconds: 150));
      return MockData.admissionEnquiries;
    });

// ── Finance ───────────────────────────────────────────────────────────────────

final webAssetsProvider = FutureProvider<List<MockAsset>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.assets;
});

// ── Transport ─────────────────────────────────────────────────────────────────

final webBusStopsProvider = FutureProvider<List<MockBusStop>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.busStops;
});

// ── Library ───────────────────────────────────────────────────────────────────

final webBookIssuesProvider = FutureProvider<List<MockBookIssue>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.bookIssues;
});

final webReservationsProvider = FutureProvider<List<MockReservation>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.reservations;
});
