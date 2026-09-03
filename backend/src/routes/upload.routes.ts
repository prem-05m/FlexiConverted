import { Router, Request, Response } from 'express';
import multer from 'multer';
import { storage } from '../storage/LocalDiskStorageProvider';

const router = Router();
const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: { fileSize: 50 * 1024 * 1024 } // 50MB
});

router.post('/', upload.single('file'), async (req: Request, res: Response): Promise<void> => {
  if (!req.file) {
    res.status(400).json({ success: false, message: 'No file uploaded' });
    return;
  }

  try {
    const filename = `${Date.now()}-${req.file.originalname.replace(/[^a-zA-Z0-9.-]/g, '_')}`;
    await storage.saveFile(req.file.buffer, filename, 'uploads');
    
    // Construct the URL to access the file
    const fileUrl = `${req.protocol}://${req.get('host')}/api/v1/uploads/files/${filename}`;
    
    res.json({ success: true, url: fileUrl });
  } catch (err: any) {
    res.status(500).json({ success: false, message: 'Failed to upload file', error: err.message });
  }
});

router.get('/files/:filename', async (req: Request, res: Response): Promise<void> => {
  try {
    const filename = req.params.filename as string;
    const filePath = storage.getAbsolutePath(filename, 'uploads');
    res.sendFile(filePath);
  } catch (err) {
    res.status(404).json({ success: false, message: 'File not found' });
  }
});

export default router;
