import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/custom_button.dart';

class FilePickerWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool allowMultiple;
  final List<String> allowedExtensions;
  final void Function(List<String> paths) onFilesSelected;

  const FilePickerWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onFilesSelected,
    this.allowMultiple = false,
    this.allowedExtensions = const ['pdf'],
  });

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
    );

    if (result.isNotEmpty) {
      final validPaths = result.map((e) => e.path).whereType<String>().toList();
      onFilesSelected(validPaths);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pickFiles,
      borderRadius: AppBorders.lg,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer.withValues(alpha: 0.2),
          borderRadius: AppBorders.lg,
          border: Border.all(
            color: context.colorScheme.primary.withValues(alpha: 0.5),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 64, color: context.colorScheme.primary),
            SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            CustomButton(
              text: 'Select Files',
              onPressed: _pickFiles,
            ),
          ],
        ),
      ),
    );
  }
}
