import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';

class WebWebsiteManagerScreen extends StatelessWidget {
  const WebWebsiteManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form editor
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Website Manager', style: AppTypography.headlineLarge),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.preview, size: 16),
                      label: const Text('Preview'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    NcPrimaryButton(
                      label: 'Publish',
                      icon: Icons.publish,
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Website published!')),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView(
                    children: [
                      _SectionEditor(
                        title: 'Hero Section',
                        icon: Icons.image,
                        children: const [
                          TextField(
                            decoration: InputDecoration(labelText: 'Headline'),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Subheadline',
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'CTA Button Text',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SectionEditor(
                        title: 'About Section',
                        icon: Icons.info_outline,
                        children: const [
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'About Text',
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SectionEditor(
                        title: 'Contact Information',
                        icon: Icons.contact_phone,
                        children: const [
                          TextField(
                            decoration: InputDecoration(labelText: 'Phone'),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(labelText: 'Email'),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(labelText: 'Address'),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Live preview
          SizedBox(
            width: 380,
            child: NcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.preview, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Live Preview', style: AppTypography.labelLarge),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school, color: Colors.white, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'Vidyashree Public School',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Smart School. Happy Campus.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Website URL', style: AppTypography.labelMedium),
                  Text(
                    'https://vidyashree.nammaclass.in',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionEditor extends StatelessWidget {
  const _SectionEditor({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(title, style: AppTypography.labelLarge),
            ],
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }
}
