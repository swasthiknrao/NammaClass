import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_input.dart';
import '../../../routing/app_routes.dart';

class WebSettingsScreen extends StatefulWidget {
  const WebSettingsScreen({super.key});
  @override
  State<WebSettingsScreen> createState() => _WebSettingsScreenState();
}

class _WebSettingsScreenState extends State<WebSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('School Settings', style: AppTypography.headlineLarge),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
              ),
              const SizedBox(width: AppSpacing.xs),
              NcPrimaryButton(
                label: 'Save (Ctrl+S)',
                icon: Icons.save,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved!')),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          DefaultTabController(
            length: 5,
            child: Column(
              children: [
                const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'General'),
                    Tab(text: 'Academics'),
                    Tab(text: 'Finance'),
                    Tab(text: 'Communication'),
                    Tab(text: 'Security'),
                  ],
                  tabAlignment: TabAlignment.start,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    children: [
                      // General
                      NcCard(
                        child: Column(
                          children: [
                            NcTextField(
                              initialValue: AppConstants.schoolName,
                              label: 'School Name',
                              prefixIcon: Icons.school,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            NcTextField(
                              initialValue: 'Kundapura, Karnataka',
                              label: 'Address',
                              prefixIcon: Icons.location_on,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            NcTextField(
                              initialValue: '2025-26',
                              label: 'Academic Year',
                              prefixIcon: Icons.calendar_today,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            NcTextField(
                              initialValue: 'India/Kolkata',
                              label: 'Timezone',
                              prefixIcon: Icons.access_time,
                            ),
                          ],
                        ),
                      ),
                      // Academics
                      NcCard(
                        child: Column(
                          children: [
                            NcTextField(
                              initialValue: '8:00 AM',
                              label: 'School Start Time',
                              prefixIcon: Icons.access_time,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            NcTextField(
                              initialValue: '3:30 PM',
                              label: 'School End Time',
                              prefixIcon: Icons.access_time,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            NcTextField(
                              initialValue: '45',
                              label: 'Period Duration (mins)',
                              prefixIcon: Icons.timelapse,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            NcTextField(
                              initialValue: '8',
                              label: 'Periods per Day',
                              prefixIcon: Icons.numbers,
                            ),
                          ],
                        ),
                      ),
                      // Remaining tabs placeholders
                      const Center(child: Text('Finance settings coming soon')),
                      const Center(
                        child: Text('Communication settings coming soon'),
                      ),
                      NcCard(
                        child: ListTile(
                          leading: const Icon(Icons.security),
                          title: const Text('Security audit log'),
                          subtitle: const Text(
                            'View login, logout and security events',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(AppRoutes.webSecurityLog),
                        ),
                      ),
                    ],
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
