import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/glass_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AnimatedAppBar(title: 'About'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: AppSpacing.xxl),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.change_circle_rounded, size: 60, color: Colors.white),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            SizedBox(height: AppSpacing.lg),
            Text(
              AppConstants.appName,
              style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 100.ms),
            Text(
              'Version ${AppConstants.appVersion}',
              style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ).animate().fadeIn(delay: 150.ms),
            SizedBox(height: AppSpacing.md),
            Text(
              'All-in-One Utility Toolkit',
              style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: AppSpacing.xxl),

            // Supported Tools
            GlassCard(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Supported Tools', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      'PDF Tools', 'Image Tools', 'Video Tools', 'Audio Tools',
                      'Document Tools', 'Archive Tools', 'QR Code Tools', 'File Manager',
                    ].map((t) => Chip(label: Text(t))).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),

            SizedBox(height: AppSpacing.lg),
            const Divider(),
            SizedBox(height: AppSpacing.lg),

            _buildInfoRow(context, 'Developer', 'Phynex').animate().fadeIn(delay: 350.ms),
            SizedBox(height: AppSpacing.md),
            _buildInfoRow(context, 'Contact', 'support@phynex.com', onTap: () {
              launchUrl(Uri.parse('mailto:support@phynex.com'));
            }).animate().fadeIn(delay: 400.ms),
            SizedBox(height: AppSpacing.md),
            _buildInfoRow(context, 'Package ID', 'com.phynex.flexiconvert').animate().fadeIn(delay: 450.ms),

            SizedBox(height: AppSpacing.xxl),
            const Text('Made with Flutter ❤️')
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .shimmer(duration: 2.seconds),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: context.textTheme.titleSmall),
            Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                color: onTap != null ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
