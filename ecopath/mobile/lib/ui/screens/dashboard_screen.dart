// lib/ui/screens/dashboard_screen.dart
import 'package:ecopath/core/api_test.dart';
import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

// NEW: real screens
import 'recycle_screen.dart';
import 'education_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  DashboardState createState() => DashboardState();
}

enum TimeRange { day, week, month, sixMonth, year }

class DashboardState extends State<Dashboard> {
  TextStyle _ts(BuildContext context, double size,
          {FontWeight? fw, Color? color, double? height}) =>
      GoogleFonts.alike(
        fontSize: size,
        fontWeight: fw,
        color: color ?? Theme.of(context).colorScheme.onSurface,
        height: height,
      );

  TimeRange _range = TimeRange.week;

  (List<String>, List<int>) _buildSeries(TimeRange r) {
    switch (r) {
      case TimeRange.day:
        return (['0', '3', '6', '9', '12', '15', '18', '21'],
            [10, 25, 40, 60, 55, 35, 70, 30]);
      case TimeRange.week:
        return (
          ['Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'],
          [120, 320, 260, 20, 180, 160, 15]
        );
      case TimeRange.month:
        return (
          ['W1', 'W2', 'W3', 'W4'],
          [850, 920, 740, 1020]
        );
      case TimeRange.sixMonth:
        return (
          ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
          [1800, 2200, 1950, 2100, 2400, 2300]
        );
      case TimeRange.year:
        return (
          ['N', 'D', 'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O'],
          [2000, 2100, 1800, 2200, 2500, 2300, 2400, 2600, 1900, 2100, 2500, 2700]
        );
    }
  }

