import '../entities/diary_entity.dart';

/// Contract for reading and writing class diary entries.
abstract class DiaryRepository {
  /// Returns diary entries for [classSection] between [from] and [to].
  Future<List<DiaryEntry>> getEntries({
    required String classSection,
    required DateTime from,
    required DateTime to,
  });

  /// Teacher: creates or updates a diary entry.
  /// The returned [DiaryEntry] has the server-assigned [id].
  Future<DiaryEntry> saveEntry(DiaryEntry entry);

  /// Student/Parent: marks homework as complete locally (synced later).
  Future<void> markHomeworkComplete(String entryId);
}
