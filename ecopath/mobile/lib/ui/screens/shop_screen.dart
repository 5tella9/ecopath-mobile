import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

class BagRule {
  final String colorName;        // e.g. "Yellow Bag"
  final String assetPath;        // e.g. assets/images/yellowbag.png
  final String wasteType;        // e.g. "Food Waste", "General Waste"
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
  int userPoints = 2440;

  String? _selectedRegion;   // e.g. "Seoul"
  String? _selectedDistrict; // e.g. "Gangnam-gu", "Cheonan-si Dongnam-gu"

  bool _loadingAddresses = true;

  // Populated from kr_address.json
  List<String> _regions = [];
  Map<String, List<String>> _districtsByRegion = {};

  // Per-card UI state
  final List<int> _selectedSizeL = [];
  final List<int> _quantity = [];
  final List<int> _sizeOptions = [1, 2, 3, 5, 10, 20, 30];

  // ---- BAG DEFINITIONS (reusable objects) ----
  final BagRule whiteGeneral = BagRule(
    "White Bag",
    "assets/images/whitebag.png",
    "General Waste",
    basePointsPerLiter: 2,
  );

  final BagRule greenGeneral = BagRule(
    "Green Bag",
    "assets/images/greenbag.png",
    "General Waste",
    basePointsPerLiter: 2,
  );

  final BagRule blueGeneral = BagRule(
    "Blue Bag",
    "assets/images/bluebag.png",
    "General Waste",
    basePointsPerLiter: 2,
  );

  final BagRule blueFood = BagRule(
    "Blue Bag",
    "assets/images/bluebag.png",
    "Food Waste",
    basePointsPerLiter: 2,
  );

  final BagRule pinkGeneral = BagRule(
    "Pink Bag",
    "assets/images/pinkbag.png",
    "General Waste",
    basePointsPerLiter: 2,
  );

  final BagRule pinkFood = BagRule(
    "Pink Bag",
    "assets/images/pinkbag.png",
    "Food Waste",
    basePointsPerLiter: 2,
  );

  final BagRule yellowGeneral = BagRule(
    "Yellow Bag",
    "assets/images/yellowbag.png",
    "General Waste",
    basePointsPerLiter: 3,
  );

  final BagRule yellowFood = BagRule(
    "Yellow Bag",
    "assets/images/yellowbag.png",
    "Food Waste",
    basePointsPerLiter: 3,
  );

  final BagRule purpleGeneral = BagRule(
    "Purple Bag",
    "assets/images/purplebag.png",
    "General Waste",
    basePointsPerLiter: 3,
  );

  final BagRule purpleFood = BagRule(
    "Purple Bag",
    "assets/images/purplebag.png",
    "Food Waste",
    basePointsPerLiter: 3,
  );

  final BagRule orangeFood = BagRule(
    "Orange Bag",
    "assets/images/orangebag.png",
    "Food Waste",
    basePointsPerLiter: 3,
  );

  @override
  void initState() {
    super.initState();
    _loadAddressData();
  }

  Future<void> _loadAddressData() async {
    // Read assets/data/kr_address.json
    final raw = await rootBundle.loadString('assets/data/kr_address.json');
    final decoded = jsonDecode(raw);

    // expecting:
    // {
    //   "Seoul": ["Gangnam-gu", "Seocho-gu", ...],
    //   "Gyeonggi-do": ["Seongnam-si Bundang-gu", ...],
    //   ...
    // }
    final Map<String, dynamic> map = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};

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

