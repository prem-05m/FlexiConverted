import 'dart:ui';
import 'dart:typed_data';
import '../models/pdf_task_model.dart';

abstract class PdfEngine {
  /// Converts a list of image paths to a single PDF
  Future<PdfResult> imagesToPdf({
    required List<String> imagePaths,
    required String outputPath,
    String pageSize = 'fit',
    String orientation = 'portrait',
    void Function(double)? onProgress,
  });

  /// Extracts pages from a PDF as images
  Future<List<String>> pdfToImages({
    required String pdfPath,
    required String outputDir,
    void Function(double)? onProgress,
  });

  /// Merges multiple PDFs into one
  Future<PdfResult> mergePdfs({
    required List<String> pdfPaths,
    required String outputPath,
    Map<String, int>? mergeRotations,
    void Function(double)? onProgress,
  });

  /// Splits a PDF into multiple PDFs (e.g. one per page, or by range)
  Future<List<String>> splitPdf({
    required String pdfPath,
    required String outputDir,
    List<int>? pageRanges,
    void Function(double)? onProgress,
  });

  /// Compresses a PDF to reduce file size
  Future<PdfResult> compressPdf({
    required String pdfPath,
    required String outputPath,
    /// 0=extreme, 1=recommended, 2=less
    int compressionLevel = 1,
    /// Optional max target size in MB (0 = ignore)
    double targetSizeMb = 0,
    void Function(double)? onProgress,
  });

  /// Rotates specific pages in a PDF (per-page angles via [pageAngles])
  Future<PdfResult> rotatePages({
    required String pdfPath,
    required String outputPath,
    required int angle,
    List<int>? pagesToRotate,
    /// Per-page angle map (page 1-indexed → angle 0/90/180/270).
    /// When supplied, [angle] is ignored.
    Map<int, int>? pageAngles,
  });

  /// Reorders pages within a PDF
  Future<PdfResult> reorderPages({
    required String pdfPath,
    required String outputPath,
    required List<int> newPageOrder, // 1-indexed
    bool multiOrg = false,
    List<String>? multiOrgFiles,
    List<int>? multiOrgFileIndices,
    List<int>? multiOrgPageNums,
    Map<int, int>? pageRotations,
    List<int>? multiOrgRotations,
  });

  /// Removes pages from a PDF
  Future<PdfResult> deletePages({
    required String pdfPath,
    required String outputPath,
    required List<int> pagesToDelete,
  });

  /// Extracts specific pages from a PDF into a new PDF
  Future<PdfResult> extractPages({
    required String pdfPath,
    required String outputPath,
    required List<int> pagesToExtract,
    Map<int, int>? pageRotations,
  });

  /// Adds a text or image watermark to a PDF
  Future<PdfResult> watermarkPdf({
    required String pdfPath,
    required String outputPath,
    required WatermarkOptions options,
  });

  /// Encrypts a PDF with a password
  Future<PdfResult> encryptPdf({
    required String pdfPath,
    required String outputPath,
    required String password,
  });

  /// Unlocks an encrypted PDF
  Future<PdfResult> unlockPdf({
    required String pdfPath,
    required String outputPath,
    required String password,
  });

  /// Adds multiple signature images at specific positions on pages
  Future<PdfResult> addSignatures({
    required String pdfPath,
    required String outputPath,
    required List<Map<String, dynamic>> signatures,
  });

  /// Redacts content from a PDF (Blur, Paint, Clear)
  Future<PdfResult> redactPdf({
    required String pdfPath,
    required String outputPath,
    required List<Map<String, dynamic>> redactions,
  });

  /// Converts PDF text to Markdown and optionally generates AI Summary
  Future<PdfResult> pdfToMarkdown({
    required String pdfPath,
    required String outputPath,
    required bool generateSummary,
    void Function(double)? onProgress,
  });

  /// Extracts text from a PDF (OCR from existing text layer)
  Future<PdfResult> ocrExtractText({
    required List<String> pdfPaths,
    required String outputPath,
    /// If true, merge all files into one output PDF
    bool mergeOutput = true,
    /// Per-file rotation angles applied before extraction
    Map<String, int>? fileRotations,
    /// 'online' | 'offline'
    String ocrMode = 'online',
    /// 'pdf' | 'txt'
    String outputFormat = 'pdf',
  });

