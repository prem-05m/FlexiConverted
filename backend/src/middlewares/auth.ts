import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { User } from '../models/User';

export interface AuthRequest extends Request {
  user?: any;
}

export const authenticate = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    const apiKey = req.headers['x-api-key'] as string;

    // Check API Key first
    if (apiKey) {
      const user = await User.findOne({ apiKey });
      if (user) {
        req.user = user;
        return next();
      }
    }

    // Check JWT
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret') as any;
      const user = await User.findById(decoded.userId);
      if (user) {
        req.user = user;
        return next();
      }
    }

    res.status(401).json({ success: false, message: 'Unauthorized' });
  } catch (error) {
    res.status(401).json({ success: false, message: 'Invalid Token or API Key' });
  }
};
