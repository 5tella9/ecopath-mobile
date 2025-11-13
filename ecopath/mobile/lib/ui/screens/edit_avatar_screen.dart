// lib/ui/screens/edit_avatar_screen.dart
import 'package:flutter/material.dart';

class EditAvatarScreen extends StatefulWidget {
  const EditAvatarScreen({super.key});

  @override
  State<EditAvatarScreen> createState() => _EditAvatarScreenState();
}

class _EditAvatarScreenState extends State<EditAvatarScreen> {
  // current preview selections
  String _selectedChar = 'assets/images/otter.png'; // default for preview
  String _selectedBg = 'assets/images/green.png';   // default bg

  // which tab is active: 0 = character, 1 = bg color
  int _tabIndex = 0;

  // your provided characters
  final List<String> _characters = [
    'assets/images/bee.png',
    'assets/images/bird.png',
    'assets/images/elephant.png',
    'assets/images/otter.png',
    'assets/images/panda.png',
    'assets/images/polar.png',
    'assets/images/wolf.png',
  ];

  // your provided background color images
  final List<String> _bgColors = [
    'assets/images/green.png',
    'assets/images/earthbrown.png',
    'assets/images/mustard.png',
    'assets/images/olivine.png',
    'assets/images/pink.png',
    'assets/images/seablue.png',
  ];

  Future<void> _saveAndClose() async {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // show alert: "Saved Successfully!"
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Saved Successfully!',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'OK',
                style: tt.titleSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    // after dismissing alert, go back to Profile screen
    if (mounted) {
      Navigator.of(context).pop({
        "character": _selectedChar,
        "background": _selectedBg,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Container(
          color: cs.surface, // page background from theme
          width: double.infinity,
          child: Column(
            children: [
              // Top bar with back + title + Done
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    // Back
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back_ios_new, size: 20, color: cs.onSurface),
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Edit Avatar',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                    ),

                    // Done button
                    TextButton(
                      onPressed: _saveAndClose,
                      child: Text(
                        'Done',
                        style: tt.titleSmall?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Preview avatar (character on background)
              const SizedBox(height: 8),
              _AvatarPreview(
                characterAsset: _selectedChar,
                bgAsset: _selectedBg,
              ),
              const SizedBox(height: 24),

              // Tab buttons row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Character',
                      selected: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                    const SizedBox(width: 12),
                    _TabButton(
                      label: 'Background Color',
                      selected: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Content under tab (grid)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withOpacity(.06),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: _tabIndex == 0
                      ? _CharacterGrid(
                          characters: _characters,
                          selected: _selectedChar,
                          onSelect: (val) => setState(() => _selectedChar = val),
                        )
                      : _BgGrid(
                          bgAssets: _bgColors,
                          selected: _selectedBg,
                          onSelect: (val) => setState(() => _selectedBg = val),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========= Avatar Preview Widget =========
class _AvatarPreview extends StatelessWidget {
  final String characterAsset;
  final String bgAsset;

  const _AvatarPreview({
    required this.characterAsset,
    required this.bgAsset,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        // background circle
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(bgAsset),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),

        // character on top
        ClipOval(
          child: Image.asset(
            characterAsset,
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

// ========= Tab Button Widget (theme-aware) =========
class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withOpacity(.12)
                : cs.surfaceVariant.withOpacity(.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant,
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: tt.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? cs.primary : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

// ========= Character Grid =========
class _CharacterGrid extends StatelessWidget {
  final List<String> characters;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CharacterGrid({
    required this.characters,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GridView.count(
      physics: const BouncingScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: characters.map((assetPath) {
        final bool isChosen = selected == assetPath;
        return GestureDetector(
          onTap: () => onSelect(assetPath),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isChosen ? cs.primary : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(.12),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ========= Background Grid =========
class _BgGrid extends StatelessWidget {
  final List<String> bgAssets;
  final String selected;
  final ValueChanged<String> onSelect;

  const _BgGrid({
    required this.bgAssets,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GridView.count(
      physics: const BouncingScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: bgAssets.map((assetPath) {
        final bool isChosen = selected == assetPath;
        return GestureDetector(
          onTap: () => onSelect(assetPath),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isChosen ? cs.primary : Colors.transparent,
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: AssetImage(assetPath),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(.12),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      }).toList(),
    );
  }
}
