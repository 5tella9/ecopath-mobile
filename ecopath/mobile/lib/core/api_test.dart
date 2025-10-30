import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiTest {
  static Future<void> testSaveUser() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": "Snow Test",
        "email": "snow@example.com",
        "avatarImage": "avatar.png",
        "userProfile": {
          "birthDate": "2001-01-01",
          "gender": "female",
          "housingType": "apartment",
          "householdSize": 2,
          "ecoGoals": ["reduce waste"],
          "location": {
            "houseNumber": "12",
            "street": "Sejong-ro",
            "city": "Seoul",
            "postalCode": "04515"
          }
        }
      }),
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  }
}
