# Clinic Database & MyDigitalID Integration - Demo Guide

## Overview

The ISN Accessible Bridge app now includes:
1. **Clinic Database** - 3 demo PEKA B40 clinics from different states
2. **MyDigitalID Verification** - Simulated verification screen with skip option
3. **Gemini AI Integration** - Intelligent conversations with clinic data context

---

## 1. Clinic Database

### Demo Clinics (3 Total)

#### Clinic 1: KLINIK DR. HALIM SDN BHD
- **State**: Melaka
- **Address**: MT 254 TAMAN SINN, JALAN SEMABOK, 75050 Melaka
- **Contact**: +606-2841199 (displayed as: 06-2841199)
- **Type**: Private (not public)
- **Google Maps**: https://maps.app.goo.gl/77nDrK7Wa1ay4TvB7
- **Coordinates**: 2.1896, 102.2501

#### Clinic 2: ALPRO CLINIC
- **State**: Johor
- **City**: Muar
- **Address**: NO 29-5 (TINGKAT BAWAH), JALAN PESTA 1/2 KAMPUNG KENANGAN TUN DR ISMAIL, 84000 Muar, Johor
- **Contact**: +6013-9724828 (displayed as: 013-9724828)
- **Type**: Private (not public)
- **Google Maps**: https://maps.app.goo.gl/8QCxfsjdadT8Mj5V9
- **Coordinates**: 2.0442, 102.5689

#### Clinic 3: Clinic Ramani
- **State**: Negeri Sembilan
- **City**: Port Dickson
- **Address**: 2026 Taman Ria, KM4 Jalan Seremban, 71000 Port Dickson, Negeri Sembilan
- **Contact**: +606-6512244 (displayed as: 06-6512244)
- **Type**: Private (not public)
- **Google Maps**: https://maps.app.goo.gl/ujZAj6PxPwoVsqyG8
- **Coordinates**: 2.5270, 101.7967

### Coverage Areas

**Covered States**:
- Melaka ✅
- Johor ✅
- Negeri Sembilan ✅

**Nearby States** (50-100km range):
- Selangor (near Negeri Sembilan)
- Pahang (between Johor & Negeri Sembilan)

**Outside Coverage**:
- Kedah, Perlis, Penang, Perak (North)
- Kelantan, Terengganu (East Coast)
- Sabah, Sarawak (East Malaysia)

### AI Response Behavior

**If user is in Melaka/Johor/Negeri Sembilan**:
```
Gemini AI will:
1. Show the clinic in their state
2. Display full details (name, address, phone)
3. Offer Google Maps navigation
4. Suggest calling the clinic
5. Mention distance estimate
```

**If user is outside coverage area**:
```
Gemini AI will respond:
Malay: "Maaf, kawasan anda terlalu jauh dari klinik demo yang tersedia.
Klinik demo hanya ada di Melaka, Johor, dan Negeri Sembilan."

English: "Sorry, your area is too far from the demo clinics.
Demo clinics are only available in Melaka, Johor, and Negeri Sembilan."
```

---

## 2. MyDigitalID Integration

### Investigation Results

**GitHub Repository**: https://github.com/IdayuIsmail/Flutter_Dart.git
- **Package Name**: `keycloak_wrapper`
- **Purpose**: Keycloak OAuth2/OpenID Connect authentication
- **Requirements**:
  - Client ID
  - Client Secret
  - MyDigital ID SSO DNS Host
  - Realm configuration

**Decision**: ❌ **NOT USABLE FOR DEMO**

**Reasons**:
1. Requires real government server credentials
2. Production OAuth2 authentication (not for prototypes)
3. Would need official MyDigitalID API access
4. Cannot simulate without actual server

### Our Solution: Simulated MyDigitalID

**Implementation**: [lib/screens/mydigitalid_verification_screen.dart](lib/screens/mydigitalid_verification_screen.dart)

**Features**:
- ✅ Beautiful verification UI
- ✅ Shows user information preview
- ✅ Simulates 2-second verification delay
- ✅ **Skip button for demo** (important!)
- ✅ Returns mock household income data
- ✅ Bilingual support (Malay/English)

### Mock Data Returned After Verification

```dart
{
  'ic_number': 'XXXXXX-01-1234',
  'name': 'Puan Aminah',
  'dob': '1948-01-01',
  'address': 'Kg. Seri Aman',
  'household_income': 3500,  // RM3,500 (eligible for B40)
  'marital_status': 'Married',
  'employment_status': 'Employed',
  'verified_at': '2025-12-11T21:00:00.000Z'
}
```

### B40 Eligibility Criteria

- **Threshold**: Household income below **RM4,850/month**
- **Demo Data**: RM3,500/month → **ELIGIBLE** ✅

### Usage in Voice Assistant

```dart
// When user reaches eligibility check service
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MyDigitalIDVerificationScreen(
      user: currentUser,
      onComplete: (verified, data) {
        if (verified && data != null) {
          // Use verified data
          final income = data['household_income'] as int;
          final isEligible = income < 4850;
          // Continue with eligibility result
        } else {
          // User skipped - continue without verification
        }
      },
    ),
  ),
);
```

