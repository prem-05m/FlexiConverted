import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/models/qr_config_model.dart';

class QrFrameWidget extends StatelessWidget {
  final Widget child;
  final QrConfigModel config;

  const QrFrameWidget({
    super.key,
    required this.child,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    if (config.frameStyle == QrFrameStyle.none) return child;

    final frameColor = config.frameColor.color;
    final textColor = config.frameTextColor.color;
    final text = config.frameText;

    switch (config.frameStyle) {
      // TOOLTIPS
      case QrFrameStyle.tooltipTop:
        return _buildTooltip(context, child, text, frameColor, textColor, top: true);
      case QrFrameStyle.tooltipBottom:
        return _buildTooltip(context, child, text, frameColor, textColor, top: false);
      case QrFrameStyle.tooltipLeft:
        return _buildTooltipHorizontal(context, child, text, frameColor, textColor, left: true);
      case QrFrameStyle.tooltipRight:
        return _buildTooltipHorizontal(context, child, text, frameColor, textColor, left: false);

      // BORDERS
      case QrFrameStyle.borderThick:
        return _buildBorder(child, text, frameColor, textColor, 8.0, BorderStyle.solid);
      case QrFrameStyle.borderThin:
        return _buildBorder(child, text, frameColor, textColor, 2.0, BorderStyle.solid);
      case QrFrameStyle.borderDashed:
        return _buildCustomBorder(child, text, frameColor, textColor, isDashed: true);
      case QrFrameStyle.borderDotted:
        return _buildCustomBorder(child, text, frameColor, textColor, isDashed: false);

      // BADGES
      case QrFrameStyle.badgeCircle:
        return _buildBadge(child, text, frameColor, textColor, BoxShape.circle);
      case QrFrameStyle.badgeShield:
        return _buildShieldBadge(child, text, frameColor, textColor);
      case QrFrameStyle.badgeStarburst:
        return _buildStarburstBadge(child, text, frameColor, textColor);

      // LAYOUTS
      case QrFrameStyle.layoutHeader:
        return _buildLayout(child, text, frameColor, textColor, header: true, footer: false);
      case QrFrameStyle.layoutFooter:
        return _buildLayout(child, text, frameColor, textColor, header: false, footer: true);
      case QrFrameStyle.layoutSplit:
        return _buildLayout(child, text, frameColor, textColor, header: true, footer: true);

      // MODERN
      case QrFrameStyle.modernNeon:
        return _buildNeon(child, text, frameColor, textColor);
      case QrFrameStyle.modernShadow:
        return _buildShadow(child, text, frameColor, textColor);
      case QrFrameStyle.modernGlass:
        return _buildGlass(child, text, frameColor, textColor);

      // SPECIALTY
      case QrFrameStyle.specialtyTicket:
        return _buildTicket(child, text, frameColor, textColor);
      case QrFrameStyle.specialtyReceipt:
        return _buildReceipt(child, text, frameColor, textColor);
      case QrFrameStyle.specialtyPhone:
        return _buildPhone(child, text, frameColor, textColor);

      // MINIMALIST
      case QrFrameStyle.minimalistBrackets:
        return _buildBrackets(child, text, frameColor, textColor);
      case QrFrameStyle.minimalistSidebar:
        return _buildSidebar(child, text, frameColor, textColor);
        
      default:
        return child;
    }
  }

  // --- IMPLEMENTATIONS ---

  Widget _buildTooltip(BuildContext context, Widget child, String text, Color frameColor, Color textColor, {required bool top}) {
    final textWidget = Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: frameColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
    );

    final arrowWidget = CustomPaint(
      size: const Size(20, 10),
      painter: _TrianglePainter(color: frameColor, pointDown: !top),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (top) ...[textWidget, arrowWidget, const SizedBox(height: 4)],
        child,
        if (!top) ...[const SizedBox(height: 4), arrowWidget, textWidget],
      ],
    );
  }

  Widget _buildTooltipHorizontal(BuildContext context, Widget child, String text, Color frameColor, Color textColor, {required bool left}) {
    final textWidget = Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(color: frameColor, borderRadius: BorderRadius.circular(12)),
      child: RotatedBox(
        quarterTurns: left ? 3 : 1,
        child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );

    final arrowWidget = RotatedBox(
      quarterTurns: left ? 3 : 1,
      child: CustomPaint(
        size: const Size(20, 10),
        painter: _TrianglePainter(color: frameColor, pointDown: true),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (left) ...[textWidget, arrowWidget, const SizedBox(width: 4)],
        Flexible(child: child),
        if (!left) ...[const SizedBox(width: 4), arrowWidget, textWidget],
      ],
    );
  }

  Widget _buildBorder(Widget child, String text, Color frameColor, Color textColor, double width, BorderStyle style) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: frameColor, width: width, style: style),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: frameColor, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildCustomBorder(Widget child, String text, Color frameColor, Color textColor, {required bool isDashed}) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: frameColor, isDashed: isDashed),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: 12),
            Text(text, style: TextStyle(color: frameColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(Widget child, String text, Color frameColor, Color textColor, BoxShape shape) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: frameColor, shape: shape),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 16),
          Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildShieldBadge(Widget child, String text, Color frameColor, Color textColor) {
    return CustomPaint(
      painter: _ShieldPainter(color: frameColor),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: 12),
            Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildStarburstBadge(Widget child, String text, Color frameColor, Color textColor) {
    return CustomPaint(
      painter: _StarburstPainter(color: frameColor),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: 12),
            Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildLayout(Widget child, String text, Color frameColor, Color textColor, {required bool header, required bool footer}) {
    return Container(
      decoration: BoxDecoration(color: frameColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header) Padding(
            padding: const EdgeInsets.all(12),
            child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: child,
          ),
          if (footer) Padding(
            padding: const EdgeInsets.all(12),
            child: Text(header ? 'SCAN ME' : text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildNeon(Widget child, String text, Color frameColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: frameColor, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: frameColor.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2),
          BoxShadow(color: frameColor.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(color: Colors.white, padding: const EdgeInsets.all(8), child: child),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: frameColor, fontWeight: FontWeight.bold, fontSize: 20, shadows: [Shadow(color: frameColor, blurRadius: 8)])),
        ],
      ),
    );
  }

  Widget _buildShadow(Widget child, String text, Color frameColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: frameColor.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: frameColor, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildGlass(Widget child, String text, Color frameColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [frameColor.withValues(alpha: 0.2), frameColor.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: frameColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 16),
          Text(text, style: TextStyle(color: frameColor, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildTicket(Widget child, String text, Color frameColor, Color textColor) {
    return CustomPaint(
      painter: _TicketPainter(color: frameColor),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: 24),
            Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildReceipt(Widget child, String text, Color frameColor, Color textColor) {
    return CustomPaint(
      painter: _ReceiptPainter(color: frameColor),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: 16),
            Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhone(Widget child, String text, Color frameColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 32, 12, 32),
      decoration: BoxDecoration(
        color: frameColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade300, width: 4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: child,
          ),
          const SizedBox(height: 24),
          Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildBrackets(Widget child, String text, Color frameColor, Color textColor) {
    return CustomPaint(
      painter: _BracketsPainter(color: frameColor),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: 12),
            Text(text, style: TextStyle(color: frameColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(Widget child, String text, Color frameColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: frameColor, width: 8),
          right: BorderSide(color: frameColor, width: 8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 16),
          Text(text, style: TextStyle(color: frameColor, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}

// --- CUSTOM PAINTERS FOR FRAMES ---

class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool pointDown;
  _TrianglePainter({required this.color, required this.pointDown});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    if (pointDown) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width / 2, 0);
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final bool isDashed;
  _DashedBorderPainter({required this.color, required this.isDashed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16));
    final path = Path()..addRRect(rrect);

    // Manual dashed/dotted implementation
    final dashWidth = isDashed ? 10.0 : 3.0;
    final dashSpace = isDashed ? 8.0 : 5.0;
    
    // Simplistic dash drawing around a rect bounds
    // Since Path metric is complex, we will just draw a basic rect manually
    var startY = 0.0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
    var startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      canvas.drawLine(Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShieldPainter extends CustomPainter {
  final Color color;
  _ShieldPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.7);
    path.quadraticBezierTo(size.width / 2, size.height, size.width / 2, size.height);
    path.quadraticBezierTo(0, size.height * 0.7, 0, size.height * 0.7);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarburstPainter extends CustomPainter {
  final Color color;
  _StarburstPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.85;
    const numPoints = 20;
    for (int i = 0; i < numPoints * 2; i++) {
      final r = (i % 2 == 0) ? radius : innerRadius;
      final angle = (i * math.pi) / numPoints;
      final point = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TicketPainter extends CustomPainter {
  final Color color;
  _TicketPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    final r = 16.0;
    path.moveTo(r, 0);
    path.lineTo(size.width - r, 0);
    path.arcToPoint(Offset(size.width, r), radius: Radius.circular(r), clockwise: false);
    path.lineTo(size.width, size.height * 0.7 - r);
    path.arcToPoint(Offset(size.width, size.height * 0.7 + r), radius: Radius.circular(r), clockwise: true);
    path.lineTo(size.width, size.height - r);
    path.arcToPoint(Offset(size.width - r, size.height), radius: Radius.circular(r), clockwise: false);
    path.lineTo(r, size.height);
    path.arcToPoint(Offset(0, size.height - r), radius: Radius.circular(r), clockwise: false);
    path.lineTo(0, size.height * 0.7 + r);
    path.arcToPoint(Offset(0, size.height * 0.7 - r), radius: Radius.circular(r), clockwise: true);
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r), clockwise: false);
    canvas.drawPath(path, paint);
    
    // Draw dashed line
    final dashPaint = Paint()..color = Colors.white..strokeWidth = 2..style = PaintingStyle.stroke;
    var startX = 20.0;
    while (startX < size.width - 20) {
      canvas.drawLine(Offset(startX, size.height * 0.7), Offset(startX + 10, size.height * 0.7), dashPaint);
      startX += 15;
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReceiptPainter extends CustomPainter {
  final Color color;
  _ReceiptPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    
    // Zig zag bottom
    final zigWidth = 10.0;
    var currentX = size.width;
    while (currentX > 0) {
      path.lineTo(currentX - zigWidth / 2, size.height - 10);
      path.lineTo(currentX - zigWidth, size.height);
      currentX -= zigWidth;
    }
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BracketsPainter extends CustomPainter {
  final Color color;
  _BracketsPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 8..style = PaintingStyle.stroke;
    final length = 30.0;
    // Top Left
    canvas.drawPath(Path()..moveTo(0, length)..lineTo(0, 0)..lineTo(length, 0), paint);
    // Top Right
    canvas.drawPath(Path()..moveTo(size.width - length, 0)..lineTo(size.width, 0)..lineTo(size.width, length), paint);
    // Bottom Left
    canvas.drawPath(Path()..moveTo(0, size.height - length)..lineTo(0, size.height)..lineTo(length, size.height), paint);
    // Bottom Right
    canvas.drawPath(Path()..moveTo(size.width - length, size.height)..lineTo(size.width, size.height)..lineTo(size.width, size.height - length), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
