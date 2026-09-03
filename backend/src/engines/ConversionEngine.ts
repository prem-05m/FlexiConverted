export interface ConversionJobData {
  jobId: string;
  userId: string;
  inputFiles: string[]; // paths or URLs
  outputFolder: string;
  toolType: string;
  params: Record<string, any>;
}

export interface ConversionJobResult {
  success: boolean;
  outputFiles?: string[];
  error?: string;
  metadata?: Record<string, any>;
}

export interface ConversionEngine {
  /**
   * Identifies which tools this engine can handle.
   */
  supportedTools: string[];

  /**
   * Execute the conversion.
   * @param data Job data containing inputs and params
   * @param onProgress Callback to update job progress (0 to 100)
   */
  process(
    data: ConversionJobData,
    onProgress: (progress: number) => Promise<void>
  ): Promise<ConversionJobResult>;
}
