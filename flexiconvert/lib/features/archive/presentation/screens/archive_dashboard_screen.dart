import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/web_constrained_box.dart';
import '../../domain/models/archive_task_model.dart';

class ArchiveDashboardScreen extends StatelessWidget {
  const ArchiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      {'title': 'Compress (ZIP)', 'icon': Icons.folder_zip, 'type': ArchiveToolType.compress},
      {'title': 'Extract', 'icon': Icons.unarchive, 'type': ArchiveToolType.extract},
      {'title': 'Archive Viewer', 'icon': Icons.manage_search, 'type': ArchiveToolType.previewArchive},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive Tools'),
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
                context.push(
                  '${RouteConstants.home}/${RouteConstants.archive}/tool',
                  extra: tool['type'] as ArchiveToolType,
                );
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
