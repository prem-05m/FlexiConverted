import sharp from 'sharp';
import path from 'path';
import { ConversionEngine, ConversionJobData, ConversionJobResult } from './ConversionEngine';

export class SharpEngine implements ConversionEngine {
  supportedTools = ['convert_image', 'compress_image', 'edit_image'];

  async process(
    data: ConversionJobData,
    onProgress: (progress: number) => Promise<void>
  ): Promise<ConversionJobResult> {
    try {
      const inputFile = data.inputFiles[0];
      const { outputFormat, operation, compress, advanced } = data.params;
      
      const parsed = path.parse(inputFile);
      const outputFile = path.join(data.outputFolder, `${parsed.name}_output.${outputFormat || 'png'}`);

      // We do not have granular progress for sharp (it's fast), so we just simulate or jump to 50% then 100%
      await onProgress(10);

      let image = sharp(inputFile);

      // Metadata preservation - keep original metadata where possible
      image = image.withMetadata(); 

      // Edits
      if (advanced) {
        if (advanced.width || advanced.height) {
          image = image.resize({
            width: advanced.width ? parseInt(advanced.width) : undefined,
            height: advanced.height ? parseInt(advanced.height) : undefined,
            fit: 'inside', // Preserve aspect ratio by default
            withoutEnlargement: true // Don't upsize unless forced
          });
        }
        if (advanced.rotate) image = image.rotate(parseInt(advanced.rotate));
        if (advanced.flip) image = image.flip();
        if (advanced.flop) image = image.flop();
        
        // Basic adjustments
        if (advanced.grayscale) image = image.grayscale();
        if (advanced.blur) image = image.blur(parseFloat(advanced.blur));
      }

      await onProgress(50);

      // Format and Quality (Quality preservation rule)
      const format = (outputFormat || 'png').toLowerCase();
      
      // Default maximum practical quality unless compress is true
      const quality = compress ? 60 : 100;

      switch(format) {
        case 'jpeg':
        case 'jpg':
          image = image.jpeg({ quality, chromaSubsampling: compress ? '4:2:0' : '4:4:4' });
          break;
        case 'png':
          image = image.png({ quality, compressionLevel: compress ? 9 : 6 });
          break;
        case 'webp':
          image = image.webp({ quality, lossless: !compress });
          break;
        case 'gif':
          image = image.gif();
          break;
        case 'tiff':
          image = image.tiff({ quality });
          break;
        default:
          image = image.toFormat(format as any);
      }

      await image.toFile(outputFile);
      
      await onProgress(100);

      return {
        success: true,
        outputFiles: [outputFile]
      };
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  }
}
