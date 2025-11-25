// lib/ui/screens/shop_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:ecopath/core/progress_tracker.dart';
import 'mybag_screen.dart'; // for BagItem + globalBagInventory

class BagRule {
  final String colorName;        // e.g. "Yellow Bag"
  final String assetPath;        // e.g. assets/images/yellowbag.png
  final String wasteType;        // "Food Waste" or "General Waste"
  final int basePointsPerLiter;  // pricing base

  BagRule(
    this.colorName,
    this.assetPath,
    this.wasteType, {
    required this.basePointsPerLiter,
  });
}

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String? _selectedRegion;   // e.g. "Seoul"
  String? _selectedDistrict; // e.g. "Gangnam-gu", "Cheonan-si Dongnam-gu"

  bool _loadingAddresses = true;

  // Populated from assets/data/kr_address.json
  List<String> _regions = [];
  Map<String, List<String>> _districtsByRegion = {};

  // Per-card UI state
  final List<int> _selectedSizeL = [];
  final List<int> _quantity = [];
  final List<int> _sizeOptions = [1, 2, 3, 5, 10, 20, 30];

  // ---- BAG DEFINITIONS ----
  final BagRule whiteGeneral = BagRule(
    "White Bag", "assets/images/whitebag.png", "General Waste",
    basePointsPerLiter: 2,
  );

  final BagRule greenGeneral = BagRule(
    "Green Bag", "assets/images/greenbag.png", "General Waste",
    basePointsPerLiter: 2,
  );

  final BagRule blueGeneral = BagRule(
    "Blue Bag", "assets/images/bluebag.png", "General Waste",
    basePointsPerLiter: 2,
  );

  final BagRule blueFood = BagRule(
    "Blue Bag", "assets/images/bluebag.png", "Food Waste",
    basePointsPerLiter: 2,
  );

  final BagRule pinkGeneral = BagRule(
    "Pink Bag", "assets/images/pinkbag.png", "General Waste",
    basePointsPerLiter: 2,
  );

  final BagRule pinkFood = BagRule(
    "Pink Bag", "assets/images/pinkbag.png", "Food Waste",
    basePointsPerLiter: 2,
  );

  final BagRule yellowGeneral = BagRule(
    "Yellow Bag", "assets/images/yellowbag.png", "General Waste",
    basePointsPerLiter: 3,
  );

  final BagRule yellowFood = BagRule(
    "Yellow Bag", "assets/images/yellowbag.png", "Food Waste",
    basePointsPerLiter: 3,
  );

  final BagRule purpleGeneral = BagRule(
    "Purple Bag", "assets/images/purplebag.png", "General Waste",
    basePointsPerLiter: 3,
  );

  final BagRule purpleFood = BagRule(
    "Purple Bag", "assets/images/purplebag.png", "Food Waste",
    basePointsPerLiter: 3,
  );

  final BagRule orangeFood = BagRule(
    "Orange Bag", "assets/images/orangebag.png", "Food Waste",
    basePointsPerLiter: 3,
  );

  @override
  void initState() {
    super.initState();
    _loadAddressData();
  }

  Future<void> _loadAddressData() async {
    try {
      final raw = await rootBundle.loadString('assets/data/kr_address.json');
      final decoded = jsonDecode(raw);

      final Map<String, dynamic> map =
          decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      final regions = <String>[];
      final districtsByRegion = <String, List<String>>{};

      map.forEach((regionName, districtsDynamic) {
        regions.add(regionName.toString());
        final list = <String>[];
        if (districtsDynamic is List) {
          for (final d in districtsDynamic) {
            list.add(d.toString());
          }
        }
        districtsByRegion[regionName.toString()] = list;
      });

      regions.sort();

      setState(() {
        _regions = regions;
        _districtsByRegion = districtsByRegion;
        _loadingAddresses = false;
      });
    } catch (e) {
      setState(() => _loadingAddresses = false);
    }
  }

  // --------------------- CORE BAG LOGIC ---------------------

  List<BagRule> _getVisibleBags() {
    if (_selectedRegion == null || _selectedDistrict == null) return [];

    final region = _selectedRegion!;
    final district = _selectedDistrict!;

    final List<BagRule> result = [];

    // ----- GREEN BAG (General Waste) -----
    final isSeongnamArea =
        region == "Gyeonggi-do" && (district.contains("Seongnam-si "));
    final isHanam = region == "Gyeonggi-do" && district == "Hanam-si";
    final isPyeongtaek = region == "Gyeonggi-do" && district == "Pyeongtaek-si";

    if (isSeongnamArea || isHanam || isPyeongtaek) {
      result.add(greenGeneral);
    }

    // ----- BLUE BAG -----
    // Blue general: Gwangju Seo-gu
    if (region == "Gwangju" && district == "Seo-gu") {
      result.add(blueGeneral);
    }
    // Blue food: Seoul Seocho-gu
    if (region == "Seoul" && district == "Seocho-gu") {
      result.add(blueFood);
    }

    // ----- PINK BAG -----
    // Pink general: Gwangju Gwangsan-gu
    if (region == "Gwangju" && district == "Gwangsan-gu") {
      result.add(pinkGeneral);
    }
    // Pink food: Cheonan-si (Dongnam-gu/Seobuk-gu)
    final isCheonan =
        region == "Chungcheongnam-do" && district.startsWith("Cheonan-si ");
    if (isCheonan) {
      result.add(pinkFood);
    }

    // ----- YELLOW BAG -----
    // Yellow general: Gwangju Nam-gu
    if (region == "Gwangju" && district == "Nam-gu") {
      result.add(yellowGeneral);
    }
    // Yellow food: Seongnam-si Bundang-gu, Asan-si, most Seoul (except Seocho, Gwangjin)
    if (region == "Gyeonggi-do" && district == "Seongnam-si Bundang-gu") {
      result.add(yellowFood);
    }
    if (region == "Chungcheongnam-do" && district == "Asan-si") {
      result.add(yellowFood);
    }
    if (region == "Seoul" &&
        district != "Seocho-gu" &&
        district != "Gwangjin-gu") {
      result.add(yellowFood);
    }

    // ----- PURPLE BAG -----
    // Purple general: Gwangju Dong-gu
    if (region == "Gwangju" && district == "Dong-gu") {
      result.add(purpleGeneral);
    }
    // Purple food: Seoul Gwangjin-gu, Cheonan-si (again)
    if (region == "Seoul" && district == "Gwangjin-gu") {
      result.add(purpleFood);
    }
    if (isCheonan) {
      result.add(purpleFood);
    }

    // ----- ORANGE BAG -----
    // Orange food: Pyeongtaek-si
    if (region == "Gyeonggi-do" && district == "Pyeongtaek-si") {
      result.add(orangeFood);
    }

    // ----- WHITE BAG (national general default unless excluded) -----
    final allowWhite = _shouldAllowWhiteBag(region, district);
    if (allowWhite) {
      final alreadyHasWhite = result.any((b) => b.colorName == "White Bag");
      if (!alreadyHasWhite) result.add(whiteGeneral);
    }
    if (result.isEmpty && allowWhite) {
      result.add(whiteGeneral);
    }

    // ====== DEFAULT FOOD-WASTE FALLBACK ======
    final hasFoodWaste = result.any((b) => b.wasteType == "Food Waste");
    if (!hasFoodWaste) {
      result.add(yellowFood);
    }
    // =========================================

    return result;
  }

  bool _shouldAllowWhiteBag(String region, String district) {
    // Exclusions for white general
    if (region == "Gyeonggi-do" && district.contains("Seongnam-si ")) {
      return false;
    }
    if (region == "Gyeonggi-do" && district == "Hanam-si") return false;
    if (region == "Gyeonggi-do" && district == "Pyeongtaek-si") return false;
    if (region == "Gwangju" && district == "Gwangsan-gu") return false;
    if (region == "Gwangju" && district == "Nam-gu") return false;
    if (region == "Gwangju" && district == "Dong-gu") return false;
    // Gwangju Seo-gu: allow white alongside blue → not excluded
    return true;
  }

  // --------------------- BUY FLOW ---------------------

  int _calcCostPoints(int index, List<BagRule> visibleBags) {
    final bag = visibleBags[index];
    final sizeL = _selectedSizeL[index];
    final qty = _quantity[index];
    return bag.basePointsPerLiter * sizeL * qty;
  }

  Future<void> _tryBuy(int index, List<BagRule> visibleBags) async {
    final tracker = ProgressTracker.instance;
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final cost = _calcCostPoints(index, visibleBags);
    final currentPoints = tracker.totalPoints; // same source as GamesScreen

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Purchase',
          style: textTheme.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.lato().fontFamily,
          ),
        ),
        content: Text(
          'Are you sure you want to buy this plastic bag?',
          style: GoogleFonts.lato(
            color: cs.onSurface.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'No',
              style: GoogleFonts.lato(color: cs.onSurface.withOpacity(0.8)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Yes',
              style: GoogleFonts.lato(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (cost > currentPoints) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Not enough points',
            style: textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.lato().fontFamily,
            ),
          ),
          content: Text(
            'You only have $currentPoints pts.',
            style: GoogleFonts.lato(
              color: cs.onSurface.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.lato(color: cs.primary),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // ✅ Deduct points using shared tracker (stays in sync with games)
    tracker.spendPoints(cost);
    setState(() {});

    // Add to global MyBag inventory
    final bagRule = visibleBags[index];
    final prefix = bagRule.wasteType == 'Food Waste' ? 'FW' : 'GW';
    final millis = DateTime.now().millisecondsSinceEpoch;
    final barcode = '$prefix-$millis';

    globalBagInventory.add(
      BagItem(
        type: '${bagRule.colorName} • ${bagRule.wasteType}',
        imagePath: bagRule.assetPath,
        barcode: barcode,
      ),
    );

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Purchase Complete',
          style: textTheme.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.lato().fontFamily,
          ),
        ),
        content: Text(
          "You bought the bag!\nCheck it in 'My Bags'.",
          style: GoogleFonts.lato(
            color: cs.onSurface.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.lato(color: cs.primary),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------- UI HELPERS ---------------------

  void _syncStateWithVisibleBags(List<BagRule> currentBags) {
    _selectedSizeL
      ..clear()
      ..addAll(List<int>.filled(currentBags.length, 3)); // default 3L
    _quantity
      ..clear()
      ..addAll(List<int>.filled(currentBags.length, 1)); // default 1
  }

  Widget _buildHeaderBar(BuildContext context, int userPoints) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline.withOpacity(0.3), width: 1),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: cs.onSurface,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Shop',
            style: GoogleFonts.lato(
              color: cs.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.onPrimary.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.stars, size: 18, color: cs.onPrimary),
              const SizedBox(width: 6),
              Text(
                '$userPoints pts',
                style: GoogleFonts.lato(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final regionItems = _regions;
    final districtItems = _selectedRegion == null
        ? <String>[]
        : (_districtsByRegion[_selectedRegion!] ?? <String>[]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your area',
          style: GoogleFonts.lato(
            color: cs.onBackground,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _FilterDropdown<String>(
                label: 'City / Province',
                value: _selectedRegion,
                items: regionItems,
                onChanged: (val) {
                  setState(() {
                    _selectedRegion = val;
                    _selectedDistrict = null;
                    _syncStateWithVisibleBags(_getVisibleBags());
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterDropdown<String>(
                label: 'Neighborhood / District',
                value: _selectedDistrict,
                items: districtItems,
                onChanged: (val) {
                  setState(() {
                    _selectedDistrict = val;
                    _syncStateWithVisibleBags(_getVisibleBags());
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.errorContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.onErrorContainer.withOpacity(0.6), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_rounded,
                color: cs.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Each Korean city/구 prints its own bag color. '
                  'Pick your exact district first.',
                  style: GoogleFonts.lato(
                    color: cs.onErrorContainer,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSizeDropdown(BuildContext context, int index) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withOpacity(0.3), width: 1),
      ),
      child: DropdownButton<int>(
        value: _selectedSizeL[index],
        dropdownColor: cs.surfaceVariant,
        underline: const SizedBox.shrink(),
        iconEnabledColor: cs.onSurface,
        isExpanded: false,
        style: GoogleFonts.lato(color: cs.onSurface),
        items: _sizeOptions
            .map((sz) => DropdownMenuItem<int>(
                  value: sz,
                  child: Text(
                    '${sz}L',
                    style: GoogleFonts.lato(
                      color: cs.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ))
            .toList(),
        onChanged: (val) {
          if (val == null) return;
          setState(() => _selectedSizeL[index] = val);
        },
      ),
    );
  }

  Widget _qtyBtn({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.transparent,
        child: Icon(
          icon,
          color: cs.onSurface,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(BuildContext context, int index) {
    final cs = Theme.of(context).colorScheme;
    final qty = _quantity[index];

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(
            context: context,
            icon: Icons.remove,
            onTap: () {
              setState(() {
                if (_quantity[index] > 1) _quantity[index] -= 1;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              '$qty',
              style: GoogleFonts.lato(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          _qtyBtn(
            context: context,
            icon: Icons.add,
            onTap: () {
              setState(() {
                if (_quantity[index] < 10) _quantity[index] += 1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBagCard(
    BuildContext context,
    int index,
    List<BagRule> visibleBags,
  ) {
    final cs = Theme.of(context).colorScheme;
    final bag = visibleBags[index];
    final cost = _calcCostPoints(index, visibleBags);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: cs.surfaceVariant.withOpacity(0.4),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(bag.assetPath, fit: BoxFit.contain),
              ),
              const SizedBox(width: 12),

              // name + waste type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bag.colorName,
                      style: GoogleFonts.lato(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bag.wasteType,
                      style: GoogleFonts.lato(
                        color: cs.onSurface.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // cost
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$cost pts',
                    style: GoogleFonts.lato(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '(${_quantity[index]}x ${_selectedSizeL[index]}L)',
                    style: GoogleFonts.lato(
                      color: cs.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // size + quantity
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bag Size',
                      style: GoogleFonts.lato(
                        color: cs.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildSizeDropdown(context, index),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: GoogleFonts.lato(
                        color: cs.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildQuantitySelector(context, index),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // buy (UNCHANGED as you asked)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _tryBuy(index, visibleBags),
              child: Text(
                'Buy',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBagListSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final visibleBags = _getVisibleBags();

    if (_loadingAddresses) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          'Loading locations…',
          style: GoogleFonts.lato(
            color: cs.onBackground.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      );
    }

    if (_selectedRegion == null || _selectedDistrict == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          'Select your city / province and district.',
          style: GoogleFonts.lato(
            color: cs.onBackground.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      );
    }

    if (visibleBags.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          'No bag info for this district yet.',
          style: GoogleFonts.lato(
            color: cs.onBackground.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      );
    }

    // Ensure state arrays match the number of visible cards
    if (_selectedSizeL.length != visibleBags.length ||
        _quantity.length != visibleBags.length) {
      _syncStateWithVisibleBags(visibleBags);
    }

    return Column(
      children: List.generate(
        visibleBags.length,
        (i) => _buildBagCard(context, i, visibleBags),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tracker = ProgressTracker.instance;
    final currentPoints = tracker.totalPoints;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBar(context, currentPoints),
              const SizedBox(height: 24),
              _buildFilters(context),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildBagListSection(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- DROPDOWN WIDGET ----------

class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textStyle = GoogleFonts.lato(color: cs.onSurface, fontSize: 14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            color: cs.onSurface.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outline.withOpacity(0.3), width: 1),
          ),
          child: DropdownButton<T>(
            value: value,
            dropdownColor: cs.surfaceVariant,
            underline: const SizedBox.shrink(),
            isExpanded: true,
            iconEnabledColor: cs.onSurface,
            style: textStyle,
            items: items
                .map(
                  (opt) => DropdownMenuItem<T>(
                    value: opt,
                    child: Text('$opt', style: textStyle),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
