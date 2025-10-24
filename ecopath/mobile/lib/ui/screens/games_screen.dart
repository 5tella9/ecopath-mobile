import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scantrash_screen.dart';
import 'quiz_screen.dart'; 

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  static const Color kInk = Color(0xFF00221C);
  static const Color kBg = Color(0xFFF5F5F5);
  static const Color kCard = Colors.white;

  int points = 480;
  int level = 3;
  int xp = 120;
  int xpToNext = 200;

  TextStyle get _title => GoogleFonts.lato(
      color: kInk, fontSize: 28, fontWeight: FontWeight.w700);

  TextStyle get _label =>
      GoogleFonts.alike(color: kInk, fontSize: 12, fontWeight: FontWeight.w400);

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
              Row(children: [
                Text('Play & Earn', style: _title),
                const Spacer(),
                _PointsPill(points: points),
              ]),
              const SizedBox(height: 12),

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
                    Text('Level $level',
                        style: GoogleFonts.lato(
                            color: kInk,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
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
                    Text('$xp / $xpToNext XP',
                        style: GoogleFonts.alike(
                            color: kInk.withOpacity(.8), fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text('Daily Quests',
                  style: GoogleFonts.lato(
                      color: kInk, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuestChip(text: 'Finish a Quiz • +20'),
                  _QuestChip(text: 'Scan 3 items • +30'),
                  _QuestChip(text: 'Recycle once • +25'),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  padding: const EdgeInsets.only(bottom: 12),
                  children: [
                    _GameTile(
                      title: 'Quiz',
                      rewardText: '+10',
                      assetPath: 'assets/images/quizicon.png',
                      tileColor: const Color(0xFFA1D0D8),
                      onTap: _openQuiz,
                    ),
                    _GameTile(
                      title: 'Scan Trash',
                      rewardText: '+15',
                      assetPath: 'assets/images/scantrash.png',
                      tileColor: const Color(0xFF71D8C6),
                      onTap: _openScan,
                    ),
                    _GameTile(
                      title: 'Recycle',
                      rewardText: '+20',
                      assetPath: 'assets/images/recycletrash.png',
                      tileColor: const Color(0xFFEDDD62),
                      onTap: _openRecycle,
                    ),
                    _GameTile(
                      title: 'Community',
                      rewardText: '+5',
                      assetPath: 'assets/images/star.png',
                      tileColor: const Color(0xFFD8E6BF),
                      onTap: _openCommunity,
                    ),
                    _GameTile(
                      title: 'Eco Marketplace',
                      rewardText: '+5',
                      assetPath: 'assets/images/marketplace.png',
                      tileColor: const Color(0xFFdedaf4),
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

  Future<void> _openQuiz() async {
    // Navigate to the quiz, receive earned points, and add them to your game state.
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );
    if (result != null && result > 0) {
      _gainPoints(result);
    }
  }

  void _openScan() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScanTrashScreen()),
    );
  }

  void _openRecycle() {
    _gainPoints(20);
  }

  void _openCommunity() {
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
          color: Color(0xFF00221C),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _GameTile extends StatefulWidget {
  final String title;
  final String assetPath;
  final String rewardText;
  final Color tileColor;
  final VoidCallback onTap;

  const _GameTile({
    required this.title,
    required this.assetPath,
    required this.rewardText,
    required this.tileColor,
    required this.onTap,
  });

  @override
  State<_GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<_GameTile> {
  double _scale = 1.0;

  void _press(bool down) => setState(() => _scale = down ? 0.97 : 1.0);

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
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.9),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.rewardText,
                    style: GoogleFonts.lato(
                        color: const Color(0xFF00221C),
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        widget.assetPath,
                        width: 92,
                        height: 92,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    style: GoogleFonts.lato(
                      color: const Color(0xFF00221C),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
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
            ],
          ),
        ),
      ),
    );
  }
}
