import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/unified_media_processor.dart';
import '../../../../core/services/media_processing_service.dart';
import '../../domain/models/audio_task_model.dart';

class BaseAudioToolScreen extends ConsumerStatefulWidget {
  final AudioToolType toolType;

  const BaseAudioToolScreen({super.key, required this.toolType});

  @override
  ConsumerState<BaseAudioToolScreen> createState() => _BaseAudioToolScreenState();
}

class _BaseAudioToolScreenState extends ConsumerState<BaseAudioToolScreen> {
  String get _title {
    return widget.toolType.name
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .replaceFirst(RegExp(r'^[a-z]'), widget.toolType.name[0].toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedMediaProcessor(
      title: _title,
      toolTypeEnumString: widget.toolType.name,
      mediaType: MediaType.audio,
      allowedExtensions: const ['mp3', 'wav', 'aac', 'ogg', 'm4a', 'flac', 'wma'],
      outputFormats: const ['mp3', 'wav', 'aac', 'ogg', 'm4a'],
    );
  }
}
