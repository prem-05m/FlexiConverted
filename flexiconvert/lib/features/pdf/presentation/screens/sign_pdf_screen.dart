import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../widgets/file_picker_widget.dart';
import '../../../../core/services/download_location_service.dart';
import '../../domain/models/pdf_task_model.dart';
import '../providers/pdf_task_provider.dart';
import 'signature_pad_dialog.dart';

class SignatureOverlayData {
  final String id;
  Offset position;
  double scale;
  double rotation; // radians
  final Uint8List bytes;
  final int pageIndex;

  SignatureOverlayData({
    required this.id,
    required this.position,
    required this.scale,
    required this.rotation,
    required this.bytes,
    required this.pageIndex,
  });
  
  SignatureOverlayData copyWith({
    String? id,
    Offset? position,
    double? scale,
    double? rotation,
    Uint8List? bytes,
    int? pageIndex,
  }) {
    return SignatureOverlayData(
      id: id ?? this.id,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      bytes: bytes ?? this.bytes,
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }
}

class SignPdfScreen extends ConsumerStatefulWidget {
  const SignPdfScreen({super.key});

  @override
  ConsumerState<SignPdfScreen> createState() => _SignPdfScreenState();
}

class _SignPdfScreenState extends ConsumerState<SignPdfScreen> {
  String? _selectedFile;
  int _currentPage = 1;
  int _totalPages = 0;
  final PdfViewerController _pdfViewerController = PdfViewerController();

  final List<SignatureOverlayData> _signatures = [];

