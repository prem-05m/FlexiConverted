import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class FullImageEditorScreen extends StatefulWidget {
  final String imagePath;

  const FullImageEditorScreen({super.key, required this.imagePath});

  @override
  State<FullImageEditorScreen> createState() => _FullImageEditorScreenState();
}

class _FullImageEditorScreenState extends State<FullImageEditorScreen> {
  @override
  Widget build(BuildContext context) {
    return ProImageEditor.file(
      File(widget.imagePath),
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (bytes) async {
          // Save the edited bytes back to a temporary file
          final tempDir = await Directory.systemTemp.createTemp('editor_');
          final ext = widget.imagePath.split('.').last;
          final outPath = '${tempDir.path}/edited_image.$ext';
          final outFile = File(outPath);
          await outFile.writeAsBytes(bytes);

          if (mounted) {
            // For now, we return just the path
            // In a future advanced "Apply All", we can pass history as well
            Navigator.pop(context, outPath);
          }
        },
        onCloseEditor: (dynamic mode) {
          Navigator.pop(context);
        },
      ),
    );
  }
}
