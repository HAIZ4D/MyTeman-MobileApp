// FILE: lib/services/enhanced_clinic_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/clinic.dart';

/// Enhanced Clinic Service with JSON loading and fuzzy search
class EnhancedClinicService {
  List<Clinic>? _clinics;
  bool _isLoaded = false;

  /// Load clinics from JSON file
  Future<void> loadClinics() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString('assets/clinics.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _clinics = jsonList.map((json) => Clinic.fromJson(json)).toList();
      _isLoaded = true;
    } catch (e) {
      print('Error loading clinics: $e');
      _clinics = [];
    }
  }

  /// Search clinics by location (state, city, or area)
  Future<List<Clinic>> searchByLocation({
    String? state,
    String? city,
    String? area,
  }) async {
    await loadClinics();

    if (_clinics == null || _clinics!.isEmpty) return [];

    // If no search criteria, return all
    if (state == null && city == null && area == null) {
      return List.from(_clinics!);
    }

    // Normalize input for better matching
    final normalizedState = state?.toLowerCase().trim();
    final normalizedCity = city?.toLowerCase().trim();
    final normalizedArea = area?.toLowerCase().trim();

    // First priority: Exact state match
    final exactStateMatches = _clinics!.where((clinic) {
      if (normalizedState == null) return false;
      return clinic.state.toLowerCase() == normalizedState;
    }).toList();

    if (exactStateMatches.isNotEmpty) return exactStateMatches;

    // Second priority: Exact city match
    final exactCityMatches = _clinics!.where((clinic) {
      if (normalizedCity == null) return false;
      return clinic.city.toLowerCase() == normalizedCity;
    }).toList();

    if (exactCityMatches.isNotEmpty) return exactCityMatches;

    // Third priority: Contains matching (for partial matches)
    return _clinics!.where((clinic) {
      final matchesState = normalizedState == null ||
          clinic.state.toLowerCase().contains(normalizedState);

      final matchesCity = normalizedCity == null ||
          clinic.city.toLowerCase().contains(normalizedCity);

      final matchesArea = normalizedArea == null ||
          clinic.address.toLowerCase().contains(normalizedArea);

      return matchesState || matchesCity || matchesArea;
    }).toList();
  }

  /// Get clinic by ID
  Future<Clinic?> getClinicById(String id) async {
    await loadClinics();

    try {
      return _clinics?.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all clinics
  Future<List<Clinic>> getAllClinics() async {
    await loadClinics();
    return List.from(_clinics ?? []);
  }

  /// Check if location is covered
  bool isLocationCovered(String? state) {
    if (state == null) return false;

    final coveredStates = ['melaka', 'johor', 'negeri sembilan'];
    return coveredStates.contains(state.toLowerCase());
  }

  /// Get nearest clinic (simplified - based on state match)
  Future<Clinic?> getNearestClinic({String? state, String? city}) async {
    final results = await searchByLocation(state: state, city: city);
    return results.isNotEmpty ? results.first : null;
  }

  /// Format clinic info for voice output
  String formatClinicForVoice(Clinic clinic, String language) {
    if (language == 'ms') {
      return '''Klinik PEKA B40 yang berdekatan dengan lokasi anda ialah ${clinic.name},
${clinic.address}, ${clinic.postcode}, ${clinic.city}, ${clinic.state}.
Nombor telefon: ${clinic.formattedContact}.''';
    } else {
      return '''The Peka B40 clinic nearest to your location is ${clinic.name},
${clinic.address}, ${clinic.postcode}, ${clinic.city}, ${clinic.state}.
Contact: ${clinic.formattedContact}.''';
    }
  }
}
