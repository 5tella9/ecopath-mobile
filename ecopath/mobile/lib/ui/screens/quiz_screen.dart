// lib/ui/screens/quiz_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../util/life_storage.dart';
import 'package:ecopath/core/progress_tracker.dart';
import 'package:provider/provider.dart';
import '../../providers/userProvider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // ===== Game state (per session) =====
  int _streak = 0;
  int _score = 0;
  int _currentIndex = 0;

  // Lives = number of sessions player can start (energy)
  int _lives = 3;

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
    _startNewGameSession(); // handles lives & fetch
  }

  @override
  void dispose() {
    _preTimer?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  // =====================================================
  //                HEART REFILL SYSTEM
  // =====================================================
  Future<void> _restoreLives() async {
    int savedLives = await LifeStorage.loadLives();
    DateTime? lastLost = await LifeStorage.loadLastLostTime();

    int lives = savedLives;

    if (lives < 3 && lastLost != null) {
      final minutes = DateTime.now().difference(lastLost).inMinutes;
      final restored = minutes ~/ 30; // 1 heart per 30 min

      if (restored > 0) {
        lives = (lives + restored).clamp(0, 3);
        await LifeStorage.saveLives(lives);

        // If not full yet, we can keep lastLost as "now"
        if (lives < 3) {
          await LifeStorage.saveLastLostTime(DateTime.now());
        }
      }
    }

    _lives = lives;
  }

  Future<bool> _deductLife() async {
    // called when starting a NEW quiz session (including first)
    if (_lives <= 0) return false;
    _lives -= 1;
    await LifeStorage.saveLives(_lives);
    if (_lives < 3) {
      await LifeStorage.saveLastLostTime(DateTime.now());
    }
    return true;
  }

  // =====================================================
  //        START A NEW GAME SESSION (1 life)
  // =====================================================
  Future<void> _startNewGameSession() async {
    _preTimer?.cancel();
    _timer?.cancel();

    setState(() {
      _isLoading = true;
      _questions = [];
      _streak = 0;
      _score = 0;
      _currentIndex = 0;
      _preCount = _preStartBegin;
      _isPreCounting = true;
      _timeLeft = _totalTimeSeconds;
      _endDialogShown = false;
    });

    await _restoreLives();
    if (!mounted) return;

    if (_lives <= 0) {
      // no life to start this session
      setState(() => _isLoading = false);
      await _showOutOfLivesDialog();
      if (mounted) Navigator.of(context).pop(); // back to games screen
      return;
    }

    final ok = await _deductLife(); // consume 1 life for this session
    if (!ok) {
      setState(() => _isLoading = false);
      await _showOutOfLivesDialog();
      if (mounted) Navigator.of(context).pop();
      return;
    }

    await _fetchQuiz();
  }

  // =====================================================
  //                   FETCH QUIZ
  // =====================================================
  Future<void> _fetchQuiz() async {
    const apiUrl =
        'https://pos-guitar-pick-his.trycloudflare.com/quiz';
    final user = context.read<UserProvider>().user;

    final payload = {
      "userId": "b2f84c7a-0d8c-4e41-b5e3-52ddf559fa66",
      "carbonFootprint": {
        "electricityKgCO2e": 14.2,
        "gasKgCO2e": 53.9,
        "wasteKgCO2e": 2.8,
        "totalKgCO2e": 70.9
      },
      "household": user?.householdSize,
      "houseType": user?.housingType.toString(),
      "ecoGoal": user?.ecoGoals,
      "gender" : user?.gender,
      "birth_date": user?.birthDate,
      "name" : user?.fullName,
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
            final correctText = q['options']
                .firstWhere((o) => o['id'] == q['correctOptionId'])['text'];

            return {
              'q': q['text'],
              'answers': opts,
              'correct': opts.indexWhere((t) => t == correctText),
              'explanation': q['explanation'],
            };
          }).toList();

          _isLoading = false;
        });

        _startPreCountdown();
      } else {
        throw Exception('HTTP ${res.statusCode}');
      }
    } catch (e) {
      debugPrint("Quiz fetch error: $e");

      setState(() {
        _isLoading = false;
        _quizTitle = "EcoPath Quiz (Offline)";
        _questions = const [
          {
            'q': "Which action reduces household waste the most?",
            'answers': [
              "Use paper plates",
              "Compost food scraps",
              "Double-bag trash",
              "Buy more plastic"
            ],
            'correct': 1,
            'explanation': "Composting food scraps reduces methane emissions."
          }
        ];
      });

      _startPreCountdown();
    }
  }

  // =====================================================
  //                    COUNTDOWN LOGIC
  // =====================================================
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

  // =====================================================
  //                        TIME UP
  // =====================================================
  void _onTimeUp() {
    if (_endDialogShown) return;
    _endDialogShown = true;

    _pauseTimer();
    _showTimeUpDialog();
  }

  // =====================================================
  //                       ANSWERING
  // =====================================================
  void _answer(int index) {
    if (_isPreCounting || _timeLeft <= 0) return;

    final q = _questions[_currentIndex];
    final correct = q['correct'] as int;
    final explanation = q['explanation'] as String?;

    if (index == correct) {
      setState(() {
        _score += 10;
        _streak += 1;
      });
      _showSnack("✅ Correct! ${explanation ?? ''}");
    } else {
      setState(() {
        _streak = 0;
        // ❗ NO life deduction here anymore – lives = sessions only
      });
      _showSnack("❌ Wrong! ${explanation ?? ''}");
    }

    if (_currentIndex >= _questions.length - 1) {
      _timer?.cancel();
      if (!_endDialogShown) {
        _endDialogShown = true;
        _showWinDialog();
      }
    } else {
      setState(() => _currentIndex += 1);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // =====================================================
  //                      DIALOGS
  // =====================================================

  // TIME UP
  Future<void> _showTimeUpDialog() async {
    final cs = Theme.of(context).colorScheme;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: cs.surface,
        title: const Text("Oh no, time’s up!", textAlign: TextAlign.center),
        content: Image.asset('assets/images/losegame.png', width: 160),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            child: const Text("Leave"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            child: const Text("Play Again"),
            onPressed: () async {
              Navigator.of(context).pop();
              await _startNewGameSession();
            },
          ),
        ],
      ),
    );
  }

  // WIN
  Future<void> _showWinDialog() async {
    final cs = Theme.of(context).colorScheme;

    // Capture score at end of session (because Play Again resets _score)
    final int finalScore = _score;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: cs.surface,
        title: const Text("Yay, you made it!", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/wingirl.png', width: 160),
            const SizedBox(height: 12),
            Text(
              "You scored $finalScore points!",
              style: TextStyle(color: cs.onSurface),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            child: const Text("Leave"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            child: const Text("Play Again"),
            onPressed: () async {
              Navigator.of(context).pop();
              await _startNewGameSession();
            },
          ),
        ],
      ),
    );

    // 🎁 After dialog is closed → grant reward for this quiz session
    if (finalScore > 0) {
      ProgressTracker.instance.rewardFromGame(
        points: finalScore,
        gameName: 'Quiz',
      );
    }
  }

  // OUT OF LIVES (no more plays)
  Future<void> _showOutOfLivesDialog() async {
    final cs = Theme.of(context).colorScheme;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: cs.surface,
        title: const Text(
          "Oh no, you used all lives 💔",
          textAlign: TextAlign.center,
        ),
        content: Image.asset('assets/images/heart.png', width: 130),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            child: const Text("Quit"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // Back button during quiz → begging girl
  Future<bool> _confirmLeaveDuringQuiz() async {
    _pauseTimer();
    final cs = Theme.of(context).colorScheme;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: cs.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/quizgirl.png', width: 160),
            const SizedBox(height: 12),
            const Text(
              "Do you want to leave the quiz?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Continue"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Quit"),
          ),
        ],
      ),
    );

    if (result == true) return true;

    _resumeTimer();
    return false;
  }

  // =====================================================
  //                      UI BUILD
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isPreCounting) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(
          child: Text(
            "$_preCount",
            style: TextStyle(
              fontSize: 72,
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];

    return WillPopScope(
      onWillPop: () async {
        final confirm = await _confirmLeaveDuringQuiz();
        if (confirm) Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text(_quizTitle ?? "Quiz"),
          centerTitle: true,
          leading: BackButton(
            onPressed: () async {
              final confirm = await _confirmLeaveDuringQuiz();
              if (confirm) Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timer & Lives
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("⏱ $_timeLeft s",
                      style: TextStyle(color: cs.primary, fontSize: 18)),
                  Text("❤️ $_lives lives",
                      style: TextStyle(color: cs.error, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 24),

              // Question
              Text(
                q['q'],
                style: TextStyle(
                  fontSize: 20,
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),

              // Answers
              Expanded(
                child: ListView.builder(
                  itemCount: q['answers'].length,
                  itemBuilder: (_, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: cs.primaryContainer,
                        ),
                        onPressed: () => _answer(i),
                        child: Text(
                          q['answers'][i],
                          style: TextStyle(
                            fontSize: 16,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      ),
                    );
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
