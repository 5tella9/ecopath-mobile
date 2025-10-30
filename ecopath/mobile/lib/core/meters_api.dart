import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class MetersApi {
  /// GET /api/smart-meters/{id}/readings?from=YYYY-MM-DD&to=YYYY-MM-DD
  static Future<Map<String, dynamic>> fetchAverageReading({
    required String smartMeterId,
    required String from, // YYYY-MM-DD
    required String to,   // YYYY-MM-DD
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/smart-meters/$smartMeterId/readings'
      '?from=$from&to=$to',
    );

    final res = await http.get(uri, headers: {'Accept': 'application/json'});

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
  }
}
