// lib/ui/screens/todo_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // --- THEME CONSTANTS (match GamesScreen) ---
  static const Color kInk = Color(0xFF00221C);
  static const Color kBg = Color(0xFFF5F5F5);
  static const Color kCard = Colors.white;

  // track total earned today from individual missions
  int _earnedToday = 0;

  // daily bonus config
  final int _dailyBonus = 30;
  bool _bonusClaimed = false;

  // list of today's missions (placeholder default set)
  late List<_Challenge> _challenges;

  @override
  void initState() {
    super.initState();
    _challenges = [
      _Challenge(
        title: 'Use a tumbler today',
        desc: 'Avoid single-use plastic cup.',
        reward: 15,
      ),
      _Challenge(
        title: 'Lights off 1 hour',
        desc: 'Turn off unused lights tonight.',
        reward: 10,
      ),
      _Challenge(
        title: 'Bring reusable bag',
        desc: 'No extra plastic when you shop.',
        reward: 15,
      ),
      _Challenge(
        title: 'Sort cans & plastic',
        desc: 'Recycle correctly at home.',
        reward: 20,
      ),
    ];
  }

  // ----- HELPERS -----

  int _completedCount() => _challenges.where((c) => c.completed).length;

  bool _allDone() => _completedCount() == _challenges.length;

  void _acceptChallenge(int index) {
    setState(() {
      _challenges[index].accepted = true;
    });
  }

  void _completeChallenge(int index) {
    final ch = _challenges[index];
    if (ch.completed) return;

    setState(() {
      ch.completed = true;
      _earnedToday += ch.reward;

      // placeholder for notifications
      _pushNotification(
        title: 'Challenge completed!',
        body: 'You earned +${ch.reward} pts: ${ch.title}',
      );
    });
  }

  void _claimBonus() {
    if (!_allDone() || _bonusClaimed) return;
    setState(() {
      _bonusClaimed = true;
      _earnedToday += _dailyBonus;

      _pushNotification(
        title: 'Daily Eco Hero 🌿',
        body: 'All missions cleared! Bonus +$_dailyBonus pts awarded.',
      );
    });
  }

  // later you connect this to notification_screen.dart state
  void _pushNotification({required String title, required String body}) {
    debugPrint('[NOTIFICATION] $title :: $body');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title\n$body')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: kInk),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SafeAssetIcon(
              assetPath: 'assets/images/todo.png',
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Daily Challenges',
              style: GoogleFonts.lato(
                color: kInk,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TOP STATS CARD ---
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // left side text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Progress",
                            style: GoogleFonts.lato(
                              color: kInk,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_completedCount()} / ${_challenges.length} completed',
                            style: GoogleFonts.alike(
                              color: kInk.withOpacity(.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '+$_earnedToday',
                                style: GoogleFonts.lato(
                                  color: kInk,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'pts earned today',
                                style: GoogleFonts.alike(
                                  color: kInk.withOpacity(.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // right side bonus badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: kInk,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.stars,
                            color: kBg,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bonus +$_dailyBonus',
                            style: GoogleFonts.lato(
                              color: kBg,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _bonusClaimed
                                ? 'CLAIMED'
                                : _allDone()
                                    ? 'Ready'
                                    : 'Locked',
                            style: GoogleFonts.alike(
                              color: kBg,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Today's Missions",
                style: GoogleFonts.lato(
                  color: kInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // --- LIST OF CHALLENGES + BONUS CARD LAST ---
              Expanded(
                child: ListView.separated(
                  itemCount: _challenges.length + 1, // +1 is bonus card
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    if (i < _challenges.length) {
                      final ch = _challenges[i];
                      return _ChallengeCard(
                        challenge: ch,
                        onAccept: () => _acceptChallenge(i),
                        onComplete: () => _completeChallenge(i),
                      );
                    } else {
                      // last item = daily bonus card
                      return _BonusCard(
                        allDone: _allDone(),
                        claimed: _bonusClaimed,
                        bonus: _dailyBonus,
                        onClaim: _claimBonus,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------- MODEL ----------------------

class _Challenge {
  final String title;
  final String desc;
  final int reward;
  bool accepted;
  bool completed;

  _Challenge({
    required this.title,
    required this.desc,
    required this.reward,
    this.accepted = false,
    this.completed = false,
  });
}

// ---------------------- SAFE ICON WIDGET ----------------------
// this tries to load an asset. if asset can't load, it shows a fallback icon.
// good for debugging missing/transparent PNGs.

class _SafeAssetIcon extends StatelessWidget {
  final String assetPath;
  final double size;

  const _SafeAssetIcon({
    required this.assetPath,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.checklist,
          color: const Color(0xFF00221C),
          size: size,
        );
      },
    );
  }
}

// ---------------------- CHALLENGE CARD WIDGET ----------------------

class _ChallengeCard extends StatelessWidget {
  static const Color kInk = Color(0xFF00221C);
  static const Color kCard = Colors.white;

  final _Challenge challenge;
  final VoidCallback onAccept;
  final VoidCallback onComplete;

  const _ChallengeCard({
    required this.challenge,
    required this.onAccept,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    // button state logic
    String buttonText;
    VoidCallback? buttonAction;
    Color buttonColor;
    Color textColor;

    if (challenge.completed) {
      buttonText = 'Done';
      buttonAction = null;
      buttonColor = const Color(0xFFE6ECEA);
      textColor = kInk.withOpacity(.6);
    } else if (!challenge.accepted) {
      buttonText = 'Accept';
      buttonAction = onAccept;
      buttonColor = kInk;
      textColor = Colors.white;
    } else {
      buttonText = 'Complete';
      buttonAction = onComplete;
      buttonColor = kInk;
      textColor = Colors.white;
    }

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // left icon box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFD8E6BF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_outline,
                color: kInk,
                size: 28,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // middle text block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: GoogleFonts.lato(
                    color: kInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  challenge.desc,
                  style: GoogleFonts.alike(
                    color: kInk.withOpacity(.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.stars,
                      size: 16,
                      color: Color(0xFF71D8C6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${challenge.reward} pts',
                      style: GoogleFonts.lato(
                        color: kInk,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // right button
          SizedBox(
            width: 92,
            child: ElevatedButton(
              onPressed: buttonAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: buttonAction == null ? 0 : 2,
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.lato(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------- BONUS CARD WIDGET ----------------------

class _BonusCard extends StatelessWidget {
  static const Color kInk = Color(0xFF00221C);
  static const Color kCard = Colors.white;

  final bool allDone;
  final bool claimed;
  final int bonus;
  final VoidCallback onClaim;

  const _BonusCard({
    required this.allDone,
    required this.claimed,
    required this.bonus,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    // can we press claim button?
    final bool canClaim = allDone && !claimed;

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // icon side
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFA1D0D8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.emoji_events,
                color: kInk,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // text + button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Bonus',
                  style: GoogleFonts.lato(
                    color: kInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete all missions to earn +$bonus pts.',
                  style: GoogleFonts.alike(
                    color: kInk.withOpacity(.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.stars,
                      size: 16,
                      color: Color(0xFF71D8C6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      claimed
                          ? 'Bonus claimed'
                          : allDone
                              ? 'Ready to claim'
                              : 'Locked',
                      style: GoogleFonts.lato(
                        color: kInk,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 92,
            child: ElevatedButton(
              onPressed: canClaim ? onClaim : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canClaim ? kInk : const Color(0xFFE6ECEA),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: canClaim ? 2 : 0,
              ),
              child: Text(
                claimed
                    ? 'Claimed'
                    : canClaim
                        ? 'Claim'
                        : 'Locked',
                style: GoogleFonts.lato(
                  color: canClaim ? Colors.white : kInk.withOpacity(.6),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
