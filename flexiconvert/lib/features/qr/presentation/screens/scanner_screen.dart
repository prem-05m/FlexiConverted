import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/qr_task_provider.dart';
import '../../domain/models/qr_task_model.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(qrTaskProvider.notifier).initializeTask(QrToolType.scan);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrTaskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                if (_isScanned) return;
                
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final rawValue = barcodes.first.rawValue;
                  if (rawValue != null) {
                    setState(() {
                      _isScanned = true;
                    });
                    ref.read(qrTaskProvider.notifier).setScannedData(rawValue);
                    cameraController.stop();
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: (state.status == TaskStatus.success && state.scannedData != null)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Scanned Data:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(state.scannedData!),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isScanned = false;
                              });
                              ref.read(qrTaskProvider.notifier).reset();
                              cameraController.start();
                            },
                            child: const Text('Scan Again'),
                          )
                        ],
                      )
                    : const Text('Scan a code'),
              ),
            ),
          )
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
