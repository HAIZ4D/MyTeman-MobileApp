// Script to add missing 'uid' field to existing Firestore documents
// Run with: node tools/fix_firestore_documents.js

const admin = require('firebase-admin');

// Initialize Firebase Admin (you'll need to download service account key)
// Go to Firebase Console → Project Settings → Service Accounts → Generate Key
const serviceAccount = require('../service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixDocuments() {
  try {
    console.log('Fetching applications without uid field...');

    const snapshot = await db.collection('applications').get();

    console.log(`Found ${snapshot.size} documents`);

    let fixedCount = 0;
    const batch = db.batch();

    snapshot.forEach(doc => {
      const data = doc.data();

      // Check if uid is missing
      if (!data.uid) {
        console.log(`Fixing document ${doc.id} - adding uid field`);

        // Try to infer uid from serviceId or set default
        let uid = 'user_aminah'; // Default user

        // You can set different uids based on serviceId or other logic
        if (data.serviceId === 'welfare_relief_2025') {
          uid = 'user_aminah';
        } else if (data.serviceId === 'business_permit_local') {
          uid = 'user_david';
        } else if (data.serviceId === 'scholarship_merit_2025') {
          uid = 'user_sarah';
        }

        batch.update(doc.ref, { uid: uid });
        fixedCount++;
      }
    });

    if (fixedCount > 0) {
      await batch.commit();
      console.log(`✅ Successfully fixed ${fixedCount} documents`);
    } else {
      console.log('ℹ️  All documents already have uid field');
    }

  } catch (error) {
    console.error('❌ Error fixing documents:', error);
  }
}

fixDocuments().then(() => {
  console.log('Done!');
  process.exit(0);
});
