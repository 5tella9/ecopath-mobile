import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecopath/theme/app_theme.dart';
import 'package:ecopath/theme/theme_controller.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = context.watch<ThemeController>();

    final previews = AppTheme.previews; // List<_ThemePreview>

    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Reduce glare and save battery on OLED'),
              value: ctrl.isDark,
              onChanged: (v) => ctrl.toggleDarkMode(v),
            ),
          ),
          const SizedBox(height: 16),
          Text('Color Themes', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: previews.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final p = previews[index];
              final selected = ctrl.themeId == p.id;
              return _ThemeTile(
                title: p.title,
                color: p.color,
                selected: selected,
                onTap: () => ctrl.setTheme(p.id),
              );
            },
          ),

          const SizedBox(height: 16),
          Text(
            'Your selection applies instantly across the app. '
            'You can change it anytime in Settings.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.title,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Swatch(color: color),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.9,
      child: Row(
        children: [
          Expanded(child: _blob(color)),
          Expanded(child: _blob(Color.alphaBlend(Colors.white24, color))),
          Expanded(child: _blob(Color.alphaBlend(Colors.black26, color))),
        ],
      ),
    );
  }

  Widget _blob(Color c) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
