// lib/ui/screens/profile_screen.dart
import 'package:ecopath/ui/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'setting_screen.dart';
import 'edit_avatar_screen.dart';
import 'notifications_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  final Random _rand = Random();

  // Random mock data for recycle days
  final Map<int, int> _recycleDays = {};

  @override
  void initState() {
    super.initState();
    // Create random recycle days
    for (int i = 1; i <= 31; i++) {
      if (_rand.nextBool()) {
        _recycleDays[i] = _rand.nextInt(20) + 5; // 5–25 points
      }
    }
  }

  // Calendar helpers
  int _daysInMonth(DateTime d) {
    final firstNextMonth = DateTime(d.year, d.month + 1, 1);
    return firstNextMonth.subtract(const Duration(days: 1)).day;
  }

  int _firstWeekdayOfMonth(DateTime d) {
    final w = DateTime(d.year, d.month, 1).weekday;
    return w % 7; // Sun=0
  }

  String get _monthLabel {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  // ---------------- Avatar Action Sheet ----------------
  void _showAvatarActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Change Avatar',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
              ),
              _ActionSheetItem(text: 'Take Photo', onTap: () {}),
              _ActionSheetItem(text: 'Choose from album', onTap: () {}),
              _ActionSheetItem(
                text: 'Choose from character',
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditAvatarScreen()),
                  );
                },
              ),
              const SizedBox(height: 8),
              _ActionSheetItem(
                isCancel: true,
                text: 'Cancel',
                onTap: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ---------- New Info Alert for ? ----------
  void _showRecycleInfo() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Track your eco journey! Each time you recycle and earn points, your activity appears here. Check your streaks and see how consistent your recycling habits are!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF00221C),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00221C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Got it!", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Info Box for Recycle Icon ----------
  void _showDayInfo(int day, int points) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Oct $day, ${_focusedMonth.year}",
                style: const TextStyle(
                  color: Color(0xFF00221C),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You earned $points points on this day!",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF00221C), fontSize: 14),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00221C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Got it!", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ---- navigate helpers (force rebuild after return) ----
  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    // when we come back, rebuild the header so icons show again
    setState(() {});
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF00221C);
    const pale = Color(0xFFE0F0ED);
    const bg = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: bg,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top right icons
                Padding(
                  padding: const EdgeInsets.only(top: 64, right: 18, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _HeaderIcon(
                        asset: 'assets/icons/bell.svg',
                        onTap: _openNotifications,
                        allowOriginalColor: false,
                        isBold: true,
                      ),
                      const SizedBox(width: 8),
                      _HeaderIcon(
                        asset: 'assets/icons/setting.svg',
                        onTap: _openSettings,
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 29, bottom: 10),
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      color: dark,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // avatar
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipOval(
                            child: Image.network(
                              'https://storage.googleapis.com/tagjs-prod.appspot.com/v1/a2h7Z2oc98/bekcjzgx_expires_30_days.png',
                              width: 84,
                              height: 84,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: -4,
                            top: -4,
                            child: GestureDetector(
                              onTap: _showAvatarActionSheet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Stella',
                        style: TextStyle(color: dark, fontSize: 18),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _StatBlock(value: '34', label: 'Points earned'),
                      _StatBlock(value: '16', label: 'Progress done'),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // recycle history + ?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Recycle History',
                        style: TextStyle(color: dark, fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _showRecycleInfo,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: dark.withOpacity(0.4)),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '?',
                            style: TextStyle(fontSize: 12, color: dark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // calendar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: pale,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: _prevMonth,
                              icon: const Icon(Icons.chevron_left, color: dark),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  _monthLabel,
                                  style: const TextStyle(
                                    color: dark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _nextMonth,
                              icon: const Icon(Icons.chevron_right, color: dark),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            _Weekday('S'),
                            _Weekday('M'),
                            _Weekday('T'),
                            _Weekday('W'),
                            _Weekday('T'),
                            _Weekday('F'),
                            _Weekday('S'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildDaysGrid(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysGrid() {
    const dark = Color(0xFF00221C);
    const dayStyle = TextStyle(color: dark, fontSize: 13);
    final firstWeekday = _firstWeekdayOfMonth(_focusedMonth);
    final totalDays = _daysInMonth(_focusedMonth);
    final today = DateTime.now();

    final leading = firstWeekday;
    final cells = leading + totalDays;
    final padded = (cells % 7 == 0) ? cells : cells + (7 - cells % 7);

    return Column(
      children: List.generate(padded ~/ 7, (row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (col) {
              final index = row * 7 + col;
              final dayNum = index - leading + 1;
              if (dayNum < 1 || dayNum > totalDays) {
                return const SizedBox(width: 32, height: 28);
              }

              final isToday = today.year == _focusedMonth.year &&
                  today.month == _focusedMonth.month &&
                  today.day == dayNum;

              final recyclePoints = _recycleDays[dayNum];

              if (recyclePoints != null) {
                return GestureDetector(
                  onTap: () => _showDayInfo(dayNum, recyclePoints),
                  child: Image.asset(
                    'assets/images/recycle.png',
                    width: 22,
                    height: 22,
                  ),
                );
              }

              return Container(
                width: 32,
                height: 28,
                alignment: Alignment.center,
                decoration: isToday
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: dark, width: 1),
                      )
                    : null,
                child: Text('$dayNum', style: dayStyle),
              );
            }),
          ),
        );
      }),
    );
  }
}

// ========== Helper Widgets ==========

class _HeaderIcon extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  final bool allowOriginalColor;
  final bool isBold;

  const _HeaderIcon({
    required this.asset,
    required this.onTap,
    this.allowOriginalColor = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = const Color(0xFF00221C);

    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isBold)
                // shadow layer for “thick” look
                SvgPicture.asset(
                  asset,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    baseColor.withOpacity(0.4),
                    BlendMode.srcIn,
                  ),
                ),
              SvgPicture.asset(
                asset,
                width: isBold ? 26 : 20,
                height: isBold ? 26 : 20,
                colorFilter: ColorFilter.mode(baseColor, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ActionSheetItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isCancel;

  const _ActionSheetItem({
    required this.text,
    required this.onTap,
    this.isCancel = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isCancel ? const Color(0xFF007AFF) : Colors.black;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isCancel ? 16 : 14,
          ),
          decoration: BoxDecoration(
            border: Border(
              top: isCancel
                  ? BorderSide.none
                  : const BorderSide(
                      color: Color(0xFFE0E0E0),
                      width: 1,
                    ),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isCancel ? 18 : 17,
                fontWeight:
                    isCancel ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;
  const _StatBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF00221C);
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: dark,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: dark, fontSize: 14),
        ),
      ],
    );
  }
}

class _Weekday extends StatelessWidget {
  final String text;
  const _Weekday(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF00221C),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
