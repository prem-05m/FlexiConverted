import { Worker, Job as BullJob } from 'bullmq';
import { CONVERSION_QUEUE_NAME, redisConnection } from '../config/queue';
import { Job } from '../models/Job';
import { ConversionJobData } from '../engines/ConversionEngine';

export const conversionWorker = new Worker(
  CONVERSION_QUEUE_NAME,
  async (bullJob: BullJob<ConversionJobData>) => {
    const { jobId, toolType } = bullJob.data;
    
    console.log(`Processing job ${jobId} for tool ${toolType}`);
    
    // 1. Update Job status to processing
    await Job.findByIdAndUpdate(jobId, { status: 'processing', progress: 0 });

    try {
      // Stub: Here we would route to the appropriate engine based on `toolType`
      // e.g., if (toolType.startsWith('pdf')) pdfEngine.process(...)
      
      // Simulate processing
      for (let i = 1; i <= 10; i++) {
        await new Promise((resolve) => setTimeout(resolve, 500)); // 0.5s work
        const progress = i * 10;
        await bullJob.updateProgress(progress);
        await Job.findByIdAndUpdate(jobId, { progress });
      }

      // 2. Mark complete
      await Job.findByIdAndUpdate(jobId, { 
        status: 'completed', 
        progress: 100,
        outputFiles: ['simulated_output_file.ext'] 
      });
      console.log(`Job ${jobId} completed successfully`);
      return { success: true };
    } catch (error: any) {
      console.error(`Job ${jobId} failed:`, error);
      await Job.findByIdAndUpdate(jobId, { 
        status: 'failed', 
        error: error.message 
      });
      throw error;
    }
  },
  { connection: redisConnection }
);

conversionWorker.on('completed', (job) => {
  console.log(`${job.id} has completed!`);
});

conversionWorker.on('failed', (job, err) => {
  console.log(`${job?.id} has failed with ${err.message}`);
});
