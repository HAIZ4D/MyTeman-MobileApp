# Quick Test Reference Card

## 🚀 Fast Testing Commands

```bash
# Run the app
flutter run

# Check for errors
flutter analyze

# Run tests
flutter test

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Hot reload (in running app)
Press 'r' in terminal

# Hot restart (in running app)
Press 'R' in terminal
```

---

## 👥 Test Personas Quick Reference

| Name | Location | Language | Special Features | Use For Testing |
|------|----------|----------|------------------|----------------|
| **Puan Aminah** | Melaka | Malay | Voice First, Visually Impaired | ✅ Clinic Search (Melaka), Voice Features |
| **Encik David** | Muar, Johor | Malay | Rural Mode | ✅ Clinic Search (Johor), Offline Mode |
| **Cik Sarah** | Kuala Lumpur | English | Visually Impaired | ✅ Clinic Search (Too Far), English UI |

---

## 🏥 Clinic Test Scripts (Copy-Paste)

### Test 1: Melaka User (Should Find Clinic)
```
1. Select: Puan Aminah
2. Navigate: Services → PEKA B40 Clinic Search
3. Say: "Saya nak cari klinik"
4. Say: "Saya di Melaka"
✅ Expect: KLINIK DR. HALIM SDN BHD shown
```

### Test 2: Johor User (Should Find Clinic)
```
1. Select: Encik David
2. Navigate: Services → PEKA B40 Clinic Search
3. Say: "Nak cari klinik"
4. Say: "Muar, Johor"
✅ Expect: ALPRO CLINIC shown
```

### Test 3: KL User (Should Say Too Far)
```
1. Select: Cik Sarah
2. Navigate: Services → PEKA B40 Clinic Search
3. Say: "Find clinic"
4. Say: "Kuala Lumpur"
✅ Expect: "Sorry, your area is too far..."
```

---

## ✅ MyDigitalID Test Script

```
1. Select: Any user
2. Navigate: Services → PEKA B40 Eligibility Check
3. Say: "Check kelayakan B40"
4. Confirm verification
5. Tap: "Verify with MyDigitalID"
6. Wait: 2 seconds
✅ Expect: Returns RM3,500 income → ELIGIBLE
```

---

## 🎤 Voice Commands Cheat Sheet

### Malay Commands
| Intent | What to Say |
|--------|------------|
| Clinic Search | "Saya nak cari klinik" / "Cari klinik PEKA B40" |
| Eligibility | "Saya nak check kelayakan" / "Semak kelayakan B40" |
| BKOKU | "Nak mohon BKOKU" / "Bantuan pelajar OKU" |
| Location | "Saya di [Melaka/Johor/KL]" |
| Repeat | "Boleh ulang?" |

### English Commands
| Intent | What to Say |
|--------|------------|
| Clinic Search | "I need to find clinic" / "Find PEKA B40 clinic" |
| Eligibility | "Check eligibility" / "Am I eligible for B40" |
| BKOKU | "Apply for BKOKU" / "Disabled student aid" |
| Location | "I'm in [Melaka/Johor/KL]" |
| Repeat | "Can you repeat?" |

---

## 📋 Quick Checklist (5 Minutes)

### Must-Test Features
- [ ] **1 min**: Launch app → Select user → See home screen
- [ ] **1 min**: Services tab → See 3 new services (PEKA B40 x2, BKOKU)
- [ ] **1 min**: Clinic Search → Melaka → Get KLINIK DR. HALIM
- [ ] **1 min**: Clinic Search → KL → Get "too far" message
- [ ] **1 min**: Eligibility → Verify MyDigitalID → Get ELIGIBLE

**Total**: 5 minutes for core demo

---

## 🗺️ Google Maps Links (Click to Test)

| Clinic | State | Link |
|--------|-------|------|
| KLINIK DR. HALIM | Melaka | https://maps.app.goo.gl/77nDrK7Wa1ay4TvB7 |
| ALPRO CLINIC | Johor | https://maps.app.goo.gl/8QCxfsjdadT8Mj5V9 |
| Clinic Ramani | N9 | https://maps.app.goo.gl/ujZAj6PxPwoVsqyG8 |

---

## 🔑 API Keys (for Reference)

```
Gemini AI: AIzaSyAqv3L7kx6CNmUVjGs86jrntEnpXh1QvLk
Google Maps: AIzaSyDQMFexXwECu0CB7JMw9GZwNe89CbiKeCk
```

---

## 🐛 Quick Fixes

### Problem: Voice not working
```bash
# Check permissions in app settings
# Use physical device (not emulator)
# Speak clearly and slowly
```

### Problem: AI not responding
```bash
# Check internet connection
# Verify Gemini API key
# Check console for errors
```

### Problem: Firestore error
```bash
firebase deploy --only firestore:rules
flutter restart
```

