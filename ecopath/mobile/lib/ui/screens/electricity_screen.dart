// lib/ui/screens/electricity_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

/// ====== COLOR & STYLE (kept consistent with your app) ======
const kPrimary = Color(0xFF00221C);
const kAccent = Color(0xFF5E9460);
const kCard = Color(0xFFF6F4F3);
const kSoft = Color(0xFF9AA8A4);

TextStyle _ts(double size,
        {FontWeight? fw, Color color = Colors.black, double? height}) =>
    GoogleFonts.alike(fontSize: size, fontWeight: fw, color: color, height: height);

enum ElecRange { week, month, year }

class ElectricityScreen extends StatefulWidget {
  const ElectricityScreen({super.key});

  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  ElecRange _range = ElecRange.month;
  bool _showCost = false; // toggle kWh <-> ₩

  // Demo data; replace with real user data later.
  (List<String>, List<double>) _series(ElecRange r) {
    switch (r) {
      case ElecRange.week:
        return (['Mon','Tue','Wed','Thu','Fri','Sat','Sun'], [9, 8, 10, 7, 11, 13, 12]);
      case ElecRange.month:
        return ([
          '1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'
        ], [
          8, 9, 7.5, 10, 8.5, 9.8, 10.2, 11.7, 9.1, 8.4, 9.7, 12.3, 11.4, 10.9, 9.6
        ]);
      case ElecRange.year:
        return (['J','F','M','A','M','J','J','A','S','O','N','D'],
            [280, 255, 230, 210, 240, 300, 350, 360, 290, 260, 240, 310]);
    }
  }

  // Simple progressive estimate (demo only).
  double _estimateWon(double kwh) {
    if (kwh <= 200) return 910 + kwh * 120;
    if (kwh <= 400) return 1600 + kwh * 214;
    return 7300 + kwh * 307;
  }

  double _sum(List<double> xs) => xs.fold(0.0, (a, b) => a + b);

  // Comparison vs previous period (demo).
  double _previousPeriodTotal(ElecRange r) {
    switch (r) {
      case ElecRange.week:
        return 64;
      case ElecRange.month:
        return 285;
      case ElecRange.year:
        return 3250;
    }
  }

  String _rangeLabel(ElecRange r) {
    switch (r) {
      case ElecRange.week:
        return 'This Week';
      case ElecRange.month:
        return 'This Month';
      case ElecRange.year:
        return 'This Year';
    }
  }

