/// Clinic model for PEKA B40 clinic search
class Clinic {
  final String id;
  final String name;
  final String address;
  final String postcode;
  final String city;
  final String state;
  final String contactNo;
  final bool isPublic;
  final String locationUrl;
  final double? latitude;
  final double? longitude;
  final String? operatingHours;
  final List<String>? services;
  final List<String>? languages;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.postcode,
    required this.city,
    required this.state,
    required this.contactNo,
    required this.isPublic,
    required this.locationUrl,
    this.latitude,
    this.longitude,
    this.operatingHours,
    this.services,
    this.languages,
  });

  /// Get full address string
  String get fullAddress {
    return '$address, $postcode $city, $state';
  }

  /// Get formatted contact number
  String get formattedContact {
    return contactNo.replaceFirst('+60', '0');
  }

  /// Calculate distance from user location (simplified for demo)
  /// In real app, use actual GPS coordinates and distance calculation
  String getDistanceFrom(String userState) {
    if (userState.toLowerCase() == state.toLowerCase()) {
      return '5-15 km'; // Same state
    } else {
      // Check neighboring states
      if (_isNearbyState(userState, state)) {
        return '50-100 km';
      } else {
        return '100+ km';
      }
    }
  }

  bool _isNearbyState(String state1, String state2) {
    final nearby = {
      'melaka': ['johor', 'negeri sembilan'],
      'johor': ['melaka', 'pahang'],
      'negeri sembilan': ['melaka', 'selangor', 'pahang'],
      'selangor': ['negeri sembilan', 'perak', 'pahang'],
    };

    final s1 = state1.toLowerCase();
    final s2 = state2.toLowerCase();

    return nearby[s1]?.contains(s2) ?? false;
  }

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      postcode: json['postcode'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      contactNo: json['contact'] as String,
      isPublic: json['is_public'] as bool,
      locationUrl: json['location_url'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      operatingHours: json['operating_hours'] as String?,
      services: json['services'] != null ? List<String>.from(json['services'] as List) : null,
      languages: json['languages'] != null ? List<String>.from(json['languages'] as List) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'postcode': postcode,
      'city': city,
      'state': state,
      'contact': contactNo,
      'is_public': isPublic,
      'location_url': locationUrl,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (operatingHours != null) 'operating_hours': operatingHours,
      if (services != null) 'services': services,
      if (languages != null) 'languages': languages,
    };
  }
}
