import { app } from '../src/app';
import { storage } from '../src/storage/LocalDiskStorageProvider';

// Initialize storage (creates temp directories) for serverless environment
storage.init().catch(console.error);

export default function(req: any, res: any) {
  return app(req, res);
}
