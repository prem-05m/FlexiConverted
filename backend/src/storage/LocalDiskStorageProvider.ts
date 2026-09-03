import fs from 'fs/promises';
import path from 'path';
import { StorageProvider } from './StorageProvider';

export class LocalDiskStorageProvider implements StorageProvider {
  private readonly rootDir: string;

  constructor() {
    this.rootDir = path.resolve(process.cwd(), '..'); 
    // Wait, process.cwd() is backend/, so '..' would be FlexiConvert/. 
    // We want the storage folders (uploads, outputs, temp) to be inside backend.
    this.rootDir = process.cwd();
  }

  async init(): Promise<void> {
    const dirs = ['uploads', 'temp', 'outputs'];
    for (const dir of dirs) {
      const dirPath = path.join(this.rootDir, dir);
      try {
        await fs.access(dirPath);
      } catch {
        await fs.mkdir(dirPath, { recursive: true });
      }
    }
  }

  async saveFile(buffer: Buffer, filename: string, folder: string): Promise<string> {
    const fullPath = this.getAbsolutePath(filename, folder);
    await fs.writeFile(fullPath, buffer);
    return fullPath;
  }

  async readFile(filePath: string): Promise<Buffer> {
    return fs.readFile(filePath);
  }

  async deleteFile(filePath: string): Promise<void> {
    try {
      await fs.unlink(filePath);
    } catch (error) {
      console.warn(`Failed to delete file: ${filePath}`, error);
    }
  }

  getAbsolutePath(filename: string, folder: string): string {
    return path.join(this.rootDir, folder, filename);
  }
}

export const storage = new LocalDiskStorageProvider();
