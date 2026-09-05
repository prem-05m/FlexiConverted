import cron from 'node-cron';
import { getFirestore } from '../config/firebase';
import { cloudStorage } from '../storage/CloudinaryStorageProvider';

// Runs once every day at midnight
export const startCloudBackupCleanupJob = () => {
  cron.schedule('0 0 * * *', async () => {
    console.log('Running Cloud Backup Cleanup Job...');
    try {
      const db = getFirestore();
      
      // Calculate 30 days ago
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      
      const jobsSnapshot = await db.collection('jobs')
        .where('createdAt', '<=', thirtyDaysAgo)
        .where('status', '==', 'completed')
        .get();
        
      if (jobsSnapshot.empty) {
        console.log('No old jobs found to clean up.');
        return;
      }
      
      let deletedCount = 0;
      
      for (const doc of jobsSnapshot.docs) {
        const data = doc.data();
        if (data.outputFiles && Array.isArray(data.outputFiles) && data.outputFiles.length > 0) {
          // Delete from Cloudinary
          for (const fileUrl of data.outputFiles) {
            try {
              // Delete the actual file from Cloudinary storage
              await cloudStorage.deleteFile(fileUrl);
            } catch (error) {
              console.error(`Failed to delete file ${fileUrl} from Cloudinary:`, error);
            }
          }
          
          // Update the Firestore doc to reflect files are deleted (e.g., empty out the array)
          // We keep the history record (names, toolType, etc.) but the file is gone.
          await doc.ref.update({
            outputFiles: [],
            cloudBackupExpired: true,
            updatedAt: new Date()
          });
          
          deletedCount++;
        }
      }
      
      console.log(`Cloud Backup Cleanup completed. Deleted files for ${deletedCount} jobs.`);
    } catch (error) {
      console.error('Error during cloud backup cleanup:', error);
    }
  });
  
  console.log('Cloud Backup Cleanup Cron Scheduled (Daily at Midnight).');
};
