// lib/ui/screens/quiz_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../util/survey_storage.dart';

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
  static const int _preStartBegin = 3;
  int _preCount = _preStartBegin;
  bool _isPreCounting = true;
  Timer? _preTimer;

  // ===== Quiz-wide timer =====
  static const int _totalTimeSeconds = 60;
  late int _timeLeft = _totalTimeSeconds;
  Timer? _timer;
  bool _endDialogShown = false;

  // ===== Dynamic quiz data =====
  bool _isLoading = true;
  List<Map<String, dynamic>> _questions = [];
  String? _quizTitle;

  @override
  void initState() {
    super.initState();
    _fetchQuiz();
  }

  @override
  void dispose() {
    _preTimer?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  // ---------- Fetch quiz from backend ----------
  Future<void> _fetchQuiz() async {
    const apiUrl = 'https://almost-enhancements-phys-doe.trycloudflare.com/quiz';
    final surveyData = await SurveyStorage.load();

    final payload = {
      "userId": "b2f84c7a-0d8c-4e41-b5e3-52ddf559fa66",
      "from_date": "2025-01-01",
      "to_date": "2025-01-31",
      "carbonFootprint": {
        "electricityKgCO2e": 14.2,
        "gasKgCO2e": 53.9,
        "wasteKgCO2e": 2.8,
        "totalKgCO2e": 70.9
      },
      "household": surveyData?.livingWith,
      "houseType": surveyData?.houseType,
      "ecoGoal": surveyData?.ecoGoals.toList(),
    };

    try {
      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rawQ = data['questions'] as List;
        setState(() {
          _quizTitle = data['title'] ?? 'EcoPath Quiz';
          _questions = rawQ.map((q) {
            final opts = (q['options'] as List)
                .map((o) => o['text'].toString())
                .toList();
            return {
              'q': q['text'],
              'answers': opts,
              'correct': opts.indexWhere((t) =>
                  t ==
                  (q['options']
                      .firstWhere((o) => o['id'] == q['correctOptionId'])['text'])),
              'explanation': q['explanation']
            };
          }).toList();
          _isLoading = false;
        });
        _startPreCountdown();
      } else {
        throw Exception('HTTP ${res.statusCode}');
      }
    } catch (e) {
      debugPrint("Quiz fetch failed: $e");
      setState(() {
        _isLoading = false;
        _quizTitle = 'EcoPath Quiz (Offline)';
        _questions = const [
          {
            'q': 'Which action reduces household waste the most?',
            'answers': [
              'Use paper plates',
              'Compost food scraps',
              'Double-bag trash',
              'Buy more plastic'
            ],
            'correct': 1,
            'explanation': 'Composting food waste prevents methane emissions.'
          }
        ];
      });
      _startPreCountdown();
    }
  }

  // ---------- Pre-start countdown ----------
  void _startPreCountdown() {
    _preTimer?.cancel();
    setState(() {
      _isPreCounting = true;
      _preCount = _preStartBegin;
      _timeLeft = _totalTimeSeconds;
      _endDialogShown = false;
    });

    _preTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_preCount <= 1) {
        t.cancel();
        setState(() => _isPreCounting = false);
        _startMainTimer();
      } else {
        setState(() => _preCount -= 1);
      }
    });
  }

  // ---------- Main timer ----------
  void _startMainTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timeLeft <= 0) {
        t.cancel();
        _onTimeUp();
      } else {
        setState(() => _timeLeft -= 1);
      }
    });
  }

  void _pauseTimer() => _timer?.cancel();
  void _resumeTimer() {
    if (!_isPreCounting && _timeLeft > 0) _startMainTimer();
  }

  // ---------- When time runs out ----------
  void _onTimeUp() {
    if (_endDialogShown) return;
    _endDialogShown = true;
    _pauseTimer();
    _showTimeUpDialog();
  }

  // ---------- Answer logic ----------
  void _answer(int index) {
    if (_isPreCounting || _timeLeft <= 0) return;

    final currentQ = _questions[_currentIndex];
    final correct = currentQ['correct'] as int;
    final explanation = currentQ['explanation'] as String?;
    if (index == correct) {
      setState(() {
        _score += 10;
        _streak += 1;
      });
      _showSnack('✅ Correct! ${explanation ?? ''}');
    } else {
      setState(() {
        _streak = 0;
        _lives = (_lives > 0) ? _lives - 1 : 0;
      });
      _showSnack('❌ Wrong! ${explanation ?? ''}');
    }

    if (_currentIndex >= _questions.length - 1) {
      // Completed quiz
      _timer?.cancel();
      if (!_endDialogShown) {
        _endDialogShown = true;
        _showWinDialog();
      }
    } else if (_lives <= 0) {
      // Lose all lives mid-quiz
      _timer?.cancel();
      if (!_endDialogShown) {
        _endDialogShown = true;
        _showLoseDialog();
      }
    } else {
      setState(() => _currentIndex += 1);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  // ---------- Dialogs ----------
  Future<void> _showTimeUpDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _ResultDialog(
          imagePath: 'assets/images/losegame.png',
          title: "Oh no, time's up ⏰",
          subtitle: "Would you like to play again?",
          score: _score,
          streak: _streak,
          lives: _lives,
          onLeave: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          onPlayAgain: _handlePlayAgain,
        );
      },
    );
  }

  Future<void> _showLoseDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _ResultDialog(
          imagePath: 'assets/images/losegame.png',
          title: "Game Over 💔",
          subtitle: "Would you like to try again?",
          score: _score,
          streak: _streak,
          lives: _lives,
          onLeave: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          onPlayAgain: _handlePlayAgain,
        );
      },
    );
  }

  Future<void> _showWinDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _ResultDialog(
          imagePath: 'assets/images/wingirl.png',
          title: "Yay, you made it! 🎉",
          subtitle: "You’ve completed the quiz!",
          score: _score,
          streak: _streak,
          lives: _lives,
          onLeave: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          onPlayAgain: _handlePlayAgain,
        );
      },
    );
  }

  // When all lives used
  Future<void> _showNoLivesDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/heart.png', height: 120),
              const SizedBox(height: 12),
              const Text(
                "💔 Oh no, you used all lives!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Quit'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _confirmLeaveDuringQuiz() async {
    _pauseTimer();
    final quit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/quizgirl.png', height: 140),
              const SizedBox(height: 12),
              const Text(
                'Do you want to leave the quiz?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Continue'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Quit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (quit == true) return true;
    _resumeTimer();
    return false;
  }

  // ---------- Restart logic with life deduction ----------
  void _handlePlayAgain() {
    Navigator.of(context).pop(); // close dialog
    setState(() {
      _lives -= 1;
    });

    if (_lives <= 0) {
      _showNoLivesDialog();
      return;
    }

    _restartNewQuiz();
  }

  void _restartNewQuiz() {
    _preTimer?.cancel();
    _timer?.cancel();
    setState(() {
      _streak = 0;
      _score = 0;
      _currentIndex = 0;
      _isLoading = true;
    });
    _fetchQuiz();
  }

  String _formatTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = _questions[_currentIndex];
    final answers = (q['answers'] as List<String>);
    final bool danger = _timeLeft <= 10;
    final Color timerColor = danger ? Colors.red : const Color(0xFF00221C);

    return WillPopScope(
      onWillPop: () async {
        if (_isPreCounting) return true;
        final quit = await _confirmLeaveDuringQuiz();
        if (quit) Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_quizTitle ?? 'EcoPath Quiz'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                              color: timerColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RewardStat(icon: Icons.local_fire_department, text: 'Streak: $_streak×'),
                      _RewardStat(icon: Icons.favorite, text: 'Lives: $_lives'),
                      _RewardStat(icon: Icons.star, text: 'Score: $_score'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Question ${_currentIndex + 1}/${_questions.length}',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                          Text(q['q'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Get ready…',
                          style: TextStyle(fontSize: 18, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------- Reusable Result Dialog ----------
class _ResultDialog extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final int score;
  final int streak;
  final int lives;
  final VoidCallback onLeave;
  final VoidCallback onPlayAgain;

  const _ResultDialog({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.score,
    required this.streak,
    required this.lives,
    required this.onLeave,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, height: 140),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('Score: $score • Streak: $streak • Lives: $lives',
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: onLeave, child: const Text('Leave'))),
              const SizedBox(width: 10),
              Expanded(
                  child:
                      ElevatedButton(onPressed: onPlayAgain, child: const Text('Play again'))),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------- Reward stat badge ----------
class _RewardStat extends StatelessWidget {
  final IconData icon;
  final String text;
  const _RewardStat({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
