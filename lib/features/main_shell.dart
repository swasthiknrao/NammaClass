import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../core/models/user_model.dart';
import '../routing/app_routes.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final destinations = _destinationsFor(role);
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(currentPath, destinations);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        onDestinationSelected: (index) {
          context.go(destinations[index].route);
        },
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon ?? d.icon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }

  List<_NavDest> _destinationsFor(UserRole? role) {
    switch (role) {
      case UserRole.parent:
        return [
          _NavDest(
            AppRoutes.parentHome,
            'Home',
            Icons.home_outlined,
            Icons.home,
          ),
          _NavDest(
            AppRoutes.parentAttendance,
            'Attendance',
            Icons.calendar_month_outlined,
            Icons.calendar_month,
          ),
          _NavDest(
            AppRoutes.parentFees,
            'Fees',
            Icons.account_balance_wallet_outlined,
            Icons.account_balance_wallet,
          ),
          _NavDest(
            AppRoutes.parentDiary,
            'Diary',
            Icons.book_outlined,
            Icons.book,
          ),
          _NavDest(
            AppRoutes.parentProfile,
            'Profile',
            Icons.person_outline,
            Icons.person,
          ),
        ];
      case UserRole.teacher:
        return [
          _NavDest(
            AppRoutes.teacherHome,
            'Home',
            Icons.home_outlined,
            Icons.home,
          ),
          _NavDest(
            AppRoutes.teacherAttendance,
            'Attendance',
            Icons.how_to_reg_outlined,
            Icons.how_to_reg,
          ),
          _NavDest(
            AppRoutes.teacherDiary,
            'Diary',
            Icons.edit_note_outlined,
            Icons.edit_note,
          ),
          _NavDest(
            AppRoutes.teacherStudents,
            'Students',
            Icons.groups_outlined,
            Icons.groups,
          ),
          _NavDest(
            AppRoutes.teacherProfile,
            'Profile',
            Icons.person_outline,
            Icons.person,
          ),
        ];
      case UserRole.student:
        return [
          _NavDest(
            AppRoutes.studentHome,
            'Home',
            Icons.home_outlined,
            Icons.home,
          ),
          _NavDest(
            AppRoutes.studentAcademics,
            'Academics',
            Icons.school_outlined,
            Icons.school,
          ),
          _NavDest(
            AppRoutes.studentLibrary,
            'Library',
            Icons.local_library_outlined,
            Icons.local_library,
          ),
          _NavDest(
            AppRoutes.studentProfile,
            'Profile',
            Icons.person_outline,
            Icons.person,
          ),
        ];
      default: // admin / principal
        return [
          _NavDest(
            AppRoutes.adminHome,
            'Dashboard',
            Icons.dashboard_outlined,
            Icons.dashboard,
          ),
          _NavDest(
            AppRoutes.adminApprovals,
            'Approvals',
            Icons.approval_outlined,
            Icons.approval,
          ),
          _NavDest(
            AppRoutes.adminBroadcast,
            'Broadcast',
            Icons.campaign_outlined,
            Icons.campaign,
          ),
          _NavDest(
            AppRoutes.adminPeople,
            'People',
            Icons.people_outline,
            Icons.people,
          ),
          _NavDest(
            AppRoutes.adminProfile,
            'Profile',
            Icons.person_outline,
            Icons.person,
          ),
        ];
    }
  }

  int _selectedIndex(String path, List<_NavDest> dests) {
    for (int i = 0; i < dests.length; i++) {
      if (path.startsWith(dests[i].route)) return i;
    }
    return 0;
  }
}

class _NavDest {
  const _NavDest(this.route, this.label, this.icon, [this.selectedIcon]);
  final String route;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
}
