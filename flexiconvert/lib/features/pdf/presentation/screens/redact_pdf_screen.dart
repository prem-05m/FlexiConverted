import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../widgets/file_picker_widget.dart';
import '../../../../core/services/download_location_service.dart';
import '../../domain/models/pdf_task_model.dart';
import '../providers/pdf_task_provider.dart';

class RedactionData {
  final int pageIndex;
  final String type; // 'clear', 'paint'
  final Rect bounds;
  final Color color;

  RedactionData({
    required this.pageIndex,
    required this.type,
    required this.bounds,
    required this.color,
  });
}

class RedactPdfScreen extends ConsumerStatefulWidget {
  const RedactPdfScreen({super.key});

  @override
  ConsumerState<RedactPdfScreen> createState() => _RedactPdfScreenState();
}

class _RedactPdfScreenState extends ConsumerState<RedactPdfScreen> {
  String? _selectedFile;
  int _currentPage = 1;
  int _totalPages = 0;
  final PdfViewerController _pdfViewerController = PdfViewerController();

  final List<RedactionData> _redactions = [];
  
  // Current drawing state
  Offset? _startPos;
  Offset? _currentPos;
  String _mode = 'box'; // 'box', 'draw'
  String _actionType = 'clear'; // 'clear', 'paint', 'blur'
  Color _selectedColor = Colors.black;
  double _opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    if (_selectedFile == null) {
      return Scaffold(
        appBar: const AnimatedAppBar(title: 'Redact PDF'),
        body: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilePickerWidget(
                title: 'Upload PDF to Redact',
                subtitle: 'Drag and drop or browse',
                icon: Icons.security,
                allowMultiple: false,
                allowedExtensions: const ['pdf'],
                onFilesSelected: (files) {
                  if (files.isNotEmpty) {
                    setState(() => _selectedFile = files.first);
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Redact Areas'),
        actions: [
          FilledButton.icon(
            onPressed: _redactions.isNotEmpty ? _savePdf : null,
            icon: const Icon(Icons.security),
            label: const Text('Apply Redactions'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'box', icon: Icon(Icons.crop_square), label: Text('Box')),
                    ButtonSegment(value: 'draw', icon: Icon(Icons.edit), label: Text('Draw')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() => _mode = newSelection.first);
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _actionType,
                  items: const [
                    DropdownMenuItem(value: 'clear', child: Text('Clear (Whiteout)')),
                    DropdownMenuItem(value: 'paint', child: Text('Paint (Color)')),
                    DropdownMenuItem(value: 'blur', child: Text('Blur (Translucent)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _actionType = val);
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: _redactions.isNotEmpty ? () {
                    setState(() => _redactions.removeLast());
                  } : null,
                ),
              ],
            ),
          ),
          if (_actionType != 'clear')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('Opacity: '),
                  Slider(
                    value: _opacity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 4,
                    label: '${(_opacity * 100).round()}%',
                    onChanged: (val) => setState(() => _opacity = val),
                  ),
                ],
              ),
            ),
            
          Expanded(
            child: Stack(
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
                
                // Drawing overlay
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _startPos = details.localPosition;
                        _currentPos = details.localPosition;
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _currentPos = details.localPosition;
                      });
                    },
                    onPanEnd: (details) {
                      if (_startPos != null && _currentPos != null) {
                        setState(() {
                          _redactions.add(RedactionData(
                            pageIndex: _currentPage - 1,
                            type: _actionType == 'clear' ? 'clear' : 'paint',
                            bounds: Rect.fromPoints(_startPos!, _currentPos!),
                            color: _actionType == 'clear' 
                                ? Colors.white 
                                : _selectedColor.withOpacity(_actionType == 'blur' ? (_opacity == 1.0 ? 0.5 : _opacity) : _opacity),
                          ));
                          _startPos = null;
                          _currentPos = null;
                        });
                      }
                    },
                    child: CustomPaint(
                      painter: RedactionPainter(
                        redactions: _redactions.where((r) => r.pageIndex == _currentPage - 1).toList(),
                        currentStart: _startPos,
                        currentEnd: _currentPos,
                        isDrawing: _mode == 'draw',
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Page Navigator
          Container(
            height: 50,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1 ? () => _pdfViewerController.previousPage() : null,
                ),
                Text('Page $_currentPage of $_totalPages'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < _totalPages ? () => _pdfViewerController.nextPage() : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePdf() async {
    if (_redactions.isEmpty || _selectedFile == null) return;
    
    final outputPath = await DownloadLocationService.getOutputPath(context, ref, _selectedFile!.split(Platform.pathSeparator).last.replaceAll('.pdf', '_redacted.pdf'));
    if (outputPath == null) return;
    
    ref.read(pdfTaskProvider.notifier).initializeTask(PdfToolType.redactPdf, [_selectedFile!]);
    
    final formattedRedactions = _redactions.map((r) {
      // NOTE: UI coordinates need to be mapped properly. 
      // Assuming a naive 1:1 mapping for this demo, though proper PDF transform is needed.
      return {
        'pageIndex': r.pageIndex,
        'type': r.type,
        'x': r.bounds.left,
        'y': r.bounds.top,
        'width': r.bounds.width,
        'height': r.bounds.height,
        'color': r.color.value,
      };
    }).toList();
    
    await ref.read(pdfTaskProvider.notifier).executeTask(
      outputPath: outputPath,
      additionalParams: {
        'redactions': formattedRedactions,
      },
    );
    
    if (mounted) {
      final state = ref.read(pdfTaskProvider);
      if (state.status == TaskStatus.success) {
        context.go('${RouteConstants.completed}?from=${Uri.encodeComponent('/home/pdf/redactPdf')}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Failed')));
      }
    }
  }
}

class RedactionPainter extends CustomPainter {
  final List<RedactionData> redactions;
  final Offset? currentStart;
  final Offset? currentEnd;
  final bool isDrawing;

  RedactionPainter({
    required this.redactions,
    this.currentStart,
    this.currentEnd,
    this.isDrawing = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in redactions) {
      final paint = Paint()
        ..color = r.color
        ..style = PaintingStyle.fill;
      canvas.drawRect(r.bounds, paint);
    }
    
    if (currentStart != null && currentEnd != null) {
      final paint = Paint()
        ..color = Colors.red.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromPoints(currentStart!, currentEnd!), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
