import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../domain/models/image_task_model.dart';
import '../../../favorites/presentation/widgets/favorite_heart_icon.dart';
import '../../../favorites/domain/models/favorite_tool_model.dart';

class ImageToolCard extends StatelessWidget {
  final ImageToolType toolType;
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const ImageToolCard({
    super.key,
    required this.toolType,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppBorders.lg,
        boxShadow: AppShadows.sm,
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorders.lg,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: AppBorders.md,
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        description,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: FavoriteHeartIcon(
                  tool: FavoriteToolItem(
                    toolId: 'image_${toolType.name}',
                    title: title,
                    subtitle: description,
                    iconCodePoint: icon.codePoint,
                    colorValue: color.toARGB32(),
                    route: '/home/image/${toolType.name}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