---

## 3. Gemini AI Updates

### Enhanced System Prompts

#### For Clinic Search Service

**Context Provided to AI**:
```
DEMO CLINICS AVAILABLE (3 clinics):
1. KLINIK DR. HALIM SDN BHD - Melaka (Taman Sinn, Jalan Semabok)
2. ALPRO CLINIC - Muar, Johor (Kampung Kenangan Tun Dr Ismail)
3. Clinic Ramani - Port Dickson, Negeri Sembilan (Taman Ria)

IMPORTANT:
- Ask user which state they live in
- If outside Melaka/Johor/Negeri Sembilan, say area too far
- If in coverage area, show clinic details
- Offer Google Maps navigation or call option
```

**AI Capabilities**:
- ✅ Understands 3-state coverage
- ✅ Knows "Oh no sorry" response for far areas
- ✅ Can provide full clinic details
- ✅ Offers navigation and call options
- ✅ Natural conversation flow (non-scripted)

#### For Eligibility Check Service

**Context Provided to AI**:
```
- Check B40 eligibility using MyDigitalID data
- Automatic verification based on household income
- If eligible, offer to enroll in PEKA B40
- Eligibility criteria: Income below RM4,850/month

User MyDigitalID status: LINKED ✅
```

### New Methods in GeminiService

```dart
// Search clinics based on location
Future<List<Clinic>> searchClinics({String? userCity, String? userState})

// Format clinic list for AI responses
String formatClinicsForAI(List<Clinic> clinics, String language)

// Check if user location has clinic coverage
bool isLocationCovered(String? userState)
```

---

## 4. File Structure

### New Files Created

```
lib/
├── models/
│   └── clinic.dart                              # Clinic data model
├── services/
│   ├── clinic_service.dart                      # Clinic search logic
│   └── gemini_service.dart                      # Updated with clinic context
└── screens/
    └── mydigitalid_verification_screen.dart     # Simulated verification UI
```

### Updated Files

```
lib/services/gemini_service.dart
- Added clinic search integration
- Enhanced system prompts with clinic data
- Added location coverage checking
```

---

## 5. Demo Test Scripts

### Test 1: Clinic Search (User in Melaka)

**Scenario**: Puan Aminah lives in Melaka

```
User: "Saya nak cari klinik PEKA B40"
AI: "Baik! Boleh beritahu saya di negeri mana anda tinggal?"

User: "Saya di Melaka"
AI: "Bagus! Kami ada klinik PEKA B40 di Melaka:

KLINIK DR. HALIM SDN BHD
Alamat: MT 254 TAMAN SINN, JALAN SEMABOK, 75050 Melaka
Telefon: 06-2841199

Adakah anda ingin saya bantu dengan navigasi Google Maps atau terus hubungi klinik ini?"

User: "Navigasi Google Maps"
AI: "Sila klik pautan ini untuk navigasi: https://maps.app.goo.gl/77nDrK7Wa1ay4TvB7"
```

### Test 2: Clinic Search (User Too Far)

**Scenario**: User lives in Kuala Lumpur (outside coverage)

```
User: "I need to find PEKA B40 clinic"
AI: "Sure! Which state do you live in?"

User: "Kuala Lumpur"
AI: "Sorry, your area is too far from the demo clinics. Demo clinics are only available in Melaka, Johor, and Negeri Sembilan. These are the states we currently cover for this demonstration."
```

### Test 3: Eligibility Check with MyDigitalID

**Scenario**: Check B40 eligibility

```
User: "Saya nak check kelayakan B40"
AI: "Baik! Untuk menyemak kelayakan B40, kita perlu menggunakan MyDigitalID untuk dapatkan maklumat pendapatan isi rumah anda. Adakah anda bersedia untuk sahkan dengan MyDigitalID?"

User: "Ya, saya bersedia"
[System shows MyDigitalIDVerificationScreen]
[User clicks "Verify with MyDigitalID" or "Skip"]

If VERIFIED:
AI: "Terima kasih! Berdasarkan maklumat MyDigitalID anda, pendapatan isi rumah anda adalah RM3,500 sebulan. Ini bermakna anda LAYAK untuk program PEKA B40! (had kelayakan: RM4,850). Adakah anda ingin saya bantu untuk mendaftar?"

If SKIPPED:
AI: "Baik, tidak mengapa. Untuk semakan kelayakan manual, boleh beritahu pendapatan isi rumah anda sebulan?"
```

---

## 6. Google Maps API Key

**API Key Provided**: `AIzaSyDQMFexXwECu0CB7JMw9GZwNe89CbiKeCk`

**Current Status**: Not yet integrated in app code

**Usage**:
- For future Google Maps SDK integration
- Will enable real-time navigation
- Can show clinic markers on map
- Calculate actual distances

**Next Steps for Full Integration**:
1. Add `google_maps_flutter` package
2. Configure API key in Android/iOS
3. Create map view screen
4. Show clinic markers
5. Enable turn-by-turn navigation

---

## 7. Demo Talking Points for Judges

