import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getFirestore as _getFirestore } from 'firebase-admin/firestore';
import { getAuth as _getAuth } from 'firebase-admin/auth';

export const initFirebase = () => {
  try {
    if (getApps().length === 0) {
      if (
        process.env.FIREBASE_PROJECT_ID &&
        process.env.FIREBASE_CLIENT_EMAIL &&
        process.env.FIREBASE_PRIVATE_KEY
      ) {
        // Initialize with explicit credentials from env
        initializeApp({
          credential: cert({
            projectId: process.env.FIREBASE_PROJECT_ID,
            clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
            // Replace escaped newlines with actual newlines
            privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
          }),
        });
        console.log('Firebase Admin initialized with environment variables.');
      } else {
        // Fallback to Application Default Credentials (e.g., if deployed to GCP)
        initializeApp();
        console.log('Firebase Admin initialized with Application Default Credentials.');
      }
    }
  } catch (error) {
    console.error('Firebase Admin initialization error:', error);
  }
};

export const getFirestore = () => {
  return _getFirestore();
};

export const getAuth = () => {
  return _getAuth();
};
