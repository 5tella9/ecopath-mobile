import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'setting_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // --- helpers for calendar ---
  int _daysInMonth(DateTime d) {
    final firstNextMonth = DateTime(d.year, d.month + 1, 1);
    return firstNextMonth.subtract(const Duration(days: 1)).day;
  }

  int _firstWeekdayOfMonth(DateTime d) {
    final w = DateTime(d.year, d.month, 1).weekday; // Mon=1
    return w % 7; // Sun->0, Mon->1, ..., Sat->6
  }

  String get _monthLabel {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec'
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
                // 🌿 Top right icons: service.svg (left) + setting.svg (right)
                Padding(
                  padding: const EdgeInsets.only(top: 64, right: 18, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _HeaderIcon(
                        asset: 'assets/icons/service.svg', // left icon
                        onTap: () {},
                        allowOriginalColor: true, // 👈 show SVG as-is
                      ),
                      const SizedBox(width: 8),
                      _HeaderIcon(
                        asset: 'assets/icons/setting.svg', // right icon
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Title
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

                // Avatar
                const SizedBox(height: 8),
                Center(
                  child: ClipOval(
                    child: Image.network(
                      'https://storage.googleapis.com/tagjs-prod.appspot.com/v1/a2h7Z2oc98/bekcjzgx_expires_30_days.png',
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Name
                const Center(
                  child: Text(
                    'Stella',
                    style: TextStyle(color: dark, fontSize: 18),
                  ),
                ),

                const SizedBox(height: 24),

                // Points / Progress
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

                // Recycle History header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('Recycle History',
                          style: TextStyle(color: dark, fontSize: 16)),
                      const SizedBox(width: 6),
                      Image.network(
                        'https://storage.googleapis.com/tagjs-prod.appspot.com/v1/a2h7Z2oc98/j21ho3mf_expires_30_days.png',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // --- Calendar Card ---
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
                        // Month header with arrows
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _prevMonth,
                                icon: const Icon(Icons.chevron_left,
                                    size: 22, color: dark),
                                splashRadius: 18,
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    _monthLabel,
                                    style: const TextStyle(
                                      color: dark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _nextMonth,
                                icon: const Icon(Icons.chevron_right,
                                    size: 22, color: dark),
                                splashRadius: 18,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Weekday header
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

                        // Days grid
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

  // --- Calendar builder ---
  Widget _buildDaysGrid() {
    const dayStyle = TextStyle(color: Color(0xFF00221C), fontSize: 13);
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

              final isToday = (today.year == _focusedMonth.year) &&
                  (today.month == _focusedMonth.month) &&
                  (today.day == dayNum);

              return Container(
                width: 32,
                height: 28,
                alignment: Alignment.center,
                decoration: isToday
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF00221C), width: 1),
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

// 🌿 Reusable header icon widget
class _HeaderIcon extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  final bool allowOriginalColor;

  const _HeaderIcon({
    required this.asset,
    required this.onTap,
    this.allowOriginalColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: SvgPicture.asset(
              asset,
              width: 20,
              height: 20,
              // If SVG color filter breaks, show original fill colors
              colorFilter: allowOriginalColor
                  ? null
                  : const ColorFilter.mode(
                      Color(0xFF00221C), BlendMode.srcIn,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Stat block ---
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
        Text(label, style: const TextStyle(color: dark, fontSize: 14)),
      ],
    );
  }
}

// --- Weekday header text ---
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
