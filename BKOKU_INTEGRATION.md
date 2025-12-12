# BKOKU (Financial Assistance for OKU Students) Integration

## Overview

This document describes the BKOKU (Bantuan Kewangan Orang Kurang Upaya) integration in the ISN Accessible Bridge app. BKOKU is a Malaysian government financial assistance program for disabled students pursuing higher education.

## Implementation Summary

The BKOKU integration follows the **Quick Integration (Option A)** approach, leveraging existing infrastructure while adding specialized BKOKU functionality.

## Files Created/Modified

### New Files

1. **lib/models/bkoku_application.dart** (320+ lines)
   - `BkokuApplication` class with complete application data
   - `BkokuDocument` class for document attachments
   - `ApplicationStatus` enum (draft, queued, syncing, submitted, failed, processing, approved, rejected)
   - `AuditEntry` class for audit trail
   - `ConsentRecord` class for MyDigitalID consent tracking
   - Privacy-focused `toRedactedJson()` method for logging

2. **lib/config/bkoku_config.dart** (140+ lines)
   - Environment configuration (Firebase/Mock API toggle)
   - Required fields and documents lists
   - TTS messages in Malay and English
   - Consent text templates
   - Compression settings
   - Security notes for developers

3. **lib/services/bkoku_service.dart** (250+ lines)
   - `buildApplicationFromVault(User)` - Validates OKU status and builds application from MyDigitalID
   - `submitApplication(BkokuApplication, consentId)` - Batch writes to Firestore collections
   - `recordConsent(ConsentRecord)` - Stores consent records
   - Helper methods for TTS messages and document labels

4. **lib/screens/bkoku_application_screen.dart** (560+ lines)
   - Voice-first BKOKU application UI
   - Sequential TTS flow (welcome → consent → auth → autofill → review → submit)
   - Consent dialog with MyDigitalID field/document disclosure
   - Biometric authentication integration
   - Application preview card
   - Message bubble conversation UI

### Modified Files

1. **lib/models/user.dart**
   - Added OKU-specific fields:
     - `bool? okuStatus`
     - `String? okuId` (JKM OKU ID)
     - `String? institution` (University name)
     - `String? enrollmentNo` (Matriculation number)
     - `String? bankAccountNo` (for financial aid disbursement)
     - `String? bankName`
     - `List<StoredDocument>? storedDocuments` (MyDigitalID vault documents)
   - Added `StoredDocument` class for document metadata
   - Updated fromJson, toJson, and copyWith methods

2. **lib/screens/service_list_screen.dart**
   - Added import for `BkokuApplicationScreen`
   - Added routing logic for `bkoku_application_2025` service ID
   - Navigates to BKOKU screen when service is selected

3. **lib/screens/my_applications_screen.dart**
   - Added special display for BKOKU applications (purple info card)
   - Shows institution, enrollment number, OKU ID, document count
   - Added BKOKU service icon and title handling
   - Similar pattern to clinic appointment display

4. **assets/seed/mygov_seed.json**
   - Added test user: Ahmad bin Abdullah (OKU student)
     - OKU status: true
     - OKU ID: JKM-OKU-2023-001234
     - Institution: Universiti Teknologi Malaysia
     - Enrollment No: A20EC0123
     - 4 stored documents (disability cert, matriculation, transcript, bank statement)
   - BKOKU service already existed in seed data

## Data Flow

### 1. User Selection
- User selects Ahmad (OKU student) from user selection screen
- App loads user profile with OKU fields from seed data

### 2. Service Navigation
- User navigates to Services → BKOKU Application 2025
- App routes to `BkokuApplicationScreen`

### 3. Voice-First Flow

```
Welcome → Consent Request → Biometric Auth → Auto-fill → Review → Submit
```

**Step-by-Step:**

1. **Welcome Message** (TTS)
   ```
   MS: "Selamat datang ke permohonan BKOKU. Saya akan bantu anda mengisi borang."
   EN: "Welcome to BKOKU application. I will help you fill the form."
   ```

2. **Consent Request** (TTS + Dialog)
   - TTS announces consent request
   - Dialog shows:
     - Required fields (name, IC, DOB, OKU ID, institution, etc.)
     - Required documents (disability cert, matriculation, transcript, bank statement)
     - Consent text explaining MyDigitalID usage
   - User taps "Agree & Authenticate"

3. **Biometric Authentication**
   - Calls `MyDigitalIDService.authenticateBiometric()`
   - Shows native biometric prompt (fingerprint/face/PIN)
   - Records consent with authentication method

4. **Auto-fill from MyDigitalID Vault**
   - Calls `BkokuService.buildApplicationFromVault(user)`
   - Validates user has `okuStatus == true`
   - Extracts data from user profile
   - Converts stored documents to BKOKU documents
   - Builds `BkokuApplication` with all required data
   - TTS announces completion:
     ```
     MS: "Saya sudah isi borang dan muat naik dokumen dari MyDigitalID anda. Sila semak."
     EN: "I have filled the form and uploaded documents from your MyDigitalID. Please review."
     ```