  @override
  Widget build(BuildContext context) {
    if (_selectedFile == null) {
      return Scaffold(
        appBar: const AnimatedAppBar(title: 'Sign PDF'),
        body: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilePickerWidget(
                title: 'Upload PDF to Sign',
                subtitle: 'Drag and drop or browse',
                icon: Icons.picture_as_pdf,
                allowMultiple: false,
                allowedExtensions: const ['pdf'],
                onFilesSelected: (files) {
                  if (files.isNotEmpty) {
                    setState(() => _selectedFile = files.first);
                  }
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Cloud Multi-Signer Feature Available!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 8),
              const Text('Send this PDF to multiple people for signatures using the FlexiConverted secure cloud.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Signature'),
        actions: [
          TextButton.icon(
            onPressed: _showCloudMultiSignDialog,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Request Signatures'),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
          ),
          FilledButton.icon(
            onPressed: _signatures.isNotEmpty ? _savePdf : null,
            icon: const Icon(Icons.save),
            label: const Text('Save Local'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.file(
            File(_selectedFile!),
            controller: _pdfViewerController,
            canShowScrollHead: false,
            onDocumentLoaded: (details) {
              setState(() => _totalPages = details.document.pages.count);
            },
            onPageChanged: (details) {
              setState(() => _currentPage = details.newPageNumber);
            },
          ),
          
          for (final sig in _signatures.where((s) => s.pageIndex == _currentPage - 1))
            Positioned(
              left: sig.position.dx,
              top: sig.position.dy,
              child: _buildSignatureWidget(sig),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: _showSignatureOptions,
              icon: const Icon(Icons.draw),
              label: const Text('Add Signature'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSignatureWidget(SignatureOverlayData sig) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          sig.position += details.delta;
        });
      },
      child: Transform.rotate(
        angle: sig.rotation,
        child: Transform.scale(
          scale: sig.scale,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.withValues(alpha: 0.5), width: 2 / sig.scale, style: BorderStyle.solid),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.memory(
                  sig.bytes,
                  width: 200,
                  fit: BoxFit.contain,
                ),
                // Resize Handle
                Positioned(
                  right: -15,
                  bottom: -15,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        sig.scale += details.delta.dy * 0.01;
                        if (sig.scale < 0.2) sig.scale = 0.2;
                        if (sig.scale > 5.0) sig.scale = 5.0;
                      });
                    },
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.open_with, size: 16 / sig.scale, color: Colors.white),
                    ),
                  ),
                ),
                // Close Handle
                Positioned(
                  left: -15,
                  top: -15,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _signatures.removeWhere((s) => s.id == sig.id);
                      });
                    },
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, size: 16 / sig.scale, color: Colors.white),
                    ),
                  ),
                ),
                // Rotate Handle
                Positioned(
                  right: -15,
                  top: -15,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        sig.rotation += details.delta.dy * 0.02;
                      });
                    },
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.rotate_right, size: 16 / sig.scale, color: Colors.white),
                    ),
                  ),
                ),
                // Duplicate Handle
                Positioned(
                  left: -15,
                  bottom: -15,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _signatures.add(sig.copyWith(
                          id: const Uuid().v4(),
                          position: sig.position + const Offset(20, 20),
                        ));
                      });
                    },
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.copy, size: 16 / sig.scale, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSignatureOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.draw),
              title: const Text('Draw Signature'),
              onTap: () {
                Navigator.pop(context);
                _openSignaturePad();
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Type Signature'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Upload Image'),
              subtitle: const Text('For better real sign use plain white background'),
              onTap: () {
                Navigator.pop(context);
                _openImageSignature();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _openSignaturePad() {
    showDialog(
      context: context,
      builder: (context) => const SignaturePadDialog(),
    ).then((bytes) {
      if (bytes != null) {
        setState(() {
          _signatures.add(SignatureOverlayData(
            id: const Uuid().v4(),
            position: const Offset(100, 100),
            scale: 1.0,
            rotation: 0.0,
            bytes: bytes,
            pageIndex: _currentPage - 1,
          ));
        });
      }
    });
  }
  
  Future<void> _openImageSignature() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final processedBytes = await _removeWhiteBackground(bytes);
      setState(() {
        _signatures.add(SignatureOverlayData(
          id: const Uuid().v4(),
          position: const Offset(100, 100),
          scale: 1.0,
          rotation: 0.0,
          bytes: processedBytes,
          pageIndex: _currentPage - 1,
        ));
      });
    }
  }

  Future<Uint8List> _removeWhiteBackground(Uint8List bytes) async {
    return await compute(_processPixels, bytes);
  }

  static Uint8List _processPixels(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        if (pixel.r > 200 && pixel.g > 200 && pixel.b > 200) {
          image.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, 0);
        }
      }
    }
    return Uint8List.fromList(img.encodePng(image));
  }

  void _showCloudMultiSignDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Signatures'),
        content: const Text('This will upload the PDF to FlexiConverted Cloud and send signature requests to multiple people.\n\nContinue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cloud signature request initiated!')));
          }, child: const Text('Send')),
        ],
      ),
    );
  }

  Future<void> _savePdf() async {
    if (_signatures.isEmpty || _selectedFile == null) return;
    
    final outputPath = await DownloadLocationService.getOutputPath(context, ref, _selectedFile!.split(Platform.pathSeparator).last.replaceAll('.pdf', '_signed.pdf'));
    if (outputPath == null) return;
    
    ref.read(pdfTaskProvider.notifier).initializeTask(PdfToolType.addSignature, [_selectedFile!]);
    
    final formattedSignatures = _signatures.map((sig) {
      return {
        'signatureBytes': sig.bytes,
        'x': sig.position.dx.clamp(0.0, 1000.0),
        'y': sig.position.dy.clamp(0.0, 1000.0),
        'width': 200 * sig.scale,
        'height': 100 * sig.scale,
        'rotation': sig.rotation,
        'pageIndex': sig.pageIndex,
      };
    }).toList();
    
    await ref.read(pdfTaskProvider.notifier).executeTask(
      outputPath: outputPath,
      additionalParams: {
        'signatures': formattedSignatures,
      },
    );
    
    if (mounted) {
      final state = ref.read(pdfTaskProvider);
      if (state.status == TaskStatus.success) {
        context.go('${RouteConstants.completed}?from=${Uri.encodeComponent('/home/pdf/addSignature')}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Failed')));
      }
    }
  }
}
