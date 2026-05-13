"""One-off patch script — remove MockData seeded generators (run from repo root)."""
from pathlib import Path


def main() -> None:
    p = Path("lib/core/mock/mock_data.dart")
    t = p.read_text(encoding="utf-8")
    t = t.replace("hodDepartment: 'English',", "hodDepartment: '',")
    t = t.replace(
        "json['hodDepartment'] as String? ??\n          'English',",
        "json['hodDepartment'] as String? ??\n          '',",
    )

    start = t.find("  /// Used when `mock_bundle.json` fails to load")
    end = t.find(
        "  /// Loads demo content from `assets/data/mock_bundle.json` (mock / offline mode)."
    )
    if start == -1 or end == -1:
        raise SystemExit(f"markers not found start={start} end={end}")
    insert = "  /// Loads persisted JSON via [applyJsonBundle] (no seeded defaults).\n"
    t = t[:start] + insert + t[end:]
    t = t.replace(
        "  /// Loads persisted JSON via [applyJsonBundle] (no seeded defaults).\n"
        "  /// Loads demo content from `assets/data/mock_bundle.json` (mock / offline mode).\n",
        "  /// Loads persisted JSON via [applyJsonBundle] (no seeded defaults).\n",
    )

    t = t.replace(
        """    if (rawAtt is List && rawAtt.isNotEmpty) {
      attendance = rawAtt
          .map(
            (e) =>
                MockAttendanceDay.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } else {
      attendance = _buildDefaultAttendance();
    }""",
        """    attendance = rawAtt is List && rawAtt.isNotEmpty
        ? rawAtt
              .map(
                (e) => MockAttendanceDay.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList()
        : <MockAttendanceDay>[];""",
    )
    t = t.replace(
        """    if (rawDiary is List && rawDiary.isNotEmpty) {
      diary = rawDiary
          .map(
            (e) => MockDiaryEntry.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } else {
      diary = _buildDefaultDiary();
    }""",
        """    diary = rawDiary is List && rawDiary.isNotEmpty
        ? rawDiary
              .map(
                (e) => MockDiaryEntry.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList()
        : <MockDiaryEntry>[];""",
    )
    t = t.replace(
        """    if (rawSess is List && rawSess.isNotEmpty) {
      attendanceSessions = rawSess
          .map(
            (e) => MockAttendanceSession.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } else {
      attendanceSessions = _buildAttendanceSessionsFromTimetable();
    }""",
        """    attendanceSessions = rawSess is List && rawSess.isNotEmpty
        ? rawSess
              .map(
                (e) => MockAttendanceSession.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList()
        : <MockAttendanceSession>[];""",
    )

    p.write_text(t, encoding="utf-8")
    print("patched", p)


if __name__ == "__main__":
    main()
