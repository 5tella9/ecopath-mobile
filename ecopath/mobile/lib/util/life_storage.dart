// lib/util/life_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class LifeStorage {
  static const _livesKey = "quiz_lives";
  static const _lastLostKey = "last_life_lost_time";

  static Future<int> loadLives() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_livesKey) ?? 3;
  }

  static Future<void> saveLives(int lives) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_livesKey, lives);
  }

  static Future<DateTime?> loadLastLostTime() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_lastLostKey);
    if (ts == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ts);
  }

  static Future<void> saveLastLostTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastLostKey, time.millisecondsSinceEpoch);
  }
}
