import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/user.dart';
import '../models/service.dart';
import '../models/clinic.dart';
import 'clinic_service.dart';

/// Gemini AI Service for intelligent voice assistant conversations
/// Handles multi-turn dialogues with context awareness for government services
class GeminiService {
  static const String _apiKey = 'AIzaSyAqv3L7kx6CNmUVjGs86jrntEnpXh1QvLk';
  late final GenerativeModel _model;
  ChatSession? _currentChat;
  final ClinicService _clinicService = ClinicService();

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
  }

  /// Start a new conversation session for a specific service
  /// Includes system context about the service, user, and language preference
  Future<void> startConversation({
    required Service service,
    required User user,
    required String language,
  }) async {
    final systemPrompt = _buildSystemPrompt(service, user, language);

    _currentChat = _model.startChat(
      history: [
        Content.text(systemPrompt),
      ],
    );
  }

  /// Send a message and get AI response
  /// Maintains conversation context automatically
  Future<String> sendMessage(String userMessage) async {
    if (_currentChat == null) {
      throw Exception('No active conversation. Call startConversation first.');
    }

    try {
      final response = await _currentChat!.sendMessage(
        Content.text(userMessage),
      );

      return response.text ?? 'Maaf, saya tidak dapat menjawab. (Sorry, I could not respond.)';
    } catch (e) {
      print('Gemini API Error: $e');
      return 'Ralat sambungan. Sila cuba lagi. (Connection error. Please try again.)';
    }
  }

  /// Get a one-time response without maintaining conversation history
  /// Useful for quick queries or intent detection
  Future<String> getQuickResponse(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response generated';
    } catch (e) {
      print('Gemini API Error: $e');
      return 'Error generating response';
    }
  }

  /// Detect user intent from voice input
  /// Returns the most likely service ID the user wants to access
  Future<Map<String, dynamic>> detectIntent(String transcript, String language) async {
    final prompt = '''
You are an intent classifier for Malaysian government services.
Based on the user's voice input, determine which service they want to access.

Available services:
1. peka_b40_clinic_search - Finding PEKA B40 clinics nearby
2. peka_b40_eligibility_check - Checking eligibility for PEKA B40 program
3. bkoku_application_2025 - Applying for financial aid for disabled students

User input (${language == 'ms' ? 'Malay' : 'English'}): "$transcript"

Respond in JSON format:
{
  "serviceId": "service_id_here",
  "confidence": 0.0-1.0,
  "language": "ms" or "en"
}
''';

    try {
      final response = await getQuickResponse(prompt);
      // Parse JSON response
      // Note: In production, add proper JSON parsing with error handling
      return {
        'serviceId': 'peka_b40_clinic_search', // Fallback
        'confidence': 0.5,
        'language': language,
      };
    } catch (e) {
      print('Intent detection error: $e');
      return {
        'serviceId': null,
        'confidence': 0.0,
        'language': language,
      };
    }
  }

  /// Build system prompt with context for the AI assistant
  String _buildSystemPrompt(Service service, User user, String language) {
    final isMs = language == 'ms';

    String basePrompt = isMs
        ? '''
Anda adalah Pembantu Perkhidmatan Kerajaan Malaysia yang mesra dan membantu.
Nama pengguna: ${user.name}
Bahasa pilihan: Bahasa Melayu

Perkhidmatan semasa: ${service.title}
Penerangan: ${service.description}

Tugasan anda:
1. Bantu pengguna dengan ${service.title}
2. Tanya soalan yang relevan untuk mengumpul maklumat yang diperlukan
3. Berikan maklum balas yang jelas dan ringkas
4. Gunakan bahasa yang mudah difahami
5. Bersikap sabar dan mesra

Maklumat yang diperlukan untuk permohonan ini:
${service.requiredFields.join(', ')}

Sentiasa bertanya satu soalan pada satu masa. Jangan terlalu teknikal.
'''
        : '''
You are a friendly and helpful Malaysian Government Services Assistant.
User name: ${user.name}
Preferred language: English

Current service: ${service.getTitle('en')}
Description: ${service.getDescription('en')}

Your tasks:
1. Help users with ${service.getTitle('en')}
2. Ask relevant questions to gather required information
3. Provide clear and concise feedback
4. Use simple, easy-to-understand language
5. Be patient and friendly

Required information for this application:
${service.requiredFields.join(', ')}

Always ask one question at a time. Don't be too technical.
''';

    // Add service-specific context
    if (service.serviceId == 'peka_b40_clinic_search') {
      final clinicList = isMs
          ? '''
KLINIK DEMO TERSEDIA (3 klinik):
1. KLINIK DR. HALIM SDN BHD - Melaka (Taman Sinn, Jalan Semabok)
2. ALPRO CLINIC - Muar, Johor (Kampung Kenangan Tun Dr Ismail)
3. Clinic Ramani - Port Dickson, Negeri Sembilan (Taman Ria)
'''
          : '''
DEMO CLINICS AVAILABLE (3 clinics):
1. KLINIK DR. HALIM SDN BHD - Melaka (Taman Sinn, Jalan Semabok)
2. ALPRO CLINIC - Muar, Johor (Kampung Kenangan Tun Dr Ismail)
3. Clinic Ramani - Port Dickson, Negeri Sembilan (Taman Ria)
''';

      basePrompt += isMs
          ? '''

Ciri-ciri khas untuk perkhidmatan ini:
- Cari klinik PEKA B40 berdasarkan lokasi pengguna
- Tunjukkan jarak dari lokasi semasa
- Tawarkan navigasi menggunakan Google Maps
- Boleh hubungi klinik terus atau buat temujanji
- Klinik PEKA B40 menawarkan pemeriksaan kesihatan percuma untuk golongan B40

$clinicList

PENTING:
- Tanya pengguna di negeri mana mereka tinggal (Melaka, Johor, atau Negeri Sembilan)
- Jika pengguna di luar 3 negeri ini, beritahu: "Maaf, kawasan anda terlalu jauh dari klinik demo yang tersedia. Klinik demo hanya ada di Melaka, Johor, dan Negeri Sembilan."
- Jika dalam kawasan, tunjukkan klinik yang berdekatan dengan butiran lengkap (nama, alamat, telefon)
- Tawarkan untuk navigasi Google Maps atau hubungi klinik
'''
          : '''

Special features for this service:
- Find PEKA B40 clinics based on user location
- Show distance from current location
- Offer navigation using Google Maps
- Can call clinic directly or book appointments
- PEKA B40 clinics offer free health screenings for B40 group

$clinicList

IMPORTANT:
- Ask user which state they live in (Melaka, Johor, or Negeri Sembilan)
- If user is outside these 3 states, say: "Sorry, your area is too far from the demo clinics. Demo clinics are only available in Melaka, Johor, and Negeri Sembilan."
- If in coverage area, show nearby clinic with full details (name, address, phone)
- Offer Google Maps navigation or call clinic
''';
    } else if (service.serviceId == 'peka_b40_eligibility_check') {
      basePrompt += isMs
          ? '''

Ciri-ciri khas untuk perkhidmatan ini:
- Semak kelayakan B40 menggunakan data MyDigitalID
- Pengesahan automatik berdasarkan pendapatan isi rumah
- Jika layak, tawarkan untuk mendaftar terus ke program PEKA B40
- Kriteria kelayakan: Pendapatan isi rumah di bawah RM4,850 sebulan

Pengguna ini ${user.mydigitalidLinked ? 'SUDAH' : 'BELUM'} menghubungkan MyDigitalID.
'''
          : '''

Special features for this service:
- Check B40 eligibility using MyDigitalID data
- Automatic verification based on household income
- If eligible, offer to enroll directly in PEKA B40 program
- Eligibility criteria: Household income below RM4,850 per month

This user ${user.mydigitalidLinked ? 'HAS' : 'HAS NOT'} linked MyDigitalID.
''';
    } else if (service.serviceId == 'bkoku_application_2025') {
      basePrompt += isMs
          ? '''

Ciri-ciri khas untuk perkhidmatan ini:
- Bantuan kewangan untuk pelajar OKU melanjutkan pengajian ke IPT
- Auto-isi borang menggunakan MyDigitalID
- Sokongan mod luar talian untuk kawasan luar bandar
- Dokumen diperlukan: Sijil perubatan, surat tawaran IPT, sijil akademik

Bantuan BKOKU meliputi:
- Yuran pengajian
- Elaun sara hidup bulanan
- Elaun peralatan khas (jika perlu)

Tanya pengguna tentang jenis kecacatan dan institusi pengajian terlebih dahulu.
'''
          : '''

Special features for this service:
- Financial assistance for disabled students pursuing higher education
- Auto-fill forms using MyDigitalID
- Offline mode support for rural areas
- Required documents: Medical certificate, institution offer letter, academic transcript

BKOKU assistance covers:
- Tuition fees
- Monthly living allowance
- Special equipment allowance (if needed)

Ask the user about their disability type and institution first.
''';
    }

    return basePrompt;
  }

  /// End current conversation and clear chat history
  void endConversation() {
    _currentChat = null;
  }

  /// Check if there's an active conversation
  bool get hasActiveConversation => _currentChat != null;

  /// Search for clinics based on user location (for clinic search service)
  Future<List<Clinic>> searchClinics({String? userCity, String? userState}) async {
    return await _clinicService.searchClinics(
      userCity: userCity,
      userState: userState,
    );
  }

  /// Get formatted clinic list for AI context
  String formatClinicsForAI(List<Clinic> clinics, String language) {
    return _clinicService.formatClinicsForAI(clinics, language);
  }

  /// Check if user location is covered by clinic database
  bool isLocationCovered(String? userState) {
    return _clinicService.isLocationCovered(userState);
  }
}
