// lib/ui/screens/features_screen.dart
import 'package:flutter/material.dart';
import 'package:ecopath/ui/screens/shop_screen.dart';
import 'package:ecopath/ui/screens/carbon_screen.dart';
import 'package:ecopath/ui/screens/electricity_screen.dart';
import 'package:ecopath/ui/screens/gas_screen.dart';
import 'package:ecopath/ui/screens/notitruck_screen.dart';
import 'package:ecopath/ui/screens/education_screen.dart';

// NEW: localization
import 'package:ecopath/l10n/app_localizations.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.featuresTitle,
          style: t.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface,
              cs.surfaceContainerHighest,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.chooseEcoMission,
                style: t.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
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
                      title: l10n.featureElectricityTitle,
                      subtitle: l10n.featureElectricitySubtitle,
                      iconPath: 'assets/images/electricity.png',
                      bubbleTone: _Tone.primary,
                      onTap: () => _open(context, const ElectricityScreen()),
                    ),
                    _FeatureCard(
                      title: l10n.featureGasTitle,
                      subtitle: l10n.featureGasSubtitle,
                      iconPath: 'assets/images/gas.png',
                      bubbleTone: _Tone.error,
                      onTap: () => _open(context, const GasScreen()),
                    ),
                    _FeatureCard(
                      title: l10n.featureCarbonTitle,
                      subtitle: l10n.featureCarbonSubtitle,
                      iconPath: 'assets/images/carbon.png',
                      bubbleTone: _Tone.tertiary,
                      onTap: () => _open(context, const CarbonScreen()),
                    ),
                    _FeatureCard(
                      title: l10n.featureTrashTitle,
                      subtitle: l10n.featureTrashSubtitle,
                      iconPath: 'assets/images/tracker.png',
                      bubbleTone: _Tone.secondary,
                      onTap: () =>
                          _open(context, const _TrashRecyclingScreen()),
                    ),
                    _FeatureCard(
                      title: l10n.featureShopTitle,
                      subtitle: l10n.featureShopSubtitle,
                      iconPath: 'assets/images/shop.png',
                      bubbleTone: _Tone.inverse,
                      onTap: () => _open(context, const ShopScreen()),
                    ),
                    _FeatureCard(
                      title: l10n.featureEducationTitle,
                      subtitle: l10n.featureEducationSubtitle,
                      iconPath: 'assets/images/education.png',
                      bubbleTone: _Tone.primarySoft,
                      onTap: () => _open(context, const EducationScreen()),
                    ),
                    _FeatureCard(
                      title: l10n.featureNotiTruckTitle,
                      subtitle: l10n.featureNotiTruckSubtitle,
                      iconPath: 'assets/images/truck.png',
                      bubbleTone: _Tone.primarySoft,
                      onTap: () => _open(context, const NotiTruckScreen()),
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

  static void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

enum _Tone { primary, secondary, tertiary, error, inverse, primarySoft }

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconPath;
  final _Tone bubbleTone;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.bubbleTone,
    required this.onTap,
  });

  Color _bubbleColor(ColorScheme cs) {
    switch (bubbleTone) {
      case _Tone.primary:
        return cs.primaryContainer;
      case _Tone.secondary:
        return cs.secondaryContainer;
      case _Tone.tertiary:
        return cs.tertiaryContainer;
      case _Tone.error:
        return cs.errorContainer;
      case _Tone.inverse:
        return cs.inversePrimary.withOpacity(.18);
      case _Tone.primarySoft:
        return cs.primary.withOpacity(.12);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: cs.surfaceContainerHighest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: cs.outlineVariant.withOpacity(.5),
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
                color: _bubbleColor(cs),
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

            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: Text(
                subtitle,
                style: t.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Text(
                  'Open',
                  style: t.textTheme.labelLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_right_alt_rounded,
                  size: 20,
                  color: cs.primary,
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
/// Simple stub page for Trash & Recycling
/// ----------------------

class _TrashRecyclingScreen extends StatelessWidget {
  const _TrashRecyclingScreen();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text(l10n.trashRecyclingTitle, style: t.textTheme.titleMedium),
      ),
      body: _StubBody(
        iconPath: 'assets/images/tracker.png',
        bubbleTone: _Tone.secondary,
        title: l10n.trashRecyclingTitle,
        lines: [
          l10n.trashRecyclingLine1,
          l10n.trashRecyclingLine2,
          l10n.trashRecyclingLine3,
        ],
      ),
    );
  }
}

class _StubBody extends StatelessWidget {
  final String iconPath;
  final _Tone bubbleTone;
  final String title;
  final List<String> lines;

  const _StubBody({
    required this.iconPath,
    required this.bubbleTone,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    Color bubble(_Tone tone) {
      switch (tone) {
        case _Tone.primary:
          return cs.primaryContainer;
        case _Tone.secondary:
          return cs.secondaryContainer;
        case _Tone.tertiary:
          return cs.tertiaryContainer;
        case _Tone.error:
          return cs.errorContainer;
        case _Tone.inverse:
          return cs.inversePrimary.withOpacity(.18);
        case _Tone.primarySoft:
          return cs.primary.withOpacity(.12);
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row with themed icon bubble
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bubble(bubbleTone),
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
                  style: t.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
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
                  Icon(Icons.check_circle_rounded, size: 20, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l, style: t.textTheme.bodyMedium)),
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
                    l10n.trashRecyclingHint,
                    style: t.textTheme.bodyMedium?.copyWith(
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
