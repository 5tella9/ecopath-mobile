import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/features_screen.dart';
import 'screens/games_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _index;

  final _pages = [
    Dashboard(),
    FeaturesScreen(),
    GamesScreen(),
    NotificationsScreen(),
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
      body: SafeArea(child: IndexedStack(index: _index, children: _pages)),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: [
            _navItem('assets/icons/board.svg', 'Dashboard', 0),
            _navItem('assets/icons/dashboard.svg', 'Features', 1),
            _navItem('assets/icons/game.svg', 'Games', 2),
            _navItem('assets/icons/bell.svg', 'Notification', 3),
            _navItem('assets/icons/profile.svg', 'Profile', 4),
          ],
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedItemColor: AppTheme.selected,
          unselectedItemColor: AppTheme.muted,
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(String asset, String label, int index) {
    final bool isSelected = _index == index;
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
