import { Worker, Job as BullJob } from 'bullmq';
import { redisConnection, CONVERSION_QUEUE_NAME } from '../config/queue';
import { JobRepository } from '../repositories/JobRepository';
import { decisionEngine } from '../engines/DecisionEngine';
import { storage } from '../storage/LocalDiskStorageProvider';
import { cloudStorage } from '../storage/CloudinaryStorageProvider';
import fs from 'fs/promises';

export class JobWorker {
  private worker: Worker;

  constructor() {
    this.worker = new Worker(CONVERSION_QUEUE_NAME, this.processJob.bind(this), {
      connection: redisConnection,
      concurrency: 2 // Max concurrent jobs to protect server CPU/RAM
    });

    this.worker.on('completed', (job) => {
      console.log(`Job ${job.id} completed successfully`);
    });

    this.worker.on('failed', (job, err) => {
      console.error(`Job ${job?.id} failed with error:`, err);
    });
  }

  private async processJob(bullJob: BullJob) {
    const { jobId, inputFiles, toolType, params } = bullJob.data;
    const absoluteInputFiles: string[] = [];
    
    try {
      // 1. Mark job as processing
      await JobRepository.update(jobId, { status: 'processing', progress: 0 });

      // 2. Resolve absolute paths for input files
      for (const file of inputFiles) {
        absoluteInputFiles.push(storage.getAbsolutePath(file, 'uploads'));
      }

      // 3. Resolve absolute output folder
      const outputFolder = storage.getAbsolutePath('', 'outputs');

      // 4. Pass to decision engine
      const result = await decisionEngine.processJob({
        jobId,
        userId: bullJob.data.userId,
        inputFiles: absoluteInputFiles,
        outputFolder,
        toolType,
        params
      }, async (progress: number) => {
        // Update BullMQ progress
        await bullJob.updateProgress(progress);
        
        // Optionally update Firestore progress (throttle this in a real prod env)
        await JobRepository.update(jobId, { progress });
      });

      // 5. Handle result
      if (result.success) {
        const cloudUrls: string[] = [];
        
        // Upload each output file to Cloudinary
        for (const outputFile of (result.outputFiles || [])) {
          const buffer = await fs.readFile(outputFile);
          const filename = outputFile.split(/[\/\\]/).pop() || 'output';
          const url = await cloudStorage.saveFile(buffer, filename, 'outputs');
          cloudUrls.push(url);
          
          // Delete local output file
          await fs.unlink(outputFile).catch(console.error);
        }

        await JobRepository.update(jobId, {
          status: 'completed',
          progress: 100,
          outputFiles: cloudUrls, // Now stores Cloudinary URLs
        });
        
        // Cleanup local input files
        for (const file of absoluteInputFiles) {
          await fs.unlink(file).catch(console.error);
        }

        return result;
      } else {
        throw new Error(result.error || 'Unknown conversion error');
      }

    } catch (error: any) {
      await JobRepository.update(jobId, {
        status: 'failed',
        error: error.message
      });
      
      // Cleanup local input files on failure
      for (const file of absoluteInputFiles) {
        await fs.unlink(file).catch(console.error);
      }
      
      throw error;
    }
  }

  close() {
    return this.worker.close();
  }
}

export const jobWorker = new JobWorker();
