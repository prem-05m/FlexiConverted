import fs from 'fs/promises';
import path from 'path';

// Clean up files older than 24 hours
const MAX_AGE_MS = 24 * 60 * 60 * 1000;

const cleanupDir = async (dirPath: string) => {
  try {
    const files = await fs.readdir(dirPath);
    const now = Date.now();

    for (const file of files) {
      const fullPath = path.join(dirPath, file);
      const stat = await fs.stat(fullPath);
      
      if (now - stat.mtimeMs > MAX_AGE_MS) {
        await fs.unlink(fullPath);
        console.log(`Cleaned up old file: ${file}`);
      }
    }
  } catch (error: any) {
    console.error(`Cleanup error for ${dirPath}:`, error.message);
  }
};

export const startCleanupJob = () => {
  const rootDir = process.cwd();
  
  // Run every hour
  setInterval(() => {
    console.log('Running scheduled temp file cleanup...');
    cleanupDir(path.join(rootDir, 'uploads'));
    cleanupDir(path.join(rootDir, 'temp'));
    cleanupDir(path.join(rootDir, 'outputs'));
  }, 60 * 60 * 1000);
};
