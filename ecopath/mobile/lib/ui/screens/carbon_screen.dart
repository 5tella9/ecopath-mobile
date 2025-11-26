// lib/ui/screens/carbon_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:ecopath/core/api_config.dart'; // contains ApiConfig.baseUrl
import 'package:ecopath/l10n/app_localizations.dart';

class CarbonScreen extends StatefulWidget {
  const CarbonScreen({super.key});

  @override
  State<CarbonScreen> createState() => _CarbonScreenState();
}

enum CarbonRange { oneMonth, sixMonth, oneYear }

/// Simple tuple-like classes (avoid Dart records for wider SDK support)
class _DateRange {
  final String from;
  final String to;
  const _DateRange(this.from, this.to);
}

class _Series {
  final List<String> labels;
  final List<double> values;
  const _Series(this.labels, this.values);
}

class _CarbonScreenState extends State<CarbonScreen> {
  // Each waste type selection: "none", "low", "med", "high"
  String _glass = 'none';
  String _plastic = 'none';
  String _metal = 'none';
  String _cardboard = 'none';
  String _paper = 'none';
  String _general = 'none';
  String _bio = 'none';

  // for chart
  CarbonRange _range = CarbonRange.oneMonth;

  // -------- Server Carbon Footprint (optional) --------
  bool _loadingServer = false;
  String? _serverError;

  double? _svElectricity;
  double? _svGas;
  double? _svWaste;
  double? _svTotal;

  // TODO: replace with the real, logged-in user id once you have it.
  static const String _demoUserId = 'b2f84c7a-0d8c-4e41-b5e3-52ddf559fa66';

  // Dummy kg CO2 factors per level (replace with backend later)
  final Map<String, double> _factor = const {
    'none': 0,
    'low': 1.2,
    'med': 3.0,
    'high': 5.5,
  };

  double _estimateKgCO2() {
    final total = _factor[_glass]! +
        _factor[_plastic]! +
        _factor[_metal]! +
        _factor[_cardboard]! +
        _factor[_paper]! +
        _factor[_general]! +
        _factor[_bio]!;
    // round 1 decimal place
    return (total * 10).roundToDouble() / 10.0;
  }

  // Compute date range from UI toggle (returns simple class instead of records)
  _DateRange _datesForRange() {
    final now = DateTime.now();
    final to = DateTime(now.year, now.month, now.day);
    DateTime from;
    switch (_range) {
      case CarbonRange.oneMonth:
        from = DateTime(to.year, to.month, to.day)
            .subtract(const Duration(days: 30));
        break;
      case CarbonRange.sixMonth:
        from = DateTime(to.year, to.month - 6, to.day);
        break;
      case CarbonRange.oneYear:
        from = DateTime(to.year - 1, to.month, to.day);
        break;
    }
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return _DateRange(fmt(from), fmt(to));
  }

  // Call backend: GET /api/users/{userId}/carbon-footprint?from=...&to=...
  Future<void> _fetchServerCarbon() async {
    setState(() {
      _loadingServer = true;
      _serverError = null;
    });

    final dr = _datesForRange();
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/users/$_demoUserId/carbon-footprint?from=${dr.from}&to=${dr.to}',
    );

