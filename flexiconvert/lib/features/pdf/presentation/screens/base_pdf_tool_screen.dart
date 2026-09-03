import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as pathLib;
import 'package:pdfx/pdfx.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../core/services/download_location_service.dart';
import '../../../../core/services/history_service.dart';
import '../../domain/engines/pdf_engine.dart';
import '../../domain/models/pdf_task_model.dart';
import '../providers/pdf_task_provider.dart';
import '../widgets/file_picker_widget.dart';
import '../widgets/progress_dialog.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:crop_image/crop_image.dart';
import 'package:image/image.dart' as img;
import 'scan_to_pdf_screen.dart';
import 'add_page_numbers_screen.dart';
import 'watermark_pdf_options_widget.dart';


class BasePdfToolScreen extends ConsumerStatefulWidget {
  final PdfToolType toolType;

  const BasePdfToolScreen({super.key, required this.toolType});

  @override
  ConsumerState<BasePdfToolScreen> createState() => _BasePdfToolScreenState();
}

enum _SplitMode { range, customPage }

// Colors for multi-PDF organize mode (per file)
const _pdfColors = [
  Color(0xFFE53935),
  Color(0xFF00ACC1),
  Color(0xFF43A047),
  Color(0xFFFB8C00),
  Color(0xFF8E24AA),
];

// Color palette for page number color picker
const _colorPalette = [
  Colors.black, Colors.white, Colors.grey,
  Colors.red, Colors.pink, Colors.purple,
  Colors.deepPurple, Colors.indigo, Colors.blue,
  Colors.lightBlue, Colors.cyan, Colors.teal,
  Colors.green, Colors.lightGreen, Colors.lime,
  Colors.yellow, Colors.amber, Colors.orange,
  Colors.deepOrange, Colors.brown, Colors.blueGrey,
];

class _BasePdfToolScreenState extends ConsumerState<BasePdfToolScreen> {
  List<String> selectedFiles = [];
  String _orientation = 'portrait';
  String _pageSize = 'fit';
  bool _isAscending = true;

  final TextEditingController _fileNameCtrl = TextEditingController();
  String _saveAsFormat = 'zip'; // 'zip' or 'folder'

  // Merge PDF
  final Map<String, Uint8List?> _pdfPreviews = {};
  final Map<String, int> _mergeRotations = {};

  // Split PDF state
  _SplitMode _splitMode = _SplitMode.range;
  final TextEditingController _rangeFromCtrl = TextEditingController();
  final TextEditingController _rangeToCtrl = TextEditingController();
  int _totalPages = 0;
  List<Uint8List> _pageImages = [];
  final Set<int> _selectedPages = {};
  bool _loadingPages = false;
  Uint8List? _rangeFromThumb;
  Uint8List? _rangeToThumb;
  final Map<int, int> _pageRotations = {};

  // Remove Pages
  final Set<int> _pagesToRemove = {};
  final TextEditingController _removePageCtrl = TextEditingController();

  // Organize PDF
  List<int> _organizePageOrder = [];
  List<_OrgPage> _multiOrgPages = [];

  // Compress PDF
  int _compressLevel = 1;
  final TextEditingController _customSizeCtrl = TextEditingController();

  // ── OCR PDF state ──────────────────────────────────────────────────────────
  bool _ocrMergeOutput = true;
  final Map<String, int> _ocrRotations = {};
  final Map<String, Uint8List?> _ocrPreviews = {};
  String _ocrMode = 'online';          // 'online' | 'offline'
  String _ocrOutputFormat = 'pdf';     // 'pdf' | 'txt'

  // ── Rotate PDF state ───────────────────────────────────────────────────────
  // Single PDF: page-level angles
  final Map<int, int> _rotateSinglePageAngles = {};
  // Multi PDF: file-level angles
  final Map<String, int> _rotateFileAngles = {};
  // Per-file first-page previews for multi rotate
  final Map<String, Uint8List?> _rotatePreviews = {};
  // All pages thumbnails for single rotate
  List<Uint8List> _rotateSinglePageImages = [];
  bool _loadingRotatePages = false;

  // ── Add Page Numbers state ─────────────────────────────────────────────────
  PageNumberOptions _pageNumberOptions = const PageNumberOptions();
  final Map<String, Uint8List?> _pnPreviews = {};
  // ── Font families for add page numbers ────────────────────────────────────
  static const _fontFamilies = [
    'Arial', 'Impact', 'Arial Unicode MS', 'Verdana',
    'Courier', 'Comic', 'Times New Roman',
    'Lohit Marathi', 'Lohit Devanagari',
  ];

  // ── Protect / Unlock PDF state ─────────────────────────────────────────────
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  Uint8List? _encryptPreview;
  bool _removePassword = false;

  // PDF to Markdown state
  bool _pdfToMarkdownGenerateSummary = false;

  // ── Crop PDF state ─────────────────────────────────────────────────────────
  String _cropApplyTo = 'current'; // 'current' or 'all'
  final Map<int, Rect> _cropRects = {};
  final Map<int, int> _cropPageRotations = {};   // per-page rotation (0/90/180/270)
  final Map<int, bool> _cropMirrorH = {};         // per-page horizontal mirror
  final Map<int, bool> _cropMirrorV = {};         // per-page vertical mirror
  
