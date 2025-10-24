import 'package:flutter/material.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Features'),
        centerTitle: true,
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
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: .92,
                children: [
                  _FeatureCard(
                    title: 'Electricity',
                    subtitle: 'Track weekly / monthly / yearly usage',
                    icon: Icons.bolt_rounded,
                    iconBg: colorScheme.primaryContainer,
                    onTap: () => _open(context, const _ElectricityUsageScreen()),
                  ),
                  _FeatureCard(
                    title: 'Gas',
                    subtitle: 'Monitor and set save goals',
                    icon: Icons.local_gas_station_rounded,
                    iconBg: colorScheme.tertiaryContainer,
                    onTap: () => _open(context, const _GasUsageScreen()),
                  ),
                  _FeatureCard(
                    title: 'Carbon\nDashboard',
                    subtitle: 'See your CO₂ footprint',
                    icon: Icons.eco_rounded,
                    iconBg: colorScheme.secondaryContainer,
                    onTap: () => _open(context, const _CarbonDashboardScreen()),
                  ),
                  _FeatureCard(
                    title: 'Trash &\nRecycling',
                    subtitle: 'Scan, sort, and earn',
                    icon: Icons.restore_from_trash_rounded,
                    iconBg: colorScheme.surfaceContainerHighest,
                    onTap: () => _open(context, const _TrashRecyclingScreen()),
                  ),
                  _FeatureCard(
                    title: 'Shop',
                    subtitle: 'Exchange points for goods',
                    icon: Icons.store_mall_directory_rounded,
                    iconBg: colorScheme.inversePrimary,
                    onTap: () => _open(context, const _ShopScreen()),
                  ),
                  _FeatureCard(
                    title: 'Education',
                    subtitle: 'Quick eco lessons & quizzes',
                    icon: Icons.menu_book_rounded,
                    iconBg: colorScheme.primaryFixedDim,
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
  final IconData icon;
  final Color? iconBg;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface.withOpacity(.96),
              cs.surfaceContainerHighest.withOpacity(.35),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: cs.outlineVariant.withOpacity(.4)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gamified points chip
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: cs.primary.withOpacity(.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded, size: 16, color: cs.primary),
                    const SizedBox(width: 6),
                    Text(
                      '+ XP',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Icon bubble
            Container(
              decoration: BoxDecoration(
                color: iconBg ?? cs.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 32, color: cs.onSecondaryContainer),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(.8),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'Open',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 18, color: cs.primary),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// ----------------------
/// Stub detail pages
/// ----------------------

class _ElectricityUsageScreen extends StatelessWidget {
  const _ElectricityUsageScreen();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Electricity Usage')),
      body: _StubBody(
        emoji: '⚡️',
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
        emoji: '🔥',
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
        emoji: '🌍',
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
        emoji: '♻️',
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

class _ShopScreen extends StatelessWidget {
  const _ShopScreen();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: _StubBody(
        emoji: '🛍️',
        title: 'Eco Shop',
        lines: const [
          '• Redeem points for goods',
          '• Partner perks & coupons',
          '• Limited-time deals',
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
        emoji: '📘',
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
  final String emoji;
  final String title;
  final List<String> lines;
  final TextTheme textTheme;

  const _StubBody({
    required this.emoji,
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
          Text('$emoji  $title',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...lines.map(
            (l) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 20, color: cs.primary),
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
              color: cs.primary.withOpacity(.1),
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