5. **Application Preview**
   - Shows green info card with:
     - Full name
     - IC number (redacted)
     - OKU ID
     - Institution name
     - Enrollment number
     - Bank details
     - Document count (4 documents)

6. **Submit Application**
   - User taps "Submit Application"
   - Calls `BkokuService.submitApplication(app, consentId)`
   - **Batch write to Firestore:**
     - Collection: `bkoku_applications` (detailed BKOKU data)
     - Collection: `applications` (general app for "My Applications" screen)
     - Both writes are atomic (succeed or fail together)
   - Shows success message
   - Navigates back to home screen

### 4. View in My Applications

- User navigates to "My Applications" from home screen
- App fetches applications from Firestore
- BKOKU applications display with:
  - Purple info card (distinct from blue clinic appointments)
  - School icon
  - Title: "Permohonan BKOKU 2025" / "BKOKU Application 2025"
  - Institution name
  - Enrollment number
  - OKU ID
  - Document count
  - Status badge ("Dihantar" / "Submitted")
  - Application ID

## Firestore Collections

### `bkoku_applications`

Stores detailed BKOKU application data.

```javascript
{
  application_id: "bkoku_1765483602317",
  uid: "user_ahmad",
  user_name: "Ahmad bin Abdullah",
  ic_number: "XXXXXX-04-4567", // Redacted in logs
  oku_id: "JKM-OKU-2023-001234",
  oku_status: "active",
  institution: "Universiti Teknologi Malaysia",
  enrollment_no: "A20EC0123",
  bank_account_no: "1234567890123", // Redacted in logs
  bank_name: "Maybank",
  filled_data: {
    full_name: "Ahmad bin Abdullah",
    dob: "2002-05-15",
    address: "Taman Universiti, Skudai, Johor",
    // ... other fields
  },
  attachments: [
    {
      document_id: "doc_1",
      name: "Sijil OKU",
      type: "disability_cert",
      path: "assets/sample_docs/disability_cert.pdf",
      size_bytes: 0,
      compressed: false,
      uploaded_at: "2025-12-12T05:00:00.000Z"
    },
    // ... 3 more documents
  ],
  status: "submitted",
  created_at: "2025-12-12T05:00:00.000Z",
  submitted_at: "2025-12-12T05:00:30.000Z",
  audit: [
    {
      timestamp: "2025-12-12T05:00:00.000Z",
      action: "created",
      details: "Application initialized"
    },
    {
      timestamp: "2025-12-12T05:00:30.000Z",
      action: "submitted",
      details: "BKOKU application submitted to system",
      metadata: {
        consent_id: "consent_user_ahmad_1765483602317",
        submission_method: "online"
      }
    }
  ],
  consent_id: "consent_user_ahmad_1765483602317",
  bundle_id: null,
  attempt_count: 0
}
```

### `applications`

Stores simplified application data for "My Applications" screen.

```javascript
{
  appId: "app_bkoku_1765483602317",
  serviceId: "bkoku_application_2025",
  uid: "user_ahmad",
  status: "submitted",
  filled_data: {
    institution: "Universiti Teknologi Malaysia",
    enrollment_no: "A20EC0123",
    oku_id: "JKM-OKU-2023-001234",
    bank_name: "Maybank",
    documents_count: 4,
    bkoku_app_id: "bkoku_1765483602317"
  },
  submitted_at: "2025-12-12T05:00:30.000Z",
  audit: [
    {
      timestamp: "2025-12-12T05:00:30.000Z",
      action: "submitted",
      details: "BKOKU application submitted via voice interface"
    }
  ]
}
```

### `bkoku_consents`

Stores MyDigitalID consent records for audit compliance.

```javascript
{
  consent_id: "consent_user_ahmad_1765483602317",
  uid: "user_ahmad",
  timestamp: "2025-12-12T05:00:15.000Z",
  method: "biometric_fingerprint", // or biometric_face, pin
  fields_requested: [
    "name", "ic_number", "dob", "oku_id", "oku_status",
    "institution", "enrollment_no", "bank_account_no", "bank_name"
  ],
  documents_requested: [
    "disability_cert", "matriculation", "transcript", "bank_statement"
  ],
  granted: true,
  consent_text: "Saya memberi kebenaran untuk MyGOV..."
}
```

## Security & Privacy

### Privacy Features

1. **Redacted Logging**
   - `BkokuApplication.toRedactedJson()` method removes sensitive fields
   - IC numbers and bank account numbers replaced with "REDACTED" in logs
   - Never log full sensitive data to console

2. **Consent Recording**
   - Every MyDigitalID access requires explicit consent
   - Consent includes:
     - Timestamp
     - Authentication method used
     - Exact list of fields accessed
     - Exact list of documents accessed
   - Stored in separate `bkoku_consents` collection for audit

3. **Biometric Authentication**
   - Face ID / Fingerprint / PIN required before auto-fill
   - Native platform security
   - Localized prompt messages

