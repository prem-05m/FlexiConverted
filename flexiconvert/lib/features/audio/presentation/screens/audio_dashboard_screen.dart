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
      _ToolInfo(AudioToolType.convertFormat, 'Convert Audio', 'MP3, WAV, FLAC, etc.', Icons.audio_file, Colors.blue),
      _ToolInfo(AudioToolType.compress, 'Compress Audio', 'Reduce file size', Icons.compress, Colors.green),
      _ToolInfo(AudioToolType.trim, 'Trim Audio', 'Cut start or end', Icons.content_cut, Colors.orange),
      _ToolInfo(AudioToolType.merge, 'Merge Audio', 'Combine multiple files', Icons.merge_type, Colors.red),
      _ToolInfo(AudioToolType.extractAudio, 'Extract Audio', 'Get audio from video', Icons.video_file, Colors.purple),
      _ToolInfo(AudioToolType.normalizeVolume, 'Normalize Volume', 'Even out audio levels', Icons.graphic_eq, Colors.teal),
      _ToolInfo(AudioToolType.increaseVolume, 'Increase Volume', 'Boost audio volume', Icons.volume_up, Colors.indigo),
      _ToolInfo(AudioToolType.reduceNoise, 'Reduce Noise', 'Remove background noise', Icons.noise_control_off, Colors.pink),
      _ToolInfo(AudioToolType.fadeIn, 'Fade In', 'Gradual volume increase', Icons.trending_up, Colors.cyan),
      
      // New Tools
      _ToolInfo(AudioToolType.fadeOut, 'Fade Out', 'Gradual volume decrease', Icons.trending_down, Colors.blueGrey),
      _ToolInfo(AudioToolType.split, 'Cut / Split', 'Split audio into parts', Icons.splitscreen, Colors.brown),
      _ToolInfo(AudioToolType.addAudioToVideo, 'Add to Video', 'Mix audio with video', Icons.video_call, Colors.redAccent),
      _ToolInfo(AudioToolType.changePitch, 'Change Pitch', 'Alter audio pitch', Icons.multiline_chart, Colors.deepPurple),
      _ToolInfo(AudioToolType.stereoMono, 'Mono ↔ Stereo', 'Change channel layout', Icons.speaker_group, Colors.indigoAccent),
      _ToolInfo(AudioToolType.removeSilence, 'Remove Silence', 'Delete silent gaps', Icons.hearing_disabled, Colors.grey),
      _ToolInfo(AudioToolType.metadataEditor, 'Metadata Editor', 'Edit ID3 tags', Icons.edit_note, Colors.lightGreen),
      _ToolInfo(AudioToolType.removeMetadata, 'Remove Metadata', 'Strip all tags', Icons.security, Colors.deepOrange),
      _ToolInfo(AudioToolType.batchConvert, 'Batch Convert', 'Process multiple files', Icons.library_music, Colors.tealAccent),
      _ToolInfo(AudioToolType.audioWaveform, 'Audio Waveform', 'Generate waveform image', Icons.waves, Colors.blueAccent),
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
