import dotenv from 'dotenv';
import { app } from './app';
import { connectDB } from './config/database';
import { storage } from './storage/LocalDiskStorageProvider';
// Workers disabled per user request to bypass Redis
// import './workers/conversionWorker';
// import { startCleanupJob } from './workers/cleanupWorker';

dotenv.config();

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/flexiconvert';

const startServer = async () => {
  // Initialize Storage
  await storage.init();
  console.log('Storage provider initialized');

  // Connect Database (Disabled for now per user request to use local storage)
  // await connectDB(MONGO_URI);

  // Start Cleanup Cron (Disabled)
  // startCleanupJob();

  // Start Server
  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
};

startServer().catch((error) => {
  console.error('Failed to start server:', error);
  process.exit(1);
});