    try {
      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final cf = (data['carbonFootprint'] as Map<String, dynamic>?);

        setState(() {
          _svElectricity = (cf?['electricityKgCO2e'] as num?)?.toDouble();
          _svGas = (cf?['gasKgCO2e'] as num?)?.toDouble();
          _svWaste = (cf?['wasteKgCO2e'] as num?)?.toDouble();
          _svTotal = (cf?['totalKgCO2e'] as num?)?.toDouble();
        });
      } else {
        setState(() {
          _serverError = 'HTTP ${res.statusCode}: ${res.body}';
        });
      }
    } catch (e) {
      setState(() {
        _serverError = e.toString();
      });
    } finally {
      setState(() {
        _loadingServer = false;
      });
    }
  }

  // chart data builder (client-side dummy series)
  _Series _buildSeries(CarbonRange r) {
    switch (r) {
      case CarbonRange.oneMonth:
        // pretend weekly values
        return const _Series(
          ['W1', 'W2', 'W3', 'W4'],
          [2.5, 3.2, 2.9, 3.8],
        );
      case CarbonRange.sixMonth:
        return const _Series(
          ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
          [12.0, 11.5, 10.8, 10.2, 9.8, 9.5],
        );
      case CarbonRange.oneYear:
        return const _Series(
          ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'],
          [13, 12, 12, 11, 11, 10, 10, 9.8, 9.5, 9.2, 9.0, 8.8],
        );
    }
  }

  Widget _buildBarChart(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final series = _buildSeries(_range);
    final labels = series.labels;
    final values = series.values;

    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final maxY = (maxVal * 1.25);
    final gridColor = cs.outlineVariant.withOpacity(0.35);
    final barColor = cs.primary;
    final backRod = cs.primary.withOpacity(.10);
    final axisText = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: cs.onSurfaceVariant, fontSize: 11);

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (v) =>
              FlLine(color: gridColor, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (val, meta) =>
                  Text(val.toStringAsFixed(0), style: axisText),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx < 0 || idx >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(labels[idx], style: axisText),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(values.length, (i) {
          final v = values[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: v,
                borderRadius: BorderRadius.circular(8),
                width: 14,
                color: barColor,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: backRod,
                ),
              ),
            ],
          );
        }),
        minY: 0,
        maxY: maxY,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final loc = AppLocalizations.of(context)!;
    final kg = _estimateKgCO2();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? cs.surface,
        elevation: theme.appBarTheme.elevation ?? 0,
        centerTitle: true,
        title: Text(
          loc.carbonTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.appBarTheme.foregroundColor ?? cs.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // scrollable content
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 300),
              children: [
                // -------- Intro / Illustration --------
                _IntroCard(
                  textTheme: textTheme,
                  cs: cs,
                  title: loc.carbonIntroTitle,
                  body: loc.carbonIntroBody,
                ),

                const SizedBox(height: 12),

                // -------- Server data panel (optional) --------
                _ServerPanel(
                  loading: _loadingServer,
                  error: _serverError,
                  electricity: _svElectricity,
                  gas: _svGas,
                  waste: _svWaste,
                  total: _svTotal,
                  onFetchPressed: _fetchServerCarbon,
                ),

                const SizedBox(height: 20),

                Text(
                  loc.carbonMonthlyTrashTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.carbonMonthlyTrashBody,
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // GLASS
                _WasteCard(
                  label: loc.carbonGlassLabel,
                  desc: loc.carbonGlassDesc,
                  value: _glass,
                  onChanged: (v) => setState(() => _glass = v),
                  cs: cs,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),

                // PLASTIC
                _WasteCard(
                  label: loc.carbonPlasticLabel,
                  desc: loc.carbonPlasticDesc,
                  value: _plastic,
                  onChanged: (v) => setState(() => _plastic = v),
                  cs: cs,
                  textTheme: textTheme,
                  highlightPlastic: true,
                ),
                const SizedBox(height: 12),

                // METAL
                _WasteCard(
                  label: loc.carbonMetalLabel,
                  desc: loc.carbonMetalDesc,
                  value: _metal,
                  onChanged: (v) => setState(() => _metal = v),
                  cs: cs,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),

                // CARDBOARD
                _WasteCard(
                  label: loc.carbonCardboardLabel,
                  desc: loc.carbonCardboardDesc,
                  value: _cardboard,
                  onChanged: (v) => setState(() => _cardboard = v),
                  cs: cs,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),

                // PAPER
                _WasteCard(
                  label: loc.carbonPaperLabel,
                  desc: loc.carbonPaperDesc,
                  value: _paper,
                  onChanged: (v) => setState(() => _paper = v),
                  cs: cs,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),

                // GENERAL
                _WasteCard(
                  label: loc.carbonGeneralLabel,
                  desc: loc.carbonGeneralDesc,
                  value: _general,
                  onChanged: (v) => setState(() => _general = v),
                  cs: cs,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),

                // BIO
                _WasteCard(
                  label: loc.carbonBioLabel,
                  desc: loc.carbonBioDesc,
                  value: _bio,
                  onChanged: (v) => setState(() => _bio = v),
                  cs: cs,
                  textTheme: textTheme,
                ),

                const SizedBox(height: 24),

                // ---------- Trend section card -----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.carbonTrendTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    _RangeToggle(
                      range: _range,
                      onChanged: (r) => setState(() => _range = r),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.surface,
                        cs.surfaceVariant.withOpacity(.7),
                      ],
                    ),
                    border: Border.all(
                      color: cs.outlineVariant.withOpacity(.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 180,
                        child: _buildBarChart(context),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _range == CarbonRange.oneMonth
                            ? loc.carbonTrendRange4w
                            : _range == CarbonRange.sixMonth
                                ? loc.carbonTrendRange6m
                                : loc.carbonTrendRange12m,
                        style: textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 120),
              ],
            ),

            // sticky bottom summary card (client-side estimate from selections)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.07),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: cs.primary.withOpacity(.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.eco_rounded, color: cs.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${loc.carbonSummaryTitle}\n',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.primary,
                                  height: 1.3,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '$kg ${loc.carbonSummaryValueSuffix}',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.primary,
                                  height: 1.3,
                                ),
                              ),
                              TextSpan(
                                text: '\n${loc.carbonSummaryBody}',
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: cs.primary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
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
}

