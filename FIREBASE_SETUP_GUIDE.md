# Firebase Setup Guide for ISN App

## Overview

Your ISN app now has **Firebase Firestore integration** to store and display applications! Here's what's been implemented and what you need to do to complete the setup.

## ✅ What's Already Implemented

### 1. **Firestore Integration in SyncQueue** ([sync_queue.dart](lib/services/sync_queue.dart:146))
   - Applications are now saved to Firestore when synced
   - Status automatically updates from 'draft' to 'submitted'
   - Full error handling and logging

### 2. **My Applications Screen** ([my_applications_screen.dart](lib/screens/my_applications_screen.dart))
   - Real-time StreamBuilder showing applications from Firestore
   - Status badges (Saved, Submitted, Processing, etc.)
   - Queue indicator showing pending offline applications
   - Pull-to-refresh functionality

### 3. **Navigation Added**
   - Button in onboarding screen to view "My Applications"
   - Route configured in app.dart

### 4. **Firebase Initialization**
   - Firebase.initializeApp() added to main.dart
   - Connectivity monitor integrated

---

## 🔧 Firebase Setup Steps

### Option 1: Use Firebase (Recommended for Production)

#### **Step 1: Create Firebase Project**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it: "ISN Accessible Bridge"
4. Enable Google Analytics (optional)
5. Create project

#### **Step 2: Add Android App**

1. In Firebase console, click "Add app" → Android icon
2. **Android package name**: `com.isn.malaysia.isn_app`
   - Find this in: `android/app/build.gradle.kts` under `namespace`
3. Download `google-services.json`
4. Place it in: `android/app/` folder

#### **Step 3: Configure Firestore**

1. In Firebase console, go to **Firestore Database**
2. Click "Create database"
3. Start in **Test mode** (for development)
4. Choose location: `asia-southeast1` (Singapore - closest to Malaysia)

#### **Step 4: Set Firestore Security Rules**

In Firestore Rules tab, paste this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read/write their own applications
    match /applications/{appId} {
      allow read: if request.auth != null && resource.data.uid == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.uid == request.auth.uid;
      allow update: if request.auth != null && resource.data.uid == request.auth.uid;
      allow delete: if false; // Don't allow deletion
    }

    // Allow all users to read services
    match /services/{serviceId} {
      allow read: if true;
      allow write: if false; // Admin only
    }

    // Allow users to read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### **Step 5: Enable Anonymous Authentication** (for prototype)

1. Go to **Authentication** in Firebase console
2. Click "Get started"
3. Enable **Anonymous** sign-in method
4. Save

#### **Step 6: Update Flutter Code for Authentication**

Since Firestore rules require authentication, add this to your code:

```dart
// In lib/main.dart, after Firebase.initializeApp()
await FirebaseAuth.instance.signInAnonymously();
```

#### **Step 7: Run FlutterFire CLI** (Automatic configuration)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Run configuration
flutterfire configure
```

This will create `lib/firebase_options.dart` automatically!

---

### Option 2: Use Firestore Emulator (For Development/Testing)

If you don't want to set up Firebase yet, use the local emulator:

#### **Step 1: Install Firebase Tools**

```bash
npm install -g firebase-tools
```

#### **Step 2: Login to Firebase**

```bash
firebase login
```

#### **Step 3: Initialize Firestore Emulator**

```bash
cd c:\FlutterProject\isn_app
firebase init emulators
```

Select: **Firestore Emulator**

#### **Step 4: Start Emulator**

```bash
firebase emulators:start
```

#### **Step 5: Connect Flutter App to Emulator**

Add this to `lib/main.dart` after `Firebase.initializeApp()`:

```dart
// Connect to Firestore emulator (localhost)
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
```

---

## 📝 Current App Flow

### **Offline Submission:**
1. User fills application form
2. Biometric authentication
3. App saves to **local queue** (SharedPreferences)
4. Status: "Application saved. Will sync when online. (X in queue)"

### **When Back Online:**
1. ConnectivityMonitor detects connection
2. Auto-sync triggered
3. Applications uploaded to **Firestore**
4. Status changes from 'draft' → 'submitted'
5. Removed from local queue

### **Viewing Applications:**
1. User clicks "My Applications" icon in onboarding screen
2. Real-time stream from Firestore
3. Shows all applications with status badges
4. Green badge = "Submitted" (synced to Firestore)
5. Orange badge = "Saved" (still in queue, offline)

---

## 🎯 Quick Test Without Firebase Setup

If you want to test immediately without Firebase:

### **Temporary Fix** - Comment out Firestore code:

1. In `lib/services/sync_queue.dart`, line 147:

```dart
Future<bool> _syncToBackend(Application application) async {
  try {
    print('SyncQueue: Syncing ${application.appId} to backend...');

    // TEMPORARY: Skip Firestore for now
    // await FirebaseFirestore.instance...

    // Just simulate success
    await Future.delayed(const Duration(milliseconds: 300));
    print('SyncQueue: Successfully synced ${application.appId} (simulated)');
    return true;
  } catch (e) {
    print('SyncQueue: Error: $e');
    return false;
  }
}
```

2. In `lib/main.dart`, comment out Firebase initialization:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TEMPORARY: Skip Firebase for now
  // await Firebase.initializeApp();

  ConnectivityMonitor().startMonitoring();
  runApp(const ProviderScope(child: IsnApp()));
}
```

