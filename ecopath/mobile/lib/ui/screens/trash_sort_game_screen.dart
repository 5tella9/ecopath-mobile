// lib/ui/screens/trash_sort_game_screen.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrashSortGameScreen extends StatefulWidget {
  final int initialEnergy;

  const TrashSortGameScreen({super.key, required this.initialEnergy});

  @override
  State<TrashSortGameScreen> createState() => _TrashSortGameScreenState();
}

enum _GamePhase { intro, preCountdown, playing, paused, finished, energyError }

enum _TrashBinType { others, plastic, metal, paper }

class _TrashItem {
  final _TrashBinType type;
  final String assetPath;
  const _TrashItem(this.type, this.assetPath);
}

class _TrashSortGameScreenState extends State<TrashSortGameScreen>
    with SingleTickerProviderStateMixin {
  late int _energy;

  // Game timer
  static const int _totalTime = 60;
  int _timeLeft = _totalTime;
  Timer? _timer;

  // Pre-start 3-2-1
  static const int _preStartBegin = 3;
  int _preCount = _preStartBegin;
  Timer? _preTimer;

  _GamePhase _phase = _GamePhase.intro;

  // Trash items
  final Random _rand = Random();
  late final List<_TrashItem> _items;
  _TrashItem? _currentItem;

  // Score
  int _points = 0;
  int _xp = 0;
  int _correct = 0;
  int _wrong = 0;

  // Bin feedback
  int? _feedbackBinIndex;
  bool _feedbackIsCorrect = false;

  // Falling animation
  late AnimationController _fallController;
  late Animation<double> _fallAnimation;
  double _fallDurationMs = 4000; // slower at start, gets faster

  @override
  void initState() {
    super.initState();
    _energy = widget.initialEnergy;

    _items = [
      // Plastic
      const _TrashItem(
          _TrashBinType.plastic, 'assets/images/trash/plasticbag.png'),
      const _TrashItem(
          _TrashBinType.plastic, 'assets/images/trash/plasticbottle.png'),
      // Paper
      const _TrashItem(_TrashBinType.paper, 'assets/images/trash/paper.png'),
      const _TrashItem(_TrashBinType.paper, 'assets/images/trash/parcel.png'),
      const _TrashItem(
          _TrashBinType.paper, 'assets/images/trash/pizzabox.png'),
      const _TrashItem(_TrashBinType.paper, 'assets/images/trash/milk.png'),
      // Metal
      const _TrashItem(_TrashBinType.metal, 'assets/images/trash/redcan.png'),
      const _TrashItem(
          _TrashBinType.metal, 'assets/images/trash/greencan.png'),
      const _TrashItem(_TrashBinType.metal, 'assets/images/trash/metal.png'),
      // Others
      const _TrashItem(_TrashBinType.others, 'assets/images/trash/beer.png'),
      const _TrashItem(_TrashBinType.others, 'assets/images/trash/bottle.png'),
      const _TrashItem(_TrashBinType.others, 'assets/images/trash/lumber.png'),
      const _TrashItem(
          _TrashBinType.others, 'assets/images/trash/styrofoam.png'),
    ];

    _pickNextItem();

    _fallController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _fallDurationMs.toInt()),
    );
    _fallAnimation = CurvedAnimation(
      parent: _fallController,
      curve: Curves.linear,
    );

    // IMPORTANT: rebuild UI while animating so trash actually moves
    _fallController.addListener(() {
      if (!mounted) return;
      if (_phase == _GamePhase.playing) {
        setState(() {});
      }
    });

    _fallController.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          _phase == _GamePhase.playing &&
          mounted) {
        _onMissedItem();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _preTimer?.cancel();
    _fallController.dispose();
    super.dispose();
  }

  void _pickNextItem() {
    if (_items.isEmpty) return;
    _currentItem = _items[_rand.nextInt(_items.length)];
  }

  // ----------------- Start & countdown -----------------
  void _onStartPressed() {
    if (_energy < 5) {
      setState(() => _phase = _GamePhase.energyError);
      return;
    }
    setState(() {
      _energy -= 5;
      _points = 0;
      _xp = 0;
      _correct = 0;
      _wrong = 0;
      _timeLeft = _totalTime;
      _phase = _GamePhase.preCountdown;
      _preCount = _preStartBegin;
    });
    _startPreCountdown();
  }

  void _startPreCountdown() {
    _preTimer?.cancel();
    _preTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_preCount <= 1) {
        t.cancel();
        setState(() => _phase = _GamePhase.playing);
        _startMainTimer();
        _startFall();
      } else {
        setState(() => _preCount -= 1);
      }
    });
  }

  void _startMainTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timeLeft <= 0) {
        t.cancel();
        _onGameOver();
      } else {
        setState(() => _timeLeft -= 1);
      }
    });
  }

  void _startFall() {
    _fallController.duration = Duration(milliseconds: _fallDurationMs.toInt());
    _fallController.forward(from: 0);
  }

  void _onGameOver() {
    _fallController.stop();
    setState(() => _phase = _GamePhase.finished);
  }

  void _advanceSpeed() {
    _fallDurationMs = max(1500, _fallDurationMs * 0.95);
  }

  void _onMissedItem() {
    if (_phase != _GamePhase.playing) return;
    setState(() => _wrong += 1);
    _advanceSpeed();
    _pickNextItem();
    _startFall();
  }

  // ----------------- Bin tap logic -----------------
  void _onBinTap(int binIndex, _TrashBinType binType) {
    if (_phase != _GamePhase.playing || _currentItem == null) return;

    final bool correct = binType == _currentItem!.type;

    setState(() {
      _feedbackBinIndex = binIndex;
      _feedbackIsCorrect = correct;
      if (correct) {
        _points += 10;
        _xp += 10;
        _correct += 1;
      } else {
        _wrong += 1;
      }
    });

    _fallController.stop();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _feedbackBinIndex = null);
    });

    _advanceSpeed();
    _pickNextItem();
    _startFall();
  }

  // ----------------- Pause / resume / quit -----------------
  void _pauseGame() {
    if (_phase != _GamePhase.playing) return;
    _timer?.cancel();
    _fallController.stop();
    setState(() => _phase = _GamePhase.paused);
  }

  void _resumeGame() {
    if (_phase != _GamePhase.paused) return;
    setState(() => _phase = _GamePhase.playing);
    _startMainTimer();
    _startFall();
  }

  Future<bool> _confirmQuit() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Quit game?'),
            content: const Text(
                'Do you want to quit the trash sorting game and go back?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Quit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _handleWillPop() async {
    if (_phase == _GamePhase.intro ||
        _phase == _GamePhase.energyError ||
        _phase == _GamePhase.finished) {
      Navigator.of(context).pop({'points': _points, 'energy': _energy});
      return false;
    }
    _timer?.cancel();
    _fallController.stop();
    final quit = await _confirmQuit();
    if (quit) {
      Navigator.of(context).pop({'points': _points, 'energy': _energy});
      return false;
    } else {
      if (_phase == _GamePhase.playing) {
        _startMainTimer();
        _startFall();
      }
      return false;
    }
  }

  void _exitToGames() {
    Navigator.of(context).pop({'points': _points, 'energy': _energy});
  }

  void _playAgain() {
    if (_energy < 5) {
      setState(() => _phase = _GamePhase.energyError);
      return;
    }
    _onStartPressed();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool danger = _timeLeft <= 10;
    final Color timerColor = danger ? Colors.red : Colors.black87;

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trash Sorting Game'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/sortbg.png',
                fit: BoxFit.cover,
              ),
            ),

            // Slight overlay for contrast
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.04)),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top row
                  Row(
                    children: [
                      _topChip(
                          icon: Icons.timer_outlined,
                          text: '$_timeLeft s',
                          color: timerColor),
                      const SizedBox(width: 8),
                      _topChip(
                          icon: Icons.bolt,
                          text: '$_energy',
                          color: Colors.amber),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.pause),
                        onPressed: _phase == _GamePhase.playing
                            ? _pauseGame
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () async {
                          _timer?.cancel();
                          _fallController.stop();
                          final quit = await _confirmQuit();
                          if (quit && mounted) {
                            _exitToGames();
                          } else if (mounted &&
                              _phase == _GamePhase.playing) {
                            _startMainTimer();
                            _startFall();
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'Sort this item!',
                    style: GoogleFonts.alike(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Falling trash
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (_currentItem == null) {
                          return const SizedBox.shrink();
                        }
                        const double trashSize = 130;
                        final double topMin = 0;
                        final double topMax =
                            constraints.maxHeight - trashSize;
                        final double top = topMin +
                            _fallAnimation.value * max(0.0, topMax);
                        final double left =
                            (constraints.maxWidth - trashSize) / 2;

                        return Stack(
                          children: [
                            Positioned(
                              top: top,
                              left: left,
                              child: SizedBox(
                                width: trashSize,
                                height: trashSize,
                                child: Image.asset(
                                  _currentItem!.assetPath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Bins row – bigger and same baseline
                  SizedBox(
                    height: 190,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBin(
                          index: 0,
                          assetPath: 'assets/images/othersb.png',
                          type: _TrashBinType.others,
                        ),
                        _buildBin(
                          index: 1,
                          assetPath: 'assets/images/plasticb.png',
                          type: _TrashBinType.plastic,
                          yOffset: -6, // nudge yellow bin up a bit
                        ),
                        _buildBin(
                          index: 2,
                          assetPath: 'assets/images/canb.png',
                          type: _TrashBinType.metal,
                        ),
                        _buildBin(
                          index: 3,
                          assetPath: 'assets/images/paperb.png',
                          type: _TrashBinType.paper,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Score strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _scoreChip(
                          icon: Icons.check_circle,
                          label: 'Correct',
                          value: _correct,
                          color: Colors.green,
                        ),
                        _scoreChip(
                          icon: Icons.cancel,
                          label: 'Wrong',
                          value: _wrong,
                          color: Colors.redAccent,
                        ),
                        _scoreChip(
                          icon: Icons.star,
                          label: 'Points',
                          value: _points,
                          color: cs.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Overlays
            if (_phase == _GamePhase.intro) _buildIntroOverlay(),
            if (_phase == _GamePhase.preCountdown) _buildCountdownOverlay(),
            if (_phase == _GamePhase.paused) _buildPausedOverlay(),
            if (_phase == _GamePhase.finished) _buildFinishedOverlay(),
            if (_phase == _GamePhase.energyError) _buildEnergyErrorOverlay(),
          ],
        ),
      ),
    );
  }

  // ----------------- Small UI helpers -----------------
  Widget _topChip(
      {required IconData icon,
      required String text,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreChip(
      {required IconData icon,
      required String label,
      required int value,
      required Color color}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBin({
    required int index,
    required String assetPath,
    required _TrashBinType type,
    double yOffset = 0,
  }) {
    final bool showFeedback = _feedbackBinIndex == index;
    final Color feedbackColor =
        _feedbackIsCorrect ? Colors.blue : Colors.red;
    final String feedbackText = _feedbackIsCorrect ? 'O' : 'X';

    return Expanded(
      child: GestureDetector(
        onTap: () => _onBinTap(index, type),
        child: SizedBox(
          height: 180,
          child: Transform.translate(
            offset: Offset(0, yOffset),
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  assetPath,
                  height: 150, // big bins, similar size to trash
                  fit: BoxFit.contain,
                ),
                if (showFeedback)
                  Positioned(
                    top: -12,
                    child: Text(
                      feedbackText,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: feedbackColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------- Overlays -----------------
  Widget _buildIntroOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How to Play: Trash Sorting',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You have 60 seconds to sort as many trash items as you can.\n\n'
                  '• 1st bin: glass, styrofoam, vinyl, wood, rubber\n'
                  '• 2nd bin: plastic type\n'
                  '• 3rd bin: can & scrap metal\n'
                  '• 4th bin: paper type\n\n'
                  'Tap the correct bin for each item.\n'
                  'Correct = blue O, Wrong = red X.',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.alike(fontSize: 14),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop({'points': 0, 'energy': _energy});
                        },
                        child: const Text('Quit'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onStartPressed,
                        child: const Text('Start'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    final bool showGo = _preCount <= 1;
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                showGo ? 'Go!' : '$_preCount',
                key: ValueKey<int>(_preCount),
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ready!',
              style: TextStyle(fontSize: 22, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPausedOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled,
                  size: 60, color: Colors.blueGrey),
              const SizedBox(height: 8),
              const Text(
                'Game Paused',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _resumeGame,
                      child: const Text('Continue'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _exitToGames,
                      child: const Text('Quit'),
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

  Widget _buildFinishedOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Game Over!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Nice work sorting trash 💚',
                style: GoogleFonts.alike(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Points: $_points\nXP earned: $_xp',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _exitToGames,
                      child: const Text('Exit'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _playAgain,
                      child: const Text('Play again'),
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

  Widget _buildEnergyErrorOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.battery_alert,
                  size: 60, color: Colors.redAccent),
              const SizedBox(height: 8),
              const Text(
                'Energy is not enough',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your energy is not enough to play.\n'
                'Wait for energy full again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _exitToGames,
                child: const Text('Quit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
