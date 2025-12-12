// FILE: lib/services/appointment_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

/// Appointment Service for booking and managing clinic appointments
class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'appointments';

  /// Create new appointment
  Future<Appointment> createAppointment(Appointment appointment) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(appointment.appointmentId)
          .set(appointment.toJson());

      return appointment;
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow;
    }
  }

  /// Get user appointments
  Stream<List<Appointment>> getUserAppointments(String userId) {
    return _firestore
        .collection(_collection)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get appointment by ID
  Future<Appointment?> getAppointmentById(String appointmentId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(appointmentId)
          .get();

      if (doc.exists) {
        return Appointment.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting appointment: $e');
      return null;
    }
  }

  /// Update appointment status
  Future<void> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).update({
        'status': status.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating appointment status: $e');
      rethrow;
    }
  }

  /// Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
  }

  /// Generate unique appointment ID
  String generateAppointmentId() {
    return 'apt_${DateTime.now().millisecondsSinceEpoch}';
  }
}
