/// Max data sensitivity a role may receive through AI tools (server enforces).
enum AiSensitivityTier {
  /// Public notices, generic tips.
  tierPublic,

  /// Operational aggregates without personal identifiers.
  tierInternal,

  /// Student/staff identifiers combined with performance or fees.
  tierConfidential,
}

extension AiSensitivityTierX on AiSensitivityTier {
  static AiSensitivityTier fromName(String? s) {
    switch (s) {
      case 'public':
        return AiSensitivityTier.tierPublic;
      case 'internal':
        return AiSensitivityTier.tierInternal;
      case 'confidential':
      default:
        return AiSensitivityTier.tierConfidential;
    }
  }
}
