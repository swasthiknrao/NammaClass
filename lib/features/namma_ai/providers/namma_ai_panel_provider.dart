import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Side panel visibility and expanded width for Namma AI.
class NammaAiPanelState {
  const NammaAiPanelState({this.visible = false, this.expanded = false});

  final bool visible;
  final bool expanded;

  NammaAiPanelState copyWith({bool? visible, bool? expanded}) {
    return NammaAiPanelState(
      visible: visible ?? this.visible,
      expanded: expanded ?? this.expanded,
    );
  }
}

class NammaAiPanelNotifier extends StateNotifier<NammaAiPanelState> {
  NammaAiPanelNotifier() : super(const NammaAiPanelState());

  void open() => state = state.copyWith(visible: true, expanded: false);

  void close() => state = const NammaAiPanelState();

  void toggleExpand() => state = state.copyWith(expanded: !state.expanded);
}

final nammaAiPanelProvider =
    StateNotifierProvider<NammaAiPanelNotifier, NammaAiPanelState>(
      (ref) => NammaAiPanelNotifier(),
    );
