// FILE: lib/screens/appointment_status_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../models/appointment.dart';
import '../providers/voice_clinic_providers.dart';

/// Appointment Status Screen - View all user appointments
class AppointmentStatusScreen extends ConsumerWidget {
  final User user;

  const AppointmentStatusScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(userAppointmentsProvider(user.uid));
    final lang = user.preferredLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'ms' ? 'Status Temujanji' : 'Appointment Status'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: appointmentsAsync.when(
        data: (appointments) {
          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lang == 'ms'
                        ? 'Tiada temujanji'
                        : 'No appointments',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              return _AppointmentCard(
                appointment: appointments[index],
                language: lang,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            lang == 'ms'
                ? 'Ralat memuatkan temujanji'
                : 'Error loading appointments',
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String language;

  const _AppointmentCard({
    required this.appointment,
    required this.language,
  });

  Color _getStatusColor() {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return Icons.schedule;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.completed:
        return Icons.done_all;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
      case AppointmentStatus.rejected:
        return Icons.block;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appointment.clinicName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 16,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment.getStatusLabel(language),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Appointment details
            _buildDetailRow(
              Icons.calendar_today,
              language == 'ms' ? 'Tarikh' : 'Date',
              appointment.getFormattedDate(language),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.access_time,
              language == 'ms' ? 'Masa' : 'Time',
              appointment.time,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.medical_services,
              language == 'ms' ? 'Tujuan' : 'Purpose',
              appointment.purpose,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.badge,
              language == 'ms' ? 'ID Temujanji' : 'Appointment ID',
              appointment.appointmentId,
            ),

            const SizedBox(height: 16),

            // Action buttons
            if (appointment.status == AppointmentStatus.pending ||
                appointment.status == AppointmentStatus.confirmed)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Get clinic location URL from metadata if available
                        final locationUrl = appointment.metadata?['clinic_location_url'] as String?;
                        if (locationUrl != null) {
                          final uri = Uri.parse(locationUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        }
                      },
                      icon: const Icon(Icons.map),
                      label: Text(language == 'ms' ? 'Arah' : 'Directions'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Show appointment details
                        showDialog(
                          context: context,
                          builder: (context) => _AppointmentDetailsDialog(
                            appointment: appointment,
                            language: language,
                          ),
                        );
                      },
                      icon: const Icon(Icons.info),
                      label: Text(language == 'ms' ? 'Butiran' : 'Details'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppointmentDetailsDialog extends StatelessWidget {
  final Appointment appointment;
  final String language;

  const _AppointmentDetailsDialog({
    required this.appointment,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(language == 'ms' ? 'Butiran Temujanji' : 'Appointment Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSection(
              language == 'ms' ? 'Klinik' : 'Clinic',
              appointment.clinicName,
            ),
            const Divider(),
            _buildSection(
              language == 'ms' ? 'Pesakit' : 'Patient',
              appointment.userName,
            ),
            _buildSection(
              language == 'ms' ? 'No. KP' : 'IC Number',
              appointment.userIc,
            ),
            const Divider(),
            _buildSection(
              language == 'ms' ? 'Tarikh & Masa' : 'Date & Time',
              '${appointment.getFormattedDate(language)}, ${appointment.time}',
            ),
            _buildSection(
              language == 'ms' ? 'Tujuan Lawatan' : 'Purpose of Visit',
              appointment.purpose,
            ),
            const Divider(),
            _buildSection(
              language == 'ms' ? 'Status' : 'Status',
              appointment.getStatusLabel(language),
            ),
            _buildSection(
              language == 'ms' ? 'Dibuat Pada' : 'Created At',
              appointment.createdAt.toString().split('.')[0],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(language == 'ms' ? 'Tutup' : 'Close'),
        ),
      ],
    );
  }

  Widget _buildSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
