import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/service.dart';
import '../models/application.dart';
import '../config.dart';

class MyGovService {
  final FirebaseFirestore? _firestore;
  Map<String, dynamic>? _seedData;

  MyGovService() : _firestore = AppConfig.useFirebase ? FirebaseFirestore.instance : null;

  // Load seed data from JSON
  Future<void> _loadSeedData() async {
    if (_seedData != null) return;
    final String jsonString = await rootBundle.loadString('assets/seed/mygov_seed.json');
    _seedData = json.decode(jsonString);
  }

  // Get user by UID
  Future<User?> getUserByUid(String uid) async {
    if (AppConfig.useFirebase) {
      final doc = await _firestore!.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return User.fromJson(doc.data()!);
    } else {
      await _loadSeedData();
      final users = _seedData!['users'] as List;
      final userJson = users.firstWhere(
        (u) => u['uid'] == uid,
        orElse: () => null,
      );
      return userJson != null ? User.fromJson(userJson) : null;
    }
  }

  // Get all users (for demo selection)
  Future<List<User>> getAllUsers() async {
    if (AppConfig.useFirebase) {
      final snapshot = await _firestore!.collection('users').get();
      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    } else {
      await _loadSeedData();
      final users = _seedData!['users'] as List;
      return users.map((u) => User.fromJson(u)).toList();
    }
  }

  // Get service by ID
  Future<Service?> getServiceById(String serviceId) async {
    if (AppConfig.useFirebase) {
      final doc = await _firestore!.collection('services').doc(serviceId).get();
      if (!doc.exists) return null;
      return Service.fromJson(doc.data()!);
    } else {
      await _loadSeedData();
      final services = _seedData!['services'] as List;
      final serviceJson = services.firstWhere(
        (s) => s['serviceId'] == serviceId,
        orElse: () => null,
      );
      return serviceJson != null ? Service.fromJson(serviceJson) : null;
    }
  }

  // Get all services
  Future<List<Service>> getAllServices() async {
    if (AppConfig.useFirebase) {
      final snapshot = await _firestore!.collection('services').get();
      return snapshot.docs.map((doc) => Service.fromJson(doc.data())).toList();
    } else {
      await _loadSeedData();
      final services = _seedData!['services'] as List;
      return services.map((s) => Service.fromJson(s)).toList();
    }
  }

  // Submit application
  Future<String> submitApplication(Application application) async {
    if (AppConfig.useFirebase) {
      final docRef = await _firestore!.collection('applications').add(application.toJson());
      return docRef.id;
    } else {
      // In local mode, just return a mock ID
      return 'app_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Get applications for a user
  Future<List<Application>> getApplicationsForUser(String uid) async {
    if (AppConfig.useFirebase) {
      final snapshot = await _firestore!
          .collection('applications')
          .where('uid', isEqualTo: uid)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['appId'] = doc.id;
        return Application.fromJson(data);
      }).toList();
    } else {
      // In local mode, return empty list for now
      return [];
    }
  }

  // Update user
  Future<void> updateUser(User user) async {
    if (AppConfig.useFirebase) {
      await _firestore!.collection('users').doc(user.uid).set(user.toJson());
    } else {
      // In local mode, update is simulated (not persisted)
      if (kDebugMode) {
        print('Local mode: User update simulated for ${user.uid}');
      }
    }
  }
}
