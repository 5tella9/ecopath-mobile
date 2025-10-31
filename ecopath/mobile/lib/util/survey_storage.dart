// lib/util/survey_storage.dart

import 'package:shared_preferences/shared_preferences.dart';
// This import path assumes your SurveyData class is in 'lib/ui/screens/survey_flow.dart'
// Adjust it if you moved the class.
import '../ui/screens/survey_flow.dart';

class SurveyStorage {
  static const _surveyDataKey = 'survey_data';

  /// Saves the SurveyData object to local storage.
  static Future<void> save(SurveyData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_surveyDataKey, data.toJson());
  }

  /// Loads the SurveyData object from local storage.
  /// Returns null if no data is found.
  static Future<SurveyData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_surveyDataKey);
    if (jsonString != null) {
      return SurveyData.fromJson(jsonString);
    }
    return null;
  }

  /// Deletes the survey data from local storage.
  static Future<void> delete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_surveyDataKey);
  }
}
