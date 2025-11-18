// lib/ui/screens/trash_sort_game_screen.dart
// ✔ Updated with tilt controls + smooth motion

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';

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

  // Trash storage
  final Random _rand = Random();
  late final List<_TrashItem> _items;
  _TrashItem? _currentItem;

  // Score
  int _points = 0;
  int _xp = 0;
  int _correct = 0;
  int _wrong = 0;

  // Feedback
  int? _feedbackBinIndex;
  bool _feedbackIsCorrect = false;

  // Falling animation
  late AnimationController _fallController;
  late Animation<double> _fallAnimation;
  double _fallDurationMs = 4000;

  // ---- NEW: Tilt Movement ----
  StreamSubscription<AccelerometerEvent>? _accelSub;

  double _trashX = 0;             // Current horizontal offset
  double _velocityX = 0;          // Smoothed horizontal velocity
  double _accelFactor = 0.04;     // Affect on velocity
  double _friction = 0.70;        // Smooth movement

  @override
  void initState() {
    super.initState();
    _energy = widget.initialEnergy;

    // Trash items
    _items = [
      const _TrashItem(_TrashBinType.plastic, 'assets/images/trash/plasticbag.png'),
      const _TrashItem(_TrashBinType.plastic, 'assets/images/trash/plasticbottle.png'),
      const _TrashItem(_TrashBinType.paper, 'assets/images/trash/paper.png'),
      const _TrashItem(_TrashBinType.paper, 'assets/images/trash/parcel.png'),
      const _TrashItem(_TrashBinType.paper, 'assets/images/trash/pizzabox.png'),
      const _TrashItem(_TrashBinType.paper, 'assets/images/trash/milk.png'),
      const _TrashItem(_TrashBinType.metal, 'assets/images/trash/redcan.png'),
      const _TrashItem(_TrashBinType.metal, 'assets/images/trash/greencan.png'),
      const _TrashItem(_TrashBinType.metal, 'assets/images/trash/metal.png'),
      const _TrashItem(_TrashBinType.others, 'assets/images/trash/beer.png'),
      const _TrashItem(_TrashBinType.others, 'assets/images/trash/bottle.png'),
      const _TrashItem(_TrashBinType.others, 'assets/images/trash/lumber.png'),
      const _TrashItem(_TrashBinType.others, 'assets/images/trash/styrofoam.png'),
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

    _fallController.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          mounted &&
          _phase == _GamePhase.playing) {
        _evaluateTrashLanding();
      }
    });

    _fallController.addListener(() {
      if (!mounted) return;
      if (_phase == _GamePhase.playing) {
        _updateTiltPhysics();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _preTimer?.cancel();
    _accelSub?.cancel();
    _fallController.dispose();
    super.dispose();
  }

  void _pickNextItem() {
    _currentItem = _items[_rand.nextInt(_items.length)];
    _trashX = 0;    // reset to center
    _velocityX = 0;
  }

  // ---- Tilt smooth physics ----
  void _startTiltControl() {
    _accelSub?.cancel();
    _accelSub = accelerometerEvents.listen((event) {
      if (_phase != _GamePhase.playing) return;

      // event.x → left/right tilt, low-pass smoothing
      double ax = event.x;

      // Invert and scale for natural movement
      _velocityX += (-ax) * _accelFactor;

      // Apply friction
      _velocityX *= _friction;
    });
  }

  void _updateTiltPhysics() {
    _trashX += _velocityX * 10; // convert velocity to movement

    // Clamp to safe screen range
    _trashX = _trashX.clamp(-120.0, 120.0);
  }

  // ----------------- Start & countdown -----------------
  void _onStartPressed() {
    if (_energy < 5) {
      setState(() => _phase = _GamePhase.energyError);
      return;
    }

    _energy -= 5;

    setState(() {
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
        _startTiltControl();
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
    _accelSub?.cancel();
    setState(() => _phase = _GamePhase.finished);
  }

  void _advanceSpeed() {
    _fallDurationMs = max(1500, _fallDurationMs * 0.94);
  }

  // ---- Evaluate trash when it reaches bottom ----
  void _evaluateTrashLanding() {
    final binSize = 1; // simplified bin width evaluation by ± zones

    // Convert tilt position (-120 to 120) to bin index 0–3
    int binIndex;

    if (_trashX < -60) binIndex = 0;
    else if (_trashX < 0) binIndex = 1;
    else if (_trashX < 60) binIndex = 2;
    else binIndex = 3;

    final binType = [
      _TrashBinType.others,
      _TrashBinType.plastic,
      _TrashBinType.metal,
      _TrashBinType.paper,
    ][binIndex];

    _onBinAutoSelect(binIndex, binType);
  }

  // Auto-triggered when trash reaches bottom
  void _onBinAutoSelect(int index, _TrashBinType type) {
    if (_phase != _GamePhase.playing) return;

    final correct = type == _currentItem!.type;

    setState(() {
      _feedbackBinIndex = index;
      _feedbackIsCorrect = correct;

      if (correct) {
        _points += 10;
        _xp += 10;
        _correct++;
      } else {
        _wrong++;
      }
    });

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
    _fallController.stop();
    _timer?.cancel();
    _accelSub?.pause();
    setState(() => _phase = _GamePhase.paused);
  }

  void _resumeGame() {
    if (_phase != _GamePhase.paused) return;
    setState(() => _phase = _GamePhase.playing);
    _startMainTimer();
    _startFall();
    _accelSub?.resume();
  }

  Future<bool> _confirmQuit() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Quit game?'),
        content: const Text('Do you want to quit the game?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Quit')),
        ],
      ),
    ) ??
        false;
  }

  Future<bool> _handleWillPop() async {
    if (_phase == _GamePhase.intro ||
        _phase == _GamePhase.energyError ||
        _phase == _GamePhase.finished) {
      Navigator.pop(context, {'points': _points, 'energy': _energy});
      return false;
    }

    _fallController.stop();
    _timer?.cancel();
    _accelSub?.pause();

    final quit = await _confirmQuit();
    if (quit) {
      Navigator.pop(context, {'points': _points, 'energy': _energy});
      return false;
    } else {
      if (_phase == _GamePhase.playing) {
        _startMainTimer();
        _startFall();
        _accelSub?.resume();
      }
      return false;
    }
  }

  void _exitToGames() {
    Navigator.pop(context, {'points': _points, 'energy': _energy});
  }

  void _playAgain() {
    if (_energy < 5) {
      setState(() => _phase = _GamePhase.energyError);
      return;
    }
    _onStartPressed();
  }

  // ---------------- UI BUILD ----------------
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
            Positioned.fill(
              child: Image.asset('assets/images/sortbg.png', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.04)),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _topChip(icon: Icons.timer_outlined, text: '$_timeLeft s', color: timerColor),
                      const SizedBox(width: 8),
                      _topChip(icon: Icons.bolt, text: '$_energy', color: Colors.amber),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.pause),
                        onPressed: _phase == _GamePhase.playing ? _pauseGame : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () async {
                          _timer?.cancel();
                          _fallController.stop();
                          final quit = await _confirmQuit();
                          if (quit && mounted) {
                            _exitToGames();
                          } else if (mounted && _phase == _GamePhase.playing) {
                            _startMainTimer();
                            _startFall();
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text('Tilt phone to sort!', style: GoogleFonts.alike(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 8),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (_, constraints) {
                        if (_currentItem == null) return const SizedBox.shrink();

                        const double size = 130;
                        final double top = (constraints.maxHeight - size) * _fallAnimation.value;
                        final double left = (constraints.maxWidth - size) / 2 + _trashX;

                        return Stack(
                          children: [
                            Positioned(
                              top: top,
                              left: left,
                              child: SizedBox(
                                width: size,
                                height: size,
                                child: Image.asset(_currentItem!.assetPath),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  SizedBox(
                    height: 190,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBin(index: 0, assetPath: 'assets/images/othersb.png'),
                        _buildBin(index: 1, assetPath: 'assets/images/plasticb.png', yOffset: -6),
                        _buildBin(index: 2, assetPath: 'assets/images/canb.png'),
                        _buildBin(index: 3, assetPath: 'assets/images/paperb.png'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _scoreChip(icon: Icons.check_circle, label: 'Correct', value: _correct, color: Colors.green),
                        _scoreChip(icon: Icons.cancel, label: 'Wrong', value: _wrong, color: Colors.redAccent),
                        _scoreChip(icon: Icons.star, label: 'Points', value: _points, color: cs.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),

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

  // ---------------- SMALL HELPERS ----------------

  Widget _topChip({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _scoreChip({required IconData icon, required String label, required int value, required Color color}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text('$label: $value', style: GoogleFonts.lato(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }

  Widget _buildBin({required int index, required String assetPath, double yOffset = 0}) {
    final bool showFeedback = _feedbackBinIndex == index;
    final Color feedbackColor = _feedbackIsCorrect ? Colors.blue : Colors.red;
    final String feedbackText = _feedbackIsCorrect ? 'O' : 'X';

    return Expanded(
      child: SizedBox(
        height: 180,
        child: Transform.translate(
          offset: Offset(0, yOffset),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Image.asset(assetPath, height: 150, fit: BoxFit.contain),
              if (showFeedback)
                Positioned(
                  top: -12,
                  child: Text(feedbackText, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: feedbackColor)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- overlays identical to your original ---

  Widget _buildIntroOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('How to Play: Tilt Sorting', style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text(
                  'Tilt your phone left/right to guide the falling trash.\n'
                      'When it reaches the bottom, it automatically sorts into a bin.\n\n'
                      '• Bin 1: others (glass, foam, vinyl, wood)\n'
                      '• Bin 2: plastic\n'
                      '• Bin 3: metal\n'
                      '• Bin 4: paper\n',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.alike(fontSize: 14),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, {'points': 0, 'energy': _energy}),
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
              child: Text(
                showGo ? 'GO!' : '$_preCount',
                key: ValueKey(showGo ? 'go' : '$_preCount'),
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Tilt to play!', style: TextStyle(fontSize: 22, color: Colors.white70)),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled, size: 60, color: Colors.blueGrey),
              const SizedBox(height: 8),
              const Text('Game Paused', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: _resumeGame, child: const Text('Continue'))),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton(onPressed: _exitToGames, child: const Text('Quit'))),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Game Over!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Nice work!', style: GoogleFonts.alike(fontSize: 16)),
              const SizedBox(height: 12),
              Text('Points: $_points\nXP: $_xp',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: _exitToGames, child: const Text('Exit'))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(onPressed: _playAgain, child: const Text('Play Again'))),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.battery_alert, size: 60, color: Colors.redAccent),
              const SizedBox(height: 8),
              const Text('Not Enough Energy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const Text('Please wait for your energy to refill.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _exitToGames, child: const Text('Quit')),
            ],
          ),
        ),
      ),
    );
  }
}
