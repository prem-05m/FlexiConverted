import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/models/engine_response.dart';
import '../../domain/engines/document_engine.dart';
import '../../domain/models/document_task_model.dart';
import '../../domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentEngine _engine;

  DocumentRepositoryImpl(this._engine);

  @override
  Future<Either<Failure, DocumentResult>> executeTask({
    required DocumentToolType toolType,
    required List<String> inputPaths,
    required String outputPath,
    void Function(double)? onProgress,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      EngineResponse<DocumentResult> response;

      switch (toolType) {
        case DocumentToolType.wordToPdf:
          response = await _engine.convertDocument(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            sourceFormat: DocumentFormat.word,
            targetFormat: DocumentFormat.pdf,
          );
          break;
        case DocumentToolType.pdfToWord:
          response = await _engine.convertDocument(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            sourceFormat: DocumentFormat.pdf,
            targetFormat: DocumentFormat.word,
          );
          break;
        case DocumentToolType.excelToPdf:
          response = await _engine.convertDocument(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            sourceFormat: DocumentFormat.excel,
            targetFormat: DocumentFormat.pdf,
          );
          break;
        case DocumentToolType.pdfToExcel:
          response = await _engine.convertDocument(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            sourceFormat: DocumentFormat.pdf,
            targetFormat: DocumentFormat.excel,
          );
          break;
        case DocumentToolType.pptToPdf:
          response = await _engine.convertDocument(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            sourceFormat: DocumentFormat.ppt,
            targetFormat: DocumentFormat.pdf,
          );
          break;
        case DocumentToolType.pdfToPpt:
          response = await _engine.convertDocument(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            sourceFormat: DocumentFormat.pdf,
            targetFormat: DocumentFormat.ppt,
          );
          break;
        case DocumentToolType.txtToPdf:
          response = await _engine.convertDocument(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            sourceFormat: DocumentFormat.txt,
            targetFormat: DocumentFormat.pdf,
          );
          break;
        case DocumentToolType.htmlToPdf:
          response = await _engine.convertDocument(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            sourceFormat: DocumentFormat.html,
            targetFormat: DocumentFormat.pdf,
          );
          break;
        case DocumentToolType.csvToExcel:
          response = await _engine.convertDocument(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            sourceFormat: DocumentFormat.csv,
            targetFormat: DocumentFormat.excel,
          );
          break;
        case DocumentToolType.jpgToPdf:
        case DocumentToolType.pdfToJpg:
        case DocumentToolType.pdfToPdfA:
          response = EngineResponse.notAvailable("Tool ${toolType.name} is coming soon.");
          break;
      }

      if (response.isSuccess) {
        return Right(response.data!);
      } else if (response.isNotAvailable) {
        return Left(ConversionFailure(response.errorMessage!));
      } else {
        return Left(ConversionFailure(response.errorMessage ?? 'Unknown error occurred.'));
      }
    } catch (e) {
      return Left(ConversionFailure('Failed to process document: ${e.toString()}'));
    }
  }
}
