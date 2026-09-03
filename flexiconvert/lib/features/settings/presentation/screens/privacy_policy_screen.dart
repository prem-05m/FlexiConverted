import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AnimatedAppBar(title: 'Privacy Policy'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(),
            const SizedBox(height: 8),
            Text(
              'Last updated: August 2026',
              style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),
            ..._sections.map((s) => _PolicySection(title: s.$1, body: s.$2)),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(body, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

const List<(String, String)> _sections = [
  (
    'Overview',
    'FlexiConvert ("we", "our", "the app") is a file conversion and utility application developed by Phynex. This Privacy Policy explains how we handle information when you use FlexiConvert.',
  ),
  (
    'File Processing',
    'All file conversions are performed entirely on your device. Your files are NOT uploaded to any server. We do not have access to the content of any files you convert. Converted files are saved to the location you choose on your device.',
  ),
  (
    'Authentication',
    'FlexiConvert uses Firebase Authentication for account management. When you sign in with email/password, Google, or Apple, your authentication token is stored securely on your device. We store your display name and email address to personalize your experience. Passwords are never stored by FlexiConvert; they are managed exclusively by Firebase Authentication.',
  ),
  (
    'Local Storage',
    'Conversion history, recent files, and favorites are stored locally on your device using an on-device database (Isar). This data does not leave your device. Sensitive settings (such as authentication state) are stored using your device\'s secure storage. Non-sensitive preferences (theme, notifications) are stored in standard app preferences.',
  ),
  (
    'Biometric Authentication',
    'FlexiConvert optionally supports biometric authentication (fingerprint, face ID). We do NOT store any biometric data. Authentication is performed entirely by your device\'s operating system. We only store a flag indicating whether you have enabled this feature.',
  ),
  (
    'Permissions',
    'FlexiConvert may request the following permissions:\n• Storage: To read your files for conversion and save converted outputs.\n• Notifications: To show conversion completion notifications (optional).\n• Internet: For Firebase Authentication and Google Sign-In.\n• Biometric: For biometric unlock (optional).',
  ),
  (
    'Analytics & Advertising',
    'FlexiConvert does not include any third-party advertising SDKs. We do not currently collect analytics data.',
  ),
  (
    'Data Retention & Deletion',
    'Local data (history, favorites, profile) is stored on your device and can be cleared by uninstalling the app or using the account deletion feature. To delete your Firebase account and associated data, use the "Delete Account" option in your Profile screen.',
  ),
  (
    'Children\'s Privacy',
    'FlexiConvert is not directed at children under 13. We do not knowingly collect personal information from children.',
  ),
  (
    'Changes to This Policy',
    'We may update this Privacy Policy from time to time. Changes will be reflected in the app with an updated "last updated" date.',
  ),
  (
    'Contact',
    'If you have any questions about this Privacy Policy, please contact:\nsupport@phynex.com',
  ),
];
