import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/models/file_task_model.dart';
import '../providers/file_task_provider.dart';

class BaseFileToolScreen extends ConsumerStatefulWidget {
  final FileToolType toolType;

  const BaseFileToolScreen({super.key, required this.toolType});

  @override
  ConsumerState<BaseFileToolScreen> createState() => _BaseFileToolScreenState();
}

class _BaseFileToolScreenState extends ConsumerState<BaseFileToolScreen> {
  final List<String> _selectedFiles = [];
  final TextEditingController _nameController = TextEditingController();

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(allowMultiple: true);
    if (result.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(result.map((e) => e.path).whereType<String>());
      });
    }
  }

  Future<void> _execute() async {
    if (_selectedFiles.isEmpty) return;

    ref.read(fileTaskProvider.notifier).initializeTask(widget.toolType, _selectedFiles);

    String? outputPath;
    if (widget.toolType == FileToolType.rename || widget.toolType == FileToolType.copy || widget.toolType == FileToolType.move) {
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide destination/new name')));
        return;
      }
      outputPath = _nameController.text.trim();
    }

    await ref.read(fileTaskProvider.notifier).executeTask(
      outputPath: outputPath,
    );

    if (mounted) {
      final state = ref.read(fileTaskProvider);
      if (state.status == TaskStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Success! ${state.outputPath ?? 'Files processed'}')),
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
              label: const Text('Select Files'),
            ),
            if (widget.toolType == FileToolType.rename || widget.toolType == FileToolType.copy || widget.toolType == FileToolType.move) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'New Name / Destination Path',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
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
                child: const Text('Execute'),
              ),
          ],
        ),
      ),
    );
  }
}
