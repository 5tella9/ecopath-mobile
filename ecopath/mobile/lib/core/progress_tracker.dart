// lib/core/progress_tracker.dart
import 'dart:math';
import 'package:flutter/foundation.dart';

class ProgressTracker extends ChangeNotifier {
  ProgressTracker._internal();
  static final ProgressTracker instance = ProgressTracker._internal();

  // -------- POINTS / MISSIONS --------
  int _totalPoints = 0;
  int _progressDone = 0; // used in profile_screen

  int get totalPoints => _totalPoints;
  int get progressDone => _progressDone;

  // -------- LEVEL / XP --------
  int _level = 1;
  int _currentXp = 0;
  int _xpToNext = 100;

  int get level => _level;
  int get currentXp => _currentXp;
  int get xpToNext => _xpToNext;

  // -------- ENERGY --------
  static const int maxEnergy = 25;
  int _energy = maxEnergy;
  DateTime? _lastEnergyUpdate;

  int get energy {
    _recalculateEnergy();
    return _energy;
  }

  /// Time until the next +1 energy (null = already full).
  Duration? get timeToNextEnergy {
    _recalculateEnergy();
    if (_energy >= maxEnergy) return null;
    if (_lastEnergyUpdate == null) {
      return const Duration(minutes: 30);
    }
    final next = _lastEnergyUpdate!.add(const Duration(minutes: 30));
    final now = DateTime.now();
    if (now.isAfter(next)) return Duration.zero;
    return next.difference(now);
  }

  void _recalculateEnergy() {
    if (_lastEnergyUpdate == null) return;
    if (_energy >= maxEnergy) return;

    final now = DateTime.now();
    if (!now.isAfter(_lastEnergyUpdate!)) return;

    final diffMinutes = now.difference(_lastEnergyUpdate!).inMinutes;
    if (diffMinutes < 30) return;

    final gained = diffMinutes ~/ 30;
    if (gained <= 0) return;

    _energy = min(maxEnergy, _energy + gained);
    _lastEnergyUpdate =
        _lastEnergyUpdate!.add(Duration(minutes: gained * 30));
  }

  /// Spend some energy. Clamped to 0. Also updates the base timestamp for regen.
  void spendEnergy(int amount) {
    if (amount <= 0) return;
    _recalculateEnergy();
    _energy = max(0, _energy - amount);
    _lastEnergyUpdate = DateTime.now();
    notifyListeners();
  }

  // -------- XP / POINTS API --------
  void addPoints(int amount) {
    if (amount <= 0) return;
    _totalPoints += amount;
    notifyListeners();
  }

  void addXp(int amount) {
    if (amount <= 0) return;
    _currentXp += amount;

    while (_currentXp >= _xpToNext) {
      _currentXp -= _xpToNext;
      _level += 1;
      _xpToNext = max(_xpToNext + 20, (_xpToNext * 1.2).round());
    }
    notifyListeners();
  }

  /// Convenience for rewards where points == xp.
  void addPointsAndXp(int amount) {
    if (amount <= 0) return;
    _totalPoints += amount;
    _currentXp += amount;

    while (_currentXp >= _xpToNext) {
      _currentXp -= _xpToNext;
      _level += 1;
      _xpToNext = max(_xpToNext + 20, (_xpToNext * 1.2).round());
    }
    notifyListeners();
  }

  /// Used by Daily Challenges (todo_screen.dart)
  void completeMission({required int points}) {
    _progressDone += 1;
    addPoints(points);
  }

  // -------- RANK (for Dashboard / Games / Community) --------
  int _rank = 9;
  int get rank => _rank;

  void setRank(int value) {
    if (value <= 0) return;
    _rank = value;
    notifyListeners();
  }
}