  /// Adds page numbers to each page of a PDF.
  Future<PdfResult> addPageNumbers({
    required String pdfPath,
    required String outputPath,
    required PageNumberOptions options,
  });

  /// Crops a PDF. cropRects contains normalized Rects (0.0 to 1.0) for each page (1-indexed).
  Future<PdfResult> cropPdf({
    required String pdfPath,
    required String outputPath,
    required Map<int, Rect> cropRects,
    Map<int, int>? cropRotations,
    Map<int, bool>? cropMirrorH,
    Map<int, bool>? cropMirrorV,
  });

  /// Edits a PDF by overlaying text, images, and drawings
  Future<PdfResult> editPdf({
    required String pdfPath,
    required String outputPath,
    required List<PdfLayerData> layers,
    void Function(double)? onProgress,
  });
}

// ── PageNumberOptions ────────────────────────────────────────────────────────
class PageNumberOptions {
  /// 'single' | 'facing'
  final String pageMode;

  /// For facing mode: 'portrait' | 'landscape'
  final String facingOrientation;

  /// Whether the first page is a standalone cover in facing mode
  final bool firstPageIsCover;

  /// Position 1–6: TL, TC, TR, BL, BC, BR
  final int position;

  /// 'big' | 'normal' | 'small'
  final String margin;

  /// The number to show on the first numbered page
  final int firstNumber;

  /// 1-based first page to number (inclusive)
  final int fromPage;

  /// 1-based last page to number (inclusive); 0 = all pages
  final int toPage;

  /// 'option1'=n, 'option2'=Page n, 'option3'=Page n of p, 'option4'=custom
  final String textFormat;

  /// Used when textFormat == 'option4'
  final String customFormat;

  final String fontFamily;
  final double fontSize;
  final bool bold;
  final bool italic;
  final bool underline;

  /// Hex color string, e.g. '#000000'
  final String colorHex;

  const PageNumberOptions({
    this.pageMode = 'single',
    this.facingOrientation = 'portrait',
    this.firstPageIsCover = false,
    this.position = 5,
    this.margin = 'normal',
    this.firstNumber = 1,
    this.fromPage = 1,
    this.toPage = 0,
    this.textFormat = 'option1',
    this.customFormat = 'Page {n}',
    this.fontFamily = 'Arial',
    this.fontSize = 14,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.colorHex = '#000000',
  });
}

class WatermarkOptions {
  final bool isText;
  final String text;
  final Uint8List? imageBytes;
  final int position; // 1-9 (1=TL, 2=TC, 3=TR, 4=CL, 5=C, 6=CR, 7=BL, 8=BC, 9=BR)
  final double transparency; // 0.0 to 1.0
  final bool isOver; // true = over, false = under
  final int rotation; // 0, 45, 90, etc.

  const WatermarkOptions({
    this.isText = true,
    this.text = 'Watermark',
    this.imageBytes,
    this.position = 5,
    this.transparency = 0.5,
    this.isOver = true,
    this.rotation = 45,
  });
}

class PdfLayerData {
  final int pageNumber;
  final String type; // 'text', 'image', 'draw'
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;

  // text specific
  final String? text;
  final double? fontSize;
  final String? colorHex;
  final String? fontFamily;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;

  // image specific
  final List<int>? imageBytes;
  
  // draw specific
  final List<List<double>>? paths;

  // shape specific
  final String? shapeType; // 'rectangle', 'circle', 'line'
  final String? backgroundColorHex;
  final String? outlineColorHex;
  final double? strokeWidth;

  PdfLayerData({
    required this.pageNumber,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0,
    this.text,
    this.fontSize,
    this.colorHex,
    this.fontFamily,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.imageBytes,
    this.paths,
    this.shapeType,
    this.backgroundColorHex,
    this.outlineColorHex,
    this.strokeWidth,
  });
}

