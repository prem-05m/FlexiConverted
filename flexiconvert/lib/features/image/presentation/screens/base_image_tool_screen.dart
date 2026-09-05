import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/unified_media_processor.dart';
import '../../../../core/services/media_processing_service.dart';
import '../../domain/models/image_task_model.dart';

class BaseImageToolScreen extends ConsumerStatefulWidget {
  final ImageToolType toolType;

  const BaseImageToolScreen({super.key, required this.toolType});

  @override
  ConsumerState<BaseImageToolScreen> createState() => _BaseImageToolScreenState();
}

class _BaseImageToolScreenState extends ConsumerState<BaseImageToolScreen> {
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
      mediaType: MediaType.image,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif'],
      outputFormats: const ['jpg', 'png', 'webp', 'bmp', 'gif'],
    );
  }
}
