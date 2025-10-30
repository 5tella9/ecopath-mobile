// lib/ui/screens/gas_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// ---- THEME PALETTE (match your app’s) ----
const kPrimary = Color(0xFF00221C);
const kAccent = Color(0xFF5E9460);
const kCard = Color(0xFFF6F4F3);
const kSoft = Color(0xFF9AA8A4);
const kBg = Color(0xFFF9F7FF);

enum GasRange { m1, m6, y1 }
enum GasUnit { m3, kwh }

class GasScreen extends StatefulWidget {
  const GasScreen({super.key});

  @override
  State<GasScreen> createState() => _GasScreenState();
}

class _GasScreenState extends State<GasScreen> {
  // --------- STATE ----------
  GasRange _range = GasRange.m1;
  GasUnit _unit = GasUnit.m3;

  final TextEditingController _readingCtl = TextEditingController();
  final TextEditingController _rateCtl = TextEditingController();

  double? _co2ResultKg;
  double? _billResult;

  // Conversion factors (illustrative defaults; tweak to your locality)
  // Natural gas ~0.184 kg CO2/kWh; ~2.03 kg CO2 per m³ (approx, varies by gas mix)
  static const double _kgCO2PerKwh = 0.184;
  static const double _kgCO2PerM3 = 2.03;

