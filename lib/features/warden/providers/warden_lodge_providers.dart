import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';

final hostelDeskInfoProvider = Provider<Map<String, dynamic>>((ref) {
  ref.watch(dataSyncProvider);
  return Map<String, dynamic>.from(MockData.hostelDeskInfo);
});

final wardenDiningRoundsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  ref.watch(dataSyncProvider);
  return List<Map<String, dynamic>>.from(MockData.wardenDiningRounds);
});

final wardenRoomHousekeepingProvider = Provider<List<Map<String, dynamic>>>((
  ref,
) {
  ref.watch(dataSyncProvider);
  return List<Map<String, dynamic>>.from(MockData.wardenRoomHousekeeping);
});

final wardenPatrolChecklistProvider = Provider<Map<String, bool>>((ref) {
  ref.watch(dataSyncProvider);
  return Map<String, bool>.from(MockData.wardenPatrolChecklist);
});

final wardenConciergeLogProvider = Provider<List<Map<String, dynamic>>>((ref) {
  ref.watch(dataSyncProvider);
  return List<Map<String, dynamic>>.from(MockData.wardenConciergeLog);
});
