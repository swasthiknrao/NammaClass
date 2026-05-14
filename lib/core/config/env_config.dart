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

  /// Namma AI Gateway (SSE). Example: `http://127.0.0.1:8787`
  static const String nammaAiBaseUrl = String.fromEnvironment(
    'NAMMA_AI_BASE_URL',
    defaultValue: '',
  );
}
