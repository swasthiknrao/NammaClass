// Writes assets/data/mock_bundle.json using [MockData.exportFullBundleForJson].
// If that file already exists, loads it into [MockData] first (same behaviour as
// export_full_mock_bundle.dart).
//
//   dart run tool/extract_mock_bundle.dart
import 'dart:convert';
import 'dart:io';

import 'package:nammaclass/core/mock/mock_data.dart';

void main() {
  final path = File('assets/data/mock_bundle.json');
  if (path.existsSync()) {
    try {
      final decoded = jsonDecode(path.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        MockData.applyJsonBundle(decoded);
      } else if (decoded is Map) {
        MockData.applyJsonBundle(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Ignore corrupt JSON — export empty / defaults from MockData.
    }
  }

  final bundle = MockData.exportFullBundleForJson();
  path.parent.createSync(recursive: true);
  path.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(bundle));
  // ignore: avoid_print
  print(
    'Wrote assets/data/mock_bundle.json (${bundle.keys.length} top-level keys)',
  );
  // ignore: avoid_print
  print('Optional: dart run tool/embed_mock_bundle.dart');
}
