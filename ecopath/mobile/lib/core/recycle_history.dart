// lib/core/recycle_history.dart
import 'package:flutter/foundation.dart';

/// Simple in-memory storage for daily recycling points.
/// (If you later want persistence, you can back this with SharedPreferences or your backend.)
class RecycleHistory {
  RecycleHistory._();
  static final RecycleHistory instance = RecycleHistory._();

  // Keyed by "pure" date (year, month, day)
  final Map<DateTime, int> _dailyPoints = {};

  /// Add [points] for [date]. If there are already points that day, they are added.
  void addRecycle(DateTime date, int points) {
    final day = DateTime(date.year, date.month, date.day);
    _dailyPoints[day] = (_dailyPoints[day] ?? 0) + points;
    debugPrint('RecycleHistory: added $points pts to $day → ${_dailyPoints[day]} pts');
  }

  /// Returns points for the given [date], or null if none.
  int? pointsFor(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return _dailyPoints[day];
  }
}
