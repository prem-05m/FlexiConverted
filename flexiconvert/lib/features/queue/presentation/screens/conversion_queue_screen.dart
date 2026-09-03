import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/glass_card.dart';

class ConversionQueueScreen extends StatelessWidget {
  const ConversionQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AnimatedAppBar(title: 'Conversion Queue'),
      body: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.lg),
        itemCount: 2,
        separatorBuilder: (context, index) => SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          return GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Image to PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () {}),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: 0.6,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: AppSpacing.sm),
                const Text('Processing 3 of 5 images... (60%)', style: TextStyle(fontSize: 12)),
              ],
            ),
          ).animate().fadeIn().slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }
}