/// Server panel to show backend carbon data (if available)
class _ServerPanel extends StatelessWidget {
  final bool loading;
  final String? error;
  final double? electricity;
  final double? gas;
  final double? waste;
  final double? total;
  final VoidCallback onFetchPressed;

  const _ServerPanel({
    required this.loading,
    required this.error,
    required this.electricity,
    required this.gas,
    required this.waste,
    required this.total,
    required this.onFetchPressed,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    Widget _line(String label, double? v) {
      return Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Text(
            v == null ? '—' : '${v.toStringAsFixed(1)} ${loc.carbonServerUnitKg}',
            style: t.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.carbonServerPanelTitle,
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${loc.carbonServerPanelErrorPrefix} $error',
                style: t.bodySmall?.copyWith(color: cs.error),
              ),
            ),
          _line(loc.carbonServerElectricity, electricity),
          const SizedBox(height: 4),
          _line(loc.carbonServerGas, gas),
          const SizedBox(height: 4),
          _line(loc.carbonServerWaste, waste),
          const Divider(height: 18),
          _line(loc.carbonServerTotal, total),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: loading ? null : onFetchPressed,
              icon: loading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_download_outlined, size: 18),
              label: Text(
                loading
                    ? loc.carbonServerFetchingButton
                    : loc.carbonServerFetchButton,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.primary,
                side: BorderSide(color: cs.primary),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Top hero card with illustration + guidance
class _IntroCard extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme cs;
  final String title;
  final String body;

  const _IntroCard({
    required this.textTheme,
    required this.cs,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface,
            cs.surfaceVariant.withOpacity(.8), // themed tint
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: cs.outlineVariant.withOpacity(.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // illustration
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cs.outlineVariant.withOpacity(.2),
                width: 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/trashsize.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable card for each waste type
class _WasteCard extends StatelessWidget {
  final String label;
  final String desc;
  final String value;
  final ValueChanged<String> onChanged;
  final ColorScheme cs;
  final TextTheme textTheme;
  final bool highlightPlastic;

  const _WasteCard({
    required this.label,
    required this.desc,
    required this.value,
    required this.onChanged,
    required this.cs,
    required this.textTheme,
    this.highlightPlastic = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        highlightPlastic ? cs.primary : cs.outlineVariant.withOpacity(.3);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface,
            cs.surfaceVariant.withOpacity(.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // left text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  softWrap: true,
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // right dropdown with fixed width so Row never overflows
          SizedBox(
            width: 110,
            child: _LevelPicker(
              value: value,
              onChanged: onChanged,
              cs: cs,
              textTheme: textTheme,
            ),
          ),
        ],
      ),
    );
  }
}

/// dropdown for waste level
class _LevelPicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final ColorScheme cs;
  final TextTheme textTheme;

  const _LevelPicker({
    required this.value,
    required this.onChanged,
    required this.cs,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      // width now comes from parent SizedBox
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cs.primary.withOpacity(.25),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: cs.onSurface,
          ),
          style: textTheme.bodyMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: [
            DropdownMenuItem(
              value: 'none',
              child: Text(loc.carbonLevelNone),
            ),
            DropdownMenuItem(
              value: 'low',
              child: Text(loc.carbonLevelLow),
            ),
            DropdownMenuItem(
              value: 'med',
              child: Text(loc.carbonLevelMedium),
            ),
            DropdownMenuItem(
              value: 'high',
              child: Text(loc.carbonLevelHigh),
            ),
          ],
        ),
      ),
    );
  }
}

// segmented control for 1M / 6M / 1Y
class _RangeToggle extends StatelessWidget {
  final CarbonRange range;
  final ValueChanged<CarbonRange> onChanged;

  const _RangeToggle({
    required this.range,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activeBg = cs.primary;
    final inactive = cs.onSurfaceVariant;

    Widget _btn(String label, CarbonRange r) {
      final bool isActive = (range == r);
      return GestureDetector(
        onTap: () => onChanged(r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive ? cs.onPrimary : inactive,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _btn('1M', CarbonRange.oneMonth),
          _btn('6M', CarbonRange.sixMonth),
          _btn('1Y', CarbonRange.oneYear),
        ],
      ),
    );
  }
}
