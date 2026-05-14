import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_input.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../auth/providers/auth_provider.dart';
import '../notifications/notification_service.dart';
import 'messaging_policy.dart';

/// Role-aware composer: announcements, direct multi-select, playbooks.
class SchoolCommsScreen extends ConsumerStatefulWidget {
  const SchoolCommsScreen({super.key, required this.access});

  final SchoolCommsAccess access;

  @override
  ConsumerState<SchoolCommsScreen> createState() => _SchoolCommsScreenState();
}

class _SchoolCommsScreenState extends ConsumerState<SchoolCommsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _searchController = TextEditingController();

  final Set<String> _audiences = {'Parents'};
  final Set<String> _channels = {'App Notification'};
  final Set<String> _selectedRecipientIds = {};
  bool _schedule = false;
  bool _sending = false;
  String? _classFilter;
  String _categoryDraft = 'Broadcast';

  final _audienceOptions = ['Parents', 'Teachers', 'Students', 'All Staff'];
  final _channelOptions = ['App Notification', 'SMS', 'Email'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _titleController.addListener(() => setState(() {}));
    _bodyController.addListener(() => setState(() {}));
    _searchController.addListener(() => setState(() {}));
    if (widget.access == SchoolCommsAccess.teacher) {
      _audiences.removeWhere((a) => !{'Parents', 'Students'}.contains(a));
      if (_audiences.isEmpty) _audiences.add('Parents');
    }
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && _categoryDraft == 'Broadcast') {
      _categoryDraft = 'Message';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String get _appBarTitle {
    switch (widget.access) {
      case SchoolCommsAccess.admin:
        return 'School Pulse';
      case SchoolCommsAccess.principal:
        return 'Principal desk';
      case SchoolCommsAccess.hod:
        return 'Department comms';
      case SchoolCommsAccess.teacher:
        return 'Messages to families';
    }
  }

  List<String> get _classSectionOptions {
    final fromStudents = MockData.students.map((s) => s.classSection).toSet();
    return fromStudents.toList()..sort();
  }

  List<UserModel> get _pickerRecipients {
    final sender = ref.read(currentUserProvider);
    if (sender == null) return const [];
    return MessagingPolicy.visibleRecipients(
      sender: sender,
      access: widget.access,
    );
  }

  List<UserModel> get _filteredPickerRecipients {
    final q = _searchController.text.trim().toLowerCase();
    final base = _pickerRecipients;
    if (q.isEmpty) return base;
    return base
        .where(
          (u) =>
              u.name.toLowerCase().contains(q) ||
              UserModel.roleDisplayLabel(u.role).toLowerCase().contains(q),
        )
        .toList();
  }

  List<String> get _announcementAudienceOptions {
    switch (widget.access) {
      case SchoolCommsAccess.teacher:
        return ['Parents', 'Students'];
      case SchoolCommsAccess.hod:
      case SchoolCommsAccess.admin:
      case SchoolCommsAccess.principal:
        return _audienceOptions;
    }
  }

  List<String> get _effectiveAnnouncementRoleKeys {
    final raw = MessagingPolicy.roleKeysFromAudienceLabels(_audiences);
    return MessagingPolicy.filterAnnouncementKeysForAccess(raw, widget.access);
  }

  int get _announcementRecipientCount {
    final keys = _effectiveAnnouncementRoleKeys;
    if (keys.isEmpty) return 0;
    return MessagingPolicy.estimateAnnouncementRecipients(
      audienceRoleKeys: keys,
      classSection: _classFilter,
    );
  }

  Future<void> _send() async {
    final sender = ref.read(currentUserProvider);
    if (sender == null) return;

    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and message')),
      );
      return;
    }

    if (_schedule) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Scheduling will be available when the server sync is enabled.',
          ),
        ),
      );
      return;
    }

    if (!_channels.contains('App Notification')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('In-app delivery requires "App Notification" enabled.'),
        ),
      );
      return;
    }

    final tab = _tabController.index;
    final effectiveTab = tab == 2 ? 0 : tab;

    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    var sentCount = 0;

    if (effectiveTab == 1) {
      if (_selectedRecipientIds.isEmpty) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one recipient')),
        );
        return;
      }
      final batch = <MockNotice>[];
      for (final id in _selectedRecipientIds) {
        UserModel? recipient;
        for (final u in MessagingPolicy.portalDemoUsers) {
          if (u.id == id) {
            recipient = u;
            break;
          }
        }
        if (recipient == null) continue;
        if (!MessagingPolicy.canSendDirectTo(
          sender: sender,
          access: widget.access,
          recipient: recipient,
        )) {
          continue;
        }
        batch.add(
          MockNotice(
            id: 'dm_${const Uuid().v4()}_$id',
            title: title,
            body: body,
            date: DateTime.now(),
            category: _categoryDraft,
            isRead: false,
            targetUserId: id,
            senderUserId: sender.id,
            senderName: sender.name,
            audienceRoleKeys: const [],
          ),
        );
      }
      if (batch.isEmpty) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid recipients for your role.')),
        );
        return;
      }
      ref.read(notificationServiceProvider.notifier).prependNotices(batch);
      sentCount = batch.length;
    } else {
      final keys = _effectiveAnnouncementRoleKeys;
      if (keys.isEmpty) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pick at least one audience segment')),
        );
        return;
      }
      ref
          .read(notificationServiceProvider.notifier)
          .prependNotice(
            MockNotice(
              id: 'bc_${const Uuid().v4()}',
              title: title,
              body: body,
              date: DateTime.now(),
              category: _categoryDraft,
              isRead: false,
              senderUserId: sender.id,
              senderName: sender.name,
              audienceRoleKeys: keys,
              audienceClassSection: _classFilter,
            ),
          );
      sentCount = 1;
    }

    setState(() => _sending = false);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          effectiveTab == 1
              ? 'Sent to $sentCount recipient(s)'
              : 'Announcement sent successfully!',
        ),
      ),
    );
    _titleController.clear();
    _bodyController.clear();
    _selectedRecipientIds.clear();
    _categoryDraft = 'Broadcast';
  }

  void _applyPlaybook(CommsPlaybook p) {
    _titleController.text = p.title;
    _bodyController.text = p.body;
    _categoryDraft = p.category;
    _tabController.animateTo(0);
    setState(() {});
  }

  IconData _playbookIcon(String name) {
    switch (name) {
      case 'payments':
        return Icons.payments_outlined;
      case 'groups':
        return Icons.groups_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'directions_bus':
        return Icons.directions_bus_outlined;
      case 'local_library':
        return Icons.local_library_outlined;
      default:
        return Icons.auto_awesome_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide =
        ScreenSize.isDesktop(context) || ScreenSize.isTablet(context);
    final sender = ref.watch(currentUserProvider);
    final tabIndex = _tabController.index == 2 ? 0 : _tabController.index;

    final tabsBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sender != null &&
            ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Text(
              '${sender.name} · ${UserModel.roleDisplayLabel(sender.role)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        Material(
          color: Colors.transparent,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Announcements'),
              Tab(text: 'Direct'),
              Tab(text: 'Playbooks'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _announcementsPane(context),
              _directPane(context),
              _playbooksPane(context),
            ],
          ),
        ),
      ],
    );

    final composer = _composerColumn(context);
    final preview = _CommsPreviewCard(
      title: _titleController.text,
      body: _bodyController.text,
      tabIndex: tabIndex,
      audiences: _audiences,
      channels: _channels,
      classFilter: _classFilter,
      recipientCount: _announcementRecipientCount,
      selectedDirect: _selectedRecipientIds.length,
    );

    final sendButton = NcPrimaryButton(
      label: _schedule ? 'Schedule send' : 'Send now',
      fullWidth: true,
      icon: Icons.send,
      loading: _sending,
      onPressed: _send,
    );

    final footer = SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          composer,
          const SizedBox(height: AppSpacing.md),
          preview,
          const SizedBox(height: AppSpacing.lg),
          sendButton,
        ],
      ),
    );

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: Text(_appBarTitle)),
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, c) {
          final twoPane = isWide && c.maxWidth >= 960;
          if (!twoPane) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tabsBlock),
                Flexible(child: footer),
              ],
            );
          }
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Expanded(child: tabsBlock),
                      composer,
                      const SizedBox(height: AppSpacing.md),
                      sendButton,
                    ],
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

  Widget _announcementsPane(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (widget.access == SchoolCommsAccess.principal) ...[
          NcCard(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.teal.withValues(alpha: 0.2),
                child: const Icon(Icons.account_balance, color: AppColors.teal),
              ),
              title: Text(
                'Coordinate with your HOD',
                style: AppTypography.labelLarge,
              ),
              subtitle: Text(
                '${UserModel.hod.name} · ${UserModel.hod.email ?? UserModel.hod.phone}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: const Icon(Icons.chat_bubble_outline),
              onTap: () => setState(() {
                _selectedRecipientIds
                  ..clear()
                  ..add(UserModel.hod.id);
                _tabController.animateTo(1);
                _categoryDraft = 'Message';
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Text(
          'Reach a role or class segment. Recipients see this in Notifications.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: _announcementAudienceOptions
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
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String?>(
          key: ValueKey(_classFilter),
          initialValue: _classFilter,
          decoration: const InputDecoration(
            labelText: 'Limit to class (optional)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All classes'),
            ),
            ..._classSectionOptions.map(
              (s) => DropdownMenuItem<String?>(value: s, child: Text(s)),
            ),
          ],
          onChanged: (v) => setState(() => _classFilter = v),
        ),
      ],
    );
  }

  Widget _directPane(BuildContext context) {
    final rows = _filteredPickerRecipients;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search by name or role…',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Text(
                    'No recipients available for your role.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (context, i) {
                    final u = rows[i];
                    final sel = _selectedRecipientIds.contains(u.id);
                    return CheckboxListTile(
                      value: sel,
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _selectedRecipientIds.add(u.id);
                        } else {
                          _selectedRecipientIds.remove(u.id);
                        }
                      }),
                      title: Text(u.name, style: AppTypography.labelLarge),
                      subtitle: Text(UserModel.roleDisplayLabel(u.role)),
                      secondary: u.classSection != null
                          ? Text(
                              u.classSection!,
                              style: AppTypography.labelSmall,
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _playbooksPane(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.15,
      ),
      itemCount: MessagingPolicy.playbooks.length,
      itemBuilder: (context, i) {
        final p = MessagingPolicy.playbooks[i];
        return InkWell(
          onTap: () => _applyPlaybook(p),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          child: NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _playbookIcon(p.iconName),
                  color: AppColors.teal,
                  size: 28,
                ),
                const Spacer(),
                Text(p.title, style: AppTypography.titleSmall),
                const SizedBox(height: 4),
                Text(
                  p.category,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
              Text('Notice details', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              NcTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter title…',
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              NcTextField(
                controller: _bodyController,
                label: 'Message body',
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
              Text('Delivery channels', style: AppTypography.labelLarge),
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

class _CommsPreviewCard extends StatelessWidget {
  const _CommsPreviewCard({
    required this.title,
    required this.body,
    required this.tabIndex,
    required this.audiences,
    required this.channels,
    required this.classFilter,
    required this.recipientCount,
    required this.selectedDirect,
  });

  final String title;
  final String body;
  final int tabIndex;
  final Set<String> audiences;
  final Set<String> channels;
  final String? classFilter;
  final int recipientCount;
  final int selectedDirect;

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
          if (tabIndex == 1) ...[
            Text(
              'Direct: $selectedDirect selected',
              style: AppTypography.labelSmall,
            ),
          ] else ...[
            Text(
              'To: ${audiences.join(', ')}',
              style: AppTypography.labelSmall,
            ),
            if (classFilter != null)
              Text('Class: $classFilter', style: AppTypography.labelSmall),
          ],
          const SizedBox(height: 4),
          Text('Via: ${channels.join(', ')}', style: AppTypography.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            tabIndex == 1
                ? '$selectedDirect recipient(s)'
                : '~$recipientCount recipients (estimate)',
            style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
