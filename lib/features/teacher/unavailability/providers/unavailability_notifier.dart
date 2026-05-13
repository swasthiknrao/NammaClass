import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/entities/unavailability_request_entry.dart';

class UnavailabilityNotifier
    extends StateNotifier<List<UnavailabilityRequestEntry>> {
  UnavailabilityNotifier() : super(const []);

  static const _uuid = Uuid();

  void submit({
    required String staffId,
    required String staffName,
    required DateTime date,
    required List<String> periodLabels,
    required String reason,
  }) {
    state = [
      UnavailabilityRequestEntry(
        id: _uuid.v4(),
        staffId: staffId,
        staffName: staffName,
        date: DateTime(date.year, date.month, date.day),
        periodLabels: List.from(periodLabels),
        reason: reason.trim(),
      ),
      ...state,
    ];
  }

  void setStatus(String id, UnavailabilityStatus status) {
    state = [
      for (final r in state) r.id == id ? r.copyWith(status: status) : r,
    ];
  }

  List<UnavailabilityRequestEntry> forStaff(String staffId) {
    return state.where((e) => e.staffId == staffId).toList();
  }

  List<UnavailabilityRequestEntry> pending() {
    return state
        .where((e) => e.status == UnavailabilityStatus.pending)
        .toList();
  }
}

final unavailabilityNotifierProvider =
    StateNotifierProvider<
      UnavailabilityNotifier,
      List<UnavailabilityRequestEntry>
    >((ref) => UnavailabilityNotifier());
