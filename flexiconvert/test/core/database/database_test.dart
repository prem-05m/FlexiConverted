import 'package:flutter_test/flutter_test.dart';
import 'package:flexiconvert/core/database/models/history_model.dart';
import 'package:flexiconvert/core/database/models/recent_file_model.dart';

void main() {
  test('HistoryItem model instantiates correctly', () {
    final history = HistoryItem()
      ..fileName = 'test.pdf'
      ..toolType = 'PDF Tool'
      ..timestamp = DateTime.now()
      ..status = 'success'
      ..outputPath = '/temp/test.pdf'
      ..durationMs = 1200
      ..fileSizeBytes = 1024;

    expect(history.fileName, 'test.pdf');
    expect(history.toolType, 'PDF Tool');
    expect(history.status, 'success');
    expect(history.durationMs, 1200);
  });

  test('RecentFile model instantiates correctly', () {
    final recent = RecentFile()
      ..filePath = '/temp/test.pdf'
      ..fileName = 'test.pdf'
      ..mimeType = 'application/pdf'
      ..lastOpened = DateTime.now();

    expect(recent.fileName, 'test.pdf');
    expect(recent.mimeType, 'application/pdf');
    expect(recent.filePath, '/temp/test.pdf');
  });
}
