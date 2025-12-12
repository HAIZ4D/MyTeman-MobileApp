// FILE: lib/providers/voice_clinic_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/voice_service_enhanced.dart';
import '../services/enhanced_clinic_service.dart';
import '../services/appointment_service.dart';
import '../services/application_service.dart';
import '../services/my_digital_id_service.dart';
import '../models/clinic.dart';
import '../models/appointment.dart';
import '../models/application.dart';

/// Voice Service Provider
final voiceServiceProvider = Provider<VoiceServiceEnhanced>((ref) {
  final service = VoiceServiceEnhanced();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Clinic Service Provider
final clinicServiceProvider = Provider<EnhancedClinicService>((ref) {
  return EnhancedClinicService();
});

/// Appointment Service Provider
final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  return AppointmentService();
});

/// Application Service Provider
final applicationServiceProvider = Provider<ApplicationService>((ref) {
  return ApplicationService();
});

/// MyDigitalID Service Provider
final myDigitalIDServiceProvider = Provider<MyDigitalIDService>((ref) {
  return MyDigitalIDService();
});

/// Selected Clinic State Provider
final selectedClinicProvider = StateProvider<Clinic?>((ref) => null);

/// Clinic Search Results Provider
final clinicSearchResultsProvider = StateProvider<List<Clinic>>((ref) => []);

/// Current Appointment Draft Provider
final appointmentDraftProvider = StateProvider<Map<String, dynamic>>((ref) => {});

/// User Appointments Stream Provider
final userAppointmentsProvider = StreamProvider.family<List<Appointment>, String>((ref, userId) {
  final appointmentService = ref.watch(appointmentServiceProvider);
  return appointmentService.getUserAppointments(userId);
});

/// User Applications Stream Provider
final userApplicationsProvider = StreamProvider.family<List<Application>, String>((ref, userId) {
  final applicationService = ref.watch(applicationServiceProvider);
  return applicationService.streamApplicationsByUser(userId);
});

/// Voice Listening State Provider
final voiceListeningProvider = StateProvider<bool>((ref) => false);

/// Voice Speaking State Provider
final voiceSpeakingProvider = StateProvider<bool>((ref) => false);

/// Current Transcript Provider
final currentTranscriptProvider = StateProvider<String>((ref) => '');

/// Conversation State Provider
enum ConversationState {
  initial,
  askingLocation,
  searchingClinic,
  showingResults,
  askingAction,
  bookingAppointment,
  collectingAppointmentDetails,
  authenticating,
  submitting,
  completed,
}

final conversationStateProvider = StateProvider<ConversationState>((ref) {
  return ConversationState.initial;
});

/// Conversation Messages Provider
final conversationMessagesProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);
