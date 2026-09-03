import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePadDialog extends StatefulWidget {
  const SignaturePadDialog({super.key});

  @override
  State<SignaturePadDialog> createState() => _SignaturePadDialogState();
}

class _SignaturePadDialogState extends State<SignaturePadDialog> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Draw Signature'),
      content: Container(
        width: 400,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.white, // So user can see their drawing easily
        ),
        child: Signature(
          controller: _controller,
          backgroundColor: Colors.white,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _controller.clear(),
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (_controller.isNotEmpty) {
              final Uint8List? data = await _controller.toPngBytes();
              if (mounted) Navigator.pop(context, data);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
