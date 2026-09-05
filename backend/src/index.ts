import dotenv from 'dotenv';
import { app } from './app';
import { initFirebase } from './config/firebase';
import { storage } from './storage/LocalDiskStorageProvider';
// Workers disabled per user request to bypass Redis
// import './workers/conversionWorker';
import { startCloudBackupCleanupJob } from './workers/cloudBackupCleanupWorker';
import './workers/JobWorker';

dotenv.config();

const PORT = process.env.PORT || 3000;

const startServer = async () => {
  // Initialize Storage
  await storage.init();
  console.log('Storage provider initialized');

  // Initialize Firebase
  initFirebase();

  // Start Cleanup Cron
  startCloudBackupCleanupJob();

  // Start Server
  app.listen(PORT as number, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
  });
};

startServer().catch((error) => {
  console.error('Failed to start server:', error);
  process.exit(1);
});
