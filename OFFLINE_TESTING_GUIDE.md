# Offline Mode Testing Guide

Complete guide for testing the ISN app's offline functionality and sync queue.

## Overview

The ISN app features an **offline-first architecture** that allows users to submit applications even without internet connectivity. Applications are saved locally and automatically synced when the device reconnects.

## Features to Test

1. ✅ **Offline Application Submission** - Submit applications without internet
2. ✅ **Local Storage Queue** - Applications stored in device memory
3. ✅ **Automatic Sync** - Auto-sync when connectivity is restored
4. ✅ **Queue Status Display** - See how many applications are pending sync
5. ✅ **Connectivity Detection** - Real-time network status monitoring

---

## Method 1: Airplane Mode Testing (Recommended)

### Step-by-Step Instructions:

#### 1. **Prepare the Application**
- Open the ISN app
- Navigate to **Services** (Perkhidmatan)
- Select any service (e.g., "Bantuan Kebajikan Harian")
- Press **Apply Now** (Mohon Sekarang)

#### 2. **Fill Out the Form**
- Go through the multi-step form
- Fill in all required fields (you can use voice input)
- Upload any required documents using camera or gallery
- Navigate to the final step

#### 3. **Enable Airplane Mode**
- **Before pressing Submit**, swipe down from the top of your screen
- Enable **Airplane Mode** ✈️
- This will disconnect WiFi, Mobile Data, and Bluetooth

#### 4. **Submit the Application**
- Press the **Submit** (Hantar) button
- Complete biometric authentication (PIN/Pattern will still work)
- You should see a message like:

**Malay:**
```
Permohonan disimpan. Akan disegerakkan apabila talian tersedia. (1 dalam baris gilir)
```

**English:**
```
Application saved. Will sync when online. (1 in queue)
```

#### 5. **Verify Local Storage**
- The application is now saved in the device's local storage
- You can submit multiple applications while offline
- Each will increment the queue counter: "(2 in queue)", "(3 in queue)", etc.

#### 6. **Restore Connectivity**
- Disable **Airplane Mode**
- Wait for WiFi/Mobile Data to reconnect (5-10 seconds)

#### 7. **Automatic Sync**
- The app will automatically detect the restored connectivity
- It will attempt to sync all queued applications
- You should see success messages for each synced application

#### 8. **Verify Sync Success**
- Check the console logs (if running from development)
- Look for messages like:
  ```
  SyncQueue: Syncing app_1234567890 to backend...
  SyncQueue: Removed application app_1234567890 from queue. Remaining: 0
  ```

---

## Method 2: Debug Console Monitoring

### Viewing Sync Queue Logs

When you submit applications offline, watch the Flutter console for these log messages:

```bash
# When submitting offline:
SyncQueue: Connectivity check - isOnline: false, result: [ConnectivityResult.none]
SyncQueue: Added application app_1702345678901 to queue. Queue size: 1

# When connectivity is restored:
SyncQueue: Connectivity check - isOnline: true, result: [ConnectivityResult.wifi]
SyncQueue: Syncing app_1702345678901 to backend...
SyncQueue: Removed application app_1702345678901 from queue. Remaining: 0
```

---

## Method 3: Test Multiple Applications

### Batch Queue Testing

1. **Submit 3-5 applications while offline**
   - Each submission will add to the queue
   - Note the increasing queue count

2. **Restore connectivity**
   - Watch the console for batch sync logs
   - Each application should sync individually

3. **Verify sync results**
   - Check for success/failure messages
   - Queue should be empty (0 in queue) after successful sync

---

## What to Expect

### ✅ When OFFLINE:
- Green success message: "Application saved. Will sync when online."
- Queue counter shows pending count: "(X in queue)"
- No error messages
- Application stored in SharedPreferences

### ✅ When ONLINE:
- Applications automatically sync in background
- Success message: "Application submitted successfully"
- Queue counter decreases as items sync
- Final queue count returns to 0

