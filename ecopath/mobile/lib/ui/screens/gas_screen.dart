// lib/ui/screens/gas_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

enum GasRange { m1, m6, y1 }
enum GasUnit { m3, kwh }

class GasScreen extends StatefulWidget {
  const GasScreen({super.key});

  @override
  State<GasScreen> createState() => _GasScreenState();
}

class _GasScreenState extends State<GasScreen> {
  GasRange _range = GasRange.m1;
  GasUnit _unit = GasUnit.m3;
  final TextEditingController _readingCtl = TextEditingController();
  final TextEditingController _rateCtl = TextEditingController();

  double? _co2ResultKg;
  double? _billResult;

  static const double _kgCO2PerKwh = 0.184;
  static const double _kgCO2PerM3 = 2.03;

  (List<String>, List<double>) _series(GasRange r) {
    switch (r) {
      case GasRange.m1:
        return (['W1', 'W2', 'W3', 'W4'], [8, 12, 10, 9]);
      case GasRange.m6:
        return (['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'], [42, 38, 31, 29, 33, 40]);
      case GasRange.y1:
        return (
          ['Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
          [55, 59, 61, 58, 49, 42, 40, 36, 30, 32, 37, 44]
        );
    }
  }

  double _safeMaxY(List<double> vals) {
    if (vals.isEmpty) return 10;
    final maxVal = vals.reduce((a, b) => a > b ? a : b);
    final pad = (maxVal * 0.2).clamp(3, 20);
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
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final (labels, values) = _series(_range);
    final maxY = _safeMaxY(values);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Gas',
          style: t.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Track your monthly gas usage\nand estimate your carbon impact.",
              style: t.textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 14),

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
                  _UnitToggle(value: _unit, onChanged: (u) => setState(() => _unit = u)),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _readingCtl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: _unit == GasUnit.m3 ? 'Gas used (m³)' : 'Gas used (kWh)',
                      hintText: _unit == GasUnit.m3 ? 'e.g. 42.5' : 'e.g. 120.0',
                      filled: true,
                      fillColor: cs.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

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
                      fillColor: cs.surfaceContainerLowest,
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
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
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
            _Card(
              child: _ResultBlock(co2Kg: _co2ResultKg, bill: _billResult, unit: _unit),
            ),
            const SizedBox(height: 16),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderRow(
                    icon: Icons.show_chart_rounded,
                    title: 'Usage Trend',
                    subtitle: _range == GasRange.m1
                        ? 'Last 4 weeks'
                        : _range == GasRange.m6
                            ? 'Last 6 months'
                            : 'Last 12 months',
                    trailing: _RangeChips(value: _range, onChanged: (r) => setState(() => _range = r)),
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
                          gridData: FlGridData(show: true, drawVerticalLine: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (v, meta) => Text(
                                  v.toStringAsFixed(0),
                                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
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
                                    child: Text(labels[idx],
                                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                                  );
                                },
                              ),
                            ),
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
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    cs.primary.withOpacity(0.35),
                                    cs.primary.withOpacity(0.05),
                                  ],
                                ),
                              ),
                              gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tip: Switch units to match your bill. Trends update automatically.',
                          style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---- SHARED WIDGETS ----

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
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
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: cs.surfaceContainerHighest),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: cs.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: t.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: t.textTheme.bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant, height: 1.2)),
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
    final cs = Theme.of(context).colorScheme;
    return SegmentedButton<GasUnit>(
      segments: const [
        ButtonSegment(value: GasUnit.m3, label: Text('m³')),
        ButtonSegment(value: GasUnit.kwh, label: Text('kWh')),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(cs.surfaceContainerLowest),
        side: WidgetStateProperty.all(BorderSide(color: cs.outlineVariant)),
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

  const _ResultBlock({required this.co2Kg, required this.bill, required this.unit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
  const _MetricTile({required this.label, required this.value, required this.helper});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
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
                    style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        color: cs.onSurface, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(helper, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_outward_rounded, color: cs.primary),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.pending_outlined, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No result yet. Enter a reading above and tap Convert.',
              style: TextStyle(color: cs.onSurfaceVariant),
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
    final cs = Theme.of(context).colorScheme;
    Widget chip(String label, GasRange v) {
      final selected = value == v;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onChanged(v),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? cs.onPrimary : cs.onSurface,
        ),
        selectedColor: cs.primary,
        backgroundColor: cs.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? cs.primary : cs.outlineVariant),
        ),
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
