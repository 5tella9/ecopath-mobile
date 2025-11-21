// lib/ui/screens/dashboard_screen.dart
import 'package:ecopath/core/api_test.dart';
import 'package:ecopath/core/progress_tracker.dart';
import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

// NEW: real screens
import 'recycle_screen.dart';
import 'education_screen.dart';

// NEW: localization
import 'package:ecopath/l10n/app_localizations.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  DashboardState createState() => DashboardState();
}

enum TimeRange { day, week, month, sixMonth, year }

class DashboardState extends State<Dashboard> {
  final ProgressTracker _tracker = ProgressTracker.instance;

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
    // NOTE: currently sample data.
    // To connect to real points history, we need per-day/period history
    // from ProgressTracker (e.g. tracker.getPointsHistory(range)).
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
    final l10n = AppLocalizations.of(context)!;

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(title, style: _ts(context, 18, fw: FontWeight.bold)),
        content: Text(message, style: _ts(context, 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.no, style: _ts(context, 14, color: cs.primary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: cs.primary),
            child:
                Text(l10n.yes, style: _ts(context, 14, color: cs.onPrimary)),
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
    final l10n = AppLocalizations.of(context)!;
    final (labels, values) = _buildSeries(_range);
    final total = values.fold<int>(0, (a, b) => a + b);
    final avg = values.isEmpty ? 0.0 : total / values.length;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                        Text(l10n.profileName,
                            style: _ts(context, 20, fw: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          '${l10n.currentRankPrefix} ${_tracker.rank}',
                          style: _ts(context, 18),
                        ),
                        const SizedBox(height: 6),
                        Row(children: [
                          Image.asset('assets/images/star.png',
                              width: 28, height: 28),
                          const SizedBox(width: 8),
                          Text(
                            '${l10n.pointsPrefix} ${_tracker.totalPoints}',
                            style: _ts(context, 18),
                          ),
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
                    Text(l10n.impactThisWeek,
                        style: _ts(context, 18, fw: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text(l10n.electricityChange, style: _ts(context, 16)),
                      const SizedBox(width: 8),
                      Text('⚡', style: _ts(context, 20))
                    ]),
                    Row(children: [
                      Text(l10n.gasChange, style: _ts(context, 16)),
                      const SizedBox(width: 8),
                      Text('🔥', style: _ts(context, 20))
                    ]),
                    Row(children: [
                      Text(l10n.overallScore, style: _ts(context, 16)),
                      const SizedBox(width: 8),
                      Text('🌱', style: _ts(context, 20))
                    ]),
                  ]),
            ),

            const SizedBox(height: 24),

            // RECYCLE & QUIZ TILES
            Row(children: [
              Expanded(
                child: _dashboardTile(
                  context,
                  title: l10n.recycleTileTitle,
                  subtitle: l10n.recycleTileSubtitle,
                  asset: 'assets/images/dashboardg1.png',
                  color: cs.primaryContainer.withOpacity(.4),
                  onTap: () {
                    _confirmAndGo(
                      title: l10n.recycleDialogTitle,
                      message: l10n.recycleDialogMessage,
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
                  title: l10n.quizTileTitle,
                  subtitle: l10n.quizTileSubtitle,
                  asset: 'assets/images/dashboardg.png',
                  color: cs.tertiaryContainer.withOpacity(.4),
                  onTap: () {
                    _confirmAndGo(
                      title: l10n.quizDialogTitle,
                      message: l10n.quizDialogMessage,
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

            // EDUCATION BANNER
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                _confirmAndGo(
                  title: l10n.educationDialogTitle,
                  message: l10n.educationDialogMessage,
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
                        Text(l10n.educateSmallTitle,
                            style: _ts(context, 12, color: cs.onPrimary)),
                        const SizedBox(height: 8),
                        Text(l10n.educateSmallAnd,
                            style: _ts(context, 12, color: cs.onPrimary)),
                        const SizedBox(height: 8),
                        Text(
                          l10n.educateSmallMain,
                          style: _ts(
                            context,
                            14,
                            fw: FontWeight.w600,
                            color: cs.onPrimary,
                          ),
                        ),
                      ],
                    ),
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
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: _ts(context, 11, fw: FontWeight.w600),
                  ),
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

// ---------------- STATS SECTION (POINTS CHART) ----------------

class StatsSectionPoints extends StatelessWidget {
  final TimeRange range;
  final ValueChanged<TimeRange> onRangeChanged;
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.ecoPointsTrend,
                style: GoogleFonts.lato(
                  color: cs.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // horizontally scrollable chips to avoid overflow
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _rangeChip(context, 'D', TimeRange.day),
                        _rangeChip(context, 'W', TimeRange.week),
                        _rangeChip(context, 'M', TimeRange.month),
                        _rangeChip(context, '6M', TimeRange.sixMonth),
                        _rangeChip(context, 'Y', TimeRange.year),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.avgPointsPrefix} ${avg.toStringAsFixed(1)} pts',
            style: GoogleFonts.alike(
              color: cs.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (val, meta) {
                        final index = val.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labels[index],
                            style: GoogleFonts.alike(
                              color: cs.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem:
                        (group, groupIndex, rod, rodIndex) {
                      final label = labels[groupIndex];
                      final v = values[groupIndex];
                      return BarTooltipItem(
                        '$label\n$v pts',
                        GoogleFonts.lato(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: List.generate(values.length, (i) {
                  final v = values[i].toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: v,
                        width: 14,
                        borderRadius: BorderRadius.circular(6),
                        color: cs.primary,
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

  Widget _rangeChip(BuildContext context, String label, TimeRange r) {
    final cs = Theme.of(context).colorScheme;
    final bool selected = r == range;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.alike(
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        selected: selected,
        onSelected: (_) => onRangeChanged(r),
        selectedColor: cs.primary,
        backgroundColor: cs.surfaceContainerHighest,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
