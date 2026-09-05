import { getFirestore } from '../config/firebase';

export interface Job {
  id?: string;
  userId: string;
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

export class JobRepository {
  private static get collection() {
    return getFirestore().collection('jobs');
  }

  static async create(jobData: Omit<Job, 'id' | 'createdAt' | 'updatedAt'>): Promise<Job> {
    const now = new Date();
    const docRef = await this.collection.add({
      ...jobData,
      createdAt: now,
      updatedAt: now,
    });
    
    return this.findById(docRef.id) as Promise<Job>;
  }

  static async findById(id: string): Promise<Job | null> {
    const doc = await this.collection.doc(id).get();
    if (!doc.exists) {
      return null;
    }
    const data = doc.data() as any;
    return {
      id: doc.id,
      ...data,
      createdAt: data.createdAt?.toDate() || new Date(),
      updatedAt: data.updatedAt?.toDate() || new Date(),
    };
  }

  static async findByUserId(userId: string): Promise<Job[]> {
    const snapshot = await this.collection
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .get();
      
    return snapshot.docs.map((doc: any) => {
      const data = doc.data() as any;
      return {
        id: doc.id,
        ...data,
        createdAt: data.createdAt?.toDate() || new Date(),
        updatedAt: data.updatedAt?.toDate() || new Date(),
      } as Job;
    });
  }

  static async update(id: string, updateData: Partial<Job>): Promise<Job | null> {
    const docRef = this.collection.doc(id);
    await docRef.update({
      ...updateData,
      updatedAt: new Date()
    });
    return this.findById(id);
  }
  
  static async delete(id: string): Promise<void> {
    await this.collection.doc(id).delete();
  }
}
