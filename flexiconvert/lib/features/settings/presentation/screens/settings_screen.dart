import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/web_constrained_box.dart';
import '../providers/settings_providers.dart';

/// Central Play Store URL — update when live
const String _playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.phynex.flexiconvert';
const String _privacyPolicyRoute = '/privacy_policy';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final notifier = ref.read(settingsNotifierProvider);

    return settingsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (settings) => Scaffold(
        appBar: const AnimatedAppBar(title: 'Settings'),
        body: WebConstrainedBox(
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.lg),
            children: [
              // ── Appearance ──────────────────────────────────
              _buildSection(context, 'Appearance', [
                _buildTileTrailing(
                  context,
                  'Theme',
                  Icons.palette_outlined,
                  trailing: Text(_friendlyTheme(settings.themeMode)),
                  onTap: () =>
                      _pickTheme(context, notifier, settings.themeMode),
                ),
                _buildTileTrailing(
                  context,
                  'Language',
                  Icons.language,
                  trailing: const Text('English'),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Only English is available currently.')),
                  ),
                ),
              ]).animate().fadeIn().slideY(begin: 0.1, end: 0),

              SizedBox(height: AppSpacing.lg),

              // ── Preferences ───────────────────────────────────
              _buildSection(context, 'Preferences', [
                _buildTileTrailing(
                  context,
                  'Download Location',
                  Icons.folder_outlined,
                  trailing: Text(
                    settings.defaultSaveDirectory.length > 15
                        ? '${settings.defaultSaveDirectory.substring(0, 14)}…'
                        : settings.defaultSaveDirectory,
                  ),
                  onTap: () => _pickDownloadLocation(
                      context, notifier, settings.defaultSaveDirectory),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.auto_delete_outlined),
                  title: const Text('Auto-delete Original',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text(
                      'Delete source file after successful conversion'),
                  value: settings.autoDeleteOriginal,
                  onChanged: (v) => notifier.updateAutoDelete(v),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle:
                      const Text('Show conversion completion notifications'),
                  value: settings.notificationsEnabled,
                  onChanged: (v) => _toggleNotifications(context, notifier, v),
                ),
              ]).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

              SizedBox(height: AppSpacing.lg),

              // ── About ─────────────────────────────────────────
              _buildSection(context, 'About', [
                _buildTileTrailing(
                  context,
                  'About FlexiConvert',
                  Icons.info_outline,
                  onTap: () => context.push(RouteConstants.about),
                ),
                _buildTileTrailing(
                  context,
                  'Privacy Policy',
                  Icons.privacy_tip_outlined,
                  onTap: () => context.push(RouteConstants.privacyPolicy),
                ),
                _buildTileTrailing(
                  context,
                  'Rate App',
                  Icons.star_outline,
                  onTap: () => _rateApp(context),
                ),
                _buildTileTrailing(
                  context,
                  'Share with Friends',
                  Icons.share_outlined,
                  onTap: _shareApp,
                ),
              ]).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _friendlyTheme(String mode) {
    switch (mode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'System';
    }
  }

  void _pickTheme(
      BuildContext context, SettingsNotifier notifier, String current) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System default'),
              trailing: current == 'system'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                notifier.updateTheme('system');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              trailing: current == 'light'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                notifier.updateTheme('light');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              trailing: current == 'dark'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                notifier.updateTheme('dark');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDownloadLocation(
      BuildContext context, SettingsNotifier notifier, String current) async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Default Downloads'),
              trailing: current == 'Default Downloads'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                notifier.updateSaveDirectory('Default Downloads');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ask Every Time'),
              trailing: current == 'Ask Every Time'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                notifier.updateSaveDirectory('Ask Every Time');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_special),
              title: const Text('Custom Folder…'),
              onTap: () async {
                Navigator.pop(context);
                await _pickCustomFolder(context, notifier);
              },
            ),
            if (!['Default Downloads', 'Ask Every Time'].contains(current))
              ListTile(
                leading: const Icon(Icons.folder, color: Colors.blue),
                title: const Text('Current custom folder:'),
                subtitle: Text(current),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomFolder(
      BuildContext context, SettingsNotifier notifier) async {
    final result = await FilePicker.getDirectoryPath();
    if (result != null) {
      await notifier.updateSaveDirectory(result);
    }
  }

  Future<void> _toggleNotifications(
      BuildContext context, SettingsNotifier notifier, bool enabled) async {
    if (enabled) {
      final status = await Permission.notification.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification permission denied.')),
          );
        }
        return;
      }
    }
    await notifier.updateNotifications(enabled);
  }

  Future<void> _rateApp(BuildContext context) async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      final uri = Uri.parse(_playStoreUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Play Store.')),
        );
      }
    }
  }

  Future<void> _shareApp() async {
    await Share.share(
        'Try FlexiConvert — the all-in-one file conversion toolkit!\n$_playStoreUrl');
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
          child: Text(
            title,
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTileTrailing(
    BuildContext context,
    String title,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: context.colorScheme.onSurfaceVariant),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
