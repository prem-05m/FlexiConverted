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
      _ToolInfo(ImageToolType.convertFormat, 'Convert Format', 'JPG, PNG, WEBP, BMP, etc.', Icons.transform, Colors.blue),
      _ToolInfo(ImageToolType.resize, 'Resize Image', 'Change image dimensions', Icons.photo_size_select_large, Colors.green),
      _ToolInfo(ImageToolType.compress, 'Compress Image', 'Reduce image file size', Icons.compress, Colors.orange),
      _ToolInfo(ImageToolType.crop, 'Crop Image', 'Crop to specific aspect ratio', Icons.crop, Colors.red),
      _ToolInfo(ImageToolType.rotate, 'Rotate Image', 'Rotate by 90/180/270 degrees', Icons.rotate_right, Colors.purple),
      _ToolInfo(ImageToolType.flip, 'Flip Image', 'Mirror image horizontally/vertically', Icons.flip, Colors.teal),
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
