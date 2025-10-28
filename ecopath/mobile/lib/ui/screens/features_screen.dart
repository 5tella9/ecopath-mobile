import 'package:flutter/material.dart';
import 'package:ecopath/ui/screens/shop_screen.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF), // soft game hub bg
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7FF),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Features',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF00221C),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose your eco-mission",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00221C),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: .92,
                children: [
                  _FeatureCard(
                    title: 'Electricity',
                    subtitle:
                        'Track weekly / monthly / yearly usage',
                    iconPath: 'assets/images/electricity.png',
                    iconBg: const Color(0xFFECE9FF),
                    onTap: () =>
                        _open(context, const _ElectricityUsageScreen()),
                  ),
                  _FeatureCard(
                    title: 'Gas',
                    subtitle: 'Monitor and set save goals',
                    iconPath: 'assets/images/gas.png',
                    iconBg: const Color(0xFFFFE8EC),
                    onTap: () => _open(context, const _GasUsageScreen()),
                  ),
                  _FeatureCard(
                    title: 'Carbon\nDashboard',
                    subtitle: 'See your CO₂ footprint',
                    iconPath: 'assets/images/carbon.png',
                    iconBg: const Color(0xFFEFF5EA),
                    onTap: () =>
                        _open(context, const _CarbonDashboardScreen()),
                  ),
                  _FeatureCard(
                    title: 'Trash &\nRecycling',
                    subtitle: 'Scan, sort, and track',
                    iconPath: 'assets/images/tracker.png',
                    iconBg: const Color(0xFFEFF0F5),
                    onTap: () =>
                        _open(context, const _TrashRecyclingScreen()),
                  ),
                  _FeatureCard(
                    title: 'Shop',
                    subtitle: 'Exchange points for goods',
                    iconPath: 'assets/images/shop.png',
                    iconBg: const Color(0xFFEDEBFF),
                    onTap: () => _open(context, const ShopScreen()),
                  ),
                  _FeatureCard(
                    title: 'Education',
                    subtitle: 'Quick eco lessons & quizzes',
                    iconPath: 'assets/images/education.png',
                    iconBg: const Color(0xFFEFF0FF),
                    onTap: () => _open(context, const _EducationScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconPath;
  final Color iconBg;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.onTap,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF3F1FF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: cs.outlineVariant.withOpacity(.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // icon bubble
            Container(
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              width: 56,
              height: 56,
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // title
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00221C),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),

            // subtitle / description
            Expanded(
              child: Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF00221C).withOpacity(.7),
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Open →
            Row(
              children: [
                Text(
                  'Open',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF00221C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_right_alt_rounded,
                  size: 20,
                  color: Color(0xFF00221C),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ----------------------
/// Stub detail pages (except Shop)
/// Now using the same PNG icons instead of emojis
/// ----------------------

class _ElectricityUsageScreen extends StatelessWidget {
  const _ElectricityUsageScreen();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Electricity Usage')),
      body: _StubBody(
        iconPath: 'assets/images/electricity.png',
        iconBg: const Color(0xFFECE9FF),
        title: 'Electricity Usage',
        lines: const [
          '• View weekly / monthly / yearly kWh',
          '• Compare against your average',
          '• Earn XP for saving streaks',
        ],
        textTheme: t.textTheme,
      ),
    );
  }
}

class _GasUsageScreen extends StatelessWidget {
  const _GasUsageScreen();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Gas Usage')),
      body: _StubBody(
        iconPath: 'assets/images/gas.png',
        iconBg: const Color(0xFFFFE8EC),
        title: 'Gas Usage',
        lines: const [
          '• Track m³ or billing cycles',
          '• Weekly / monthly / yearly charts',
          '• Targets & badges',
        ],
        textTheme: t.textTheme,
      ),
    );
  }
}

class _CarbonDashboardScreen extends StatelessWidget {
  const _CarbonDashboardScreen();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Carbon Footprint Dashboard')),
      body: _StubBody(
        iconPath: 'assets/images/carbon.png',
        iconBg: const Color(0xFFEFF5EA),
        title: 'Carbon Footprint',
        lines: const [
          '• Combined CO₂ estimate from energy & habits',
          '• Trend vs. last period',
          '• Tips to reduce & earn XP',
        ],
        textTheme: t.textTheme,
      ),
    );
  }
}

class _TrashRecyclingScreen extends StatelessWidget {
  const _TrashRecyclingScreen();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Trash & Recycling')),
      body: _StubBody(
        iconPath: 'assets/images/tracker.png',
        iconBg: const Color(0xFFEFF0F5),
        title: 'Trash & Recycling',
        lines: const [
          '• Scan items & sort correctly',
          '• Track recycling streaks',
          '• Leaderboard boosts',
        ],
        textTheme: t.textTheme,
      ),
    );
  }
}

class _EducationScreen extends StatelessWidget {
  const _EducationScreen();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Education')),
      body: _StubBody(
        iconPath: 'assets/images/education.png',
        iconBg: const Color(0xFFEFF0FF),
        title: 'Eco Education',
        lines: const [
          '• Micro-lessons on recycling & eco-living',
          '• Quizzes to earn XP',
          '• Tips tailored to your data',
        ],
        textTheme: t.textTheme,
      ),
    );
  }
}

class _StubBody extends StatelessWidget {
  final String iconPath;
  final Color iconBg;
  final String title;
  final List<String> lines;
  final TextTheme textTheme;

  const _StubBody({
    required this.iconPath,
    required this.iconBg,
    required this.title,
    required this.lines,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row with same style icon bubble
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...lines.map(
            (l) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.primary.withOpacity(.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.stars_rounded, color: cs.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Complete actions here to earn EcoPath points & badges.',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
