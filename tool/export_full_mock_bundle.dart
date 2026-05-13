// Merges existing mock_bundle.json (bundle slice) with all inlined MockData and
// rewrites assets/data/mock_bundle.json. Run before stripping Dart literals.
//
//   dart run tool/export_full_mock_bundle.dart
import 'dart:convert';
import 'dart:io';

import 'package:nammaclass/core/mock/mock_data.dart';

void main() {
  final path = File('assets/data/mock_bundle.json');
  if (path.existsSync()) {
    MockData.applyJsonBundle(
      jsonDecode(path.readAsStringSync()) as Map<String, dynamic>,
    );
  }
  final map = MockData.exportFullBundleForJson();
  path.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(map));
  // ignore: avoid_print
  print(
    'Wrote assets/data/mock_bundle.json (${map.keys.length} top-level keys)',
  );
}
