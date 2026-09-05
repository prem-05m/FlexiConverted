import { Request, Response, NextFunction } from 'express';
import { getAuth } from '../config/firebase';
import { UserRepository } from '../repositories/UserRepository';

export interface AuthRequest extends Request {
  user?: any;
}

export const authenticate = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    
    // Check Firebase ID Token
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      
      const decodedToken = await getAuth().verifyIdToken(token);
      
      // Get or create user in Firestore
      let user = await UserRepository.findById(decodedToken.uid);
      
      if (!user) {
        user = await UserRepository.createOrUpdate(decodedToken.uid, {
          email: decodedToken.email || '',
          name: decodedToken.name || '',
          role: 'user',
        });
      }
      
      req.user = user;
      return next();
    }

    res.status(401).json({ success: false, message: 'Unauthorized' });
  } catch (error) {
    console.error('Auth Error:', error);
    res.status(401).json({ success: false, message: 'Invalid Token' });
  }
};
