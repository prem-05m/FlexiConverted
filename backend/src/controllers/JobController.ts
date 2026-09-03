import { Request, Response } from 'express';
import { Job } from '../models/Job';
import { conversionQueue } from '../config/queue';
import { storage } from '../storage/LocalDiskStorageProvider';
import { AuthRequest } from '../middlewares/auth';
import { v4 as uuidv4 } from 'uuid';

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

      // Save files via StorageProvider
      const inputFiles: string[] = [];
      for (const file of files) {
        const ext = file.originalname.split('.').pop() || '';
        const filename = `${uuidv4()}.${ext}`;
        const path = await storage.saveFile(file.buffer, filename, 'uploads');
        inputFiles.push(filename); 
      }

      const parsedParams = params ? JSON.parse(params) : {};

      const jobDoc = await Job.create({
        userId: req.user._id,
        toolType,
        inputFiles,
        status: 'pending',
        params: parsedParams
      });

      // Add to BullMQ
      await conversionQueue.add('convert', {
        jobId: jobDoc._id.toString(),
        userId: req.user._id.toString(),
        inputFiles,
        outputFolder: 'outputs',
        toolType,
        params: parsedParams
      }, {
        jobId: jobDoc._id.toString()
      });

      res.status(201).json({ success: true, job: jobDoc });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  static async getStatus(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const job = await Job.findOne({ _id: id, userId: req.user._id });
      if (!job) {
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
      const jobs = await Job.find({ userId: req.user._id }).sort({ createdAt: -1 });
      res.status(200).json({ success: true, jobs });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  static async deleteJob(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const job = await Job.findOneAndDelete({ _id: id, userId: req.user._id });
      
      if (!job) {
        res.status(404).json({ success: false, message: 'Job not found' });
        return;
      }

      // Cleanup files
      if (job.inputFiles) {
        for (const file of job.inputFiles) {
          await storage.deleteFile(storage.getAbsolutePath(file, 'uploads'));
        }
      }
      if (job.outputFiles) {
        for (const file of job.outputFiles) {
          await storage.deleteFile(storage.getAbsolutePath(file, 'outputs'));
        }
      }

      res.status(200).json({ success: true, message: 'Job deleted' });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }
}
