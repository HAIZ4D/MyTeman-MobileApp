import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application.dart';
import '../models/service.dart';
import '../providers/app_state_provider.dart';
import '../services/sync_queue.dart';

/// Screen to display user's submitted applications
class MyApplicationsScreen extends ConsumerStatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  ConsumerState<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen> {
  final SyncQueue _syncQueue = SyncQueue();

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(language == 'ms' ? 'Permohonan Saya' : 'My Applications'),
        ),
        body: Center(
          child: Text(language == 'ms' ? 'Sila log masuk' : 'Please login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(language == 'ms' ? 'Permohonan Saya' : 'My Applications'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: language == 'ms' ? 'Muat semula' : 'Refresh',
            onPressed: () {
              setState(() {}); // Trigger rebuild
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Pending sync queue indicator
          FutureBuilder<int>(
            future: _syncQueue.getQueueSize(),
            builder: (context, snapshot) {
              final queueSize = snapshot.data ?? 0;
              if (queueSize == 0) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.orange[100],
                child: Row(
                  children: [
                    const Icon(Icons.sync, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        language == 'ms'
                            ? '$queueSize permohonan menunggu untuk disegerakkan'
                            : '$queueSize application(s) waiting to sync',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Applications list from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('applications')
                  // Temporarily removed uid filter to show all applications
                  // TODO: Add back .where('uid', isEqualTo: user.uid) after fixing documents
                  .orderBy('submitted_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          language == 'ms' ? 'Ralat: ${snapshot.error}' : 'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 100, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          language == 'ms'
                              ? 'Tiada permohonan'
                              : 'No applications',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          language == 'ms'
                              ? 'Permohonan anda akan muncul di sini'
                              : 'Your applications will appear here',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                final applications = snapshot.data!.docs
                    .map((doc) => Application.fromJson(doc.data() as Map<String, dynamic>))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final app = applications[index];
                    return _ApplicationCard(
                      application: app,
                      language: language,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Card widget to display individual application
class _ApplicationCard extends ConsumerWidget {
  final Application application;
  final String language;

  const _ApplicationCard({
    required this.application,
    required this.language,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Service?>(
      future: ref.read(myGovServiceProvider).getServiceById(application.serviceId),
      builder: (context, snapshot) {
        final service = snapshot.data;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: InkWell(
            onTap: () {
              // TODO: Navigate to application details
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service title
                  Row(
                    children: [
                      Icon(
                        _getServiceIcon(service?.icon, application.serviceId),
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getServiceTitle(service, application.serviceId, language),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Clinic appointment details
                  if (application.serviceId == 'peka_b40_clinic_search' && application.filledData.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (application.filledData['clinic_name'] != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.local_hospital, size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    application.filledData['clinic_name'],
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (application.filledData['appointment_date'] != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  _formatAppointmentDate(application.filledData['appointment_date']),
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(width: 16),
                                if (application.filledData['appointment_time'] != null) ...[
                                  const Icon(Icons.access_time, size: 16, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(
                                    application.filledData['appointment_time'],
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // BKOKU application details
                  if (application.serviceId == 'bkoku_application_2025' && application.filledData.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (application.filledData['institution'] != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.school, size: 16, color: Colors.purple),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    application.filledData['institution'],
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (application.filledData['enrollment_no'] != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.badge, size: 16, color: Colors.purple),
                                const SizedBox(width: 8),
                                Text(
                                  '${language == 'ms' ? 'No. Matrik' : 'Enrollment No'}: ${application.filledData['enrollment_no']}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (application.filledData['oku_id'] != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.card_membership, size: 16, color: Colors.purple),
                                const SizedBox(width: 8),
                                Text(
                                  '${language == 'ms' ? 'ID OKU' : 'OKU ID'}: ${application.filledData['oku_id']}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (application.filledData['documents_count'] != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.attach_file, size: 16, color: Colors.purple),
                                const SizedBox(width: 8),
                                Text(
                                  '${application.filledData['documents_count']} ${language == 'ms' ? 'dokumen' : 'documents'}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Status badge
                  Row(
                    children: [
                      _StatusBadge(
                        status: application.status,
                        language: language,
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(application.submittedAt.toString(), language),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // Application ID
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${application.appId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getServiceIcon(String? iconName, String serviceId) {
    // Check service ID first for special services
    if (serviceId == 'peka_b40_clinic_search') {
      return Icons.local_hospital;
    }
    if (serviceId == 'bkoku_application_2025') {
      return Icons.school;
    }

    // Then check icon name from service
    switch (iconName) {
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'business_center':
        return Icons.business_center;
      case 'school':
        return Icons.school;
      default:
        return Icons.description;
    }
  }

  String _getServiceTitle(Service? service, String serviceId, String language) {
    // Handle special services
    if (serviceId == 'peka_b40_clinic_search') {
      return language == 'ms' ? 'Temujanji Klinik PEKA B40' : 'PEKA B40 Clinic Appointment';
    }
    if (serviceId == 'bkoku_application_2025') {
      return language == 'ms' ? 'Permohonan BKOKU 2025' : 'BKOKU Application 2025';
    }

    // Use service title if available
    if (service != null) {
      return service.title;
    }

    // Fallback to service ID
    return serviceId;
  }

  String _formatAppointmentDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }

  String _formatDate(String isoDate, String language) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return language == 'ms' ? 'Hari ini' : 'Today';
      } else if (difference.inDays == 1) {
        return language == 'ms' ? 'Semalam' : 'Yesterday';
      } else if (difference.inDays < 7) {
        return language == 'ms' ? '${difference.inDays} hari lalu' : '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return isoDate;
    }
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final String status;
  final String language;

  const _StatusBadge({
    required this.status,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'submitted':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[900]!;
        label = language == 'ms' ? 'Dihantar' : 'Submitted';
        break;
      case 'draft':
      case 'saved':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
        label = language == 'ms' ? 'Disimpan' : 'Saved';
        break;
      case 'processing':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[900]!;
        label = language == 'ms' ? 'Diproses' : 'Processing';
        break;
      case 'approved':
        backgroundColor = Colors.teal[100]!;
        textColor = Colors.teal[900]!;
        label = language == 'ms' ? 'Diluluskan' : 'Approved';
        break;
      case 'rejected':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[900]!;
        label = language == 'ms' ? 'Ditolak' : 'Rejected';
        break;
      default:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[800]!;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
