import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/env_config.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tenant/providers/tenant_provider.dart';
import '../data/namma_ai_gateway_client.dart';
import '../providers/namma_ai_providers.dart';
import 'fee_buckets_chart.dart';
import 'scope_chip_bar.dart';

final nammaAiGatewayClientProvider = Provider.autoDispose(
  (ref) => NammaAiGatewayClient(),
);

class _ChatMessage {
  _ChatMessage({required this.isUser, required this.text, this.toolResults});

  final bool isUser;
  final String text;
  final List<dynamic>? toolResults;
}

/// Shared chat body for full-screen route and side panel.
class NammaAiChatView extends ConsumerStatefulWidget {
  const NammaAiChatView({
    super.key,
    this.embedded = false,
    this.compactPadding = false,
  });

  final bool embedded;
  final bool compactPadding;

  @override
  ConsumerState<NammaAiChatView> createState() => _NammaAiChatViewState();
}

class _NammaAiChatViewState extends ConsumerState<NammaAiChatView> {
  final _scroll = ScrollController();
  final _input = TextEditingController();
  final _uuid = const Uuid();
  late String _convoId;
  final _messages = <_ChatMessage>[];
  var _streaming = '';
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _convoId = _uuid.v4();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _busy) return;
    final ctxMap = ref.read(nammaAiContextMapProvider);
    if (ctxMap.isEmpty) return;

    setState(() {
      _busy = true;
      _messages.add(_ChatMessage(isUser: true, text: text));
      _streaming = '';
    });
    _input.clear();
    _scrollBottom();

    final client = ref.read(nammaAiGatewayClientProvider);
    final buf = StringBuffer();
    List<dynamic>? lastTools;

    try {
      await for (final ev in client.chatStream(
        message: text,
        context: ctxMap,
        conversationId: _convoId,
      )) {
        switch (ev) {
          case NammaAiScopeEvent():
            break;
          case NammaAiToolResultEvent(:final results):
            lastTools = results;
          case NammaAiTokenEvent(:final text):
            buf.write(text);
            setState(() => _streaming = buf.toString());
            _scrollBottom();
          case NammaAiDoneEvent():
            break;
        }
      }
      setState(() {
        _messages.add(
          _ChatMessage(
            isUser: false,
            text: buf.toString().trim().isEmpty
                ? 'No response from Namma AI Gateway.'
                : buf.toString(),
            toolResults: lastTools,
          ),
        );
        _streaming = '';
        _busy = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage(
            isUser: false,
            text:
                'Could not reach Namma AI Gateway (${EnvConfig.nammaAiBaseUrl.isEmpty ? 'default http://127.0.0.1:8787' : EnvConfig.nammaAiBaseUrl}).\n'
                'Start the service: `cd services/namma_ai_gateway && npm start`\n\n$e',
            toolResults: null,
          ),
        );
        _streaming = '';
        _busy = false;
      });
    }
    _scrollBottom();
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final tenant = ref.watch(tenantProfileProvider);
    final policy = ref.watch(nammaAiPolicyProvider);
    final theme = Theme.of(context);
    final pad = widget.compactPadding ? AppSpacing.sm : AppSpacing.md;

    if (user == null) {
      return const Center(child: Text('Sign in to use Namma AI.'));
    }

    final wardHint = user.role == UserRole.parent && user.studentId != null
        ? 'Linked student: ${user.studentId}'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!NammaAiGatewayClient.isConfigured)
          Container(
            width: double.infinity,
            color: AppColors.warning.withValues(alpha: 0.12),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              'Gateway: ${EnvConfig.nammaAiBaseUrl.isEmpty ? '127.0.0.1:8787' : EnvConfig.nammaAiBaseUrl}',
              style: AppTypography.labelSmall,
            ),
          ),
        NammaAiScopeChipBar(
          role: user.role,
          rowScope: policy.rowScope,
          tenantName: tenant.institutionName,
          branchLabel: user.branchId,
          wardHint: wardHint,
        ),
        if (!policy.hasAnyTools)
          Padding(
            padding: EdgeInsets.all(pad),
            child: Text(
              'Namma AI has no tools for this account or ai_insights is off.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.3),
                  theme.colorScheme.surfaceContainerLowest.withValues(
                    alpha: 0.5,
                  ),
                ],
              ),
            ),
            child: ListView.builder(
              controller: _scroll,
              padding: EdgeInsets.fromLTRB(pad, AppSpacing.sm, pad, pad),
              itemCount: _messages.length + (_streaming.isNotEmpty ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length && _streaming.isNotEmpty) {
                  return _AiTypingBubble(text: _streaming);
                }
                final m = _messages[i];
                return _MessageBubble(
                      isUser: m.isUser,
                      text: m.text,
                      toolResults: m.toolResults,
                    )
                    .animate(delay: (i * 30).ms)
                    .fadeIn(duration: 200.ms)
                    .slideY(begin: 0.06, end: 0);
              },
            ),
          ),
        ),
        _quickActions(pad),
        _inputBar(theme, pad),
      ],
    );
  }

  Widget _quickActions(double pad) {
    final chips = [
      ('Attendance', 'Summarize attendance for my scope'),
      ('Fees', 'Show fee aging summary'),
      ('Health', 'Give institutional health snapshot'),
      ('Notice', 'Draft a parent notice about PTM'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(pad, 0, pad, AppSpacing.xs),
      child: Row(
        children: [
          for (final c in chips)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Material(
                color: Colors.transparent,
                child: ActionChip(
                  avatar: Icon(
                    Icons.bolt_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(c.$1, style: AppTypography.labelMedium),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.35),
                  ),
                  onPressed: _busy ? null : () => _send(c.$2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _inputBar(ThemeData theme, double pad) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, AppSpacing.xs, pad, AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(_input.text),
                decoration: InputDecoration(
                  hintText: 'Message Namma AI…',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.85),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(14),
                shape: const CircleBorder(),
              ),
              onPressed: _busy ? null : () => _send(_input.text),
              child: _busy
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.arrow_upward_rounded, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiTypingBubble extends StatelessWidget {
  const _AiTypingBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
          ),
          border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 20,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text.isEmpty ? '…' : text,
                style: AppTypography.bodyMedium.copyWith(height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.isUser,
    required this.text,
    this.toolResults,
  });

  final bool isUser;
  final String text;
  final List<dynamic>? toolResults;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(6),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SelectableText(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onPrimary,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
          ),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SelectableText(
                    text,
                    style: AppTypography.bodyMedium.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
            if (toolResults != null) _ToolCards(toolResults: toolResults!),
          ],
        ),
      ),
    );
  }
}

class _ToolCards extends StatelessWidget {
  const _ToolCards({required this.toolResults});

  final List<dynamic> toolResults;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Insights',
          style: AppTypography.labelLarge.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        for (final r in toolResults)
          if (r is Map<String, dynamic>) ...[
            const SizedBox(height: AppSpacing.xs),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${r['tool'] ?? 'result'}',
                      style: AppTypography.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.entries
                          .where((e) => e.key != 'tool')
                          .map((e) => '${e.key}: ${e.value}')
                          .join('\n'),
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (r['buckets'] is List)
              NammaAiFeeBucketsChart(
                buckets: (r['buckets'] as List)
                    .whereType<Map>()
                    .map((e) => Map<String, dynamic>.from(e))
                    .toList(),
              ),
          ],
      ],
    );
  }
}
