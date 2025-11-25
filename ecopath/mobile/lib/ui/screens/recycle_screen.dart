// lib/ui/screens/recycle_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ecopath/core/progress_tracker.dart';
import 'package:ecopath/core/recycle_history.dart';

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
                title: const Text('Take a photo'),
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
                title: const Text('Choose from gallery'),
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
                  "Not enough energy",
                  style: GoogleFonts.alike(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You need $_energyCost energy to recycle.\n"
                  "Current energy: $currentEnergy",
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
                    child: const Text("Quit"),
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

    if (_category == null) {
      _showValidationSnack("Please choose what you recycled.");
      return;
    }
    if (_descController.text.trim().isEmpty) {
      _showValidationSnack("Please add a short description.");
      return;
    }
    if (_imageFile == null) {
      _showValidationSnack("Please upload a photo as proof.");
      return;
    }

    final currentEnergy = tracker.energy;
    if (currentEnergy < _energyCost) {
      _showNotEnoughEnergyDialog(currentEnergy);
      return;
    }

    setState(() => _submitting = true);

    // Spend energy (void, always succeeds as long as we checked above)
    tracker.spendEnergy(_energyCost);

    final int earnedPoints = _previewPoints;

    // ✅ Use game reward API so points + XP + notifications are handled
    tracker.rewardFromGame(
      points: earnedPoints,
      gameName: 'Recycle',
    );

    // Log recycle history (for Profile calendar)
    RecycleHistory.instance.addRecycle(DateTime.now(), earnedPoints);

    setState(() => _submitting = false);

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
                  "Nice job! ♻️",
                  style: GoogleFonts.alike(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "You earned $earnedPoints points for recycling.\n"
                  "This will show up in your Recycle History on the Profile page.",
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
                    child: const Text("Back to Games"),
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
    switch (cat) {
      case RecycleCategory.plastic:
        return "Plastic";
      case RecycleCategory.paper:
        return "Paper";
      case RecycleCategory.metal:
        return "Metal";
      case RecycleCategory.glass:
        return "Glass";
      case RecycleCategory.ewaste:
        return "E-waste";
      case RecycleCategory.other:
        return "Other";
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

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final tracker = ProgressTracker.instance;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Recycle',
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
              const SizedBox(height: 20),
              Text(
                "Complete your recycling mission",
                style: GoogleFonts.alike(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              _buildCategorySection(cs),
              const SizedBox(height: 16),
              _buildDescriptionSection(cs),
              const SizedBox(height: 16),
              _buildPhotoSection(cs),
              const SizedBox(height: 16),
              _buildQuantitySection(cs),
              const SizedBox(height: 20),
              _buildPointsPreview(cs),
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
                          "Recycle & claim points",
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

  Widget _buildCategorySection(ColorScheme cs) {
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
            "Step 1 • What did you recycle?",
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

  Widget _buildDescriptionSection(ColorScheme cs) {
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
            "Step 2 • Add a short note",
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
              hintText: "e.g. 3 plastic bottles and 2 cans",
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

  Widget _buildPhotoSection(ColorScheme cs) {
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
            "Step 3 • Upload a photo",
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
                          "Tap to take or choose a photo\nas proof of your recycling",
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

  Widget _buildQuantitySection(ColorScheme cs) {
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
            "How many items?",
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Move the slider to estimate how many items you recycled.",
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

  Widget _buildPointsPreview(ColorScheme cs) {
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
                  "Estimated reward",
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$_previewPoints points · $_quantity item(s)",
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
                "♻️",
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
                  "Recycle to earn points",
                  style: GoogleFonts.alike(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Upload proof of your recycling. Each mission costs $energyCost energy.",
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
                  "$energyCurrent/$energyMax",
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
