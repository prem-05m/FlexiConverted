import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_spacing.dart';

class ProgressDialog extends StatelessWidget {
  final double progress;
  final String message;
  final VoidCallback? onCancel;

  const ProgressDialog({
    super.key,
    required this.progress,
    required this.message,
    this.onCancel,
  });

  static void show(BuildContext context, {double progress = 0.0, String message = 'Processing...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(progress: progress, message: message),
    );
  }
  
  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppBorders.lg),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: AppSpacing.xl),
            Text(
              message,
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: AppSpacing.sm),
            Text('${(progress * 100).toInt()}%', style: context.textTheme.bodySmall),
            if (onCancel != null) ...[
              SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: () {
                  onCancel!();
                  Navigator.pop(context);
                },
                child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
