import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';

class HostelScreen extends StatelessWidget {
  const HostelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hostel')),
      backgroundColor: AppColors.background,
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'My Room'),
                Tab(text: 'Mess'),
                Tab(text: 'Requests'),
                Tab(text: 'Notices'),
              ],
              tabAlignment: TabAlignment.start,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // My Room
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        NcCard(
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Room 204 — Block A',
                                style: AppTypography.headlineMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '2nd Floor • 4-Sharing',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Wrap(
                                spacing: AppSpacing.xs,
                                children:
                                    ['Wi-Fi', 'AC', 'Attached Bath', 'Locker']
                                        .map(
                                          (f) => Chip(
                                            label: Text(
                                              f,
                                              style: AppTypography.labelSmall
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.2),
                                            padding: EdgeInsets.zero,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                        )
                                        .toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _InfoGrid(),
                        const SizedBox(height: AppSpacing.md),
                        NcCard(
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppColors.teal,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Devraj Hostel',
                                      style: AppTypography.labelLarge,
                                    ),
                                    Text(
                                      'Hostel Warden',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.call, size: 16),
                                label: const Text('Call'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Mess
                  ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: 3,
                    itemBuilder: (ctx, i) {
                      final meals = ['Breakfast', 'Lunch', 'Dinner'];
                      final menus = [
                        'Idli, Sambar, Coconut Chutney',
                        'Rice, Rasam, Dal, Sabzi, Papad',
                        'Chapati, Dal Fry, Mixed Veg, Curd',
                      ];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: NcCard(
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: [
                                    AppColors.warning,
                                    AppColors.success,
                                    AppColors.primary,
                                  ][i],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meals[i],
                                      style: AppTypography.labelLarge,
                                    ),
                                    Text(
                                      menus[i],
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Requests
                  ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: 3,
                    itemBuilder: (ctx, i) {
                      final types = [
                        'Maintenance',
                        'Room Change',
                        'Leave Request',
                      ];
                      final statuses = ['Pending', 'Approved', 'Pending'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: NcCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      types[i],
                                      style: AppTypography.labelLarge,
                                    ),
                                    Text(
                                      'Submitted 2 days ago',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Chip(
                                label: Text(
                                  statuses[i],
                                  style: AppTypography.labelSmall,
                                ),
                                backgroundColor: statuses[i] == 'Approved'
                                    ? AppColors.successBg
                                    : AppColors.warningBg,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Notices
                  ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: 3,
                    itemBuilder: (ctx, i) {
                      final titles = [
                        'Water supply disruption',
                        'Hostel inspection',
                        'Guest policy update',
                      ];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: NcCard(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.campaign,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  titles[i],
                                  style: AppTypography.labelMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.build),
        label: const Text('New Request'),
        backgroundColor: AppColors.accent,
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      ('Floor', '2nd'),
      ('Block', 'A'),
      ('Sharing', '4-Sharing'),
      ('Joined', 'Jun 2024'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.xs,
      crossAxisSpacing: AppSpacing.xs,
      childAspectRatio: 2.5,
      children: items
          .map(
            (item) => NcCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.$1,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(item.$2, style: AppTypography.labelMedium),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
