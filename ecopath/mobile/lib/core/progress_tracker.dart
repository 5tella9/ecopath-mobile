// lib/core/progress_tracker.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:ecopath/ui/screens/notifications_screen.dart';

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

    final prevEnergy = _energy;
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

    // 🔔 Energy became full
    if (prevEnergy < maxEnergy && _energy == maxEnergy) {
      NotificationCenter.I.pushEnergyFull(maxEnergy);
    }
  }

  /// Spend some energy. Clamped to 0. Also updates the base timestamp for regen.
  void spendEnergy(int amount) {
    if (amount <= 0) return;
    _recalculateEnergy();
    _energy = max(0, _energy - amount);
    _lastEnergyUpdate = DateTime.now();
    notifyListeners();
  }

  // -------- XP / POINTS API (generic) --------

  /// Add points (used when user earns points).
  /// Negative values are ignored on purpose.
  void addPoints(int amount) {
    if (amount <= 0) return;
    _totalPoints += amount;
    notifyListeners();
  }

  /// Add XP (used when user earns XP not tied to games).
  void addXp(int amount) {
    if (amount <= 0) return;
    _currentXp += amount;

    while (_currentXp >= _xpToNext) {
      _currentXp -= _xpToNext;
      _level += 1;

      // 🔔 Level up notification (even for non-game XP)
      NotificationCenter.I.pushLevelUp(newLevel: _level);

      _xpToNext = max(_xpToNext + 20, (_xpToNext * 1.2).round());
    }
    notifyListeners();
  }

  /// Convenience for rewards where points == xp (non-game).
  void addPointsAndXp(int amount) {
    if (amount <= 0) return;
    _totalPoints += amount;
    _currentXp += amount;

    while (_currentXp >= _xpToNext) {
      _currentXp -= _xpToNext;
      _level += 1;

      // 🔔 Level up notification
      NotificationCenter.I.pushLevelUp(newLevel: _level);

      _xpToNext = max(_xpToNext + 20, (_xpToNext * 1.2).round());
    }
    notifyListeners();
  }

  /// Spend points (for shop purchases, etc.).
  /// Returns true if the user had enough points and the spend succeeded.
  bool spendPoints(int amount) {
    if (amount <= 0) return false;
    if (amount > _totalPoints) return false;

    _totalPoints -= amount;
    notifyListeners();
    return true;
  }

  /// 🎮 GAME REWARD:
  /// Use this when a *game* grants points (quiz, scan trash, recycle, etc.)
  /// so that we can show game notification + handle XP + level-up.
  void rewardFromGame({
    required int points,
    required String gameName,
  }) {
    if (points <= 0) return;

    _totalPoints += points;
    _currentXp += points;

    // 🔔 Game points notification
    NotificationCenter.I.pushGamePoints(
      gameName: gameName,
      points: points,
    );

    // Level up loop with notifications
    while (_currentXp >= _xpToNext) {
      _currentXp -= _xpToNext;
      _level += 1;

      NotificationCenter.I.pushLevelUp(newLevel: _level);

      _xpToNext = max(_xpToNext + 20, (_xpToNext * 1.2).round());
    }

    notifyListeners();
  }

  /// Used by Daily Challenges (todo_screen.dart)
  void completeMission({required int points}) {
    _progressDone += 1;

    // Treat daily challenges as a "game" source for notifications
    rewardFromGame(points: points, gameName: 'Daily Challenge');
  }

  // -------- RANK (for Dashboard / Games / Community) --------
  int _rank = 9;
  int get rank => _rank;

  void setRank(int value) {
    if (value <= 0) return;
    if (value == _rank) return;

    final old = _rank;
    _rank = value;

    // 🔔 Rank change notification for leaderboard
    NotificationCenter.I.pushRankChanged(
      oldRank: old,
      newRank: _rank,
    );

    notifyListeners();
  }
}
