import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/layout/constrained_content.dart';
import '../../../shared/widgets/layout/responsive_builder.dart';
import '../../../shared/widgets/lists/app_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  final List<String> _items = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _loading = false;
          _items.addAll(['Item 1', 'Item 2', 'Item 3']);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: ConstrainedContent(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: ResponsiveBuilder(
          builder: (context, breakpoint, isMobile, isTablet, isDesktop) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get started with your dashboard below.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2,
                        children: [
                          AppCard(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Card 1', style: theme.textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text('Placeholder content', style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                          AppCard(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Card 2', style: theme.textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text('Placeholder content', style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                          AppCard(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Card 3', style: theme.textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text('Placeholder content', style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Recent items', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  AppListView<String>(
                    loading: _loading,
                    itemCount: _items.length,
                    emptyMessage: 'No items yet',
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_items[index]),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