    setState(() {
      _regions = regions;
      _districtsByRegion = districtsByRegion;
      _loadingAddresses = false;
    });
  }

  // --------------------- CORE BAG LOGIC ---------------------

  // We compute bags for (region, district) following your table.

  List<BagRule> _getVisibleBags() {
    if (_selectedRegion == null || _selectedDistrict == null) return [];

    final region = _selectedRegion!;
    final district = _selectedDistrict!;

    final List<BagRule> result = [];

    // 1. AREA-SPECIFIC RULES FROM YOUR TABLE

    // ----- GREEN BAG (General Waste) -----
    // "Use in Gyeonggi-do Seongnam-si, Gyeonggi-do Hanam-si, Pyeongtaek-si"
    //
    // In kr_address.json:
    //   Gyeonggi-do:
    //     "Seongnam-si Bundang-gu", "Seongnam-si Sujeong-gu", "Seongnam-si Jungwon-gu",
    //     "Hanam-si",
    //     "Pyeongtaek-si"
    final isSeongnamArea =
        region == "Gyeonggi-do" && (district.contains("Seongnam-si "));
    final isHanam = region == "Gyeonggi-do" && district == "Hanam-si";
    final isPyeongtaek = district == "Pyeongtaek-si"; // region should be Gyeonggi-do in your file

    if (isSeongnamArea || isHanam || isPyeongtaek) {
      result.add(greenGeneral);
    }

    // ----- BLUE BAG -----
    // Blue bag general waste: Gwangju Seo-gu
    // Blue bag food waste: Seoul Seocho-gu
    final isGwangjuSeogu = (region == "Gwangju" && district == "Seo-gu");
    if (isGwangjuSeogu) {
      // general waste blue
      result.add(blueGeneral);
      // This area also uses white bag, we'll allow white later by not blocking.
    }

    final isSeoulSeocho = (region == "Seoul" && district == "Seocho-gu");
    if (isSeoulSeocho) {
      // food waste blue
      result.add(blueFood);
    }

    // ----- PINK BAG -----
    // Pink bag general waste: Gwangju Gwangsan-gu
    // Pink bag food waste: Cheonan-si
    //
    // In kr_address.json:
    //   Gwangju: "Gwangsan-gu"
    final isGwangjuGwangsan = (region == "Gwangju" && district == "Gwangsan-gu");
    if (isGwangjuGwangsan) {
      result.add(pinkGeneral);
    }

    //   Cheonan-si in json is split:
    //     "Cheonan-si Dongnam-gu", "Cheonan-si Seobuk-gu"
    final isCheonan = region == "Chungcheongnam-do" && (district.startsWith("Cheonan-si "));
    if (isCheonan) {
      // Pink bag = Food Waste (Cheonan-si)
      result.add(pinkFood);
    }

    // ----- YELLOW BAG -----
    // Yellow bag general waste: Gwangju Nam-gu
    // Yellow bag food waste:
    //   - Seongnam-si Bundang-gu
    //   - Asan-si
    //   - most Seoul area uses as food waste
    final isGwangjuNamgu = (region == "Gwangju" && district == "Nam-gu");
    if (isGwangjuNamgu) {
      result.add(yellowGeneral);
    }

    // Seongnam-si Bundang-gu specifically:
    final isSeongnamBundang = region == "Gyeonggi-do" && district == "Seongnam-si Bundang-gu";
    if (isSeongnamBundang) {
      result.add(yellowFood);
    }

    // Asan-si (Chungcheongnam-do list includes "Asan-si")
    final isAsan = region == "Chungcheongnam-do" && district == "Asan-si";
    if (isAsan) {
      result.add(yellowFood);
    }

    // Seoul: "most Seoul area uses yellow as food waste bag"
    // We'll attach yellowFood for any Seoul district EXCEPT:
    //  - Seocho-gu (blueFood already defined)
    //  - Gwangjin-gu (purpleFood below)
    final isSeoul = region == "Seoul";
    if (isSeoul && district != "Seocho-gu" && district != "Gwangjin-gu") {
      result.add(yellowFood);
    }

    // ----- PURPLE BAG -----
    // Purple bag general waste: Gwangju Dong-gu
    // Purple bag food waste:
    //   - Seoul Gwangjin-gu
    //   - Cheonan-si (again)
    final isGwangjuDonggu = (region == "Gwangju" && district == "Dong-gu");
    if (isGwangjuDonggu) {
      result.add(purpleGeneral);
    }

    final isSeoulGwangjin = (region == "Seoul" && district == "Gwangjin-gu");
    if (isSeoulGwangjin) {
      result.add(purpleFood);
    }

    if (isCheonan) {
      // Cheonan-si also uses purple bag for food waste in your table
      result.add(purpleFood);
    }

    // ----- ORANGE BAG -----
    // Orange bag food waste: Pyeongtaek-si
    final isPyeongtaekOrange = region == "Gyeonggi-do" && district == "Pyeongtaek-si";
    if (isPyeongtaekOrange) {
      result.add(orangeFood);
    }

    // ----- WHITE BAG -----
    // White bag = national general waste default
    // EXCEPT:
    //  - Seongnam-si (all its gus)
    //  - Hanam-si
    //  - Pyeongtaek-si
    //  - Gwangju Gwangsan-gu
    //  - Gwangju Nam-gu
    //  - Gwangju Dong-gu
    //
    // We'll allow white unless this district hits an exclusion case.
    final allowWhite = _shouldAllowWhiteBag(region, district);
    if (allowWhite) {
      final alreadyHasWhite = result.any((b) => b.colorName == "White Bag");
      if (!alreadyHasWhite) {
        result.add(whiteGeneral);
      }
    }
    if (result.isEmpty && allowWhite) {
      result.add(whiteGeneral);
    }

    // ====== NEW: DEFAULT FOOD-WASTE MAPPING ======
    // If no food-waste bag was assigned by the rules above,
    // auto-assign Yellow Food Waste as a fallback.
    final hasFoodWaste = result.any((b) => b.wasteType == "Food Waste");
    if (!hasFoodWaste) {
      result.add(yellowFood);
    }
    // ====== END DEFAULT ======

    return result;
  }

  bool _shouldAllowWhiteBag(String region, String district) {
    // if this district is in a "no white bag for general waste" zone,
    // we return false.

    // 1. Gyeonggi-do Seongnam-si (any gu of Seongnam-si)
    if (region == "Gyeonggi-do" && district.contains("Seongnam-si ")) {
      return false;
    }

    // 2. Gyeonggi-do Hanam-si
    if (region == "Gyeonggi-do" && district == "Hanam-si") {
      return false;
    }

    // 3. Pyeongtaek-si
    if (district == "Pyeongtaek-si") {
      // region == "Gyeonggi-do" in your data, but we just check name
      return false;
    }

    // 4. Gwangju Gwangsan-gu
    if (region == "Gwangju" && district == "Gwangsan-gu") {
      return false;
    }

    // 5. Gwangju Nam-gu
    if (region == "Gwangju" && district == "Nam-gu") {
      return false;
    }

    // 6. Gwangju Dong-gu
    if (region == "Gwangju" && district == "Dong-gu") {
      return false;
    }

    // NOTE:
    // You did NOT say white bag is blocked in Asan-si or Cheonan-si
    // in the new table, so we are allowing white there now.

    // 7. Special case: Gwangju Seo-gu
    // You said "people use both blue and white bag so display both" → allow white
    // (so we do nothing here)

    // otherwise allowed
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
    final cost = _calcCostPoints(index, visibleBags);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF00221C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Confirm Purchase',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure to buy the plastic bag?',
          style: GoogleFonts.lato(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'No',
              style: GoogleFonts.lato(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Yes',
              style: GoogleFonts.lato(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (cost > userPoints) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF00221C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Not enough points',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'You only have $userPoints pts.',
            style: GoogleFonts.lato(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.lato(color: Colors.white),
              ),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      userPoints -= cost;
    });

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF00221C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Purchase Complete',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "You bought the bag!\nCheck it in 'My Plastic Bags'.",
          style: GoogleFonts.lato(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.lato(color: Colors.white),
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

  Widget _buildHeaderBar() {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00362B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Shop',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF00362B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.stars,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                '$userPoints pts',
                style: GoogleFonts.lato(
                  color: Colors.white,
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

  Widget _buildFilters() {
    final regionItems = _regions;
    final districtItems = _selectedRegion == null
        ? <String>[]
        : (_districtsByRegion[_selectedRegion] ?? <String>[]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your area',
          style: GoogleFonts.lato(
            color: Colors.white,
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
                    final bags = _getVisibleBags();
                    _syncStateWithVisibleBags(bags);
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
                    final bags = _getVisibleBags();
                    _syncStateWithVisibleBags(bags);
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
            color: const Color(0xFF3A2A00),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFC107), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Color(0xFFFFC107),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Each Korean city / 구 prints its own bag color.\n'
                  'Pick your exact district first.\n\n'
                  'White Bag = national general waste, EXCEPT:\n'
                  '  • Seongnam-si (all gus)\n'
                  '  • Hanam-si\n'
                  '  • Pyeongtaek-si\n'
                  '  • Gwangsan-gu (Gwangju)\n'
                  '  • Nam-gu (Gwangju)\n'
                  '  • Dong-gu (Gwangju)\n\n'
                  'If no food-waste color is defined for your district, we default to Yellow Food Waste.',
                  style: GoogleFonts.lato(
                    color: Colors.white,
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

  Widget _buildSizeDropdown(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF00362B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: DropdownButton<int>(
        value: _selectedSizeL[index],
        dropdownColor: const Color(0xFF00221C),
        underline: const SizedBox.shrink(),
        iconEnabledColor: Colors.white,
        isExpanded: false,
        style: GoogleFonts.lato(color: Colors.white),
        items: _sizeOptions
            .map(
              (sz) => DropdownMenuItem<int>(
                value: sz,
                child: Text(
                  '${sz}L',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (val) {
          if (val == null) return;
          setState(() {
            _selectedSizeL[index] = val;
          });
        },
      ),
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.transparent,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildQuantitySelector(int index) {
    final qty = _quantity[index];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF00362B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(
            icon: Icons.remove,
            onTap: () {
              setState(() {
                if (_quantity[index] > 1) {
                  _quantity[index] = _quantity[index] - 1;
                }
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              '$qty',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          _qtyBtn(
            icon: Icons.add,
            onTap: () {
              setState(() {
                if (_quantity[index] < 10) {
                  _quantity[index] = _quantity[index] + 1;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBagCard(int index, List<BagRule> visibleBags) {
    final bag = visibleBags[index];
    final cost = _calcCostPoints(index, visibleBags);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00362B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, 6),
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
                  color: Colors.black.withOpacity(0.2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  bag.assetPath,
                  fit: BoxFit.contain,
                ),
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
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bag.wasteType,
                      style: GoogleFonts.lato(
                        color: Colors.white70,
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
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '(${_quantity[index]}x ${_selectedSizeL[index]}L)',
                    style: GoogleFonts.lato(
                      color: Colors.white54,
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
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildSizeDropdown(index),
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
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildQuantitySelector(index),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // buy
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF00221C),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                _tryBuy(index, visibleBags);
              },
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

  Widget _buildBagListSection() {
    final visibleBags = _getVisibleBags();

    if (_loadingAddresses) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          'Loading locations…',
          style: GoogleFonts.lato(
            color: Colors.white54,
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
            color: Colors.white54,
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
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      );
    }

    // sync size/qty state with current visible bag list
    if (_selectedSizeL.length != visibleBags.length ||
        _quantity.length != visibleBags.length) {
      _syncStateWithVisibleBags(visibleBags);
    }

    return Column(
      children: List.generate(
        visibleBags.length,
        (i) => _buildBagCard(i, visibleBags),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF00221C);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBar(),
              const SizedBox(height: 24),
              _buildFilters(),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildBagListSection(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF00362B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: DropdownButton<T>(
            value: value,
            dropdownColor: const Color(0xFF00221C),
            underline: const SizedBox.shrink(),
            isExpanded: true,
            iconEnabledColor: Colors.white,
            style: GoogleFonts.lato(color: Colors.white),
            items: items
                .map(
                  (opt) => DropdownMenuItem<T>(
                    value: opt,
                    child: Text(
                      '$opt',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
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
