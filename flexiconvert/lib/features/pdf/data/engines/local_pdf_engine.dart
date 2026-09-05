import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as pathLib;
import 'package:pdf/pdf.dart' as pw_core;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sync_pdf;
import '../../../../core/exceptions/engine_not_implemented_exception.dart';
import '../../domain/engines/pdf_engine.dart';
import '../../domain/models/pdf_task_model.dart';
import 'ocr_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class LocalPdfEngine implements PdfEngine {
  @override
  Future<PdfResult> imagesToPdf({
    required List<String> imagePaths,
    required String outputPath,
    String pageSize = 'fit',
    String orientation = 'portrait',
    void Function(double)? onProgress,
  }) async {
    final pdf = pw.Document();

    for (int i = 0; i < imagePaths.length; i++) {
      final imageFile = File(imagePaths[i]);
      final imageBytes = await imageFile.readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      pw_core.PdfPageFormat baseFormat;
      if (pageSize == 'fit') {
        baseFormat = pw_core.PdfPageFormat(image.width!.toDouble(), image.height!.toDouble());
      } else if (pageSize == 'us_letter') {
        baseFormat = pw_core.PdfPageFormat.letter;
      } else {
        baseFormat = pw_core.PdfPageFormat.a4;
      }

      final pageFormat = pageSize == 'fit'
          ? baseFormat
          : (orientation == 'landscape' ? baseFormat.landscape : baseFormat.portrait);

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image));
          },
        ),
      );

      if (onProgress != null) {
        onProgress((i + 1) / imagePaths.length);
      }
    }

    final file = File(outputPath);
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);

    return PdfResult(
      outputPath: outputPath,
      pageCount: imagePaths.length,
      fileSizeBytes: bytes.length,
      durationMs: 0,
    );
  }

  @override
  Future<List<String>> pdfToImages({
    required String pdfPath,
    required String outputDir,
    void Function(double)? onProgress,
  }) async {
    final document = await PdfDocument.openFile(pdfPath);
    final List<String> imagePaths = [];

    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.jpeg,
      );

      await page.close();

      if (pageImage != null) {
        final outputPath = '$outputDir/page_$i.jpg';
        final file = File(outputPath);
        await file.writeAsBytes(pageImage.bytes);
        imagePaths.add(outputPath);
      }

      if (onProgress != null) {
        onProgress(i / document.pagesCount);
      }
    }

    await document.close();
    return imagePaths;
  }

  // ── Helper: apply canvas rotation for syncfusion ──────────────────────────
  void _drawRotated({
    required sync_pdf.PdfPage page,
    required sync_pdf.PdfTemplate template,
    required int angleDeg,
    required Size originalSize,
  }) {
    final gfx = page.graphics;
    final w = originalSize.width;
    final h = originalSize.height;

    gfx.save();
    switch (angleDeg % 360) {
      case 90:
        gfx.translateTransform(h, 0);
        gfx.rotateTransform(90);
        break;
      case 180:
        gfx.translateTransform(w, h);
        gfx.rotateTransform(180);
        break;
      case 270:
        gfx.translateTransform(0, w);
        gfx.rotateTransform(-90);
        break;
      default:
        break;
    }
    gfx.drawPdfTemplate(template, const Offset(0, 0), originalSize);
    gfx.restore();
  }

  @override
  Future<PdfResult> mergePdfs({
    required List<String> pdfPaths,
    required String outputPath,
    Map<String, int>? mergeRotations,
    void Function(double)? onProgress,
  }) async {
    final outDoc = sync_pdf.PdfDocument();
    outDoc.pageSettings.margins.all = 0;
    int totalPages = 0;

    for (int p = 0; p < pdfPaths.length; p++) {
      final path = pdfPaths[p];
      final rotation = (mergeRotations?[path] ?? 0) % 360;

      final bytes = await File(path).readAsBytes();
      final srcDoc = sync_pdf.PdfDocument(inputBytes: bytes);

      for (int i = 0; i < srcDoc.pages.count; i++) {
        final origSize = srcDoc.pages[i].size;
        final template = srcDoc.pages[i].createTemplate();

        final bool swapDims = rotation == 90 || rotation == 270;
        final pageWidth = swapDims ? origSize.height : origSize.width;
        final pageHeight = swapDims ? origSize.width : origSize.height;

        outDoc.pageSettings.size = Size(pageWidth, pageHeight);
        outDoc.pageSettings.orientation = pageWidth > pageHeight
            ? sync_pdf.PdfPageOrientation.landscape
            : sync_pdf.PdfPageOrientation.portrait;

        final newPage = outDoc.pages.add();

        if (rotation == 0) {
          newPage.graphics.drawPdfTemplate(template, const Offset(0, 0), origSize);
        } else {
          _drawRotated(
            page: newPage,
            template: template,
            angleDeg: rotation,
            originalSize: origSize,
          );
        }
        totalPages++;
      }
      srcDoc.dispose();

      if (onProgress != null) {
        onProgress((p + 1) / pdfPaths.length);
      }
    }

    final file = File(outputPath);
    final outBytes = await outDoc.save();
    outDoc.dispose();
    await file.writeAsBytes(outBytes);

    return PdfResult(
      outputPath: outputPath,
      pageCount: totalPages,
      fileSizeBytes: outBytes.length,
      durationMs: 0,
    );
  }

  @override
  Future<List<String>> splitPdf({
    required String pdfPath,
    required String outputDir,
    List<int>? pageRanges,
    void Function(double)? onProgress,
  }) async {
    final bytes = await File(pdfPath).readAsBytes();
    final document = sync_pdf.PdfDocument(inputBytes: bytes);
    final totalPages = document.pages.count;
    document.dispose();

    final List<String> splitPaths = [];
    final pagesToExtract = pageRanges ?? List.generate(totalPages, (i) => i + 1);

    for (int i = 0; i < pagesToExtract.length; i++) {
      final pageIndex = pagesToExtract[i] - 1;
      if (pageIndex < 0 || pageIndex >= totalPages) continue;

      final tempDoc = sync_pdf.PdfDocument(inputBytes: bytes);
      for (int j = tempDoc.pages.count - 1; j >= 0; j--) {
        if (j != pageIndex) {
          tempDoc.pages.removeAt(j);
        }
      }

      final outBytes = await tempDoc.save();
      tempDoc.dispose();

      final outputPath = '$outputDir/page_${pageIndex + 1}.pdf';
      final file = File(outputPath);
      await file.writeAsBytes(outBytes);
      splitPaths.add(outputPath);

      if (onProgress != null) {
        onProgress((i + 1) / pagesToExtract.length);
      }
    }

    return splitPaths;
  }

  @override
  Future<PdfResult> compressPdf({
    required String pdfPath,
    required String outputPath,
    int compressionLevel = 1,
    double targetSizeMb = 0,
    void Function(double)? onProgress,
  }) async {
    final int jpegQuality;
    final double renderScale;
    switch (compressionLevel) {
      case 0:
        jpegQuality = 15;
        renderScale = 0.6;
        break;
      case 2:
        jpegQuality = 82;
        renderScale = 1.2;
        break;
      default:
        jpegQuality = 50;
        renderScale = 0.9;
    }

    final doc = await PdfDocument.openFile(pdfPath);
    final pdf = pw.Document(compress: true);
    int totalPages = 0;

    for (int i = 1; i <= doc.pagesCount; i++) {
      final page = await doc.getPage(i);
      final renderW = (page.width * renderScale).round();
      final renderH = (page.height * renderScale).round();

      final pageImage = await page.render(
        width: renderW.toDouble(),
        height: renderH.toDouble(),
        format: PdfPageImageFormat.jpeg,
        quality: jpegQuality,
      );
      await page.close();

      if (pageImage != null) {
        final image = pw.MemoryImage(pageImage.bytes);
        pdf.addPage(
          pw.Page(
            pageFormat: pw_core.PdfPageFormat(page.width, page.height),
            build: (pw.Context ctx) => pw.Center(child: pw.Image(image)),
          ),
        );
        totalPages++;
      }

      if (onProgress != null) onProgress(i / doc.pagesCount);
    }

    await doc.close();

    var outBytes = await pdf.save();

    if (targetSizeMb > 0) {
      final targetBytes = (targetSizeMb * 1024 * 1024).round();
      if (outBytes.length > targetBytes) {
        final doc2 = await PdfDocument.openFile(pdfPath);
        final pdf2 = pw.Document(compress: true);
        final ratio = targetBytes / outBytes.length;
        final reducedScale = renderScale * math.sqrt(ratio) * 0.9;
        final reducedQ = (jpegQuality * ratio).clamp(8, 30).round();

        for (int i = 1; i <= doc2.pagesCount; i++) {
          final page = await doc2.getPage(i);
          final rW = (page.width * reducedScale).round().clamp(100, 4000);
          final rH = (page.height * reducedScale).round().clamp(100, 4000);
          final img = await page.render(
            width: rW.toDouble(), height: rH.toDouble(),
            format: PdfPageImageFormat.jpeg,
            quality: reducedQ,
          );
          await page.close();
          if (img != null) {
            final image = pw.MemoryImage(img.bytes);
            pdf2.addPage(
              pw.Page(
                pageFormat: pw_core.PdfPageFormat(page.width, page.height),
                build: (pw.Context ctx) => pw.Center(child: pw.Image(image)),
              ),
            );
          }
        }
        await doc2.close();
        outBytes = await pdf2.save();
      }
    }

    await File(outputPath).writeAsBytes(outBytes);

    return PdfResult(
      outputPath: outputPath,
      pageCount: totalPages,
      fileSizeBytes: outBytes.length,
      durationMs: 0,
    );
  }

  // ── ROTATE PAGES ──────────────────────────────────────────────────────────
  @override
  Future<PdfResult> rotatePages({
    required String pdfPath,
    required String outputPath,
    required int angle,
    List<int>? pagesToRotate,
    Map<int, int>? pageAngles,
  }) async {
    final bytes = await File(pdfPath).readAsBytes();
    final srcDoc = sync_pdf.PdfDocument(inputBytes: bytes);
    final outDoc = sync_pdf.PdfDocument();
    outDoc.pageSettings.margins.all = 0;
    int addedPages = 0;

    for (int i = 0; i < srcDoc.pages.count; i++) {
      final pageNum = i + 1;

      // Determine angle for this page
      int pageAngle;
      if (pageAngles != null && pageAngles.containsKey(pageNum)) {
        pageAngle = pageAngles[pageNum]! % 360;
      } else if (pagesToRotate == null || pagesToRotate.contains(pageNum)) {
        pageAngle = angle % 360;
      } else {
        pageAngle = 0;
      }

      final origSize = srcDoc.pages[i].size;
      final template = srcDoc.pages[i].createTemplate();
      final bool swapDims = pageAngle == 90 || pageAngle == 270;
      final pageW = swapDims ? origSize.height : origSize.width;
      final pageH = swapDims ? origSize.width : origSize.height;

      outDoc.pageSettings.size = Size(pageW, pageH);
      outDoc.pageSettings.orientation = pageW > pageH
          ? sync_pdf.PdfPageOrientation.landscape
          : sync_pdf.PdfPageOrientation.portrait;

      final newPage = outDoc.pages.add();
      if (pageAngle == 0) {
        newPage.graphics.drawPdfTemplate(template, const Offset(0, 0), origSize);
      } else {
        _drawRotated(page: newPage, template: template, angleDeg: pageAngle, originalSize: origSize);
      }
      addedPages++;
    }

    srcDoc.dispose();
    final outBytes = await outDoc.save();
    outDoc.dispose();
    await File(outputPath).writeAsBytes(outBytes);

    return PdfResult(
      outputPath: outputPath,
      pageCount: addedPages,
      fileSizeBytes: outBytes.length,
      durationMs: 0,
    );
  }

  /// Rotates multiple PDFs, each with its own global angle, and zips them.
  /// Returns the path to the zip file (or folder if [saveAsFolder] is true).
  Future<String> rotateMultiplePdfs({
    required List<String> pdfPaths,
    required Map<String, int> fileAngles,
    required String outputDirOrZipPath,
    required bool saveAsFolder,
    void Function(double)? onProgress,
  }) async {
    final processedPaths = <String>[];

    for (int i = 0; i < pdfPaths.length; i++) {
      final path = pdfPaths[i];
      final fileAngle = (fileAngles[path] ?? 0) % 360;
      final name = path.split(Platform.pathSeparator).last;

      final String outPath;
      if (saveAsFolder) {
        final dir = Directory(outputDirOrZipPath);
        if (!await dir.exists()) await dir.create(recursive: true);
        outPath = '$outputDirOrZipPath${Platform.pathSeparator}$name';
      } else {
        final tempDir = Directory('${outputDirOrZipPath}_tmp');
        if (!await tempDir.exists()) await tempDir.create(recursive: true);
        outPath = '${tempDir.path}${Platform.pathSeparator}$name';
      }

      await rotatePages(
        pdfPath: path,
        outputPath: outPath,
        angle: fileAngle,
      );
      processedPaths.add(outPath);

      if (onProgress != null) onProgress((i + 1) / pdfPaths.length);
    }

    if (saveAsFolder) {
      return outputDirOrZipPath;
    }

    // Create zip
    final encoder = ZipFileEncoder();
    encoder.create(outputDirOrZipPath);
    for (final p in processedPaths) {
      encoder.addFile(File(p), pathLib.basename(p));
    }
    encoder.close();

    // Clean up temp folder
    try {
      await Directory('${outputDirOrZipPath}_tmp').delete(recursive: true);
    } catch (_) {}

    return outputDirOrZipPath;
  }

  @override
  Future<PdfResult> reorderPages({
    required String pdfPath,
    required String outputPath,
    required List<int> newPageOrder,
    bool multiOrg = false,
    List<String>? multiOrgFiles,
    List<int>? multiOrgFileIndices,
    List<int>? multiOrgPageNums,
    Map<int, int>? pageRotations,
    List<int>? multiOrgRotations,
  }) async {
    final outDoc = sync_pdf.PdfDocument();
    outDoc.pageSettings.margins.all = 0;
    int addedPages = 0;

    if (multiOrg) {
      if (multiOrgFiles == null || multiOrgFileIndices == null || multiOrgPageNums == null) {
        throw Exception('Missing multi-org parameters');
      }
      final List<sync_pdf.PdfDocument> docs = [];
      for (final f in multiOrgFiles) {
        final bytes = await File(f).readAsBytes();
        docs.add(sync_pdf.PdfDocument(inputBytes: bytes));
      }

      for (int i = 0; i < multiOrgFileIndices.length; i++) {
        final doc = docs[multiOrgFileIndices[i]];
        final idx = multiOrgPageNums[i] - 1;
        if (idx < 0 || idx >= doc.pages.count) continue;

        final origSize = doc.pages[idx].size;
        final template = doc.pages[idx].createTemplate();
        final rotation = (multiOrgRotations != null && i < multiOrgRotations.length)
            ? multiOrgRotations[i] % 360
            : 0;

        final bool swapDims = rotation == 90 || rotation == 270;
        final pageW = swapDims ? origSize.height : origSize.width;
        final pageH = swapDims ? origSize.width : origSize.height;

        outDoc.pageSettings.size = Size(pageW, pageH);
        final newPage = outDoc.pages.add();

        if (rotation == 0) {
          newPage.graphics.drawPdfTemplate(template, const Offset(0, 0), origSize);
        } else {
          _drawRotated(page: newPage, template: template, angleDeg: rotation, originalSize: origSize);
        }
        addedPages++;
      }

      for (final doc in docs) {
        doc.dispose();
      }
    } else {
      final bytes = await File(pdfPath).readAsBytes();
      final srcDoc = sync_pdf.PdfDocument(inputBytes: bytes);

      for (final pageNum in newPageOrder) {
        final idx = pageNum - 1;
        if (idx < 0 || idx >= srcDoc.pages.count) continue;

        final origSize = srcDoc.pages[idx].size;
        final template = srcDoc.pages[idx].createTemplate();
        final rotation = (pageRotations?[pageNum] ?? 0) % 360;

        final bool swapDims = rotation == 90 || rotation == 270;
        final pageW = swapDims ? origSize.height : origSize.width;
        final pageH = swapDims ? origSize.width : origSize.height;

        outDoc.pageSettings.size = Size(pageW, pageH);
        final newPage = outDoc.pages.add();

        if (rotation == 0) {
          newPage.graphics.drawPdfTemplate(template, const Offset(0, 0), origSize);
        } else {
          _drawRotated(page: newPage, template: template, angleDeg: rotation, originalSize: origSize);
        }
        addedPages++;
      }
      srcDoc.dispose();
    }

    if (addedPages == 0) outDoc.pages.add();

    final outBytes = await outDoc.save();
    outDoc.dispose();
    await File(outputPath).writeAsBytes(outBytes);
    return PdfResult(
      outputPath: outputPath,
      pageCount: addedPages,
      fileSizeBytes: outBytes.length,
      durationMs: 0,
    );
  }

  @override
  Future<PdfResult> deletePages({
    required String pdfPath,
    required String outputPath,
    required List<int> pagesToDelete,
  }) async {
    final bytes = await File(pdfPath).readAsBytes();
    final srcDoc = sync_pdf.PdfDocument(inputBytes: bytes);
    final outDoc = sync_pdf.PdfDocument();
    outDoc.pageSettings.margins.all = 0;

    final toRemove = pagesToDelete.map((p) => p - 1).toSet();
    int addedPages = 0;

    for (int i = 0; i < srcDoc.pages.count; i++) {
      if (!toRemove.contains(i)) {
        final size = srcDoc.pages[i].size;
        outDoc.pageSettings.size = size;
        final newPage = outDoc.pages.add();
        newPage.graphics.drawPdfTemplate(
          srcDoc.pages[i].createTemplate(),
          const Offset(0, 0),
          size,
        );
        addedPages++;
      }
    }

    srcDoc.dispose();
    final outBytes = await outDoc.save();
    outDoc.dispose();

    await File(outputPath).writeAsBytes(outBytes);
    return PdfResult(
      outputPath: outputPath,
      pageCount: addedPages,
      fileSizeBytes: outBytes.length,
      durationMs: 0,
    );
  }

  @override
  Future<PdfResult> extractPages({
    required String pdfPath,
    required String outputPath,
    required List<int> pagesToExtract,
    Map<int, int>? pageRotations,
  }) async {
    final bytes = await File(pdfPath).readAsBytes();
    final srcDoc = sync_pdf.PdfDocument(inputBytes: bytes);
    final outDoc = sync_pdf.PdfDocument();
    outDoc.pageSettings.margins.all = 0;

    final toKeep = pagesToExtract.map((p) => p - 1).toSet();
    int addedPages = 0;

    for (int i = 0; i < srcDoc.pages.count; i++) {
      if (toKeep.contains(i)) {
        final pageNum = i + 1;
        final rotation = (pageRotations?[pageNum] ?? 0) % 360;
        final origSize = srcDoc.pages[i].size;
        final template = srcDoc.pages[i].createTemplate();

        final bool swapDims = rotation == 90 || rotation == 270;
        final pageWidth = swapDims ? origSize.height : origSize.width;
        final pageHeight = swapDims ? origSize.width : origSize.height;

        outDoc.pageSettings.size = Size(pageWidth, pageHeight);
        outDoc.pageSettings.orientation = pageWidth > pageHeight
            ? sync_pdf.PdfPageOrientation.landscape
            : sync_pdf.PdfPageOrientation.portrait;

        final newPage = outDoc.pages.add();

        if (rotation == 0) {
          newPage.graphics.drawPdfTemplate(template, const Offset(0, 0), origSize);
        } else {
          _drawRotated(page: newPage, template: template, angleDeg: rotation, originalSize: origSize);
        }
        addedPages++;
      }
    }

    srcDoc.dispose();
    final outBytes = await outDoc.save();
    outDoc.dispose();

    await File(outputPath).writeAsBytes(outBytes);
    return PdfResult(
      outputPath: outputPath,
      pageCount: addedPages,
      fileSizeBytes: outBytes.length,
      durationMs: 0,
    );
  }

  @override
  Future<PdfResult> watermarkPdf({
    required String pdfPath,
    required String outputPath,
    required WatermarkOptions options,
  }) async {
    final startTime = DateTime.now();
    try {
      final bytes = await File(pdfPath).readAsBytes();
      final doc = sync_pdf.PdfDocument(inputBytes: bytes);
      
      for (int i = 0; i < doc.pages.count; i++) {
        final page = doc.pages[i];
        final size = page.size;
        
        final sync_pdf.PdfGraphics graphics = options.isOver ? page.graphics : page.graphics;
        // In Syncfusion, to draw UNDER the content, we'd need a background template.
        // For simplicity we draw over content or set transparency.
        graphics.save();
        graphics.setTransparency(options.transparency);
        
        double x = size.width / 2;
        double y = size.height / 2;
        
        // Grid position (1-9)
        // 1 2 3
        // 4 5 6
        // 7 8 9
        if (options.position % 3 == 1) x = size.width * 0.25;
        if (options.position % 3 == 0) x = size.width * 0.75;
        if (options.position <= 3) y = size.height * 0.25;
        if (options.position >= 7) y = size.height * 0.75;

        // Apply rotation
        graphics.translateTransform(x, y);
        graphics.rotateTransform(-options.rotation.toDouble()); // Syncfusion rotation is counter-clockwise?
        
        if (options.isText) {
          final font = sync_pdf.PdfStandardFont(sync_pdf.PdfFontFamily.helvetica, 48);
          final brush = sync_pdf.PdfSolidBrush(sync_pdf.PdfColor(128, 128, 128)); // gray
          
          final textSize = font.measureString(options.text);
          graphics.drawString(
            options.text,
            font,
            brush: brush,
            bounds: Rect.fromLTWH(-textSize.width / 2, -textSize.height / 2, textSize.width, textSize.height),
            format: sync_pdf.PdfStringFormat(
              alignment: sync_pdf.PdfTextAlignment.center,
              lineAlignment: sync_pdf.PdfVerticalAlignment.middle,
            ),
          );
        } else if (options.imageBytes != null) {
          final image = sync_pdf.PdfBitmap(options.imageBytes!);
          final w = image.width.toDouble();
          final h = image.height.toDouble();
          
          // scale image down if too large
          double scale = 1.0;
          if (w > size.width * 0.8) scale = (size.width * 0.8) / w;
          if (h * scale > size.height * 0.8) scale = (size.height * 0.8) / h;
          
          graphics.drawImage(
            image,
            Rect.fromLTWH(-(w * scale) / 2, -(h * scale) / 2, w * scale, h * scale),
          );
        }
        
        graphics.restore();
      }
      
      final outBytes = await doc.save();
      doc.dispose();
      
      final outFile = File(outputPath);
      await outFile.writeAsBytes(outBytes);
      
      return PdfResult(
        outputPath: outputPath,
        pageCount: doc.pages.count,
        fileSizeBytes: outBytes.length,
        durationMs: DateTime.now().difference(startTime).inMilliseconds,
      );
    } catch (e) {
      throw Exception('Failed to add watermark: $e');
    }
  }

  @override
  Future<PdfResult> addSignatures({
    required String pdfPath,
    required String outputPath,
    required List<Map<String, dynamic>> signatures,
  }) async {
    final startTime = DateTime.now();
    try {
      final bytes = await File(pdfPath).readAsBytes();
      final doc = sync_pdf.PdfDocument(inputBytes: bytes);
      
      for (final sig in signatures) {
        final pageIndex = sig['pageIndex'] as int? ?? 0;
        final x = sig['x'] as double? ?? 0.0;
        final y = sig['y'] as double? ?? 0.0;
        final width = sig['width'] as double? ?? 200.0;
        final height = sig['height'] as double? ?? 100.0;
        final rotation = sig['rotation'] as double? ?? 0.0;
        final signatureBytes = sig['signatureBytes'] as Uint8List?;

        if (signatureBytes != null && pageIndex >= 0 && pageIndex < doc.pages.count) {
          final page = doc.pages[pageIndex];
          final image = sync_pdf.PdfBitmap(signatureBytes);
          
          page.graphics.save();
          
          // Translate to center of image, rotate, then translate back
          final centerX = x + (width / 2);
          final centerY = y + (height / 2);
          
          page.graphics.translateTransform(centerX, centerY);
          page.graphics.rotateTransform(-rotation); // syncfusion is counter-clockwise?
          page.graphics.translateTransform(-centerX, -centerY);
          
          page.graphics.drawImage(image, Rect.fromLTWH(x, y, width, height));
          page.graphics.restore();
        }
      }
      
      final outBytes = await doc.save();
      doc.dispose();
      
      final outFile = File(outputPath);
      await outFile.writeAsBytes(outBytes);
      
      return PdfResult(
        outputPath: outputPath,
        pageCount: doc.pages.count,
        fileSizeBytes: outBytes.length,
        durationMs: DateTime.now().difference(startTime).inMilliseconds,
      );
    } catch (e) {
      throw Exception('Failed to add signature: $e');
    }
  }

  @override
  Future<PdfResult> encryptPdf({
    required String pdfPath,
    required String outputPath,
    required String password,
  }) async {
    final startTime = DateTime.now();
    final bytes = await File(pdfPath).readAsBytes();
    final doc = sync_pdf.PdfDocument(inputBytes: bytes);

    // Apply password encryption using Syncfusion
    doc.security.algorithm = sync_pdf.PdfEncryptionAlgorithm.aesx128Bit;
    doc.security.userPassword = password;
    doc.security.ownerPassword = password;

    final outBytes = await doc.save();
    doc.dispose();
    await File(outputPath).writeAsBytes(outBytes);

    return PdfResult(
      outputPath: outputPath,
      pageCount: 1,
      fileSizeBytes: outBytes.length,
      durationMs: DateTime.now().difference(startTime).inMilliseconds,
    );
  }

  @override
  Future<PdfResult> unlockPdf({
    required String pdfPath,
    required String outputPath,
    required String password,
  }) async {
    final startTime = DateTime.now();
    final bytes = await File(pdfPath).readAsBytes();

    // Open with password
    final doc = sync_pdf.PdfDocument(inputBytes: bytes, password: password);

    // Remove password by clearing security
    doc.security.userPassword = '';
    doc.security.ownerPassword = '';

    final outBytes = await doc.save();
    doc.dispose();
    await File(outputPath).writeAsBytes(outBytes);

    return PdfResult(
      outputPath: outputPath,
      pageCount: 1,
      fileSizeBytes: outBytes.length,
      durationMs: DateTime.now().difference(startTime).inMilliseconds,
    );
  }

  // ── REAL OCR ──────────────────────────────────────────────────────────────
  @override
  Future<PdfResult> ocrExtractText({
    required List<String> pdfPaths,
    required String outputPath,
    bool mergeOutput = true,
    Map<String, int>? fileRotations,
    String ocrMode = 'online',
    String outputFormat = 'pdf',
  }) async {
    final service = OcrService();

    final pages = await service.extractPages(
      pdfPaths: pdfPaths,
      mode: ocrMode,
    );

    final String finalPath;
    if (outputFormat == 'txt') {
      final txt = service.buildTxt(pages);
      final txtPath = outputPath.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '.txt');
      await File(txtPath).writeAsString(txt);
      finalPath = txtPath;
    } else {
      final pdfBytes = await service.buildSearchablePdf(pages);
      await File(outputPath).writeAsBytes(pdfBytes);
      finalPath = outputPath;
    }

    return PdfResult(
      outputPath: finalPath,
      pageCount: pages.length,
      fileSizeBytes: File(finalPath).lengthSync(),
      durationMs: 0,
    );
  }

  // ── ADD PAGE NUMBERS ──────────────────────────────────────────────────────
  @override
  Future<PdfResult> addPageNumbers({
    required String pdfPath,
    required String outputPath,
    required PageNumberOptions options,
  }) async {
    final bytes = await File(pdfPath).readAsBytes();
    final doc = sync_pdf.PdfDocument(inputBytes: bytes);
    final totalPages = doc.pages.count;
    final effectiveTo = options.toPage <= 0 ? totalPages : options.toPage.clamp(1, totalPages);

    // Build font
    final sync_pdf.PdfFont pdfFont = _buildSyncFont(options);
    // Build brush from hex color
    final brush = sync_pdf.PdfSolidBrush(_hexToPdfColor(options.colorHex));

    int numberIndex = 0;

    for (int pageIdx = 0; pageIdx < doc.pages.count; pageIdx++) {
      final pageNum = pageIdx + 1;
      if (pageNum < options.fromPage || pageNum > effectiveTo) continue;

      final displayNum = options.firstNumber + numberIndex;
      numberIndex++;

      final text = _formatPageNumberText(
        displayNum, totalPages, options.textFormat, options.customFormat);

      final page = doc.pages[pageIdx];
      final pageSize = page.size;
      final effectivePosition = _getEffectivePosition(options.position, pageNum, options);
      final bounds = _calculateNumberBounds(pageSize, effectivePosition, options.margin);

      final format = sync_pdf.PdfStringFormat(
        alignment: _positionToAlignment(effectivePosition),
        lineAlignment: sync_pdf.PdfVerticalAlignment.middle,
      );

      page.graphics.drawString(
        text, pdfFont,
        brush: brush,
        bounds: bounds,
        format: format,
      );
    }

    final outBytes = await doc.save();
    doc.dispose();
    await File(outputPath).writeAsBytes(outBytes);

    return PdfResult(
      outputPath: outputPath,
      pageCount: totalPages,
      fileSizeBytes: outBytes.length,
      durationMs: 0,
    );
  }

  // ── Helpers for addPageNumbers ────────────────────────────────────────────

  sync_pdf.PdfFont _buildSyncFont(PageNumberOptions opt) {
    final List<sync_pdf.PdfFontStyle> styles = [];
    if (opt.bold) styles.add(sync_pdf.PdfFontStyle.bold);
    if (opt.italic) styles.add(sync_pdf.PdfFontStyle.italic);
    if (opt.underline) styles.add(sync_pdf.PdfFontStyle.underline);
    final style = styles.isEmpty ? sync_pdf.PdfFontStyle.regular : styles.first;

    switch (opt.fontFamily) {
      case 'Times New Roman':
        return sync_pdf.PdfStandardFont(sync_pdf.PdfFontFamily.timesRoman, opt.fontSize,
            style: style, multiStyle: styles.length > 1 ? styles : null);
      case 'Courier':
        return sync_pdf.PdfStandardFont(sync_pdf.PdfFontFamily.courier, opt.fontSize,
            style: style, multiStyle: styles.length > 1 ? styles : null);
      default:
        return sync_pdf.PdfStandardFont(sync_pdf.PdfFontFamily.helvetica, opt.fontSize,
            style: style, multiStyle: styles.length > 1 ? styles : null);
    }
  }

  sync_pdf.PdfColor _hexToPdfColor(String hex) {
    final clean = hex.replaceAll('#', '');
    final value = int.tryParse(clean, radix: 16) ?? 0x000000;
    final r = (value >> 16) & 0xFF;
    final g = (value >> 8) & 0xFF;
    final b = value & 0xFF;
    return sync_pdf.PdfColor(r, g, b);
  }

  String _formatPageNumberText(
      int n, int total, String format, String custom) {
    switch (format) {
      case 'option2':
        return 'Page $n';
      case 'option3':
        return 'Page $n of $total';
      case 'option4':
        return custom
            .replaceAll('{n}', '$n')
            .replaceAll('{p}', '$total');
      default:
        return '$n';
    }
  }

  int _getEffectivePosition(int position, int pageNum, PageNumberOptions opt) {
    if (opt.pageMode != 'facing') return position;
    
    // Determine if this is a "right" or "bottom" page depending on orientation
    // Portrait: swaps Left/Right (1<->3, 4<->6)
    // Landscape: swaps Top/Bottom (1<->4, 2<->5, 3<->6) 
    // If firstPageIsCover = true, page 1 is the 'right' or 'bottom' page.
    // If firstPageIsCover = false, page 1 is the 'left' or 'top' page.
    final isOddPage = (pageNum % 2) != 0;
    final isSecondInPair = opt.firstPageIsCover ? isOddPage : !isOddPage;

    if (!isSecondInPair) {
      // First in pair (Left or Top) - keep default position usually,
      // but let's assume default position is selected for the first page of the pair.
      return position;
    } else {
      // Second in pair (Right or Bottom) - swap position
      if (opt.facingOrientation == 'landscape') {
        // Swap top/bottom
        switch (position) {
          case 1: return 4;
          case 2: return 5;
          case 3: return 6;
          case 4: return 1;
          case 5: return 2;
          case 6: return 3;
          default: return position;
        }
      } else {
        // Swap left/right (portrait)
        switch (position) {
          case 1: return 3;
          case 3: return 1;
          case 4: return 6;
          case 6: return 4;
          default: return position;
        }
      }
    }
  }

  Rect _calculateNumberBounds(Size pageSize, int position, String margin) {
    final pct = margin == 'big' ? 0.15 : margin == 'small' ? 0.05 : 0.10;
    final mX = pageSize.width * pct;
    final mY = pageSize.height * pct;
    const textH = 32.0;
    final textW = pageSize.width * 0.25;

    switch (position) {
      case 1: // TL
        return Rect.fromLTWH(mX, mY, textW, textH);
      case 2: // TC
        return Rect.fromLTWH((pageSize.width - textW) / 2, mY, textW, textH);
      case 3: // TR
        return Rect.fromLTWH(pageSize.width - mX - textW, mY, textW, textH);
      case 4: // BL
        return Rect.fromLTWH(mX, pageSize.height - mY - textH, textW, textH);
      case 5: // BC
        return Rect.fromLTWH((pageSize.width - textW) / 2, pageSize.height - mY - textH, textW, textH);
      case 6: // BR
      default:
        return Rect.fromLTWH(pageSize.width - mX - textW, pageSize.height - mY - textH, textW, textH);
    }
  }

  sync_pdf.PdfTextAlignment _positionToAlignment(int position) {
    switch (position) {
      case 1:
      case 4:
        return sync_pdf.PdfTextAlignment.left;
      case 2:
      case 5:
        return sync_pdf.PdfTextAlignment.center;
      case 3:
      case 6:
      default:
        return sync_pdf.PdfTextAlignment.right;
    }
  }

  /// Zips [filePaths] into [zipPath].
  Future<String> zipFiles(List<String> filePaths, String zipPath) async {
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    for (final p in filePaths) {
      encoder.addFile(File(p), pathLib.basename(p));
    }
    encoder.close();
    return zipPath;
  }

  /// Saves [filePaths] into [folderPath], copying each file there.
  Future<String> saveToFolder(List<String> filePaths, String folderPath) async {
    final dir = Directory(folderPath);
    if (!await dir.exists()) await dir.create(recursive: true);
    for (final p in filePaths) {
      final name = p.split(Platform.pathSeparator).last;
      await File(p).copy('$folderPath${Platform.pathSeparator}$name');
    }
    return folderPath;
  }

  /// Saves [filePaths] into a ZIP archive at [zipPath].
  Future<String> saveToZip(List<String> filePaths, String zipPath) async {
    final archive = Archive();
    for (final p in filePaths) {
      final name = p.split(Platform.pathSeparator).last;
      final file = File(p);
      final bytes = await file.readAsBytes();
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }
    final zipData = ZipEncoder().encode(archive);
    await File(zipPath).writeAsBytes(zipData);
    return zipPath;
  }

  @override
  Future<PdfResult> cropPdf({
    required String pdfPath,
    required String outputPath,
    required Map<int, Rect> cropRects,
    Map<int, int>? cropRotations,
    Map<int, bool>? cropMirrorH,
    Map<int, bool>? cropMirrorV,
  }) async {
    final startTime = DateTime.now();
    final bytes = await File(pdfPath).readAsBytes();
    final doc = sync_pdf.PdfDocument(inputBytes: bytes);
    final newDoc = sync_pdf.PdfDocument();
    
    for (int i = 0; i < doc.pages.count; i++) {
      final pageNum = i + 1;
      final page = doc.pages[i];
      final size = page.size;
      
      if (cropRects.containsKey(pageNum)) {
        final rect = cropRects[pageNum]!;
        
        final rot = (cropRotations?[pageNum] ?? 0) % 360;
        final mH = cropMirrorH?[pageNum] ?? false;
        final mV = cropMirrorV?[pageNum] ?? false;
        
        final bool swapDims = rot == 90 || rot == 270;
        final TW = swapDims ? size.height : size.width;
        final TH = swapDims ? size.width : size.height;
        
        final left = rect.left * TW;
        final top = rect.top * TH;
        final width = rect.width * TW;
        final height = rect.height * TH;
        
        newDoc.pageSettings.size = Size(width, height);
        newDoc.pageSettings.margins.all = 0;
        final newPage = newDoc.pages.add();
        final template = page.createTemplate();
        
        newPage.graphics.save();
        
        // 1. Crop translation
        newPage.graphics.translateTransform(-left, -top);
        
        // 2. Mirroring (applied from canvas space)
        if (mV) {
          // newPage.graphics.translateTransform(0, TH);
          // newPage.graphics.scaleTransform(1, -1);
          // Syncfusion doesn't support mirroring natively via scaleTransform.
        }
        if (mH) {
          // newPage.graphics.translateTransform(TW, 0);
          // newPage.graphics.scaleTransform(-1, 1);
        }
        
        // 3. Rotation
        if (rot == 90) {
          newPage.graphics.translateTransform(TW, 0);
          newPage.graphics.rotateTransform(90);
        } else if (rot == 180) {
          newPage.graphics.translateTransform(TW, TH);
          newPage.graphics.rotateTransform(180);
        } else if (rot == 270) {
          newPage.graphics.translateTransform(0, TH);
          newPage.graphics.rotateTransform(270);
        }
        
        newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
        newPage.graphics.restore();
      } else {
        newDoc.pageSettings.size = size;
        newDoc.pageSettings.margins.all = 0;
        final newPage = newDoc.pages.add();
        final template = page.createTemplate();
        newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
      }
    }
    
    final outBytes = await newDoc.save();
    doc.dispose();
    newDoc.dispose();
    await File(outputPath).writeAsBytes(outBytes);
    
    return PdfResult(
      outputPath: outputPath,
      pageCount: doc.pages.count,
      fileSizeBytes: outBytes.length,
      durationMs: DateTime.now().difference(startTime).inMilliseconds,
    );
  }

  @override
  Future<PdfResult> editPdf({
    required String pdfPath,
    required String outputPath,
    required List<PdfLayerData> layers,
    void Function(double)? onProgress,
  }) async {
    final startTime = DateTime.now();
    final bytes = await File(pdfPath).readAsBytes();
    final doc = sync_pdf.PdfDocument(inputBytes: bytes);
    
    // Group layers by page
    final layersByPage = <int, List<PdfLayerData>>{};
    for (var layer in layers) {
      layersByPage.putIfAbsent(layer.pageNumber, () => []).add(layer);
    }

    for (int i = 0; i < doc.pages.count; i++) {
      final page = doc.pages[i];
      final pageLayers = layersByPage[i + 1] ?? [];
      
      for (var layer in pageLayers) {
        // Apply rotation context
        page.graphics.save();
        
        // Translate to center of layer, rotate, translate back
        final cx = layer.x + layer.width / 2;
        final cy = layer.y + layer.height / 2;
        page.graphics.translateTransform(cx, cy);
        page.graphics.rotateTransform(layer.rotation); // degrees? Syncfusion uses degrees
        page.graphics.translateTransform(-cx, -cy);

        if (layer.type == 'text' && layer.text != null) {
          sync_pdf.PdfFontStyle fontStyle = sync_pdf.PdfFontStyle.regular;
          final List<sync_pdf.PdfFontStyle> multiStyle = [];
          
          if (layer.isBold) multiStyle.add(sync_pdf.PdfFontStyle.bold);
          if (layer.isItalic) multiStyle.add(sync_pdf.PdfFontStyle.italic);
          if (layer.isUnderline) multiStyle.add(sync_pdf.PdfFontStyle.underline);
          
          if (multiStyle.isNotEmpty) {
            fontStyle = multiStyle.first;
          }
          
          final font = sync_pdf.PdfStandardFont(
            sync_pdf.PdfFontFamily.helvetica, 
            layer.fontSize ?? 14, 
            style: fontStyle,
            multiStyle: multiStyle.isEmpty ? null : multiStyle,
          );
          
          int hex = 0xFF000000;
          if (layer.colorHex != null) {
            final cleaned = layer.colorHex!.replaceAll('#', '');
            if (cleaned.length == 6) hex = int.parse('FF$cleaned', radix: 16);
            if (cleaned.length == 8) hex = int.parse(cleaned, radix: 16);
          }
          final color = Color(hex);
          
          page.graphics.drawString(
            layer.text!,
            font,
            bounds: Rect.fromLTWH(layer.x, layer.y, layer.width, layer.height),
            brush: sync_pdf.PdfSolidBrush(sync_pdf.PdfColor(color.red, color.green, color.blue)),
          );
        }
        else if (layer.type == 'image' && layer.imageBytes != null) {
          final pdfImage = sync_pdf.PdfBitmap(layer.imageBytes!);
          page.graphics.drawImage(
            pdfImage, 
            Rect.fromLTWH(layer.x, layer.y, layer.width, layer.height)
          );
        }
        else if (layer.type == 'shape' && layer.shapeType != null) {
          sync_pdf.PdfPen? pen;
          sync_pdf.PdfBrush? brush;
          
          if (layer.outlineColorHex != null && layer.outlineColorHex!.isNotEmpty) {
            final cleaned = layer.outlineColorHex!.replaceAll('#', '');
            if (cleaned.length >= 6) {
              final hex = int.parse(cleaned.length == 6 ? 'FF$cleaned' : cleaned, radix: 16);
              final color = Color(hex);
              pen = sync_pdf.PdfPen(sync_pdf.PdfColor(color.red, color.green, color.blue), width: layer.strokeWidth ?? 1);
            }
          }
          if (layer.backgroundColorHex != null && layer.backgroundColorHex!.isNotEmpty) {
            final cleaned = layer.backgroundColorHex!.replaceAll('#', '');
            if (cleaned.length >= 6) {
              final hex = int.parse(cleaned.length == 6 ? 'FF$cleaned' : cleaned, radix: 16);
              final color = Color(hex);
              brush = sync_pdf.PdfSolidBrush(sync_pdf.PdfColor(color.red, color.green, color.blue));
            }
          }
          
          final bounds = Rect.fromLTWH(layer.x, layer.y, layer.width, layer.height);
          
          if (layer.shapeType == 'rectangle') {
            page.graphics.drawRectangle(bounds: bounds, pen: pen, brush: brush);
          } else if (layer.shapeType == 'circle' || layer.shapeType == 'ellipse') {
            page.graphics.drawEllipse(bounds, pen: pen, brush: brush);
          }
        }
        
        page.graphics.restore();
      }
      
      if (onProgress != null) {
        onProgress((i + 1) / doc.pages.count);
      }
    }
    
    final outBytes = await doc.save();
    doc.dispose();
    await File(outputPath).writeAsBytes(outBytes);

    return PdfResult(
      outputPath: outputPath,
      pageCount: doc.pages.count,
      fileSizeBytes: outBytes.length,
      durationMs: DateTime.now().difference(startTime).inMilliseconds,
    );
  }

  @override
  Future<PdfResult> redactPdf({
    required String pdfPath,
    required String outputPath,
    required List<Map<String, dynamic>> redactions,
  }) async {
    final startTime = DateTime.now();
    try {
      final bytes = await File(pdfPath).readAsBytes();
      final doc = sync_pdf.PdfDocument(inputBytes: bytes);
      
      for (final redaction in redactions) {
        final pageIndex = redaction['pageIndex'] as int? ?? 0;
        final type = redaction['type'] as String? ?? 'clear';
        final x = redaction['x'] as double? ?? 0.0;
        final y = redaction['y'] as double? ?? 0.0;
        final width = redaction['width'] as double? ?? 100.0;
        final height = redaction['height'] as double? ?? 100.0;
        final color = redaction['color'] as int? ?? 0xFFFFFFFF; // ARGB
        
        if (pageIndex >= 0 && pageIndex < doc.pages.count) {
          final page = doc.pages[pageIndex];
          final bounds = Rect.fromLTWH(x, y, width, height);
          
          if (type == 'clear') {
            page.graphics.drawRectangle(
              brush: sync_pdf.PdfSolidBrush(sync_pdf.PdfColor(255, 255, 255)),
              bounds: bounds,
            );
          } else {
            // Paint or Blur (simulated with translucent rectangle)
            final r = (color >> 16) & 0xFF;
            final g = (color >> 8) & 0xFF;
            final b = color & 0xFF;
            
            page.graphics.drawRectangle(
              brush: sync_pdf.PdfSolidBrush(sync_pdf.PdfColor(r, g, b)),
              bounds: bounds,
            );
          }
        }
      }
      
      final outBytes = await doc.save();
      doc.dispose();
      
      await File(outputPath).writeAsBytes(outBytes);
      return PdfResult(
        outputPath: outputPath,
        pageCount: doc.pages.count,
        fileSizeBytes: outBytes.length,
        durationMs: DateTime.now().difference(startTime).inMilliseconds,
      );
    } catch (e) {
      throw Exception('Failed to redact PDF: $e');
    }
  }

  @override
  Future<PdfResult> pdfToMarkdown({
    required String pdfPath,
    required String outputPath,
    required bool generateSummary,
    void Function(double)? onProgress,
  }) async {
    final startTime = DateTime.now();
    try {
      onProgress?.call(0.1);
      final bytes = await File(pdfPath).readAsBytes();
      final document = sync_pdf.PdfDocument(inputBytes: bytes);
      
      String extractedText = '';
      for (int i = 0; i < document.pages.count; i++) {
        final textExtractor = sync_pdf.PdfTextExtractor(document);
        extractedText += textExtractor.extractText(startPageIndex: i, endPageIndex: i) ?? '';
        extractedText += '\n\n';
        onProgress?.call(0.1 + (i / document.pages.count) * 0.4);
      }
      final pageCount = document.pages.count;
      document.dispose();

      String markdownContent = '# Extracted Content from ${pathLib.basename(pdfPath)}\n\n';
      markdownContent += extractedText;

      if (generateSummary) {
        onProgress?.call(0.6);
        try {
          final model = GenerativeModel(
            model: 'gemini-1.5-flash',
            apiKey: 'YOUR_API_KEY_HERE',
          );

          final prompt = 'Please summarize the following extracted text from a PDF document:\n\n$extractedText';
          final response = await model.generateContent([Content.text(prompt)]);
          
          if (response.text != null) {
            markdownContent = '# AI Summary\n\n${response.text}\n\n---\n\n$markdownContent';
          }
        } catch (e) {
          markdownContent = '> **Note:** AI Summary failed to generate: $e\n\n$markdownContent';
        }
      }

      onProgress?.call(0.9);
      final outFile = File(outputPath);
      await outFile.writeAsString(markdownContent);

      onProgress?.call(1.0);
      return PdfResult(
        outputPath: outputPath,
        pageCount: pageCount,
        fileSizeBytes: await outFile.length(),
        durationMs: DateTime.now().difference(startTime).inMilliseconds,
      );
    } catch (e) {
      throw Exception('Failed to convert PDF to Markdown: $e');
    }
  }
}
