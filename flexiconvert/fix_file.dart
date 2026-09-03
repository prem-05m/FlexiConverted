import 'dart:io';

void main() {
  final file = File('lib/features/pdf/presentation/screens/base_pdf_tool_screen.dart');
  final lines = file.readAsLinesSync();

  int uiStart = -1;
  int uiEnd = -1;
  int stateEnd = -1;

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Widget _buildUnlockPdfUI(BuildContext context) {')) {
      uiStart = i - 3; 
    }
    if (lines[i].contains('class _OrgPageCard extends StatelessWidget {')) {
      uiEnd = i - 3;
    }
    if (lines[i].contains('class _PdfPreviewCard extends StatelessWidget {')) {
      stateEnd = i - 3;
    }
  }

  if (uiStart != -1 && uiEnd != -1 && stateEnd != -1) {
    final uiLines = lines.sublist(uiStart, uiEnd);
    lines.removeRange(uiStart, uiEnd);
    
    // Add missing braces for _PdfPreviewCard where we removed the lines
    lines.insert(uiStart, '  }');
    lines.insert(uiStart + 1, '}');
    lines.insert(uiStart + 2, '');

    // Insert uiLines before the end of the state class
    lines.insertAll(stateEnd, uiLines);
    
    file.writeAsStringSync(lines.join('\n'));
    print('Fixed successfully');
  } else {
    print('Indices not found: uiStart=$uiStart, uiEnd=$uiEnd, stateEnd=$stateEnd');
  }
}
