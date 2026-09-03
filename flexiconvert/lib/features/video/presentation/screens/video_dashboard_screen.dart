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
