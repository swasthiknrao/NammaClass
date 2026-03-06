/// Placeholder for environment-specific config (dev/staging/prod).
/// No secrets or API keys in code; use from env or build config later.
class EnvConfig {
  EnvConfig._();

  static const String env = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  /// Placeholder for API base URL when backend is integrated.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
}
