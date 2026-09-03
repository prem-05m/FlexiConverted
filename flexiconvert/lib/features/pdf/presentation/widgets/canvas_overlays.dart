import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

abstract class OverlayLayer {
  final String id;
  double x;
  double y;
  double width;
  double height;
  double rotation; // degrees

  OverlayLayer({
    String? id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0,
  }) : id = id ?? const Uuid().v4();
}

class TextLayer extends OverlayLayer {
  String text;
  double fontSize;
  Color color;
  String fontFamily;
  bool isBold;
  bool isItalic;
  bool isUnderline;

  TextLayer({
    super.id,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    super.rotation,
    required this.text,
    this.fontSize = 24,
    this.color = Colors.black,
    this.fontFamily = 'Arial',
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
  });
}

class ImageLayer extends OverlayLayer {
  final Uint8List imageBytes;
  
  ImageLayer({
    super.id,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    super.rotation,
    required this.imageBytes,
  });
}

class DrawPath {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  
  DrawPath({
    required this.points,
    this.color = Colors.black,
    this.strokeWidth = 3,
  });
}

class DrawLayer extends OverlayLayer {
  final List<DrawPath> paths;
  
  DrawLayer({
    super.id,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    super.rotation,
    required this.paths,
  });
}

class ShapeLayer extends OverlayLayer {
  final String shapeType; // e.g. 'rectangle', 'circle'
  Color backgroundColor;
  Color outlineColor;
  double strokeWidth;
  
  ShapeLayer({
    super.id,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    super.rotation,
    required this.shapeType,
    this.backgroundColor = Colors.blue,
    this.outlineColor = Colors.transparent,
    this.strokeWidth = 0,
  });
}

class InteractiveOverlay extends StatefulWidget {
  final OverlayLayer layer;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final Function(double dx, double dy) onMove;
  final Function(double dw, double dh, double dx, double dy) onResize;
  final Function(double deltaAngle) onRotate;
  final VoidCallback onDelete;
  final Widget child;

  const InteractiveOverlay({
    super.key,
    required this.layer,
    required this.isSelected,
    required this.onTap,
    this.onDoubleTap,
    required this.onMove,
    required this.onResize,
    required this.onRotate,
    required this.onDelete,
    required this.child,
  });

  @override
  State<InteractiveOverlay> createState() => _InteractiveOverlayState();
}

class _InteractiveOverlayState extends State<InteractiveOverlay> {
  Offset? _startDragPos;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.layer.x,
      top: widget.layer.y,
      width: widget.layer.width,
      height: widget.layer.height,
      child: GestureDetector(
        onTapDown: (details) {
          _startDragPos = details.globalPosition;
        },
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onPanStart: (details) {
          _startDragPos = details.globalPosition;
          widget.onTap(); // Select on drag start
        },
        onPanUpdate: (details) {
          if (_startDragPos != null) {
            final delta = details.delta;
            widget.onMove(delta.dx, delta.dy);
          }
        },
        child: Transform.rotate(
          angle: widget.layer.rotation * 3.14159 / 180,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: widget.isSelected
                      ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                      : Border.all(color: Colors.transparent, width: 2),
                ),
                child: widget.child,
              ),
              if (widget.isSelected) ...[
                // Delete button
                Positioned(
                  top: -12,
                  right: -12,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                    ),
                  ),
                ),
                // Resize handle (Bottom Right)
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      widget.onResize(details.delta.dx, details.delta.dy, 0, 0);
                    },
                    child: _buildHandle(context),
                  ),
                ),
                // Rotate handle (Bottom Left)
                Positioned(
                  bottom: -8,
                  left: -8,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      // Simple rotation calculation based on X movement
                      widget.onRotate(details.delta.dx);
                    },
                    child: _buildHandle(context, icon: Icons.rotate_right),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context, {IconData? icon}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
        shape: BoxShape.circle,
      ),
      child: icon != null ? Icon(icon, size: 12, color: Theme.of(context).colorScheme.primary) : null,
    );
  }
}
