import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../domain/models/qr_config_model.dart';

class CustomQrEyeShape extends PrettyQrShape {
  final QrEyeShape outerShape;
  final QrInnerEyeShape innerShape;
  final Color color;

  const CustomQrEyeShape({
    required this.outerShape,
    required this.innerShape,
    required this.color,
  });

  @override
  void paint(PrettyQrPaintingContext context) {
    final canvas = context.canvas;
    final bounds = context.estimatedBounds;
    final dimension = context.matrix.dimension; // number of modules
    final moduleSize = bounds.width / dimension;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // The 3 finders are at:
    // Top-Left: (0, 0)
    // Top-Right: (dimension - 7, 0)
    // Bottom-Left: (0, dimension - 7)
    final finderPositions = [
      Offset(0, 0),
      Offset((dimension - 7).toDouble(), 0),
      Offset(0, (dimension - 7).toDouble()),
    ];

    for (final pos in finderPositions) {
      final rect = Rect.fromLTWH(
        bounds.left + pos.dx * moduleSize,
        bounds.top + pos.dy * moduleSize,
        7 * moduleSize,
        7 * moduleSize,
      );

      _drawOuterEye(canvas, rect, moduleSize, paint);
      _drawInnerEye(canvas, rect, moduleSize, paint);
    }
  }

  void _drawOuterEye(Canvas canvas, Rect rect, double moduleSize, Paint paint) {
    // Outer eye is a 7x7 box with a 5x5 hole.
    final outerRect = rect;
    final innerHole = rect.deflate(moduleSize); // 1 module thickness

    final path = Path();
    
    switch (outerShape) {
      case QrEyeShape.square:
        path.addRect(outerRect);
        path.addRect(innerHole);
        break;
      case QrEyeShape.circle:
        path.addOval(outerRect);
        path.addOval(innerHole);
        break;
      case QrEyeShape.rounded:
        final r = Radius.circular(moduleSize * 1.5);
        final rInner = Radius.circular(moduleSize * 0.5);
        path.addRRect(RRect.fromRectAndRadius(outerRect, r));
        path.addRRect(RRect.fromRectAndRadius(innerHole, rInner));
        break;
      case QrEyeShape.leaf:
        final r1 = Radius.circular(moduleSize * 3);
        final r2 = Radius.zero;
        path.addRRect(RRect.fromRectAndCorners(outerRect, topLeft: r1, bottomRight: r1, topRight: r2, bottomLeft: r2));
        path.addRRect(RRect.fromRectAndCorners(innerHole, topLeft: Radius.circular(moduleSize * 1.5), bottomRight: Radius.circular(moduleSize*1.5), topRight: r2, bottomLeft: r2));
        break;
    }
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  void _drawInnerEye(Canvas canvas, Rect rect, double moduleSize, Paint paint) {
    // Inner eye is a 3x3 solid block at offset (2, 2)
    final innerRect = rect.deflate(moduleSize * 2);

    switch (innerShape) {
      case QrInnerEyeShape.square:
        canvas.drawRect(innerRect, paint);
        break;
      case QrInnerEyeShape.circle:
        canvas.drawOval(innerRect, paint);
        break;
      case QrInnerEyeShape.diamond:
        final path = Path();
        path.moveTo(innerRect.center.dx, innerRect.top);
        path.lineTo(innerRect.right, innerRect.center.dy);
        path.lineTo(innerRect.center.dx, innerRect.bottom);
        path.lineTo(innerRect.left, innerRect.center.dy);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case QrInnerEyeShape.plus:
        final thirdW = innerRect.width / 3;
        final thirdH = innerRect.height / 3;
        final path = Path();
        path.addRect(Rect.fromLTWH(innerRect.left + thirdW, innerRect.top, thirdW, innerRect.height));
        path.addRect(Rect.fromLTWH(innerRect.left, innerRect.top + thirdH, innerRect.width, thirdH));
        canvas.drawPath(path, paint);
        break;
    }
  }
}

class CustomQrDataShape extends PrettyQrShape {
  final QrDataModuleShape shape;
  final QrOverallShape overallShape;
  final Color color;

  const CustomQrDataShape({
    required this.shape,
    required this.overallShape,
    required this.color,
  });

  @override
  void paint(PrettyQrPaintingContext context) {
    final canvas = context.canvas;
    final bounds = context.estimatedBounds;
    final dimension = context.matrix.dimension;
    final moduleSize = bounds.width / dimension;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    void drawDot(int x, int y) {
      final rect = Rect.fromLTWH(
        bounds.left + x * moduleSize,
        bounds.top + y * moduleSize,
        moduleSize,
        moduleSize,
      );

      final paddedRect = rect.deflate(0.2);

      switch (shape) {
        case QrDataModuleShape.square:
          canvas.drawRect(paddedRect, paint);
          break;
        case QrDataModuleShape.circle:
          canvas.drawOval(paddedRect, paint);
          break;
        case QrDataModuleShape.rounded:
          canvas.drawRRect(RRect.fromRectAndRadius(paddedRect, Radius.circular(moduleSize * 0.3)), paint);
          break;
        case QrDataModuleShape.diamond:
          final path = Path();
          path.moveTo(paddedRect.center.dx, paddedRect.top);
          path.lineTo(paddedRect.right, paddedRect.center.dy);
          path.lineTo(paddedRect.center.dx, paddedRect.bottom);
          path.lineTo(paddedRect.left, paddedRect.center.dy);
          path.close();
          canvas.drawPath(path, paint);
          break;
        case QrDataModuleShape.star:
          final path = Path();
          final c = paddedRect.center;
          final w = paddedRect.width / 2;
          path.moveTo(c.dx, c.dy - w);
          path.quadraticBezierTo(c.dx, c.dy, c.dx + w, c.dy);
          path.quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + w);
          path.quadraticBezierTo(c.dx, c.dy, c.dx - w, c.dy);
          path.quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - w);
          canvas.drawPath(path, paint);
          break;
      }
    }

    // 1. Draw Real Data
    for (var x = 0; x < dimension; x++) {
      for (var y = 0; y < dimension; y++) {
        if (context.matrix.hasModuleAt(x, y)) {
          drawDot(x, y);
        }
      }
    }

    // 2. Removed Fake Dots
    // The user requested a clean circular boundary without detached pixels.
    // If the overall shape is circle, the BoxShape.circle handles the background,
    // and we will render the exact square QR data that falls in it (or we could mask it).
  }
}
