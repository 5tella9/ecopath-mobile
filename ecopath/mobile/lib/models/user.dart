import 'enums.dart';
import 'location.dart';

class User {
  final String fullName;
  final String email;

  Location? location;
  List<String>? ecoGoals;
  int? householdSize;
  HousingType? housingType;
  Gender? gender;
  String? birthDate;
  String? profileImage;
  String? avatarBackground;

  User({
    required this.fullName,
    required this.email,
    this.location,
    this.ecoGoals,
    this.householdSize,
    this.housingType,
    this.gender,
    this.birthDate,
    this.profileImage,
    this.avatarBackground,
  });

  /// Convert User to JSON (for saving to storage or sending to backend)
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'location': location?.toJson(), // Make sure Location has toJson()
      'ecoGoals': ecoGoals,
      'householdSize': householdSize,
      'housingType': housingType?.name, // enum -> string
      'gender': gender?.name, // enum -> string
      'birthDate': birthDate,
      'profileImage': profileImage,
      'avatarBackground': avatarBackground,
    };
  }

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['fullName'],
      email: json['email'],
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      ecoGoals: List<String>.from(json['ecoGoals'] ?? []),
      householdSize: json['householdSize'],
      housingType: json['housingType'] != null
          ? HousingType.values.firstWhere((e) => e.name == json['housingType'])
          : null,
      gender: json['gender'] != null
          ? Gender.values.firstWhere((e) => e.name == json['gender'])
          : null,
      birthDate: json['birthDate'],
      profileImage: json['profileImage'],
      avatarBackground: json['avatarBackground'],
    );
  }

  User copyWith({
    String? birthDate,
    Gender? gender,
    Location? location,
    List<String>? ecoGoals,
    int? householdSize,
    HousingType? housingType,
  }) {
    return User(
      fullName: fullName,
      email: email,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      ecoGoals: ecoGoals ?? this.ecoGoals,
      householdSize: householdSize ?? this.householdSize,
      housingType: housingType ?? this.housingType,
    );
  }

}
