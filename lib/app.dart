import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_glass_theme.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_mode_provider.dart';
import 'features/tenant/providers/tenant_provider.dart';
import 'routing/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Resolved tenant profile drives colors and locale at runtime.
    // Falls back to default NammaClass palette while the profile is loading.
    final tenant = ref.watch(tenantProfileProvider);
    final primary = Color(tenant.primaryColorValue);
    final accent = Color(tenant.accentColorValue);

    // First language in the tenant's list is the default locale.
    final localeTag = tenant.languages.isNotEmpty
        ? tenant.languages.first
        : 'en';
    final parts = localeTag.split('_');
    final locale = Locale(parts[0], parts.length > 1 ? parts[1] : null);

    return MaterialApp.router(
      title: tenant.institutionName.isNotEmpty
          ? tenant.institutionName
          : 'NammaClass',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildLight(primary: primary, accent: accent),
      darkTheme: AppTheme.buildDark(primary: primary, accent: accent),
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppGlassTheme.backgroundGradientDark
                : AppGlassTheme.backgroundGradientLight,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
