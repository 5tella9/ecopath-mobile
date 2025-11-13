// lib/ui/screens/games_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scantrash_screen.dart';
import 'quiz_screen.dart';
import 'todo_screen.dart';
import 'community_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  int points = 500;
  int energy = 25;
  int level = 3;
  int xp = 140;
  int xpToNext = 200;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final progress = (xp / xpToNext).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- HEADER ROW ----------
              Row(
                children: [
                  Text(
                    'Play & Earn',
                    style: GoogleFonts.lato(
                      color: cs.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  _EnergyPill(energy: energy),
                  const SizedBox(width: 8),
                  _PointsPill(points: points),
                ],
              ),
              const SizedBox(height: 12),

              // ---------- LEVEL CARD ----------
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $level',
                      style: GoogleFonts.lato(
                        color: cs.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: cs.surfaceContainerHighest,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$xp / $xpToNext XP',
                      style: GoogleFonts.alike(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---------- DAILY QUESTS ----------
              Text(
                'Daily Quests',
                style: GoogleFonts.lato(
                  color: cs.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuestChip(text: 'Finish a Quiz'),
                  _QuestChip(text: 'Scan 3 items'),
                  _QuestChip(text: 'Recycle once'),
                ],
              ),
              const SizedBox(height: 16),

              // ---------- GAME GRID ----------
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  padding: const EdgeInsets.only(bottom: 12),
                  children: [
                    _GameTile(
                      title: 'Quiz',
                      tileColor: cs.primaryContainer,
                      assetPath: 'assets/images/quiz.png',
                      onTap: _openQuiz,
                    ),
                    _GameTile(
                      title: 'Scan Trash',
                      tileColor: cs.tertiaryContainer,
                      assetPath: 'assets/images/scantrash.png',
                      onTap: _openScan,
                    ),
                    _GameTile(
                      title: 'Recycle',
                      tileColor: cs.secondaryContainer,
                      assetPath: 'assets/images/recycletrash.png',
                      onTap: _openRecycle,
                    ),
                    _GameTile(
                      title: 'Daily Challenge',
                      tileColor: cs.surfaceTint.withOpacity(.25),
                      assetPath: 'assets/images/todolist.png',
                      iconData: Icons.checklist,
                      onTap: _openTodo,
                    ),
                    _GameTile(
                      title: 'Community',
                      tileColor: cs.primary.withOpacity(.15),
                      assetPath: 'assets/images/star.png',
                      onTap: _openCommunity,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- NAVIGATION / XP LOGIC ----------
  Future<void> _openQuiz() async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );
    if (result != null && result > 0) _gainPoints(result);
  }

  Future<void> _openScan() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScanTrashScreen()),
    );
  }

  void _openRecycle() => _gainPoints(20);

  Future<void> _openTodo() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TodoScreen()),
    );
  }

  Future<void> _openCommunity() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CommunityScreen()),
    );
    _gainPoints(5);
  }

  void _gainPoints(int add) {
    setState(() {
      points += add;
      xp += add;
      if (xp >= xpToNext) {
        level += 1;
        xp = xp - xpToNext;
        xpToNext = (xpToNext * 1.2).round();
      }
    });
  }
}

// -------------------------------------------------------
// ------------------- HEADER PILLS ----------------------
// -------------------------------------------------------

class _EnergyPill extends StatelessWidget {
  final int energy;
  const _EnergyPill({required this.energy});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt, color: cs.onPrimary, size: 18),
          const SizedBox(width: 6),
          Text(
            '$energy',
            style: GoogleFonts.lato(
              color: cs.onPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsPill extends StatelessWidget {
  final int points;
  const _PointsPill({required this.points});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(Icons.stars, color: cs.onPrimary, size: 18),
          const SizedBox(width: 6),
          Text(
            '$points pts',
            style: GoogleFonts.lato(
              color: cs.onPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// -------------------- QUEST CHIP ----------------------
// -------------------------------------------------------

class _QuestChip extends StatelessWidget {
  final String text;
  const _QuestChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.alike(
          color: cs.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// --------------------- GAME TILE ----------------------
// -------------------------------------------------------

class _GameTile extends StatefulWidget {
  final String title;
  final Color tileColor;
  final VoidCallback onTap;
  final String? assetPath;
  final IconData? iconData;

  const _GameTile({
    required this.title,
    required this.tileColor,
    required this.onTap,
    this.assetPath,
    this.iconData,
  });

  @override
  State<_GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<_GameTile> {
  double _scale = 1.0;
  void _press(bool down) => setState(() => _scale = down ? 0.97 : 1.0);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      child: InkWell(
        onTapDown: (_) => _press(true),
        onTapCancel: () => _press(false),
        onTapUp: (_) => _press(false),
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: widget.tileColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 64,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _GameVisual(
                    assetPath: widget.assetPath,
                    iconData: widget.iconData,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.title,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  color: cs.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap to play',
                style: GoogleFonts.alike(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// ------------------- GAME VISUAL ----------------------
// -------------------------------------------------------

class _GameVisual extends StatelessWidget {
  final String? assetPath;
  final IconData? iconData;

  const _GameVisual({this.assetPath, this.iconData});

  @override
  Widget build(BuildContext context) {
    const double targetHeight = 56.0;
    final cs = Theme.of(context).colorScheme;

    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        height: targetHeight,
        fit: BoxFit.contain,
        alignment: Alignment.topLeft,
        errorBuilder: (context, error, stackTrace) {
          return Icon(iconData ?? Icons.sports_esports,
              color: cs.onSurface, size: targetHeight);
        },
      );
    }
    return Icon(iconData ?? Icons.sports_esports,
        color: cs.onSurface, size: targetHeight);
  }
}
