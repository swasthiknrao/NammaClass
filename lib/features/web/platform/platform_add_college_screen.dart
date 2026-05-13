import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/tenant_policy_loader.dart';
import '../../../core/tenant/role_module_requirements.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_presets.dart';
import '../../../domain/entities/entitlement_snapshot.dart';
import '../../../domain/entities/nc_feature.dart';
import '../../../domain/entities/registered_college.dart';
import '../../../domain/entities/tenant_profile.dart';
import '../../../routing/app_routes.dart';
import 'platform_college_registry_provider.dart';
import 'widgets/live_theme_preview_card.dart';

/// Register a college into the platform registry with real [AppTheme] preview presets.
class PlatformAddCollegeScreen extends ConsumerStatefulWidget {
  const PlatformAddCollegeScreen({super.key});

  @override
  ConsumerState<PlatformAddCollegeScreen> createState() =>
      _PlatformAddCollegeScreenState();
}

class _PlatformAddCollegeScreenState
    extends ConsumerState<PlatformAddCollegeScreen> {
  final _nameCtrl = TextEditingController();
  final _tenantIdCtrl = TextEditingController();
  final _rolePackCtrl = TextEditingController();
  Color _primaryColor = AppThemePresets.oceanBlue.primaryColor;
  Color _accentColor = AppThemePresets.oceanBlue.accentColor;
  final Map<NcFeature, bool> _modules = {};
  final Map<String, Set<String>> _moduleSubFeatures = {};
  String _selectedPresetId = AppThemePresets.oceanBlue.id;
  int _step = 0;

  AppThemePreset get _selectedPreset => AppThemePresets.byId(_selectedPresetId);

  String _colorToHex(Color c) {
    return c.toARGB32().toRadixString(16).toUpperCase().substring(2);
  }

  @override
  void initState() {
    super.initState();
    for (final f in TenantPolicyLoader.subscribableNcFeatures) {
      _modules[f] = false;
    }
    for (final entry in TenantPolicyLoader.visibleModuleCatalog) {
      if (entry.subFeatures.isNotEmpty) {
        _moduleSubFeatures[entry.moduleKey] = <String>{};
      }
    }
  }

  void _selectPreset(AppThemePreset preset) {
    setState(() {
      _selectedPresetId = preset.id;
      _primaryColor = preset.primaryColor;
      _accentColor = preset.accentColor;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tenantIdCtrl.dispose();
    _rolePackCtrl.dispose();
    super.dispose();
  }

  List<ModuleCatalogEntry> get _visibleModules =>
      TenantPolicyLoader.visibleModuleCatalog;

  int get _enabledModuleCount => _modules.values.where((v) => v).length;

  Map<String, List<ModuleCatalogEntry>> _modulesByCategory() {
    final grouped = <String, List<ModuleCatalogEntry>>{};
    for (final entry in _visibleModules) {
      grouped.putIfAbsent(entry.category, () => []).add(entry);
    }
    return grouped;
  }

  List<ModuleCatalogEntry> get _enabledCatalogEntries {
    return _visibleModules.where((entry) {
      final feature = NcFeatureX.fromKey(entry.moduleKey);
      return feature != null && (_modules[feature] ?? false);
    }).toList();
  }

  void _applyStarterPack() {
    const starterKeys = {'library', 'canteen', 'transport'};
    setState(() {
      for (final entry in _visibleModules) {
        final feature = NcFeatureX.fromKey(entry.moduleKey);
        if (feature != null) {
          _modules[feature] = starterKeys.contains(entry.moduleKey);
        }
      }
      // Library starter defaults
      _moduleSubFeatures['library'] = {
        'student_library',
        'catalog',
        'issue_return',
        'fine_collection',
        'reservations',
      };
      // Canteen starter defaults
      _moduleSubFeatures['canteen'] = {
        'student_food',
        'campus_wallet',
        'combo_meals',
        'counter',
        'menu_manage',
        'allergen_veg',
      };
      // Transport starter defaults
      _moduleSubFeatures['transport'] = {
        'parent_live_tracking',
        'driver_route_app',
        'student_boarding',
        'sos_emergency',
      };
    });
  }

  void _clearModules() {
    setState(() {
      for (final key in _modules.keys.toList()) {
        _modules[key] = false;
      }
      for (final key in _moduleSubFeatures.keys.toList()) {
        _moduleSubFeatures[key] = <String>{};
      }
    });
  }

  Map<String, dynamic> _buildIntake() {
    final subFeatures = <String, List<String>>{};
    for (final entry in _moduleSubFeatures.entries) {
      if (entry.value.isEmpty) continue;
      subFeatures[entry.key] = entry.value.toList()..sort();
    }
    return {if (subFeatures.isNotEmpty) 'module_sub_features': subFeatures};
  }

  void _setModuleEnabled(NcFeature feature, bool enabled) {
    setState(() {
      _modules[feature] = enabled;
      if (!enabled) {
        _moduleSubFeatures[feature.key] = <String>{};
      }
    });
  }

  void _setSubFeature(String moduleKey, String subFeatureId, bool enabled) {
    final feature = NcFeatureX.fromKey(moduleKey);
    if (feature == null) return;

    setState(() {
      final selected = {...(_moduleSubFeatures[moduleKey] ?? <String>{})};
      if (enabled) {
        selected.add(subFeatureId);
        _modules[feature] = true;
      } else {
        selected.remove(subFeatureId);
      }
      _moduleSubFeatures[moduleKey] = selected;
    });
  }

  String _rateLabel(String moduleKey) {
    final rate = TenantPolicyLoader.moduleMrrInrPer1k[moduleKey];
    if (rate == null || rate <= 0) return 'Rate not set';
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return '${currency.format(rate)} / 1k MAU';
  }

  Widget _buildModulesStepContent() {
    final grouped = _modulesByCategory();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.14),
            ),
          ),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 430,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask what they actually need',
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Only route-gated modules from this app are shown. Future catalog items stay hidden until they are real.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _applyStarterPack,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Starter pack'),
              ),
              OutlinedButton.icon(
                onPressed: _clearModules,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear'),
              ),
              Chip(
                label: Text('$_enabledModuleCount selected'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...grouped.entries.map((group) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.key, style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                ...group.value.map(_buildModuleQuestionCard),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildModuleQuestionCard(ModuleCatalogEntry entry) {
    final feature = NcFeatureX.fromKey(entry.moduleKey);
    final enabled = feature != null && (_modules[feature] ?? false);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: enabled
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.shimmerBase,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    enabled ? Icons.check_circle : Icons.help_outline,
                    color: enabled
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.question, style: AppTypography.titleSmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        entry.subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          Chip(
                            label: Text(entry.title),
                            visualDensity: VisualDensity.compact,
                          ),
                          Chip(
                            label: Text(_rateLabel(entry.moduleKey)),
                            visualDensity: VisualDensity.compact,
                          ),
                          if (entry.suggestedRoles.isNotEmpty)
                            Chip(
                              label: Text(
                                'Roles: ${entry.suggestedRoles.join(', ')}',
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  children: [
                    Switch(
                      value: enabled,
                      onChanged: feature == null
                          ? null
                          : (v) => _setModuleEnabled(feature, v),
                    ),
                    Text(
                      enabled ? 'Yes' : 'No',
                      style: AppTypography.labelSmall.copyWith(
                        color: enabled
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (entry.subFeatures.isNotEmpty && enabled) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Which ${entry.title.toLowerCase()} workflows do they need?',
                style: AppTypography.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...entry.subFeatures.map((option) {
                final selected =
                    _moduleSubFeatures[entry.moduleKey] ?? <String>{};
                final isSelected = selected.contains(option.id);
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(option.question),
                  subtitle: option.title.isEmpty ? null : Text(option.title),
                  value: isSelected,
                  onChanged: (v) =>
                      _setSubFeature(entry.moduleKey, option.id, v ?? false),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  TenantProfile _buildDraftProfileForPreview() {
    final p = _colorToHex(_primaryColor);
    final a = _colorToHex(_accentColor);
    final modulesMap = <String, ModuleEntitlement>{
      for (final e in _modules.entries)
        e.key.key: ModuleEntitlement(enabled: e.value),
    };
    final snap = EntitlementSnapshot(
      schemaVersion: 1,
      snapshotVersion: 1,
      tenantId: _tenantIdCtrl.text.trim().isEmpty
          ? 'draft'
          : _tenantIdCtrl.text.trim(),
      modules: modulesMap,
    );
    final provisional = TenantProfile(
      tenantId: snap.tenantId,
      institutionName: _nameCtrl.text.trim().isEmpty
          ? 'New institution'
          : _nameCtrl.text.trim(),
      logoUrl: '',
      appIconUrl: '',
      primaryHex: p,
      accentHex: a,
      features: _modules.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toSet(),
      timezone: 'Asia/Kolkata',
      currency: 'INR',
      languages: const ['en'],
      entitlementSnapshot: snap,
      intake: _buildIntake(),
      themeTokens: _selectedPreset.tokens,
    );
    return provisional;
  }

  Future<void> _save() async {
    final tid = _tenantIdCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (tid.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tenant id and institution name are required.'),
        ),
      );
      return;
    }

    final primary = _colorToHex(_primaryColor);
    final accent = _colorToHex(_accentColor);
    final pack = _rolePackCtrl.text.trim();

    final modulesMap = <String, ModuleEntitlement>{
      for (final e in _modules.entries)
        e.key.key: ModuleEntitlement(enabled: e.value),
    };

    final snapDraft = EntitlementSnapshot(
      schemaVersion: 1,
      snapshotVersion: 1,
      tenantId: tid,
      modules: modulesMap,
      limits: const EntitlementLimits.empty(),
      integrationAllowlist: const [],
      allowedRoleKeys: const [],
    );

    final features = _modules.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toSet();
    final provisional = TenantProfile(
      tenantId: tid,
      institutionName: name,
      logoUrl: '',
      appIconUrl: '',
      primaryHex: primary,
      accentHex: accent,
      features: features,
      timezone: 'Asia/Kolkata',
      currency: 'INR',
      languages: const ['en'],
      entitlementSnapshot: snapDraft,
      intake: _buildIntake(),
      themeTokens: _selectedPreset.tokens,
      rolePackIds: pack.isEmpty ? const [] : [pack],
    );

    final allowed = assignableTenantRoles(
      provisional,
    ).map((r) => r.name).toList();
    final snap = snapDraft.copyWith(allowedRoleKeys: allowed);

    final profile = provisional.copyWith(entitlementSnapshot: snap);

    await ref
        .read(platformCollegeRegistryProvider.notifier)
        .upsertCollege(
          RegisteredCollege(
            profile: profile,
            users: const [],
            status: CollegeProvisioningStatus.live,
            createdAt: DateTime.now(),
          ),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved $name · snapshot v${snap.snapshotVersion}'),
      ),
    );
    context.go('/web/platform/colleges/${Uri.encodeComponent(tid)}');
  }

  @override
  Widget build(BuildContext context) {
    final previewProfile = _buildDraftProfileForPreview();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go(AppRoutes.webPlatformColleges),
              ),
              Text('Add college', style: AppTypography.headlineMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Step ${_step + 1} of 4 · Data is stored in your local platform registry file until a backend exists.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Stepper(
            currentStep: _step,
            physics: const ClampingScrollPhysics(),
            onStepTapped: (int index) {
              setState(() => _step = index);
            },
            onStepContinue: () {
              if (_step < 3) setState(() => _step++);
            },
            onStepCancel: () {
              if (_step > 0) setState(() => _step--);
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Row(
                  children: [
                    if (_step > 0)
                      OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    const SizedBox(width: AppSpacing.sm),
                    if (_step < 3)
                      FilledButton(
                        onPressed: details.onStepContinue,
                        child: const Text('Next'),
                      ),
                    if (_step == 3)
                      FilledButton(
                        onPressed: _save,
                        child: const Text('Save to registry'),
                      ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Identity'),
                content: Column(
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Institution name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _tenantIdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tenant id (unique)',
                        border: OutlineInputBorder(),
                        helperText: 'e.g. nc_inst_acme',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _rolePackCtrl,
                      decoration: InputDecoration(
                        labelText: 'Role pack id (optional)',
                        border: const OutlineInputBorder(),
                        hintText: TenantPolicyLoader.defaultRolePackId.isEmpty
                            ? 'k12_basic'
                            : TenantPolicyLoader.defaultRolePackId,
                      ),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Modules'),
                subtitle: const Text(
                  'Answer a few setup questions; only real app modules appear.',
                ),
                content: _buildModulesStepContent(),
              ),
              Step(
                title: const Text('Brand & theme'),
                subtitle: const Text(
                  'Pick a style — colors & layout apply instantly',
                ),
                content: _BrandThemeStepContent(
                  selectedPresetId: _selectedPresetId,
                  primaryColor: _primaryColor,
                  accentColor: _accentColor,
                  previewProfile: previewProfile,
                  onPresetSelected: _selectPreset,
                  onPrimaryChanged: (c) => setState(() => _primaryColor = c),
                  onAccentChanged: (c) => setState(() => _accentColor = c),
                ),
              ),
              Step(
                title: const Text('Review'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameCtrl.text.trim().isEmpty
                          ? '(name)'
                          : _nameCtrl.text.trim(),
                      style: AppTypography.titleMedium,
                    ),
                    Text(_tenantIdCtrl.text.trim()),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$_enabledModuleCount modules on · ${_selectedPreset.emoji} ${_selectedPreset.name}',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_enabledCatalogEntries.isEmpty)
                      Text(
                        'No optional modules selected yet.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    else
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: _enabledCatalogEntries
                            .map(
                              (entry) => Chip(
                                label: Text(entry.title),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                    if (_moduleSubFeatures.values.any((s) => s.isNotEmpty)) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Selected sub-features: ${_moduleSubFeatures.entries.where((e) => e.value.isNotEmpty).map((e) => '${e.key}: ${e.value.join(', ')}').join(' · ')}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand & Theme step — visual preset picker
// ─────────────────────────────────────────────────────────────────────────────

class _BrandThemeStepContent extends StatelessWidget {
  const _BrandThemeStepContent({
    required this.selectedPresetId,
    required this.primaryColor,
    required this.accentColor,
    required this.previewProfile,
    required this.onPresetSelected,
    required this.onPrimaryChanged,
    required this.onAccentChanged,
  });

  final String selectedPresetId;
  final Color primaryColor;
  final Color accentColor;
  final TenantProfile previewProfile;
  final ValueChanged<AppThemePreset> onPresetSelected;
  final ValueChanged<Color> onPrimaryChanged;
  final ValueChanged<Color> onAccentChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          icon: Icons.palette_rounded,
          label: 'Select a theme style',
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Preset cards ──────────────────────────────────────────
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 4),
            itemCount: AppThemePresets.all.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final preset = AppThemePresets.all[i];
              final isSelected = preset.id == selectedPresetId;
              return _PresetPickerCard(
                preset: preset,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () => onPresetSelected(preset),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
        _SectionLabel(
          icon: Icons.colorize_rounded,
          label: 'Choose brand colours',
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Creative colour pickers — responsive ──────────────────
        LayoutBuilder(
          builder: (ctx, constraints) {
            final screenW = MediaQuery.sizeOf(ctx).width;
            final layoutW = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : screenW;
            final isWide = layoutW >= 640;
            final picker1 = _CreativeColorPicker(
              label: 'Primary',
              selected: primaryColor,
              onChanged: onPrimaryChanged,
              isDark: isDark,
              embeddedInStudio: isWide,
            );
            final picker2 = _CreativeColorPicker(
              label: 'Accent',
              selected: accentColor,
              onChanged: onAccentChanged,
              isDark: isDark,
              embeddedInStudio: isWide,
            );
            if (isWide) {
              return _BrandColourStudioWindow(
                primaryColor: primaryColor,
                accentColor: accentColor,
                isDark: isDark,
                primaryPicker: picker1,
                accentPicker: picker2,
              );
            }
            return Column(
              children: [
                picker1,
                const SizedBox(height: AppSpacing.sm),
                picker2,
              ],
            );
          },
        ),

        const SizedBox(height: AppSpacing.lg),
        _SectionLabel(
          icon: Icons.preview_rounded,
          label: 'Live preview',
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ThreeDeviceRow(
          preset: AppThemePresets.byId(selectedPresetId),
          primaryColor: primaryColor,
          accentColor: accentColor,
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.md),
        // Mini app preview with preset label
        Stack(
          children: [
            LiveThemePreviewCard(profile: previewProfile, height: 180),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppThemePresets.byId(selectedPresetId).emoji,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        AppThemePresets.byId(selectedPresetId).name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TinyLiveColorDot(color: primaryColor),
                    const SizedBox(width: 3),
                    _TinyLiveColorDot(color: accentColor),
                    const SizedBox(width: 8),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Desktop-style “studio window” wrapping Primary + Accent pickers.
class _BrandColourStudioWindow extends StatelessWidget {
  const _BrandColourStudioWindow({
    required this.primaryColor,
    required this.accentColor,
    required this.isDark,
    required this.primaryPicker,
    required this.accentPicker,
  });

  final Color primaryColor;
  final Color accentColor;
  final bool isDark;
  final Widget primaryPicker;
  final Widget accentPicker;

  @override
  Widget build(BuildContext context) {
    final frame = isDark ? const Color(0xFF252838) : const Color(0xFFE4E6F0);
    final bodyBg = isDark ? const Color(0xFF1A1D2E) : const Color(0xFFF7F8FD);

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.14),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BrandColourWindowTitleBar(
                primaryColor: primaryColor,
                accentColor: accentColor,
                isDark: isDark,
              ),
              Container(
                color: bodyBg,
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
                // Bounded width for Stepper/unbounded parents; Table aligns row heights.
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenW = MediaQuery.sizeOf(context).width;
                    final maxW = constraints.hasBoundedWidth
                        ? constraints.maxWidth
                        : screenW;
                    return SizedBox(
                      width: maxW,
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FixedColumnWidth(1),
                          2: FlexColumnWidth(1),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.top,
                        children: [
                          TableRow(
                            children: [
                              TableCell(child: primaryPicker),
                              TableCell(
                                child: VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: frame,
                                  indent: 4,
                                  endIndent: 4,
                                ),
                              ),
                              TableCell(child: accentPicker),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandColourWindowTitleBar extends StatelessWidget {
  const _BrandColourWindowTitleBar({
    required this.primaryColor,
    required this.accentColor,
    required this.isDark,
  });

  final Color primaryColor;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final mid = Color.lerp(primaryColor, accentColor, 0.45) ?? accentColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(primaryColor, Colors.white, isDark ? 0.08 : 0.55) ??
                primaryColor,
            Color.lerp(mid, Colors.white, isDark ? 0.05 : 0.35) ?? mid,
            Color.lerp(accentColor, Colors.white, isDark ? 0.06 : 0.45) ??
                accentColor,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _traffic(const Color(0xFFFF5F57)),
              const SizedBox(width: 6),
              _traffic(const Color(0xFFFEBC2E)),
              const SizedBox(width: 6),
              _traffic(const Color(0xFF28C840)),
            ],
          ),
          const SizedBox(width: 14),
          Icon(
            Icons.brush_rounded,
            size: 16,
            color: primaryColor.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Brand colours studio',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.92)
                    : const Color(0xFF1B1D2A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.55),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _miniSwatch(primaryColor),
                const SizedBox(width: 5),
                _miniSwatch(accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _traffic(Color c) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.45),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
      ),
    );
  }

  static Widget _miniSwatch(Color c) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 6)],
      ),
    );
  }
}

class _TinyLiveColorDot extends StatelessWidget {
  const _TinyLiveColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 6),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.isDark,
  });
  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PresetPickerCard extends StatelessWidget {
  const _PresetPickerCard({
    required this.preset,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final AppThemePreset preset;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E2235) : const Color(0xFFF5F6FF);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 160,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? preset.primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: preset.primaryColor.withValues(alpha: 0.35),
                blurRadius: 14,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Text(preset.emoji, style: const TextStyle(fontSize: 18)),
                const Spacer(),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: preset.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 11,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              preset.name,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              preset.description,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Palette bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(color: preset.primaryColor),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: preset.primaryColor.withValues(alpha: 0.55),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(color: preset.accentColor),
                    ),
                    Expanded(
                      child: Container(
                        color: preset.accentColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Creative colour picker ──────────────────────────────────────────────────

/// Flat list of all curated swatches — 8 families × 5 shades each = 40 colours.
/// Displayed as a responsive wrap grid; no fixed widths needed.
const _kSwatchRows = <_SwatchRow>[
  _SwatchRow('Navy', Color(0xFF667EEA), [
    Color(0xFF0D1B2A),
    Color(0xFF1B4F72),
    Color(0xFF2471A3),
    Color(0xFF5DADE2),
    Color(0xFFAED6F1),
  ]),
  _SwatchRow('Teal', Color(0xFF45B7AA), [
    Color(0xFF0B4F45),
    Color(0xFF117A65),
    Color(0xFF1A9E8E),
    Color(0xFF45B7AA),
    Color(0xFF76C7BF),
  ]),
  _SwatchRow('Green', Color(0xFF27AE60), [
    Color(0xFF1A6B3C),
    Color(0xFF1E8449),
    Color(0xFF27AE60),
    Color(0xFF52BE80),
    Color(0xFF82E0AA),
  ]),
  _SwatchRow('Purple', Color(0xFF9B59B6), [
    Color(0xFF2D1B69),
    Color(0xFF5B2C8D),
    Color(0xFF7D3C98),
    Color(0xFF9B59B6),
    Color(0xFFBB8FCE),
  ]),
  _SwatchRow('Red', Color(0xFFE74C3C), [
    Color(0xFF6E1A12),
    Color(0xFF922B21),
    Color(0xFFCB4335),
    Color(0xFFE74C3C),
    Color(0xFFF1948A),
  ]),
  _SwatchRow('Orange', Color(0xFFE67E22), [
    Color(0xFF784212),
    Color(0xFFB7500C),
    Color(0xFFE67E22),
    Color(0xFFF39C12),
    Color(0xFFF8C471),
  ]),
  _SwatchRow('Steel', Color(0xFF5D6D7E), [
    Color(0xFF17202A),
    Color(0xFF2C3E50),
    Color(0xFF34495E),
    Color(0xFF5D6D7E),
    Color(0xFF95A5A6),
  ]),
  _SwatchRow('Rose', Color(0xFFCD6155), [
    Color(0xFF641E16),
    Color(0xFF922B21),
    Color(0xFFB03A2E),
    Color(0xFFCD6155),
    Color(0xFFF2B4B0),
  ]),
];

class _SwatchRow {
  const _SwatchRow(this.name, this.familyColor, this.colors);
  final String name;
  final Color familyColor;
  final List<Color> colors;
}

class _CreativeColorPicker extends StatefulWidget {
  const _CreativeColorPicker({
    required this.label,
    required this.selected,
    required this.onChanged,
    required this.isDark,
    this.embeddedInStudio = false,
  });

  final String label;
  final Color selected;
  final ValueChanged<Color> onChanged;
  final bool isDark;

  /// When true, sits inside [_BrandColourStudioWindow] — flatter chrome.
  final bool embeddedInStudio;

  @override
  State<_CreativeColorPicker> createState() => _CreativeColorPickerState();
}

class _CreativeColorPickerState extends State<_CreativeColorPicker> {
  bool _expanded = false;
  bool _showCustom = false;
  late TextEditingController _hexCtrl;

  @override
  void initState() {
    super.initState();
    _hexCtrl = TextEditingController(text: _toHex(widget.selected));
  }

  @override
  void didUpdateWidget(_CreativeColorPicker old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      _hexCtrl.text = _toHex(widget.selected);
    }
  }

  @override
  void dispose() {
    _hexCtrl.dispose();
    super.dispose();
  }

  String _toHex(Color c) =>
      c.toARGB32().toRadixString(16).toUpperCase().substring(2);

  Color? _parseHex(String raw) {
    final s = raw.replaceAll('#', '').trim().toUpperCase();
    if (s.length == 6 && RegExp(r'^[0-9A-F]{6}$').hasMatch(s)) {
      return Color(int.parse('FF$s', radix: 16));
    }
    return null;
  }

  bool _colorsMatch(Color a, Color b) =>
      (a.r - b.r).abs() < 0.01 &&
      (a.g - b.g).abs() < 0.01 &&
      (a.b - b.b).abs() < 0.01;

  void _pick(Color c) {
    widget.onChanged(c);
    setState(() => _hexCtrl.text = _toHex(c));
  }

  @override
  Widget build(BuildContext context) {
    final surface = widget.isDark
        ? const Color(0xFF1C2030)
        : const Color(0xFFF5F6FF);
    final embeddedSurface = widget.isDark
        ? const Color(0xFF151824)
        : const Color(0xFFFDFEFF);

    final decoration = widget.embeddedInStudio
        ? BoxDecoration(
            color: embeddedSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.selected.withValues(alpha: 0.12)),
          )
        : BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.selected.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.selected.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.all(widget.embeddedInStudio ? 6 : 12),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: widget.embeddedInStudio
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ───────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              // Hex badge + colour pill combined
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: widget.selected,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.selected.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '#${_toHex(widget.selected)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: widget.embeddedInStudio ? 6 : 10),

          // ── Responsive swatch grid ────────────────────────────────
          // Mobile starts compact; users can expand into the full palette.
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final totalW = constraints.maxWidth;
                // Half-width studio columns are <420px; still show full palette
                // there with compact swatches (no "3 rows + scroll" mode).
                final paletteCompact = !widget.embeddedInStudio && totalW < 420;
                final visibleRows = paletteCompact && !_expanded
                    ? _kSwatchRows.take(3).toList()
                    : _kSwatchRows;
                // 5 swatches + 1 indicator circle + gaps per row
                const indicatorW = 10.0;
                const indicatorGap = 6.0;
                const swatchGap = 2.0;
                const swatchCount = 5;
                final isTiny = totalW < 150;

                // Studio (wide) panels: stretch swatches across the full column
                // width — avoids a large empty band beside a fixed 48px grid.
                if (widget.embeddedInStudio) {
                  const embeddedIndicator = 10.0;
                  const embeddedSwatchH = 18.0;
                  const embeddedRowGap = 4.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...visibleRows.map((row) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: embeddedRowGap,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Tooltip(
                                message: row.name,
                                child: Container(
                                  width: embeddedIndicator,
                                  height: embeddedIndicator,
                                  decoration: BoxDecoration(
                                    color: row.familyColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              ...row.colors.asMap().entries.map((e) {
                                final idx = e.key;
                                final c = e.value;
                                final isSelected = _colorsMatch(
                                  c,
                                  widget.selected,
                                );
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: idx == 0 ? 0 : swatchGap * 0.5,
                                      right: idx == row.colors.length - 1
                                          ? 0
                                          : swatchGap * 0.5,
                                    ),
                                    child: Tooltip(
                                      message: '#${_toHex(c)}',
                                      child: GestureDetector(
                                        onTap: () => _pick(c),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 160,
                                          ),
                                          height: embeddedSwatchH,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: c,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: isSelected
                                                ? Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  )
                                                : null,
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: c.withValues(
                                                        alpha: 0.65,
                                                      ),
                                                      blurRadius: 8,
                                                      spreadRadius: 0.5,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.white,
                                                  size: 14,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                      if (paletteCompact) ...[
                        const SizedBox(height: 4),
                        Center(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              setState(() => _expanded = !_expanded);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: widget.selected.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: widget.selected.withValues(
                                    alpha: 0.22,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _expanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.palette_rounded,
                                    size: 14,
                                    color: widget.selected,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _expanded ? 'Show less' : 'More colours',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: widget.selected,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                }

                final swatchW =
                    ((totalW -
                                indicatorW -
                                indicatorGap -
                                swatchGap * (swatchCount - 1)) /
                            swatchCount)
                        .clamp(isTiny ? 10.0 : 18.0, 56.0);
                final swatchH = (swatchW * 0.75).clamp(
                  isTiny ? 12.0 : 16.0,
                  40.0,
                );
                final radius = swatchW * 0.22;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...visibleRows.map((row) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Tooltip(
                              message: row.name,
                              child: Container(
                                width: indicatorW,
                                height: indicatorW,
                                decoration: BoxDecoration(
                                  color: row.familyColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: indicatorGap),
                            ...row.colors.asMap().entries.map((e) {
                              final c = e.value;
                              final isSelected = _colorsMatch(
                                c,
                                widget.selected,
                              );
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: e.key < row.colors.length - 1
                                      ? swatchGap
                                      : 0,
                                ),
                                child: Tooltip(
                                  message: '#${_toHex(c)}',
                                  child: GestureDetector(
                                    onTap: () => _pick(c),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 160,
                                      ),
                                      width: swatchW,
                                      height: swatchH,
                                      decoration: BoxDecoration(
                                        color: c,
                                        borderRadius: BorderRadius.circular(
                                          radius,
                                        ),
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              )
                                            : null,
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: c.withValues(
                                                    alpha: 0.7,
                                                  ),
                                                  blurRadius: 10,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: isSelected
                                          ? Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: swatchH * 0.55,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                    if (paletteCompact) ...[
                      const SizedBox(height: 4),
                      Center(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            setState(() => _expanded = !_expanded);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: widget.selected.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: widget.selected.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _expanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.palette_rounded,
                                  size: 14,
                                  color: widget.selected,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _expanded ? 'Show less' : 'More colours',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: widget.selected,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          SizedBox(height: widget.embeddedInStudio ? 2 : 6),

          // ── Custom hex row ────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _showCustom = !_showCustom),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showCustom ? Icons.expand_less_rounded : Icons.edit_rounded,
                  size: widget.embeddedInStudio ? 11 : 13,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _showCustom ? 'Hide' : 'Custom hex',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_showCustom) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hexCtrl,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 7,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixText: '#',
                      hintText: '1B4F72',
                    ),
                    onChanged: (v) {
                      final c = _parseHex(v);
                      if (c != null) widget.onChanged(c);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: widget.selected,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: widget.selected.withValues(alpha: 0.45),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Inline 3-device mockup row ──────────────────────────────────────────────

class _ThreeDeviceRow extends StatelessWidget {
  const _ThreeDeviceRow({
    required this.preset,
    required this.primaryColor,
    required this.accentColor,
    required this.isDark,
  });

  final AppThemePreset preset;
  final Color primaryColor;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 22,
          child: _InlineDeviceFrame(
            label: 'Mobile',
            icon: Icons.smartphone_rounded,
            aspectRatio: 9 / 18,
            preset: preset,
            primaryColor: primaryColor,
            accentColor: accentColor,
            isDark: isDark,
            isMobile: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 36,
          child: _InlineDeviceFrame(
            label: 'Tablet',
            icon: Icons.tablet_rounded,
            aspectRatio: 4 / 5.5,
            preset: preset,
            primaryColor: primaryColor,
            accentColor: accentColor,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 56,
          child: _InlineDeviceFrame(
            label: 'Desktop',
            icon: Icons.desktop_mac_rounded,
            aspectRatio: 16 / 9,
            preset: preset,
            primaryColor: primaryColor,
            accentColor: accentColor,
            isDark: isDark,
            isDesktop: true,
          ),
        ),
      ],
    );
  }
}

class _InlineDeviceFrame extends StatelessWidget {
  const _InlineDeviceFrame({
    required this.label,
    required this.icon,
    required this.aspectRatio,
    required this.preset,
    required this.primaryColor,
    required this.accentColor,
    required this.isDark,
    this.isMobile = false,
    this.isDesktop = false,
  });

  final String label;
  final IconData icon;
  final double aspectRatio;
  final AppThemePreset preset;
  final Color primaryColor;
  final Color accentColor;
  final bool isDark;
  final bool isMobile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final frameColor = isDark
        ? const Color(0xFF2A2A3E)
        : const Color(0xFFE0E2EE);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: frameColor,
            borderRadius: BorderRadius.circular(isDesktop ? 6 : 14),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isDesktop ? 3 : 10),
              child: _InlineMockScreen(
                preset: preset,
                primaryColor: primaryColor,
                accentColor: accentColor,
                isDark: isDark,
                isMobile: isMobile,
                isDesktop: isDesktop,
              ),
            ),
          ),
        ),
        if (isDesktop)
          Center(
            child: Column(
              children: [
                Container(width: 16, height: 10, color: frameColor),
                Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: frameColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final showLabel = constraints.maxWidth >= 58;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 11, color: AppColors.textSecondary),
                if (showLabel) ...[
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      label,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _InlineMockScreen extends StatelessWidget {
  const _InlineMockScreen({
    required this.preset,
    required this.primaryColor,
    required this.accentColor,
    required this.isDark,
    required this.isMobile,
    required this.isDesktop,
  });
  final AppThemePreset preset;
  final Color primaryColor;
  final Color accentColor;
  final bool isDark;
  final bool isMobile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _InlineMockPainter(
        preset: preset,
        primaryColor: primaryColor,
        accentColor: accentColor,
        isDark: isDark,
        isMobile: isMobile,
        isDesktop: isDesktop,
      ),
    );
  }
}

class _InlineMockPainter extends CustomPainter {
  _InlineMockPainter({
    required this.preset,
    required this.primaryColor,
    required this.accentColor,
    required this.isDark,
    required this.isMobile,
    required this.isDesktop,
  });

  final AppThemePreset preset;
  final Color primaryColor;
  final Color accentColor;
  final bool isDark;
  final bool isMobile;
  final bool isDesktop;

  Color get _bg => isDark ? const Color(0xFF141420) : const Color(0xFFF6F7FA);
  Color get _card => isDark ? const Color(0xFF1E2235) : Colors.white;
  Color get _muted => isDark
      ? Colors.white.withValues(alpha: 0.14)
      : Colors.black.withValues(alpha: 0.1);
  Color get _divider => isDark
      ? Colors.white.withValues(alpha: 0.07)
      : Colors.black.withValues(alpha: 0.06);

  double get _r {
    final s = preset.tokens.radiusScale ?? 1.0;
    return (6 * s).clamp(1.5, 12.0);
  }

  Paint _fill(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  void _rect(Canvas c, Rect r, Color color, {double? radius}) {
    c.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(radius ?? _r)),
      _fill(color),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _fill(_bg));

    if (isMobile) {
      _paintMobile(canvas, w, h);
    } else if (isDesktop) {
      _paintDesktop(canvas, w, h);
    } else {
      _paintTablet(canvas, w, h);
    }
  }

  void _paintMobile(Canvas canvas, double w, double h) {
    // AppBar
    _rect(canvas, Rect.fromLTWH(0, 0, w, h * 0.12), primaryColor, radius: 0);
    _rect(
      canvas,
      Rect.fromLTWH(w * 0.1, h * 0.04, w * 0.45, h * 0.04),
      Colors.white.withValues(alpha: 0.85),
      radius: 2,
    );
    canvas.drawCircle(
      Offset(w * 0.88, h * 0.06),
      w * 0.05,
      _fill(Colors.white.withValues(alpha: 0.3)),
    );

    // Cards
    for (var i = 0; i < 4; i++) {
      final y = h * 0.15 + i * (h * 0.19);
      _rect(canvas, Rect.fromLTWH(w * 0.04, y, w * 0.92, h * 0.16), _card);
      canvas.drawCircle(
        Offset(w * 0.12, y + h * 0.08),
        w * 0.05,
        _fill(
          i.isEven
              ? primaryColor.withValues(alpha: 0.2)
              : accentColor.withValues(alpha: 0.2),
        ),
      );
      _rect(
        canvas,
        Rect.fromLTWH(w * 0.22, y + h * 0.03, w * 0.55, h * 0.04),
        _muted,
        radius: 2,
      );
      _rect(
        canvas,
        Rect.fromLTWH(w * 0.22, y + h * 0.09, w * 0.35, h * 0.03),
        _muted.withValues(alpha: _muted.a * 0.6),
        radius: 2,
      );
    }

    // Bottom nav
    _rect(canvas, Rect.fromLTWH(0, h * 0.9, w, h * 0.1), _card, radius: 0);
    canvas.drawLine(
      Offset(0, h * 0.9),
      Offset(w, h * 0.9),
      Paint()
        ..color = _divider
        ..strokeWidth = 0.8,
    );
    for (var i = 0; i < 4; i++) {
      final nx = w / 4 * i + w / 8;
      _rect(
        canvas,
        Rect.fromLTWH(nx - w * 0.06, h * 0.918, w * 0.12, h * 0.05),
        i == 0 ? primaryColor : _muted,
        radius: 3,
      );
    }
  }

  void _paintTablet(Canvas canvas, double w, double h) {
    final sw = w * 0.28;
    // Sidebar
    _rect(canvas, Rect.fromLTWH(0, 0, sw, h), primaryColor, radius: 0);
    _rect(
      canvas,
      Rect.fromLTWH(sw * 0.1, h * 0.04, sw * 0.8, h * 0.08),
      Colors.white.withValues(alpha: 0.2),
      radius: 5,
    );
    for (var i = 0; i < 5; i++) {
      final sy = h * 0.16 + i * h * 0.1;
      if (i == 0) {
        _rect(
          canvas,
          Rect.fromLTWH(sw * 0.06, sy - h * 0.005, sw * 0.88, h * 0.076),
          Colors.white.withValues(alpha: 0.18),
          radius: 6,
        );
      }
      _rect(
        canvas,
        Rect.fromLTWH(sw * 0.15, sy + h * 0.02, sw * 0.55, h * 0.03),
        Colors.white.withValues(alpha: i == 0 ? 0.85 : 0.35),
        radius: 2,
      );
    }
    // Main area
    canvas.drawRect(Rect.fromLTWH(sw, 0, w - sw, h), _fill(_bg));
    // Topbar
    _rect(canvas, Rect.fromLTWH(sw, 0, w - sw, h * 0.1), _card, radius: 0);
    canvas.drawLine(
      Offset(sw, h * 0.1),
      Offset(w, h * 0.1),
      Paint()
        ..color = _divider
        ..strokeWidth = 0.8,
    );
    // Stat row
    final cw = (w - sw - 3 * (w - sw) * 0.025) / 2;
    for (var i = 0; i < 2; i++) {
      final cx = sw + (w - sw) * 0.025 + i * (cw + (w - sw) * 0.025);
      _rect(canvas, Rect.fromLTWH(cx, h * 0.12, cw, h * 0.16), _card);
      _rect(
        canvas,
        Rect.fromLTWH(cx + cw * 0.1, h * 0.15, cw * 0.35, h * 0.06),
        (i == 0 ? primaryColor : accentColor).withValues(alpha: 0.2),
        radius: 4,
      );
      _rect(
        canvas,
        Rect.fromLTWH(cx + cw * 0.1, h * 0.23, cw * 0.6, h * 0.03),
        _muted,
        radius: 2,
      );
    }
    // Chart
    _rect(
      canvas,
      Rect.fromLTWH(sw + (w - sw) * 0.025, h * 0.31, (w - sw) * 0.94, h * 0.55),
      _card,
    );
    _paintBars(
      canvas,
      Rect.fromLTWH(sw + (w - sw) * 0.07, h * 0.37, (w - sw) * 0.86, h * 0.42),
    );
  }

  void _paintDesktop(Canvas canvas, double w, double h) {
    final topH = h * 0.11;
    final sideW = w * 0.18;
    // Topbar
    _rect(canvas, Rect.fromLTWH(0, 0, w, topH), _card, radius: 0);
    canvas.drawLine(
      Offset(0, topH),
      Offset(w, topH),
      Paint()
        ..color = _divider
        ..strokeWidth = 0.8,
    );
    _rect(
      canvas,
      Rect.fromLTWH(w * 0.01, topH * 0.2, sideW * 0.6, topH * 0.6),
      primaryColor.withValues(alpha: 0.15),
      radius: 3,
    );
    _rect(
      canvas,
      Rect.fromLTWH(w * 0.015, topH * 0.3, sideW * 0.3, topH * 0.4),
      primaryColor,
      radius: 2,
    );
    for (var i = 0; i < 5; i++) {
      final nx = sideW + w * 0.05 + i * w * 0.09;
      _rect(
        canvas,
        Rect.fromLTWH(nx, topH * 0.35, w * 0.06, topH * 0.3),
        i == 0 ? primaryColor : _muted,
        radius: 2,
      );
    }
    // Sidebar
    _rect(
      canvas,
      Rect.fromLTWH(0, topH, sideW, h - topH),
      isDark ? const Color(0xFF0D1117) : const Color(0xFFEEF0F7),
      radius: 0,
    );
    canvas.drawLine(
      Offset(sideW, topH),
      Offset(sideW, h),
      Paint()
        ..color = _divider
        ..strokeWidth = 0.8,
    );
    for (var i = 0; i < 6; i++) {
      final sy = topH + h * 0.04 + i * h * 0.09;
      if (i == 0) {
        _rect(
          canvas,
          Rect.fromLTWH(sideW * 0.04, sy - h * 0.005, sideW * 0.92, h * 0.075),
          primaryColor.withValues(alpha: 0.12),
          radius: 5,
        );
      }
      _rect(
        canvas,
        Rect.fromLTWH(sideW * 0.12, sy + h * 0.015, sideW * 0.6, h * 0.03),
        i == 0 ? primaryColor.withValues(alpha: 0.7) : _muted,
        radius: 2,
      );
    }
    // Content
    final mainX = sideW;
    final mainW = w - sideW;
    // Stats row
    final statCount = 3;
    final sw2 = (mainW - (statCount + 1) * mainW * 0.025) / statCount;
    final statY = topH + h * 0.05;
    for (var i = 0; i < statCount; i++) {
      final sx = mainX + mainW * 0.025 + i * (sw2 + mainW * 0.025);
      _rect(canvas, Rect.fromLTWH(sx, statY, sw2, h * 0.16), _card);
      _rect(
        canvas,
        Rect.fromLTWH(sx + sw2 * 0.08, statY + h * 0.03, sw2 * 0.3, h * 0.07),
        (i % 2 == 0 ? primaryColor : accentColor).withValues(alpha: 0.18),
        radius: 4,
      );
      _rect(
        canvas,
        Rect.fromLTWH(sx + sw2 * 0.08, statY + h * 0.12, sw2 * 0.55, h * 0.025),
        _muted,
        radius: 2,
      );
    }
    // Chart
    _rect(
      canvas,
      Rect.fromLTWH(
        mainX + mainW * 0.025,
        topH + h * 0.26,
        mainW * 0.94,
        h * 0.56,
      ),
      _card,
    );
    _paintBars(
      canvas,
      Rect.fromLTWH(
        mainX + mainW * 0.06,
        topH + h * 0.32,
        mainW * 0.86,
        h * 0.44,
      ),
    );
  }

  void _paintBars(Canvas canvas, Rect area) {
    const heights = [0.55, 0.8, 0.45, 0.9, 0.65, 1.0, 0.7];
    final barW = area.width / (heights.length * 1.7);
    final gap = area.width / heights.length;
    for (var i = 0; i < heights.length; i++) {
      final bh = area.height * heights[i];
      final bx = area.left + gap * i + (gap - barW) / 2;
      _rect(
        canvas,
        Rect.fromLTWH(bx, area.bottom - bh, barW, bh),
        i.isEven
            ? primaryColor.withValues(alpha: 0.75)
            : accentColor.withValues(alpha: 0.6),
        radius: 2,
      );
    }
    canvas.drawLine(
      area.bottomLeft,
      area.bottomRight,
      Paint()
        ..color = _muted
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(_InlineMockPainter old) =>
      old.preset.id != preset.id ||
      old.primaryColor != primaryColor ||
      old.accentColor != accentColor ||
      old.isDark != isDark;
}