  Future<void> _confirmAndGo({
    required String title,
    required String message,
    required VoidCallback onYes,
  }) async {
    final cs = Theme.of(context).colorScheme;
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(title, style: _ts(context, 18, fw: FontWeight.bold)),
        content: Text(message, style: _ts(context, 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('No', style: _ts(context, 14, color: cs.primary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: cs.primary),
            child: Text('Yes', style: _ts(context, 14, color: cs.onPrimary)),
          ),
        ],
      ),
    );
    if (res == true) onYes();
  }

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
      messenger.showSnackBar(SnackBar(content: Text('Request failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (labels, values) = _buildSeries(_range);
    final total = values.fold<int>(0, (a, b) => a + b);
    final avg = values.isEmpty ? 0.0 : total / values.length;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // -------- Profile Card --------
            Container(
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(.2),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(children: [
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
                        Text('Stella',
                            style: _ts(context, 20, fw: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Current Rank : 9', style: _ts(context, 18)),
                        const SizedBox(height: 6),
                        Row(children: [
                          Image.asset('assets/images/star.png',
                              width: 28, height: 28),
                          const SizedBox(width: 8),
                          Text('Points : 94', style: _ts(context, 18)),
                        ]),
                      ]),
                ),
              ]),
            ),

            const SizedBox(height: 16),

            // -------- Impact Card --------
            Container(
              decoration: BoxDecoration(
                color: cs.secondaryContainer.withOpacity(.25),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Impact This Week:',
                        style: _ts(context, 18, fw: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text('Electricity ↓ 12%', style: _ts(context, 16)),
                      const SizedBox(width: 8),
                      Text('⚡', style: _ts(context, 20))
                    ]),
                    Row(children: [
                      Text('Gas ↑ 4%', style: _ts(context, 16)),
                      const SizedBox(width: 8),
                      Text('🔥', style: _ts(context, 20))
                    ]),
                    Row(children: [
                      Text('Overall Score: 78', style: _ts(context, 16)),
                      const SizedBox(width: 8),
                      Text('🌱', style: _ts(context, 20))
                    ]),
                  ]),
            ),

            const SizedBox(height: 24),

            // --------------------------------------
            //         RECYCLE & QUIZ TILES
            // --------------------------------------
            Row(children: [
              Expanded(
                child: _dashboardTile(
                  context,
                  title: 'Did you recycle item today?',
                  subtitle: 'Go & Recycle!',
                  asset: 'assets/images/dashboardg1.png',
                  color: cs.primaryContainer.withOpacity(.4),
                  onTap: () {
                    _confirmAndGo(
                      title: 'Recycle item',
                      message:
                          'Do you want to recycle an item?',
                      onYes: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RecycleScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _dashboardTile(
                  context,
                  title: 'Do you want to challenge?',
                  subtitle: 'Take the quiz and get full marks!',
                  asset: 'assets/images/dashboardg.png',
                  color: cs.tertiaryContainer.withOpacity(.4),
                  onTap: () {
                    _confirmAndGo(
                      title: 'Challenge yourself',
                      message: 'Do you want to take a quiz now?',
                      onYes: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const QuizScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // -------------------------------------------------
            //                 EDUCATION BANNER
            // -------------------------------------------------
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                _confirmAndGo(
                  title: 'Educate yourself',
                  message:
                      'Do you want to learn more eco tips and lessons now?',
                  onYes: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EducationScreen(),
                      ),
                    );
                  },
                );
              },
              child: Container(
                width: 400,
                height: 190,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Educate yourself',
                            style: _ts(context, 12, color: cs.onPrimary)),
                        const SizedBox(height: 8),
                        Text('and',
                            style: _ts(context, 12, color: cs.onPrimary)),
                        const SizedBox(height: 8),
                        Text('“Protect” the environment',
                            style: _ts(context, 14,
                                fw: FontWeight.w600, color: cs.onPrimary)),
                      ],
                    ),

                    // girl image
                    Positioned(
                      bottom: -20,
                      right: -20,
                      child: Image.asset(
                        'assets/images/dashboardg2.png',
                        width: 175,
                        height: 175,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 26),

            StatsSectionPoints(
              range: _range,
              onRangeChanged: (r) => setState(() => _range = r),
              labels: labels,
              values: values,
              avg: avg,
            ),
          ]),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  //          DASHBOARD TILE WITH POSITIONED IMAGE
  // -----------------------------------------------------------
  Widget _dashboardTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String asset,
    required VoidCallback onTap,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: _ts(context, 10, fw: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      textAlign: TextAlign.center,
                      style: _ts(context, 11, fw: FontWeight.w600)),
                ],
              ),
            ),
            Positioned(
              bottom: -15,
              left: 0,
              right: 0,
              child: Image.asset(
                asset,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------
//                 STATS SECTION
// ---------------------------------------------------
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
    final cs = Theme.of(context).colorScheme;
    final ts = GoogleFonts.alike;

    final maxY =
        (values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b)).toDouble();
    final yMax = (maxY == 0 ? 10 : (maxY * 1.25)).ceilToDouble();
    final double step =
        ((yMax / 4).ceilToDouble()).clamp(1, double.maxFinite).toDouble();

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.3),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          for (final t in TimeRange.values)
            _Segment(
              selected: range == t,
              label: _labelFor(t),
              onTap: () => onRangeChanged(t),
            )
        ]),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(avg.toStringAsFixed(0),
              style: ts(fontSize: 36, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('points',
              style: ts(fontSize: 18, color: cs.onSurface.withOpacity(.6))),
        ]),
        const SizedBox(height: 6),
        Text(_subtitleForRange(range),
            style: ts(fontSize: 12, color: cs.onSurfaceVariant)),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(enabled: false),
              maxY: yMax,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: step,
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: step,
                    getTitlesWidget: (value, meta) {
                      if (value != 0 && value % step != 0) {
                        return const SizedBox();
                      }
                      return Text(
                        value.toInt().toString(),
                        style: ts(fontSize: 10, color: cs.onSurfaceVariant),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      final idx = val.toInt();
                      if (idx < 0 || idx >= labels.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          labels[idx],
                          style: ts(fontSize: 10, color: cs.onSurfaceVariant),
                        ),
                      );
                    },
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(values.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: values[i].toDouble(),
                      width: 14,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                      color: cs.primary,
                    )
                  ],
                );
              }),
            ),
          ),
        ),
      ]),
    );
  }

  static String _labelFor(TimeRange r) => switch (r) {
        TimeRange.day => 'D',
        TimeRange.week => 'W',
        TimeRange.month => 'M',
        TimeRange.sixMonth => '6M',
        TimeRange.year => 'Y',
      };

  static String _subtitleForRange(TimeRange r) {
    final now = DateTime.now();
    switch (r) {
      case TimeRange.day:
        return 'Today, ${_fmtDate(now)}';
      case TimeRange.week:
        return
            '${_fmtDate(now.subtract(const Duration(days: 6)))} — ${_fmtDate(now)}';
      case TimeRange.month:
        return 'Since ${_fmtMonth(DateTime(now.year, now.month, 1))}';
      case TimeRange.sixMonth:
        return
            '${_fmtMonth(DateTime(now.year, now.month - 5, 1))} — ${_fmtMonth(now)}';
      case TimeRange.year:
        return '${DateTime(now.year, 1, 1).year} — ${now.year}';
    }
  }

  static String _fmtDate(DateTime d) =>
      '${_monthShort[d.month]} ${d.day}, ${d.year}';
  static String _fmtMonth(DateTime d) =>
      '${_monthShort[d.month]} ${d.year}';

  static const _monthShort = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
}

class _Segment extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;
  const _Segment(
      {required this.selected, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = GoogleFonts.alike;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: ts(
            fontSize: 12,
            color: selected ? cs.onPrimary : cs.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
