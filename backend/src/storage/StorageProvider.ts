export interface StorageProvider {
  /**
   * Initialize the storage provider (e.g., ensure directories exist)
   */
  init(): Promise<void>;

  /**
   * Save a file to storage
   * @param buffer File data
   * @param filename Desired filename
   * @param folder Target folder (e.g., 'uploads', 'outputs')
   * @returns The relative or absolute path/URL to the saved file
   */
  saveFile(buffer: Buffer, filename: string, folder: string): Promise<string>;

  /**
   * Read a file from storage
   * @param path The path/URL of the file
   * @returns The file data as a Buffer
   */
  readFile(path: string): Promise<Buffer>;

  /**
   * Delete a file from storage
   * @param path The path/URL of the file
   */
  deleteFile(path: string): Promise<void>;

  /**
   * Get the full path for a given file name and folder
   * Useful for engines that require absolute paths (like FFmpeg)
   */
  getAbsolutePath(filename: string, folder: string): string;
}
