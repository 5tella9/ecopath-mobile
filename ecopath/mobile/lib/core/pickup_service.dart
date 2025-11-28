import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ecopath/models/pickup_request.dart';
import 'package:ecopath/core/api_config.dart';

class PickupService {
  static final PickupService _instance = PickupService._internal();
  final String _baseUrl = ApiConfig.baseUrl;

  factory PickupService() {
    return _instance;
  }

  PickupService._internal();

  Future<Map<String, dynamic>> submitPickupRequest({
    required String location,
    required File imageFile,
    required String notes,
  }) async {
    try {
      // Parse the location string (assuming format: "HouseNumber Street, City PostalCode")
      final locationParts = _parseLocation(location);
      
      // Read image file and convert to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Create pickup request
      final pickupRequest = PickupRequest(
        location: Location(
          houseNumber: locationParts['houseNumber'] ?? '',
          street: locationParts['street'] ?? '',
          city: locationParts['city'] ?? '',
          postalCode: locationParts['postalCode'] ?? '',
        ),
        image: base64Image,
        timestamp: DateTime.now().toUtc().toIso8601String(),
        notes: notes,
      );

      // Make POST request
      final response = await http.post(
        Uri.parse('$_baseUrl/api/pickup-requests'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pickupRequest.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Failed to submit request: ${response.statusCode} - ${response.body}'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Map<String, String> _parseLocation(String location) {
    // Try to parse location string in format "HouseNumber Street, City PostalCode"
    try {
      final parts = location.split(',');
      if (parts.length < 2) {
        final addressParts = location.trim().split(' ');
        if (addressParts.length >= 4) {
          // Try to parse "HouseNumber Street City PostalCode"
          final postalCode = addressParts.last;
          final city = addressParts[addressParts.length - 2];
          final street = addressParts.sublist(1, addressParts.length - 2).join(' ');
          final houseNumber = addressParts[0];
          
          return {
            'houseNumber': houseNumber,
            'street': street,
            'city': city,
            'postalCode': postalCode,
          };
        }
        return {};
      }

      final addressPart = parts[0].trim();
      final cityPart = parts[1].trim();

      // Split address into house number and street
      final addressParts = addressPart.split(' ');
      if (addressParts.length < 2) return {};
      
      final houseNumber = addressParts[0];
      final street = addressParts.sublist(1).join(' ');

      // Split city part into city and postal code
      final cityParts = cityPart.split(' ');
      if (cityParts.length < 2) return {};
      
      final city = cityParts.sublist(0, cityParts.length - 1).join(' ');
      final postalCode = cityParts.last;

      return {
        'houseNumber': houseNumber,
        'street': street,
        'city': city,
        'postalCode': postalCode,
      };
    } catch (e) {
      return {};
    }
  }
}
