import 'dart:async';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // ===== Game state =====
  int _streak = 0;
  int _lives = 3;
  int _score = 0;
  int _currentIndex = 0;

  // ===== Pre-start 3-2-1 overlay =====
  static const int _preStartBegin = 3; // shows 3,2,1
  int _preCount = _preStartBegin;
  bool _isPreCounting = true;
  Timer? _preTimer;

  // ===== Quiz-wide timer =====
  static const int _totalTimeSeconds = 60; // change if you want longer/shorter quiz
  late int _timeLeft = _totalTimeSeconds;
  Timer? _timer;
  bool _endDialogShown = false;

  // Dummy data
  final List<Map<String, dynamic>> _questions = const [
    {
      'q': 'Which action reduces household waste the most?',
      'answers': [
        'Use paper plates',
        'Compost food scraps',
        'Double-bag trash',
        'Buy more plastic'
      ],
      'correct': 1,
    },
    {
      'q': 'Best time to run washing machine for energy savings?',
      'answers': ['Peak hours', 'Anytime', 'Off-peak hours', 'Midday only'],
      'correct': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startPreCountdown(); // show 3-2-1 immediately when entering screen
  }

  @override
  void dispose() {
    _preTimer?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  // ---------- Pre-start countdown logic ----------
  void _startPreCountdown() {
    _preTimer?.cancel();
    setState(() {
      _isPreCounting = true;
      _preCount = _preStartBegin;
      _timeLeft = _totalTimeSeconds; // reset display; main timer starts after pre-count
      _endDialogShown = false;
    });

    _preTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_preCount <= 1) {
        t.cancel();
        setState(() {
          _isPreCounting = false;
        });
        _startMainTimer();
      } else {
        setState(() {
          _preCount -= 1;
        });
      }
    });
  }

  // ---------- Main quiz timer ----------
  void _startMainTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timeLeft <= 0) {
        t.cancel();
        _onTimeUp();
      } else {
        setState(() {
          _timeLeft -= 1;
        });
      }
    });
  }

  void _onTimeUp() {
    if (_endDialogShown) return;
    _endDialogShown = true;
    _showEndDialog(reason: 'Time\'s up ⏰');
  }

  // ---------- Quiz logic ----------
  void _answer(int index) {
    if (_isPreCounting || _timeLeft <= 0) return; // block taps during pre-count or after time

    final correct = _questions[_currentIndex]['correct'] as int;
    if (index == correct) {
      setState(() {
        _score += 10;
        _streak += 1;
      });
    } else {
      setState(() {
        _streak = 0;
        _lives = (_lives > 0) ? _lives - 1 : 0;
      });
    }

    if (_lives <= 0 || _currentIndex >= _questions.length - 1) {
      _timer?.cancel();
      _showEndDialog();
      return;
    }
    setState(() => _currentIndex += 1);
  }

  void _showEndDialog({String? reason}) {
    if (_endDialogShown) return;
    _endDialogShown = true;

    final bool survived = _lives > 0 && _timeLeft > 0;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(reason ?? (survived ? 'Great job! 🎉' : 'Game over 💔')),
          content: Text('Score: $_score\nStreak: $_streak\nLives left: $_lives'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('Play again'),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _streak = 0;
      _lives = 3;
      _score = 0;
      _currentIndex = 0;
    });
    _startPreCountdown(); // show 3-2-1 again, then start timer
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final answers = (q['answers'] as List<String>);

    final Color normalColor = const Color(0xFF00221C);
    final bool danger = _timeLeft <= 10;
    final Color timerColor = danger ? Colors.red : normalColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoPath Quiz'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ===== Main content =====
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top timer (starts only after 3-2-1 finishes)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(_timeLeft),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: timerColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Gamified header stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RewardStat(
                      icon: Icons.local_fire_department,
                      text: 'Streak: $_streak×',
                    ),
                    _RewardStat(icon: Icons.favorite, text: 'Lives: $_lives'),
                    _RewardStat(icon: Icons.star, text: 'Score: $_score'),
                  ],
                ),
                const SizedBox(height: 16),

                // Question card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Question ${_currentIndex + 1}/${_questions.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          q['q'] as String,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Answers
                Expanded(
                  child: ListView.separated(
                    itemCount: answers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed:
                          (_isPreCounting || _timeLeft <= 0) ? null : () => _answer(i),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          answers[i],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== Pre-start overlay (3-2-1) =====
          if (_isPreCounting)
            Container(
              color: Colors.black.withOpacity(0.35),
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
                        '$_preCount',
                        key: ValueKey<int>(_preCount),
                        style: const TextStyle(
                          fontSize: 96,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get ready…',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small reusable stat widget for gamified header
class _RewardStat extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RewardStat({
    required this.icon,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