### ❌ If Sync Fails:
- Red error message with details
- Application remains in queue
- Can manually retry by re-enabling connectivity

---

## Technical Details

### Where Applications Are Stored

**Local Storage Location:**
```dart
SharedPreferences
Key: 'sync_queue'
Format: JSON array of Application objects
```

**Storage Capacity:**
- Limited only by device storage
- Typical SharedPreferences limit: ~2MB
- Approximately 50-100 applications (depending on data size)

### Connectivity Detection

The app uses `connectivity_plus` package to detect:
- ✅ WiFi connection
- ✅ Mobile data (3G/4G/5G)
- ✅ Ethernet connection
- ✅ VPN connection
- ❌ No connection (Offline)

### Auto-Sync Behavior

**When does auto-sync trigger?**
1. Immediately after form submission (if online)
2. When app detects connectivity change (offline → online)
3. When user manually refreshes (future feature)

---

## Testing Checklist

Use this checklist to verify all offline features:

### Basic Functionality
- [ ] Submit application while offline
- [ ] See "saved" message (not "submitted")
- [ ] Queue counter shows correct count
- [ ] Multiple offline submissions increment queue
- [ ] Applications stored locally (survive app restart)

### Sync Functionality
- [ ] Auto-sync triggers when connectivity restored
- [ ] Success message appears for each sync
- [ ] Queue counter decreases correctly
- [ ] Final queue count is 0 after all synced
- [ ] Console logs show sync activity

### Edge Cases
- [ ] Submit 5+ applications offline (stress test)
- [ ] Toggle airplane mode multiple times
- [ ] Close and reopen app while offline (persistence test)
- [ ] Restore connectivity while app is in background
- [ ] Submit same form twice while offline (duplicate handling)

### Error Handling
- [ ] Graceful failure if sync fails
- [ ] Applications remain in queue on error
- [ ] User can retry failed syncs
- [ ] Error messages are clear and bilingual

---

## Troubleshooting

### Issue: "Application submitted successfully" while offline

**Solution:** The connectivity check may not be working. Verify:
```bash
# Check console for:
SyncQueue: Connectivity check - isOnline: false, result: [ConnectivityResult.none]
```

### Issue: Queue not decreasing after going online

**Solution:** Check if backend is accessible:
```bash
# Current implementation uses mock backend
# Verify _syncToBackend() is being called
SyncQueue: Syncing app_XXXXX to backend...
```

### Issue: Applications lost after app restart

**Solution:** Check SharedPreferences permissions:
- Ensure app has storage permissions
- Verify no cache clearing settings are active

---

## Future Enhancements

### Planned Features:
1. **Manual Sync Button** - User-triggered sync retry
2. **Queue Management Screen** - View and manage pending applications
3. **Conflict Resolution** - Handle duplicate submissions
4. **Sync Progress Indicator** - Real-time sync status
5. **Failed Sync Recovery** - Automatic retry with exponential backoff

---

## Developer Notes

### Key Files:
- **SyncQueue Service**: `lib/services/sync_queue.dart`
- **Application Model**: `lib/models/application.dart`
- **Form Screen**: `lib/screens/application_form_screen.dart`

### Testing Commands:
```bash
# Run app with verbose logging
flutter run -d R52Y509B01W --verbose

# Clear app data (reset queue)
flutter clean
flutter run

# View SharedPreferences data (Android)
adb shell run-as com.isn.malaysia.isn_app cat /data/data/com.isn.malaysia.isn_app/shared_prefs/FlutterSharedPreferences.xml
```

---

## Quick Reference

| Action | Expected Behavior |
|--------|-------------------|
| Submit offline | "Application saved. Will sync when online. (X in queue)" |
| Submit online | "Application submitted successfully" |
| Restore connectivity | Auto-sync starts, queue count decreases |
| Multiple offline | Queue count increments: 1, 2, 3... |
| All synced | Queue count returns to 0 |

---

**Happy Testing! 🎉**

If you encounter any issues, check the console logs for detailed debugging information.
