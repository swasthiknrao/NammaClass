import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<File> _bundleFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/namaclass_user_bundle.json');
}

Future<Map<String, dynamic>> loadUserBundleMap() async {
  try {
    final f = await _bundleFile();
    if (!await f.exists()) return {};
    final text = await f.readAsString();
    if (text.trim().isEmpty) return {};
    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  } catch (_) {}
  return {};
}

Future<void> saveUserBundleMap(Map<String, dynamic> data) async {
  try {
    final f = await _bundleFile();
    await f.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  } catch (_) {}
}
