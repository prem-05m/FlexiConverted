import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/web_constrained_box.dart';
import '../../domain/models/qr_task_model.dart';

class QrDashboardScreen extends StatelessWidget {
  const QrDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      {'title': 'Text to QR', 'icon': Icons.qr_code, 'type': QrToolType.generate},
      {'title': 'Scan QR', 'icon': Icons.qr_code_scanner, 'type': QrToolType.scan},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR'),
      ),
      body: WebConstrainedBox(
        maxWidth: 800,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final tool = tools[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (tool['type'] == QrToolType.scan) {
                    context.push('${RouteConstants.home}/${RouteConstants.qr}/scan');
                  } else {
                    context.push(
                      '${RouteConstants.home}/${RouteConstants.qr}/tool',
                      extra: tool['type'] as QrToolType,
                    );
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tool['icon'] as IconData, size: 48, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      tool['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
