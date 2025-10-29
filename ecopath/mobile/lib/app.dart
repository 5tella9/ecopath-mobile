import 'package:flutter/material.dart';

/// TEMP stub versions of each screen so this file can run.
/// In the real app you already have the actual screens in
/// lib/ui/screens/... and you use RootShell instead.

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Dashboard Screen'));
}

class Features extends StatelessWidget {
  const Features({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Features Screen'));
}

class ScanTrash extends StatelessWidget {
  const ScanTrash({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Scan Trash Screen'));
}

class Games extends StatelessWidget {
  const Games({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Games Screen'));
}

// Renamed to avoid clashing with the real Profile screen in ui/screens/profile_screen.dart
class ProfileStub extends StatelessWidget {
  const ProfileStub({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Profile Screen'));
}

class EcoPathApp extends StatefulWidget {
  const EcoPathApp({super.key});
  @override
  State<EcoPathApp> createState() => _EcoPathAppState();
}

class _EcoPathAppState extends State<EcoPathApp> {
  int _selectedIndex = 0;

  // Order: Dashboard, Features, Scan, Games, Profile
  final List<Widget> _pages = const [
    Dashboard(),
    Features(),
    ScanTrash(),
    Games(),
    ProfileStub(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            label: 'Features',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset_outlined),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
