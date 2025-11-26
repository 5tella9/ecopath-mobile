// lib/ui/screens/mybag_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecopath/l10n/app_localizations.dart';

/// Shared model for a bag the user owns (from Shop).
class BagItem {
  final String type;
  final String imagePath;
  final String barcode;

  BagItem({
    required this.type,
    required this.imagePath,
    required this.barcode,
  });
}

/// Global inventory that ShopScreen will add to,
/// and MyBagScreen will display.
final List<BagItem> globalBagInventory = [];

class MyBagScreen extends StatefulWidget {
  const MyBagScreen({super.key});

  @override
  State<MyBagScreen> createState() => _MyBagScreenState();
}

class _MyBagScreenState extends State<MyBagScreen> {
  BagItem? _selectedBag;

  List<BagItem> get _bags => globalBagInventory;

  TextStyle _titleStyle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GoogleFonts.alike(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: cs.onBackground,
    );
  }

  TextStyle _labelStyle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GoogleFonts.lato(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: cs.onSurface,
    );
  }

  TextStyle _hintStyle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GoogleFonts.lato(
      fontSize: 13,
      color: cs.onSurface.withOpacity(0.7),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                cs.surface.withOpacity(0.9),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: cs.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          loc.myBagsTitle,
          style: _titleStyle(context),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildMainContent(context),
          if (_selectedBag != null) _buildBarcodeOverlay(context, _selectedBag!),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_bags.isEmpty) {
      return Center(
        child: Text(
          loc.myBagsEmptyMessage,
          textAlign: TextAlign.center,
          style: _hintStyle(context),
        ),
      );
    }

    final cs = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _bags.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final bag = _bags[index];
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _selectedBag = bag;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    bag.imagePath,
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bag.type, style: _labelStyle(context)),
                      const SizedBox(height: 4),
                      Text(
                        loc.myBagsTapToViewBarcode,
                        style: _hintStyle(context),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.qr_code_2_rounded,
                  color: cs.primary,
                  size: 28,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarcodeOverlay(BuildContext context, BagItem bag) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedBag = null;
          });
        },
        child: Container(
          color: cs.scrim.withOpacity(0.6),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // prevent closing on card tap
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: cs.onSurface.withOpacity(0.8),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedBag = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bag.type,
                      style: GoogleFonts.alike(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFakeBarcodeBox(context, bag.barcode),
                    const SizedBox(height: 10),
                    Text(
                      loc.myBagsShowBarcodeInstruction,
                      textAlign: TextAlign.center,
                      style: _hintStyle(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFakeBarcodeBox(BuildContext context, String code) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outline.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const barCount = 30;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(barCount, (i) {
                    final thick = i % 3 == 0;
                    final isVisibleBar = i.isEven;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        color: isVisibleBar
                            ? cs.onBackground
                                .withOpacity(thick ? 0.9 : 0.5)
                            : Colors.transparent,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            code,
            style: GoogleFonts.robotoMono(
              fontSize: 14,
              letterSpacing: 2,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
