import 'package:ecopath/core/api_test.dart';
import 'package:flutter/material.dart';
import 'quiz_screen.dart'; // keep this import
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  DashboardState createState() => DashboardState();
}

enum TimeRange { day, week, month, sixMonth, year }

class DashboardState extends State<Dashboard> {
  // Alike font helper
  TextStyle _ts(double size,
          {FontWeight? fw, Color color = Colors.black, double? height}) =>
      GoogleFonts.alike(fontSize: size, fontWeight: fw, color: color, height: height);

  // --------- STATE for the stats ----------
  TimeRange _range = TimeRange.week;

  // Demo data builder — replace with your real data later
  (List<String>, List<int>) _buildSeries(TimeRange r) {
    switch (r) {
      case TimeRange.day:
        final labels = ['0', '3', '6', '9', '12', '15', '18', '21'];
        final vals = [10, 25, 40, 60, 55, 35, 70, 30];
        return (labels, vals);
      case TimeRange.week:
        final labels = ['Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
        final vals = [120, 320, 260, 20, 180, 160, 15];
        return (labels, vals);
      case TimeRange.month:
        final labels = ['W1', 'W2', 'W3', 'W4'];
        final vals = [850, 920, 740, 1020];
        return (labels, vals);
      case TimeRange.sixMonth:
        final labels = ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
        final vals = [1800, 2200, 1950, 2100, 2400, 2300];
        return (labels, vals);
      case TimeRange.year:
        final labels = ['N', 'D', 'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O'];
        final vals = [2000, 2100, 1800, 2200, 2500, 2300, 2400, 2600, 1900, 2100, 2500, 2700];
        return (labels, vals);
    }
  }

  Future<void> _confirmAndGo({
    required String title,
    required String message,
    required VoidCallback onYes,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: _ts(18)),
        content: Text(message, style: _ts(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('No', style: _ts(14, color: const Color(0xFF00221C))),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Yes', style: _ts(14, color: Colors.white)),
          ),
        ],
      ),
    );
    if (res == true) onYes();
  }

  // ---- Test backend helper (uses ApiTest.testSaveUser) ----
  Future<void> _testBackend() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        const SnackBar(content: Text('Sending test request to backend…')),
      );
      await ApiTest.testSaveUser();
      messenger.showSnackBar(
        const SnackBar(content: Text('Done. Check Run console for status/body.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Request failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (labels, values) = _buildSeries(_range);
    final int total = values.fold<int>(0, (a, b) => a + b);
    final double avg = values.isEmpty ? 0.0 : total / values.length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- Profile card (F1EDED) --------
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EDED),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        'assets/images/profileimg.png',
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 6),
                            child: Text('Stella', style: _ts(20, fw: FontWeight.w600)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('Current Rank : 9', style: _ts(18)),
                          ),
                          Row(
                            children: [
                              Image.asset('assets/images/star.png', width: 28, height: 28),
                              const SizedBox(width: 8),
                              Text('Points : 94', style: _ts(18)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // -------- Impact card (copy style) --------
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 227, 207, 239),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Impact This Week:',
                      style: _ts(18, fw: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),

                    // Electricity ↓12% ⚡
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Electricity ↓ 12%',
                          style: _ts(16, fw: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Text('⚡', style: _ts(20)),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Gas ↑4% 🔥
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Gas ↑ 4%',
                          style: _ts(16, fw: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Text('🔥', style: _ts(20)),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Overall Score: 78 🌱
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Overall Score: 78',
                          style: _ts(16, fw: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Text('🌱', style: _ts(20)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // -------- Top 2 boxes --------
              Row(
                children: [
                  // Recycle
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        _confirmAndGo(
                          title: 'Recycle',
                          message: 'Are you ready to recycle?',
                          onYes: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RecycleScreen()),
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB7D7E2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Did you recycle item?', style: _ts(9)),
                                  const SizedBox(height: 6),
                                  Text('Go & Recycle!', style: _ts(11, fw: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 20,
                              bottom: -12,
                              child: Image.asset(
                                'assets/images/dashboardg1.png',
                                width: 95,
                                height: 95,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Quiz
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        _confirmAndGo(
                          title: 'Quiz',
                          message: 'Are you ready to take quiz?',
                          onYes: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const QuizScreen()),
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFF90DEC9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Can you do a challenge?', style: _ts(9)),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Take the quiz and get full marks!',
                                    textAlign: TextAlign.center,
                                    style: _ts(11, fw: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 60,
                              bottom: -27,
                              child: Image.asset(
                                'assets/images/dashboardg.png',
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // -------- Bottom banner --------
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  _confirmAndGo(
                    title: 'Education',
                    message: 'Do you want to learn more?',
                    onYes: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EducationScreen()),
                      );
                    },
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  height: 190,
                  width: 500,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00221C),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 22, 14, 22),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Educate yourself', style: _ts(12, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text('and', style: _ts(12, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(
                            '“Protect” the environment',
                            style: _ts(14, fw: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                      Positioned(
                        right: -40,
                        bottom: -22,
                        child: Image.asset(
                          'assets/images/dashboardg2.png',
                          width: 175,
                          height: 170,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // ================== STATS SECTION ==================
              StatsSectionPoints(
                range: _range,
                onRangeChanged: (r) => setState(() => _range = r),
                labels: labels,
                values: values,
                avg: avg,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ---- Floating action button to test backend ----
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _testBackend,
        label: const Text('Test Backend'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}

// ---------- Stats Section widget ----------
class StatsSectionPoints extends StatelessWidget {
  final TimeRange range;
  final void Function(TimeRange) onRangeChanged;
  final List<String> labels;
  final List<int> values;
  final double avg;

  const StatsSectionPoints({
    super.key,
    required this.range,
    required this.onRangeChanged,
    required this.labels,
    required this.values,
    required this.avg,
  });

  @override
  Widget build(BuildContext context) {
    final ts = GoogleFonts.alike;
    final maxY = (values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b)).toDouble();
    final yMax = (maxY == 0 ? 10 : (maxY * 1.25)).ceilToDouble();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented control row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Segment(
                selected: range == TimeRange.day,
                label: 'D',
                onTap: () => onRangeChanged(TimeRange.day),
              ),
              _Segment(
                selected: range == TimeRange.week,
                label: 'W',
                onTap: () => onRangeChanged(TimeRange.week),
              ),
              _Segment(
                selected: range == TimeRange.month,
                label: 'M',
                onTap: () => onRangeChanged(TimeRange.month),
              ),
              _Segment(
                selected: range == TimeRange.sixMonth,
                label: '6M',
                onTap: () => onRangeChanged(TimeRange.sixMonth),
              ),
              _Segment(
                selected: range == TimeRange.year,
                label: 'Y',
                onTap: () => onRangeChanged(TimeRange.year),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Average points line
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(avg.toStringAsFixed(0), style: ts(fontSize: 36, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text('points', style: ts(fontSize: 18, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _subtitleForRange(range),
            style: ts(fontSize: 12, color: Colors.black54),
          ),

          const SizedBox(height: 10),

          // Bar chart
          SizedBox(
            height: 220,
            width: double.infinity,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(enabled: false), // disable red highlight
                maxY: yMax,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: yMax / 4,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: Colors.black12, strokeWidth: 1),
                  getDrawingVerticalLine: (v) =>
                      FlLine(color: Colors.black12, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: yMax / 4,
                      getTitlesWidget: (value, meta) => Text(
                        value == 0 ? '0' : value.toInt().toString(),
                        style: ts(fontSize: 10, color: Colors.black45),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labels[idx],
                            style: ts(fontSize: 10, color: Colors.black54),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(values.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i].toDouble(),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        color: const Color(0xFFFF7A33), // orange bars
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _subtitleForRange(TimeRange r) {
    final now = DateTime.now();
    switch (r) {
      case TimeRange.day:
        return 'Today, ${_fmtDate(now)}';
      case TimeRange.week:
        final start = now.subtract(const Duration(days: 6));
        return '${_fmtDate(start)} — ${_fmtDate(now)}';
      case TimeRange.month:
        final start = DateTime(now.year, now.month, 1);
        return 'Since ${_fmtMonth(start)}';
      case TimeRange.sixMonth:
        final start = DateTime(now.year, now.month - 5, 1);
        return '${_fmtMonth(start)} — ${_fmtMonth(now)}';
      case TimeRange.year:
        final start = DateTime(now.year, 1, 1);
        return '${start.year} — ${now.year}';
    }
  }

  static String _fmtDate(DateTime d) => '${_monthShort[d.month]} ${d.day}, ${d.year}';
  static String _fmtMonth(DateTime d) => '${_monthShort[d.month]} ${d.year}';

  static const _monthShort = [
    '',
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}

class _Segment extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;
  const _Segment({required this.selected, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ts = GoogleFonts.alike;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2F2F2F) : const Color(0xFFEAEAEA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: ts(
            fontSize: 12,
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ---------- temporary placeholders so it runs now ----------
class RecycleScreen extends StatelessWidget {
  const RecycleScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Recycle', style: GoogleFonts.alike())),
        body: Center(child: Text('Recycle flow here.', style: GoogleFonts.alike(fontSize: 16))),
      );
}

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Education', style: GoogleFonts.alike())),
        body: Center(
            child: Text('Education content here.', style: GoogleFonts.alike(fontSize: 16))),
      );
}
