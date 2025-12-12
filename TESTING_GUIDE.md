# ISN Accessible Bridge - Complete Testing Guide

## Overview

This guide provides step-by-step instructions to test all features of the ISN Accessible Bridge app, including the new Gemini AI integration, clinic search, and MyDigitalID verification.

---

## Prerequisites

1. **Device Setup**
   - Physical device recommended (better speech recognition)
   - Microphone permissions enabled
   - Internet connection for Gemini AI
   - Location services enabled (for future Maps integration)

2. **App Running**
   ```bash
   flutter run
   ```

3. **Test Personas Available**
   - Puan Aminah (Melaka, Visually Impaired, Voice First)
   - Encik David (Johor, Rural Mode)
   - Cik Sarah (Kuala Lumpur, Visually Impaired)

---

## Test 1: User Selection & Onboarding

### Steps:

1. **Launch App**
   - App should open to User Selection screen
   - Should see 3 persona cards

2. **Select Puan Aminah**
   - Tap on "Puan Aminah" card
   - Verify card shows:
     - Name: Puan Aminah
     - IC: XXXXXX-01-1234 (redacted)
     - Location: Kg. Seri Aman
     - Accessibility icons (eye, microphone)

3. **Navigate to My Applications**
   - After selection, screen should show "My Applications" (previously onboarding_voice_screen)
   - Should see list of applications or empty state

### Expected Results:
- ✅ 3 persona cards displayed
- ✅ Card selection works
- ✅ Navigation to My Applications successful
- ✅ User data preserved (check name in app bar)

---

## Test 2: Home Screen & Navigation

### Steps:

1. **View Home Screen**
   - Tap "Home" in bottom navigation
   - Should see:
     - Welcome banner with user name
     - 3 Quick Action cards
     - Service categories
     - Recent applications (if any)

2. **Test Bottom Navigation**
   - Tap "Home" → Home screen
   - Tap "Services" → Service list
   - Tap "Profile" → Profile screen
   - Tap "Settings" → Settings screen

3. **Test Quick Actions**
   - **Apply for Service**: Should navigate to Services tab
   - **My Applications**: Should push to My Applications screen
   - **Voice Search**: Should show "Coming soon" snackbar

### Expected Results:
- ✅ Welcome message shows user name
- ✅ All navigation tabs work
- ✅ Quick Actions navigate correctly
- ✅ Voice Search shows coming soon message

---

## Test 3: Service List (New Services)

### Steps:

1. **Navigate to Services Tab**
   - Tap "Services" in bottom navigation

2. **Verify 3 New Services Displayed**
   - Should see service cards for:
     1. **Carian Klinik PEKA B40** (or English title if user preference is English)
     2. **Semak Kelayakan PEKA B40**
     3. **Permohonan BKOKU 2025**

3. **Check Service Card Details**
   - Each card should show:
     - Icon (hospital, verified_user, school)
     - Title in user's language
     - Description
     - Category badges
     - Estimated days (if applicable)

4. **Tap a Service Card**
   - Should navigate to service detail or voice assistant
   - (Implementation depends on current routing)

### Expected Results:
- ✅ 3 new services displayed (no old services)
- ✅ Icons display correctly:
  - PEKA B40 Clinic Search: 🏥 local_hospital
  - PEKA B40 Eligibility: ✅ verified_user
  - BKOKU Application: 🎓 school
- ✅ Bilingual titles work (switch user language to test)

---

## Test 4: Voice Assistant - PEKA B40 Clinic Search

### Prerequisites:
- **Recommended Persona**: Puan Aminah (Melaka)
- **Microphone permission**: Granted

### Steps:

#### 4.1 Start Voice Assistant

1. Navigate to Services tab
2. Tap "Carian Klinik PEKA B40" service
3. Should launch Voice Assistant Screen
4. Wait for initial AI greeting (2-3 seconds)

#### 4.2 Test Scenario 1: User in Melaka (Coverage Area)

**Test Script (Malay)**:
```
[AI greets]: "Selamat datang Puan Aminah..."

User (tap mic & say): "Saya nak cari klinik PEKA B40"

[AI asks]: "Boleh beritahu saya di negeri mana anda tinggal?"

User: "Saya di Melaka"

[AI responds with clinic details]:
- KLINIK DR. HALIM SDN BHD
- Address: MT 254 TAMAN SINN, JALAN SEMABOK, 75050 Melaka
- Phone: 06-2841199
- Offers navigation/call options

User: "Boleh bagi link Google Maps?"

[AI provides]: https://maps.app.goo.gl/77nDrK7Wa1ay4TvB7
```

