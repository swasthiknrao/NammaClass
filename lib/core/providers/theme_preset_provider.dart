import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';
import '../theme/theme_presets.dart';

// ── Font-scale provider ────────────────────────────────────────────────────

/// Text scale factor: 0.9 = small, 1.0 = medium, 1.15 = large.
final fontScaleProvider = StateNotifierProvider<FontScaleNotifier, double>(
  (ref) => FontScaleNotifier(),
);

class FontScaleNotifier extends StateNotifier<double> {
  FontScaleNotifier() : super(1.0) {
    _load();
  }

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> _load() async {
    final saved = await _storage.read(key: StorageKeys.themeFontScale);
    if (saved != null) {
      final v = double.tryParse(saved);
      if (v != null) state = v;
    }
  }

  Future<void> setScale(double scale) async {
    state = scale;
    await _storage.write(
      key: StorageKeys.themeFontScale,
      value: scale.toString(),
    );
  }
}

// ── Theme preset provider ──────────────────────────────────────────────────

/// Holds the selected [AppThemePreset.id]. Persisted to secure storage.
final themePresetProvider = AsyncNotifierProvider<ThemePresetNotifier, String>(
  ThemePresetNotifier.new,
);

class ThemePresetNotifier extends AsyncNotifier<String> {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<String> build() async {
    final saved = await _storage.read(key: StorageKeys.themePresetId);
    return saved ?? AppThemePresets.oceanBlue.id;
  }

  Future<void> select(String presetId) async {
    state = const AsyncLoading();
    await _storage.write(key: StorageKeys.themePresetId, value: presetId);
    state = AsyncData(presetId);
  }
}
