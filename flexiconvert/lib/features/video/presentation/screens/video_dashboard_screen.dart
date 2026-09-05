import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/web_constrained_box.dart';
import '../../domain/models/video_task_model.dart';
import '../widgets/video_tool_card.dart';

class VideoDashboardScreen extends StatelessWidget {
  const VideoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolInfo(VideoToolType.convertFormat, 'Convert Video', 'MP4, AVI, MKV, etc.', Icons.switch_video, Colors.blue),
      _ToolInfo(VideoToolType.compress, 'Compress Video', 'Reduce file size', Icons.compress, Colors.green),
      _ToolInfo(VideoToolType.trim, 'Trim Video', 'Cut start or end', Icons.content_cut, Colors.orange),
      _ToolInfo(VideoToolType.merge, 'Merge Videos', 'Combine multiple videos', Icons.merge_type, Colors.red),
      _ToolInfo(VideoToolType.extractAudio, 'Extract Audio', 'Save as MP3/AAC', Icons.audiotrack, Colors.purple),
      _ToolInfo(VideoToolType.mute, 'Mute Video', 'Remove audio track', Icons.volume_off, Colors.teal),
      _ToolInfo(VideoToolType.changeResolution, 'Resolution', 'Change video size', Icons.aspect_ratio, Colors.indigo),
      _ToolInfo(VideoToolType.changeFps, 'Change FPS', 'Modify frame rate', Icons.speed, Colors.pink),
      _ToolInfo(VideoToolType.rotate, 'Rotate Video', 'Rotate video angle', Icons.rotate_right, Colors.cyan),
      _ToolInfo(VideoToolType.generateGif, 'Video to GIF', 'Create animated GIF', Icons.gif, Colors.amber),
      
      // New Tools
      _ToolInfo(VideoToolType.cutSplit, 'Cut / Split', 'Split video into parts', Icons.splitscreen, Colors.brown),
      _ToolInfo(VideoToolType.crop, 'Crop Video', 'Crop video frame', Icons.crop, Colors.redAccent),
      _ToolInfo(VideoToolType.flip, 'Flip Video', 'Mirror video horizontally/vertically', Icons.flip, Colors.deepPurple),
      _ToolInfo(VideoToolType.addAudio, 'Add Audio', 'Mix audio with video', Icons.library_music, Colors.indigoAccent),
      _ToolInfo(VideoToolType.replaceAudio, 'Replace Audio', 'Change video soundtrack', Icons.audio_file, Colors.blueGrey),
      _ToolInfo(VideoToolType.removeAudio, 'Remove Audio', 'Strip sound completely', Icons.music_off, Colors.grey),
      _ToolInfo(VideoToolType.gifToVideo, 'GIF to Video', 'Convert GIF to MP4', Icons.movie_creation, Colors.lightGreen),
      _ToolInfo(VideoToolType.videoToImages, 'Video to Images', 'Extract all frames', Icons.burst_mode, Colors.deepOrange),
      _ToolInfo(VideoToolType.imagesToVideo, 'Images to Video', 'Create video from images', Icons.video_call, Colors.tealAccent),
      _ToolInfo(VideoToolType.generateThumbnail, 'Generate Thumbnail', 'Extract single frame', Icons.image, Colors.pinkAccent),
      _ToolInfo(VideoToolType.addText, 'Add Text', 'Add subtitles or text', Icons.subtitles, Colors.blueAccent),
      _ToolInfo(VideoToolType.addWatermark, 'Add Watermark', 'Overlay image logo', Icons.branding_watermark, Colors.lightBlue),
      _ToolInfo(VideoToolType.changeAspectRatio, 'Aspect Ratio', '16:9, 4:3, 1:1, etc.', Icons.crop_16_9, Colors.amberAccent),
      _ToolInfo(VideoToolType.batchConvert, 'Batch Convert', 'Process multiple videos', Icons.video_collection, Colors.deepPurpleAccent),
    ];

    return Scaffold(
      appBar: const AnimatedAppBar(title: 'Video Tools'),
      body: WebConstrainedBox(
        maxWidth: 800,
        child: GridView.builder(
          padding: EdgeInsets.all(AppSpacing.lg),
          itemCount: tools.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final tool = tools[index];
            return VideoToolCard(
              toolType: tool.type,
              title: tool.title,
              description: tool.desc,
              icon: tool.icon,
              color: tool.color,
              onTap: () {
                context.go('${RouteConstants.home}/${RouteConstants.video}/${tool.type.name}');
              },
            ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
          },
        ),
      ),
    );
  }
}

class _ToolInfo {
  final VideoToolType type;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  _ToolInfo(this.type, this.title, this.desc, this.icon, this.color);
}