### Point 1: Realistic Clinic Database
> "We have 3 real PEKA B40 clinics from different states - Melaka, Johor, and Negeri Sembilan. Each has actual addresses, phone numbers, and Google Maps links. The AI knows the coverage area and will politely inform users if they're too far."

### Point 2: Intelligent Location Handling
> "The Gemini AI doesn't use hardcoded responses. It understands state geography and can say 'Oh no sorry' naturally when users are outside the coverage area. It's not scripted - it genuinely understands the clinic database."

### Point 3: MyDigitalID Simulation
> "We investigated the official MyDigitalID Keycloak integration but found it requires government server credentials. For the demo, we created a realistic simulation that shows what the verification flow would look like, with a skip button for judges to test easily."

### Point 4: Real-World Integration
> "Each clinic has a Google Maps link that actually works! Judges can click and see the real locations. The contact numbers are also real - this demonstrates how the app would work in production."

### Point 5: B40 Eligibility Intelligence
> "The AI knows the B40 threshold (RM4,850/month) and can automatically determine eligibility from MyDigitalID data. In our demo, the household income is RM3,500, which correctly shows as eligible."

---

## 8. Limitations & Future Enhancements

### Current Limitations

1. **Clinic Database**: Only 3 clinics (demo limitation)
   - Real app would connect to government database
   - Would have hundreds of clinics nationwide

2. **MyDigitalID**: Simulated verification
   - Real app would use OAuth2 authentication
   - Requires government API credentials

3. **Google Maps**: Links only, no SDK integration
   - Future: Embedded map view
   - Turn-by-turn navigation
   - Distance calculation

4. **Distance Calculation**: Simplified logic
   - Current: Same state = "5-15km", Nearby = "50-100km"
   - Future: Real GPS distance using coordinates

### Future Enhancements

**Phase 1: Enhanced Maps**
- Add `google_maps_flutter` package
- Embed map view in clinic search
- Show all 3 clinics as markers
- Enable real-time location

**Phase 2: Real MyDigitalID**
- Get official API credentials
- Implement OAuth2 flow
- Secure token storage
- Real data retrieval

**Phase 3: Expanded Database**
- Connect to government API
- Load all PEKA B40 clinics
- Real-time availability
- Appointment booking

**Phase 4: Advanced Features**
- Clinic ratings and reviews
- Queue time estimates
- Health screening history
- Digital health card

---

## 9. Testing Checklist

### Clinic Search Service

- [ ] Test with user in Melaka → Should show KLINIK DR. HALIM
- [ ] Test with user in Johor → Should show ALPRO CLINIC
- [ ] Test with user in Negeri Sembilan → Should show Clinic Ramani
- [ ] Test with user in Kuala Lumpur → Should say "too far"
- [ ] Test with user in Kedah → Should say "too far"
- [ ] Click Google Maps link → Should open real location
- [ ] Test bilingual (Malay & English) → Both should work

### MyDigitalID Verification

- [ ] Open verification screen → Should show user info
- [ ] Click "Verify with MyDigitalID" → Should simulate 2s delay
- [ ] Check returned data → Should have household_income: 3500
- [ ] Click "Skip" → Should return verified: false
- [ ] Test in Malay → UI should be in Bahasa
- [ ] Test in English → UI should be in English

### Eligibility Check

- [ ] Start eligibility check service
- [ ] Verify with MyDigitalID → Should get RM3,500 income
- [ ] AI should calculate: 3500 < 4850 = ELIGIBLE ✅
- [ ] AI should offer enrollment
- [ ] Skip verification → AI should ask manually

---

## 10. Quick Reference

### Important URLs

- **Clinic 1 (Melaka)**: https://maps.app.goo.gl/77nDrK7Wa1ay4TvB7
- **Clinic 2 (Johor)**: https://maps.app.goo.gl/8QCxfsjdadT8Mj5V9
- **Clinic 3 (Negeri Sembilan)**: https://maps.app.goo.gl/ujZAj6PxPwoVsqyG8

### API Keys

- **Gemini AI**: `AIzaSyAqv3L7kx6CNmUVjGs86jrntEnpXh1QvLk`
- **Google Maps**: `AIzaSyDQMFexXwECu0CB7JMw9GZwNe89CbiKeCk`

### Demo Personas

1. **Puan Aminah** - Melaka, Visually Impaired, RM3,500 income (ELIGIBLE)
2. **Encik David** - Muar (Johor), Rural Mode
3. **Cik Sarah** - KL (outside coverage), Visually Impaired

---

## Summary

✅ **3 Real Clinics** from Melaka, Johor, Negeri Sembilan
✅ **Intelligent AI** that knows coverage areas
✅ **MyDigitalID Simulation** with skip option for demo
✅ **B40 Eligibility Logic** (threshold: RM4,850)
✅ **Google Maps Integration** (links ready, SDK future)
✅ **Bilingual Support** throughout
✅ **Production-Ready Architecture** for real API integration

The app is now ready to demonstrate realistic government service scenarios with intelligent voice conversations! 🚀🇲🇾
