import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import morgan from 'morgan';
import jobRoutes from './routes/job.routes';
import uploadRoutes from './routes/upload.routes';
import apiKeyRoutes from './routes/api_key.routes';
import { setupSwagger } from './config/swagger';

export const app = express();

// Trust proxy for rate limiting (needed on Vercel/proxies)
app.set('trust proxy', 1);

// Security Middlewares
app.use(helmet());
app.use(cors());

// Body Parsers
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Request Logging
app.use(morgan('dev'));

// Rate Limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per `window` (here, per 15 minutes)
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api', apiLimiter);

// Swagger Documentation
setupSwagger(app);

// Routes
app.use('/api/v1/jobs', jobRoutes);
app.use('/api/v1/uploads', uploadRoutes);
app.use('/api/v1/keys', apiKeyRoutes);

// Health Check
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({ status: 'ok', timestamp: new Date() });
});

// Generic Error Handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('Unhandled Error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal Server Error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

export default app;
