import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../ui/screens/survey_flow.dart';
import '../models/location.dart';
import '../models/enums.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get hasUser => _user != null;
  bool get hasCompletedSurvey => _user?.ecoGoals != null && _user!.ecoGoals!.isNotEmpty;

  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');

    if (userData != null) {
      _user = User.fromJson(jsonDecode(userData));
      notifyListeners();
    }
  }

  // inside UserProvider
  Future<void> updateFromSurvey(SurveyData data) async {
    if (_user == null) return; // No user yet

    _user = _user!.copyWith(
      birthDate: data.dateOfBirth,
      gender: Gender.values.firstWhere(
            (e) => e.name == data.gender,
        orElse: () => Gender.other, // adjust based on your enum
      ),
      location: Location(
        houseNumber: data.detail, // adjust if needed
        street: data.dong,
        city: data.sigungu,
        postalCode: data.sido,
      ),
      ecoGoals: data.ecoGoals,
      householdSize: int.tryParse(data.livingWith), // if this is a number
      housingType: HousingType.values.firstWhere(
            (e) => e.name == data.houseType,
        orElse: () => HousingType.apartment,
      ),
    );

    notifyListeners();

    // 📌 Save updated user permanently
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(_user!.toJson()));
  }


}
