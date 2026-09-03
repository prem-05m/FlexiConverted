import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/models/archive_task_model.dart';
import '../providers/archive_task_provider.dart';
import '../../../../features/pdf/presentation/widgets/progress_dialog.dart';

class BaseArchiveToolScreen extends ConsumerStatefulWidget {
  final ArchiveToolType toolType;

  const BaseArchiveToolScreen({super.key, required this.toolType});

  @override
  ConsumerState<BaseArchiveToolScreen> createState() => _BaseArchiveToolScreenState();
}

class _BaseArchiveToolScreenState extends ConsumerState<BaseArchiveToolScreen> {
  final List<String> _selectedFiles = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: widget.toolType == ArchiveToolType.compress,
    );

    if (result.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(result.map((e) => e.path).whereType<String>());
      });
    }
  }

  Future<void> _execute() async {
    if (_selectedFiles.isEmpty) return;

    ref.read(archiveTaskProvider.notifier).initializeTask(widget.toolType, _selectedFiles);

    final directory = await getApplicationDocumentsDirectory();
    final outputPath = '${directory.path}/output_${DateTime.now().millisecondsSinceEpoch}';
    final actualOutputPath = widget.toolType == ArchiveToolType.compress ? '$outputPath.zip' : outputPath;

    ProgressDialog.show(context, message: 'Processing archive...');

    await ref.read(archiveTaskProvider.notifier).executeTask(
      outputPath: actualOutputPath,
      additionalParams: {'format': ArchiveFormat.zip},
    );

    if (mounted) {
      ProgressDialog.hide(context);
      final state = ref.read(archiveTaskProvider);
      if (state.status == TaskStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Success: ${state.outputPath}')),
        );
      } else if (state.status == TaskStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${state.errorMessage}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.toolType.name.toUpperCase())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.file_upload),
              label: const Text('Select Files/Archive'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_selectedFiles[index].split('/').last),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedFiles.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            if (_selectedFiles.isNotEmpty)
              ElevatedButton(
                onPressed: _execute,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text(widget.toolType == ArchiveToolType.compress ? 'Compress' : 'Extract'),
              ),
          ],
        ),
      ),
    );
  }
}
