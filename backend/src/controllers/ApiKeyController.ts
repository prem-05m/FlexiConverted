import { Request, Response } from 'express';
import { initializeApp, getApps, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

// Initialize Firebase if not already initialized
if (getApps().length === 0) {
  // We use the applicationDefault which reads from GOOGLE_APPLICATION_CREDENTIALS
  // Or we can just initialize if env vars are present. For now, try default.
  try {
    initializeApp({
      credential: applicationDefault(),
    });
  } catch (e) {
    console.error('Failed to initialize Firebase Admin:', e);
  }
}

export const getCloudConvertKey = async (req: Request, res: Response): Promise<void> => {
  try {
    // Safely get Firestore if initialized
    if (getApps().length === 0) {
      throw new Error('Firebase Admin not initialized. Check credentials.');
    }
    const db = getFirestore();

    const keys = [
      process.env.CLOUDCONVERT_API_KEY_1,
      process.env.CLOUDCONVERT_API_KEY_2,
      process.env.CLOUDCONVERT_API_KEY_3,
      process.env.CLOUDCONVERT_API_KEY_4,
      process.env.CLOUDCONVERT_API_KEY_5,
    ].filter(Boolean) as string[];

    if (keys.length === 0) {
      res.status(500).json({ success: false, message: 'No API keys configured on server' });
      return;
    }

    const statsRef = db.collection('conversion_stats').doc('global');
    
    // Use a transaction to safely increment the counter
    const currentCount = await db.runTransaction(async (transaction) => {
      const doc = await transaction.get(statsRef);
      let count = 1;
      if (doc.exists) {
        count = (doc.data()?.totalConversions || 0) + 1;
      }
      transaction.set(statsRef, { totalConversions: count }, { merge: true });
      return count;
    });

    const limitPerKey = 10;
    const maxConversions = keys.length * limitPerKey;

    if (currentCount > maxConversions) {
      res.status(429).json({ success: false, message: 'Daily limit reached. Try again tomorrow.' });
      return;
    }

    // Determine which key to use
    const keyIndex = Math.floor((currentCount - 1) / limitPerKey);
    const selectedKey = keys[keyIndex];

    res.json({ success: true, apiKey: selectedKey, currentCount, maxConversions });

  } catch (error: any) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Failed to retrieve API key', error: error.message });
  }
};