  // --------- DATA GENERATOR (demo) ----------
  // Return (labels, values). Keep values modest & positive.
  (List<String>, List<double>) _series(GasRange r) {
    switch (r) {
      case GasRange.m1:
        // 1M = last 4 weeks
        return (
          ['W1', 'W2', 'W3', 'W4'],
          [8, 12, 10, 9] // in m³ or kWh-ish (display only)
        );
      case GasRange.m6:
        // 6M = last 6 months
        return (
          ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
          [42, 38, 31, 29, 33, 40]
        );
      case GasRange.y1:
        // 1Y = last 12 months
        return (
          ['Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
          [55, 59, 61, 58, 49, 42, 40, 36, 30, 32, 37, 44]
        );
    }
  }

  // Compute safe maxY so it’s always above the biggest value (prevents red underline overflow issues)
  double _safeMaxY(List<double> vals) {
    if (vals.isEmpty) return 10;
    final maxVal = vals.reduce((a, b) => a > b ? a : b);
    final pad = (maxVal * 0.2).clamp(3, 20); // add 20% (3~20) headroom
    return maxVal + pad;
  }

  void _convertToCO2() {
    final raw = double.tryParse(_readingCtl.text.trim());
    if (raw == null || raw <= 0) {
      setState(() {
        _co2ResultKg = null;
        _billResult = null;
      });
      return;
    }
    final factor = _unit == GasUnit.kwh ? _kgCO2PerKwh : _kgCO2PerM3;
    final co2 = raw * factor;

    // Optional bill estimate if the user provided a rate
    final rate = double.tryParse(_rateCtl.text.trim());
    final bill = (rate != null && rate >= 0) ? raw * rate : null;

    setState(() {
      _co2ResultKg = co2;
      _billResult = bill;
    });
  }

  @override
  void dispose() {
    _readingCtl.dispose();
    _rateCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (labels, values) = _series(_range);
    final maxY = _safeMaxY(values);

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Gas',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: kPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prompt (same vibe as Electricity)
            Text(
              "Track your monthly gas usage\nand estimate your carbon impact.",
              style: theme.textTheme.titleMedium?.copyWith(
                color: kPrimary,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 14),

            // --- INPUT CARD ---
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderRow(
                    icon: Icons.local_gas_station_rounded,
                    title: 'Quick Converter',
                    subtitle: 'Enter your latest reading to convert to CO₂e',
                  ),
                  const SizedBox(height: 12),

                  // Unit toggle
                  _UnitToggle(
                    value: _unit,
                    onChanged: (u) => setState(() => _unit = u),
                  ),
                  const SizedBox(height: 12),

                  // Reading field
                  TextField(
                    controller: _readingCtl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: _unit == GasUnit.m3 ? 'Gas used (m³)' : 'Gas used (kWh)',
                      hintText: _unit == GasUnit.m3 ? 'e.g. 42.5' : 'e.g. 120.0',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Optional rate field
                  TextField(
                    controller: _rateCtl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: _unit == GasUnit.m3
                          ? 'Optional: Rate per m³ (₩)'
                          : 'Optional: Rate per kWh (₩)',
                      hintText: 'e.g. 92.5',
                      helperText: 'If set, we’ll also estimate this month’s bill.',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _convertToCO2,
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: const Text('Convert'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // --- RESULTS CARD ---
            _Card(
              child: _ResultBlock(
                co2Kg: _co2ResultKg,
                bill: _billResult,
                unit: _unit,
              ),
            ),

            const SizedBox(height: 16),

            // --- CHART CARD ---
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderRow(
                    icon: Icons.show_chart_rounded,
                    title: 'Usage Trend',
                    subtitle: _range == GasRange.m1
                        ? 'Last 4 weeks'
                        : (_range == GasRange.m6 ? 'Last 6 months' : 'Last 12 months'),
                    trailing: _RangeChips(
                      value: _range,
                      onChanged: (r) => setState(() => _range = r),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AspectRatio(
                    aspectRatio: 1.8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: maxY,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: (maxY / 4).clamp(5, 20),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                interval: (maxY / 4).clamp(5, 20),
                                getTitlesWidget: (v, meta) => Text(
                                  v.toStringAsFixed(0),
                                  style: const TextStyle(fontSize: 11, color: kSoft),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, meta) {
                                  final idx = v.toInt();
                                  if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      labels[idx],
                                      style: const TextStyle(fontSize: 11, color: kSoft),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              tooltipRoundedRadius: 10,
                              tooltipPadding: const EdgeInsets.all(8),
                              getTooltipItems: (spots) => spots
                                  .map((s) => LineTooltipItem(
                                        '${labels[s.x.toInt()]}  •  ${s.y.toStringAsFixed(1)}',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: const Color(0x11000000)),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                for (int i = 0; i < values.length; i++)
                                  FlSpot(i.toDouble(), values[i]),
                              ],
                              isCurved: true,
                              barWidth: 3.5,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    kAccent.withOpacity(0.35),
                                    kAccent.withOpacity(0.05),
                                  ],
                                ),
                              ),
                              gradient: const LinearGradient(
                                colors: [kAccent, kPrimary],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 24),
                  // Small legend / hint line
                  Row(
                    children: const [
                      Icon(Icons.info_outline_rounded, size: 18, color: kSoft),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tip: Switch units to match your bill. Trends update automatically.',
                          style: TextStyle(fontSize: 12.5, color: kSoft),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// ---- WIDGETS ----

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      child: child,
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _HeaderRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: kPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: kPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: kSoft,
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final GasUnit value;
  final ValueChanged<GasUnit> onChanged;

  const _UnitToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<GasUnit>(
      segments: const [
        ButtonSegment(value: GasUnit.m3, label: Text('m³')),
        ButtonSegment(value: GasUnit.kwh, label: Text('kWh')),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return Colors.white;
        }),
        side: WidgetStateProperty.all(const BorderSide(color: Color(0x22000000))),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _ResultBlock extends StatelessWidget {
  final double? co2Kg;
  final double? bill;
  final GasUnit unit;

  const _ResultBlock({
    required this.co2Kg,
    required this.bill,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = co2Kg != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderRow(
          icon: Icons.eco_rounded,
          title: 'Result',
          subtitle: 'Your estimated carbon footprint and optional bill estimate',
        ),
        const SizedBox(height: 12),
        if (!hasData)
          const _EmptyHint()
        else
          Column(
            children: [
              _MetricTile(
                label: 'CO₂e',
                value: '${co2Kg!.toStringAsFixed(2)} kg',
                helper: 'Based on your input in ${unit == GasUnit.m3 ? "m³" : "kWh"}.',
              ),
              const SizedBox(height: 10),
              _MetricTile(
                label: 'Estimated Bill',
                value: bill == null ? '—' : '₩${_formatMoney(bill!)}',
                helper: 'Set your rate to see a bill estimate.',
              ),
            ],
          ),
      ],
    );
  }

  static String _formatMoney(double v) {
    // Simple thousands separator
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String helper;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      color: kSoft,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: kPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(helper, style: const TextStyle(color: kSoft, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_outward_rounded, color: kPrimary),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.pending_outlined, color: kSoft),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'No result yet. Enter a reading above and tap Convert.',
              style: TextStyle(color: kSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeChips extends StatelessWidget {
  final GasRange value;
  final ValueChanged<GasRange> onChanged;

  const _RangeChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, GasRange v) {
      final selected = value == v;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onChanged(v),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : kPrimary,
        ),
        selectedColor: kPrimary,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? kPrimary : const Color(0x22000000)),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );
    }

    return Wrap(
      spacing: 6,
      children: [
        chip('1M', GasRange.m1),
        chip('6M', GasRange.m6),
        chip('1Y', GasRange.y1),
      ],
    );
  }
}