### Current Firestore Rules Status

**⚠️ IMPORTANT: Currently OPEN for testing**

```javascript
allow read, write: if true;
```

**Must revert to secure rules after testing:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // General applications
    match /applications/{appId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if false;
    }

    // BKOKU applications
    match /bkoku_applications/{appId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if false;
    }

    // BKOKU consents (user can only read their own)
    match /bkoku_consents/{consentId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && resource.data.uid == request.auth.uid;
      allow update, delete: if false;
    }

    // Services (read-only)
    match /services/{serviceId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Users
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Deploy with:
```bash
firebase deploy --only firestore:rules
```

## Testing Steps

### 1. Hot Restart App
```
Press 'R' in Flutter terminal
```

### 2. Complete BKOKU Flow

1. **Select OKU User**
   - On user selection screen, tap "Ahmad bin Abdullah"
   - Verify OKU status badge shows

2. **Navigate to BKOKU Service**
   - Tap "Services" tab
   - Find "Permohonan BKOKU 2025" service
   - Tap "Apply Now"

3. **Listen to Welcome**
   - Should hear TTS welcome message
   - Message bubble should appear

4. **Grant Consent**
   - Dialog should appear showing required fields and documents
   - Review the consent text
   - Tap "Agree & Authenticate"

5. **Complete Biometric Auth**
   - Native biometric prompt should appear
   - Authenticate with fingerprint/face/PIN
   - Should hear success sound

6. **Review Auto-filled Application**
   - Green preview card should show all data
   - Verify institution: "Universiti Teknologi Malaysia"
   - Verify enrollment: "A20EC0123"
   - Verify OKU ID: "JKM-OKU-2023-001234"
   - Verify documents: "4 documents"
   - Should hear TTS completion message

7. **Submit Application**
   - Tap "Submit Application" button
   - Wait for success message
   - Should navigate back to home screen

8. **View in My Applications**
   - Tap "My Applications" from home screen
   - Should see BKOKU application card with:
     - Purple info section
     - School icon
     - Title: "Permohonan BKOKU 2025"
     - Institution name
     - Enrollment number
     - OKU ID
     - Document count
     - "Dihantar" status badge

9. **Verify Firestore**
   - Open Firebase Console
   - Check `bkoku_applications` collection for new document
   - Check `applications` collection for corresponding record
   - Check `bkoku_consents` collection for consent record

### Expected Console Logs

```
I/flutter: Starting BKOKU application flow for user: user_ahmad
I/flutter: Building BKOKU application from MyDigitalID vault
I/flutter: Consent given: consent_user_ahmad_1765483602317
I/flutter: BKOKU application created: bkoku_1765483602317
I/flutter: Submitting BKOKU application...
I/flutter: BKOKU application submitted successfully!
```

## Architecture Patterns

### Leveraged Existing Infrastructure

1. **State Management**: Riverpod providers
2. **Voice Services**: `VoiceServiceEnhanced` with `speakAndWait()`
3. **Authentication**: `MyDigitalIDService.authenticateBiometric()`
4. **Storage**: Firestore with batch writes
5. **UI Patterns**: Message bubbles, info cards, status badges

### BKOKU-Specific Components

1. **Models**: `BkokuApplication`, `ConsentRecord`
2. **Configuration**: `BkokuConfig` with TTS messages and requirements
3. **Service Layer**: `BkokuService` with vault extraction and submission logic
4. **UI Screen**: `BkokuApplicationScreen` with voice-first flow

## Future Enhancements

### Not Implemented (Out of Scope for Quick Integration)

1. **Offline Queue**
   - Local SQLite storage for pending applications
   - Batch sync when network available
   - Image compression before upload

2. **Node.js Mock Backend**
   - Express server for BKOKU API simulation
   - Application status updates
   - Document verification simulation

3. **Comprehensive Testing**
   - Unit tests for `BkokuService`
   - Widget tests for `BkokuApplicationScreen`
   - Integration tests for full flow

4. **Advanced Features**
   - Application status tracking (processing, approved, rejected)
   - Document re-upload capability
   - Application editing before submission
   - Push notifications for status updates

### Potential Next Steps

If needed for production:

1. Implement offline queue with compression
2. Add status tracking and updates
3. Create comprehensive test suite
4. Add error recovery mechanisms
5. Implement document verification
6. Add analytics for flow completion rates

## Summary

The BKOKU integration successfully demonstrates:

✅ Voice-first application flow
✅ MyDigitalID consent and biometric authentication
✅ Auto-fill from digital identity vault
✅ Dual Firestore storage (specialized + general)
✅ Privacy-focused data handling
✅ Comprehensive audit logging
✅ Bilingual support (Malay/English)
✅ Seamless integration with existing "My Applications" screen

The implementation follows the ISN Accessible Bridge prototype's vision of making government services simple, secure, and accessible to all Malaysians.

---

**Last Updated:** 2025-12-12
**Status:** ✅ Ready for testing
**Next Step:** Secure Firestore rules after testing
