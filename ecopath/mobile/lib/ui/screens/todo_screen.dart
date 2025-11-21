// lib/ui/screens/todo_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecopath/core/progress_tracker.dart';

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

  // track total earned today from individual missions (points only)
  int _earnedToday = 0;

  // ----- DAILY CHEST STATE -----
  // Chest can give XP or points
  _ChestType? _chestType;
  int? _chestAmount;
  bool _chestClaimed = false; // once per day

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

      // update global progress + points
      ProgressTracker.instance.completeMission(points: ch.reward);

      // placeholder for notifications
      _pushNotification(
        title: 'Challenge completed!',
        body: 'You earned +${ch.reward} pts: ${ch.title}',
      );
    });
  }

  /// Opens a modal dialog with a closed chest.
  /// When user taps the chest, it opens and reveals a random reward.
  void _openChestDialog() {
    if (_chestClaimed) return; // already opened today

    showDialog(
      context: context,
      barrierDismissible: false, // must use Close button
      builder: (dialogCtx) {
        bool opened = false;
        _ChestType? type;
        int? amount;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // decide what to show depending on opened state
            Widget chestImage;
            String titleText;
            String subtitleText;
            Widget bottomButton;

            if (!opened) {
              chestImage = Image.asset(
                'assets/images/closechest.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              );
              titleText = 'Daily Chest';
              subtitleText = 'Tap the chest to see your reward!';
              bottomButton = const SizedBox.shrink();
            } else {
              // opened: show type-specific chest
              if (type == _ChestType.xp) {
                chestImage = Image.asset(
                  'assets/images/xpchest.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                );
                subtitleText = 'You got $amount XP!';
              } else {
                chestImage = Image.asset(
                  'assets/images/pointchest.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                );
                subtitleText = 'You got $amount points!';
              }
              titleText = 'Nice reward!';

              bottomButton = Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kInk,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleText,
                      style: GoogleFonts.lato(
                        color: kInk,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        if (opened) return;

                        // generate the reward
                        final rand = Random();
                        final bool giveXp = rand.nextBool();
                        int generatedAmount;

                        if (giveXp) {
                          // XP: 5–30
                          generatedAmount = 5 + rand.nextInt(26);
                          type = _ChestType.xp;
                          // update global XP
                          ProgressTracker.instance.addXp(generatedAmount);
                        } else {
                          // Points: 1–10
                          generatedAmount = 1 + rand.nextInt(10);
                          type = _ChestType.points;
                          // update today + global points
                          _earnedToday += generatedAmount;
                          ProgressTracker.instance.addPoints(generatedAmount);
                        }

                        amount = generatedAmount;

                        // Update main state
                        setState(() {
                          _chestClaimed = true;
                          _chestType = type;
                          _chestAmount = amount;
                        });

                        // send notification
                        _pushNotification(
                          title: 'Daily Chest opened 🎁',
                          body: type == _ChestType.xp
                              ? 'You received $generatedAmount XP!'
                              : 'You received $generatedAmount points!',
                        );

                        // update dialog state to show opened chest
                        setDialogState(() {
                          opened = true;
                        });
                      },
                      child: chestImage,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitleText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.alike(
                        color: kInk.withOpacity(.9),
                        fontSize: 13,
                      ),
                    ),
                    bottomButton,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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

                    // right side small chest status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: kInk,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            color: kBg,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Daily Chest',
                            style: GoogleFonts.lato(
                              color: kBg,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _chestClaimed ? 'Opened' : 'Ready',
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

              // --- DAILY CHEST SUMMARY BANNER (beneath Today's Progress) ---
              if (_chestClaimed && _chestAmount != null && _chestType != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            _chestType == _ChestType.xp
                                ? 'assets/images/xpchest.png'
                                : 'assets/images/pointchest.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today\'s Chest Reward',
                                style: GoogleFonts.lato(
                                  color: kInk,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _chestType == _ChestType.xp
                                    ? 'You got $_chestAmount XP!'
                                    : 'You got $_chestAmount points!',
                                style: GoogleFonts.alike(
                                  color: kInk.withOpacity(.85),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

              // --- LIST OF CHALLENGES + DAILY CHEST CARD LAST ---
              Expanded(
                child: ListView.separated(
                  itemCount: _challenges.length + 1, // +1 is daily chest card
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
                      // last item = daily chest card
                      return _ChestCard(
                        claimed: _chestClaimed,
                        allDone: _allDone(),
                        onGet: _openChestDialog,
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

enum _ChestType { xp, points }

// ---------------------- SAFE ICON WIDGET ----------------------

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

// ---------------------- DAILY CHEST CARD WIDGET ----------------------

class _ChestCard extends StatelessWidget {
  static const Color kInk = Color(0xFF00221C);
  static const Color kCard = Colors.white;

  final bool claimed;
  final bool allDone;
  final VoidCallback onGet;

  const _ChestCard({
    required this.claimed,
    required this.allDone,
    required this.onGet,
  });

  @override
  Widget build(BuildContext context) {
    final bool canPress = !claimed;

    String statusText;
    if (claimed) {
      statusText = 'Already opened today';
    } else if (allDone) {
      statusText = 'Missions done – grab your chest!';
    } else {
      statusText = 'Free chest once a day.';
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
                Icons.inventory_2_outlined,
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
                  'Daily Chest',
                  style: GoogleFonts.lato(
                    color: kInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Open a free chest for random XP or points.',
                  style: GoogleFonts.alike(
                    color: kInk.withOpacity(.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  statusText,
                  style: GoogleFonts.lato(
                    color: kInk,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 92,
            child: ElevatedButton(
              onPressed: canPress ? onGet : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canPress ? kInk : const Color(0xFFE6ECEA),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: canPress ? 2 : 0,
              ),
              child: Text(
                claimed ? 'Claimed' : 'Get',
                style: GoogleFonts.lato(
                  color:
                      canPress ? Colors.white : kInk.withOpacity(.6),
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
