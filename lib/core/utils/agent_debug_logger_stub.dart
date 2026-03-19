class AgentDebugLogger {
  static void log({
    required String hypothesisId,
    required String location,
    required String message,
    required Map<String, Object?> data,
    String runId = 'pre-fix',
  }) {
    // No-op (non-IO platforms like web).
  }
}
