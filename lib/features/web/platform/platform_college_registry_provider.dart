import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/services/app_logger.dart';
import '../../../domain/entities/registered_college.dart';
import '../../tenant/providers/tenant_provider.dart';

/// Persisted multi-tenant registry for Super Admin (local disk until API exists).
final platformCollegeRegistryProvider =
    AsyncNotifierProvider<
      PlatformCollegeRegistryNotifier,
      List<RegisteredCollege>
    >(PlatformCollegeRegistryNotifier.new);

class PlatformCollegeRegistryNotifier
    extends AsyncNotifier<List<RegisteredCollege>> {
  static const _fileName = 'platform_college_registry.json';

  @override
  Future<List<RegisteredCollege>> build() async {
    final fromDisk = await _readFile();
    if (fromDisk.isNotEmpty) return fromDisk;

    final seed = ref.read(tenantProfileProvider);
    final bootstrap = [
      RegisteredCollege(
        profile: seed,
        users: const [],
        status: CollegeProvisioningStatus.live,
        createdAt: DateTime.now(),
      ),
    ];
    await _writeFile(bootstrap);
    return bootstrap;
  }

  Future<List<RegisteredCollege>> _readFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = p.join(dir.path, _fileName);
      final file = File(filePath);
      final String text;
      try {
        text = await file.readAsString();
      } on FileSystemException catch (e) {
        final code = e.osError?.errorCode;
        // Windows: 2 = file not found; treat missing/unreadable registry as empty.
        if (code == 2 ||
            (e.message.toLowerCase().contains('cannot open file')) ||
            (e.message.toLowerCase().contains('no such file'))) {
          return [];
        }
        AppLogger.instance.warn('PlatformCollegeRegistry read', e);
        return [];
      }

      final raw = jsonDecode(text);
      if (raw is! List) return [];
      return raw
          .map(
            (e) =>
                RegisteredCollege.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (e, st) {
      AppLogger.instance.debug('PlatformCollegeRegistry read', e, st);
      return [];
    }
  }

  Future<void> _writeFile(List<RegisteredCollege> list) async {
    final dir = await getApplicationDocumentsDirectory();
    await Directory(dir.path).create(recursive: true);
    final file = File(p.join(dir.path, _fileName));
    await file.writeAsString(
      JsonEncoder.withIndent(
        '  ',
      ).convert(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> upsertCollege(RegisteredCollege college) async {
    final prev = await future;
    final list = [...prev];
    final i = list.indexWhere((c) => c.tenantId == college.tenantId);
    if (i >= 0) {
      list[i] = college.copyWith(updatedAt: DateTime.now());
    } else {
      list.add(college);
    }
    state = AsyncData(list);
    await _writeFile(list);
  }

  Future<void> replaceUsers(
    String tenantId,
    List<CollegeInstitutionUser> users,
  ) async {
    final prev = await future;
    final list = prev.map((c) {
      if (c.tenantId != tenantId) return c;
      return c.copyWith(users: users, updatedAt: DateTime.now());
    }).toList();
    state = AsyncData(list);
    await _writeFile(list);
  }
}
