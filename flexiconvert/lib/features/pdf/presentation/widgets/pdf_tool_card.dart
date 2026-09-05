import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../domain/models/pdf_task_model.dart';
import '../../../favorites/presentation/widgets/favorite_heart_icon.dart';
import '../../../favorites/domain/models/favorite_tool_model.dart';

class PdfToolCard extends StatelessWidget {
  final PdfToolType toolType;
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool isComingSoon;

  const PdfToolCard({
    super.key,
    required this.toolType,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.color,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isComingSoon ? Colors.grey : color;

    return Opacity(
      opacity: isComingSoon ? 0.55 : 1.0,
      child: Container(
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: effectiveColor.withValues(alpha: 0.1),
                          borderRadius: AppBorders.md,
                        ),
                        child: Icon(icon, color: effectiveColor, size: 28),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isComingSoon ? Colors.grey : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          description,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isComingSoon
                                ? Colors.grey
                                : context.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (isComingSoon)
                    Positioned(
                      top: 0,
                      right: 32, // Offset to not overlap with heart icon
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Soon',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: FavoriteHeartIcon(
                      tool: FavoriteToolItem(
                        toolId: 'pdf_${toolType.name}',
                        title: title,
                        subtitle: description,
                        iconCodePoint: icon.codePoint,
                        colorValue: color.toARGB32(),
                        route: '/home/pdf/${toolType.name}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
