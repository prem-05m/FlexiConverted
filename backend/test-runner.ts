import { decisionEngine } from './src/engines/DecisionEngine';
import path from 'path';
import fs from 'fs';
import { execSync } from 'child_process';

const tempDir = path.join(__dirname, 'temp');
const outDir = path.join(__dirname, 'outputs');

if (!fs.existsSync(tempDir)) fs.mkdirSync(tempDir);
if (!fs.existsSync(outDir)) fs.mkdirSync(outDir);

const testMp4 = path.join(tempDir, 'test.mp4');
const testMp3 = path.join(tempDir, 'test.mp3');
const testJpg = path.join(tempDir, 'test.jpg');

console.log('Generating test files...');
try {
  execSync(`npx ffmpeg-static -f lavfi -i testsrc=duration=1:size=320x240:rate=30 -f lavfi -i sine=frequency=1000:duration=1 -c:v libx264 -c:a aac "${testMp4}" -y`, { stdio: 'ignore' });
  execSync(`npx ffmpeg-static -f lavfi -i sine=frequency=1000:duration=1 "${testMp3}" -y`, { stdio: 'ignore' });
  execSync(`npx ffmpeg-static -f lavfi -i color=c=red:s=320x240 -vframes 1 "${testJpg}" -y`, { stdio: 'ignore' });
} catch (e: any) {
  console.log('Skipping generation, assuming files exist or error occurred:', e.message);
}

async function runTests() {
  console.log('\n--- TESTING VIDEO REMUX (MP4 -> MKV) ---');
  let res = await decisionEngine.processJob({
    jobId: 'test1', userId: 'user1', toolType: 'convert_video',
    inputFiles: [testMp4], outputFolder: outDir,
    params: { operation: 'convert_video', outputFormat: 'mkv' }
  }, async (p) => console.log('Progress:', p));
  console.log('Result:', res);

  console.log('\n--- TESTING AUDIO (MP3 -> WAV) ---');
  res = await decisionEngine.processJob({
    jobId: 'test2', userId: 'user1', toolType: 'convert_audio',
    inputFiles: [testMp3], outputFolder: outDir,
    params: { operation: 'convert_audio', outputFormat: 'wav' }
  }, async (p) => console.log('Progress:', p));
  console.log('Result:', res);

  console.log('\n--- TESTING IMAGE (JPG -> PNG) ---');
  res = await decisionEngine.processJob({
    jobId: 'test3', userId: 'user1', toolType: 'convert_image',
    inputFiles: [testJpg], outputFolder: outDir,
    params: { operation: 'convert_image', outputFormat: 'png' }
  }, async (p) => console.log('Progress:', p));
  console.log('Result:', res);
}

runTests().catch(console.error);
