import '../models/clinic.dart';

/// Clinic Search Service for PEKA B40 clinics
/// Demo version with 3 hardcoded clinics from different states
class ClinicService {
  // Demo clinic database - 3 clinics from different states
  static final List<Clinic> _demoClinicDatabase = [
    Clinic(
      id: 'clinic_001',
      name: 'KLINIK DR. HALIM SDN BHD',
      address: 'MT 254 TAMAN SINN, JALAN SEMABOK',
      postcode: '75050',
      city: 'Melaka',
      state: 'Melaka',
      contactNo: '+606-2841199',
      isPublic: false,
      locationUrl: 'https://maps.app.goo.gl/77nDrK7Wa1ay4TvB7',
      latitude: 2.1896,
      longitude: 102.2501,
      operatingHours: 'Mon-Fri: 8:00 AM - 5:00 PM, Sat: 8:00 AM - 1:00 PM',
      services: ['General Checkup', 'Blood Test', 'Vaccination', 'Health Screening'],
      languages: ['Malay', 'English', 'Chinese'],
    ),
    Clinic(
      id: 'clinic_002',
      name: 'ALPRO CLINIC',
      address: 'NO 29-5 (TINGKAT BAWAH), JALAN PESTA 1/2 KAMPUNG KENANGAN TUN DR ISMAIL',
      postcode: '84000',
      city: 'Muar',
      state: 'Johor',
      contactNo: '+6013-9724828',
      isPublic: false,
      locationUrl: 'https://maps.app.goo.gl/8QCxfsjdadT8Mj5V9',
      latitude: 2.0442,
      longitude: 102.5689,
      operatingHours: 'Mon-Sat: 9:00 AM - 6:00 PM',
      services: ['General Checkup', 'Blood Test', 'X-Ray', 'Health Screening'],
      languages: ['Malay', 'English'],
    ),
    Clinic(
      id: 'clinic_003',
      name: 'Clinic Ramani',
      address: '2026 Taman Ria, KM4 Jalan Seremban',
      postcode: '71000',
      city: 'Port Dickson',
      state: 'Negeri Sembilan',
      contactNo: '+606-6512244',
      isPublic: false,
      locationUrl: 'https://maps.app.goo.gl/ujZAj6PxPwoVsqyG8',
      latitude: 2.5270,
      longitude: 101.7967,
      operatingHours: 'Mon-Fri: 8:30 AM - 5:30 PM, Sat: 8:30 AM - 12:30 PM',
      services: ['General Checkup', 'Blood Test', 'Minor Surgery', 'Health Screening'],
      languages: ['Malay', 'English', 'Tamil'],
    ),
  ];

  /// Search for PEKA B40 clinics near user's location
  /// Returns list of clinics sorted by distance
  Future<List<Clinic>> searchClinics({
    String? userCity,
    String? userState,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (userState == null || userState.isEmpty) {
      // No location provided, return all clinics
      return _demoClinicDatabase;
    }

    // Check if user's state matches any clinic
    final matchingClinics = _demoClinicDatabase.where((clinic) {
      return clinic.state.toLowerCase() == userState.toLowerCase() ||
          clinic.city.toLowerCase() == (userCity?.toLowerCase() ?? '');
    }).toList();

    if (matchingClinics.isNotEmpty) {
      return matchingClinics;
    }

    // Check nearby states
    final nearbyClinics = _demoClinicDatabase.where((clinic) {
      return _isNearbyState(userState, clinic.state);
    }).toList();

    if (nearbyClinics.isNotEmpty) {
      return nearbyClinics;
    }

    // User is too far from all clinics - return empty list
    // Gemini will handle the "Oh no sorry" response
    return [];
  }

  /// Get all clinics (for demo purposes)
  List<Clinic> getAllClinics() {
    return List.from(_demoClinicDatabase);
  }

  /// Get clinic by name
  Clinic? getClinicByName(String name) {
    try {
      return _demoClinicDatabase.firstWhere(
        (clinic) => clinic.name.toLowerCase().contains(name.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if user location is covered by any clinic
  bool isLocationCovered(String? userState) {
    if (userState == null || userState.isEmpty) return false;

    // Check exact match
    final hasExactMatch = _demoClinicDatabase.any(
      (clinic) => clinic.state.toLowerCase() == userState.toLowerCase(),
    );

    if (hasExactMatch) return true;

    // Check nearby states
    return _demoClinicDatabase.any(
      (clinic) => _isNearbyState(userState, clinic.state),
    );
  }

  /// Get user-friendly message about clinic availability
  String getAvailabilityMessage(String? userState, String language) {
    if (userState == null || userState.isEmpty) {
      return language == 'ms'
          ? 'Sila beritahu lokasi anda untuk carian klinik yang lebih tepat.'
          : 'Please provide your location for more accurate clinic search.';
    }

    if (isLocationCovered(userState)) {
      return language == 'ms'
          ? 'Klinik PEKA B40 tersedia di kawasan anda!'
          : 'PEKA B40 clinics are available in your area!';
    } else {
      return language == 'ms'
          ? 'Maaf, kawasan anda terlalu jauh dari klinik PEKA B40 yang tersedia. Klinik demo hanya merangkumi Melaka, Johor, dan Negeri Sembilan.'
          : 'Sorry, your area is too far from available PEKA B40 clinics. Demo clinics only cover Melaka, Johor, and Negeri Sembilan.';
    }
  }

  /// Helper to check if states are nearby
  bool _isNearbyState(String state1, String state2) {
    final nearby = {
      'melaka': ['johor', 'negeri sembilan'],
      'johor': ['melaka', 'pahang'],
      'negeri sembilan': ['melaka', 'selangor', 'pahang'],
      'selangor': ['negeri sembilan', 'perak', 'pahang'],
      'pahang': ['johor', 'negeri sembilan', 'selangor'],
      'kuala lumpur': ['selangor'],
    };

    final s1 = state1.toLowerCase();
    final s2 = state2.toLowerCase();

    return nearby[s1]?.contains(s2) ?? false;
  }

  /// Format clinic list for Gemini AI context
  String formatClinicsForAI(List<Clinic> clinics, String language) {
    if (clinics.isEmpty) {
      return language == 'ms'
          ? 'Tiada klinik PEKA B40 berdekatan dengan lokasi pengguna.'
          : 'No PEKA B40 clinics found near user location.';
    }

    final buffer = StringBuffer();
    for (int i = 0; i < clinics.length; i++) {
      final clinic = clinics[i];
      buffer.writeln('${i + 1}. ${clinic.name}');
      buffer.writeln('   Alamat: ${clinic.fullAddress}');
      buffer.writeln('   Telefon: ${clinic.formattedContact}');
      buffer.writeln('   Google Maps: ${clinic.locationUrl}');
      buffer.writeln();
    }

    return buffer.toString();
  }
}
