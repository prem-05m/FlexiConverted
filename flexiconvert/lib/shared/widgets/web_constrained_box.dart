import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebConstrainedBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;

  const WebConstrainedBox({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
