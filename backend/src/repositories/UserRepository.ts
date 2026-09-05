import { getFirestore } from '../config/firebase';

export interface User {
  id: string; // The Firebase UID
  email: string;
  name?: string;
  role: 'user' | 'admin';
  createdAt: Date;
  updatedAt: Date;
}

export class UserRepository {
  private static get collection() {
    return getFirestore().collection('users');
  }

  static async findById(id: string): Promise<User | null> {
    const doc = await this.collection.doc(id).get();
    if (!doc.exists) {
      return null;
    }
    const data = doc.data();
    return {
      id: doc.id,
      email: data?.email,
      name: data?.name,
      role: data?.role || 'user',
      createdAt: data?.createdAt?.toDate() || new Date(),
      updatedAt: data?.updatedAt?.toDate() || new Date(),
    };
  }

  static async createOrUpdate(id: string, userData: Partial<User>): Promise<User> {
    const docRef = this.collection.doc(id);
    const now = new Date();
    
    await docRef.set({
      ...userData,
      updatedAt: now,
      createdAt: userData.createdAt || now,
    }, { merge: true });

    return (await this.findById(id)) as User;
  }
}
