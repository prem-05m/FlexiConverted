import { ConversionEngine, ConversionJobData, ConversionJobResult } from './ConversionEngine';
import { FFmpegEngine } from './FFmpegEngine';
import { SharpEngine } from './SharpEngine';

export class DecisionEngine {
  private engines: ConversionEngine[] = [];

  constructor() {
    this.engines.push(new FFmpegEngine());
    this.engines.push(new SharpEngine());
  }

  getEngineForTool(toolType: string): ConversionEngine | undefined {
    return this.engines.find(e => e.supportedTools.includes(toolType));
  }

  async processJob(
    data: ConversionJobData,
    onProgress: (progress: number) => Promise<void>
  ): Promise<ConversionJobResult> {
    const engine = this.getEngineForTool(data.toolType);
    if (!engine) {
      return { success: false, error: `No engine found for tool type: ${data.toolType}` };
    }
    return engine.process(data, onProgress);
  }
}

export const decisionEngine = new DecisionEngine();
