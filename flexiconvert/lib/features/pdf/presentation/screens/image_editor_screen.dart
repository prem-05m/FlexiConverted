import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img_lib;

class ImageEditorScreen extends StatefulWidget {
  final File imageFile;
  const ImageEditorScreen({super.key, required this.imageFile});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  img_lib.Image? _srcImage;
  bool _isBlackAndWhite = false;
  int _rotationAngle = 0; // 0, 90, 180, 270
  bool _isLoading = true;

  // Crop state (fractions 0.0–1.0 of display image)
  double _cropLeft = 0.0;
  double _cropTop = 0.0;
  double _cropRight = 1.0;
  double _cropBottom = 1.0;

  // Drag handle state
  String? _dragging; // 'tl', 'tr', 'bl', 'br', 'body'
  Offset _dragStart = Offset.zero;
  double _cropLeftStart = 0.0, _cropTopStart = 0.0, _cropRightStart = 1.0, _cropBottomStart = 1.0;

  final GlobalKey _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() => _isLoading = true);
    final bytes = await widget.imageFile.readAsBytes();
    final decoded = img_lib.decodeImage(bytes);
    if (mounted) {
      setState(() {
        _srcImage = decoded;
        _isLoading = false;
      });
    }
  }

  img_lib.Image _applyEdits(img_lib.Image source) {
    img_lib.Image result = source.clone();

    // Rotation
    if (_rotationAngle == 90) {
      result = img_lib.copyRotate(result, angle: 90);
    } else if (_rotationAngle == 180) {
      result = img_lib.copyRotate(result, angle: 180);
    } else if (_rotationAngle == 270) {
      result = img_lib.copyRotate(result, angle: 270);
    }

    // Crop
    if (_cropLeft > 0 || _cropTop > 0 || _cropRight < 1 || _cropBottom < 1) {
      final w = result.width;
      final h = result.height;
      final x = (_cropLeft * w).round().clamp(0, w - 1);
      final y = (_cropTop * h).round().clamp(0, h - 1);
      final cw = ((_cropRight - _cropLeft) * w).round().clamp(1, w - x);
      final ch = ((_cropBottom - _cropTop) * h).round().clamp(1, h - y);
      result = img_lib.copyCrop(result, x: x, y: y, width: cw, height: ch);
    }

    // B&W
    if (_isBlackAndWhite) {
      result = img_lib.grayscale(result);
    }

    return result;
  }

  /// Auto-detect border: find the bounding box of non-white pixels
  void _detectBorder() {
    if (_srcImage == null) return;
    final src = _srcImage!;
    const threshold = 230;
    int minX = src.width, minY = src.height, maxX = 0, maxY = 0;

    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final px = src.getPixel(x, y);
        final r = px.r.toInt();
        final g = px.g.toInt();
        final b = px.b.toInt();
        // If pixel is not near-white
        if (r < threshold || g < threshold || b < threshold) {
          if (x < minX) minX = x;
          if (y < minY) minY = y;
          if (x > maxX) maxX = x;
          if (y > maxY) maxY = y;
        }
      }
    }

    if (maxX <= minX || maxY <= minY) return;

    // Add 2% padding
    const pad = 0.02;
    setState(() {
      _cropLeft = ((minX / src.width) - pad).clamp(0.0, 1.0);
      _cropTop = ((minY / src.height) - pad).clamp(0.0, 1.0);
      _cropRight = ((maxX / src.width) + pad).clamp(0.0, 1.0);
      _cropBottom = ((maxY / src.height) + pad).clamp(0.0, 1.0);
    });
  }

  Future<void> _confirmAndSave() async {
    if (_srcImage == null) return;
    setState(() => _isLoading = true);

    final edited = _applyEdits(_srcImage!);
    final jpgBytes = img_lib.encodeJpg(edited, quality: 92);

    final tmpDir = await Directory.systemTemp.createTemp('flexiconvert_scan');
    final outFile = File('${tmpDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await outFile.writeAsBytes(jpgBytes);

    if (mounted) {
      Navigator.pop(context, outFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Edit Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            tooltip: 'Confirm',
            onPressed: _isLoading ? null : _confirmAndSave,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // Image preview with crop overlay
                Expanded(child: _buildCropArea()),
                // Toolbar
                _buildToolbar(),
              ],
            ),
    );
  }

  Widget _buildCropArea() {
    if (_srcImage == null) return const SizedBox.shrink();

    // Build preview image with edits for display
    final previewImage = _applyEdits(_srcImage!);
    final previewBytes = Uint8List.fromList(img_lib.encodeJpg(previewImage, quality: 75));

    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onPanStart: (details) {
          final imgRect = _getImageDisplayRect(constraints);
          final local = details.localPosition;
          final rel = Offset(
            ((local.dx - imgRect.left) / imgRect.width).clamp(0.0, 1.0),
            ((local.dy - imgRect.top) / imgRect.height).clamp(0.0, 1.0),
          );

          _dragStart = local;
          _cropLeftStart = _cropLeft;
          _cropTopStart = _cropTop;
          _cropRightStart = _cropRight;
          _cropBottomStart = _cropBottom;

          // Hit test corners
          if ((rel - Offset(_cropLeft, _cropTop)).distance < 0.06) {
            _dragging = 'tl';
          } else if ((rel - Offset(_cropRight, _cropTop)).distance < 0.06) {
            _dragging = 'tr';
          } else if ((rel - Offset(_cropLeft, _cropBottom)).distance < 0.06) {
            _dragging = 'bl';
          } else if ((rel - Offset(_cropRight, _cropBottom)).distance < 0.06) {
            _dragging = 'br';
          }
        },
        onPanUpdate: (details) {
          if (_dragging == null) return;
          final imgRect = _getImageDisplayRect(constraints);
          final dx = (details.localPosition.dx - _dragStart.dx) / imgRect.width;
          final dy = (details.localPosition.dy - _dragStart.dy) / imgRect.height;

          setState(() {
            switch (_dragging) {
              case 'tl':
                _cropLeft = (_cropLeftStart + dx).clamp(0.0, _cropRight - 0.05);
                _cropTop = (_cropTopStart + dy).clamp(0.0, _cropBottom - 0.05);
                break;
              case 'tr':
                _cropRight = (_cropRightStart + dx).clamp(_cropLeft + 0.05, 1.0);
                _cropTop = (_cropTopStart + dy).clamp(0.0, _cropBottom - 0.05);
                break;
              case 'bl':
                _cropLeft = (_cropLeftStart + dx).clamp(0.0, _cropRight - 0.05);
                _cropBottom = (_cropBottomStart + dy).clamp(_cropTop + 0.05, 1.0);
                break;
              case 'br':
                _cropRight = (_cropRightStart + dx).clamp(_cropLeft + 0.05, 1.0);
                _cropBottom = (_cropBottomStart + dy).clamp(_cropTop + 0.05, 1.0);
                break;
            }
          });
        },
        onPanEnd: (_) => _dragging = null,
        child: Stack(
          children: [
            // Image
            Center(
              child: Image.memory(
                previewBytes,
                key: _imageKey,
                fit: BoxFit.contain,
              ),
            ),
            // Crop overlay
            CustomPaint(
              painter: _CropOverlayPainter(
                cropLeft: _cropLeft,
                cropTop: _cropTop,
                cropRight: _cropRight,
                cropBottom: _cropBottom,
                imgRect: _getImageDisplayRect(constraints),
              ),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            ),
          ],
        ),
      );
    });
  }

  Rect _getImageDisplayRect(BoxConstraints constraints) {
    if (_srcImage == null) return Rect.zero;

    final src = _applyEdits(_srcImage!);
    final imgW = src.width.toDouble();
    final imgH = src.height.toDouble();
    final availW = constraints.maxWidth;
    final availH = constraints.maxHeight;

    final scale = math.min(availW / imgW, availH / imgH);
    final scaledW = imgW * scale;
    final scaledH = imgH * scale;
    final offsetX = (availW - scaledW) / 2;
    final offsetY = (availH - scaledH) / 2;
    return Rect.fromLTWH(offsetX, offsetY, scaledW, scaledH);
  }

  Widget _buildToolbar() {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToolButton(
                icon: Icons.rotate_right,
                label: 'Rotate',
                onTap: () => setState(() => _rotationAngle = (_rotationAngle + 90) % 360),
              ),
              _ToolButton(
                icon: _isBlackAndWhite ? Icons.color_lens : Icons.invert_colors,
                label: _isBlackAndWhite ? 'Colour' : 'B&W',
                active: _isBlackAndWhite,
                onTap: () => setState(() => _isBlackAndWhite = !_isBlackAndWhite),
              ),
              _ToolButton(
                icon: Icons.crop_free,
                label: 'Full',
                onTap: () => setState(() {
                  _cropLeft = 0.0; _cropTop = 0.0;
                  _cropRight = 1.0; _cropBottom = 1.0;
                }),
              ),
              _ToolButton(
                icon: Icons.document_scanner,
                label: 'Detect',
                onTap: _detectBorder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: active ? Colors.teal.withValues(alpha: 0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: active ? Border.all(color: Colors.teal, width: 1.5) : null,
            ),
            child: Icon(icon, color: active ? Colors.teal : Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            color: active ? Colors.teal : Colors.grey.shade400,
            fontSize: 11,
          )),
        ],
      ),
    );
  }
}