### Problem: Services not showing
```bash
# Check assets/seed/mygov_seed.json
# Verify in pubspec.yaml assets section
flutter clean
flutter pub get
flutter run
```

---

## 📊 Expected Results Quick Reference

### Clinic Search Results

| User Says | Location | Expected Clinic | Expected Distance |
|-----------|----------|----------------|-------------------|
| "Melaka" | Melaka | KLINIK DR. HALIM | 5-15 km |
| "Johor" / "Muar" | Johor | ALPRO CLINIC | 5-15 km |
| "Port Dickson" / "N9" | Negeri Sembilan | Clinic Ramani | 5-15 km |
| "KL" / "Kuala Lumpur" | Kuala Lumpur | ❌ Too far | N/A |
| "Penang" / "Kedah" | North | ❌ Too far | N/A |

### Eligibility Check Results

| Household Income | Threshold | Result |
|-----------------|-----------|--------|
| RM3,500 | RM4,850 | ✅ ELIGIBLE |
| Mock data always returns | RM3,500 | ✅ Always eligible in demo |

---

## 🎯 Priority Test Order (for Demo)

### If you only have 10 minutes:

1. **✅ Test 1** (2 min): User selection → Home → Services
2. **✅ Test 2** (3 min): Clinic Search (Melaka) → Show clinic
3. **✅ Test 3** (2 min): Clinic Search (KL) → "Too far"
4. **✅ Test 4** (3 min): MyDigitalID verification → Eligible

### If you have 30 minutes:

Add:
5. Test BKOKU service
6. Test My Applications screen
7. Test offline mode (Encik David)
8. Test bilingual (switch between users)
9. Test voice features (TTS/STT)
10. Test Quick Actions on home

---

## 🎬 Demo Script for Judges (3 Minutes)

```
[0:00-0:30] Introduction
"This is ISN Accessible Bridge - government services made accessible"

[0:30-1:00] Show Personas
"3 test users with different accessibility needs"
- Select Puan Aminah

[1:00-2:00] Demo Clinic Search
"Find PEKA B40 clinics using intelligent voice AI"
- Voice: "Saya nak cari klinik"
- Voice: "Saya di Melaka"
- Show: KLINIK DR. HALIM with Google Maps

[2:00-2:30] Demo Coverage Intelligence
"AI knows coverage areas - watch this:"
- Switch to Cik Sarah (KL)
- Voice: "Find clinic"
- Voice: "Kuala Lumpur"
- Show: "Too far" message (naturally spoken, not scripted!)

[2:30-3:00] Demo MyDigitalID
"Automated eligibility checking"
- Eligibility service
- MyDigitalID verification
- Show: ELIGIBLE result

[3:00] Closing
"Powered by Google Gemini AI - no scripted dialogues!"
"All clinic data is real with working Google Maps links"
"Thank you!"
```

---

## 📱 Screenshots to Capture

For documentation/presentation:

1. ✅ User Selection screen (3 personas)
2. ✅ Home screen (welcome + quick actions)
3. ✅ Services list (3 new services)
4. ✅ Voice Assistant (chat interface)
5. ✅ Clinic details (with Maps link)
6. ✅ "Too far" message
7. ✅ MyDigitalID verification screen
8. ✅ Eligibility result (ELIGIBLE)
9. ✅ My Applications list
10. ✅ Google Maps (opened from app)

---

## 🔄 Reset Demo Data

If you need to reset:

```bash
# Clear app data (Android)
adb shell pm clear com.example.isn_app

# Or uninstall and reinstall
flutter clean
flutter pub get
flutter run
```

---

## ✨ Success Criteria

### Core Features Working ✅
- [x] Voice recognition captures speech
- [x] Gemini AI responds naturally (non-scripted)
- [x] Clinic search shows correct results
- [x] "Too far" message for uncovered areas
- [x] MyDigitalID simulation with skip
- [x] Eligibility calculation correct
- [x] Google Maps links work
- [x] Bilingual support (Malay/English)
- [x] TTS speaks responses
- [x] My Applications displays data

### Judge-Impressing Features 🌟
- [x] Real clinic data (not dummy)
- [x] Intelligent location coverage
- [x] Non-scripted AI conversations
- [x] Production-ready architecture
- [x] Accessibility features
- [x] Offline mode support

---

## 📞 Emergency Contacts (If App Breaks)

```
Issue: App crashes
Fix: flutter clean && flutter pub get && flutter run

Issue: Voice not working
Fix: Use physical device, check permissions

Issue: AI offline
Fix: Check internet, verify API key in gemini_service.dart

Issue: Firestore errors
Fix: firebase deploy --only firestore:rules

Issue: Can't find services
Fix: Verify assets/seed/mygov_seed.json in pubspec.yaml
```

---

**🚀 You're ready to test! Start with the 5-minute checklist, then expand to full testing. Good luck with the demo!** 🇲🇾
