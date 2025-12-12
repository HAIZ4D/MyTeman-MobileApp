class User {
  final String uid;
  final String name;
  final String icNumber; // Redacted format: XXXXXX-01-1234
  final String dob;
  final String address;
  final bool mydigitalidLinked;
  final bool biometricEnabled;
  final String preferredLanguage;
  final AccessibilitySettings accessibility;

  // OKU (Orang Kurang Upaya) fields for BKOKU
  final bool? okuStatus;
  final String? okuId;
  final String? institution;
  final String? enrollmentNo;
  final String? bankAccountNo;
  final String? bankName;
  final List<StoredDocument>? storedDocuments;

  // Eligibility fields for Peka B40
  final String? citizenship;
  final int? householdIncome;
  final List<String>? existingAids; // e.g., ["STR", "BSH"]
  final int? householdSize;

  User({
    required this.uid,
    required this.name,
    required this.icNumber,
    required this.dob,
    required this.address,
    required this.mydigitalidLinked,
    required this.biometricEnabled,
    required this.preferredLanguage,
    required this.accessibility,
    this.okuStatus,
    this.okuId,
    this.institution,
    this.enrollmentNo,
    this.bankAccountNo,
    this.bankName,
    this.storedDocuments,
    this.citizenship,
    this.householdIncome,
    this.existingAids,
    this.householdSize,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      name: json['name'] as String,
      icNumber: json['ic_number'] as String,
      dob: json['dob'] as String,
      address: json['address'] as String,
      mydigitalidLinked: json['mydigitalid_linked'] as bool,
      biometricEnabled: json['biometric_enabled'] as bool,
      preferredLanguage: json['preferred_language'] as String,
      accessibility: AccessibilitySettings.fromJson(
        json['accessibility'] as Map<String, dynamic>,
      ),
      okuStatus: json['oku_status'] as bool?,
      okuId: json['oku_id'] as String?,
      institution: json['institution'] as String?,
      enrollmentNo: json['enrollment_no'] as String?,
      bankAccountNo: json['bank_account_no'] as String?,
      bankName: json['bank_name'] as String?,
      storedDocuments: json['stored_docs'] != null
          ? (json['stored_docs'] as List)
              .map((e) => StoredDocument.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      citizenship: json['citizenship'] as String?,
      householdIncome: json['household_income'] as int?,
      existingAids: json['existing_aids'] != null
          ? List<String>.from(json['existing_aids'] as List)
          : null,
      householdSize: json['household_size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'ic_number': icNumber,
      'dob': dob,
      'address': address,
      'mydigitalid_linked': mydigitalidLinked,
      'biometric_enabled': biometricEnabled,
      'preferred_language': preferredLanguage,
      'accessibility': accessibility.toJson(),
      'oku_status': okuStatus,
      'oku_id': okuId,
      'institution': institution,
      'enrollment_no': enrollmentNo,
      'bank_account_no': bankAccountNo,
      'bank_name': bankName,
      'stored_docs': storedDocuments?.map((e) => e.toJson()).toList(),
      'citizenship': citizenship,
      'household_income': householdIncome,
      'existing_aids': existingAids,
      'household_size': householdSize,
    };
  }

  User copyWith({
    String? uid,
    String? name,
    String? icNumber,
    String? dob,
    String? address,
    bool? mydigitalidLinked,
    bool? biometricEnabled,
    String? preferredLanguage,
    AccessibilitySettings? accessibility,
    bool? okuStatus,
    String? okuId,
    String? institution,
    String? enrollmentNo,
    String? bankAccountNo,
    String? bankName,
    List<StoredDocument>? storedDocuments,
    String? citizenship,
    int? householdIncome,
    List<String>? existingAids,
    int? householdSize,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      icNumber: icNumber ?? this.icNumber,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      mydigitalidLinked: mydigitalidLinked ?? this.mydigitalidLinked,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      accessibility: accessibility ?? this.accessibility,
      okuStatus: okuStatus ?? this.okuStatus,
      okuId: okuId ?? this.okuId,
      institution: institution ?? this.institution,
      enrollmentNo: enrollmentNo ?? this.enrollmentNo,
      bankAccountNo: bankAccountNo ?? this.bankAccountNo,
      bankName: bankName ?? this.bankName,
      storedDocuments: storedDocuments ?? this.storedDocuments,
      citizenship: citizenship ?? this.citizenship,
      householdIncome: householdIncome ?? this.householdIncome,
      existingAids: existingAids ?? this.existingAids,
      householdSize: householdSize ?? this.householdSize,
    );
  }

  // Calculate age from date of birth
  int get age {
    try {
      final birthDate = DateTime.parse(dob);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }
}

/// Document stored in MyDigitalID vault
class StoredDocument {
  final String name;
  final String path;
  final String type; // disability_cert, matriculation, transcript, bank_statement
  final String? base64Data;

  StoredDocument({
    required this.name,
    required this.path,
    required this.type,
    this.base64Data,
  });

  factory StoredDocument.fromJson(Map<String, dynamic> json) {
    return StoredDocument(
      name: json['name'] as String,
      path: json['path'] as String,
      type: json['type'] as String,
      base64Data: json['base64'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'type': type,
      'base64': base64Data,
    };
  }
}

class AccessibilitySettings {
  final bool visuallyImpaired;
  final bool voiceFirst;
  final bool ruralMode;

  AccessibilitySettings({
    required this.visuallyImpaired,
    required this.voiceFirst,
    required this.ruralMode,
  });

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      visuallyImpaired: json['visually_impaired'] as bool,
      voiceFirst: json['voice_first'] as bool,
      ruralMode: json['rural_mode'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visually_impaired': visuallyImpaired,
      'voice_first': voiceFirst,
      'rural_mode': ruralMode,
    };
  }

  AccessibilitySettings copyWith({
    bool? visuallyImpaired,
    bool? voiceFirst,
    bool? ruralMode,
  }) {
    return AccessibilitySettings(
      visuallyImpaired: visuallyImpaired ?? this.visuallyImpaired,
      voiceFirst: voiceFirst ?? this.voiceFirst,
      ruralMode: ruralMode ?? this.ruralMode,
    );
  }
}
