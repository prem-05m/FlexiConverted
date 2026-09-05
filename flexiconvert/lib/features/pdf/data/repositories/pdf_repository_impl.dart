import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/exceptions/engine_not_implemented_exception.dart';
import '../../domain/engines/pdf_engine.dart';
import '../../domain/models/pdf_task_model.dart';
import '../../domain/repositories/pdf_repository.dart';
import '../engines/local_pdf_engine.dart';

class PdfRepositoryImpl implements PdfRepository {
  final PdfEngine _engine;

  PdfRepositoryImpl(this._engine);

  @override
  Future<Either<Failure, PdfResult>> executeTask({
    required PdfToolType toolType,
    required List<String> inputPaths,
    required String outputPath,
    void Function(double)? onProgress,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      PdfResult result;

      switch (toolType) {
        case PdfToolType.imageToPdf:
          result = await _engine.imagesToPdf(
            imagePaths: inputPaths,
            outputPath: outputPath,
            pageSize: additionalParams?['pageSize'] ?? 'fit',
            orientation: additionalParams?['orientation'] ?? 'portrait',
            onProgress: onProgress,
          );
          break;

        case PdfToolType.pdfToImage:
          final dirPath = outputPath.replaceAll('.pdf', '');
          final dir = Directory(dirPath);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          final images = await _engine.pdfToImages(
            pdfPath: inputPaths.first,
            outputDir: dirPath,
            onProgress: onProgress,
          );
          result = PdfResult(
            outputPath: dirPath,
            pageCount: images.length,
            fileSizeBytes: 0,
            durationMs: 0,
          );
          break;

        case PdfToolType.mergePdf:
          final rawRotations = additionalParams?['mergeRotations'];
          final Map<String, int>? mergeRotations = rawRotations != null
              ? Map<String, int>.from(rawRotations)
              : null;
          result = await _engine.mergePdfs(
            pdfPaths: inputPaths,
            outputPath: outputPath,
            mergeRotations: mergeRotations,
            onProgress: onProgress,
          );
          break;

        case PdfToolType.splitPdf:
          final List<int> pages = List<int>.from(
            additionalParams?['pageRanges'] ?? [],
          );
          if (pages.isEmpty) {
            throw Exception('No page range specified');
          }
          final rawRotations = additionalParams?['pageRotations'];
          final Map<int, int>? pageRotations = rawRotations != null
              ? Map<int, int>.from(rawRotations)
              : null;
          result = await _engine.extractPages(
            pdfPath: inputPaths.first,
            outputPath: outputPath,
            pagesToExtract: pages,
            pageRotations: pageRotations,
          );
          break;

        case PdfToolType.compressPdf:
          result = await _engine.compressPdf(
            pdfPath: inputPaths.first,
            outputPath: outputPath,
            compressionLevel: additionalParams?['compressionLevel'] ?? 1,
            targetSizeMb: (additionalParams?['targetSizeMb'] ?? 0).toDouble(),
            onProgress: onProgress,
          );
          break;

        case PdfToolType.rotatePdf:
          final isMulti = additionalParams?['multiFile'] == true;
          if (isMulti) {
            // Multiple PDFs: rotate each and zip/save to folder
            final localEngine = _engine as LocalPdfEngine;
            final rawFileAngles = additionalParams?['fileAngles'];
            final Map<String, int> fileAngles = rawFileAngles != null
                ? Map<String, int>.from(rawFileAngles)
                : {};
            final saveAsFolder = additionalParams?['saveAsFolder'] == true;

            final outPath = await localEngine.rotateMultiplePdfs(
              pdfPaths: inputPaths,
              fileAngles: fileAngles,
              outputDirOrZipPath: outputPath,
              saveAsFolder: saveAsFolder,
              onProgress: onProgress,
            );
            result = PdfResult(
              outputPath: outPath,
              pageCount: inputPaths.length,
              fileSizeBytes: File(outPath).existsSync() ? File(outPath).lengthSync() : 0,
              durationMs: 0,
            );
          } else {
            // Single PDF with per-page angles
            final rawPageAngles = additionalParams?['pageAngles'];
            final Map<int, int>? pageAngles = rawPageAngles != null
                ? Map<int, int>.from(rawPageAngles)
                : null;
            result = await _engine.rotatePages(
              pdfPath: inputPaths.first,
              outputPath: outputPath,
              angle: additionalParams?['angle'] ?? 90,
              pagesToRotate: additionalParams?['pagesToRotate'],
              pageAngles: pageAngles,
            );
          }
          break;

        case PdfToolType.reorderPages:
          if (additionalParams?['multiOrg'] == true) {
            final rawRotations = additionalParams?['multiOrgRotations'];
            result = await _engine.reorderPages(
              pdfPath: inputPaths.first,
              outputPath: outputPath,
              newPageOrder: [],
              multiOrg: true,
              multiOrgFiles: inputPaths,
              multiOrgFileIndices: List<int>.from(additionalParams?['fileIndices'] ?? []),
              multiOrgPageNums: List<int>.from(additionalParams?['pageNums'] ?? []),
              multiOrgRotations: rawRotations != null ? List<int>.from(rawRotations) : null,
            );
          } else {
            final rawRotations = additionalParams?['pageRotations'];
            result = await _engine.reorderPages(
              pdfPath: inputPaths.first,
              outputPath: outputPath,
              newPageOrder: List<int>.from(additionalParams?['newPageOrder'] ?? []),
              pageRotations: rawRotations != null ? Map<int, int>.from(rawRotations) : null,
            );
          }
          break;

        case PdfToolType.deletePages:
          result = await _engine.deletePages(
            pdfPath: inputPaths.first,
            outputPath: outputPath,
            pagesToDelete: List<int>.from(additionalParams?['pagesToDelete'] ?? []),
          );
          break;

        case PdfToolType.extractPages:
          result = await _engine.extractPages(
            pdfPath: inputPaths.first,
            outputPath: outputPath,
            pagesToExtract: additionalParams?['pagesToExtract'] ?? [],
          );
          break;

        case PdfToolType.watermarkPdf:
          result = await _engine.watermarkPdf(
            pdfPath: inputPaths.first,
            outputPath: outputPath,
            options: additionalParams?['options'] as WatermarkOptions? ?? const WatermarkOptions(),
          );
          break;

        case PdfToolType.addSignature:
          result = await _engine.addSignatures(
            pdfPath: inputPaths.first,
            outputPath: outputPath,
            signatures: (additionalParams?['signatures'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
          );
          break;

        case PdfToolType.encryptPdf:
          result = await _engine.encryptPdf(
            pdfPath: inputPaths.first,
            outputPath: outputPath,
            password: additionalParams?['password'] as String? ?? '',
          );
          break;

        case PdfToolType.redactPdf:
          result = await _engine.redactPdf(
            pdfPath: inputPaths.first,
            outputPath: outputPath,
            redactions: (additionalParams?['redactions'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
          );
          break;

        case PdfToolType.unlockPdf:
          result = await _engine.unlockPdf(
            pdfPath: inputPaths.first,
            outputPath: outputPath,
            password: additionalParams?['password'] ?? '',
          );
          break;

        case PdfToolType.cropPdf:
          result = await _engine.cropPdf(
            pdfPath: inputPaths.first,
            outputPath: outputPath,
            cropRects: additionalParams?['cropRects'] ?? {},
            cropRotations: additionalParams?['cropRotations'] as Map<int, int>?,
            cropMirrorH: additionalParams?['cropMirrorH'] as Map<int, bool>?,
            cropMirrorV: additionalParams?['cropMirrorV'] as Map<int, bool>?,
          );
          break;

        case PdfToolType.renamePdf:
        case PdfToolType.duplicatePdf:
        case PdfToolType.previewPdf:
        case PdfToolType.sharePdf:
        case PdfToolType.printPdf:
        case PdfToolType.scanToPdf:
        case PdfToolType.repairPdf:
          throw EngineNotImplementedException(toolType.name);

        case PdfToolType.ocrPdf:
          final bool mergeOutput = additionalParams?['mergeOutput'] ?? true;
          final rawOcrRotations = additionalParams?['fileRotations'];
          final Map<String, int>? ocrFileRotations = rawOcrRotations != null
              ? Map<String, int>.from(rawOcrRotations)
              : null;
          result = await _engine.ocrExtractText(
            pdfPaths: inputPaths,
            outputPath: outputPath,
            mergeOutput: mergeOutput,
            fileRotations: ocrFileRotations,
            ocrMode: additionalParams?['ocrMode'] ?? 'online',
            outputFormat: additionalParams?['outputFormat'] ?? 'pdf',
          );
          break;

        case PdfToolType.addPageNumbers:
          // Multi-file: process each separately then zip / save to folder
          final isMultiPdf = inputPaths.length > 1;
          final options = additionalParams?['pageNumberOptions'] as PageNumberOptions?
              ?? const PageNumberOptions();

          if (isMultiPdf) {
            final localEngine = _engine as LocalPdfEngine;
            final saveAsFolder = additionalParams?['saveAsFolder'] == true;
            final processedPaths = <String>[];
            final tempBase = outputPath.replaceAll(RegExp(r'\.[^.]+$'), '');

            for (int i = 0; i < inputPaths.length; i++) {
              final name = inputPaths[i].split(Platform.pathSeparator).last;
              final tempOut = '${tempBase}_tmp_${i}_$name';
              await _engine.addPageNumbers(
                pdfPath: inputPaths[i],
                outputPath: tempOut,
                options: options,
              );
              processedPaths.add(tempOut);
            }

            final String finalPath;
            if (saveAsFolder) {
              finalPath = await localEngine.saveToFolder(processedPaths, outputPath);
            } else {
              finalPath = await localEngine.zipFiles(processedPaths, outputPath);
            }

            // Clean up temp files
            for (final p in processedPaths) {
              try { await File(p).delete(); } catch (_) {}
            }

            result = PdfResult(
              outputPath: finalPath,
              pageCount: inputPaths.length,
              fileSizeBytes: File(finalPath).existsSync() ? File(finalPath).lengthSync() : 0,
              durationMs: 0,
            );
          } else {
            result = await _engine.addPageNumbers(
              pdfPath: inputPaths.first,
              outputPath: outputPath,
              options: options,
            );
          }
          break;

        case PdfToolType.pdfToMarkdown:
          // Multi-file: process each separately then zip / save to folder
          final isMultiPdf = inputPaths.length > 1;
          final generateSummary = additionalParams?['generateSummary'] == true;
          
          if (isMultiPdf) {
            final localEngine = _engine as LocalPdfEngine;
            final saveAsFolder = additionalParams?['saveAsFolder'] == true;
            final processedPaths = <String>[];
            final tempBase = outputPath.replaceAll(RegExp(r'\.[^.]+$'), '');

            for (int i = 0; i < inputPaths.length; i++) {
              final name = inputPaths[i].split(Platform.pathSeparator).last.replaceAll('.pdf', '.md');
              final tempOut = '${tempBase}_tmp_${i}_$name';
              await _engine.pdfToMarkdown(
                pdfPath: inputPaths[i],
                outputPath: tempOut,
                generateSummary: generateSummary,
              );
              processedPaths.add(tempOut);
            }

            final String finalPath;
            if (saveAsFolder) {
              finalPath = await localEngine.saveToFolder(processedPaths, outputPath);
            } else {
              finalPath = await localEngine.saveToZip(processedPaths, outputPath);
            }

            for (final p in processedPaths) {
              try { File(p).deleteSync(); } catch (_) {}
            }

            result = PdfResult(
              outputPath: finalPath,
              pageCount: 1,
              fileSizeBytes: File(finalPath).lengthSync(),
              durationMs: 0,
            );
          } else {
            result = await _engine.pdfToMarkdown(
              pdfPath: inputPaths.first,
              outputPath: outputPath,
              generateSummary: generateSummary,
            );
          }
          break;

        case PdfToolType.cropPdf:
        case PdfToolType.editPdf:
        case PdfToolType.pdfForms:
        case PdfToolType.redactPdf:
        case PdfToolType.comparePdf:
        case PdfToolType.aiSummarizer:
        case PdfToolType.translatePdf:
          throw EngineNotImplementedException(toolType.name);
      }

      return Right(result);
    } on EngineNotImplementedException catch (e) {
      return Left(ConversionFailure(e.toString()));
    } catch (e) {
      return Left(ConversionFailure('Failed to process PDF: ${e.toString()}'));
    }
  }
}
