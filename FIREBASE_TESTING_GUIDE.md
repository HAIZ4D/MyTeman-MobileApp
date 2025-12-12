# Firebase Integration Testing Guide

## Current Issue
Applications are not appearing in Firestore or My Applications screen.

## Root Cause Analysis

### User Flow
1. **UserSelectionScreen** → Select persona
2. **AdaptiveNavigation** → Main app with bottom navigation
3. **ServiceListScreen** → Browse and select services (Bottom Nav index 1)
4. **ApplicationFormScreen** → Fill and submit application
5. **SyncQueue** → Save locally and sync to Firestore
6. **MyApplicationsScreen** → View submitted applications

### Potential Issues

1. **User not reaching ApplicationFormScreen**
   - Users might not know to click bottom nav "Services" tab
   - Need to test: UserSelection → Bottom Nav → Services → Select Service → Fill Form → Submit

2. **Firebase Auth not initialized**
   - Check console for "Firebase: Signed in anonymously"
   - Check for Firebase init errors

3. **Firestore write permissions**
   - Verify security rules allow anonymous writes
   - Check Firebase Console → Firestore → Rules

4. **Network connectivity**
   - App might be offline during testing
   - SyncQueue saves locally but doesn't sync until online

## Testing Steps

### Step 1: Verify Firebase Initialization
Run the app and check console logs for:
```
Firebase: Signed in anonymously
```

### Step 2: Navigate to Services
1. Launch app
2. Select any user (e.g., Puan Aminah)
3. **Click bottom navigation "Perkhidmatan" / "Services" tab** (index 1)
4. You should see 3 service cards

### Step 3: Fill and Submit Application
1. Click on "Bantuan Kebajikan Harian" (Welfare Relief)
2. Fill in the form fields
3. Click Save/Submit button
4. Watch console for these logs:
   ```
   SyncQueue: Added application app_XXX to queue
   SyncQueue: Connectivity check - isOnline: true
   SyncQueue: Syncing app_XXX to Firestore...
   SyncQueue: Successfully synced app_XXX to Firestore
   SyncQueue: Removed application app_XXX from queue
   ```

### Step 4: Verify in My Applications
1. **From any screen**, look for the 📋 icon in top AppBar
2. Click My Applications icon
3. Should see your submitted application with green "Submitted" badge

### Step 5: Verify in Firebase Console
1. Go to Firebase Console → Firestore Database
2. Check `applications` collection
3. Should see documents with structure:
   ```json
   {
     "appId": "app_XXX",
     "serviceId": "welfare_relief_2025",
     "uid": "user_aminah",
     "status": "submitted",
     "filledData": {...},
     "submittedAt": "2025-12-11T...",
     "audit": [...]
   }
   ```

## Debugging Console Logs

### Good Flow (Success)
```
SyncQueue: Added application app_1234 to queue. Queue size: 1
SyncQueue: Connectivity check - isOnline: true, result: [ConnectivityResult.wifi]
SyncQueue: Syncing app_1234 to Firestore...
SyncQueue: Successfully synced app_1234 to Firestore
SyncQueue: Removed application app_1234 from queue. Remaining: 0
```

### Offline Flow (Queued)
```
SyncQueue: Added application app_1234 to queue. Queue size: 1
SyncQueue: Connectivity check - isOnline: false, result: [ConnectivityResult.none]
[Later when online...]
ConnectivityMonitor: Network connectivity restored
SyncQueue: Auto-syncing queued applications...
SyncQueue: Syncing app_1234 to Firestore...
SyncQueue: Successfully synced app_1234 to Firestore
```

### Error Flow (Permission Denied)
```
SyncQueue: Syncing app_1234 to Firestore...
SyncQueue: Error syncing app_1234 to Firestore: [cloud_firestore/permission-denied]
```

## Common Issues & Fixes

### Issue 1: "Permission Denied" in Console
**Fix**: Update Firestore security rules to allow anonymous writes
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /applications/{appId} {
      allow create: if request.auth != null;
      allow read, update: if request.auth != null;
    }
  }
}
```

### Issue 2: No Console Logs Appearing
**Fix**: User didn't actually submit an application
- Make sure to navigate: Bottom Nav → Services → Select Service → Fill Form → Submit

### Issue 3: Applications Not Showing in My Applications Screen
**Fix**: Check that Firebase query matches user UID
- My Applications queries: `where('uid', isEqualTo: user.uid)`
- Make sure submitted application has correct UID

### Issue 4: "No My Applications Icon"
**Fix**: My Applications icon only appears in certain screens
- Look for 📋 icon in AppBar (onboarding_voice_screen or home_screen)
- Or add to AdaptiveNavigation AppBar

## Quick Test Command

Run app and monitor logs:
```bash
flutter run
```

Then follow the navigation:
1. Select User → Services Tab (bottom nav) → Welfare Relief → Fill Form → Submit
2. Watch console for "Successfully synced to Firestore"
3. Go back → Click My Applications icon
4. Check Firebase Console → Firestore → applications collection

## Expected Result

After successful submission, you should see:
- ✅ Green snackbar: "Application submitted successfully"
- ✅ Console log: "SyncQueue: Successfully synced app_XXX to Firestore"
- ✅ My Applications screen shows 1 application
- ✅ Firebase Console shows 1 document in 'applications' collection
- ✅ Application status: "Submitted" (green badge)
