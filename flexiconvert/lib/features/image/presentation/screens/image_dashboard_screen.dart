import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/web_constrained_box.dart';
import '../../domain/models/image_task_model.dart';
import '../widgets/image_tool_card.dart';

class ImageDashboardScreen extends StatelessWidget {
  const ImageDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolInfo(ImageToolType.editImage, 'Image Edits', 'Pro Editor, Crop, Draw, Filters', Icons.edit_attributes, Colors.pink),
      _ToolInfo(ImageToolType.convertFormat, 'Convert Image', 'JPG, PNG, WEBP, BMP, etc.', Icons.transform, Colors.blue),
      _ToolInfo(ImageToolType.compress, 'Compress Image', 'Reduce image file size', Icons.compress, Colors.orange),
      _ToolInfo(ImageToolType.crop, 'Crop Image', 'Crop to specific aspect ratio', Icons.crop, Colors.red),
      _ToolInfo(ImageToolType.rotate, 'Rotate Image', 'Rotate by 90/180/270 degrees', Icons.rotate_right, Colors.purple),
      _ToolInfo(ImageToolType.flip, 'Flip Image', 'Mirror image horizontally/vertically', Icons.flip, Colors.teal),
      
      // New Tools
      _ToolInfo(ImageToolType.adjust, 'Adjust Image', 'Brightness, contrast, saturation', Icons.tune, Colors.indigo),
      _ToolInfo(ImageToolType.addText, 'Add Text', 'Add text overlay to image', Icons.text_fields, Colors.brown),
      _ToolInfo(ImageToolType.addWatermark, 'Add Watermark', 'Add logo or watermark', Icons.branding_watermark, Colors.deepOrange),
      _ToolInfo(ImageToolType.blur, 'Blur Image', 'Apply blur effects', Icons.blur_on, Colors.blueGrey),
      _ToolInfo(ImageToolType.pixelate, 'Pixelate', 'Censor or mosaic image', Icons.grid_on, Colors.deepPurple),
      _ToolInfo(ImageToolType.metadataViewer, 'Metadata Viewer', 'View EXIF data', Icons.info_outline, Colors.cyan),
      _ToolInfo(ImageToolType.removeMetadata, 'Remove Metadata', 'Strip EXIF/GPS data', Icons.security, Colors.amber),
      _ToolInfo(ImageToolType.dpiResolution, 'DPI / Resolution', 'Change print resolution', Icons.print, Colors.lightBlue),
      _ToolInfo(ImageToolType.colorMode, 'Color Mode', 'Grayscale, CMYK, RGB', Icons.color_lens, Colors.pink),
      _ToolInfo(ImageToolType.batchConvert, 'Batch Convert', 'Convert multiple images', Icons.collections, Colors.indigoAccent),
      _ToolInfo(ImageToolType.batchResize, 'Batch Resize', 'Resize multiple images', Icons.photo_library, Colors.greenAccent),
      _ToolInfo(ImageToolType.batchCompress, 'Batch Compress', 'Compress multiple images', Icons.folder_zip, Colors.orangeAccent),

    ];

    return Scaffold(
      appBar: const AnimatedAppBar(title: 'Image Tools'),
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
            return ImageToolCard(
              toolType: tool.type,
              title: tool.title,
              description: tool.desc,
              icon: tool.icon,
              color: tool.color,
              onTap: () {
                context.go('${RouteConstants.home}/${RouteConstants.image}/${tool.type.name}');
              },
            ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
          },
        ),
      ),
    );
  }
}

class _ToolInfo {
  final ImageToolType type;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  _ToolInfo(this.type, this.title, this.desc, this.icon, this.color);
}
