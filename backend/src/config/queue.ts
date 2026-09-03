import { Queue } from 'bullmq';
import IORedis from 'ioredis';
import dotenv from 'dotenv';

dotenv.config();

const redisUrl = process.env.REDIS_URL;

if (!redisUrl) {
  console.error('==================================================');
  console.error('ERROR: REDIS_URL is not configured in environment.');
  console.error('Redis is required for the conversion queue backend.');
  console.error('Please configure a cloud Redis provider (or local Redis).');
  console.error('==================================================');
  // We can still create a dummy connection or just let it fail gracefully
}

export const redisConnection = new IORedis(redisUrl || 'redis://localhost:6379', {
  lazyConnect: true, // Don't connect immediately, prevents ECONNREFUSED spam on startup
  maxRetriesPerRequest: null,
  retryStrategy: (times) => {
    if (!redisUrl && times > 3) {
      console.warn('Gracefully stopping Redis retries (missing REDIS_URL configuration).');
      return null; // Stop retrying
    }
    return Math.min(times * 50, 2000);
  }
});

redisConnection.on('error', (err) => {
  if (!redisUrl) {
    // Suppress spammy errors if it wasn't configured
    return;
  }
  console.error('Redis Connection Error:', err);
});

export const CONVERSION_QUEUE_NAME = 'conversion-queue';

export const conversionQueue = new Queue(CONVERSION_QUEUE_NAME, {
  connection: redisConnection,
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 1000,
    },
    removeOnComplete: true,
  },
});
