import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../domain/models/file_task_model.dart';

class FileDashboardScreen extends StatelessWidget {
  const FileDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      {'title': 'File Manager', 'icon': Icons.folder, 'type': FileToolType.info}, // Stub for File Manager
      {'title': 'Rename', 'icon': Icons.edit, 'type': FileToolType.rename},
      {'title': 'Move', 'icon': Icons.drive_file_move, 'type': FileToolType.move},
      {'title': 'Copy', 'icon': Icons.copy, 'type': FileToolType.copy},
      {'title': 'Delete', 'icon': Icons.delete, 'type': FileToolType.delete},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Tools'),
      ),
      body: GridView.builder(
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
                if (tool['title'] == 'File Manager') {
                   context.push('${RouteConstants.home}/${RouteConstants.files}/manager');
                } else {
                   context.push(
                    '${RouteConstants.home}/${RouteConstants.files}/tool',
                    extra: tool['type'] as FileToolType,
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
    );
  }
}
