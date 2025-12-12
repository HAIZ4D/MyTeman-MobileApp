# How to Test Firebase Integration - Step by Step

## ✅ What I Fixed

1. **Added My Applications Icon** to the main app navigation
   - Now visible on ALL screens (Home, Services, Profile, Settings)
   - Located in top AppBar next to notifications bell
   - Click to view all submitted applications

2. **Firebase Configuration**
   - firebase_auth package installed
   - Firebase initialized with platform-specific options
   - Anonymous authentication enabled
   - Firestore integration complete

3. **Gradle Issues Fixed**
   - NDK version updated to 27.0.12077973
   - minSdkVersion increased to 23 for Firebase compatibility

## 📱 How to Test - Complete Flow

### Step 1: Launch the App
```bash
flutter run
```

Watch the console for this message (confirms Firebase working):
```
Firebase: Signed in anonymously
```

### Step 2: Select a User
- App will show 3 user personas:
  - **Puan Aminah** (Voice-First + Visually Impaired)
  - **Encik David** (Rural Mode)
  - **Cik Sarah** (Visually Impaired)
- Click any one to proceed

### Step 3: Navigate to Services
After selecting user, you'll see the main app with bottom navigation:
- 🏠 **Home** (Utama)
- 📱 **Services** (Perkhidmatan) ← **Click this!**
- 👤 Profile (Profil)
- ⚙️ Settings (Tetapan)

### Step 4: Select a Service
You'll see 3 available services:
1. **Bantuan Kebajikan Harian** (Daily Welfare Relief)
2. **Permohonan Lesen Perniagaan** (Business Permit)
3. **Biasiswa Merit Universiti 2025** (University Scholarship)

Click any service card.

### Step 5: Fill the Application Form
The ApplicationFormScreen will open with:
- Step indicator at top (e.g., "Step 1 of 3")
- Form fields for that step
- Voice input button (microphone icon) on each field
- **Next** button to proceed to next step
- **Save** button in AppBar to save draft

Fill in the fields:
- Type manually OR
- Click microphone icon for voice input

When on the last step, click **Save** button.

### Step 6: Watch Console Logs
You should see:
```
SyncQueue: Added application app_XXXXX to queue. Queue size: 1
SyncQueue: Connectivity check - isOnline: true, result: [ConnectivityResult.wifi]
SyncQueue: Syncing app_XXXXX to Firestore...
SyncQueue: Successfully synced app_XXXXX to Firestore  ← THIS IS THE KEY LOG!
SyncQueue: Removed application app_XXXXX from queue. Remaining: 0
```

You'll also see a green snackbar:
- **English**: "Application submitted successfully"
- **Malay**: "Permohonan berjaya dihantar"

### Step 7: View My Applications
Look at the top AppBar, you'll see:
- 📋 **My Applications icon** (clipboard/assignment icon)
- 🔔 Notifications icon
- 👤 User avatar

**Click the 📋 My Applications icon.**

### Step 8: Verify Application Display
MyApplicationsScreen will show:
- Your submitted application card with:
  - Service title (e.g., "Daily Welfare Relief")
  - Submitted date/time
  - **Green badge**: "Submitted" (Dihantar)
- If there's nothing, you'll see "No applications yet"

### Step 9: Verify in Firebase Console
1. Open https://console.firebase.google.com
2. Select your "ISN Accessible Bridge" project
3. Go to **Firestore Database**
4. Click **applications** collection
5. You should see 1 document:

```json
{
  "appId": "app_1702123456789",
  "serviceId": "welfare_relief_2025",
  "uid": "user_aminah",
  "status": "submitted",
  "filledData": {
    "income_proof": "...",
    "household_size": "...",
    "reason": "..."
  },
  "submittedAt": "2025-12-11T08:15:30.000Z",
  "audit": [
    {
      "timestamp": "2025-12-11T08:15:30.000Z",
      "action": "created",
      "details": "Application created via ISN app"
    }
  ]
}
```

## 🧪 Testing Offline Mode

