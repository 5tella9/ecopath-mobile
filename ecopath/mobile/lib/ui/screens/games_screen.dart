import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scantrash_screen.dart';
import 'quiz_screen.dart';
import 'todo_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  static const Color kInk = Color(0xFF00221C);
  static const Color kBg = Color(0xFFF5F5F5);
  static const Color kCard = Colors.white;

  int points = 500; // shown in header
  int energy = 25;  // shown in header
  int level = 3;
  int xp = 140;
  int xpToNext = 200;

  TextStyle get _title => GoogleFonts.lato(
        color: kInk,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      );

  @override
  Widget build(BuildContext context) {
    final progress = (xp / xpToNext).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- HEADER ROW ----------
              Row(
                children: [
                  Text('Play & Earn', style: _title),
                  const Spacer(),

                  // Energy pill
                  _EnergyPill(energy: energy),
                  const SizedBox(width: 8),

                  // Points pill
                  _PointsPill(points: points),
                ],
              ),
              const SizedBox(height: 12),

              // ---------- LEVEL CARD ----------
              Container(
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
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
                        color: kInk,
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
                        backgroundColor: const Color(0xFFE6ECEA),
                        color: const Color(0xFF71D8C6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$xp / $xpToNext XP',
                      style: GoogleFonts.alike(
                        color: kInk.withOpacity(.8),
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
                  color: kInk,
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
                  // A little taller so no overflow
                  childAspectRatio: 1.1,
                  padding: const EdgeInsets.only(bottom: 12),
                  children: [
                    _GameTile(
                      title: 'Quiz',
                      tileColor: const Color(0xFFA1D0D8),
                      assetPath: 'assets/images/quizicon.png',
                      onTap: _openQuiz,
                    ),
                    _GameTile(
                      title: 'Scan Trash',
                      tileColor: const Color(0xFF71D8C6),
                      assetPath: 'assets/images/scantrash.png',
                      onTap: _openScan,
                    ),
                    _GameTile(
                      title: 'Recycle',
                      tileColor: const Color(0xFFEDDD62),
                      assetPath: 'assets/images/recycletrash.png',
                      onTap: _openRecycle,
                    ),
                    _GameTile(
                      // remove the manual \n and let text wrap
                      title: 'Daily Challenge',
                      tileColor: const Color(0xFFC8D9A5),
                      assetPath: 'assets/images/todolist.png',
                      iconData: Icons.checklist, // fallback icon
                      onTap: _openTodo,
                    ),
                    _GameTile(
                      title: 'Community',
                      tileColor: const Color(0xFFD8E6BF),
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

  // ---------- NAVIGATION / STATE UPDATE LOGIC ----------

  Future<void> _openQuiz() async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );
    if (result != null && result > 0) _gainPoints(result);
  }

  void _openScan() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScanTrashScreen()),
    );
  }

  void _openRecycle() => _gainPoints(20);

  void _openTodo() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TodoScreen()),
    );
  }

  void _openCommunity() => _gainPoints(5);

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00221C),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bolt,
            color: Color(0xFFF5F5F5),
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '$energy',
            style: GoogleFonts.lato(
              color: const Color(0xFFF5F5F5),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00221C),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Color(0xFFF5F5F5), size: 18),
          const SizedBox(width: 6),
          Text(
            '$points pts',
            style: GoogleFonts.lato(
              color: const Color(0xFFF5F5F5),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.alike(
          color: const Color(0xFF00221C),
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

  // visual options:
  final String? assetPath; // preferred image asset for this tile
  final IconData? iconData; // fallback if asset fails

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
  void _press(bool down) => setState(() {
        _scale = down ? 0.97 : 1.0;
      });

  @override
  Widget build(BuildContext context) {
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
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- ICON AREA (fixed height block) ----------
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

              // ---------- TITLE ----------
              Text(
                widget.title,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  color: const Color(0xFF00221C),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 2),

              // ---------- SUBTITLE ----------
              Text(
                'Tap to play',
                style: GoogleFonts.alike(
                  color: const Color(0xFF00221C),
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
    const Color ink = Color(0xFF00221C);

    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        height: targetHeight,
        fit: BoxFit.contain,
        alignment: Alignment.topLeft,
        errorBuilder: (context, error, stackTrace) {
          if (iconData != null) {
            return Icon(
              iconData,
              color: ink,
              size: targetHeight,
            );
          }
          return const Icon(
            Icons.sports_esports,
            color: ink,
            size: targetHeight,
          );
        },
      );
    }

    if (iconData != null) {
      return Icon(
        iconData,
        color: ink,
        size: targetHeight,
      );
    }

    return const Icon(
      Icons.sports_esports,
      color: ink,
      size: targetHeight,
    );
  }
}
