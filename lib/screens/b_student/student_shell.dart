import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'applications_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class StudentShell extends StatefulWidget {
  final int initialIndex;
  const StudentShell({super.key, this.initialIndex = 0});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  late int index = widget.initialIndex;

  static const _items = [
    NavItemSpec(
      icon: Symbols.home_rounded,
      activeIcon: Symbols.home_rounded,
      label: 'Home',
    ),
    NavItemSpec(
      icon: Symbols.search_rounded,
      activeIcon: Symbols.search_rounded,
      label: 'Explore',
    ),
    NavItemSpec(
      icon: Symbols.work_rounded,
      activeIcon: Symbols.work_rounded,
      label: 'Applications',
    ),
    NavItemSpec(
      icon: Symbols.person_rounded,
      activeIcon: Symbols.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: index,
        children: [
          HomeScreen(onNavigateToTab: (i) => setState(() => index = i)),
          const ExploreScreen(),
          const ApplicationsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: _items,
      ),
    );
  }
}
