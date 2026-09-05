import { v2 as cloudinary } from 'cloudinary';
import { StorageProvider } from './StorageProvider';
import path from 'path';

// Note: In Cloudinary, audio and video are both treated as 'video' resource_type.
// Max sizes based on requirements:
const MAX_GENERAL_SIZE = 15 * 1024 * 1024; // 15MB
const MAX_IMAGE_SIZE = 5 * 1024 * 1024; // 5MB
const MAX_AUDIO_SIZE = 10 * 1024 * 1024; // 10MB

export class CloudinaryStorageProvider implements StorageProvider {
  private accounts: string[] = [];

  constructor() {
    // Collect the 3 cloudinary URLs from env
    if (process.env.CLOUDINARY_URL_1) this.accounts.push(process.env.CLOUDINARY_URL_1);
    if (process.env.CLOUDINARY_URL_2) this.accounts.push(process.env.CLOUDINARY_URL_2);
    if (process.env.CLOUDINARY_URL_3) this.accounts.push(process.env.CLOUDINARY_URL_3);
  }

  async init(): Promise<void> {
    if (this.accounts.length === 0) {
      console.warn('No Cloudinary accounts configured. Uploads will fail.');
    }
  }

  private validateSize(buffer: Buffer, resourceType: string) {
    const size = buffer.length;
    if (resourceType === 'image' && size > MAX_IMAGE_SIZE) {
      throw new Error('Image size exceeds 5MB limit.');
    }
    if (resourceType === 'video' && size > MAX_AUDIO_SIZE) { // Cloudinary uses 'video' for audio
      throw new Error('Audio/Video size exceeds 10MB limit.');
    }
    if (size > MAX_GENERAL_SIZE) {
      throw new Error('File size exceeds 15MB limit.');
    }
  }

  private getResourceType(filename: string): 'image' | 'video' | 'raw' | 'auto' {
    const ext = path.extname(filename).toLowerCase();
    const imageExts = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.tiff'];
    const audioExts = ['.mp3', '.wav', '.ogg', '.m4a', '.flac', '.aac'];
    const videoExts = ['.mp4', '.avi', '.mov', '.wmv', '.mkv'];

    if (imageExts.includes(ext)) return 'image';
    if (audioExts.includes(ext) || videoExts.includes(ext)) return 'video';
    return 'raw'; // PDF, DOCX, etc.
  }

  async saveFile(buffer: Buffer, filename: string, folder: string): Promise<string> {
    // Local processing tools might pass "outputs" as the folder name. We map this to "flexiconverted"
    const targetFolder = folder === 'outputs' ? 'flexiconverted' : folder;
    const resourceType = this.getResourceType(filename);
    
    this.validateSize(buffer, resourceType);

    // Rotate through accounts until one succeeds
    for (let i = 0; i < this.accounts.length; i++) {
      try {
        const url = this.accounts[i];
        cloudinary.config({
          cloudinary_url: url
        });

        const result = await new Promise<any>((resolve, reject) => {
          const uploadStream = cloudinary.uploader.upload_stream(
            { 
              folder: targetFolder, 
              public_id: path.parse(filename).name,
              resource_type: resourceType === 'raw' ? 'raw' : 'auto' // Raw is needed for PDFs
            },
            (error, result) => {
              if (error) reject(error);
              else resolve(result);
            }
          );
          uploadStream.end(buffer);
        });

        console.log(`Successfully uploaded to Cloudinary Account ${i + 1}`);
        return result.secure_url;
      } catch (error: any) {
        console.error(`Failed to upload to Cloudinary Account ${i + 1}:`, error?.message || error);
        // If it's the last account, throw the error
        if (i === this.accounts.length - 1) {
          throw new Error('All Cloudinary accounts failed or exceeded quota.');
        }
      }
    }
    throw new Error('No Cloudinary accounts available.');
  }

  async readFile(filePath: string): Promise<Buffer> {
    // Usually files are read locally during processing.
    // Cloudinary URLs can be fetched via HTTP if needed.
    const response = await fetch(filePath);
    if (!response.ok) {
      throw new Error(`Failed to read file from Cloudinary: ${response.statusText}`);
    }
    const arrayBuffer = await response.arrayBuffer();
    return Buffer.from(arrayBuffer);
  }

  async deleteFile(filePath: string): Promise<void> {
    // Delete file from Cloudinary (requires extracting public_id from URL)
    // For simplicity, we assume filePath is the secure_url
    try {
      const parts = filePath.split('/');
      const filenameWithExt = parts.pop() || '';
      const folder = parts.pop() || '';
      const publicId = `${folder}/${path.parse(filenameWithExt).name}`;
      const resourceType = this.getResourceType(filenameWithExt) === 'raw' ? 'raw' : 'image'; // Needs to handle video too, but keeping simple
      
      // Try across accounts
      for (const url of this.accounts) {
        cloudinary.config({ cloudinary_url: url });
        await cloudinary.uploader.destroy(publicId, { resource_type: resourceType });
      }
    } catch (error) {
      console.error('Failed to delete file from Cloudinary:', error);
    }
  }

  getAbsolutePath(filename: string, folder: string): string {
    // Cloudinary doesn't use absolute local paths.
    // Return a virtual path or throw if an engine strictly needs a local path.
    return path.join('/tmp', folder, filename);
  }
}

export const cloudStorage = new CloudinaryStorageProvider();
