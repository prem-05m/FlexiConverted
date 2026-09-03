import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pw_core;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';

// ── API Keys ──────────────────────────────────────────────────────────────────
// NOTE: Move these to environment variables / secure storage before releasing
// to production. Never commit real API keys to a public repository.
const _kGoogleVisionKey = 'AIzaSyB-CpYmjLAk5GO6fHfeUZJ-4AXcgS2AqZQ';
const _kOcrSpaceKey = 'K81385833888957';

// ── Data model ────────────────────────────────────────────────────────────────
class OcrWord {
  /// The recognised text.
  final String text;

  /// All values are relative (0.0 – 1.0) to the source image dimensions.
  final double left;
  final double top;
  final double width;
  final double height;

  const OcrWord({
    required this.text,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

// ── OcrService ────────────────────────────────────────────────────────────────
class OcrService {
  final Dio _dio = Dio();

  // ── Public entry points ───────────────────────────────────────────────────

  /// Renders every page of [pdfPaths] to a high-res image, runs OCR, and
  /// returns a list of (pageImage, pageSize, words) tuples.
  Future<List<_OcrPageData>> extractPages({
    required List<String> pdfPaths,
    required String mode, // 'online' | 'offline'
    void Function(double)? onProgress,
  }) async {
    final pages = <_OcrPageData>[];

    for (final pdfPath in pdfPaths) {
      final doc = await PdfDocument.openFile(pdfPath);
      final count = doc.pagesCount;
      for (int i = 1; i <= count; i++) {
        final pg = await doc.getPage(i);
        final pdfW = pg.width;
        final pdfH = pg.height;
        final renderScale = 2.5; // ~180 DPI equivalent
        final img = await pg.render(
          width: pdfW * renderScale,
          height: pdfH * renderScale,
          format: PdfPageImageFormat.jpeg,
          quality: 95,
        );
        await pg.close();
        final imageBytes = img?.bytes ?? Uint8List(0);
        final imageW = (pdfW * renderScale).round();
        final imageH = (pdfH * renderScale).round();

        List<OcrWord> words;
        try {
          words = mode == 'online'
              ? await _ocrOnline(imageBytes, imageW, imageH)
              : await _ocrOffline(imageBytes, imageW: imageW, imageH: imageH);
        } catch (_) {
          words = [];
        }

        pages.add(_OcrPageData(
          imageBytes: imageBytes,
          pdfSize: ui.Size(pdfW, pdfH),
          imageW: imageW,
          imageH: imageH,
          words: words,
        ));

        if (onProgress != null) {
          onProgress(pages.length / (count * pdfPaths.length));
        }
      }
      await doc.close();
    }

    return pages;
  }

  /// Builds a **searchable PDF** where each page contains the original scanned
  /// image as background with an invisible (alpha = 0) text layer on top so
  /// text can be selected and copied in any PDF viewer.
  Future<Uint8List> buildSearchablePdf(List<_OcrPageData> pages) async {
    final document = pw.Document();
    final font = pw.Font.helvetica();

    for (final page in pages) {
      final bgImage = pw.MemoryImage(page.imageBytes);
      final pdfW = page.pdfSize.width;
      final pdfH = page.pdfSize.height;

      document.addPage(
        pw.Page(
          pageFormat: pw_core.PdfPageFormat(pdfW, pdfH, marginAll: 0),
          build: (ctx) {
            return pw.Stack(
              children: [
                // ① Original scanned image — fills the entire page
                pw.Positioned.fill(
                  child: pw.Image(bgImage, fit: pw.BoxFit.fill),
                ),
                // ② Invisible text layer — each word at its exact position
                ...page.words.map((w) {
                  final x = w.left * pdfW;
                  final y = w.top * pdfH;
                  final fs = (w.height * pdfH).clamp(5.0, 72.0);
                  return pw.Positioned(
                    left: x,
                    top: y,
                    child: pw.Text(
                      w.text,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: fs,
                        // Fully transparent and invisible rendering mode
                        color: const pw_core.PdfColor(0, 0, 0, 0),
                        renderingMode: pw_core.PdfTextRenderingMode.invisible,
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      );
    }

    return document.save();
  }

  /// Extracts all recognised text from [pages] and joins it into a plain
  /// string suitable for writing to a .txt file.
  String buildTxt(List<_OcrPageData> pages) {
    final buf = StringBuffer();
    for (int i = 0; i < pages.length; i++) {
      if (pages.length > 1) buf.writeln('--- Page ${i + 1} ---');
      buf.writeln(pages[i].words.map((w) => w.text).join(' '));
      buf.writeln();
    }
    return buf.toString();
  }

  // ── Online OCR ────────────────────────────────────────────────────────────

  Future<List<OcrWord>> _ocrOnline(
      Uint8List imageBytes, int imageW, int imageH) async {
    // Primary: Google Cloud Vision DOCUMENT_TEXT_DETECTION
    try {
      return await _googleVisionOcr(imageBytes, imageW, imageH);
    } catch (_) {}

    // Fallback: OCR.space
    try {
      return await _ocrSpaceOcr(imageBytes, imageW, imageH);
    } catch (_) {}

    return [];
  }

  Future<List<OcrWord>> _googleVisionOcr(
      Uint8List imageBytes, int imageW, int imageH) async {
    final base64Image = base64Encode(imageBytes);
    final response = await _dio.post(
      'https://vision.googleapis.com/v1/images:annotate',
      queryParameters: {'key': _kGoogleVisionKey},
      data: {
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'DOCUMENT_TEXT_DETECTION', 'maxResults': 1}
            ],
          }
        ]
      },
      options: Options(
        headers: {'Content-Type': 'application/json'},
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    final results = response.data['responses'] as List?;
    if (results == null || results.isEmpty) return [];

    final fullText = results[0]['fullTextAnnotation'];
    if (fullText == null) return [];

    final words = <OcrWord>[];
    final pages = fullText['pages'] as List? ?? [];
    for (final pg in pages) {
      for (final block in (pg['blocks'] as List? ?? [])) {
        for (final para in (block['paragraphs'] as List? ?? [])) {
          for (final word in (para['words'] as List? ?? [])) {
            final text = (word['symbols'] as List? ?? [])
                .map((s) => s['text'] as String? ?? '')
                .join('');
            if (text.trim().isEmpty) continue;

            final verts = (word['boundingBox']?['vertices'] as List?) ?? [];
            if (verts.length < 4) continue;
            final x0 = (verts[0]['x'] as num?)?.toDouble() ?? 0;
            final y0 = (verts[0]['y'] as num?)?.toDouble() ?? 0;
            final x2 = (verts[2]['x'] as num?)?.toDouble() ?? 0;
            final y2 = (verts[2]['y'] as num?)?.toDouble() ?? 0;

            words.add(OcrWord(
              text: text,
              left: (x0 / imageW).clamp(0.0, 1.0),
              top: (y0 / imageH).clamp(0.0, 1.0),
              width: ((x2 - x0) / imageW).clamp(0.0, 1.0),
              height: ((y2 - y0) / imageH).clamp(0.0, 1.0),
            ));
          }
        }
      }
    }
    return words;
  }

  Future<List<OcrWord>> _ocrSpaceOcr(
      Uint8List imageBytes, int imageW, int imageH) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/ocr_tmp_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(imageBytes);

    try {
      final formData = FormData.fromMap({
        'apikey': _kOcrSpaceKey,
        'language': 'eng',
        'isOverlayRequired': 'true',
        'OCREngine': '2',
        'file': await MultipartFile.fromFile(tempFile.path,
            filename: 'page.jpg'),
      });

      final response = await _dio.post(
        'https://api.ocr.space/parse/image',
        data: formData,
        options: Options(receiveTimeout: const Duration(seconds: 60)),
      );

      final parsed = response.data['ParsedResults'] as List?;
      if (parsed == null || parsed.isEmpty) return [];

      final words = <OcrWord>[];
      for (final result in parsed) {
        final lines = result['TextOverlay']?['Lines'] as List? ?? [];
        for (final line in lines) {
          for (final word in (line['Words'] as List? ?? [])) {
            final text = word['WordText'] as String? ?? '';
            if (text.trim().isEmpty) continue;
            final left = (word['Left'] as num?)?.toDouble() ?? 0;
            final top = (word['Top'] as num?)?.toDouble() ?? 0;
            final w = (word['Width'] as num?)?.toDouble() ?? 0;
            final h = (word['Height'] as num?)?.toDouble() ?? 0;
            words.add(OcrWord(
              text: text,
              left: (left / imageW).clamp(0.0, 1.0),
              top: (top / imageH).clamp(0.0, 1.0),
              width: (w / imageW).clamp(0.0, 1.0),
              height: (h / imageH).clamp(0.0, 1.0),
            ));
          }
        }
      }
      return words;
    } finally {
      try { await tempFile.delete(); } catch (_) {}
    }
  }

  // ── Offline OCR (ML Kit) ──────────────────────────────────────────────────

  Future<List<OcrWord>> _ocrOffline(Uint8List imageBytes, {required int imageW, required int imageH}) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/ocr_offline_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(imageBytes);

    try {
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFilePath(tempFile.path);
      final result = await recognizer.processImage(inputImage);
      await recognizer.close();

      final iW = imageW.toDouble();
      final iH = imageH.toDouble();

      final words = <OcrWord>[];
      for (final block in result.blocks) {
        for (final line in block.lines) {
          for (final element in line.elements) {
            final text = element.text.trim();
            if (text.isEmpty) continue;
            final bbox = element.boundingBox;
            words.add(OcrWord(
              text: text,
              left: (bbox.left / iW).clamp(0.0, 1.0),
              top: (bbox.top / iH).clamp(0.0, 1.0),
              width: (bbox.width / iW).clamp(0.0, 1.0),
              height: (bbox.height / iH).clamp(0.0, 1.0),
            ));
          }
        }
      }
      return words;
    } finally {
      try { await tempFile.delete(); } catch (_) {}
    }
  }
} // end OcrService

// ── Internal data class ───────────────────────────────────────────────────────
class _OcrPageData {
  final Uint8List imageBytes;
  final ui.Size pdfSize;
  final int imageW;
  final int imageH;
  final List<OcrWord> words;

  const _OcrPageData({
    required this.imageBytes,
    required this.pdfSize,
    required this.imageW,
    required this.imageH,
    required this.words,
  });
}
