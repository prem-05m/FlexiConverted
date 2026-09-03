import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../widgets/file_picker_widget.dart';
import '../widgets/canvas_overlays.dart';
import '../widgets/progress_dialog.dart';
import '../../domain/models/pdf_task_model.dart';
import '../../domain/engines/pdf_engine.dart';
import '../../data/engines/local_pdf_engine.dart';
import 'package:image_picker/image_picker.dart';
import 'signature_pad_dialog.dart';

class EditPdfScreen extends ConsumerStatefulWidget {
  const EditPdfScreen({super.key});

  @override
  ConsumerState<EditPdfScreen> createState() => _EditPdfScreenState();
}

class _EditPdfScreenState extends ConsumerState<EditPdfScreen> {
  String? _filePath;
  PdfDocument? _pdfDocument;
  int _totalPages = 0;
  int _currentPage = 1;
  PdfPageImage? _currentBackgroundImage;
  
  // State for layers
  final Map<int, List<OverlayLayer>> _pageLayers = {};
  String? _selectedLayerId;

  bool _isLoading = false;
  String _loadingText = '';

  @override
  void dispose() {
    _pdfDocument?.close();
    super.dispose();
  }

  Future<void> _loadPdf(String path) async {
    setState(() {
      _isLoading = true;
      _loadingText = 'Loading document...';
      _filePath = path;
    });

    try {
      _pdfDocument = await PdfDocument.openFile(path);
      _totalPages = _pdfDocument!.pagesCount;
      _pageLayers.clear();
      for (int i = 1; i <= _totalPages; i++) {
        _pageLayers[i] = [];
      }
      await _loadPage(_currentPage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open PDF: $e')));
        setState(() {
          _filePath = null;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPage(int pageNumber) async {
    if (_pdfDocument == null) return;
    setState(() => _isLoading = true);
    
    try {
      final page = await _pdfDocument!.getPage(pageNumber);
      // Render at a high resolution for crisp editing
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.png,
      );
      await page.close();
      
      setState(() {
        _currentBackgroundImage = pageImage;
        _currentPage = pageNumber;
        _selectedLayerId = null; // deselect on page change
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addTextLayer() {
    setState(() {
      _pageLayers[_currentPage]!.add(
        TextLayer(
          x: 50,
          y: 50,
          width: 200,
          height: 100,
          text: 'Double tap to edit',
        ),
      );
    });
  }

  void _addShapeLayer(String shapeType) {
    setState(() {
      _pageLayers[_currentPage]!.add(
        ShapeLayer(
          x: 100,
          y: 100,
          width: 100,
          height: 100,
          shapeType: shapeType,
          backgroundColor: Colors.blue.withValues(alpha: 0.5),
          outlineColor: Colors.blue,
          strokeWidth: 2,
        ),
      );
    });
  }

  Future<void> _addImageLayer() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pageLayers[_currentPage]!.add(
          ImageLayer(
            x: 100,
            y: 100,
            width: 150,
            height: 150,
            imageBytes: bytes,
          ),
        );
      });
    }
  }

  void _addDrawLayer() {
    showDialog(
      context: context,
      builder: (context) => const SignaturePadDialog(),
    ).then((bytes) {
      if (bytes != null) {
        setState(() {
          _pageLayers[_currentPage]!.add(
            ImageLayer(
              x: 100,
              y: 100,
              width: 150,
              height: 150,
              imageBytes: bytes,
            ),
          );
        });
      }
    });
  }

  void _editTextLayer(TextLayer layer) {
    final TextEditingController ctrl = TextEditingController(text: layer.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Text'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Text'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() => layer.text = ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndConvert() async {
    if (_filePath == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ProgressDialog(message: 'Processing...', progress: 0.5),
    );

    try {
      final layers = <PdfLayerData>[];
      for (final entry in _pageLayers.entries) {
        final pageNum = entry.key;
        for (final layer in entry.value) {
          if (layer is TextLayer) {
            layers.add(PdfLayerData(
              pageNumber: pageNum,
              type: 'text',
              x: layer.x,
              y: layer.y,
              width: layer.width,
              height: layer.height,
              rotation: layer.rotation,
              text: layer.text,
              fontSize: layer.fontSize,
              colorHex: '#${(layer.color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
              fontFamily: layer.fontFamily,
              isBold: layer.isBold,
              isItalic: layer.isItalic,
              isUnderline: layer.isUnderline,
            ));
          } else if (layer is ImageLayer) {
            layers.add(PdfLayerData(
              pageNumber: pageNum,
              type: 'image',
              x: layer.x,
              y: layer.y,
              width: layer.width,
              height: layer.height,
              rotation: layer.rotation,
              imageBytes: layer.imageBytes.toList(),
            ));
          } else if (layer is ShapeLayer) {
            layers.add(PdfLayerData(
              pageNumber: pageNum,
              type: 'shape',
              x: layer.x,
              y: layer.y,
              width: layer.width,
              height: layer.height,
              rotation: layer.rotation,
              shapeType: layer.shapeType,
              backgroundColorHex: '#${(layer.backgroundColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
              outlineColorHex: layer.strokeWidth > 0 ? '#${(layer.outlineColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}' : null,
              strokeWidth: layer.strokeWidth,
            ));
          }
        }
      }

      final outputPath = _filePath!.replaceFirst('.pdf', '_edited.pdf');
      
      await LocalPdfEngine().editPdf(
        pdfPath: _filePath!,
        outputPath: outputPath,
        layers: layers,
      );
      
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to: $outputPath')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showLayerPanel() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final layers = _pageLayers[_currentPage] ?? [];
            return Container(
              padding: const EdgeInsets.all(16),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Layers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: layers.isEmpty
                        ? const Center(child: Text('No layers on this page'))
                        : ReorderableListView.builder(
                            itemCount: layers.length,
                            onReorder: (oldIndex, newIndex) {
                              if (oldIndex < newIndex) newIndex -= 1;
                              setState(() {
                                final item = layers.removeAt(oldIndex);
                                layers.insert(newIndex, item);
                              });
                              setSheetState(() {});
                            },
                            itemBuilder: (context, index) {
                              final layer = layers[index];
                              return ListTile(
                                key: ValueKey(layer.id),
                                leading: Icon(
                                  layer is TextLayer ? Icons.text_fields :
                                  layer is ImageLayer ? Icons.image :
                                  layer is DrawLayer ? Icons.draw : Icons.layers,
                                ),
                                title: Text(layer is TextLayer ? layer.text : layer.runtimeType.toString()),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() => layers.removeAt(index));
                                    setSheetState(() {});
                                  },
                                ),
                                selected: _selectedLayerId == layer.id,
                                onTap: () {
                                  setState(() => _selectedLayerId = layer.id);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AnimatedAppBar(
        title: 'Edit PDF',
      ),
      body: _filePath == null
          ? _buildFileSelector()
          : _buildEditorWorkspace(),
      floatingActionButton: _filePath != null ? FloatingActionButton(
        onPressed: _showLayerPanel,
        child: const Icon(Icons.layers),
        tooltip: 'Layer Panel',
      ) : null,
    );
  }

  Widget _buildFileSelector() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: FilePickerWidget(
          title: 'Select PDF to Edit',
          subtitle: 'Original text remains selectable',
          icon: Icons.picture_as_pdf,
          allowedExtensions: const ['pdf'],
          allowMultiple: false,
          onFilesSelected: (files) {
            if (files.isNotEmpty) {
              _loadPdf(files.first);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEditorWorkspace() {
    if (_isLoading && _currentBackgroundImage == null) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_loadingText),
        ],
      ));
    }

    return Column(
      children: [
        // Toolbar
        Container(
          height: 60,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(Icons.text_fields), tooltip: 'Add Text', onPressed: _addTextLayer),
              IconButton(icon: const Icon(Icons.image), tooltip: 'Add Image', onPressed: _addImageLayer),
              IconButton(icon: const Icon(Icons.draw), tooltip: 'Draw', onPressed: _addDrawLayer),
              PopupMenuButton<String>(
                icon: const Icon(Icons.category),
                tooltip: 'Add Shape',
                onSelected: _addShapeLayer,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'rectangle', child: Text('Rectangle')),
                  const PopupMenuItem(value: 'circle', child: Text('Circle')),
                ],
              ),
              const VerticalDivider(width: 1),
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'Convert & Save',
                onPressed: _saveAndConvert,
              ),
            ],
          ),
        ),
        
        // Canvas
        Expanded(
          child: _currentBackgroundImage == null
              ? const Center(child: CircularProgressIndicator())
              : InteractiveViewer(
                  boundaryMargin: EdgeInsets.zero,
                  minScale: 0.1,
                  maxScale: 5.0,
                  constrained: true,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Background PDF Page
                          Image.memory(
                            _currentBackgroundImage!.bytes,
                            width: (_currentBackgroundImage!.width ?? 0).toDouble() / 2, // scale down to normal logical pixels
                            height: (_currentBackgroundImage!.height ?? 0).toDouble() / 2,
                            fit: BoxFit.contain,
                          ),
                          
                          // Overlays
                          ...(_pageLayers[_currentPage] ?? []).map((layer) {
                            return InteractiveOverlay(
                              key: ValueKey(layer.id),
                              layer: layer,
                              isSelected: _selectedLayerId == layer.id,
                              onTap: () => setState(() => _selectedLayerId = layer.id),
                              onDoubleTap: layer is TextLayer ? () => _editTextLayer(layer as TextLayer) : null,
                              onMove: (dx, dy) => setState(() {
                                layer.x += dx;
                                layer.y += dy;
                              }),
                              onResize: (dw, dh, dx, dy) => setState(() {
                                layer.width += dw;
                                layer.height += dh;
                                layer.x += dx;
                                layer.y += dy;
                              }),
                              onRotate: (deltaAngle) => setState(() {
                                layer.rotation += deltaAngle;
                              }),
                              onDelete: () => setState(() {
                                _pageLayers[_currentPage]!.remove(layer);
                                if (_selectedLayerId == layer.id) _selectedLayerId = null;
                              }),
                              child: _buildLayerWidget(layer),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
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
                onPressed: _currentPage > 1 ? () => _loadPage(_currentPage - 1) : null,
              ),
              Text('Page $_currentPage of $_totalPages'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages ? () => _loadPage(_currentPage + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLayerWidget(OverlayLayer layer) {
    if (layer is TextLayer) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white.withOpacity(0.5),
        child: Center(
          child: Text(
            layer.text,
            style: TextStyle(
              color: layer.color,
              fontSize: layer.fontSize,
              fontFamily: layer.fontFamily,
              fontWeight: layer.isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: layer.isItalic ? FontStyle.italic : FontStyle.normal,
              decoration: layer.isUnderline ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ),
      );
    } else if (layer is ShapeLayer) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: layer.backgroundColor,
          shape: layer.shapeType == 'circle' ? BoxShape.circle : BoxShape.rectangle,
          border: layer.strokeWidth > 0 ? Border.all(
            color: layer.outlineColor,
            width: layer.strokeWidth,
          ) : null,
        ),
      );
    } else if (layer is ImageLayer) {
      return Image.memory(
        layer.imageBytes,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      );
    }
    return const SizedBox();
  }
}
