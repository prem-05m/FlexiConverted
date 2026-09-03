import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/web_constrained_box.dart';
import '../../domain/models/document_task_model.dart';
import '../widgets/document_tool_card.dart';

class DocumentDashboardScreen extends StatelessWidget {
  const DocumentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolInfo(DocumentToolType.jpgToPdf, 'JPG to PDF', 'Convert JPG/PNG to PDF', Icons.image, Colors.amber),
      _ToolInfo(DocumentToolType.pdfToJpg, 'PDF to JPG', 'Extract pages to JPG/PNG', Icons.photo_library, Colors.amberAccent),
      _ToolInfo(DocumentToolType.wordToPdf, 'WORD to PDF', 'Convert DOC/DOCX to PDF', Icons.description, Colors.blue),
      _ToolInfo(DocumentToolType.pdfToWord, 'PDF to WORD', 'Convert PDF to DOC/DOCX', Icons.picture_as_pdf, Colors.blueAccent),
      _ToolInfo(DocumentToolType.pptToPdf, 'POWERPOINT to PDF', 'Convert PPT/PPTX to PDF', Icons.slideshow, Colors.orange),
      _ToolInfo(DocumentToolType.pdfToPpt, 'PDF to POWERPOINT', 'Convert PDF to PPT/PPTX', Icons.picture_as_pdf, Colors.deepOrange),
      _ToolInfo(DocumentToolType.excelToPdf, 'EXCEL to PDF', 'Convert XLS/XLSX to PDF', Icons.table_chart, Colors.green),
      _ToolInfo(DocumentToolType.pdfToExcel, 'PDF to EXCEL', 'Convert PDF to XLS/XLSX', Icons.picture_as_pdf, Colors.lightGreen),
      _ToolInfo(DocumentToolType.htmlToPdf, 'HTML to PDF', 'Convert Web pages to PDF', Icons.html, Colors.teal),
      _ToolInfo(DocumentToolType.pdfToPdfA, 'PDF to PDF/A', 'Convert PDF to PDF/A', Icons.picture_as_pdf, Colors.blueGrey),
    ];

    return Scaffold(
      appBar: const AnimatedAppBar(title: 'Convert PDF'),
      body: WebConstrainedBox(
        maxWidth: 800,
        child: GridView.builder(
        padding: EdgeInsets.all(AppSpacing.lg),
        itemCount: tools.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final tool = tools[index];
          return DocumentToolCard(
            toolType: tool.type,
            title: tool.title,
            description: tool.desc,
            icon: tool.icon,
            color: tool.color,
            onTap: () {
              final comingSoonTools = [
                DocumentToolType.jpgToPdf, 
                DocumentToolType.pdfToJpg, 
                DocumentToolType.pdfToPdfA
              ];
              if (comingSoonTools.contains(tool.type)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${tool.title} is coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                context.go('${RouteConstants.home}/${RouteConstants.document}/${tool.type.name}');
              }
            },
          ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
        },
      ),
      ),
    );
  }
}

class _ToolInfo {
  final DocumentToolType type;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  _ToolInfo(this.type, this.title, this.desc, this.icon, this.color);
}
