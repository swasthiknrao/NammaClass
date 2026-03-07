import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';

class WebIntegrationsScreen extends ConsumerStatefulWidget {
  const WebIntegrationsScreen({super.key});

  @override
  ConsumerState<WebIntegrationsScreen> createState() =>
      _WebIntegrationsScreenState();
}

class _WebIntegrationsScreenState extends ConsumerState<WebIntegrationsScreen> {
  final Map<String, bool> _enabled = {
    'payment': true,
    'sms': true,
    'whatsapp': false,
    'email': true,
    'maps': true,
    'biometric': false,
  };

  bool _apiKeyGenerated = false;
  String _apiKey = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Integrations & API Settings',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Configure payment gateways, messaging providers, and API access. Only Super Admins can modify these settings.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Payment Gateway
          _IntegrationCard(
            key: const ValueKey('payment'),
            icon: Icons.payment,
            iconColor: AppColors.teal,
            title: 'Payment Gateway',
            subtitle: 'Razorpay | SBIePay | Cashfree | PhonePe',
            enabled: _enabled['payment']!,
            onToggle: (v) => setState(() => _enabled['payment'] = v),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Gateway Provider',
                    border: OutlineInputBorder(),
                  ),
                  value: 'Razorpay',
                  items: ['Razorpay', 'SBIePay', 'Cashfree', 'PhonePe']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (_) {},
                ),
                const SizedBox(height: AppSpacing.sm),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Key ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Secret Key',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.visibility),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Webhook Secret',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connection test successful!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.cable),
                      label: const Text('Test Connection'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FilledButton(onPressed: () {}, child: const Text('Save')),
                  ],
                ),
              ],
            ),
          ),

          // SMS
          _IntegrationCard(
            key: const ValueKey('sms'),
            icon: Icons.sms,
            iconColor: AppColors.primary,
            title: 'SMS Provider',
            subtitle: 'Textlocal | MSG91 | Twilio',
            enabled: _enabled['sms']!,
            onToggle: (v) => setState(() => _enabled['sms'] = v),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Provider',
                    border: OutlineInputBorder(),
                  ),
                  value: 'MSG91',
                  items: ['Textlocal', 'MSG91', 'Twilio']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (_) {},
                ),
                const SizedBox(height: AppSpacing.sm),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Sender ID (6 chars)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test SMS sent!')),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Send Test SMS'),
                ),
              ],
            ),
          ),

          // WhatsApp
          _IntegrationCard(
            key: const ValueKey('whatsapp'),
            icon: Icons.chat,
            iconColor: const Color(0xFF25D366),
            title: 'WhatsApp Business API',
            subtitle: 'Add-on — Contact support to enable',
            enabled: _enabled['whatsapp']!,
            onToggle: (v) => setState(() => _enabled['whatsapp'] = v),
            child: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Business Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'API Token',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Webhook URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          // Email (SMTP)
          _IntegrationCard(
            key: const ValueKey('email'),
            icon: Icons.email,
            iconColor: AppColors.accent,
            title: 'Email (SMTP)',
            subtitle: 'Configure outgoing email server',
            enabled: _enabled['email']!,
            onToggle: (v) => setState(() => _enabled['email'] = v),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: const TextField(
                        decoration: InputDecoration(
                          labelText: 'SMTP Host',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 100,
                      child: const TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Port',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'From Name (e.g. "Vidyashree School")',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'From Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test email sent!')),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Send Test Email'),
                ),
              ],
            ),
          ),

          // Google Maps
          _IntegrationCard(
            key: const ValueKey('maps'),
            icon: Icons.map,
            iconColor: AppColors.error,
            title: 'Google Maps API',
            subtitle:
                'Required for GPS tracking, geo-fencing, and driver navigation',
            enabled: _enabled['maps']!,
            onToggle: (v) => setState(() => _enabled['maps'] = v),
            child: const TextField(
              decoration: InputDecoration(
                labelText: 'Google Maps API Key',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Biometric
          _IntegrationCard(
            key: const ValueKey('biometric'),
            icon: Icons.fingerprint,
            iconColor: AppColors.purple,
            title: 'Biometric Device',
            subtitle: 'ZKTeco / eSSL hardware device integration',
            enabled: _enabled['biometric']!,
            onToggle: (v) => setState(() => _enabled['biometric'] = v),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: const TextField(
                        decoration: InputDecoration(
                          labelText: 'Device IP',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 100,
                      child: const TextField(
                        decoration: InputDecoration(
                          labelText: 'Port',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cable),
                  label: const Text('Test Connection'),
                ),
              ],
            ),
          ),

          // API Access
          NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.api, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'API Access (Developers)',
                          style: AppTypography.titleSmall,
                        ),
                        Text(
                          'Generate API keys for custom integrations',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (_apiKeyGenerated) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _apiKey,
                            style: AppTypography.labelMedium.copyWith(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _apiKey));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('API key copied!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '⚠️ Save this key now. It will not be shown again.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _apiKeyGenerated = false;
                      _apiKey = '';
                    }),
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    label: const Text(
                      'Revoke Key',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ] else ...[
                  FilledButton.icon(
                    onPressed: () => setState(() {
                      _apiKeyGenerated = true;
                      _apiKey =
                          'nc_live_${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
                    }),
                    icon: const Icon(Icons.add),
                    label: const Text('Generate API Key'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Feature Flags
          NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Feature Flags', style: AppTypography.titleSmall),
                Text(
                  'Enable or disable optional modules (licensed per plan)',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...[
                  ('Canteen Module', true),
                  ('Hostel Module', true),
                  ('Face Recognition Attendance', false),
                  ('AI Insights & Analytics', true),
                  ('Social Media Auto-post', false),
                  ('E-Library (PDF access)', false),
                ].map(
                  (flag) => SwitchListTile(
                    value: flag.$2,
                    onChanged: (_) {},
                    title: Text(flag.$1, style: AppTypography.bodyMedium),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntegrationCard extends StatefulWidget {
  const _IntegrationCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onToggle,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final Widget child;

  @override
  State<_IntegrationCard> createState() => _IntegrationCardState();
}

class _IntegrationCardState extends State<_IntegrationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(widget.icon, color: widget.iconColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: AppTypography.titleSmall),
                    Text(
                      widget.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(value: widget.enabled, onChanged: widget.onToggle),
              IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ],
          ),
          if (_expanded && widget.enabled) ...[const Divider(), widget.child],
        ],
      ),
    );
  }
}
