import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart'; // you can keep or remove if unused
import 'screens/dashboard_screen.dart';
import 'screens/features_screen.dart';
import 'screens/scantrash_screen.dart';
import 'screens/games_screen.dart';
import 'screens/profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({
    super.key,
    this.initialIndex = 0,
    this.showGuideOnStart = true, // keep true while testing
  });

  final int initialIndex;
  final bool showGuideOnStart;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  static const int tabCount = 5;

  late int _index;

  // user guide
  bool _showGuide = false;
  int _guideStep = 0; // 0=Dashboard,1=Features,2=Scan,3=Games,4=Profile

  final List<Widget> _pages = const [
    Dashboard(),
    FeaturesScreen(),
    ScanTrashScreen(),
    GamesScreen(),
    Profile(key: ValueKey('profile')),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _pages.length - 1);
    _showGuide = widget.showGuideOnStart;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: IndexedStack(
              index: _index,
              children: _pages,
            ),
          ),
          if (_showGuide) _buildUserGuideOverlay(),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    final cs = Theme.of(context).colorScheme;

    // colors that automatically change for light / dark theme
    final Color bgColor = cs.surface;
    final Color borderColor = cs.outline.withOpacity(0.3);
    final Color selectedColor = cs.primary;
    final Color mutedColor = cs.onSurface.withOpacity(0.6);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: bgColor,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: selectedColor,
        unselectedItemColor: mutedColor,
        showUnselectedLabels: true,
        items: [
          _navItem('assets/icons/board.svg', 'Dashboard', 0, selectedColor, mutedColor),
          _navItem('assets/icons/dashboard.svg', 'Features', 1, selectedColor, mutedColor),

          // Scan uses Material icon
          BottomNavigationBarItem(
            icon: Icon(
              Icons.camera_alt_outlined,
              size: 26,
              color: _index == 2 ? selectedColor : mutedColor,
            ),
            label: 'Scan',
          ),

          _navItem('assets/icons/game.svg', 'Games', 3, selectedColor, mutedColor),
          _navItem('assets/icons/profile.svg', 'Profile', 4, selectedColor, mutedColor),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(
    String asset,
    String label,
    int index,
    Color selectedColor,
    Color mutedColor,
  ) {
    final bool isSelected = _index == index;
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        asset,
        width: 26,
        height: 26,
        colorFilter: ColorFilter.mode(
          isSelected ? selectedColor : mutedColor,
          BlendMode.srcIn,
        ),
      ),
      label: label,
    );
  }

  // ---------------------------------------------------------------------------
  // USER GUIDE OVERLAY (only arrows + text, no circles)
  // ---------------------------------------------------------------------------

  Widget _buildUserGuideOverlay() {
    final bool isLastStep = _guideStep == 4;

    return IgnorePointer(
      ignoring: false,
      child: Container(
        color: Colors.black54,
        child: Stack(
          children: [
            _buildArrowCoachmark(),

            // bottom buttons
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _skipGuide,
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _nextGuide,
                        child: Text(isLastStep ? 'Got it!' : 'Next'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Arrow + text that points to the current bottom-nav icon.
  Widget _buildArrowCoachmark() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        // which tab we are pointing at
        final int tabIndex = _guideStep.clamp(0, tabCount - 1);

        // horizontal center of that tab
        final double iconCenterX = width * (tabIndex + 0.5) / tabCount;

        // text block
        const double textWidth = 250.0;
        double leftText = iconCenterX - textWidth / 2;
        if (leftText < 16) leftText = 16;
        if (leftText + textWidth > width - 16) {
          leftText = width - 16 - textWidth;
        }

        // you can tweak these to change arrow length / position
        const double arrowBottomOffset = 40.0; // distance from bottom of screen
        const double arrowHeight = 160.0; // height of the curve

        return Stack(
          children: [
            // TEXT
            Positioned(
              left: leftText,
              bottom: arrowBottomOffset + arrowHeight + 16,
              child: SizedBox(
                width: textWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _guideTitleForStep(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _guideTextForStep(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // CURVED ARROW
            Positioned(
              left: iconCenterX - 15, // center arrow horizontally on icon
              bottom: arrowBottomOffset,
              child: CustomPaint(
                size: const Size(30, arrowHeight),
                painter: CurvedArrowPainter(),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------- guide text helpers ----------------

  String _guideTitleForStep() {
    switch (_guideStep) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Features';
      case 2:
        return 'Scan';
      case 3:
        return 'Games';
      case 4:
      default:
        return 'Profile';
    }
  }

  String _guideTextForStep() {
    switch (_guideStep) {
      case 0:
        return 'See today’s eco score, usage charts, and quick missions at a glance.';
      case 1:
        return 'Open electricity, gas, carbon, and shop to explore all EcoPath features.';
      case 2:
        return 'Tap Scan to open the camera and let EcoPath help you sort your trash.';
      case 3:
        return 'Play eco games and quizzes to learn and earn XP for your profile.';
      case 4:
      default:
        return 'View your profile, eco stats, achievements, and settings here.';
    }
  }

  // ---------------- guide navigation ----------------

  void _nextGuide() {
    setState(() {
      if (_guideStep < 4) {
        _guideStep++;
        _index = _guideStep; // switch underlying tab to match arrow
      } else {
        _showGuide = false;
        // TODO: mark "hasSeenGuide" = true in backend/local storage
      }
    });
  }

  void _skipGuide() {
    setState(() {
      _showGuide = false;
      // TODO: also mark hasSeenGuide = true if you never want to show again
    });
  }
}

// ---------------------------------------------------------------------------
// Curved arrow painter (outside the widget class)
// ---------------------------------------------------------------------------

class CurvedArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();

    // Start at top centre of the painter
    path.moveTo(size.width / 2, 0);

    // Long smooth curve going down toward the icon
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.4,
      size.width / 2,
      size.height,
    );

    // Arrow head
    path.moveTo(size.width / 2, size.height);
    path.relativeLineTo(-6, -12);
    path.moveTo(size.width / 2, size.height);
    path.relativeLineTo(6, -12);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CurvedArrowPainter oldDelegate) => false;
}
