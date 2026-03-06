import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/route_config.dart';
import '../layout/responsive_builder.dart';

/// Destinations for shell navigation. Shared across rail and bottom nav.
class NavDestination {
  const NavDestination({
    required this.path,
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;

  static const List<NavDestination> all = [
    NavDestination(path: RouteConfig.home, label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home),
    NavDestination(path: RouteConfig.dashboard, label: 'Dashboard', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard),
    NavDestination(path: RouteConfig.settings, label: 'Settings', icon: Icons.settings_outlined, selectedIcon: Icons.settings),
  ];
}

/// Responsive scaffold: bottom nav on mobile, navigation rail on tablet/desktop.
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, breakpoint, isMobile, isTablet, isDesktop) {
        if (isMobile) {
          return Scaffold(
            appBar: appBar,
            body: child,
            bottomNavigationBar: _BottomNavBar(
              currentPath: GoRouterState.of(context).uri.path,
            ),
            floatingActionButton: floatingActionButton,
          );
        }
        return Scaffold(
          appBar: appBar,
          body: Row(
            children: [
              _NavRail(
                currentPath: GoRouterState.of(context).uri.path,
              ),
              Expanded(child: child),
            ],
          ),
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedIndex(currentPath),
      onDestinationSelected: (index) => _onSelect(context, index),
      destinations: NavDestination.all
          .map(
            (d) => NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon ?? d.icon),
              label: d.label,
            ),
          )
          .toList(),
    );
  }

  int _selectedIndex(String path) {
    final i = NavDestination.all.indexWhere((d) => path == d.path || path.startsWith('${d.path}/'));
    return i >= 0 ? i : 0;
  }

  void _onSelect(BuildContext context, int index) {
    final path = NavDestination.all[index].path;
    context.go(path);
  }
}

class _NavRail extends StatelessWidget {
  const _NavRail({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: _selectedIndex(currentPath),
      onDestinationSelected: (index) => _onSelect(context, index),
      labelType: NavigationRailLabelType.all,
      destinations: NavDestination.all
          .map(
            (d) => NavigationRailDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon ?? d.icon),
              label: Text(d.label),
            ),
          )
          .toList(),
    );
  }

  int _selectedIndex(String path) {
    final i = NavDestination.all.indexWhere((d) => path == d.path || path.startsWith('${d.path}/'));
    return i >= 0 ? i : 0;
  }

  void _onSelect(BuildContext context, int index) {
    final path = NavDestination.all[index].path;
    context.go(path);
  }
}
