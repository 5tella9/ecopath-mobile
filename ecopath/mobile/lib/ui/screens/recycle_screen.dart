// lib/ui/screens/recycle_screen.dart
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecopath/core/api_config.dart';
import 'package:ecopath/core/progress_tracker.dart';
import 'package:ecopath/core/recycle_history.dart';
import 'package:ecopath/l10n/app_localizations.dart';

enum RecycleCategory { plastic, paper, metal, glass, ewaste, other }

class RecycleScreen extends StatefulWidget {
  const RecycleScreen({super.key});

  @override
  State<RecycleScreen> createState() => _RecycleScreenState();
}

class _RecycleScreenState extends State<RecycleScreen> {
  final _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  RecycleCategory? _category;
  int _quantity = 1;
  File? _imageFile;
  bool _submitting = false;

  static const int _energyCost = 3;
  static const int _pointsPerItem = 5;

  bool _hasShownInstructions = false;

  @override
  void initState() {
    super.initState();
    // Show instructions automatically the first time the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownInstructions) {
        _showInstructionsSheet();
        _hasShownInstructions = true;
      }
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  int get _previewPoints => _quantity * _pointsPerItem;

  Future<void> _pickImage() async {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(AppLocalizations.of(context)!.recycleTakePhoto),
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? picked =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    setState(() => _imageFile = File(picked.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title:
                    Text(AppLocalizations.of(context)!.recycleChooseFromGallery),
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? picked =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => _imageFile = File(picked.path));
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showNotEnoughEnergyDialog(int currentEnergy) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierColor: cs.scrim.withOpacity(0.4),
      builder: (ctx) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 26),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.recycleNotEnoughEnergyTitle,
                  style: GoogleFonts.alike(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.recycleNotEnoughEnergyBody(_energyCost, currentEnergy),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: cs.onError,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx); // close dialog
                      Navigator.pop(context); // quit recycle screen
                    },
                    child: Text(t.recycleNotEnoughEnergyQuit),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showValidationSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _handleSubmit() async {
    final tracker = ProgressTracker.instance;
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    if (_category == null) {
      _showValidationSnack(t.recycleValidationChooseCategory);
      return;
    }
    if (_descController.text.trim().isEmpty) {
      _showValidationSnack(t.recycleValidationAddDescription);
      return;
    }
    if (_imageFile == null) {
      _showValidationSnack(t.recycleValidationAddPhoto);
      return;
    }

    final currentEnergy = tracker.energy;
    if (currentEnergy < _energyCost) {
      _showNotEnoughEnergyDialog(currentEnergy);
      return;
    }

    setState(() => _submitting = true);

    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Read image file as bytes and convert to base64
      final bytes = await _imageFile!.readAsBytes();
      final base64Img = base64Encode(bytes);

      // Make API call to waste-scan endpoint
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/waste-scan'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': base64Img,
          'timestamp': DateTime.now().toIso8601String(),
          'wasteType': _category.toString().split('.').last,
          'geolocation': {
            'longitude': position.longitude,
            'latitude': position.latitude,
          },
          'description': _descController.text.trim(),
        }),
      );


      // Spend energy only after successful API call
      tracker.spendEnergy(_energyCost);

      final int earnedPoints = _previewPoints;

      // Reward through game API
      tracker.rewardFromGame(
        points: earnedPoints,
        gameName: 'Recycle',
      );

      // Log recycle history (for Profile calendar)
      RecycleHistory.instance.addRecycle(DateTime.now(), earnedPoints);

      setState(() => _submitting = false);
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting waste scan: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Show success bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.recycleSuccessTitle,
                  style: GoogleFonts.alike(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t.recycleSuccessBody(_previewPoints),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx); // close sheet
                      Navigator.pop(context); // back to Games
                    },
                    child: Text(t.recycleSuccessBackButton),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _categoryLabel(RecycleCategory cat) {
    final t = AppLocalizations.of(context)!;
    switch (cat) {
      case RecycleCategory.plastic:
        return t.recycleCategoryPlastic;
      case RecycleCategory.paper:
        return t.recycleCategoryPaper;
      case RecycleCategory.metal:
        return t.recycleCategoryMetal;
      case RecycleCategory.glass:
        return t.recycleCategoryGlass;
      case RecycleCategory.ewaste:
        return t.recycleCategoryEwaste;
      case RecycleCategory.other:
        return t.recycleCategoryOther;
    }
  }

  IconData _categoryIcon(RecycleCategory cat) {
    switch (cat) {
      case RecycleCategory.plastic:
        return Icons.local_drink_outlined;
      case RecycleCategory.paper:
        return Icons.article_outlined;
      case RecycleCategory.metal:
        return Icons.recycling_outlined;
      case RecycleCategory.glass:
        return Icons.wine_bar_outlined;
      case RecycleCategory.ewaste:
        return Icons.memory_outlined;
      case RecycleCategory.other:
        return Icons.more_horiz;
    }
  }

  // ---------- INSTRUCTIONS SHEET ----------

  Future<void> _showInstructionsSheet() async {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.recycleInstrTitle,
                        style: GoogleFonts.alike(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.recycleInstrIntro,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ruleBullet(cs, t.recycleInstrRule1),
                  _ruleBullet(cs, t.recycleInstrRule2),
                  _ruleBullet(cs, t.recycleInstrRule3),
                  _ruleBullet(cs, t.recycleInstrRule4),
                  const SizedBox(height: 16),

                  Text(
                    t.recycleInstrWhatGoesWhere,
                    style: GoogleFonts.alike(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _categoryCard(
                    cs: cs,
                    title: t.recyclePaperTitle,
                    prep: t.recyclePaperPrep,
                    disposal: t.recyclePaperDisposal,
                  ),
                  const SizedBox(height: 8),
                  _categoryCard(
                    cs: cs,
                    title: t.recyclePaperPackTitle,
                    prep: t.recyclePaperPackPrep,
                    disposal: t.recyclePaperPackDisposal,
                  ),
                  const SizedBox(height: 8),
                  _categoryCard(
                    cs: cs,
                    title: t.recycleCansMetalsTitle,
                    prep: t.recycleCansMetalsPrep,
                    disposal: t.recycleCansMetalsDisposal,
                  ),
                  const SizedBox(height: 8),
                  _categoryCard(
                    cs: cs,
                    title: t.recycleGlassTitle,
                    prep: t.recycleGlassPrep,
                    disposal: t.recycleGlassDisposal,
                  ),
                  const SizedBox(height: 8),
                  _categoryCard(
                    cs: cs,
                    title: t.recyclePlasticsTitle,
                    prep: t.recyclePlasticsPrep,
                    disposal: t.recyclePlasticsDisposal,
                  ),
                  const SizedBox(height: 8),
                  _categoryCard(
                    cs: cs,
                    title: t.recycleVinylTitle,
                    prep: t.recycleVinylPrep,
                    disposal: t.recycleVinylDisposal,
                  ),
                  const SizedBox(height: 8),
                  _categoryCard(
                    cs: cs,
                    title: t.recycleStyrofoamTitle,
                    prep: t.recycleStyrofoamPrep,
                    disposal: t.recycleStyrofoamDisposal,
                  ),
                  const SizedBox(height: 18),

                  Text(
                    t.recycleInstrBagsTitle,
                    style: GoogleFonts.alike(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _categoryCard(
                    cs: cs,
                    title: t.recycleBagGeneralTitle,
                    prep: t.recycleBagGeneralPrep,
                    disposal: t.recycleBagGeneralDisposal,
                  ),
                  const SizedBox(height: 8),
                  _categoryCard(
                    cs: cs,
                    title: t.recycleBagFoodTitle,
                    prep: t.recycleBagFoodPrep,
                    disposal: t.recycleBagFoodDisposal,
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(t.recycleInstrGotIt),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _ruleBullet(ColorScheme cs, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline,
              size: 16, color: cs.primary.withOpacity(0.9)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard({
    required ColorScheme cs,
    required String title,
    required String prep,
    required String disposal,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            prep,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 11,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            disposal,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- BUILD UI ----------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tracker = ProgressTracker.instance;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.recycleTitle,
          style: GoogleFonts.alike(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(
                energyCurrent: tracker.energy,
                energyMax: ProgressTracker.maxEnergy,
                energyCost: _energyCost,
              ),
              const SizedBox(height: 16),

              // Instructions button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _showInstructionsSheet,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  icon: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: cs.primary,
                  ),
                  label: Text(
                    t.recycleInstructionsButton,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              Text(
                t.recycleCompleteMissionTitle,
                style: GoogleFonts.alike(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              _buildCategorySection(context, cs),
              const SizedBox(height: 16),
              _buildDescriptionSection(context, cs),
              const SizedBox(height: 16),
              _buildPhotoSection(context, cs),
              const SizedBox(height: 16),
              _buildQuantitySection(context, cs),
              const SizedBox(height: 20),
              _buildPointsPreview(context, cs),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          t.recycleSubmitButton,
                          style: GoogleFonts.alike(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, ColorScheme cs) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.recycleStep1Title,
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: RecycleCategory.values.map((cat) {
              final selected = _category == cat;
              return GestureDetector(
                onTap: () => setState(() => _category = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? cs.primary
                        : cs.surfaceContainerHighest.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? cs.primary
                          : cs.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _categoryIcon(cat),
                        size: 16,
                        color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _categoryLabel(cat),
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              selected ? cs.onPrimary : cs.onSurfaceVariant,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, ColorScheme cs) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.recycleStep2Title,
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: t.recycleStep2Hint,
              hintStyle: TextStyle(color: cs.onSurfaceVariant),
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: cs.primary, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context, ColorScheme cs) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.recycleStep3Title,
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.7),
                  style: BorderStyle.solid,
                  width: 1.2,
                ),
              ),
              child: _imageFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            size: 28, color: cs.onSurfaceVariant),
                        const SizedBox(height: 8),
                        Text(
                          t.recycleStep3Hint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        _imageFile!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection(BuildContext context, ColorScheme cs) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.recycleQtyTitle,
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.recycleQtySubtitle,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _quantity.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$_quantity',
                  onChanged: (v) {
                    setState(() => _quantity = v.round());
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_quantity',
                  style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsPreview(BuildContext context, ColorScheme cs) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.stars_rounded, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.recycleEstimatedRewardTitle,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_previewPoints pts · $_quantity item(s)',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
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

class _HeaderCard extends StatelessWidget {
  final int energyCurrent;
  final int energyMax;
  final int energyCost;

  const _HeaderCard({
    required this.energyCurrent,
    required this.energyMax,
    required this.energyCost,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                '♻️',
                style: TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.recycleHeaderTitle,
                  style: GoogleFonts.alike(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.recycleHeaderSubtitle(energyCost),
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt, size: 16, color: cs.onSecondaryContainer),
                const SizedBox(width: 4),
                Text(
                  '$energyCurrent/$energyMax',
                  style: TextStyle(
                    color: cs.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
