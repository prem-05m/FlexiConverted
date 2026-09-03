import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/web_constrained_box.dart';
import '../../domain/models/audio_task_model.dart';
import '../widgets/audio_tool_card.dart';

class AudioDashboardScreen extends StatelessWidget {
  const AudioDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolInfo(AudioToolType.convertFormat, 'Convert Audio', 'MP3, WAV, AAC, etc.', Icons.audiotrack, Colors.blue),
      _ToolInfo(AudioToolType.compress, 'Compress Audio', 'Reduce file size', Icons.compress, Colors.green),
      _ToolInfo(AudioToolType.trim, 'Trim Audio', 'Cut start or end', Icons.content_cut, Colors.orange),
      _ToolInfo(AudioToolType.merge, 'Merge Audio', 'Combine multiple files', Icons.merge_type, Colors.red),
      _ToolInfo(AudioToolType.normalizeVolume, 'Normalize Volume', 'Even out sound levels', Icons.volume_up, Colors.purple),
      _ToolInfo(AudioToolType.increaseVolume, 'Increase Volume', 'Make audio louder', Icons.volume_up, Colors.teal),
      _ToolInfo(AudioToolType.reduceNoise, 'Reduce Noise', 'Clean up background noise', Icons.noise_control_off, Colors.indigo),
      _ToolInfo(AudioToolType.fadeIn, 'Fade In', 'Gradually increase volume', Icons.arrow_forward_ios, Colors.pink),
      _ToolInfo(AudioToolType.fadeOut, 'Fade Out', 'Gradually decrease volume', Icons.arrow_back_ios, Colors.cyan),
      _ToolInfo(AudioToolType.metadataEditor, 'Edit Metadata', 'Change title, artist, etc.', Icons.edit, Colors.amber),
    ];

    return Scaffold(
      appBar: const AnimatedAppBar(title: 'Audio Tools'),
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
          return AudioToolCard(
            toolType: tool.type,
            title: tool.title,
            description: tool.desc,
            icon: tool.icon,
            color: tool.color,
            onTap: () {
              context.go('${RouteConstants.home}/${RouteConstants.audio}/${tool.type.name}');
            },
          ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
        },
      ),
      ),
    );
  }
}

class _ToolInfo {
  final AudioToolType type;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  _ToolInfo(this.type, this.title, this.desc, this.icon, this.color);
}
