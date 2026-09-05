import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/unified_media_processor.dart';
import '../../../../core/services/media_processing_service.dart';
import '../../domain/models/video_task_model.dart';

class BaseVideoToolScreen extends ConsumerStatefulWidget {
  final VideoToolType toolType;

  const BaseVideoToolScreen({super.key, required this.toolType});

  @override
  ConsumerState<BaseVideoToolScreen> createState() => _BaseVideoToolScreenState();
}

class _BaseVideoToolScreenState extends ConsumerState<BaseVideoToolScreen> {
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
      mediaType: MediaType.video,
      allowedExtensions: const ['mp4', 'avi', 'mov', 'mkv', 'flv', 'wmv', 'webm', 'mpeg'],
      outputFormats: const ['mp4', 'avi', 'mov', 'mkv'],
    );
  }
}
