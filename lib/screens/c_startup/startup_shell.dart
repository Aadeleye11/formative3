import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'dashboard_screen.dart';
import 'pipeline_screen.dart';
import 'postings_screen.dart';
import 'startup_profile_screen.dart';

class StartupShell extends StatefulWidget {
  final int initialIndex;
  const StartupShell({super.key, this.initialIndex = 0});

  @override
  State<StartupShell> createState() => _StartupShellState();
}

class _StartupShellState extends State<StartupShell> {
  late int index = widget.initialIndex;

  static const _items = [
    NavItemSpec(
      icon: Symbols.dashboard_rounded,
      activeIcon: Symbols.dashboard_rounded,
      label: 'Dashboard',
    ),
    NavItemSpec(
      icon: Symbols.description_rounded,
      activeIcon: Symbols.description_rounded,
      label: 'Postings',
    ),
    NavItemSpec(
      icon: Symbols.group_rounded,
      activeIcon: Symbols.group_rounded,
      label: 'Applicants',
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
        children: const [
          DashboardScreen(),
          PostingsScreen(),
          PipelineScreen(),
          StartupProfileScreen(),
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
