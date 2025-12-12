// FILE: lib/config/bkoku_config.dart

/// BKOKU Configuration
///
/// PRODUCTION NOTE: Replace these values with secure environment variables.
/// Never commit API keys, secrets, or production URLs to version control.

class BkokuConfig {
  // Environment toggle
  static const bool USE_FIREBASE = false; // Set to true for Firebase backend
  static const bool ENABLE_OFFLINE_MODE = true;

  // Mock Node.js Backend URL
  // TODO: Replace with production backend URL
  static const String MOCK_NODE_URL = 'http://localhost:3000';

  // API Endpoints
  static const String API_APPLICATIONS = '/api/applications';
  static const String API_SYNC_JOBS = '/api/sync_jobs';
  static const String API_HEALTH = '/api/health';

  // Compression Settings
  static const int MAX_IMAGE_DIMENSION = 1024; // pixels
  static const int IMAGE_QUALITY = 70; // 0-100
  static const int MAX_FILE_SIZE_KB = 300; // per file

  // Sync Settings
  static const int MAX_RETRY_ATTEMPTS = 3;
  static const Duration INITIAL_RETRY_DELAY = Duration(seconds: 5);
  static const Duration MAX_RETRY_DELAY = Duration(minutes: 5);

  // Audio Recording (if enabled in future)
  // NOTE: Audio recording requires explicit user consent
  // and must be stored encrypted with access controls
  static const bool ENABLE_AUDIO_RECORDING = false;
  static const Duration MAX_AUDIO_DURATION = Duration(minutes: 2);

  // MyDigitalID Fields
  static const List<String> REQUIRED_FIELDS = [
    'name',
    'ic_number',
    'dob',
    'oku_id',
    'oku_status',
    'institution',
    'enrollment_no',
    'bank_account_no',
    'bank_name',
  ];

  // Required Documents
  static const List<String> REQUIRED_DOCUMENTS = [
    'disability_cert',
    'matriculation',
    'transcript',
    'bank_statement',
  ];

  // Document Type Labels (Malay/English)
  static const Map<String, Map<String, String>> DOCUMENT_LABELS = {
    'disability_cert': {
      'ms': 'Sijil OKU',
      'en': 'Disability Certificate',
    },
    'matriculation': {
      'ms': 'Kad Matrikulasi',
      'en': 'Matriculation Card',
    },
    'transcript': {
      'ms': 'Transkrip Akademik',
      'en': 'Academic Transcript',
    },
    'bank_statement': {
      'ms': 'Penyata Bank',
      'en': 'Bank Statement',
    },
  };

  // Consent Text
  static const Map<String, String> CONSENT_TEXT = {
    'ms': 'Saya memberi kebenaran kepada ISN untuk mengakses maklumat MyDigitalID saya termasuk butiran OKU, pendaftaran universiti, dan dokumen sokongan untuk tujuan permohonan BKOKU.',
    'en': 'I authorize ISN to access my MyDigitalID information including OKU details, university enrollment, and supporting documents for BKOKU application purposes.',
  };

  // TTS Messages
  static const Map<String, Map<String, String>> TTS_MESSAGES = {
    'welcome': {
      'ms': 'Selamat datang ke permohonan BKOKU. Saya akan bantu anda mengisi borang.',
      'en': 'Welcome to BKOKU application. I will help you fill the form.',
    },
    'consent_request': {
      'ms': 'Pertama, saya perlukan kebenaran untuk guna maklumat MyDigitalID anda.',
      'en': 'First, I need permission to use your MyDigitalID information.',
    },
    'autofill_complete': {
      'ms': 'Saya sudah isi borang dan muat naik dokumen dari MyDigitalID anda. Sila semak.',
      'en': 'I have filled the form and uploaded documents from your MyDigitalID. Please review.',
    },
    'submit_confirm': {
      'ms': 'Adakah anda mahu hantar permohonan sekarang?',
      'en': 'Would you like to submit the application now?',
    },
    'offline_detected': {
      'ms': 'Ops, tiada internet. Tidak mengapa, saya akan simpan dan hantar bila internet kembali.',
      'en': 'Oops, no internet. No worry, I will save and submit when internet is back.',
    },
    'queued': {
      'ms': 'Permohonan anda telah disimpan. Akan dihantar secara automatik bila ada internet.',
      'en': 'Your application has been saved. Will be submitted automatically when online.',
    },
    'syncing': {
      'ms': 'Sedang menghantar permohonan anda...',
      'en': 'Submitting your application...',
    },
    'submitted': {
      'ms': 'Permohonan BKOKU anda telah berjaya dihantar.',
      'en': 'Your BKOKU application has been successfully submitted.',
    },
    'failed': {
      'ms': 'Penghantaran gagal. Saya akan cuba lagi kemudian.',
      'en': 'Upload failed. I will retry later.',
    },
  };

  // Security Notes (for developers)
  static const String SECURITY_NOTES = '''
    SECURITY CHECKLIST:
    1. Never log raw IC numbers or bank account numbers
    2. Always use HTTPS for API calls
    3. Encrypt sensitive data at rest
    4. Validate all user inputs
    5. Use secure key storage (e.g., Flutter Secure Storage)
    6. Implement rate limiting on backend
    7. Add CSP headers on web
    8. Regular security audits
    9. GDPR/PDPA compliance for data handling
    10. Implement proper session management
  ''';
}
