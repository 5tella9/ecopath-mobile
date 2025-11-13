import 'package:flutter/material.dart';

enum AppThemeId { eco, ocean, sunset, lavender, mocha, highContrast }

class _ThemeMeta {
  final String title;
  final Color seed;
  const _ThemeMeta(this.title, this.seed);
}

class AppTheme {
  // Original tokens for your default "Eco"
  static const Color bg = Color(0xFFF6F7F5);
  static const Color text = Color(0xFF111111);
  static const Color muted = Color(0xFFC9D0C9);
  static const Color divider = Color(0xFFE2E5E1);
  static const Color selected = Color(0xFF0F0F0F);

  static const Map<AppThemeId, _ThemeMeta> _meta = {
    AppThemeId.eco: _ThemeMeta("Eco (Default)", Color(0xFF00221C)),
    AppThemeId.ocean: _ThemeMeta("Ocean", Color(0xFF005E7A)),
    AppThemeId.sunset: _ThemeMeta("Sunset", Color(0xFFB84A2B)),
    AppThemeId.lavender: _ThemeMeta("Lavender", Color(0xFF5A5DB5)),
    AppThemeId.mocha: _ThemeMeta("Mocha", Color(0xFF6D4C41)),
    AppThemeId.highContrast: _ThemeMeta("High Contrast", Color(0xFF000000)),
  };

  static String title(AppThemeId id) => _meta[id]!.title;
  static Color seed(AppThemeId id) => _meta[id]!.seed;

  // For the picker grid
  static List<_ThemePreview> get previews {
    final list = <_ThemePreview>[];
    for (final id in AppThemeId.values) {
      final m = _meta[id]!;
      list.add(_ThemePreview(id: id, title: m.title, color: m.seed));
    }
    return list;
  }

  static ThemeData themeOf(AppThemeId id, {bool dark = false}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed(id),
      brightness: dark ? Brightness.dark : Brightness.light,
    );

    final bool isEco = id == AppThemeId.eco && !dark;

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,

      // Surfaces
      scaffoldBackgroundColor: isEco ? bg : null,
      cardColor: scheme.surface, // global card color (safe across versions)

      fontFamily: 'SF Pro Text',

      // Text
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontSize: 16,
          color: dark ? scheme.onSurface : (isEco ? text : scheme.onSurface),
        ),
      ),

      // Icons
      iconTheme: IconThemeData(
        size: 26,
        color: dark
            ? scheme.onSurfaceVariant
            : (isEco ? muted : scheme.onSurfaceVariant),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
      ),

      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: scheme.primary,
        unselectedItemColor:
            dark ? scheme.onSurfaceVariant : (isEco ? muted : scheme.outline),
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        showUnselectedLabels: true,
        elevation: 0,
        backgroundColor: dark ? scheme.surface : (isEco ? bg : scheme.surface),
      ),

      // Cards / Inputs
      cardTheme: CardThemeData( // <-- CardThemeData (not CardTheme)
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
        fillColor: scheme.surface,
      ),
      dividerTheme: DividerThemeData(
        color: dark ? scheme.outlineVariant : divider,
        thickness: 1,
      ),
    );
  }
}

class _ThemePreview {
  final AppThemeId id;
  final String title;
  final Color color;
  const _ThemePreview({
    required this.id,
    required this.title,
    required this.color,
  });
}
