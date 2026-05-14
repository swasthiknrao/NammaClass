import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Distance from **parent** bottom-right where the FAB sits (session memory).
class NammaAiFabAnchor {
  const NammaAiFabAnchor({required this.fromRight, required this.fromBottom});

  final double fromRight;
  final double fromBottom;

  NammaAiFabAnchor clamp({
    required double minRight,
    required double maxRight,
    required double minBottom,
    required double maxBottom,
  }) {
    return NammaAiFabAnchor(
      fromRight: fromRight.clamp(minRight, maxRight),
      fromBottom: fromBottom.clamp(minBottom, maxBottom),
    );
  }
}

class NammaAiFabAnchorNotifier extends StateNotifier<NammaAiFabAnchor?> {
  NammaAiFabAnchorNotifier() : super(null);

  void reset() => state = null;

  void setAnchor(NammaAiFabAnchor anchor) => state = anchor;
}

final nammaAiFabAnchorProvider =
    StateNotifierProvider<NammaAiFabAnchorNotifier, NammaAiFabAnchor?>(
      (ref) => NammaAiFabAnchorNotifier(),
    );
