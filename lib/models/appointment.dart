// FILE: lib/models/appointment.dart

/// Appointment model for clinic bookings
class Appointment {
  final String appointmentId;
  final String clinicId;
  final String clinicName;
  final String userId;
  final String userName;
  final String userIc;
  final DateTime date;
  final String time;
  final String purpose;
  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Appointment({
    required this.appointmentId,
    required this.clinicId,
    required this.clinicName,
    required this.userId,
    required this.userName,
    required this.userIc,
    required this.date,
    required this.time,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// Get localized status label
  String getStatusLabel(String language) {
    switch (status) {
      case AppointmentStatus.pending:
        return language == 'ms' ? 'Menunggu' : 'Pending';
      case AppointmentStatus.confirmed:
        return language == 'ms' ? 'Disahkan' : 'Confirmed';
      case AppointmentStatus.completed:
        return language == 'ms' ? 'Selesai' : 'Completed';
      case AppointmentStatus.cancelled:
        return language == 'ms' ? 'Dibatalkan' : 'Cancelled';
      case AppointmentStatus.rejected:
        return language == 'ms' ? 'Ditolak' : 'Rejected';
    }
  }

  /// Get formatted date string
  String getFormattedDate(String language) {
    final months = language == 'ms'
        ? ['Jan', 'Feb', 'Mac', 'Apr', 'Mei', 'Jun', 'Jul', 'Ogos', 'Sep', 'Okt', 'Nov', 'Dis']
        : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointment_id'] as String,
      clinicId: json['clinic_id'] as String,
      clinicName: json['clinic_name'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userIc: json['user_ic'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      purpose: json['purpose'] as String,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == 'AppointmentStatus.${json['status']}',
        orElse: () => AppointmentStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'clinic_id': clinicId,
      'clinic_name': clinicName,
      'user_id': userId,
      'user_name': userName,
      'user_ic': userIc,
      'date': date.toIso8601String(),
      'time': time,
      'purpose': purpose,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  Appointment copyWith({
    String? appointmentId,
    String? clinicId,
    String? clinicName,
    String? userId,
    String? userName,
    String? userIc,
    DateTime? date,
    String? time,
    String? purpose,
    AppointmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Appointment(
      appointmentId: appointmentId ?? this.appointmentId,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userIc: userIc ?? this.userIc,
      date: date ?? this.date,
      time: time ?? this.time,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Appointment status enum
enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  rejected,
}
