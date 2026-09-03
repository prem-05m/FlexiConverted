import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_spacing.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool useLottie;

  const LoadingWidget({
    super.key,
    this.message,
    this.useLottie = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (useLottie)
            // Replace with actual lottie asset later
            const CircularProgressIndicator()
          else
            const CircularProgressIndicator(),
            
          if (message != null) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ]
        ],
      ),
    );
  }
}
