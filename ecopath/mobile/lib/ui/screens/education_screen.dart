// lib/ui/screens/education_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecopath/l10n/app_localizations.dart'; // ✅ add this

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen>
    with SingleTickerProviderStateMixin {
  final Random _rand = Random();

  // For eco tip of the day per level
  final Map<_Level, int> _ecoTipIndex = {};
  // For infographic page indicator per level
  final Map<_Level, int> _pageIndex = {
    _Level.beginner: 0,
    _Level.intermediate: 0,
    _Level.advanced: 0,
  };

  String? _selectedBinId; // For subtle animation/highlight

  @override
  void initState() {
    super.initState();
    // Pick a random tip index for each level
    for (final level in _Level.values) {
      final tips = _ecoTips[level] ?? [];
      if (tips.isNotEmpty) {
        _ecoTipIndex[level] = _rand.nextInt(tips.length);
      } else {
        _ecoTipIndex[level] = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final l = AppLocalizations.of(context)!; // ✅ localization

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            l.ecoEducationTitle, // ✅ 'Eco Education'
            style: GoogleFonts.alike(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          bottom: TabBar(
            indicatorColor: cs.primary,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurface.withOpacity(0.6),
            labelStyle: GoogleFonts.alike(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.alike(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: l.ecoEducationTabBeginner),     // ✅ Beginner / 초급
              Tab(text: l.ecoEducationTabIntermediate), // ✅ Intermediate / 중급
              Tab(text: l.ecoEducationTabAdvanced),     // ✅ Advanced / 고급
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLevelContent(context, _Level.beginner),
            _buildLevelContent(context, _Level.intermediate),
            _buildLevelContent(context, _Level.advanced),
          ],
        ),
      ),
    );
  }

  // ---------- LEVEL CONTENT ----------

  Widget _buildLevelContent(BuildContext context, _Level level) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    final String levelHeading = switch (level) {
      _Level.beginner => l.ecoEducationLevelBeginnerHeading,
      _Level.intermediate => l.ecoEducationLevelIntermediateHeading,
      _Level.advanced => l.ecoEducationLevelAdvancedHeading,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, levelHeading),
          const SizedBox(height: 8),
          _buildBinGuideRow(context, level),
          const SizedBox(height: 20),
          _sectionTitle(context, l.ecoEducationSectionInfographics),
          const SizedBox(height: 8),
          _buildInfographicCarousel(context, level),
          const SizedBox(height: 20),
          _sectionTitle(context, l.ecoEducationSectionEcoTip),
          const SizedBox(height: 8),
          _buildEcoTipCard(context, level),
          const SizedBox(height: 20),
          _sectionTitle(context, l.ecoEducationSectionMythFact),
          const SizedBox(height: 8),
          _buildMythFactList(context, level),
          const SizedBox(height: 8),
          Text(
            l.ecoEducationHintTapCards,
            style: GoogleFonts.alike(
              fontSize: 12,
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: GoogleFonts.alike(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
    );
  }

  // ---------- 1) TRASH BIN GUIDE ----------

  Widget _buildBinGuideRow(BuildContext context, _Level level) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _bins.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final bin = _bins[index];
          final isSelected = _selectedBinId == bin.id;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBinId = bin.id;
              });
              _showBinDetailsModal(context, level, bin);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceVariant.withOpacity(isSelected ? 0.5 : 0.3),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? cs.primary.withOpacity(0.9)
                      : cs.outlineVariant.withOpacity(0.4),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: cs.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'bin_${bin.id}',
                      child: Image.asset(
                        bin.assetPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bin.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.alike(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bin.shortDesc,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.alike(
                      fontSize: 11,
                      color: cs.onSurface.withOpacity(0.6),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBinDetailsModal(
      BuildContext context, _Level level, _BinInfo bin) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final details = _getBinDetails(level, bin.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cs.outlineVariant.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Hero(
                        tag: 'bin_${bin.id}',
                        child: Image.asset(
                          bin.assetPath,
                          height: 46,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              details.title,
                              style: GoogleFonts.alike(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              details.subtitle,
                              style: GoogleFonts.alike(
                                fontSize: 13,
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (details.allowed.isNotEmpty)
                    _buildBulletSection(
                      context,
                      icon: Icons.check_circle_rounded,
                      iconColor: Colors.greenAccent.shade400,
                      title: l.ecoEducationBinSectionAllowed,
                      bullets: details.allowed,
                    ),
                  if (details.notAllowed.isNotEmpty) const SizedBox(height: 12),
                  if (details.notAllowed.isNotEmpty)
                    _buildBulletSection(
                      context,
                      icon: Icons.close_rounded,
                      iconColor: Colors.redAccent.shade200,
                      title: l.ecoEducationBinSectionNotAllowed,
                      bullets: details.notAllowed,
                    ),
                  if (details.tips.isNotEmpty) const SizedBox(height: 12),
                  if (details.tips.isNotEmpty)
                    _buildBulletSection(
                      context,
                      icon: Icons.lightbulb_rounded,
                      iconColor: cs.primary,
                      title: l.ecoEducationBinSectionTipsKorea,
                      bullets: details.tips,
                    ),
                  const SizedBox(height: 16),
                  _buildExtraKoreaInfo(context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBulletSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> bullets,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.alike(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...bullets.map(
          (b) => Padding(
            padding: const EdgeInsets.only(left: 4, top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  ', style: TextStyle(fontSize: 13)),
                Expanded(
                  child: Text(
                    b,
                    style: GoogleFonts.alike(
                      fontSize: 13,
                      color: cs.onSurface.withOpacity(0.8),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExtraKoreaInfo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        l.ecoEducationExtraKoreaNote,
        style: GoogleFonts.alike(
          fontSize: 12,
          color: cs.onSurface.withOpacity(0.8),
          height: 1.3,
        ),
      ),
    );
  }

  // ---------- 2) INFOGRAPHIC CAROUSEL ----------

  Widget _buildInfographicCarousel(BuildContext context, _Level level) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final data = _infographics[level] ?? [];

    if (data.isEmpty) {
      return Text(
        l.ecoEducationInfographicsComingSoon,
        style: GoogleFonts.alike(
          fontSize: 13,
          color: cs.onSurface.withOpacity(0.6),
        ),
      );
    }

    final pageController = PageController(
      viewportFraction: 0.9,
      initialPage: _pageIndex[level] ?? 0,
    );

    return Column(
      children: [
        // bigger height to avoid overflow for all levels
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: pageController,
            itemCount: data.length,
            onPageChanged: (idx) {
              setState(() {
                _pageIndex[level] = idx;
              });
            },
            itemBuilder: (context, index) {
              final item = data[index];
              return AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: (_pageIndex[level] ?? 0) == index ? 1.0 : 0.96,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: cs.outlineVariant.withOpacity(0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(item.icon, size: 22, color: cs.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.title,
                              style: GoogleFonts.alike(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.subtitle,
                        style: GoogleFonts.alike(
                          fontSize: 13,
                          color: cs.onSurface.withOpacity(0.8),
                          height: 1.3,
                        ),
                      ),
                      if (item.bullets.isNotEmpty) const SizedBox(height: 10),
                      ...item.bullets.map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('•  ',
                                  style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  b,
                                  style: GoogleFonts.alike(
                                    fontSize: 12,
                                    color: cs.onSurface.withOpacity(0.8),
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            data.length,
            (i) {
              final isActive = (_pageIndex[level] ?? 0) == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: isActive ? 16 : 6,
                decoration: BoxDecoration(
                  color:
                      isActive ? cs.primary : cs.onSurface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------- 3) ECO TIP OF THE DAY ----------

  Widget _buildEcoTipCard(BuildContext context, _Level level) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final tips = _ecoTips[level] ?? [];

    if (tips.isEmpty) {
      return Text(
        l.ecoEducationTipsComingSoon,
        style: GoogleFonts.alike(
          fontSize: 13,
          color: cs.onSurface.withOpacity(0.6),
        ),
      );
    }

    final currentIndex = _ecoTipIndex[level] ?? 0;
    final tip = tips[currentIndex % tips.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.primary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.wb_sunny_rounded, color: cs.primary, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.alike(
                fontSize: 13,
                color: cs.onSurface,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l.ecoEducationTipShuffleTooltip,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            color: cs.onSurface.withOpacity(0.8),
            onPressed: () {
              setState(() {
                _ecoTipIndex[level] =
                    _rand.nextInt(tips.length == 0 ? 1 : tips.length);
              });
            },
          ),
        ],
      ),
    );
  }

  // ---------- 4) MYTH vs FACT ----------

  Widget _buildMythFactList(BuildContext context, _Level level) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final items = _myths[level] ?? [];

    if (items.isEmpty) {
      return Text(
        l.ecoEducationMythsComingSoon,
        style: GoogleFonts.alike(
          fontSize: 13,
          color: cs.onSurface.withOpacity(0.6),
        ),
      );
    }

    return Column(
      children: items
          .map((m) => _MythFactCard(mythFact: m))
          .toList(growable: false),
    );
  }
}

// ---------- SUPPORTING WIDGETS & DATA CLASSES ----------

enum _Level { beginner, intermediate, advanced }

class _BinInfo {
  final String id;
  final String label;
  final String assetPath;
  final String shortDesc;

  const _BinInfo({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.shortDesc,
  });
}

class _BinDetails {
  final String title;
  final String subtitle;
  final List<String> allowed;
  final List<String> notAllowed;
  final List<String> tips;

  const _BinDetails({
    required this.title,
    required this.subtitle,
    this.allowed = const [],
    this.notAllowed = const [],
    this.tips = const [],
  });
}

class _InfographicItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> bullets;

  const _InfographicItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.bullets = const [],
  });
}

class _MythFact {
  final String statement;
  final bool isMyth;
  final String explanation;

  const _MythFact({
    required this.statement,
    required this.isMyth,
    required this.explanation,
  });
}

class _MythFactCard extends StatefulWidget {
  final _MythFact mythFact;

  const _MythFactCard({super.key, required this.mythFact});

  @override
  State<_MythFactCard> createState() => _MythFactCardState();
}

class _MythFactCardState extends State<_MythFactCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMyth = widget.mythFact.isMyth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(_expanded ? 0.6 : 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMyth
              ? Colors.redAccent.withOpacity(0.4)
              : Colors.greenAccent.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isMyth
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 20,
                  color: isMyth ? Colors.redAccent : Colors.greenAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.mythFact.statement,
                    style: GoogleFonts.alike(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.mythFact.explanation,
                  style: GoogleFonts.alike(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.85),
                    height: 1.3,
                  ),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- STATIC CONTENT (YOU CAN EDIT LATER) ----------

// Your 4 main bin images & labels
const List<_BinInfo> _bins = [
  _BinInfo(
    id: 'can',
    label: 'Cans & Metals',
    assetPath: 'assets/images/canb.png',
    shortDesc: 'Beverage cans,\nmetal lids, scrap',
  ),
  _BinInfo(
    id: 'plastic',
    label: 'Plastics',
    assetPath: 'assets/images/plasticb.png',
    shortDesc: 'PET bottles,\nplastic containers',
  ),
  _BinInfo(
    id: 'paper',
    label: 'Paper',
    assetPath: 'assets/images/paperb.png',
    shortDesc: 'Newspapers,\nboxes, flyers',
  ),
  _BinInfo(
    id: 'others',
    label: 'Others',
    assetPath: 'assets/images/othersb.png',
    shortDesc: 'Glass, vinyl,\nstyrofoam, etc.',
  ),
];

// Per-level bin details (Korean rules, English explanation)
_BinDetails _getBinDetails(_Level level, String binId) {
  switch (binId) {
    case 'can':
      return switch (level) {
        _Level.beginner => const _BinDetails(
            title: 'Cans & Scrap Metals Bin',
            subtitle: 'Clean beverage cans, food cans, and small metal items.',
            allowed: [
              'Empty beverage cans (beer, soda).',
              'Food cans (corn, tuna, etc.) rinsed clean.',
              'Metal lids from glass bottles (jam lids, etc.).',
              'Small scrap metals such as bottle caps.',
            ],
            notAllowed: [
              'Cans with food or liquid still inside.',
              'Aerosol cans with remaining gas (these usually go to a special collection).',
              'Batteries, electric devices, or large metal products.',
            ],
            tips: [
              'In many Korean apartments, cans & metals share a bin with glass or plastics. Follow local signboards.',
              'Lightly rinse cans to remove food smell before disposing.',
              'Crush cans if possible to save space, but do not over-compress mixed materials together.',
            ],
          ),
        _Level.intermediate => const _BinDetails(
            title: 'Cans & Metals – Detailed Rules',
            subtitle:
                'Focus on “empty · clean · separated” before recycling metals.',
            allowed: [
              'Aluminum beverage cans, steel food cans (rinsed).',
              'Metal lids from bottles and jars, separated from glass.',
              'Clean aluminum foil or trays with no food residue.',
            ],
            notAllowed: [
              'Cans with attached plastic labels that cannot be easily removed.',
              'Dirty disposable foil or instant food containers with oil.',
              'Gas canisters or spray cans with leftover gas (check separate disposal instructions).',
            ],
            tips: [
              'If your building has a separate “dangerous waste” box, spray cans and gas canisters should go there, not in general metal recycling.',
              'Batteries (전지류) are usually collected in small dedicated boxes inside buildings or near convenience stores.',
            ],
          ),
        _Level.advanced => const _BinDetails(
            title: 'Metals in the Korean Recycling System',
            subtitle:
                'Metals are highly recyclable if sorted correctly and kept clean.',
            allowed: [
              'Well-sorted aluminum and steel cans (labels removed if possible).',
              'Clean metal packaging such as cookie tins or gift sets (분리배출).',
            ],
            notAllowed: [
              'Items made of mixed materials that cannot be separated (metal + wood, metal + plastic glued tightly).',
              'Large home appliances (these need bulk waste collection or special pickup).',
            ],
            tips: [
              'Metals collected in Korea are usually pressed and sent to recycling facilities; contamination lowers quality.',
              'For large metal items, contact your local 구청 (district office) website for bulky waste pickup (대형폐기물).',
            ],
          ),
      };
    case 'plastic':
      return switch (level) {
        _Level.beginner => const _BinDetails(
            title: 'Plastics Bin',
            subtitle: 'PET bottles and clean plastic containers.',
            allowed: [
              'PET beverage bottles (water, juice, tea).',
              'Plastic bottles for shampoo, body wash, detergent (rinsed).',
              'Plastic food containers that are clean and dry.',
            ],
            notAllowed: [
              'Plastic with a lot of food or oil left inside.',
              'Vinyl bags heavily contaminated with food (often go to general waste).',
              'Mixed-material items (e.g., toys with metal and electronics).',
            ],
            tips: [
              'In Korea, remember “비우고 · 헹구고 · 분리하고 (empty, rinse, separate)”.',
              'Remove caps and labels from PET bottles if possible and crush the bottle to save space.',
              'Many places separate PET bottles (투명 페트병) from other plastics in a different bag or bin.',
            ],
          ),
        _Level.intermediate => const _BinDetails(
            title: 'Plastics – Material Codes & Sorting',
            subtitle: 'PET, HDPE, PP, and other codes affect recyclability.',
            allowed: [
              'Plastics marked with recycling codes like PET(01), HDPE(02), PP(05), when clean.',
              'Transparent PET bottles stored separately if your building has a dedicated bag or bin.',
              'Plastic trays for fruits or snacks if they are clean and dry.',
            ],
            notAllowed: [
              'Biodegradable or “eco” plastics that are not officially accepted in recycling streams.',
              'Hard plastics such as shoes or bags (often treated as general waste).',
              'Plastic with strong contamination (oil, sauce, cheese).',
            ],
            tips: [
              'Check apartment notices: many now require transparent PET bottles to be stored in a mesh bag or special bag.',
              'If the plastic has no recycling code, it may be treated as 일반쓰레기 (general waste).',
            ],
          ),
        _Level.advanced => const _BinDetails(
            title: 'Plastics & Zero-Waste Thinking',
            subtitle:
                'Reducing plastic use is more powerful than recycling alone.',
            allowed: [
              'Only plastics that are clearly recyclable and accepted by your local system.',
            ],
            notAllowed: [
              'Over-reliance on “recyclable” label without checking local rules.',
            ],
            tips: [
              'Use a tumbler and reusable containers to reduce single-use plastic from cafés and 배달 (delivery).',
              'Choose products with minimal packaging; refill stores are becoming more common in Korean cities.',
            ],
          ),
      };
    case 'paper':
      return switch (level) {
        _Level.beginner => const _BinDetails(
            title: 'Paper Bin',
            subtitle: 'Newspapers, books, office paper, and boxes.',
            allowed: [
              'Newspapers, magazines, flyers.',
              'Cardboard boxes (flattened and tied with string).',
              'Office paper and notebooks without plastic covers.',
            ],
            notAllowed: [
              'Tissues, paper towels, and toilet paper (often go to general waste).',
              'Paper cups with plastic coating, unless your local area collects them separately.',
              'Greasy pizza boxes or food-stained paper.',
            ],
            tips: [
              'Remove plastic tape and labels from boxes as much as possible.',
              'Stack and tie paper neatly; many Korean recycling stations prefer bundled paper.',
            ],
          ),
        _Level.intermediate => const _BinDetails(
            title: 'Paper – What Cannot Be Recycled',
            subtitle:
                'Not all “paper” counts as recyclable paper in Korea’s system.',
            allowed: [
              'High-quality printing paper, envelopes without plastic windows.',
              'Paper bags that are not laminated with plastic or foil.',
            ],
            notAllowed: [
              'Thermal paper receipts (often treated as general waste).',
              'Paper with plastic lamination (gift wrap with shiny coating).',
              'Waxed or heavily coated paper for food.',
            ],
            tips: [
              'Separate high-quality white paper from colored or printed paper if your building requests it.',
              'Check whether your local area collects paper cups separately; if not, they go to general waste.',
            ],
          ),
        _Level.advanced => const _BinDetails(
            title: 'Paper Recycling & Contamination',
            subtitle:
                'Moisture and contamination greatly reduce recycling quality.',
            allowed: [
              'Dry, clean paper sorted by type when possible.',
            ],
            notAllowed: [
              'Wet or moldy paper; it can cause problems in recycling facilities.',
            ],
            tips: [
              'Store paper indoors until collection day to avoid getting it wet.',
              'If a box is heavily contaminated with food, cut off the clean part and recycle only that portion.',
            ],
          ),
      };
    case 'others':
    default:
      return switch (level) {
        _Level.beginner => const _BinDetails(
            title: 'Other Recyclables (Glass, Vinyl, Styrofoam, etc.)',
            subtitle:
                'Items that are not cans, plastics, or paper but can still be sorted.',
            allowed: [
              'Glass bottles (wine, beer, soju) rinsed and with caps removed.',
              'Clean styrofoam packaging from electronics or fruits.',
              'Clean vinyl packaging and plastic bags (if your area has a vinyl bin).',
            ],
            notAllowed: [
              'Broken glass mixed with other waste (often wrapped and put in general waste).',
              'Styrofoam with food stuck on it (e.g., instant cup noodle containers).',
              'Ceramics or mirrors (these are usually not recycled as glass).',
            ],
            tips: [
              'Separate caps and labels from glass bottles; check if your area has a return system for certain bottles.',
              'If your apartment has no vinyl bin, vinyl may need to go to general waste.',
            ],
          ),
        _Level.intermediate => const _BinDetails(
            title: 'Other Recyclables – Check Local Rules',
            subtitle:
                '“Others” depends strongly on what your apartment or 구청 accepts.',
            allowed: [
              'Colorless and colored glass bottles placed in the correct bin.',
              'Big clean styrofoam blocks (often stored separately at recycling stations).',
            ],
            notAllowed: [
              'Heat-resistant glass (e.g., glass pots, Pyrex) – often not accepted in glass recycling.',
              'Sand, soil, stones, or ceramics in the glass bin.',
            ],
            tips: [
              'Read the signs at your recycling area; some districts separate colorless and colored glass.',
              'For unusual items (ceramic dishes, mirrors), check bulk waste or general waste instructions.',
            ],
          ),
        _Level.advanced => const _BinDetails(
            title: 'Advanced Sorting & Special Waste',
            subtitle:
                'Some items need special collection rather than normal bins.',
            allowed: [
              'Only items clearly listed on your local signboards as recyclable.',
            ],
            notAllowed: [
              'Electronic waste, batteries, fluorescent lamps – these have dedicated collection boxes.',
            ],
            tips: [
              'Look for special e-waste or battery boxes in your building entrance, supermarkets, or community centers.',
              'When in doubt, check your 구청 website or app for the latest sorting guide.',
            ],
          ),
      };
  }
}

// Infographic data per level
final Map<_Level, List<_InfographicItem>> _infographics = {
  _Level.beginner: const [
    _InfographicItem(
      icon: Icons.delete_outline_rounded,
      title: 'Basic Korean Bin Types',
      subtitle:
          'Most Korean apartments separate recyclables into several categories.',
      bullets: [
        'Recyclables: cans & metals, plastics, paper, glass, and others.',
        'Food waste is collected separately in special bins or smart food waste machines.',
        'General waste must be placed in official volume-rate bags (종량제 봉투).',
      ],
    ),
    _InfographicItem(
      icon: Icons.recycling_rounded,
      title: '3-Step Rule: Empty · Rinse · Separate',
      subtitle:
          'Following this simple rule makes recycling much more effective.',
      bullets: [
        'EMPTY: Remove all food or liquid from containers.',
        'RINSE: Lightly rinse bottles and cans to remove smell and residue.',
        'SEPARATE: Remove caps, labels, and different materials before disposal.',
      ],
    ),
    _InfographicItem(
      icon: Icons.home_rounded,
      title: 'Check Your Building Notice Board',
      subtitle:
          'Each apartment complex may have slightly different instructions.',
      bullets: [
        'Look for posters near the recycling area or entrance.',
        'Follow the icons and color codes specific to your complex.',
        'If you are unsure, ask the 관리사무소 (management office).',
      ],
    ),
  ],
  _Level.intermediate: const [
    _InfographicItem(
      icon: Icons.line_style_rounded,
      title: 'Understanding Plastic Codes',
      subtitle: 'Common codes in Korea: PET, HDPE, PP, PS, etc.',
      bullets: [
        'PET (01): Clear beverage bottles – often collected separately.',
        'HDPE (02): Strong, opaque bottles like detergent containers.',
        'PP (05): Many food containers and caps.',
        'PS, PVC, and others may be harder to recycle depending on area.',
      ],
    ),
    _InfographicItem(
      icon: Icons.local_pizza_rounded,
      title: 'Contamination Problems',
      subtitle:
          'Food and oil residue can turn recyclables into general waste.',
      bullets: [
        'Greasy pizza boxes often cannot be recycled as paper.',
        'Styrofoam bowls with soup or oil usually go to general waste.',
        'Rinse gently – you do not need to make it “perfect”, just reasonably clean.',
      ],
    ),
    _InfographicItem(
      icon: Icons.local_shipping_rounded,
      title: 'What Happens After Collection?',
      subtitle:
          'Recyclables go to sorting centers where machines and workers separate items.',
      bullets: [
        'Well-sorted, clean items are easier to process and have more value.',
        'Mixed or dirty items may be incinerated or landfilled instead of recycled.',
        'Good sorting at home directly improves recycling rates in Korea.',
      ],
    ),
  ],
  _Level.advanced: const [
    _InfographicItem(
      icon: Icons.public_rounded,
      title: 'Korea’s Waste Policies & You',
      subtitle:
          'Policies like the volume-rate system and single-use plastic reduction rely on citizen participation.',
      bullets: [
        'Pay-as-you-throw bags encourage reducing general waste.',
        'Delivery apps and cafés now offer “no disposable spoon” and discount for tumblers.',
        'Local governments run campaigns for correct recycling and reducing waste.',
      ],
    ),
    _InfographicItem(
      icon: Icons.eco_rounded,
      title: 'Zero-Waste & Low-Waste Lifestyle',
      subtitle:
          'Beyond sorting trash, the goal is to create less trash from the beginning.',
      bullets: [
        'Carry a reusable tumbler, chopsticks, and shopping bag.',
        'Buy in bulk or at refill shops when possible.',
        'Choose durable products instead of disposables.',
      ],
    ),
    _InfographicItem(
      icon: Icons.people_alt_rounded,
      title: 'Community Impact',
      subtitle:
          'Your habits influence family, friends, and neighbors in your building.',
      bullets: [
        'Sorting your trash correctly sets a visual example for others.',
        'Share simple tips with friends who are new to Korea.',
        'Join local or school eco clubs to spread good practices.',
      ],
    ),
  ],
};

// Eco tips per level (English, Korea context)
final Map<_Level, List<String>> _ecoTips = {
  _Level.beginner: [
    'Bring a reusable shopping bag when you go to the mart or convenience store. In Korea, you often have to buy plastic bags.',
    'Choose “no disposable cutlery” when ordering delivery (배달) to reduce plastic waste.',
    'Rinse PET bottles quickly with water before recycling to avoid bad smells in the recycling area.',
  ],
  _Level.intermediate: [
    'Keep a small box or basket at home for batteries and small electronics; drop them at a dedicated collection point rather than general waste.',
    'Flatten cardboard boxes and tie them with string; this makes collection easier for the recycling workers.',
    'If your building separates transparent PET bottles, store them in a mesh or clear bag as instructed.',
  ],
  _Level.advanced: [
    'Track your weekly general waste bag usage. Try to reduce the number or size of 종량제 bags you use.',
    'Visit a zero-waste or refill store in your city and try replacing one frequently used product with a refillable option.',
    'Organize a small eco-awareness event or challenge in your dorm or neighborhood, such as “Plastic-Free Week”.',
  ],
};

// Myth vs Fact per level
final Map<_Level, List<_MythFact>> _myths = {
  _Level.beginner: const [
    _MythFact(
      statement:
          '“If I put everything into the recycling bin, it will all be recycled.”',
      isMyth: true,
      explanation:
          'Myth. In Korea, only items that are sorted correctly and clean enough can actually be recycled. Contaminated or mixed items may be treated as general waste.',
    ),
    _MythFact(
      statement: '“Paper cups always go into the paper recycling bin.”',
      isMyth: true,
      explanation:
          'Myth. Many paper cups have a plastic coating and are not accepted as normal paper. Unless your area has a special collection for paper cups, they often go into general waste.',
    ),
    _MythFact(
      statement: '“I must wash recyclables perfectly like new.”',
      isMyth: true,
      explanation:
          'Myth. In most cases, you only need to remove food or liquid so that the item is reasonably clean. A quick rinse is usually enough.',
    ),
  ],
  _Level.intermediate: const [
    _MythFact(
      statement: '“All plastics with a recycling symbol can be recycled.”',
      isMyth: true,
      explanation:
          'Myth. The symbol only shows the material type. Actual recyclability depends on local facilities, contamination, and whether your district accepts that type.',
    ),
    _MythFact(
      statement:
          '“If a pizza box has only a little oil, it is always fine in the paper bin.”',
      isMyth: true,
      explanation:
          'Myth. Heavy grease or food residue can cause problems. In many areas, oily boxes are treated as general waste. When possible, cut off the clean part and recycle only that.',
    ),
    _MythFact(
      statement: '“Broken glass always goes into the glass recycling bin.”',
      isMyth: true,
      explanation:
          'Myth. Some types of glass (heat-resistant glass, mirrors, ceramics) are not suitable for glass recycling. They often need to be wrapped and treated as general or bulky waste.',
    ),
  ],
  _Level.advanced: const [
    _MythFact(
      statement: '“Biodegradable plastics disappear quickly in nature.”',
      isMyth: true,
      explanation:
          'Myth. Many so-called “biodegradable” plastics require special industrial conditions to break down and may not decompose quickly in the environment or normal landfills.',
    ),
    _MythFact(
      statement:
          '“As long as I recycle, it is okay to use a lot of single-use items.”',
      isMyth: true,
      explanation:
          'Myth. Recycling helps, but reducing and reusing are more effective. Korea’s policies encourage using fewer disposables by charging for bags and limiting single-use cutlery.',
    ),
    _MythFact(
      statement:
          '“Individual actions do not matter because waste is a systemic problem.”',
      isMyth: true,
      explanation:
          'Myth. Systemic change is important, but individual habits influence demand, policy support, and community culture—especially in dense urban environments like Korean cities.',
    ),
  ],
};
