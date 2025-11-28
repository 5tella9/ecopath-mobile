class PickupRequest {
  final Location location;
  final String image; // Base64 encoded image string
  final String timestamp;
  final String notes;

  PickupRequest({
    required this.location,
    required this.image,
    required this.timestamp,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
    "location": {
      "houseNumber": "12B",
      "street": "neungdong-ro",
      "city": "Seoul",
      "postalCode": "05000"
    },
        'image': image,
        'timestamp': "2026-01-01 10:00:00.000000 +00:00",
        'notes': notes,
      };
}

class Location {
  final String houseNumber;
  final String street;
  final String city;
  final String postalCode;

  Location({
    required this.houseNumber,
    required this.street,
    required this.city,
    required this.postalCode,
  });

  Map<String, dynamic> toJson() => {
        'houseNumber': houseNumber,
        'street': street,
        'city': city,
        'postalCode': postalCode,
      };
}
