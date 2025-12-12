# MyTeman - Digital Services Made Accessible

> A voice-first mobile application making government services accessible to all Malaysians.

## 🌟 Live Demo

**https://isn-accessible-bridge.web.app**

## Project Overview

MyTeman is a Flutter application that makes government services accessible through voice commands, automatic accessibility features, and MyDigitalID integration. Designed for elderly users, visually impaired citizens, and anyone who finds traditional apps complex.

## Features

- **Voice-First Onboarding**: Natural language voice interaction for government service applications
- **Visually Impaired Mode**: High contrast UI with TTS guidance and haptic feedback
- **Rural/Offline Mode**: Offline-first queue system for areas with poor connectivity
- **Simulated MyDigitalID**: Secure authentication with biometric support
- **Intent Mapping**: AI-powered natural language understanding (mock Gemini)

## Tech Stack

- **Frontend**: Flutter (SDK ^3.7.0) with Material Design 3
- **State Management**: Riverpod ^2.6.1
- **Backend**: Firebase Firestore + Storage (or local JSON for offline demo)
- **Voice**:
  - Text-to-Speech: flutter_tts ^4.2.0
  - Speech-to-Text: speech_to_text ^7.1.0
- **Biometric**: local_auth ^2.3.0
- **Storage**: shared_preferences ^2.3.4, sqflite ^2.4.1

## Project Structure

```
isn_app/
├── lib/
│   ├── models/           # Data models (User, Service, Application)
│   ├── services/         # Business logic (MyGOV service layer)
│   ├── screens/          # UI screens
│   ├── widgets/          # Reusable widgets
│   ├── utils/            # Utilities (Intent mapper)
│   ├── config.dart       # App configuration
│   ├── app.dart          # Main app widget
│   └── main.dart         # Entry point
├── assets/
│   ├── intent_mapping.json    # NLP patterns
│   └── seed/
│       └── mygov_seed.json   # Demo data
└── test/                 # Unit and widget tests
```

## Getting Started

### Prerequisites

- Flutter SDK (^3.7.0)
- Dart SDK (^3.7.0)
- Android Studio / Xcode / VS Code
- Git

### Installation

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

### Configuration

The app can run in two modes:

1. **Local JSON Mode** (default):
   - Set `AppConfig.useFirebase = false` in `lib/config.dart`
   - Uses local seed data from `assets/seed/mygov_seed.json`
   - Perfect for offline development and demos

2. **Firebase Mode**:
   - Set `AppConfig.useFirebase = true` in `lib/config.dart`
   - Configure Firebase project (see Firebase Setup below)

## 👥 Demo Users

The app includes two demo users showcasing different accessibility needs:

### 1. Puan Aminah (Elderly, Visually Impaired)
- **Age**: 77 years old
- **Location**: Kg. Seri Aman, Kedah
- **Language**: Bahasa Melayu
- **PEKA B40 Eligibility**: ✅ Eligible
- **Features**: Voice-first interface, TTS guidance, high contrast mode
- **Use Case**: Checking eligibility for PEKA B40 assistance

### 2. Ahmad bin Abdullah (Student with Disability)
- **Age**: 23 years old
- **Location**: Taman Universiti, Skudai, Johor
- **Language**: Bahasa Melayu
- **PEKA B40 Eligibility**: ❌ Not Eligible (age requirement)
- **Features**: Voice commands, BKOKU scholarship access
- **Use Case**: Applying for BKOKU disability student scholarship

## 🎤 Voice Commands

Try these voice commands after logging in:

### Service Selection
- Say **"eligibility"** or **"kelayakan"** → Opens PEKA B40 Eligibility Check
- Say **"clinic"** or **"klinik"** → Opens Clinic Search
- Say **"BKOKU"** or **"scholarship"** → Opens BKOKU Application

### Navigation
- Say **"home"**, **"services"**, **"profile"**, or **"settings"** to navigate

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Building for Production

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## Accessibility Features

This app follows WCAG 2.1 AA guidelines:

- ✅ Minimum 48x48 dp touch targets
- ✅ High contrast mode support
- ✅ Screen reader compatible
- ✅ Voice navigation
- ✅ Haptic feedback for important actions
- ✅ Keyboard navigation support
- ✅ Adaptable font sizes

## Security & Privacy

- Simulated MyDigitalID with minimal PII
- Biometric consent with timestamp tracking
- Firebase security rules restrict access to owner only
- Client-side image compression before upload
- Redacted IC numbers in demo data (XXXXXX-XX-XXXX)

## License

Copyright © 2025 ISN Team. All rights reserved.
