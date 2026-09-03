import mongoose, { Schema, Document } from 'mongoose';

export interface IJob extends Document {
  userId: mongoose.Types.ObjectId;
  toolType: string;
  status: 'pending' | 'processing' | 'completed' | 'failed' | 'paused' | 'cancelled';
  progress: number;
  inputFiles: string[];
  outputFiles?: string[];
  error?: string;
  params: Record<string, any>;
  createdAt: Date;
  updatedAt: Date;
}

const JobSchema: Schema = new Schema({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  toolType: { type: String, required: true },
  status: { 
    type: String, 
    enum: ['pending', 'processing', 'completed', 'failed', 'paused', 'cancelled'], 
    default: 'pending' 
  },
  progress: { type: Number, default: 0 },
  inputFiles: [{ type: String, required: true }],
  outputFiles: [{ type: String }],
  error: { type: String },
  params: { type: Schema.Types.Mixed, default: {} }
}, { timestamps: true });

export const Job = mongoose.model<IJob>('Job', JobSchema);
