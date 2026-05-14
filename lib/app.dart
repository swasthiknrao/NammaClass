import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_glass_theme.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_presets.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/providers/theme_preset_provider.dart';
import 'features/tenant/providers/tenant_provider.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final fontScale = ref.watch(fontScaleProvider);

    // Selected theme preset overrides tenant colors.
    // Falls back to tenant/default palette when preset is loading.
    final presetAsync = ref.watch(themePresetProvider);
    final presetId = presetAsync.valueOrNull ?? AppThemePresets.oceanBlue.id;
    final preset = AppThemePresets.byId(presetId);

    final tenant = ref.watch(tenantProfileProvider);
    final primary = preset.primaryColor;
    final accent = preset.accentColor;
    final themeTokens = preset.tokens;

    // First language in the tenant's list is the default locale.
    final localeTag = tenant.languages.isNotEmpty
        ? tenant.languages.first
        : 'en';
    final parts = localeTag.split('_');
    var locale = Locale(parts[0], parts.length > 1 ? parts[1] : null);
    // App-generated l10n only ships en / hi / kn — avoid a null AppLocalizations tree.
    const l10nCodes = {'en', 'hi', 'kn'};
    if (!l10nCodes.contains(locale.languageCode)) {
      locale = const Locale('en');
    }

    return MaterialApp.router(
      title: tenant.institutionName.isNotEmpty
          ? tenant.institutionName
          : 'NammaClass',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildLight(
        primary: primary,
        accent: accent,
        tokens: themeTokens,
      ),
      darkTheme: AppTheme.buildDark(
        primary: primary,
        accent: accent,
        tokens: themeTokens,
      ),
      themeMode: themeMode,
      routerConfig: router,

      // Localization
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('kn'),
        Locale('hi'),
        Locale('ta'),
      ],
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(fontScale)),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppGlassTheme.backgroundGradientDark
                  : AppGlassTheme.backgroundGradientLight,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