3. The "My Applications" screen won't work without Firebase, but offline queue will still work!

---

## 🐛 Troubleshooting

### Error: "FirebaseOptions cannot be null"

**Solution**: You need to configure Firebase first. Use FlutterFire CLI:

```bash
flutterfire configure
```

### Error: "PERMISSION_DENIED: Missing or insufficient permissions"

**Solution**: Make sure you're signed in anonymously or update Firestore rules to allow unauthenticated access (for testing):

```javascript
allow read, write: if true; // WARNING: Only for testing!
```

### Applications not showing in My Applications screen

**Checklist**:
1. ✅ Firebase initialized?
2. ✅ Firestore rules allow read access?
3. ✅ User authenticated (even anonymously)?
4. ✅ Applications synced (check console logs)?
5. ✅ Correct user UID in query?

---

## 📱 Testing the Complete Flow

### **Full Integration Test:**

1. **Fill an application offline**
   - Enable Airplane Mode
   - Fill and submit application
   - See: "Application saved. Will sync when online. (1 in queue)"

2. **Go back online**
   - Disable Airplane Mode
   - Watch console logs: "ConnectivityMonitor: Auto-sync successful! 1 applications synced"
   - Watch console logs: "SyncQueue: Successfully synced app_XXX to Firestore"

3. **View in My Applications**
   - Click "My Applications" icon (📋) in top bar
   - See your submitted application with green "Submitted" badge
   - See timestamp (e.g., "Today", "2 days ago")

---

## 🚀 What's Next?

After Firebase is set up, you can:

1. **View real-time updates** - Applications update live as status changes
2. **Persistent storage** - Applications survive app restarts
3. **Multi-device sync** - See applications on any device (same user)
4. **Admin dashboard** - Build web admin panel to manage applications
5. **Push notifications** - Notify users when status changes

---

## 📊 Firestore Data Structure

### **Collections:**

```
/applications/{appId}
  - appId: string
  - serviceId: string
  - uid: string
  - status: string ("draft" | "submitted" | "processing" | "approved" | "rejected")
  - filledData: map
  - submittedAt: string (ISO timestamp)
  - audit: array

/services/{serviceId}
  - serviceId: string
  - title: string
  - titleEn: string
  - description: string
  - requiredFields: array
  - categories: array
  - icon: string

/users/{uid}
  - uid: string
  - name: string
  - icNumber: string (redacted)
  - preferredLanguage: string
  - accessibility: map
  - biometricEnabled: boolean
```

---

## 💡 Recommendation

For your **hackathon demo**, I recommend:

1. **Use Firebase Emulator** initially (fastest setup)
2. **Switch to real Firebase** before final demo (more impressive)
3. **Keep offline mode** as your key differentiator

The offline-first architecture with auto-sync is your **strongest feature** - it solves real problems for rural Malaysians!

---

## 🎬 Demo Script

> **"Let me show you the offline capability..."**
>
> 1. *Enable Airplane Mode*
> 2. *Submit application* - "See? It saves locally"
> 3. *Disable Airplane Mode* - "Watch it auto-sync!"
> 4. *Click My Applications* - "And here it is in Firestore, with real-time updates!"

---

**Need help?** Check the console logs - they show exactly what's happening at each step!