  // Watermark Options
  WatermarkOptions _watermarkOptions = const WatermarkOptions();
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _fileNameCtrl.dispose();
    _rangeFromCtrl.dispose();
    _rangeToCtrl.dispose();
    _removePageCtrl.dispose();
    _customSizeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.toolType) {
      case PdfToolType.deletePages: return 'Remove Pages';
      case PdfToolType.reorderPages: return 'Organize PDF';
      case PdfToolType.scanToPdf: return 'Scan to PDF';
      case PdfToolType.addPageNumbers: return 'Add Page Numbers';
      default:
        return widget.toolType.name
            .replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m.group(0)}')
            .replaceFirst(RegExp(r'^[a-z]'), widget.toolType.name[0].toUpperCase());
    }
  }

  bool get _isMultiOrgMode =>
      widget.toolType == PdfToolType.reorderPages && selectedFiles.length > 1;

  bool get _isSingleOrgMode =>
      widget.toolType == PdfToolType.reorderPages && selectedFiles.length == 1;

  bool get _isRotateSingle =>
      widget.toolType == PdfToolType.rotatePdf && selectedFiles.length == 1;

  bool get _isRotateMulti =>
      widget.toolType == PdfToolType.rotatePdf && selectedFiles.length > 1;

  String _defaultFileNameStem(List<String> paths) {
    if (paths.isEmpty) return 'output';
    final base = pathLib.basenameWithoutExtension(paths.first);
    switch (widget.toolType) {
      case PdfToolType.mergePdf: return 'FlexiConvert_Merge';
      case PdfToolType.splitPdf: return '${base}_Split';
      case PdfToolType.deletePages: return '${base}_Removed';
      case PdfToolType.compressPdf: return '${base}_Compressed';
      case PdfToolType.ocrPdf:
        return paths.length == 1 ? '${base}_OCR' : 'FlexiConvert_OCR_Merged';
      case PdfToolType.reorderPages:
        return paths.length == 1 ? '${base}_Organize' : 'Organize';
      case PdfToolType.rotatePdf:
        return paths.length == 1 ? '${base}_Rotated' : 'Rotate';
      case PdfToolType.addPageNumbers:
        return paths.length == 1 ? '${base}_Numbered' : 'Added Page No';
      case PdfToolType.imageToPdf: return 'FlexiConvert_Image';
      default: return 'FlexiConvert_${widget.toolType.name}';
    }
  }

  /// Whether this tool supports appending files on subsequent picks
  bool get _canAppend =>
      widget.toolType == PdfToolType.mergePdf ||
      widget.toolType == PdfToolType.imageToPdf ||
      widget.toolType == PdfToolType.ocrPdf ||
      widget.toolType == PdfToolType.rotatePdf ||
      widget.toolType == PdfToolType.reorderPages ||
      widget.toolType == PdfToolType.addPageNumbers;

  void _onFilesSelected(List<String> paths) {
    // Single-file tools: replace existing file instead of appending
    final isSingleFileOnly = widget.toolType == PdfToolType.cropPdf ||
        widget.toolType == PdfToolType.encryptPdf ||
        widget.toolType == PdfToolType.unlockPdf ||
        widget.toolType == PdfToolType.addPageNumbers;

    if (isSingleFileOnly && paths.isNotEmpty) {
      setState(() {
        selectedFiles = [paths.first];
        _passwordCtrl.clear();
        _confirmPasswordCtrl.clear();
        _cropRects.clear();
        _cropPageRotations.clear();
        _cropMirrorH.clear();
        _cropMirrorV.clear();
        _rotateSinglePageImages.clear();
        _encryptPreview = null;
      });
      _fileNameCtrl.text = _defaultFileNameStem([paths.first]);
      if (widget.toolType == PdfToolType.cropPdf) {
        _loadRotateSinglePages(paths.first);
      } else if (widget.toolType == PdfToolType.addPageNumbers) {
        _loadAllPageThumbnails(paths.first);
      } else {
        _loadEncryptPreview(paths.first);
      }
      if (paths.length > 1) {
        _snack('Only 1 file is allowed. Using the first file selected.', Colors.orange);
      }
      return;
    }

    setState(() {
      if (_canAppend) {
        selectedFiles.addAll(paths);
      } else {
        selectedFiles = paths;
        _pdfPreviews.clear();
        _mergeRotations.clear();
        _pageImages.clear();
        _selectedPages.clear();
        _pagesToRemove.clear();
        _removePageCtrl.clear();
        _organizePageOrder.clear();
        _multiOrgPages.clear();
        _totalPages = 0;
        _rangeFromThumb = null;
        _rangeToThumb = null;
        _pageRotations.clear();
        _ocrRotations.clear();
        _ocrPreviews.clear();
        _rotateSinglePageAngles.clear();
        _rotateFileAngles.clear();
        _rotatePreviews.clear();
        _rotateSinglePageImages.clear();
        _pnPreviews.clear();
      }
    });
    _fileNameCtrl.text = _defaultFileNameStem(selectedFiles);

    if (widget.toolType == PdfToolType.mergePdf) {
      _loadMergePreviews(paths);
    } else if (widget.toolType == PdfToolType.splitPdf && paths.isNotEmpty) {
      _loadAllPageThumbnails(paths.first);
    } else if (widget.toolType == PdfToolType.deletePages && paths.isNotEmpty) {
      _loadAllPageThumbnails(paths.first);
    } else if (widget.toolType == PdfToolType.reorderPages) {
      if (selectedFiles.length == 1) {
        _loadOrganizeSinglePdf(selectedFiles.first);
      } else if (selectedFiles.length > 1) {
        _loadOrganizeMultiPdf(selectedFiles);
      }
    } else if (widget.toolType == PdfToolType.ocrPdf) {
      _loadOcrPreviews(paths);
    } else if (widget.toolType == PdfToolType.rotatePdf) {
      if (selectedFiles.length == 1) {
        _loadRotateSinglePages(selectedFiles.first);
      } else {
        _loadRotatePreviews(paths);
      }
    } else if (widget.toolType == PdfToolType.addPageNumbers) {
      _loadPnPreviews(paths);
    }
  }

  Future<void> _loadEncryptPreview(String filePath) async {
    final thumb = await _loadPageThumb(filePath, 1);
    if (mounted) setState(() => _encryptPreview = thumb);
  }

  // ── Thumbnail loaders ──────────────────────────────────────────────────────

  Future<Uint8List?> _loadPageThumb(String filePath, int pageNum, {String? password}) async {
    try {
      final doc = await PdfDocument.openFile(filePath, password: password);
      if (pageNum < 1 || pageNum > doc.pagesCount) { await doc.close(); return null; }
      final pg = await doc.getPage(pageNum);
      final img = await pg.render(width: pg.width, height: pg.height, format: PdfPageImageFormat.jpeg);
      await pg.close();
      await doc.close();
      return img?.bytes;
    } catch (_) { return null; }
  }

  Future<void> _updateRangeThumbnails() async {
    final fromPage = int.tryParse(_rangeFromCtrl.text);
    final toPage = int.tryParse(_rangeToCtrl.text);
    if (selectedFiles.isEmpty) return;
    final from = (fromPage != null && fromPage >= 1 && fromPage <= _totalPages) ? fromPage : null;
    final to = (toPage != null && toPage >= 1 && toPage <= _totalPages) ? toPage : null;
    final fromThumb = from != null ? await _loadPageThumb(selectedFiles.first, from) : null;
    final toThumb = to != null ? await _loadPageThumb(selectedFiles.first, to) : null;
    if (mounted) setState(() { _rangeFromThumb = fromThumb; _rangeToThumb = toThumb; });
  }

  Future<void> _loadMergePreviews(List<String> paths) async {
    for (final filePath in paths) {
      if (_pdfPreviews.containsKey(filePath)) continue;
      try {
        final doc = await PdfDocument.openFile(filePath);
        final page = await doc.getPage(1);
        final img = await page.render(width: page.width * 1.5, height: page.height * 1.5, format: PdfPageImageFormat.jpeg);
        await page.close();
        await doc.close();
        if (mounted) setState(() => _pdfPreviews[filePath] = img?.bytes);
      } catch (_) {
        if (mounted) setState(() => _pdfPreviews[filePath] = null);
      }
    }
  }

  Future<void> _loadAllPageThumbnails(String filePath) async {
    setState(() => _loadingPages = true);
    try {
      final doc = await PdfDocument.openFile(filePath);
      _totalPages = doc.pagesCount;
      final List<Uint8List> images = [];
      for (int i = 1; i <= doc.pagesCount; i++) {
        final pg = await doc.getPage(i);
        final img = await pg.render(width: pg.width, height: pg.height, format: PdfPageImageFormat.jpeg);
        await pg.close();
        if (img != null) images.add(img.bytes);
      }
      await doc.close();
      if (mounted) {
        setState(() {
          _pageImages = images;
          _loadingPages = false;
          if (widget.toolType == PdfToolType.reorderPages) {
            _organizePageOrder = List.generate(images.length, (i) => i + 1);
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPages = false);
    }
  }

  Future<void> _loadOrganizeSinglePdf(String filePath) async {
    await _loadAllPageThumbnails(filePath);
  }

  Future<void> _loadOrganizeMultiPdf(List<String> paths) async {
    setState(() => _loadingPages = true);
    final List<_OrgPage> pages = [];
    for (int fi = 0; fi < paths.length; fi++) {
      try {
        final doc = await PdfDocument.openFile(paths[fi]);
        for (int i = 1; i <= doc.pagesCount; i++) {
          final pg = await doc.getPage(i);
          final img = await pg.render(width: pg.width * 0.8, height: pg.height * 0.8, format: PdfPageImageFormat.jpeg);
          await pg.close();
          pages.add(_OrgPage(fileIndex: fi, pageNum: i, thumbnail: img?.bytes));
        }
        await doc.close();
      } catch (_) {}
    }
    if (mounted) setState(() { _multiOrgPages = pages; _loadingPages = false; });
  }

  Future<void> _loadOcrPreviews(List<String> paths) async {
    for (final filePath in paths) {
      if (_ocrPreviews.containsKey(filePath)) continue;
      try {
        final doc = await PdfDocument.openFile(filePath);
        final page = await doc.getPage(1);
        final img = await page.render(width: page.width * 1.5, height: page.height * 1.5, format: PdfPageImageFormat.jpeg);
        await page.close();
        await doc.close();
        if (mounted) setState(() => _ocrPreviews[filePath] = img?.bytes);
      } catch (_) {
        if (mounted) setState(() => _ocrPreviews[filePath] = null);
      }
    }
  }

  Future<void> _loadRotateSinglePages(String filePath) async {
    setState(() { _loadingRotatePages = true; _rotateSinglePageImages.clear(); _rotateSinglePageAngles.clear(); });
    try {
      final doc = await PdfDocument.openFile(filePath);
      final imgs = <Uint8List>[];
      for (int i = 1; i <= doc.pagesCount; i++) {
        final pg = await doc.getPage(i);
        final img = await pg.render(width: pg.width, height: pg.height, format: PdfPageImageFormat.jpeg);
        await pg.close();
        if (img != null) imgs.add(img.bytes);
      }
      await doc.close();
      if (mounted) setState(() { _rotateSinglePageImages = imgs; _loadingRotatePages = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingRotatePages = false);
    }
  }

  Future<void> _loadRotatePreviews(List<String> paths) async {
    for (final filePath in paths) {
      if (_rotatePreviews.containsKey(filePath)) continue;
      final thumb = await _loadPageThumb(filePath, 1);
      if (mounted) setState(() => _rotatePreviews[filePath] = thumb);
    }
  }

  Future<void> _loadPnPreviews(List<String> paths) async {
    for (final filePath in paths) {
      if (_pnPreviews.containsKey(filePath)) continue;
      final thumb = await _loadPageThumb(filePath, 1);
      if (mounted) setState(() => _pnPreviews[filePath] = thumb);
    }
  }

  // ── Remove Pages helpers ───────────────────────────────────────────────────

  void _onRemoveTextChanged(String text) {
    final Set<int> parsed = {};
    for (final part in text.split(',')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.contains('-')) {
        final range = trimmed.split('-');
        if (range.length == 2) {
          final from = int.tryParse(range[0].trim());
          final to = int.tryParse(range[1].trim());
          if (from != null && to != null) {
            for (int i = from; i <= to && i <= _totalPages; i++) {
              if (i >= 1) parsed.add(i);
            }
          }
        }
      } else {
        final n = int.tryParse(trimmed);
        if (n != null && n >= 1 && n <= _totalPages) parsed.add(n);
      }
    }
    setState(() {
      _pagesToRemove.clear();
      _pagesToRemove.addAll(parsed);
    });
  }

  void _toggleRemovePage(int pageNum) {
    setState(() {
      if (_pagesToRemove.contains(pageNum)) {
        _pagesToRemove.remove(pageNum);
      } else {
        _pagesToRemove.add(pageNum);
      }
      final sorted = _pagesToRemove.toList()..sort();
      _removePageCtrl.text = sorted.join(', ');
    });
  }

  // ── Process / Convert ──────────────────────────────────────────────────────

  Future<void> _processFiles() async {
    if (selectedFiles.isEmpty) return;

    if (widget.toolType == PdfToolType.mergePdf && selectedFiles.length < 2) {
      _snack('Please select at least 2 PDF files to merge.', Colors.red);
      return;
    }

    String stem = _fileNameCtrl.text.trim();
    if (stem.isEmpty) stem = _defaultFileNameStem(selectedFiles);
    if (stem.toLowerCase().endsWith('.pdf')) stem = stem.substring(0, stem.length - 4);

    Map<String, dynamic> extraParams = {
      'orientation': _orientation,
      'pageSize': _pageSize,
      'generateSummary': _pdfToMarkdownGenerateSummary,
    };

    // ── OCR ─────────────────────────────────────────────────────────────────
    if (widget.toolType == PdfToolType.ocrPdf) {
      // Ask output format
      final format = await _showOcrFormatDialog();
      if (format == null) return;

      bool doMerge = _ocrMergeOutput;
      if (selectedFiles.length > 1) {
        final choice = await _showOcrMergeDialog();
        if (choice == null) return;
        doMerge = choice;
      }

      extraParams['ocrMode'] = _ocrMode;
      extraParams['outputFormat'] = format;
      extraParams['mergeOutput'] = doMerge;
      extraParams['fileRotations'] = Map<String, int>.from(_ocrRotations);

      final ext = format == 'txt' ? '.txt' : '.pdf';
      final fileName = '$stem$ext';
      if (!mounted) return;
      final outputPath = await DownloadLocationService.getOutputPath(context, ref, fileName);
      if (outputPath == null) return;

      await _executeTask(outputPath, extraParams);
      return;
    }

    // ── Rotate PDF ───────────────────────────────────────────────────────────
    if (widget.toolType == PdfToolType.rotatePdf) {
      if (_isRotateMulti) {
        // Ask zip or folder
        final saveAsFolder = _saveAsFormat == 'folder';
        final ext = saveAsFolder ? '' : '.zip';
        if (!mounted) return;
        final outputPath = await DownloadLocationService.getOutputPath(context, ref, '$stem$ext');
        if (outputPath == null) return;

        extraParams['multiFile'] = true;
        extraParams['fileAngles'] = Map<String, int>.from(_rotateFileAngles);
        extraParams['saveAsFolder'] = saveAsFolder;
        await _executeTask(outputPath, extraParams);
        return;
      } else {
        // Single PDF
        final outputPath = await DownloadLocationService.getOutputPath(context, ref, '$stem.pdf');
        if (outputPath == null) return;
        extraParams['multiFile'] = false;
        extraParams['pageAngles'] = Map<int, int>.from(_rotateSinglePageAngles);
        await _executeTask(outputPath, extraParams);
        return;
      }
    }

    // ── Add Page Numbers ─────────────────────────────────────────────────────
    if (widget.toolType == PdfToolType.addPageNumbers) {
      extraParams['pageNumberOptions'] = _pageNumberOptions;

      if (selectedFiles.length > 1) {
        final saveAsFolder = _saveAsFormat == 'folder';
        final ext = saveAsFolder ? '' : '.zip';
        if (!mounted) return;
        final outputPath = await DownloadLocationService.getOutputPath(context, ref, '$stem$ext');
        if (outputPath == null) return;
        extraParams['saveAsFolder'] = saveAsFolder;
        await _executeTask(outputPath, extraParams);
        return;
      } else {
        final outputPath = await DownloadLocationService.getOutputPath(context, ref, '$stem.pdf');
        if (outputPath == null) return;
        await _executeTask(outputPath, extraParams);
        return;
      }
    }
    
    // ── Watermark PDF ────────────────────────────────────────────────────────
    if (widget.toolType == PdfToolType.watermarkPdf) {
      extraParams['options'] = _watermarkOptions;
      final outputPath = await DownloadLocationService.getOutputPath(context, ref, '$stem.pdf');
      if (outputPath == null) return;
      await _executeTask(outputPath, extraParams);
      return;
    }

    // ── Merge ────────────────────────────────────────────────────────────────
    if (widget.toolType == PdfToolType.mergePdf) {
      extraParams['mergeRotations'] = {for (final e in _mergeRotations.entries) e.key: e.value};
    }

    // ── Split ────────────────────────────────────────────────────────────────
    else if (widget.toolType == PdfToolType.splitPdf) {
      if (_splitMode == _SplitMode.range) {
        final from = int.tryParse(_rangeFromCtrl.text) ?? 1;
        final to = int.tryParse(_rangeToCtrl.text) ?? _totalPages;
        if (from < 1 || to > _totalPages || from > to) {
          _snack('Invalid range. Enter values between 1 and $_totalPages.', Colors.red);
          return;
        }
        final originalName = pathLib.basenameWithoutExtension(selectedFiles.first);
        stem = '${originalName}_$from-$to';
        extraParams['pageRanges'] = List.generate(to - from + 1, (i) => from + i);
        extraParams['splitMode'] = 'range';
      } else {
        if (_selectedPages.isEmpty) {
          _snack('Please select at least one page.', Colors.red);
          return;
        }
        extraParams['pageRanges'] = _selectedPages.toList()..sort();
        extraParams['splitMode'] = 'customPage';
        extraParams['pageRotations'] = Map<int, int>.from(_pageRotations);
      }
    }

    // ── Delete Pages ─────────────────────────────────────────────────────────
    else if (widget.toolType == PdfToolType.deletePages) {
      if (_pagesToRemove.isEmpty) {
        _snack('Please select pages to remove.', Colors.red);
        return;
      }
      if (_pagesToRemove.length == _totalPages) {
        _snack('Cannot remove all pages. Please leave at least one.', Colors.red);
        return;
      }
      extraParams['pagesToDelete'] = _pagesToRemove.toList()..sort();
    }

    // ── Compress ─────────────────────────────────────────────────────────────
    else if (widget.toolType == PdfToolType.compressPdf) {
      final targetMb = double.tryParse(_customSizeCtrl.text.trim()) ?? 0;
      extraParams['compressionLevel'] = _compressLevel;
      extraParams['targetSizeMb'] = targetMb;
    }

    // ── Organize ─────────────────────────────────────────────────────────────
    else if (widget.toolType == PdfToolType.reorderPages) {
      if (_isSingleOrgMode) {
        extraParams['newPageOrder'] = List<int>.from(_organizePageOrder);
        extraParams['multiOrg'] = false;
        extraParams['pageRotations'] = Map<int, int>.from(_pageRotations);
      } else {
        await _processMultiOrganize('$stem.pdf');
        return;
      }
    }

    // ── Protect PDF ──────────────────────────────────────────────────────────
    else if (widget.toolType == PdfToolType.encryptPdf) {
      if (_passwordCtrl.text.isEmpty || _passwordCtrl.text != _confirmPasswordCtrl.text) {
        _snack('Please enter a password and make sure both passwords match.', Colors.red);
        return;
      }
      extraParams['password'] = _passwordCtrl.text;
    }

    // ── Unlock PDF ───────────────────────────────────────────────────────────
    else if (widget.toolType == PdfToolType.unlockPdf) {
      if (_passwordCtrl.text.isEmpty) {
        _snack('Please enter the password to unlock.', Colors.red);
        return;
      }
      extraParams['password'] = _passwordCtrl.text;
    }

    // ── Crop PDF ─────────────────────────────────────────────────────────────
    else if (widget.toolType == PdfToolType.cropPdf) {
      if (_cropRects.isEmpty) {
        _snack('Please crop at least one page first.', Colors.red);
        return;
      }
      
      final Map<int, Rect> finalCropRects = {};
      if (_cropApplyTo == 'all' && _cropRects.isNotEmpty) {
        final firstCropRect = _cropRects.values.first;
        final count = _pageImages.length;
        for (int i = 1; i <= count; i++) {
          finalCropRects[i] = firstCropRect;
        }
      } else {
        finalCropRects.addAll(_cropRects);
      }
      
      // Apply per-page rotations/mirrors from crop screen
      final Map<int, int> cropRotations = {};
      final Map<int, bool> cropMirrorH = {};
      final Map<int, bool> cropMirrorV = {};
      if (_cropApplyTo == 'all' && _cropRects.isNotEmpty) {
        final firstPageNum = _cropRects.keys.first;
        final rot = _cropPageRotations[firstPageNum] ?? 0;
        final mH = _cropMirrorH[firstPageNum] ?? false;
        final mV = _cropMirrorV[firstPageNum] ?? false;
        for (int i = 1; i <= _pageImages.length; i++) {
          cropRotations[i] = rot;
          cropMirrorH[i] = mH;
          cropMirrorV[i] = mV;
        }
      } else {
        cropRotations.addAll(_cropPageRotations);
        cropMirrorH.addAll(_cropMirrorH);
        cropMirrorV.addAll(_cropMirrorV);
      }
      
      extraParams['cropRects'] = finalCropRects;
      extraParams['cropRotations'] = cropRotations;
      extraParams['cropMirrorH'] = cropMirrorH;
      extraParams['cropMirrorV'] = cropMirrorV;
    }

    if (!mounted) return;
    final outputPath = await DownloadLocationService.getOutputPath(context, ref, '$stem.pdf');
    if (outputPath == null) return;

    await _executeTask(outputPath, extraParams);
  }

  Future<void> _executeTask(String outputPath, Map<String, dynamic> extraParams) async {
    ref.read(pdfTaskProvider.notifier).initializeTask(widget.toolType, selectedFiles);
    if (mounted) ProgressDialog.show(context, message: 'Processing your file...');

    final startTime = DateTime.now();
    await ref.read(pdfTaskProvider.notifier).executeTask(
      outputPath: outputPath,
      additionalParams: extraParams,
    );
    final duration = DateTime.now().difference(startTime).inMilliseconds;

    if (mounted) {
      ProgressDialog.hide(context);
      try {
        final state = ref.read(pdfTaskProvider);
        await HistoryService.logConversion(
          fileName: outputPath.split(Platform.pathSeparator).last,
          toolType: widget.toolType.name,
          status: state.status == TaskStatus.success ? 'success' : 'failed',
          outputPath: outputPath,
          durationMs: duration,
        );
        if (state.status == TaskStatus.failure) {
          _snack(state.errorMessage ?? 'An error occurred', Colors.red);
        } else if (state.status == TaskStatus.success) {
          final toolPath = '/home/pdf/${widget.toolType.name}';
          if (mounted) context.go('${RouteConstants.completed}?from=${Uri.encodeComponent(toolPath)}');
        }
      } catch (e) {
        _snack('Converted successfully, but an UI error occurred: $e', Colors.orange);
        final toolPath = '/home/pdf/${widget.toolType.name}';
        if (mounted) context.go('${RouteConstants.completed}?from=${Uri.encodeComponent(toolPath)}');
      }
    }
  }

  Future<void> _processMultiOrganize(String fileName) async {
    final outputPath = await DownloadLocationService.getOutputPath(context, ref, fileName);
    if (outputPath == null) return;

    if (mounted) ProgressDialog.show(context, message: 'Organizing PDF...');
    try {
      ref.read(pdfTaskProvider.notifier).initializeTask(PdfToolType.reorderPages, selectedFiles);
      final fileIndices = _multiOrgPages.map((p) => p.fileIndex).toList();
      final pageNums = _multiOrgPages.map((p) => p.pageNum).toList();
      final rotations = _multiOrgPages.map((p) => p.rotation).toList();

      await ref.read(pdfTaskProvider.notifier).executeTask(
        outputPath: outputPath,
        additionalParams: {
          'multiOrg': true,
          'fileIndices': fileIndices,
          'pageNums': pageNums,
          'multiOrgRotations': rotations,
        },
      );

      if (mounted) {
        ProgressDialog.hide(context);
        final state = ref.read(pdfTaskProvider);
        if (state.status == TaskStatus.failure) {
          _snack(state.errorMessage ?? 'Failed', Colors.red);
        } else {
          final toolPath = '/home/pdf/${widget.toolType.name}';
          context.go('${RouteConstants.completed}?from=${Uri.encodeComponent(toolPath)}');
        }
      }
    } catch (e) {
      if (mounted) {
        ProgressDialog.hide(context);
        _snack('Error: $e', Colors.red);
      }
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 4)),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  Future<String?> _showOcrFormatDialog() => showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Save Output As'),
      content: const Text('How do you want to save the OCR output?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop('txt'), child: const Text('Text File (.txt)')),
        FilledButton(onPressed: () => Navigator.of(ctx).pop('pdf'), child: const Text('Searchable PDF')),
      ],
    ),
  );

  Future<bool?> _showOcrMergeDialog() => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Multiple Files'),
      content: const Text('How do you want to save the OCR output?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Separate Files')),
        FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Merged PDF')),
      ],
    ),
  );

  // ── Full-screen page preview ───────────────────────────────────────────────

  void _showFullScreenPreview(BuildContext ctx, Uint8List imageBytes, [int rotation = 0]) {
    showDialog(
      context: ctx,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Transform.rotate(
                angle: rotation * 3.14159265 / 180,
                child: Image.memory(imageBytes, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 0, right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPdfFullScreenPreview(BuildContext ctx, String filePath) {
    showDialog(
      context: ctx,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: SfPdfViewer.file(
                File(filePath),
                password: _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : null,
              ),
            ),
            Positioned(
              top: 8, right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black54, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (widget.toolType == PdfToolType.scanToPdf) {
      return const ScanToPdfScreen();
    }

    return Scaffold(
      appBar: AnimatedAppBar(title: _title),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _title.toUpperCase(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold, letterSpacing: 1.2,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // ── OCR mode selector (shown BEFORE file upload for OCR tool) ──
            if (widget.toolType == PdfToolType.ocrPdf) ...[
              _buildOcrModeSelector(context),
              const SizedBox(height: 16),
            ],

            FilePickerWidget(
              title: 'Upload your file',
              subtitle: 'Drag and drop or browse to choose files',
              icon: Icons.cloud_upload_outlined,
              allowMultiple: _canAppend,
              allowedExtensions: widget.toolType == PdfToolType.imageToPdf
                  ? ['jpg', 'jpeg', 'png']
                  : ['pdf'],
              onFilesSelected: _onFilesSelected,
            ),

            if (selectedFiles.isNotEmpty) ...[
              SizedBox(height: AppSpacing.xl),

              // ── Output filename field ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fileNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Output File Name',
                          hintText: 'e.g. MyDocument',
                          prefixIcon: Icon(Icons.drive_file_rename_outline),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.withAlpha(50)),
                      ),
                      child: Text(
                        _ocrOutputFormat == 'txt' && widget.toolType == PdfToolType.ocrPdf
                            ? '.txt'
                            : (widget.toolType == PdfToolType.rotatePdf && _isRotateMulti) || (widget.toolType == PdfToolType.addPageNumbers && selectedFiles.length > 1)
                                ? (_saveAsFormat == 'zip' ? '.zip' : '')
                                : '.pdf',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              
              if ((widget.toolType == PdfToolType.rotatePdf && _isRotateMulti) || 
                  (widget.toolType == PdfToolType.addPageNumbers && selectedFiles.length > 1) ||
                  (widget.toolType == PdfToolType.cropPdf && selectedFiles.isNotEmpty)) ...[
                const SizedBox(height: 12),
                Text(widget.toolType == PdfToolType.cropPdf ? 'Apply crop to' : 'Save as', style: Theme.of(context).textTheme.titleSmall),
                Row(
                  children: [
                    Expanded(child: RadioListTile<String>(
                      title: Text(widget.toolType == PdfToolType.cropPdf ? 'Current page' : 'ZIP Archive'),
                      value: widget.toolType == PdfToolType.cropPdf ? 'current' : 'zip',
                      groupValue: widget.toolType == PdfToolType.cropPdf ? _cropApplyTo : _saveAsFormat,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) {
                        setState(() {
                          if (widget.toolType == PdfToolType.cropPdf) _cropApplyTo = v!;
                          else _saveAsFormat = v!;
                        });
                      },
                    )),
                    Expanded(child: RadioListTile<String>(
                      title: Text(widget.toolType == PdfToolType.cropPdf ? 'All pages' : 'Folder'),
                      value: widget.toolType == PdfToolType.cropPdf ? 'all' : 'folder',
                      groupValue: widget.toolType == PdfToolType.cropPdf ? _cropApplyTo : _saveAsFormat,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) {
                        setState(() {
                          if (widget.toolType == PdfToolType.cropPdf) _cropApplyTo = v!;
                          else _saveAsFormat = v!;
                        });
                      },
                    )),
                  ],
                ),
              ],
              
              SizedBox(height: AppSpacing.xl),

              // ── TOOL-SPECIFIC UIs ─────────────────────────────────────────

              if (widget.toolType == PdfToolType.mergePdf)
                _buildMergePdfUI(context),

              if (widget.toolType == PdfToolType.imageToPdf)
                _buildImageToPdfUI(context),

              if (widget.toolType == PdfToolType.splitPdf)
                _buildSplitPdfUI(context),

              if (widget.toolType == PdfToolType.deletePages)
                _buildRemovePagesUI(context),

              if (_isSingleOrgMode)
                _buildOrganizeSingleUI(context),

              if (_isMultiOrgMode)
                _buildOrganizeMultiUI(context),

              if (widget.toolType == PdfToolType.compressPdf)
                _buildCompressPdfUI(context),

              if (widget.toolType == PdfToolType.ocrPdf)
                _buildOcrPdfUI(context),

              if (widget.toolType == PdfToolType.encryptPdf)
                _buildProtectPdfUI(context),

              if (widget.toolType == PdfToolType.unlockPdf)
                _buildUnlockPdfUI(context),

              if (widget.toolType == PdfToolType.cropPdf && selectedFiles.isNotEmpty)
                _buildCropPdfUI(context),

              if (_isRotateSingle)
                _buildRotateSingleUI(context),

              if (_isRotateMulti)
                _buildRotateMultiUI(context),

              if (widget.toolType == PdfToolType.addPageNumbers)
                _buildAddPageNumbersUI(context),
                
              if (widget.toolType == PdfToolType.watermarkPdf)
                _buildWatermarkPdfUI(context),
                
              if (widget.toolType == PdfToolType.pdfToMarkdown)
                _buildPdfToMarkdownUI(context),

              // Default file list for remaining tools
              if (widget.toolType != PdfToolType.mergePdf &&
                  widget.toolType != PdfToolType.imageToPdf &&
                  widget.toolType != PdfToolType.splitPdf &&
                  widget.toolType != PdfToolType.deletePages &&
                  widget.toolType != PdfToolType.reorderPages &&
                  widget.toolType != PdfToolType.ocrPdf &&
                  widget.toolType != PdfToolType.rotatePdf &&
                  widget.toolType != PdfToolType.watermarkPdf &&
                  widget.toolType != PdfToolType.addPageNumbers)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedFiles.length,
                  itemBuilder: (context, index) {
                    final name = selectedFiles[index].split(Platform.pathSeparator).last;
                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file, color: Colors.red),
                      title: Text(name),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => selectedFiles.removeAt(index)),
                      ),
                    );
                  },
                ),

              SizedBox(height: AppSpacing.xxl),
              CustomButton(
                text: widget.toolType == PdfToolType.mergePdf ? 'Merge PDF'
                    : widget.toolType == PdfToolType.splitPdf ? 'Split PDF'
                    : widget.toolType == PdfToolType.deletePages ? 'Remove Pages'
                    : widget.toolType == PdfToolType.reorderPages ? 'Organize PDF'
                    : widget.toolType == PdfToolType.ocrPdf ? 'Apply OCR'
                    : widget.toolType == PdfToolType.rotatePdf ? 'Rotate & Convert'
                    : widget.toolType == PdfToolType.addPageNumbers ? 'Add Page Numbers'
                    : widget.toolType == PdfToolType.watermarkPdf ? 'Apply Watermark'
                    : 'Process Files',
                onPressed: _processFiles,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MERGE PDF UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMergePdfUI(BuildContext context) {
    return Column(
      children: [
        Text('Drag to reorder PDFs — tap to preview',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 12),
        ReorderableGridView.builder(
          dragWidgetBuilder: _dragWidgetBuilder,
          onDragStart: (_) => HapticFeedback.lightImpact(),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
          ),
          itemCount: selectedFiles.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final item = selectedFiles.removeAt(oldIndex);
              selectedFiles.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            final filePath = selectedFiles[index];
            final name = filePath.split(Platform.pathSeparator).last;
            final preview = _pdfPreviews[filePath];
            final rotation = _mergeRotations[filePath] ?? 0;
            return _PdfPreviewCard(
              key: ValueKey(filePath),
              fileName: name,
              previewBytes: preview,
              rotation: rotation,
              onRemove: () => setState(() {
                selectedFiles.removeAt(index);
                _pdfPreviews.remove(filePath);
                _mergeRotations.remove(filePath);
              }),
              onRotate: () => setState(() {
                _mergeRotations[filePath] = ((_mergeRotations[filePath] ?? 0) + 90) % 360;
              }),
              onTap: () => _showPdfFullScreenPreview(context, filePath),
            );
          },
        ),
        SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // IMAGE TO PDF UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildImageToPdfUI(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: Icon(_isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_sharp),
              label: Text(_isAscending ? 'Sort Z-A' : 'Sort A-Z'),
              onPressed: () {
                setState(() {
                  _isAscending = !_isAscending;
                  selectedFiles.sort((a, b) {
                    final na = a.split('/').last.toLowerCase();
                    final nb = b.split('/').last.toLowerCase();
                    return _isAscending ? na.compareTo(nb) : nb.compareTo(na);
                  });
                });
              },
            ),
          ],
        ),
        ReorderableGridView.builder(
          dragWidgetBuilder: _dragWidgetBuilder,
          onDragStart: (_) => HapticFeedback.lightImpact(),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8,
          ),
          itemCount: selectedFiles.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final item = selectedFiles.removeAt(oldIndex);
              selectedFiles.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            final filePath = selectedFiles[index];
            return Card(
              key: ValueKey(filePath),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(filePath), fit: BoxFit.cover),
                  Positioned(
                    top: 0, right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                      onPressed: () => setState(() => selectedFiles.removeAt(index)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: AppSpacing.xxl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Page Orientation', style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: AppSpacing.sm),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'portrait', label: Text('Portrait'), icon: Icon(Icons.crop_portrait)),
                  ButtonSegment(value: 'landscape', label: Text('Landscape'), icon: Icon(Icons.crop_landscape)),
                ],
                selected: <String>{_orientation},
                onSelectionChanged: (s) => setState(() => _orientation = s.first),
              ),
              SizedBox(height: AppSpacing.lg),
              Text('Page Size', style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: AppSpacing.sm),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'fit', label: Text('Fit Page'), icon: Icon(Icons.crop_free)),
                  ButtonSegment(value: 'a4', label: Text('A4'), icon: Icon(Icons.insert_page_break)),
                  ButtonSegment(value: 'us_letter', label: Text('US Letter'), icon: Icon(Icons.description)),
                ],
                selected: <String>{_pageSize},
                onSelectionChanged: (s) => setState(() => _pageSize = s.first),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SPLIT PDF UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSplitPdfUI(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<_SplitMode>(
            segments: const [
              ButtonSegment(value: _SplitMode.range, label: Text('Range'), icon: Icon(Icons.linear_scale)),
              ButtonSegment(value: _SplitMode.customPage, label: Text('Custom Page'), icon: Icon(Icons.grid_view)),
            ],
            selected: {_splitMode},
            onSelectionChanged: (s) => setState(() { _splitMode = s.first; _selectedPages.clear(); }),
          ),
          const SizedBox(height: 20),

          if (_splitMode == _SplitMode.range) ...[
            Text(
              _totalPages > 0 ? 'Page range (1 – $_totalPages)' : 'Page range',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rangeFromCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'From page', border: OutlineInputBorder()),
                    onChanged: (_) => _updateRangeThumbnails(),
                    onSubmitted: (_) => _updateRangeThumbnails(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('–', style: TextStyle(fontSize: 20)),
                ),
                Expanded(
                  child: TextField(
                    controller: _rangeToCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'To page', border: OutlineInputBorder()),
                    onChanged: (_) => _updateRangeThumbnails(),
                    onSubmitted: (_) => _updateRangeThumbnails(),
                  ),
                ),
              ],
            ),
            // ── Range thumbnails — tappable ─────────────────────────────────
            if (_rangeFromThumb != null || _rangeToThumb != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_rangeFromThumb != null)
                    Expanded(
                      child: Column(
                        children: [
                          Text('From: Page ${_rangeFromCtrl.text}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => _showFullScreenPreview(context, _rangeFromThumb!),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(_rangeFromThumb!, height: 100, fit: BoxFit.contain),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('Tap to view', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                  if (_rangeFromThumb != null && _rangeToThumb != null)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward, color: Colors.grey),
                    ),
                  if (_rangeToThumb != null)
                    Expanded(
                      child: Column(
                        children: [
                          Text('To: Page ${_rangeToCtrl.text}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => _showFullScreenPreview(context, _rangeToThumb!),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(_rangeToThumb!, height: 100, fit: BoxFit.contain),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('Tap to view', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],

          if (_splitMode == _SplitMode.customPage) ...[
            Text('Select & rotate pages to extract', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (_selectedPages.isNotEmpty)
              Text('${_selectedPages.length} page(s) selected',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 12),
            _buildPageGrid(
              images: _pageImages,
              selectedPages: _selectedPages,
              isLoading: _loadingPages,
              onTap: (pageNum) => setState(() {
                if (_selectedPages.contains(pageNum)) {
                  _selectedPages.remove(pageNum);
                } else {
                  _selectedPages.add(pageNum);
                }
              }),
              showXOnSelected: false,
              pageRotations: _pageRotations,
              onRotate: (pageNum) => setState(() {
                _pageRotations[pageNum] = ((_pageRotations[pageNum] ?? 0) + 90) % 360;
              }),
            ),
          ],
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REMOVE PAGES UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRemovePagesUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tap pages to mark them for removal.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Total pages: $_totalPages',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 16),
        _buildPageGrid(
          images: _pageImages,
          selectedPages: _pagesToRemove,
          isLoading: _loadingPages,
          onTap: _toggleRemovePage,
          showXOnSelected: true,
        ),
        const SizedBox(height: 16),
        Text('Pages to remove:', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _removePageCtrl,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'e.g. 4, 6, 8-10',
            border: const OutlineInputBorder(),
            suffixIcon: _removePageCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () { _removePageCtrl.clear(); setState(() => _pagesToRemove.clear()); },
                  )
                : null,
          ),
          onChanged: _onRemoveTextChanged,
        ),
        if (_pagesToRemove.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('${_pagesToRemove.length} page(s) will be removed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red[700])),
        ],
        SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ORGANIZE PDF — SINGLE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildOrganizeSingleUI(BuildContext context) {
    if (_loadingPages) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Drag pages to reorder — tap to preview',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 12),
        ReorderableGridView.builder(
          dragWidgetBuilder: _dragWidgetBuilder,
          onDragStart: (_) => HapticFeedback.lightImpact(),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
          ),
          itemCount: _organizePageOrder.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final item = _organizePageOrder.removeAt(oldIndex);
              _organizePageOrder.insert(newIndex, item);
              final imgItem = _pageImages.removeAt(oldIndex);
              _pageImages.insert(newIndex, imgItem);
            });
          },
          itemBuilder: (context, index) {
            final pageNum = _organizePageOrder[index];
            final imgBytes = _pageImages[index];
            final rotation = _pageRotations[pageNum] ?? 0;
            return _OrgPageCard(
              key: ValueKey('org_single_${pageNum}_$index'),
              imageBytes: imgBytes,
              label: '$pageNum',
              borderColor: Theme.of(context).colorScheme.primary,
              rotation: rotation,
              onRotate: () => setState(() {
                _pageRotations[pageNum] = ((_pageRotations[pageNum] ?? 0) + 90) % 360;
              }),
              onTap: () => _showFullScreenPreview(context, imgBytes, rotation),
            );
          },
        ),
        SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ORGANIZE PDF — MULTI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildOrganizeMultiUI(BuildContext context) {
    if (_loadingPages) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Files:', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  ...List.generate(selectedFiles.length, (i) {
                    final letter = String.fromCharCode(65 + i);
                    final name = selectedFiles[i].split(Platform.pathSeparator).last;
                    final color = _pdfColors[i % _pdfColors.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 14, height: 14,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              border: Border.all(color: color, width: 2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$letter: $name',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: color, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => _loadOrganizeMultiPdf(selectedFiles),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Drag pages to reorder — tap to preview',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 12),
        ReorderableGridView.builder(
          dragWidgetBuilder: _dragWidgetBuilder,
          onDragStart: (_) => HapticFeedback.lightImpact(),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
          ),
          itemCount: _multiOrgPages.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final item = _multiOrgPages.removeAt(oldIndex);
              _multiOrgPages.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            final page = _multiOrgPages[index];
            final letter = String.fromCharCode(65 + page.fileIndex);
            final color = _pdfColors[page.fileIndex % _pdfColors.length];
            return _OrgPageCard(
              key: ValueKey('org_multi_${page.fileIndex}_${page.pageNum}_$index'),
              imageBytes: page.thumbnail,
              label: '$letter${page.pageNum}',
              borderColor: color,
              rotation: page.rotation,
              onRotate: () => setState(() { page.rotation = (page.rotation + 90) % 360; }),
              onTap: page.thumbnail != null
                  ? () => _showFullScreenPreview(context, page.thumbnail!, page.rotation)
                  : null,
            );
          },
        ),
        SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPRESS PDF UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCompressPdfUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compression Level',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildCompressOption(level: 0, title: 'Extreme Compression', subtitle: 'Less quality, maximum compression', icon: Icons.compress),
        const SizedBox(height: 8),
        _buildCompressOption(level: 1, title: 'Recommended Compression', subtitle: 'Good quality, good compression', icon: Icons.thumb_up_alt_outlined),
        const SizedBox(height: 8),
        _buildCompressOption(level: 2, title: 'Less Compression', subtitle: 'High quality, less compression', icon: Icons.hd_outlined),
        const SizedBox(height: 24),
        Text('Custom Target Size (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _customSizeCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Target Size (MB)',
            hintText: 'e.g. 2.5',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.sd_storage_outlined),
          ),
        ),
        SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildCompressOption({required int level, required String title, required String subtitle, required IconData icon}) {
    final isSelected = _compressLevel == level;
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6);
    return InkWell(
      onTap: () => setState(() => _compressLevel = level),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.2) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? theme.colorScheme.primary : null,
                  )),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OCR PDF UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildOcrModeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('OCR Method', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'online',
              label: Text('Online'),
              icon: Icon(Icons.cloud_outlined),
            ),
            ButtonSegment(
              value: 'offline',
              label: Text('Offline'),
              icon: Icon(Icons.phone_android),
            ),
          ],
          selected: {_ocrMode},
          onSelectionChanged: (s) => setState(() => _ocrMode = s.first),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _ocrMode == 'online' ? Colors.blue.withOpacity(0.08) : Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _ocrMode == 'online' ? Colors.blue.withOpacity(0.3) : Colors.green.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _ocrMode == 'online' ? Icons.cloud_outlined : Icons.phone_android,
                size: 18,
                color: _ocrMode == 'online' ? Colors.blue[700] : Colors.green[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _ocrMode == 'online'
                      ? 'Uses Google Cloud Vision API for highest accuracy. Requires internet connection.'
                      : 'Uses on-device Google ML Kit. Works offline. No data leaves your device.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _ocrMode == 'online' ? Colors.blue[800] : Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOcrPdfUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selected Files (${selectedFiles.length})',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[700])),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75,
          ),
          itemCount: selectedFiles.length,
          itemBuilder: (context, index) {
            final filePath = selectedFiles[index];
            final preview = _ocrPreviews[filePath];
            final name = filePath.split(Platform.pathSeparator).last;
            final rotation = _ocrRotations[filePath] ?? 0;
            return _PdfPreviewCard(
              fileName: name,
              previewBytes: preview,
              rotation: rotation,
              onRemove: () {
                setState(() {
                  selectedFiles.remove(filePath);
                  _ocrPreviews.remove(filePath);
                  _ocrRotations.remove(filePath);
                  if (selectedFiles.isEmpty) {
                    _fileNameCtrl.clear();
                  } else {
                    _fileNameCtrl.text = _defaultFileNameStem(selectedFiles);
                  }
                });
              },
              onRotate: () => setState(() {
                _ocrRotations[filePath] = (rotation + 90) % 360;
              }),
            );
          },
        ),
        SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ROTATE PDF UI — SINGLE PDF
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRotateSingleUI(BuildContext context) {
    if (_loadingRotatePages) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }
    if (_rotateSinglePageImages.isEmpty) return const SizedBox.shrink();

    // Compute "current" global angle for Rotate All cycling
    final allAngles = List.generate(_rotateSinglePageImages.length, (i) => _rotateSinglePageAngles[i + 1] ?? 0);
    final firstAngle = allAngles.isEmpty ? 0 : allAngles.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top bar: info + Rotate All
        Row(
          children: [
            Expanded(
              child: Text(
                '${_rotateSinglePageImages.length} pages — tap 🔄 to rotate, tap page to fullscreen',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.rotate_right, size: 16),
              label: const Text('Rotate All'),
              onPressed: () {
                setState(() {
                  final nextAngle = (firstAngle + 90) % 360;
                  for (int i = 1; i <= _rotateSinglePageImages.length; i++) {
                    _rotateSinglePageAngles[i] = nextAngle;
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
          ),
          itemCount: _rotateSinglePageImages.length,
          itemBuilder: (context, index) {
            final pageNum = index + 1;
            final imgBytes = _rotateSinglePageImages[index];
            final angle = _rotateSinglePageAngles[pageNum] ?? 0;
            return GestureDetector(
              onTap: () => _showFullScreenPreview(context, imgBytes, angle),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.rotate(
                        angle: angle * 3.14159265 / 180,
                        child: Image.memory(imgBytes, fit: BoxFit.cover),
                      ),
                      // Per-page rotate icon
                      Positioned(
                        top: 2, right: 2,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _rotateSinglePageAngles[pageNum] = (angle + 90) % 360;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(3),
                            child: const Icon(Icons.rotate_right, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                      // Angle badge
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            'Page $pageNum  •  ${angle}°',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ROTATE PDF UI — MULTIPLE PDFs
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRotateMultiUI(BuildContext context) {
    final firstAngle = _rotateFileAngles.isNotEmpty ? _rotateFileAngles.values.first : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${selectedFiles.length} PDFs — tap 🔄 to rotate, tap thumbnail to preview',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.rotate_right, size: 16),
              label: const Text('Rotate All'),
              onPressed: () {
                setState(() {
                  final nextAngle = (firstAngle + 90) % 360;
                  for (final path in selectedFiles) {
                    _rotateFileAngles[path] = nextAngle;
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
          ),
          itemCount: selectedFiles.length,
          itemBuilder: (context, index) {
            final filePath = selectedFiles[index];
            final name = filePath.split(Platform.pathSeparator).last;
            final preview = _rotatePreviews[filePath];
            final angle = _rotateFileAngles[filePath] ?? 0;
            return _PdfPreviewCard(
              key: ValueKey(filePath),
              fileName: name,
              previewBytes: preview,
              rotation: angle,
              onRemove: () => setState(() {
                selectedFiles.removeAt(index);
                _rotatePreviews.remove(filePath);
                _rotateFileAngles.remove(filePath);
                _fileNameCtrl.text = _defaultFileNameStem(selectedFiles);
              }),
              onRotate: () => setState(() {
                _rotateFileAngles[filePath] = (angle + 90) % 360;
              }),
              onTap: () => _showPdfFullScreenPreview(context, filePath),
            );
          },
        ),
        SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADD PAGE NUMBERS UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAddPageNumbersUI(BuildContext context) {
    return AddPageNumbersOptionsWidget(
      initialOptions: _pageNumberOptions,
      selectedFiles: selectedFiles,
      pageImages: _pageImages,
      totalPages: _totalPages,
      onChanged: (opts) => setState(() => _pageNumberOptions = opts),
      onRemoveFile: (filePath) => setState(() {
        selectedFiles.remove(filePath);
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WATERMARK PDF UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildWatermarkPdfUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (selectedFiles.isNotEmpty) ...[
          _buildWatermarkPreview(context),
          const SizedBox(height: 24),
        ],
        WatermarkPdfOptionsWidget(
          initialOptions: _watermarkOptions,
          onOptionsChanged: (opts) => setState(() => _watermarkOptions = opts),
        ),
      ],
    );
  }
  
  // PDF TO MARKDOWN UI
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPdfToMarkdownUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          title: const Text('Generate AI Summary'),
          subtitle: const Text('Uses Google Gemini AI to append a summary of the extracted text.'),
          value: _pdfToMarkdownGenerateSummary,
          onChanged: (val) => setState(() => _pdfToMarkdownGenerateSummary = val),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildWatermarkPreview(BuildContext context) {
    final fileName = selectedFiles.first.split(Platform.pathSeparator).last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selected File Preview', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[700])),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showPdfFullScreenPreview(context, selectedFiles.first),
                child: Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      if (_pnPreviews[selectedFiles.first] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _pnPreviews[selectedFiles.first]!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      else
                        const Center(child: Icon(Icons.picture_as_pdf, size: 40, color: Colors.red)),
                      
                      // Watermark Overlay preview
                      Positioned.fill(
                        child: Opacity(
                          opacity: _watermarkOptions.transparency,
                          child: Center(
                            child: Transform.rotate(
                              angle: _watermarkOptions.rotation * 3.14159 / 180,
                              child: _watermarkOptions.isText
                                ? Text(
                                    _watermarkOptions.text,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : (_watermarkOptions.imageBytes != null 
                                    ? Image.memory(_watermarkOptions.imageBytes!, width: 40, height: 40)
                                    : const SizedBox()),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  fileName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    selectedFiles.removeAt(0);
                    _pnPreviews.remove(selectedFiles.first);
                  });
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Color _getPasswordStrengthColor(String password) {
    if (password.isEmpty) return Colors.grey;
    if (password.length < 6) return Colors.red; // Weak
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    bool hasSymbol = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    if (password.length >= 8 && hasNumber && hasSymbol) return Colors.green; // Strong
    return Colors.amber; // Normal
  }

  Widget _dragWidgetBuilder(int index, Widget child) {
    return Transform.scale(
      scale: 0.9,
      child: Opacity(opacity: 0.6, child: Material(color: Colors.transparent, child: child)),
    );
  }

  Widget _buildPageGrid({
    required List<Uint8List> images,
    required Set<int> selectedPages,
    required bool isLoading,
    required void Function(int) onTap,
    required bool showXOnSelected,
    Map<int, int>? pageRotations,
    void Function(int)? onRotate,
  }) {
    if (isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }
    if (images.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final pageNum = index + 1;
        final isSelected = selectedPages.contains(pageNum);
        final rotation = pageRotations?[pageNum] ?? 0;
        return GestureDetector(
          onTap: () => onTap(pageNum),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? (showXOnSelected ? Colors.red : Theme.of(context).colorScheme.primary)
                    : Colors.grey.shade300,
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Transform.rotate(
                    angle: rotation * 3.14159265 / 180,
                    child: Image.memory(images[index], fit: BoxFit.cover),
                  ),
                  if (isSelected && showXOnSelected)
                    Container(
                      color: Colors.red.withValues(alpha: 0.15),
                      child: const Center(child: Icon(Icons.close, color: Colors.red, size: 36)),
                    ),
                  if (isSelected && !showXOnSelected)
                    Container(
                      color: Colors.blue.withValues(alpha: 0.20),
                      child: const Align(
                        alignment: Alignment.topRight,
                        child: Padding(padding: EdgeInsets.all(4),
                            child: Icon(Icons.check_circle, color: Colors.blue, size: 20)),
                      ),
                    ),
                  if (onRotate != null)
                    Positioned(
                      top: 2, right: 2,
                      child: GestureDetector(
                        onTap: () => onRotate(pageNum),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(3),
                          child: const Icon(Icons.rotate_right, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 2, left: 2,
                    child: GestureDetector(
                      onTap: () => _showFullScreenPreview(context, images[index], rotation),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(3),
                        child: const Icon(Icons.fullscreen, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      color: isSelected
                          ? (showXOnSelected ? Colors.red.withValues(alpha: 0.8) : Colors.blue.withValues(alpha: 0.8))
                          : Colors.black54,
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        isSelected && showXOnSelected ? 'Page $pageNum ✕' : 'Page $pageNum',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// ═══════════════════════════════════════════════════════════════════════════════
  // UNLOCK PDF UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildUnlockPdfUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_encryptPreview != null && selectedFiles.isNotEmpty) ...[
          _buildEncryptFilePreview(context),
          const SizedBox(height: 24),
        ],
        Text(
          'Enter Password to Unlock',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          onChanged: (val) async {
            if (val.isNotEmpty) {
              if (selectedFiles.isNotEmpty) {
                final thumb = await _loadPageThumb(selectedFiles.first, 1, password: val);
                if (mounted) setState(() => _encryptPreview = thumb);
              }
            } else {
              if (mounted) setState(() => _encryptPreview = null);
            }
          },
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROTECT PDF UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProtectPdfUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_encryptPreview != null && selectedFiles.isNotEmpty) ...[
          _buildEncryptFilePreview(context),
          const SizedBox(height: 24),
        ],
        Text(
          'Set a Password',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Password',
            helperText: 'Suggestion: Use at least 8 chars with symbols/numbers for strong security.',
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordCtrl,
          obscureText: _obscurePassword,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_clock),
            border: const OutlineInputBorder(),
            errorText: _confirmPasswordCtrl.text.isNotEmpty && _confirmPasswordCtrl.text != _passwordCtrl.text
                ? 'Passwords do not match'
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildEncryptFilePreview(BuildContext context) {
    final fileName = selectedFiles.first.split(Platform.pathSeparator).last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selected File', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[700])),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showPdfFullScreenPreview(context, selectedFiles.first),
                child: Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.memory(_encryptPreview!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap thumbnail to preview',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    selectedFiles.clear();
                    _encryptPreview = null;
                    _fileNameCtrl.clear();
                  });
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPwdRule(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check : Icons.close,
            color: isValid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CROP PDF UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCropPreview(Uint8List imgBytes, Rect? cropRect) {
    if (cropRect == null) {
      return Image.memory(imgBytes, fit: BoxFit.contain);
    }
    double alignX = cropRect.width >= 1.0 ? 0.0 : (cropRect.left / (1 - cropRect.width)) * 2 - 1;
    double alignY = cropRect.height >= 1.0 ? 0.0 : (cropRect.top / (1 - cropRect.height)) * 2 - 1;

    return FittedBox(
      fit: BoxFit.fill,
      child: ClipRect(
        child: Align(
          alignment: Alignment(alignX, alignY),
          widthFactor: cropRect.width,
          heightFactor: cropRect.height,
          child: Image.memory(imgBytes),
        ),
      ),
    );
  }

  Widget _buildCropPdfUI(BuildContext context) {
    if (_loadingRotatePages) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }
    if (_rotateSinglePageImages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tap a page to crop',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rotateSinglePageImages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final pageNum = index + 1;
            final imgBytes = _rotateSinglePageImages[index];
            final hasCrop = _cropRects.containsKey(pageNum);

            return GestureDetector(
              onTap: () => _showCropScreen(context, pageNum, imgBytes),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: hasCrop ? Theme.of(context).colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
                        width: hasCrop ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildCropPreview(imgBytes, _cropRects[pageNum]),
                  ),
                  if (hasCrop)
                    Positioned(
                      top: 4, right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(Icons.crop, color: Colors.white, size: 16),
                      ),
                    ),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Page $pageNum',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  void _showCropScreen(BuildContext ctx, int pageNum, Uint8List originalBytes) {
    int rot = _cropPageRotations[pageNum] ?? 0;
    bool mH = _cropMirrorH[pageNum] ?? false;
    bool mV = _cropMirrorV[pageNum] ?? false;
    
    Uint8List currentBytes = originalBytes;
    bool isProcessing = false;

    // Helper to apply rotate/mirror to image bytes
    Future<void> updateImage(void Function(void Function()) setDialogState) async {
      setDialogState(() => isProcessing = true);
      
      final result = await Future.microtask(() {
        if (rot == 0 && !mH && !mV) return originalBytes;
        img.Image? decoded = img.decodeImage(originalBytes);
        if (decoded == null) return originalBytes;
        if (rot != 0) decoded = img.copyRotate(decoded, angle: rot);
        if (mH) decoded = img.flipHorizontal(decoded);
        if (mV) decoded = img.flipVertical(decoded);
        return Uint8List.fromList(img.encodeJpg(decoded, quality: 90));
      });
      
      setDialogState(() {
        currentBytes = result;
        isProcessing = false;
      });
    }

    final controller = CropController(
      aspectRatio: null,
      defaultCrop: _cropRects[pageNum] ?? const Rect.fromLTWH(0, 0, 1, 1),
    );

    showDialog(
      context: ctx,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            // Initially load the transformed image if needed
            if (currentBytes == originalBytes && (rot != 0 || mH || mV)) {
              updateImage(setDialogState);
            }

            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: isProcessing
                        ? const Center(child: CircularProgressIndicator())
                        : CropImage(
                            key: ValueKey(currentBytes.hashCode),
                            controller: controller,
                            image: Image.memory(currentBytes),
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          tooltip: 'Rotate 90°',
                          icon: const Icon(Icons.rotate_right),
                          onPressed: () {
                            rot = (rot + 90) % 360;
                            updateImage(setDialogState);
                          },
                        ),
                        IconButton(
                          tooltip: 'Mirror Horizontal',
                          icon: const Icon(Icons.flip),
                          onPressed: () {
                            mH = !mH;
                            updateImage(setDialogState);
                          },
                        ),
                        IconButton(
                          tooltip: 'Mirror Vertical',
                          icon: const RotatedBox(quarterTurns: 1, child: Icon(Icons.flip)),
                          onPressed: () {
                            mV = !mV;
                            updateImage(setDialogState);
                          },
                        ),
                        Container(width: 1, height: 24, color: Colors.grey),
                        TextButton(
                          onPressed: () => controller.aspectRatio = null,
                          child: const Text('Free'),
                        ),
                        TextButton(
                          onPressed: () => controller.aspectRatio = 1,
                          child: const Text('1:1'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _cropRects[pageNum] = controller.crop;
                              _cropPageRotations[pageNum] = rot;
                              _cropMirrorH[pageNum] = mH;
                              _cropMirrorV[pageNum] = mV;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Apply Crop'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _PdfPreviewCard
// ═══════════════════════════════════════════════════════════════════════════════

class _PdfPreviewCard extends StatelessWidget {
  final String fileName;
  final Uint8List? previewBytes;
  final VoidCallback onRemove;
  final VoidCallback? onRotate;
  final VoidCallback? onTap;
  final int rotation;

  const _PdfPreviewCard({
    super.key,
    required this.fileName,
    required this.previewBytes,
    required this.onRemove,
    this.onRotate,
    this.onTap,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Transform.rotate(
                    angle: rotation * 3.14159265 / 180,
                    child: previewBytes != null
                        ? Image.memory(previewBytes!, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                          ),
                  ),
                  // Rotate — top-left
                  if (onRotate != null)
                    Positioned(
                      top: 4, left: 4,
                      child: GestureDetector(
                        onTap: onRotate,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(3),
                          child: const Icon(Icons.rotate_right, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  // Remove — top-right
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                  // Fullscreen hint
                  if (onTap != null)
                    const Positioned(
                      bottom: 20, left: 0, right: 0,
                      child: Center(
                        child: Icon(Icons.open_in_full, color: Colors.white54, size: 18),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  // ═══════════════════════════════════════════════════════════════════════════
  }
}

// _OrgPageCard
// ═══════════════════════════════════════════════════════════════════════════════

class _OrgPageCard extends StatelessWidget {
  final Uint8List? imageBytes;
  final String label;
  final Color borderColor;
  final int rotation;
  final VoidCallback? onRotate;
  final VoidCallback? onTap;

  const _OrgPageCard({
    super.key,
    required this.imageBytes,
    required this.label,
    required this.borderColor,
    this.rotation = 0,
    this.onRotate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.rotate(
                angle: rotation * 3.14159265 / 180,
                child: imageBytes != null
                    ? Image.memory(imageBytes!, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.picture_as_pdf, size: 32, color: Colors.grey),
                      ),
              ),
              if (onRotate != null)
                Positioned(
                  top: 4, right: 4,
                  child: GestureDetector(
                    onTap: onRotate,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(3),
                      child: const Icon(Icons.rotate_right, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  color: borderColor.withValues(alpha: 0.85),
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// ═══════════════════════════════════════════════════════════════════════════════
// _OrgPage data class
// ═══════════════════════════════════════════════════════════════════════════════

class _OrgPage {
  final int fileIndex;
  final int pageNum;
  final Uint8List? thumbnail;
  int rotation;

  // ignore: unused_element_parameter
  _OrgPage({required this.fileIndex, required this.pageNum, required this.thumbnail, this.rotation = 0});
}