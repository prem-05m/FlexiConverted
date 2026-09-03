import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/download_location_service.dart';
import '../../domain/models/qr_task_model.dart';
import '../providers/qr_task_provider.dart';
import 'dart:io';

class BaseQrToolScreen extends ConsumerStatefulWidget {
  final QrToolType toolType;

  const BaseQrToolScreen({super.key, required this.toolType});

  @override
  ConsumerState<BaseQrToolScreen> createState() => _BaseQrToolScreenState();
}

class _BaseQrToolScreenState extends ConsumerState<BaseQrToolScreen> {
  final TextEditingController _textController = TextEditingController();

  Future<void> _execute() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(qrTaskProvider.notifier).initializeTask(widget.toolType);

    final directory = await getApplicationDocumentsDirectory();
    final outputPath = '${directory.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';

    await ref.read(qrTaskProvider.notifier).executeTask(
      inputData: text,
      outputPath: outputPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrTaskProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.toolType.name.toUpperCase())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Data to encode',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state.status == TaskStatus.processing ? null : _execute,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: state.status == TaskStatus.processing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Generate QR Code'),
            ),
            const SizedBox(height: 32),
            if (state.status == TaskStatus.success && state.outputPath != null)
              Column(
                children: [
                  const Text('Generated QR Code:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Image.file(File(state.outputPath!), height: 250),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Export'),
                        onPressed: () async {
                          final outputPath = await DownloadLocationService.getOutputPath(context, ref, 'qr_${DateTime.now().millisecondsSinceEpoch}.png');
                          if (outputPath != null) {
                            await File(state.outputPath!).copy(outputPath);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('QR Code Exported Successfully!'), backgroundColor: Colors.green),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        onPressed: () {
                          Share.shareXFiles([XFile(state.outputPath!)], text: 'Here is my QR Code!');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            if (state.status == TaskStatus.failure)
              Text('Error: ${state.errorMessage}', style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