**Verify**:
- ✅ AI greeting in Malay
- ✅ Speech-to-text captures "cari klinik"
- ✅ AI asks for location
- ✅ AI shows correct Melaka clinic
- ✅ Full address and phone displayed
- ✅ Google Maps link provided
- ✅ Text-to-speech works (AI speaks)

#### 4.3 Test Scenario 2: User Outside Coverage (Kuala Lumpur)

**Test Script (English)**:
```
User (switch to Cik Sarah - KL user)

User: "I need to find PEKA B40 clinic"

[AI asks]: "Sure! Which state do you live in?"

User: "Kuala Lumpur"

[AI responds]: "Sorry, your area is too far from the demo clinics.
Demo clinics are only available in Melaka, Johor, and Negeri Sembilan."
```

**Verify**:
- ✅ AI responds in English (Cik Sarah's preference)
- ✅ AI politely says "too far"
- ✅ Lists coverage states (Melaka, Johor, N9)
- ✅ No clinic details shown

#### 4.4 Test Scenario 3: User in Johor

**Test Script**:
```
User (Encik David - Johor)

User: "Nak cari klinik dekat Muar"

[AI shows]: ALPRO CLINIC
- Address: NO 29-5, JALAN PESTA 1/2, Muar
- Phone: 013-9724828
- Maps: https://maps.app.goo.gl/8QCxfsjdadT8Mj5V9
```

**Verify**:
- ✅ AI understands "Muar" is in Johor
- ✅ Shows ALPRO CLINIC (Johor clinic)
- ✅ Provides mobile number format (013-)

### Expected Results:
- ✅ Voice recognition works
- ✅ AI understands intent (clinic search)
- ✅ Non-scripted responses (natural conversation)
- ✅ Correct clinic shown based on state
- ✅ "Too far" message for uncovered areas
- ✅ Google Maps links provided
- ✅ TTS speaks responses

### Common Issues & Solutions:

**Issue**: Speech recognition not working
- **Solution**: Check microphone permission, use physical device, speak clearly

**Issue**: AI not responding
- **Solution**: Check internet connection, verify Gemini API key is valid

**Issue**: Wrong language
- **Solution**: Change user's preferred_language in user selection

---

## Test 5: Voice Assistant - PEKA B40 Eligibility Check

### Prerequisites:
- **Recommended Persona**: Puan Aminah
- **MyDigitalID**: Will be simulated

### Steps:

#### 5.1 Start Eligibility Check

1. Navigate to Services tab
2. Tap "Semak Kelayakan PEKA B40"
3. Voice Assistant launches
4. Wait for greeting

#### 5.2 Test MyDigitalID Verification

**Test Script (Malay)**:
```
User: "Saya nak check kelayakan B40"

[AI asks]: "Untuk menyemak kelayakan, kita perlu gunakan MyDigitalID.
Adakah anda bersedia untuk sahkan identiti?"

User: "Ya, saya bersedia"

[System shows]: MyDigitalID Verification Screen
```

#### 5.3 Test Verification Screen

**On Verification Screen**:

1. **Verify UI Elements**:
   - ✅ User info preview (Name, IC, Address)
   - ✅ "Verify with MyDigitalID" button
   - ✅ "Skip (Demo)" button
   - ✅ Demo mode notice (orange banner)
   - ✅ "What will be verified?" expansion

2. **Test Verify Button**:
   - Tap "Verify with MyDigitalID"
   - Should show loading (2 seconds)
   - Returns to Voice Assistant
   - AI receives mock data (income: RM3,500)

3. **AI Eligibility Response**:
   ```
   [AI says]: "Berdasarkan MyDigitalID, pendapatan isi rumah anda RM3,500 sebulan.
   Anda LAYAK untuk program PEKA B40! (had kelayakan: RM4,850)
   Adakah anda ingin mendaftar sekarang?"
   ```

4. **Test Skip Button**:
   - Restart service
   - When verification screen appears, tap "Skip (Demo)"
   - Returns to Voice Assistant
   - AI should ask for manual income input

### Expected Results:
- ✅ MyDigitalID screen appears
- ✅ User info preview correct
- ✅ Verify button simulates 2s delay
- ✅ Mock data returns: income = 3500
- ✅ AI calculates: 3500 < 4850 = ELIGIBLE ✅
- ✅ Skip button works (returns without data)
- ✅ AI handles both verified and skipped scenarios

---

## Test 6: Voice Assistant - BKOKU Application

### Prerequisites:
- **Recommended Persona**: Any
- **Service**: Permohonan BKOKU 2025

### Steps:

#### 6.1 Start BKOKU Application

1. Navigate to Services
2. Tap "Permohonan BKOKU 2025"
3. Voice Assistant launches

#### 6.2 Test Auto-Fill Flow

**Test Script**:
```
User: "Saya nak mohon BKOKU"

[AI asks]: "Apa jenis kecacatan anda?"

User: "Masalah penglihatan"

[AI asks]: "Di institusi mana anda belajar?"

User: "Universiti Malaya"

[AI says]: "Baik, saya akan isi maklumat peribadi dari MyDigitalID anda.
Nama: Puan Aminah
IC: XXXXXX-01-1234
Alamat: Kg. Seri Aman

Seterusnya, kita perlu upload dokumen:
1. Sijil perubatan
2. Surat tawaran IPT
3. Sijil akademik

Adakah dokumen sudah bersedia?"
```

#### 6.3 Test Offline Mode (Rural User)

**Test with Encik David (Rural Mode enabled)**:
```
User (Encik David): "Saya di kawasan luar bandar, internet tidak stabil"

[AI responds]: "Tidak mengapa! Sistem kami sokong mod luar talian.
Anda boleh isi permohonan sekarang, dan ia akan disegerakkan automatik
bila sambungan internet kembali."
```

### Expected Results:
- ✅ AI asks about disability type
- ✅ AI asks about institution
- ✅ AI mentions MyDigitalID auto-fill
- ✅ AI lists required documents
- ✅ AI acknowledges offline mode for rural users
- ✅ Natural conversation flow (not scripted)

---

## Test 7: My Applications Screen

### Steps:

1. **Navigate to My Applications**
   - From Home: Tap "My Applications" Quick Action
   - OR: From User Selection: Select user → Goes to My Applications

2. **View Application List**
   - Should see existing applications from Firestore
   - Each card shows:
     - Service title
     - Status badge (Submitted, Processing, Approved, Rejected)
     - Submission date
     - Application ID

3. **Test Empty State**
   - If no applications, should see:
     - Icon (empty state)
     - Message "No applications yet"

4. **Test Sync Queue**
   - If offline applications exist, should see:
     - Orange banner at top
     - "X application(s) waiting to sync"

5. **Tap Refresh Button**
   - Top-right refresh icon
   - Should reload data from Firestore

### Expected Results:
- ✅ Application cards displayed (if data exists)
- ✅ Status badges color-coded
- ✅ Empty state shows if no applications
- ✅ Sync queue indicator works
- ✅ Refresh reloads data

---

## Test 8: Firestore Integration

### Steps:

1. **Check Firestore Console**
   - Open Firebase Console
   - Navigate to Firestore Database
   - Check `applications` collection

2. **Verify Existing Data**
   - Should see 6 demo applications
   - Each document has:
     - `service_id`
     - `submitted_at`
     - `status`
     - `filled_data`

3. **Test Real-Time Updates**
   - In Firebase Console, change a document's status
   - App should update automatically (StreamBuilder)
   - Check My Applications screen updates

4. **Test Security Rules**
   - Only authenticated users can read/write
   - Rules deployed correctly

### Expected Results:
- ✅ Applications visible in Firestore
- ✅ Real-time sync works
- ✅ Security rules allow anonymous auth
- ✅ No permission errors

---

## Test 9: Offline Mode (Rural Scenario)

### Prerequisites:
- **Persona**: Encik David (Rural Mode enabled)

### Steps:

1. **Simulate Offline**
   - Turn on Airplane Mode on device
   - OR: Disconnect WiFi/Data

2. **Submit Application**
   - Try to submit via Voice Assistant
   - Application should queue locally

3. **Check Sync Queue**
   - Navigate to My Applications
   - Should see orange banner: "X application(s) waiting to sync"

4. **Restore Connection**
   - Turn off Airplane Mode
   - App should auto-sync in background

5. **Verify Firestore**
   - Check Firebase Console
   - Queued application should appear

### Expected Results:
- ✅ Offline submission queues locally
- ✅ Sync indicator shows pending count
- ✅ Auto-sync when connection restored
- ✅ Application appears in Firestore
- ✅ Sync queue clears

---

## Test 10: Accessibility Features

### Test 10.1: Voice-First Mode (Puan Aminah)

**Steps**:
1. Select Puan Aminah (voice_first: true)
2. All screens should emphasize voice input
3. TTS should speak important messages
4. Voice button prominently displayed

**Verify**:
- ✅ Voice Assistant activates automatically
- ✅ TTS speaks AI responses
- ✅ Large microphone button
- ✅ Visual feedback during listening

### Test 10.2: Visually Impaired Mode (Puan Aminah / Cik Sarah)

**Steps**:
1. Select user with visually_impaired: true
2. Check UI adaptations:
   - High contrast colors
   - Larger fonts
   - TTS for all interactions

**Verify**:
- ✅ High contrast theme applied
- ✅ Text is larger
- ✅ Screen reader compatible
- ✅ TTS guidance

### Test 10.3: Rural Mode (Encik David)

**Steps**:
1. Select Encik David (rural_mode: true)
2. Offline capabilities emphasized
3. Sync queue prominently shown

**Verify**:
- ✅ Offline submission works
- ✅ Sync queue visible
- ✅ Auto-sync on connection restore

---

## Test 11: Bilingual Support

### Steps:

1. **Test Malay Interface**
   - Select Puan Aminah or Encik David
   - Verify all UI in Bahasa Melayu:
     - Navigation labels
     - Service titles
     - AI responses
     - TTS language

2. **Test English Interface**
   - Select Cik Sarah
   - Verify all UI in English:
     - Navigation labels
     - Service titles
     - AI responses
     - TTS language

3. **Switch Languages Mid-Session**
   - Change user preference in settings (if implemented)
   - OR: Select different user
   - Verify language switches correctly

### Expected Results:
- ✅ Full Malay interface (text + voice)
- ✅ Full English interface (text + voice)
- ✅ No mixed languages
- ✅ Service descriptions translated
- ✅ AI responds in correct language

---

## Test 12: Gemini AI Intelligence

### Test Non-Scripted Responses

**Try unexpected questions**:

1. **Off-topic Question**:
   ```
   User: "What's the weather today?"
   AI should: Politely redirect to service topic
   ```

2. **Clarification**:
   ```
   User: "Can you repeat that?"
   AI should: Repeat previous information naturally
   ```

3. **Multiple Questions**:
   ```
   User: "What clinics are there and how do I get there?"
   AI should: Answer both (clinic list + navigation offer)
   ```

4. **Unclear Input**:
   ```
   User: "Uh... klinik... mana... tak tahu"
   AI should: Ask clarifying question
   ```

### Expected Results:
- ✅ AI handles unexpected questions gracefully
- ✅ Can repeat information when asked
- ✅ Answers multiple questions in one response
- ✅ Asks for clarification when unclear
- ✅ No "I don't understand" failures
- ✅ Maintains conversation context

---

## Test 13: Error Handling

### Test Scenarios:

#### 13.1 No Internet Connection

1. Turn off WiFi/Data
2. Try to use Voice Assistant
3. Should show: "Connection error. Please try again."
4. Should NOT crash

#### 13.2 Microphone Permission Denied

1. Revoke microphone permission
2. Try to use voice input
3. Should show: "Speech recognition not available"
4. Should offer text input alternative (if implemented)

#### 13.3 Gemini API Error

1. Invalid API key scenario (can't test easily)
2. Should show: "Error generating response"
3. Should NOT crash

#### 13.4 Firestore Permission Error

1. If rules not deployed
2. Should show error message
3. Should NOT crash

### Expected Results:
- ✅ Graceful error messages
- ✅ No app crashes
- ✅ User can retry
- ✅ Helpful error descriptions

---

## Test 14: Performance

### Metrics to Check:

1. **Voice Recognition Latency**
   - Time from speaking to transcript display
   - Should be: < 2 seconds

2. **AI Response Time**
   - Time from user input to AI response
   - Should be: 2-5 seconds

3. **TTS Speed**
   - Natural speech rate
   - Not too fast or slow

4. **Screen Transitions**
   - Navigation should be smooth
   - No janky animations

5. **Firestore Sync**
   - Real-time updates should be instant
   - < 1 second delay

### Expected Results:
- ✅ Voice recognition: < 2s
- ✅ AI response: 2-5s
- ✅ TTS: Natural speed (0.5 rate)
- ✅ Smooth UI transitions
- ✅ Fast Firestore sync

---

## Test 15: End-to-End Scenarios

### Scenario 1: Complete Clinic Search Journey

1. Launch app → Select Puan Aminah
2. Home → Services → PEKA B40 Clinic Search
3. Voice: "Saya nak cari klinik"
4. Voice: "Saya di Melaka"
5. AI shows KLINIK DR. HALIM
6. Request Google Maps link
7. Click link → Opens Google Maps ✅
8. Return to app
9. Request to call clinic
10. AI provides phone number
11. End conversation

### Scenario 2: Complete Eligibility Check Journey

1. Launch app → Select Puan Aminah
2. Services → PEKA B40 Eligibility Check
3. Voice: "Check kelayakan B40"
4. AI asks for verification
5. Confirm verification
6. MyDigitalID screen appears
7. Tap "Verify with MyDigitalID"
8. Wait 2 seconds
9. Returns with income: RM3,500
10. AI confirms: ELIGIBLE ✅
11. AI offers enrollment
12. Complete

### Scenario 3: Offline Application (Rural)

1. Select Encik David
2. Turn on Airplane Mode
3. Services → BKOKU Application
4. Fill application via voice
5. Submit application
6. Check My Applications
7. See "1 application waiting to sync"
8. Turn off Airplane Mode
9. Wait 5 seconds
10. Check My Applications
11. Sync indicator gone
12. Check Firestore Console
13. Application appears ✅

### Expected Results:
- ✅ All scenarios complete without errors
- ✅ Natural conversation flows
- ✅ Offline mode works perfectly
- ✅ Data syncs to Firestore
- ✅ External links (Maps) work

---

## Quick Test Checklist

Use this checklist for rapid testing:

### Core Features
- [ ] User selection works
- [ ] 3 new services displayed
- [ ] Voice Assistant launches
- [ ] Speech-to-text works
- [ ] Text-to-speech works
- [ ] Gemini AI responds naturally

### Clinic Search
- [ ] Melaka → Shows KLINIK DR. HALIM
- [ ] Johor → Shows ALPRO CLINIC
- [ ] N9 → Shows Clinic Ramani
- [ ] KL → Says "too far"
- [ ] Google Maps links work

### MyDigitalID
- [ ] Verification screen appears
- [ ] Verify button works (2s delay)
- [ ] Skip button works
- [ ] Mock data returns (RM3,500)
- [ ] Eligibility calculated correctly

### My Applications
- [ ] Application list displays
- [ ] Firestore data shown
- [ ] Real-time updates work
- [ ] Refresh button works
- [ ] Sync queue indicator shows

### Accessibility
- [ ] Voice-first mode works
- [ ] TTS speaks responses
- [ ] High contrast (visually impaired)
- [ ] Offline mode (rural)

### Bilingual
- [ ] Malay interface complete
- [ ] English interface complete
- [ ] AI responds in correct language

---

## Troubleshooting

### Common Issues

**Issue**: "Permission denied" in Firestore
- **Fix**: Deploy firestore.rules: `firebase deploy --only firestore:rules`

**Issue**: Speech recognition not working
- **Fix**: Use physical device, check mic permission, speak clearly

**Issue**: AI not responding
- **Fix**: Check internet, verify Gemini API key

**Issue**: Services not showing
- **Fix**: Check assets/seed/mygov_seed.json loaded correctly

**Issue**: Wrong language
- **Fix**: Check user's preferred_language in seed data

---

## Test Report Template

After testing, document results:

```
## Test Report - [Date]

### Environment
- Device: [Physical/Emulator]
- OS: [Android/iOS version]
- Flutter: [Version]

### Test Results

#### Passed ✅
- [List passed tests]

#### Failed ❌
- [List failed tests with details]

#### Blocked 🚫
- [List blocked tests with reasons]

### Issues Found
1. [Issue description]
   - Steps to reproduce
   - Expected vs Actual
   - Severity: [Critical/High/Medium/Low]

### Recommendations
- [Suggested fixes or improvements]
```

---

## Summary

This testing guide covers:
- ✅ 15 comprehensive test scenarios
- ✅ 3 end-to-end user journeys
- ✅ Quick test checklist
- ✅ Troubleshooting guide
- ✅ Performance metrics
- ✅ Error handling verification

**Total Test Cases**: 50+

**Estimated Testing Time**: 2-3 hours for complete testing

**Priority Tests** (for quick demo):
1. Clinic Search (Melaka user)
2. Clinic Search (KL user - too far)
3. MyDigitalID verification
4. Eligibility check
5. My Applications list

**Ready to impress judges!** 🚀🇲🇾
