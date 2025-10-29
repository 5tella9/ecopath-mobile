import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/features_screen.dart';
import 'screens/scantrash_screen.dart';
import 'screens/games_screen.dart';
import 'screens/profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _index;

  // Keep the order: Dashboard, Features, Scan, Games, Profile
  final List<Widget> _pages =  [
    const Dashboard(),
    const FeaturesScreen(),
    const ScanTrashScreen(),
    const GamesScreen(),
    const Profile(key: ValueKey('profile')),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _pages.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: _pages,
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          border: Border(
            top: BorderSide(
              color: AppTheme.divider,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedItemColor: AppTheme.selected,
          unselectedItemColor: AppTheme.muted,
          items: [
            _navItem('assets/icons/board.svg', 'Dashboard', 0),
            _navItem('assets/icons/dashboard.svg', 'Features', 1),
            _navItem('assets/icons/camera.svg', 'Scan', 2),
            _navItem('assets/icons/game.svg', 'Games', 3),
            _navItem('assets/icons/profile.svg', 'Profile', 4),
          ],
        ),
      ),
    );
  }

    BottomNavigationBarItem _navItem(String asset, String label, int index) {
    final bool isSelected = _index == index;

    // Special case for Scan tab (index == 2): use a Material icon instead of the SVG.
    // This guarantees you SEE an icon even if camera.svg is weird.
    if (index == 2) {
      return BottomNavigationBarItem(
        icon: Icon(
          Icons.camera_alt_outlined,
          size: 26,
          color: isSelected ? AppTheme.selected : AppTheme.muted,
        ),
        label: label,
      );
    }

    // everyone else (board.svg, dashboard.svg, game.svg, profile.svg)
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        asset,
        width: 26,
        height: 26,
        colorFilter: ColorFilter.mode(
          isSelected ? AppTheme.selected : AppTheme.muted,
          BlendMode.srcIn,
        ),
      ),
      label: label,
    );
  }
}