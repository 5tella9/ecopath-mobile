// lib/ui/screens/electricity_screen.dart
import 'package:ecopath/core/meters_api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ecopath/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecopath/core/api_config.dart';

TextStyle _ts(BuildContext context, double size,
    {FontWeight? fw, Color? color, double? height}) {
  final cs = Theme.of(context).colorScheme;
  return GoogleFonts.alike(
    fontSize: size,
    fontWeight: fw,
    color: color ?? cs.onSurface,
    height: height,
  );
}

enum ElecRange { week, month, year }

class ElectricityScreen extends StatefulWidget {
  const ElectricityScreen({super.key});

  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  ElecRange _range = ElecRange.month;
  bool _showCost = false;

  bool _loadingAvg = false;
  double? _avgKwh;
  String _avgUnit = 'kWh';

  static const String _demoSmartMeterId =
      'c7d42103-dbc7-4a3a-8813-3be0c1587f78';



  @override
  void initState() {
    super.initState();
    _loadAverageForJanuary2025();
  }

  Future<void> _loadAverageForJanuary2025() async {
    setState(() => _loadingAvg = true);
    try {
      final result = await MetersApi.fetchAverageReading(
        smartMeterId: _demoSmartMeterId,
        from: '2025-01-01',
        to: '2025-01-31',
      );
      final avg = (result['average'] as num?)?.toDouble();
      final unit = (result['unit'] as String?) ?? 'kWh';
      setState(() {
        _avgKwh = avg;
        _avgUnit = (unit == 'kilowatt_hour') ? 'kWh' : unit;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load average: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingAvg = false);
    }
  }

  (List<String>, List<double>) _series(ElecRange r) {
    switch (r) {
      case ElecRange.week:
        return (
          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          [9, 8, 10, 7, 11, 13, 12]
        );
      case ElecRange.month:
        return (
          [
            '1',
            '3',
            '5',
            '7',
            '9',
            '11',
            '13',
            '15',
            '17',
            '19',
            '21',
            '23',
            '25',
            '27',
            '29'
          ],
          [
            8,
            9,
            7.5,
            10,
            8.5,
            9.8,
            10.2,
            11.7,
            9.1,
            8.4,
            9.7,
            12.3,
            11.4,
            10.9,
            9.6
          ]
        );
      case ElecRange.year:
        return (
          [
            'J',
            'F',
            'M',
            'A',
            'M',
            'J',
            'J',
            'A',
            'S',
            'O',
            'N',
            'D'
          ],
          [
            280,
            255,
            230,
            210,
            240,
            300,
            350,
            360,
            290,
            260,
            240,
            310
          ]
        );
    }
  }

  double _estimateWon(double kwh) {
    if (kwh <= 200) return 910 + kwh * 120;
    if (kwh <= 400) return 1600 + kwh * 214;
    return 7300 + kwh * 307;
  }

  double _sum(List<double> xs) => xs.fold(0.0, (a, b) => a + b);
  double _previousPeriodTotal(ElecRange r) =>
      r == ElecRange.week ? 64 : r == ElecRange.month ? 285 : 3250;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final (labels, values) = _series(_range);
    final totalKwh = _sum(values);
    final prev = _previousPeriodTotal(_range);
    final pct = prev == 0 ? 0.0 : ((totalKwh - prev) / prev) * 100.0;
    final estWon =
        _estimateWon(_range == ElecRange.year ? totalKwh / 12 : totalKwh);
    final projectedMonth =
        (_range == ElecRange.month) ? (totalKwh / values.length) * 30.0 : null;

    final String rangeLabel = switch (_range) {
      ElecRange.week => l10n.electricityThisWeek,
      ElecRange.month => l10n.electricityThisMonth,
      ElecRange.year => l10n.electricityThisYear,
    };

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.electricityTitle,
          style: _ts(context, 20, fw: FontWeight.w700, color: cs.onSurface),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rangeLabel,
                      style: _ts(
                        context,
                        16,
                        fw: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _KpiTile(
                            title: l10n.electricityUsageKpiTitle,
                            value: '${totalKwh.toStringAsFixed(0)} kWh',
                            sub: l10n.electricityUsageKpiSub,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _KpiTile(
                            title: l10n.electricityBillKpiTitle,
                            value: '₩${estWon.toStringAsFixed(0)}',
                            sub: _range == ElecRange.year
                                ? l10n.electricityBillKpiSubYear
                                : l10n.electricityBillKpiSubOther,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          pct >= 0 ? Icons.trending_up : Icons.trending_down,
                          color:
                              pct >= 0 ? Colors.redAccent : Colors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${pct >= 0 ? l10n.electricityTrendUp : l10n.electricityTrendDown} ${pct.abs().toStringAsFixed(1)}% ${l10n.electricityVsLastPeriod}',
                          style: _ts(context, 13, color: cs.onSurface),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              _ToggleChip(
                                label: 'kWh',
                                selected: !_showCost,
                                onTap: () =>
                                    setState(() => _showCost = false),
                              ),
                              _ToggleChip(
                                label: '₩',
                                selected: _showCost,
                                onTap: () =>
                                    setState(() => _showCost = true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (projectedMonth != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.electricityProjectionPrefix} ~${projectedMonth.toStringAsFixed(0)} kWh (₩${_estimateWon(projectedMonth).toStringAsFixed(0)})',
                        style: _ts(
                          context,
                          13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Backend average card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _loadingAvg
                          ? Text(
                              l10n.electricityBackendLoading,
                              style: _ts(context, 13),
                            )
                          : (_avgKwh == null)
                              ? Text(
                                  l10n.electricityBackendNone,
                                  style: _ts(context, 13),
                                )
                              : Text(
                                  '${l10n.electricityBackendLabel} ${_avgKwh!.toStringAsFixed(2)} $_avgUnit',
                                  style: _ts(
                                    context,
                                    14,
                                    fw: FontWeight.w700,
                                  ),
                                ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _loadingAvg
                          ? null
                          : _loadAverageForJanuary2025,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l10n.electricityRefresh),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.primary,
                        side: BorderSide(color: cs.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Range buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RangeButton(
                    l10n.electricityRangeWeekButton,
                    _range == ElecRange.week,
                    () => setState(() => _range = ElecRange.week),
                  ),
                  _RangeButton(
                    l10n.electricityRangeMonthButton,
                    _range == ElecRange.month,
                    () => setState(() => _range = ElecRange.month),
                  ),
                  _RangeButton(
                    l10n.electricityRangeYearButton,
                    _range == ElecRange.year,
                    () => setState(() => _range = ElecRange.year),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Chart
              Container(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.electricityUsageChartTitle,
                      style: _ts(context, 16, fw: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: _range == ElecRange.year
                          ? _buildLineChart(labels, values)
                          : _buildBarChart(labels, values),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// BAR CHART
  Widget _buildBarChart(List<String> labels, List<double> values) {
    final cs = Theme.of(context).colorScheme;
    final maxY = (values.reduce((a, b) => a > b ? a : b) * 1.3).toDouble();

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (val, _) {
                // show only every 5 units (0,5,10,15,...) to avoid overlap
                if (val % 5 != 0) return const SizedBox.shrink();
                return Text(val.toInt().toString(),
                    style: _ts(context, 11));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (val, _) {
                final i = val.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(labels[i], style: _ts(context, 10)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(labels.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                width: 14,
                borderRadius: BorderRadius.circular(4),
                color: cs.primary,
              )
            ],
          );
        }),
        maxY: maxY,
      ),
    );
  }

  /// LINE CHART (Year)
  Widget _buildLineChart(List<String> labels, List<double> values) {
    final cs = Theme.of(context).colorScheme;
    final maxY = (values.reduce((a, b) => a > b ? a : b) * 1.2).toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (val, _) {
                if (val % 50 != 0) return const SizedBox.shrink();
                return Text(val.toInt().toString(),
                    style: _ts(context, 11));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (val, _) {
                final i = val.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Text(labels[i], style: _ts(context, 10));
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: cs.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            spots: [
              for (int i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i])
            ],
          )
        ],
        maxY: maxY,
        minY: 0,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

/// Small widgets

class _RangeButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _RangeButton(this.text, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? cs.primary : cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Text(
            text,
            style: GoogleFonts.alike(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? cs.onPrimary : cs.primary,
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
  const _KpiTile({
    required this.title,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _ts(context, 12, color: cs.outline)),
          const SizedBox(height: 4),
          Text(
            value,
            style: _ts(context, 18, fw: FontWeight.w800, color: cs.onSurface),
          ),
          Text(sub, style: _ts(context, 11, color: cs.outline)),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.alike(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? cs.primary : cs.outline,
          ),
        ),
      ),
    );
  }
}
