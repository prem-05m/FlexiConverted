import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/web_constrained_box.dart';
import '../../domain/models/pdf_task_model.dart';
import '../widgets/pdf_tool_card.dart';

class PdfDashboardScreen extends StatefulWidget {
  const PdfDashboardScreen({super.key});

  @override
  State<PdfDashboardScreen> createState() => _PdfDashboardScreenState();
}

class _PdfDashboardScreenState extends State<PdfDashboardScreen> {
  final Map<String, bool> _expanded = {
    'ORGANIZE PDF': true,
    'OPTIMIZE PDF': true,
    'EDIT PDF': true,
    'PDF SECURITY': true,
    'PDF INTELLIGENCE': true,
  };

  @override
  Widget build(BuildContext context) {
    final Map<String, List<_ToolInfo>> categories = {
      'ORGANIZE PDF': [
        _ToolInfo(PdfToolType.mergePdf, 'Merge PDF',
            'Combine multiple PDFs into one', Icons.merge_type, Colors.orange),
        _ToolInfo(PdfToolType.splitPdf, 'Split PDF',
            'Extract pages or split by range', Icons.call_split, Colors.red),
        _ToolInfo(
            PdfToolType.deletePages,
            'Remove Pages',
            'Remove unwanted pages from PDF',
            Icons.delete_outline,
            Colors.pink),
        _ToolInfo(
            PdfToolType.extractPages,
            'Extract Pages',
            'Extract specific pages to new PDF',
            Icons.file_download,
            Colors.cyan),
        _ToolInfo(PdfToolType.reorderPages, 'Organize PDF',
            'Change page order across PDFs', Icons.reorder, Colors.indigo),
        _ToolInfo(PdfToolType.scanToPdf, 'Scan to PDF', 'Scan documents to PDF',
            Icons.document_scanner, Colors.teal),
      ],
      'OPTIMIZE PDF': [
        _ToolInfo(PdfToolType.compressPdf, 'Compress PDF',
            'Reduce PDF file size', Icons.compress, Colors.purple),
        _ToolInfo(PdfToolType.repairPdf, 'Repair PDF',
            'Repair corrupted PDF files', Icons.build, Colors.green),
        _ToolInfo(
            PdfToolType.ocrPdf,
            'OCR PDF',
            'Extract text from scanned PDFs',
            Icons.document_scanner_outlined,
            Colors.deepOrange),
      ],
      'EDIT PDF': [
        _ToolInfo(PdfToolType.rotatePdf, 'Rotate PDF', 'Rotate pages in PDF',
            Icons.rotate_right, Colors.teal),
        _ToolInfo(PdfToolType.addPageNumbers, 'Add Page Numbers',
            'Add numbers to pages', Icons.format_list_numbered, Colors.blue),
        _ToolInfo(
            PdfToolType.watermarkPdf,
            'Add Watermark',
            'Add text or image watermark',
            Icons.branding_watermark,
            Colors.brown),
        _ToolInfo(PdfToolType.cropPdf, 'Crop PDF', 'Crop PDF margins',
            Icons.crop, Colors.deepPurple),
        _ToolInfo(PdfToolType.editPdf, 'Edit PDF', 'Edit text and images',
            Icons.edit_document, Colors.blueGrey),
        _ToolInfo(PdfToolType.pdfForms, 'PDF Forms', 'Fill and edit PDF forms',
            Icons.text_snippet, Colors.cyan),
      ],
      'PDF SECURITY': [
        _ToolInfo(PdfToolType.unlockPdf, 'Unlock PDF', 'Remove password',
            Icons.lock_open, Colors.greenAccent),
        _ToolInfo(PdfToolType.encryptPdf, 'Protect PDF',
            'Add password protection', Icons.lock, Colors.redAccent),
        _ToolInfo(PdfToolType.addSignature, 'Sign PDF',
            'Sign your PDF document', Icons.draw, Colors.deepPurple),
        _ToolInfo(PdfToolType.redactPdf, 'Redact PDF', 'Remove sensitive info',
            Icons.cleaning_services, Colors.grey),
        _ToolInfo(PdfToolType.comparePdf, 'Compare PDF', 'Compare two PDFs',
            Icons.compare, Colors.indigo),
      ],
      'PDF INTELLIGENCE': [
        _ToolInfo(PdfToolType.aiSummarizer, 'AI Summarizer',
            'Summarize PDF with AI', Icons.auto_awesome, Colors.purpleAccent),
        _ToolInfo(PdfToolType.translatePdf, 'Translate PDF',
            'Translate PDF text', Icons.translate, Colors.blue),
        _ToolInfo(PdfToolType.pdfToMarkdown, 'PDF to Markdown',
            'Convert PDF to MD', Icons.text_format, Colors.teal),
      ],
    };

    // All tools that show "Coming Soon"
    const comingSoonTools = {
      PdfToolType.extractPages,
      PdfToolType.repairPdf,
      PdfToolType.pdfForms,
      PdfToolType.comparePdf,
      PdfToolType.translatePdf,
    };

    return Scaffold(
      appBar: const AnimatedAppBar(title: 'PDF Tools'),
      body: WebConstrainedBox(
        maxWidth: 800,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.lg),
          children: categories.entries.map((entry) {
            final categoryName = entry.key;
            final tools = entry.value;
            final isExpanded = _expanded[categoryName] ?? true;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () =>
                      setState(() => _expanded[categoryName] = !isExpanded),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 4.0),
                    child: Row(
                      children: [
                        Text(
                          categoryName,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                    letterSpacing: 1.2,
                                  ),
                        ),
                        const Spacer(),
                        AnimatedRotation(
                          turns: isExpanded ? 0 : -0.5,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(Icons.keyboard_arrow_down,
                              color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: tools.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final tool = tools[index];
                      final isSoon = comingSoonTools.contains(tool.type);
                      return PdfToolCard(
                        toolType: tool.type,
                        title: tool.title,
                        description: tool.desc,
                        icon: tool.icon,
                        color: tool.color,
                        isComingSoon: isSoon,
                        onTap: () {
                          if (isSoon) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${tool.title} — Coming Soon!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.grey[700],
                              ),
                            );
                          } else {
                            context.go(
                                '${RouteConstants.home}/${RouteConstants.pdf}/${tool.type.name}');
                          }
                        },
                      )
                          .animate()
                          .fadeIn(delay: (index * 20).ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                  ),
                  secondChild: const SizedBox.shrink(),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 250),
                ),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ToolInfo {
  final PdfToolType type;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  _ToolInfo(this.type, this.title, this.desc, this.icon, this.color);
}
