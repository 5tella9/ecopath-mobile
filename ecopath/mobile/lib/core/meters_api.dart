import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class MetersApi {
  /// GET /api/smart-meters/{id}/readings?from=YYYY-MM-DD&to=YYYY-MM-DD
  static Future<Map<String, dynamic>> fetchAverageReading({
    required String from, // YYYY-MM-DD
    required String to,   // YYYY-MM-DD
    required String interval
  }) async {
    // First get the electricity meter
    final meterJson = await fetchApiMeter();
    final meter = jsonDecode(meterJson) as Map<String, dynamic>;
    final meterId = meter['id'] as String;
    
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/smart-meters/$meterId/readings'
      '?from=$from&to=$to&interval=$interval',
    );

    final res = await http.get(uri, headers: {'Accept': 'application/json'});

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
  }

  static Future<String> fetchApiMeter() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/smart-meters');
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final result = jsonDecode(res.body) as Map<String, dynamic>;
      final meters = (result['data'] as List).cast<Map<String, dynamic>>();
      final electricityMeters = meters.where((meter) => meter['meterType'] == 'electricity').toList();
      if (electricityMeters.isNotEmpty) {
        return jsonEncode(electricityMeters.first);
      }
      throw Exception('No electricity meters found');
    } else {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
  }
}
