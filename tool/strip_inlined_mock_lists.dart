// One-off: removes duplicated mock lists now served from mock_bundle.json.
import 'dart:io';

void main() {
  final f = File('lib/core/mock/mock_data.dart');
  var s = f.readAsStringSync();
  const startMark =
      '  // ── 35 Students (moved to assets/data/mock_bundle.json)';
  const endMark = '  // ── Timetable (5 days × 8 periods)';
  final start = s.indexOf(startMark);
  final end = s.indexOf(endMark);
  if (start == -1 || end == -1) {
    stderr.writeln('Markers not found (already stripped?)');
    exit(1);
  }
  f.writeAsStringSync(s.substring(0, start) + s.substring(end));
  // ignore: avoid_print
  print('Stripped inlined students..notices block.');
}
