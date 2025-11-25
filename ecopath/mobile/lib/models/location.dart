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

  // Convert Location to Map (for saving to backend or SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'houseNumber': houseNumber,
      'street': street,
      'city': city,
      'postalCode': postalCode,
    };
  }

  // Create Location from Map (for loading data)
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      houseNumber: json['houseNumber'],
      street: json['street'],
      city: json['city'],
      postalCode: json['postalCode'],
    );
  }
}