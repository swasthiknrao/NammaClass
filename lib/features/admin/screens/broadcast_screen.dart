import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_input.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../shared/notifications/notification_service.dart';

class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final Set<String> _audiences = {'Parents'};
  final Set<String> _channels = {'App Notification'};
  bool _schedule = false;
  bool _sending = false;

  final _audienceOptions = ['Parents', 'Teachers', 'Students', 'All Staff'];
  final _channelOptions = ['App Notification', 'SMS', 'Email'];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    _bodyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  int get _recipientCount =>
      _audiences.contains('All Staff') || _audiences.length == 3
      ? 1335
      : _audiences.length * 350;

  Future<void> _send() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and message')),
      );
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (_channels.contains('App Notification')) {
      ref
          .read(notificationServiceProvider.notifier)
          .prependNotice(
            MockNotice(
              id: 'bc_${const Uuid().v4()}',
              title: title,
              body: body,
              date: DateTime.now(),
              category: 'Broadcast',
              isRead: false,
            ),
          );
    }
    setState(() => _sending = false);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Broadcast sent successfully!')),
    );
    _titleController.clear();
    _bodyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isWide =
        ScreenSize.isDesktop(context) || ScreenSize.isTablet(context);

    final composer = _composerColumn(context);
    final preview = _BroadcastPreviewCard(
      title: _titleController.text,
      body: _bodyController.text,
      audiences: _audiences,
      channels: _channels,
      recipientCount: _recipientCount,
    );

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Broadcast Message')),
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, c) {
          final twoPane = isWide && c.maxWidth >= 960;
          if (!twoPane) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  composer,
                  const SizedBox(height: AppSpacing.md),
                  preview,
                  const SizedBox(height: AppSpacing.lg),
                  NcPrimaryButton(
                    label: _schedule ? 'Schedule Broadcast' : 'Send Now',
                    fullWidth: true,
                    icon: Icons.send,
                    loading: _sending,
                    onPressed: _send,
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        composer,
                        const SizedBox(height: AppSpacing.lg),
                        NcPrimaryButton(
                          label: _schedule ? 'Schedule Broadcast' : 'Send Now',
                          fullWidth: true,
                          icon: Icons.send,
                          loading: _sending,
                          onPressed: _send,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(flex: 4, child: SingleChildScrollView(child: preview)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _composerColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NcCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notice Details', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              NcTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter notice title…',
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              NcTextField(
                controller: _bodyController,
                label: 'Message Body',
                hint: 'Write your message here…',
                maxLines: 5,
                minLines: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        NcCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Target Audience', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: _audienceOptions
                    .map(
                      (a) => NcChip(
                        label: a,
                        selected: _audiences.contains(a),
                        onTap: () => setState(() {
                          if (_audiences.contains(a)) {
                            _audiences.remove(a);
                          } else {
                            _audiences.add(a);
                          }
                        }),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.xxl),
                ),
                child: Text(
                  '~$_recipientCount recipients',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        NcCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery Channels', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              ..._channelOptions.map(
                (ch) => CheckboxListTile(
                  value: _channels.contains(ch),
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _channels.add(ch);
                    } else {
                      _channels.remove(ch);
                    }
                  }),
                  title: Text(ch, style: AppTypography.bodyMedium),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        NcCard(
          child: SwitchListTile(
            value: _schedule,
            onChanged: (v) => setState(() => _schedule = v),
            title: Text('Schedule for later', style: AppTypography.labelLarge),
            subtitle: Text(
              'Send at a specific time',
              style: AppTypography.bodySmall,
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _BroadcastPreviewCard extends StatelessWidget {
  const _BroadcastPreviewCard({
    required this.title,
    required this.body,
    required this.audiences,
    required this.channels,
    required this.recipientCount,
  });

  final String title;
  final String body;
  final Set<String> audiences;
  final Set<String> channels;
  final int recipientCount;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.teal.withValues(alpha: 0.12),
          AppColors.primary.withValues(alpha: 0.06),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview_outlined, color: AppColors.teal),
              const SizedBox(width: AppSpacing.sm),
              Text('Live preview', style: AppTypography.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title.isEmpty ? 'Title appears here' : title,
            style: AppTypography.headlineSmall.copyWith(
              color: title.isEmpty ? AppColors.textSecondary : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body.isEmpty ? 'Message body…' : body,
            style: AppTypography.bodyMedium.copyWith(
              color: body.isEmpty ? AppColors.textSecondary : null,
              height: 1.4,
            ),
          ),
          const Divider(height: AppSpacing.lg),
          Text('To: ${audiences.join(', ')}', style: AppTypography.labelSmall),
          const SizedBox(height: 4),
          Text('Via: ${channels.join(', ')}', style: AppTypography.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '~$recipientCount recipients',
            style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
