import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/services/app_logger.dart';
import '../../../domain/entities/registered_college.dart';
import '../../tenant/providers/tenant_provider.dart';
import 'platform_registry_seed_colleges.dart';

/// Super Admin **college store**: single source of truth is [RegisteredCollege]
/// JSON in `platform_college_registry.json` on disk (read on startup, written on
/// every change). List, detail, dashboard, and add-college all go through this
/// notifier — there is no parallel in-memory college database.
final platformCollegeRegistryProvider =
    AsyncNotifierProvider<
      PlatformCollegeRegistryNotifier,
      List<RegisteredCollege>
    >(PlatformCollegeRegistryNotifier.new);

class PlatformCollegeRegistryNotifier
    extends AsyncNotifier<List<RegisteredCollege>> {
  static const _fileName = 'platform_college_registry.json';

  /// First path that successfully read or wrote this session (avoids split-brain).
  String? _sessionRegistryPath;

  @override
  Future<List<RegisteredCollege>> build() async {
    final fromDisk = await _readFile();
    if (fromDisk.isNotEmpty) return fromDisk;

    final seed = ref.read(tenantProfileProvider);
    final demos = buildPlatformRegistrySeedColleges();
    final bootstrap = <RegisteredCollege>[
      RegisteredCollege(
        profile: seed,
        users: const [],
        status: CollegeProvisioningStatus.live,
        createdAt: DateTime.now(),
      ),
      ...demos.where((c) => c.tenantId != seed.tenantId),
    ];
    try {
      await _writeFile(bootstrap);
    } catch (e, st) {
      AppLogger.instance.error(
        'PlatformCollegeRegistry bootstrap write skipped (in-memory only)',
        e,
        st,
      );
    }
    return bootstrap;
  }

  /// Ordered discovery: session hint, Documents (legacy), app support, LocalAppData vault.
  Future<List<File>> _registryFileCandidates({
    bool preferSessionFirst = true,
  }) async {
    final out = <File>[];
    void add(File f) => out.add(f);

    if (preferSessionFirst &&
        _sessionRegistryPath != null &&
        _sessionRegistryPath!.isNotEmpty) {
      add(File(_sessionRegistryPath!));
    }

    try {
      final d = await getApplicationDocumentsDirectory();
      add(File(p.join(d.path, _fileName)));
    } catch (e, st) {
      AppLogger.instance.debug('getApplicationDocumentsDirectory', e, st);
    }

    try {
      final s = await getApplicationSupportDirectory();
      add(File(p.join(s.path, 'nammaclass', _fileName)));
    } catch (e, st) {
      AppLogger.instance.debug('getApplicationSupportDirectory', e, st);
    }

    final local = Platform.environment['LOCALAPPDATA'];
    if (local != null && local.isNotEmpty) {
      add(File(p.join(local, 'NammaClass', _fileName)));
    }
    final profile = Platform.environment['USERPROFILE'];
    if (profile != null && profile.isNotEmpty) {
      add(File(p.join(profile, 'AppData', 'Local', 'NammaClass', _fileName)));
    }

    return _dedupeFiles(out);
  }

  List<File> _dedupeFiles(List<File> files) {
    final seen = <String>{};
    final result = <File>[];
    for (final f in files) {
      final key = p.normalize(f.absolute.path).toLowerCase();
      if (seen.add(key)) result.add(f);
    }
    return result;
  }

  List<RegisteredCollege>? _decodeList(String text) {
    try {
      final raw = jsonDecode(text);
      if (raw is! List) return null;
      return raw
          .map(
            (e) =>
                RegisteredCollege.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<List<RegisteredCollege>> _readFile() async {
    try {
      List<RegisteredCollege>? best;
      var bestM = DateTime.fromMillisecondsSinceEpoch(0);

      for (final file in await _registryFileCandidates()) {
        try {
          if (!await file.exists()) continue;
          final stat = await file.stat();
          final text = await file.readAsString();
          final list = _decodeList(text);
          if (list == null || list.isEmpty) continue;
          if (stat.modified.isAfter(bestM)) {
            bestM = stat.modified;
            best = list;
            _sessionRegistryPath = file.path;
          }
        } on PathNotFoundException {
          continue;
        } on FileSystemException catch (e) {
          final code = e.osError?.errorCode;
          if (code == 2 ||
              e.message.toLowerCase().contains('cannot open file') ||
              e.message.toLowerCase().contains('no such file')) {
            continue;
          }
          AppLogger.instance.debug('PlatformCollegeRegistry read try', e);
        }
      }
      return best ?? [];
    } catch (e, st) {
      AppLogger.instance.debug('PlatformCollegeRegistry read', e, st);
      return [];
    }
  }

  Future<void> _writeFile(List<RegisteredCollege> list) async {
    final payload = JsonEncoder.withIndent(
      '  ',
    ).convert(list.map((e) => e.toJson()).toList());

    Object? lastError;
    StackTrace? lastSt;

    for (final file in await _registryFileCandidates()) {
      try {
        await file.parent.create(recursive: true);
        await file.writeAsString(payload);
        _sessionRegistryPath = file.path;
        return;
      } catch (e, st) {
        lastError = e;
        lastSt = st;
        AppLogger.instance.debug(
          'PlatformCollegeRegistry write try ${file.path}',
          e,
          st,
        );
      }
    }

    AppLogger.instance.error(
      'PlatformCollegeRegistry write failed (all locations)',
      lastError,
      lastSt,
    );
    if (lastError != null) {
      Error.throwWithStackTrace(lastError, lastSt ?? StackTrace.empty);
    }
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
    try {
      await _writeFile(list);
    } catch (e, st) {
      AppLogger.instance.error('PlatformCollegeRegistry persist failed', e, st);
    }
  }

  /// Re-read [platform_college_registry.json] from disk (e.g. after manual edit
  /// or sync). Replaces the in-memory list with whatever the file contains.
  Future<void> reloadFromDisk() async {
    final list = await _readFile();
    state = AsyncData(list);
  }

  /// Remove a college row and persist the updated list to JSON.
  Future<void> removeCollege(String tenantId) async {
    final prev = await future;
    final list = prev.where((c) => c.tenantId != tenantId).toList();
    if (list.length == prev.length) return;
    state = AsyncData(list);
    try {
      await _writeFile(list);
    } catch (e, st) {
      AppLogger.instance.error('PlatformCollegeRegistry persist failed', e, st);
    }
  }

  /// Appends [buildPlatformRegistrySeedColleges] rows whose `tenantId` is not
  /// already in the registry, then writes JSON. Safe to call multiple times.
  Future<void> mergeSeedCollegesIfAbsent() async {
    final prev = await future;
    final ids = prev.map((c) => c.tenantId).toSet();
    final demos = buildPlatformRegistrySeedColleges();
    final toAdd = demos.where((c) => !ids.contains(c.tenantId)).toList();
    if (toAdd.isEmpty) return;
    final list = [...prev, ...toAdd];
    state = AsyncData(list);
    try {
      await _writeFile(list);
    } catch (e, st) {
      AppLogger.instance.error('PlatformCollegeRegistry persist failed', e, st);
    }
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
    try {
      await _writeFile(list);
    } catch (e, st) {
      AppLogger.instance.error('PlatformCollegeRegistry persist failed', e, st);
    }
  }
}
