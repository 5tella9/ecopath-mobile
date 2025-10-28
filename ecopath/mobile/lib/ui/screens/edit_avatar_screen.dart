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

  void _saveAndClose() async {
    // show alert: "Saved Successfully!"
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Saved Successfully!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00221C),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF007AFF), // iOS blue
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    // after dismissing alert, go back to Profile screen
    Navigator.of(context).pop({
      "character": _selectedChar,
      "background": _selectedBg,
    });
  }

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF00221C);
    const pageBg = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: pageBg,
          width: double.infinity,
          child: Column(
            children: [
              // Top bar with back + title + Done
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    // Back
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // just go back
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: dark,
                      ),
                    ),
                    const SizedBox(width: 8),

                    const Expanded(
                      child: Text(
                        'Edit Avatar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: dark,
                        ),
                      ),
                    ),

                    // Done button
                    TextButton(
                      onPressed: _saveAndClose,
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF007AFF), // iOS blue style
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Character',
                      selected: _tabIndex == 0,
                      onTap: () {
                        setState(() {
                          _tabIndex = 0;
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    _TabButton(
                      label: 'Background Color',
                      selected: _tabIndex == 1,
                      onTap: () {
                        setState(() {
                          _tabIndex = 1;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Content under tab (grid)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: _tabIndex == 0
                      ? _CharacterGrid(
                          characters: _characters,
                          selected: _selectedChar,
                          onSelect: (val) {
                            setState(() {
                              _selectedChar = val;
                            });
                          },
                        )
                      : _BgGrid(
                          bgAssets: _bgColors,
                          selected: _selectedBg,
                          onSelect: (val) {
                            setState(() {
                              _selectedBg = val;
                            });
                          },
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
    // We'll render background as a circle using bgAsset as decoration image,
    // and then overlay the animal character in the middle.

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
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
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

// ========= Tab Button Widget =========
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
    const dark = Color(0xFF00221C);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE0F0ED) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? dark : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? dark : Colors.black87,
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
                    color: isChosen ? const Color(0xFF00221C) : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
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
              // we can show nothing or show label; for now no text
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
                    color: isChosen ? const Color(0xFF00221C) : Colors.transparent,
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: AssetImage(assetPath),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
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