### Test 1: Submit While Offline
1. Enable **Airplane Mode** on your device
2. Navigate: Services → Select Service → Fill Form → Submit
3. You should see message:
   - "Application saved. Will sync when online. (1 in queue)"
4. Console will show:
   ```
   SyncQueue: Added application app_XXX to queue
   SyncQueue: Connectivity check - isOnline: false
   ```

### Test 2: Auto-Sync When Back Online
1. Disable **Airplane Mode**
2. Wait a few seconds
3. Console should show:
   ```
   ConnectivityMonitor: Network connectivity restored
   SyncQueue: Auto-syncing queued applications...
   SyncQueue: Syncing app_XXX to Firestore...
   SyncQueue: Successfully synced app_XXX to Firestore
   ```
4. You'll see snackbar: "Auto-sync successful! 1 applications synced"

### Test 3: View Synced Applications
1. Click 📋 My Applications icon
2. Previously offline application should now show:
   - Status: **Submitted** (green badge)
   - Correct submission time
3. Check Firebase Console - document should be there

## ❌ Troubleshooting

### Problem 1: "No applications yet" in My Applications
**Cause**: You haven't actually submitted an application yet
**Fix**: Follow Steps 1-5 above to submit an application

### Problem 2: No "Successfully synced to Firestore" log
**Cause 1**: You're offline
- Check if device has internet
- Look for "isOnline: false" in console

**Cause 2**: Firebase permissions issue
- Check Firestore Rules in Firebase Console
- Should allow: `allow create: if request.auth != null;`

**Cause 3**: Anonymous auth failed
- Check for "Firebase: Signed in anonymously" at app start
- If missing, check firebase_options.dart exists

### Problem 3: Can't find My Applications icon
**Fix**: Look at the top AppBar (not bottom navigation!)
- Icon looks like: 📋 (clipboard/assignment)
- Located between app title and notifications bell

### Problem 4: Gradle build errors
**Already Fixed!** But if you see errors:
- Check android/app/build.gradle.kts:
  - `ndkVersion = "27.0.12077973"`
  - `minSdk = 23`

## 📊 Success Indicators

You know Firebase is working when you see ALL of these:

✅ Console log: `Firebase: Signed in anonymously`
✅ Console log: `SyncQueue: Successfully synced app_XXX to Firestore`
✅ Green snackbar: "Application submitted successfully"
✅ My Applications shows your application
✅ Firebase Console → applications collection has 1+ documents
✅ Application status badge is green "Submitted"

## 🎯 Quick Test Checklist

- [ ] App launches without errors
- [ ] Select user persona
- [ ] See bottom navigation with 4 tabs
- [ ] Click "Services" tab (index 1)
- [ ] See 3 service cards
- [ ] Click any service
- [ ] Fill form fields (at least 1 field)
- [ ] Click Save button
- [ ] See green "Application submitted successfully" message
- [ ] See console log "Successfully synced to Firestore"
- [ ] Click 📋 My Applications icon in top bar
- [ ] See 1 application with green "Submitted" badge
- [ ] Check Firebase Console for application document

## 🔍 Console Logs to Watch For

### Good (Success):
```
Firebase: Signed in anonymously
SyncQueue: Added application app_1234 to queue
SyncQueue: Connectivity check - isOnline: true
SyncQueue: Syncing app_1234 to Firestore...
SyncQueue: Successfully synced app_1234 to Firestore  ← CRITICAL!
SyncQueue: Removed application app_1234 from queue
```

### Bad (Error):
```
SyncQueue: Error syncing app_1234 to Firestore: [permission-denied]
```
→ Fix: Check Firestore security rules

```
SyncQueue: Connectivity check - isOnline: false
```
→ Fix: Enable WiFi/Mobile data

---

## Need Help?

If applications still don't appear:
1. Share the **complete console logs** from app launch to submission
2. Share a **screenshot** of My Applications screen
3. Share a **screenshot** of Firebase Console → Firestore Database

The logs will tell us exactly what's happening!
