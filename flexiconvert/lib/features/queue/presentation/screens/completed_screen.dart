import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../../pdf/presentation/providers/pdf_task_provider.dart';

class CompletedScreen extends ConsumerWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfTaskProvider);
    final outputPath = state.outputPath;

    // Read the "from" route from query params so we can navigate back to the tool
    final fromRoute = GoRouterState.of(context).uri.queryParameters['from'];

    return Scaffold(
      appBar: const AnimatedAppBar(title: 'Conversion Complete', centerTitle: true),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.green)
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.easeOutBack),
              SizedBox(height: AppSpacing.xl),
              const Text(
                'Success!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ).animate().fadeIn(delay: 200.ms),
              SizedBox(height: AppSpacing.sm),
              const Text(
                'Your file has been successfully converted and saved.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ).animate().fadeIn(delay: 300.ms),
              SizedBox(height: AppSpacing.massive),
              if (outputPath != null) ...[
                CustomButton(
                  text: 'View File',
                  icon: Icons.folder_open,
                  onPressed: () => OpenFilex.open(outputPath),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                SizedBox(height: AppSpacing.md),
                CustomButton(
                  text: 'Share File',
                  icon: Icons.share,
                  onPressed: () => Share.shareXFiles([XFile(outputPath)], text: 'Check out this converted file!'),
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2, end: 0),
              ],
              SizedBox(height: AppSpacing.md),
              if (fromRoute != null)
                CustomButton(
                  text: 'Convert Another',
                  icon: Icons.refresh,
                  onPressed: () {
                    context.go(fromRoute);
                  },
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
              SizedBox(height: AppSpacing.md),
              CustomButton(
                text: 'Back to Home',
                isOutlined: true,
                onPressed: () {
                  context.go(RouteConstants.home);
                },
              ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
