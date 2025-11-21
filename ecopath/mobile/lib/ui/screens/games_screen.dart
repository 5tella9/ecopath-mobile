// lib/ui/screens/games_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecopath/core/progress_tracker.dart';

import 'scantrash_screen.dart';
import 'quiz_screen.dart';
import 'todo_screen.dart';
import 'community_screen.dart';
import 'trash_sort_game_screen.dart';
import 'recycle_screen.dart';

import 'package:ecopath/l10n/app_localizations.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final tracker = ProgressTracker.instance;

    final points = tracker.totalPoints;
    final energy = tracker.energy;
    final level = tracker.level;
    final xp = tracker.currentXp;
    final xpToNext = tracker.xpToNext;
    final progress =
        xpToNext == 0 ? 0.0 : (xp / xpToNext).clamp(0.0, 1.0);
    final nextEnergy = tracker.timeToNextEnergy;

    // Distinct colors
    const Color quizColor = Color(0xFFC8F7DC);
    const Color scanColor = Color(0xFFCCE5FF);
    const Color recycleColor = Color(0xFFFFF4C2);
    const Color dailyColor = Color(0xFFE6D6FF);
    const Color communityColor = Color(0xFFFFE0CC);
    const Color sortColor = Color(0xFFFFD6E8);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- HEADER ----------
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.gamesTitle, // ← LOCALIZED
                      style: GoogleFonts.lato(
                        color: cs.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _EnergyPill(
                          energy: energy,
                          label: nextEnergy == null
                              ? 'Full'
                              : '+1 in ${_formatDuration(nextEnergy)}',
                          showLabel: nextEnergy != null,
                        ),
                        const SizedBox(width: 8),
                        _PointsPill(
                          points: points,
                          label: l10n.pointsSuffix, // ← LOCALIZED SUFFIX
                        ),
                      ],
                    ),
                  ),
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
                      '${l10n.levelPrefix} $level', // ← LOCALIZED ("Level")
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
                      title: l10n.gameQuiz,
                      tileColor: quizColor,
                      assetPath: 'assets/images/quiz.png',
                      onTap: _openQuiz,
                    ),
                    _GameTile(
                      title: l10n.gameScanTrash,
                      tileColor: scanColor,
                      assetPath: 'assets/images/scantrash.png',
                      onTap: _openScan,
                    ),
                    _GameTile(
                      title: l10n.gameRecycle,
                      tileColor: recycleColor,
                      assetPath: 'assets/images/recycletrash.png',
                      onTap: _openRecycle,
                    ),
                    _GameTile(
                      title: l10n.gameDailyChallenge,
                      tileColor: dailyColor,
                      assetPath: 'assets/images/todolist.png',
                      onTap: _openTodo,
                    ),
                    _GameTile(
                      title: l10n.gameCommunity,
                      tileColor: communityColor,
                      assetPath: 'assets/images/star.png',
                      onTap: _openCommunity,
                    ),
                    _GameTile(
                      title: l10n.gameTrashSorting,
                      tileColor: sortColor,
                      assetPath: 'assets/images/falltrash.png',
                      onTap: _openTrashSortGame,
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

  // ---------- ENERGY DIALOG ----------
  Future<void> _showEnergyDialog() async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.energyDialogTitle),
        content: Text(l10n.energyDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          )
        ],
      ),
    );
  }

  // ---------- NAVIGATION ----------
  Future<void> _openQuiz() async {
    final tracker = ProgressTracker.instance;
    if (tracker.energy <= 0) {
      await _showEnergyDialog();
      return;
    }
    tracker.spendEnergy(1);
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );
    setState(() {});
  }

  Future<void> _openScan() async {
    final tracker = ProgressTracker.instance;
    if (tracker.energy <= 0) {
      await _showEnergyDialog();
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScanTrashScreen()),
    );
    setState(() {});
  }

  Future<void> _openRecycle() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RecycleScreen()),
    );
    setState(() {});
  }

  Future<void> _openTodo() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TodoScreen()),
    );
    setState(() {});
  }

  Future<void> _openCommunity() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CommunityScreen()),
    );
    ProgressTracker.instance.addPointsAndXp(5);
    setState(() {});
  }

  Future<void> _openTrashSortGame() async {
    final tracker = ProgressTracker.instance;
    if (tracker.energy <= 0) {
      await _showEnergyDialog();
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            TrashSortGameScreen(initialEnergy: tracker.energy),
      ),
    );
    setState(() {});
  }
}

// =====================================================
// ===================== PILLS =========================
// =====================================================

class _EnergyPill extends StatelessWidget {
  final int energy;
  final String label;
  final bool showLabel;

  const _EnergyPill({
    required this.energy,
    required this.label,
    this.showLabel = true,
  });

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, color: cs.onPrimary, size: 18),
          const SizedBox(width: 6),
          Text(
            '$energy/${ProgressTracker.maxEnergy}',
            style: GoogleFonts.lato(
              color: cs.onPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.alike(
                color: cs.onPrimary.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PointsPill extends StatelessWidget {
  final int points;
  final String label;

  const _PointsPill({required this.points, required this.label});

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars, color: cs.onPrimary, size: 18),
          const SizedBox(width: 6),
          Text(
            '$points $label',
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

// =====================================================
// ===================== GAME TILE =====================
// =====================================================

class _GameTile extends StatelessWidget {
  final String title;
  final Color tileColor;
  final String? assetPath;
  final IconData? iconData;
  final VoidCallback onTap;

  const _GameTile({
    required this.title,
    required this.tileColor,
    this.assetPath,
    this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: GoogleFonts.lato(
                  color: cs.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: assetPath != null
                  ? Image.asset(
                      assetPath!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      iconData ?? Icons.videogame_asset,
                      size: 48,
                      color: cs.onSurface.withOpacity(0.8),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
