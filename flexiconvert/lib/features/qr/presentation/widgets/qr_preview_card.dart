import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../providers/qr_config_provider.dart';
import '../../domain/models/qr_config_model.dart';
import 'dart:io';
import 'package:barcode_widget/barcode_widget.dart';
import 'custom_qr_shapes.dart';
import 'qr_frame_widget.dart';

class _QrCircleMaskClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    path.addRect(Rect.fromLTWH(0, 0, size.width * 0.35, size.height * 0.35));
    path.addRect(Rect.fromLTWH(size.width * 0.65, 0, size.width * 0.35, size.height * 0.35));
    path.addRect(Rect.fromLTWH(0, size.height * 0.65, size.width * 0.35, size.height * 0.35));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class QrPreviewCard extends ConsumerWidget {
  const QrPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(qrConfigProvider);

    if (config.payloadType == QrPayloadType.barcode) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AspectRatio(
            aspectRatio: 2.0,
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              data: config.payloadData.isEmpty ? '123456' : config.payloadData,
              errorBuilder: (context, error) => Center(child: Text('Invalid data', style: TextStyle(color: Colors.red))),
              backgroundColor: config.backgroundColor.color,
              color: config.dotColor.color,
            ),
          ),
        ),
      );
    }

    // Build Shape
    PrettyQrShape shape = PrettyQrShape.custom(
      CustomQrDataShape(
        shape: config.dotShape,
        overallShape: config.overallShape,
        color: config.dotColor.color,
      ),
      finderPattern: CustomQrEyeShape(
        outerShape: config.cornerOutsideShape,
        innerShape: config.cornerInsideShape,
        color: config.cornerOutsideColor.color,
      ),
    );

    // Build logo
    PrettyQrDecorationImage? decorationImage;
    if (config.logoPath != null && config.logoPath!.isNotEmpty) {
      decorationImage = PrettyQrDecorationImage(
        image: FileImage(File(config.logoPath!)),
        position: PrettyQrDecorationImagePosition.embedded,
      );
    }
    
    // Gradients aren't natively supported in all pretty_qr_code shapes easily without custom painter, 
    // but we will apply basic color configuration here.
    
    // Handle Overall Shape (circular clip if requested)
    Widget qrWidget = LayoutBuilder(
      builder: (context, constraints) {
        // If circle, we need padding so the circumscribing fake dots fit inside the container.
        // padding = diameter * (1 - sqrt(1/2)) / 2 ≈ diameter * 0.1464
        final paddingValue = config.overallShape == QrOverallShape.circle 
            ? constraints.maxWidth * 0.1464 
            : 16.0;

        return Container(
          decoration: BoxDecoration(
            color: config.backgroundColor.color,
            shape: config.overallShape == QrOverallShape.circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: config.overallShape == QrOverallShape.circle ? null : BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(paddingValue),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PrettyQrView.data(
                data: config.payloadData,
                errorCorrectLevel: QrErrorCorrectLevel.H,
                decoration: PrettyQrDecoration(
                  shape: shape,
                  image: decorationImage,
                  background: Colors.transparent,
                ),
              ),
              if (config.logoPath == null && config.payloadType == QrPayloadType.whatsapp)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.message, color: Colors.green, size: 32),
                ),
            ],
          ),
        );
      }
    );

    // Apply Frame
    qrWidget = QrFrameWidget(
      config: config,
      child: qrWidget,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: qrWidget,
        ),
      ),
    );
  }
}
