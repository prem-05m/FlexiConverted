import { Request, Response } from 'express';
import { JobRepository } from '../repositories/JobRepository';
import { conversionQueue } from '../config/queue';
import { storage } from '../storage/LocalDiskStorageProvider';
import { AuthRequest } from '../middlewares/auth';
import crypto from 'crypto';

export class JobController {
  /**
   * Upload file(s) and create a conversion job
   */
  static async createJob(req: AuthRequest, res: Response): Promise<void> {
    try {
      const files = req.files as Express.Multer.File[];
      const { toolType, params } = req.body;

      if (!files || files.length === 0) {
        res.status(400).json({ success: false, message: 'No files uploaded' });
        return;
      }

      if (!toolType) {
        res.status(400).json({ success: false, message: 'Missing toolType' });
        return;
      }

      // Save input files to local disk for processing
      const inputFiles: string[] = [];
      for (const file of files) {
        const ext = file.originalname.split('.').pop() || '';
        const filename = `${crypto.randomUUID()}.${ext}`;
        const path = await storage.saveFile(file.buffer, filename, 'uploads');
        inputFiles.push(filename); 
      }

      const parsedParams = params ? JSON.parse(params) : {};

      const jobDoc = await JobRepository.create({
        userId: req.user.id,
        toolType,
        inputFiles,
        status: 'pending',
        progress: 0,
        params: parsedParams
      });

      // Add to BullMQ
      await conversionQueue.add('convert', {
        jobId: jobDoc.id,
        userId: req.user.id,
        inputFiles,
        outputFolder: 'outputs',
        toolType,
        params: parsedParams
      }, {
        jobId: jobDoc.id
      });

      res.status(201).json({ success: true, job: jobDoc });
    } catch (error: any) {
      console.error('Create Job Error:', error);
      res.status(500).json({ success: false, message: error.message });
    }
  }

  static async getStatus(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = req.params.id as string;
      const job = await JobRepository.findById(id);
      if (!job || job.userId !== req.user.id) {
        res.status(404).json({ success: false, message: 'Job not found' });
        return;
      }
      res.status(200).json({ success: true, job });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  static async getHistory(req: AuthRequest, res: Response): Promise<void> {
    try {
      // Syncs across devices since we query by user ID (Firebase UID)
      const jobs = await JobRepository.findByUserId(req.user.id);
      res.status(200).json({ success: true, jobs });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  static async deleteJob(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = req.params.id as string;
      const job = await JobRepository.findById(id);
      
      if (!job || job.userId !== req.user.id) {
        res.status(404).json({ success: false, message: 'Job not found' });
        return;
      }

      await JobRepository.delete(id);

      // We only delete from Cloudinary if outputFiles exist
      // Assuming outputFiles now store the Cloudinary URLs
      if (job.outputFiles) {
        const { cloudStorage } = await import('../storage/CloudinaryStorageProvider');
        for (const fileUrl of job.outputFiles) {
          await cloudStorage.deleteFile(fileUrl);
        }
      }

      res.status(200).json({ success: true, message: 'Job deleted' });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  static async downloadJob(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = req.params.id as string;
      const job = await JobRepository.findById(id);
      
      if (!job || job.userId !== req.user.id) {
        res.status(404).json({ success: false, message: 'Job not found' });
        return;
      }

      if (job.status !== 'completed' || !job.outputFiles || job.outputFiles.length === 0) {
        res.status(400).json({ success: false, message: 'Job is not completed or has no output files' });
        return;
      }

      // outputFiles now stores Cloudinary URLs. Redirect the user to the URL.
      const fileUrl = job.outputFiles[0];
      res.redirect(fileUrl);
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }
}
