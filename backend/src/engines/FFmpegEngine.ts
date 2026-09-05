import ffmpeg from 'fluent-ffmpeg';
import ffmpegStatic from 'ffmpeg-static';
const ffprobeStatic = require('ffprobe-static');
import path from 'path';
import { ConversionEngine, ConversionJobData, ConversionJobResult } from './ConversionEngine';
import fs from 'fs';

if (ffmpegStatic) {
  ffmpeg.setFfmpegPath(ffmpegStatic);
}
if (ffprobeStatic.path) {
  ffmpeg.setFfprobePath(ffprobeStatic.path);
}

export class FFmpegEngine implements ConversionEngine {
  supportedTools = [
    'convert_video', 'compress_video', 'edit_video',
    'convert_audio', 'compress_audio', 'edit_audio'
  ];

  async process(
    data: ConversionJobData,
    onProgress: (progress: number) => Promise<void>
  ): Promise<ConversionJobResult> {
    try {
      const inputFile = data.inputFiles[0];
      const { outputFormat, operation, compress, advanced } = data.params;
      
      const parsed = path.parse(inputFile);
      const outputFile = path.join(data.outputFolder, `${parsed.name}_output.${outputFormat || 'mp4'}`);

      // Probe input to understand streams
      const metadata = await this.probe(inputFile);

      return new Promise((resolve, reject) => {
        const command = ffmpeg(inputFile);

        // Quality preservation logic
        if (operation === 'convert_video' || operation === 'convert_audio') {
          if (!compress) {
            // Attempt to copy streams if formats are compatible
            // For now, doing a basic check or fallback to high quality
            if (this.canStreamCopy(metadata, outputFormat)) {
              command.outputOptions(['-c copy']);
            } else {
              command.outputOptions(['-preset slow', '-crf 18']); // High quality fallback
            }
          } else {
            // Compression requested
            command.outputOptions(['-preset medium', '-crf 28']);
          }
        }

        // Apply advanced options
        if (advanced) {
          if (advanced.resolution) command.size(advanced.resolution);
          if (advanced.fps) command.fps(advanced.fps);
          if (advanced.videoBitrate) command.videoBitrate(advanced.videoBitrate);
          if (advanced.audioBitrate) command.audioBitrate(advanced.audioBitrate);
          // Handle trim
          if (advanced.startTime) command.setStartTime(advanced.startTime);
          if (advanced.duration) command.setDuration(advanced.duration);
        }

        command
          .on('progress', async (progress) => {
            if (progress.percent) {
              await onProgress(Math.min(99, Math.round(progress.percent)));
            }
          })
          .on('end', async () => {
            await onProgress(100);
            resolve({
              success: true,
              outputFiles: [outputFile]
            });
          })
          .on('error', (err) => {
            reject(err);
          })
          .save(outputFile);
      });
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  }

  private probe(file: string): Promise<ffmpeg.FfprobeData> {
    return new Promise((resolve, reject) => {
      ffmpeg.ffprobe(file, (err, data) => {
        if (err) reject(err);
        else resolve(data);
      });
    });
  }

  private canStreamCopy(metadata: ffmpeg.FfprobeData, outputFormat: string): boolean {
    if (!metadata.streams || metadata.streams.length === 0) return false;
    
    const videoStream = metadata.streams.find(s => s.codec_type === 'video');
    const audioStream = metadata.streams.find(s => s.codec_type === 'audio');

    // A simple heuristic for format compatibility
    // MKV can hold almost anything
    if (outputFormat === 'mkv') return true;
    
    if (outputFormat === 'mp4') {
      const vCompatible = !videoStream || ['h264', 'hevc', 'mpeg4'].includes(videoStream.codec_name || '');
      const aCompatible = !audioStream || ['aac', 'mp3'].includes(audioStream.codec_name || '');
      return vCompatible && aCompatible;
    }

    if (outputFormat === 'mp3') {
      return !videoStream && audioStream?.codec_name === 'mp3';
    }

    return false;
  }
}