/// Custom painter for crop selection overlay
class _CropOverlayPainter extends CustomPainter {
  final double cropLeft, cropTop, cropRight, cropBottom;
  final Rect imgRect;

  const _CropOverlayPainter({
    required this.cropLeft,
    required this.cropTop,
    required this.cropRight,
    required this.cropBottom,
    required this.imgRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (imgRect == Rect.zero) return;

    final selLeft = imgRect.left + cropLeft * imgRect.width;
    final selTop = imgRect.top + cropTop * imgRect.height;
    final selRight = imgRect.left + cropRight * imgRect.width;
    final selBottom = imgRect.top + cropBottom * imgRect.height;
    final selRect = Rect.fromLTRB(selLeft, selTop, selRight, selBottom);

    // Dark overlay outside selection
    final shadePaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    canvas.drawRect(Rect.fromLTRB(imgRect.left, imgRect.top, imgRect.right, selTop), shadePaint);
    canvas.drawRect(Rect.fromLTRB(imgRect.left, selBottom, imgRect.right, imgRect.bottom), shadePaint);
    canvas.drawRect(Rect.fromLTRB(imgRect.left, selTop, selLeft, selBottom), shadePaint);
    canvas.drawRect(Rect.fromLTRB(selRight, selTop, imgRect.right, selBottom), shadePaint);

    // Selection border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(selRect, borderPaint);

    // Corner handles
    final handlePaint = Paint()..color = Colors.white;
    const hs = 10.0;
    for (final corner in [
      Offset(selLeft, selTop),
      Offset(selRight, selTop),
      Offset(selLeft, selBottom),
      Offset(selRight, selBottom),
    ]) {
      canvas.drawCircle(corner, hs / 2, handlePaint);
    }

    // Rule-of-thirds grid lines (subtle)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final thirdW = selRect.width / 3;
    final thirdH = selRect.height / 3;
    canvas.drawLine(Offset(selLeft + thirdW, selTop), Offset(selLeft + thirdW, selBottom), gridPaint);
    canvas.drawLine(Offset(selLeft + 2 * thirdW, selTop), Offset(selLeft + 2 * thirdW, selBottom), gridPaint);
    canvas.drawLine(Offset(selLeft, selTop + thirdH), Offset(selRight, selTop + thirdH), gridPaint);
    canvas.drawLine(Offset(selLeft, selTop + 2 * thirdH), Offset(selRight, selTop + 2 * thirdH), gridPaint);
  }

  @override
  bool shouldRepaint(_CropOverlayPainter old) =>
      old.cropLeft != cropLeft || old.cropTop != cropTop ||
      old.cropRight != cropRight || old.cropBottom != cropBottom ||
      old.imgRect != imgRect;
}
