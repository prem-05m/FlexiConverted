import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { User } from '../models/User';
import crypto from 'crypto';

export class AuthController {
  static async register(req: Request, res: Response): Promise<void> {
    try {
      const { email, password, name } = req.body;
      if (!email || !password || !name) {
        res.status(400).json({ success: false, message: 'Missing fields' });
        return;
      }
      
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        res.status(400).json({ success: false, message: 'Email already exists' });
        return;
      }

      const passwordHash = await bcrypt.hash(password, 10);
      const apiKey = crypto.randomUUID();

      const user = await User.create({ email, passwordHash, name, apiKey });
      
      const token = jwt.sign({ userId: user._id, role: user.role }, process.env.JWT_SECRET || 'fallback_secret', { expiresIn: '7d' });

      res.status(201).json({ success: true, token, apiKey, user: { id: user._id, email, name } });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  static async login(req: Request, res: Response): Promise<void> {
    try {
      const { email, password } = req.body;
      if (!email || !password) {
        res.status(400).json({ success: false, message: 'Missing fields' });
        return;
      }

      const user = await User.findOne({ email });
      if (!user) {
        res.status(401).json({ success: false, message: 'Invalid credentials' });
        return;
      }

      const isMatch = await bcrypt.compare(password, user.passwordHash);
      if (!isMatch) {
        res.status(401).json({ success: false, message: 'Invalid credentials' });
        return;
      }

      const token = jwt.sign({ userId: user._id, role: user.role }, process.env.JWT_SECRET || 'fallback_secret', { expiresIn: '7d' });

      res.status(200).json({ success: true, token, apiKey: user.apiKey, user: { id: user._id, email: user.email, name: user.name } });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }
}
