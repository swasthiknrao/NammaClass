import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_input.dart';
import '../../../core/widgets/shell_layout_scope.dart';

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
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipientCount =
        _audiences.contains('All Staff') || _audiences.length == 3
        ? 1335
        : _audiences.length * 350;

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Broadcast Message')),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
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

            // Audience chips
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
                  // Recipient count badge
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
                      '~$recipientCount recipients',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Channels
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

            // Schedule toggle
            NcCard(
              child: SwitchListTile(
                value: _schedule,
                onChanged: (v) => setState(() => _schedule = v),
                title: Text(
                  'Schedule for later',
                  style: AppTypography.labelLarge,
                ),
                subtitle: Text(
                  'Send at a specific time',
                  style: AppTypography.bodySmall,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            NcPrimaryButton(
              label: _schedule ? 'Schedule Broadcast' : 'Send Now',
              fullWidth: true,
              icon: Icons.send,
              loading: _sending,
              onPressed: () async {
                setState(() => _sending = true);
                await Future.delayed(const Duration(seconds: 1));
                if (!mounted) return;
                setState(() => _sending = false);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Broadcast sent successfully!')),
                );
                _titleController.clear();
                _bodyController.clear();
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