  @override
  Widget build(BuildContext context) {
    final (labels, values) = _series(_range);
    final totalKwh = _sum(values);
    final prev = _previousPeriodTotal(_range);
    final pct = prev == 0 ? 0.0 : ((totalKwh - prev) / prev) * 100.0;
    final estWon = _estimateWon(_range == ElecRange.year ? totalKwh / 12 : totalKwh); // avg/month for yearly
    final projectedMonth = (_range == ElecRange.month)
        ? (totalKwh / values.length) * 30.0
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new, color: kPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Electricity Usage', style: _ts(20, fw: FontWeight.w700, color: kPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====== KPI HEADER CARD ======
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_rangeLabel(_range), style: _ts(16, fw: FontWeight.w700, color: kPrimary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _KpiTile(
                            title: 'Usage',
                            value: '${totalKwh.toStringAsFixed(0)} kWh',
                            sub: 'Estimate only',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _KpiTile(
                            title: 'Est. Bill',
                            value: '₩${estWon.toStringAsFixed(0)}',
                            sub: _range == ElecRange.year ? 'avg/month' : 'estimate',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          pct >= 0 ? Icons.trending_up : Icons.trending_down,
                          color: pct >= 0 ? Colors.redAccent : Colors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${pct >= 0 ? 'Up' : 'Down'} ${pct.abs().toStringAsFixed(1)}% vs last period',
                          style: _ts(13, color: kPrimary),
                        ),
                        const Spacer(),
                        // Unit toggle
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kSoft),
                          ),
                          child: Row(
                            children: [
                              _ToggleChip(
                                label: 'kWh',
                                selected: !_showCost,
                                onTap: () => setState(() => _showCost = false),
                              ),
                              _ToggleChip(
                                label: '₩',
                                selected: _showCost,
                                onTap: () => setState(() => _showCost = true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (projectedMonth != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Projection: ~${projectedMonth.toStringAsFixed(0)} kWh (₩${_estimateWon(projectedMonth).toStringAsFixed(0)})',
                        style: _ts(13, color: kPrimary),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ====== RANGE TABS ======
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RangeButton(
                    text: 'Week',
                    selected: _range == ElecRange.week,
                    onTap: () => setState(() => _range = ElecRange.week),
                  ),
                  _RangeButton(
                    text: 'Month',
                    selected: _range == ElecRange.month,
                    onTap: () => setState(() => _range = ElecRange.month),
                  ),
                  _RangeButton(
                    text: 'Year',
                    selected: _range == ElecRange.year,
                    onTap: () => setState(() => _range = ElecRange.year),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ====== CHART CARD ======
              Container(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kCard),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Usage Chart', style: _ts(16, fw: FontWeight.w700, color: kPrimary)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: _range == ElecRange.year
                          ? _buildLineChart(labels, values, showCost: _showCost, wonFn: _estimateWon)
                          : _buildBarChart(labels, values, showCost: _showCost, wonFn: _estimateWon, highlightPeak: _range == ElecRange.week),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _showCost
                          ? 'Showing estimated cost (₩). For reference only.'
                          : 'Showing energy use (kWh).',
                      style: _ts(12, color: kSoft),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ====== BREAKDOWN & TIPS ======
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Likely Breakdown', style: _ts(16, fw: FontWeight.w700, color: kPrimary)),
                    const SizedBox(height: 10),
                    _breakdownRow('Air Conditioner / Heater', 0.36),
                    _breakdownRow('Refrigerator', 0.18),
                    _breakdownRow('Washer & Dryer', 0.12),
                    _breakdownRow('Lighting', 0.10),
                    _breakdownRow('Electronics & Standby', 0.24),
                    const SizedBox(height: 12),
                    Container(height: 1, color: Colors.white),
                    const SizedBox(height: 12),
                    Text('Quick Tips (KR Homes)', style: _ts(15, fw: FontWeight.w700, color: kPrimary)),
                    const SizedBox(height: 8),
                    _tipBullet('대기전력 차단 멀티탭 사용 (standby power off).'),
                    _tipBullet('여름 에어컨 26–28°C, 겨울 난방 ~20°C 권장.'),
                    _tipBullet('세탁은 찬물/에코 코스, 건조기 사용 줄이기.'),
                    _tipBullet('LED 조명과 타이머/인체감지 센서 활용.'),
                    _tipBullet('피크 시간대 전기사용 분산하기.'),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ====== GAMIFICATION ======
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Eco Achievements', style: _ts(16, fw: FontWeight.w700, color: kPrimary)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _Badge(label: 'Off-peak Pro'),
                        _Badge(label: 'LED Swapper'),
                        _Badge(label: 'Laundry Eco'),
                        _Badge(label: 'Standby Slayer'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Monthly XP', style: _ts(13, fw: FontWeight.w600, color: kPrimary)),
                    const SizedBox(height: 6),
                    _XpBar(progress: 0.62),
                    const SizedBox(height: 6),
                    Text('Earn XP by reducing kWh vs last month and completing eco-quests.',
                        style: _ts(12, color: kSoft)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, double pct) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _ts(14, color: kPrimary))),
          SizedBox(
            width: 120,
            child: Stack(
              children: [
                Container(height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                FractionallySizedBox(
                  widthFactor: pct.clamp(0, 1),
                  child: Container(height: 10, decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(20))),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('${(pct * 100).toStringAsFixed(0)}%', style: _ts(13, color: kPrimary)),
        ],
      ),
    );
  }

  Widget _tipBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(color: kPrimary, fontSize: 16)),
          Expanded(child: Text(text, style: _ts(13, color: kPrimary))),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    List<String> labels,
    List<double> values, {
    required bool showCost,
    required double Function(double) wonFn,
    bool highlightPeak = false,
  }) {
    final transValues = showCost
        ? values.map((v) => wonFn(v) / 1000.0).toList() // scale cost (₩) down to fit
        : values;

    final maxCandidate = transValues.fold<double>(0, (m, v) => v > m ? v : m) * 1.25;
    final maxY = maxCandidate.clamp(1.0, 999999.0).toDouble(); // <-- force double

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (val, meta) => Text(
                showCost ? '${val.toStringAsFixed(0)}k' : val.toStringAsFixed(0),
                style: _ts(11, color: kSoft),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final i = val.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(labels[i], style: _ts(11, color: kSoft)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(labels.length, (i) {
          final isPeak = highlightPeak && (i == 4 || i == 5); // Fri/Sat highlight (demo)
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: transValues[i],
                width: 14,
                borderRadius: BorderRadius.circular(6),
                color: isPeak ? Colors.redAccent.withOpacity(0.85) : kAccent,
              )
            ],
          );
        }),
        minY: 0,
        maxY: maxY, // <-- safe double
      ),
    );
  }

  Widget _buildLineChart(
    List<String> labels,
    List<double> values, {
    required bool showCost,
    required double Function(double) wonFn,
  }) {
    final series = showCost ? values.map((v) => wonFn(v)).toList() : values;

    final maxCandidate = series.fold<double>(0, (m, v) => v > m ? v : m) * 1.2;
    final maxY = maxCandidate.clamp(1.0, 999999.0).toDouble(); // <-- safe double

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (val, meta) => Text(
                showCost ? '₩${val.toStringAsFixed(0)}' : val.toStringAsFixed(0),
                style: _ts(11, color: kSoft),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final i = val.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(labels[i], style: _ts(11, color: kSoft)),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        minY: 0,
        maxY: maxY, // <-- safe double
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            color: kAccent,
            spots: [
              for (int i = 0; i < labels.length; i++) FlSpot(i.toDouble(), series[i]),
            ],
          )
        ],
      ),
    );
  }
}

/// ====== SMALL WIDGETS ======

class _RangeButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _RangeButton({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? kPrimary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kPrimary.withOpacity(0.2)),
          ),
          child: Text(
            text,
            style: GoogleFonts.alike(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : kPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  const _KpiTile({required this.title, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.alike(fontSize: 12, color: kSoft)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.alike(fontSize: 18, fontWeight: FontWeight.w800, color: kPrimary)),
          const SizedBox(height: 2),
          Text(sub, style: GoogleFonts.alike(fontSize: 11, color: kSoft)),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? kAccent.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.alike(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? kPrimary : kSoft,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Text(label, style: GoogleFonts.alike(fontSize: 12, fontWeight: FontWeight.w700, color: kPrimary)),
    );
  }
}

class _XpBar extends StatelessWidget {
  final double progress; // 0..1
  const _XpBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(30),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0, 1),
        child: Container(
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
