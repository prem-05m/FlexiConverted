import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/models/user_profile_model.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final userProfileProvider = StreamProvider<UserProfileModel?>((ref) async* {
  yield* db.watchUserProfile(1);
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.value;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.pushNamed(RouteConstants.login),
            child: const Text('Login to view profile'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.pushNamed(
                '${RouteConstants.home}/edit_profile'), // Add this route
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            _buildAvatar(user.photoURL, profile?.customAvatarPath,
                profile?.builtInAvatarIndex, theme),
            SizedBox(height: 16.h),
            Text(
              user.displayName ?? 'Flexi User',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            Text(user.email ?? 'No email', style: theme.textTheme.bodyMedium),
            SizedBox(height: 24.h),
            _buildStatsCard(theme, profile),
            SizedBox(height: 24.h),
            _buildSettingsList(context, ref,
                user.providerData.any((info) => info.providerId == 'password')),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? photoUrl, String? customPath, int? builtinIndex,
      ThemeData theme) {
    ImageProvider? imageProvider;
    if (customPath != null && !kIsWeb) {
      imageProvider = FileImage(File(customPath));
    } else if (photoUrl != null) {
      imageProvider = NetworkImage(photoUrl);
    }

    return CircleAvatar(
      radius: 50.r,
      backgroundColor: theme.colorScheme.primaryContainer,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Icon(Icons.person,
              size: 50.r, color: theme.colorScheme.onPrimaryContainer)
          : null,
    );
  }

  Widget _buildStatsCard(ThemeData theme, UserProfileModel? profile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
                'Conversions', '${profile?.totalConversions ?? 0}', theme),
            _buildStatItem(
                'Saved', _formatBytes(profile?.storageSavedBytes ?? 0), theme),
            _buildStatItem('Files', '${profile?.totalConversions ?? 0}',
                theme), // Assuming 1 file per conversion for now
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (bytes > 0) ? (bytes.toString().length - 1) ~/ 3 : 0;
    return '${(bytes / (1024 * i > 0 ? 1024 * i : 1)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  Widget _buildSettingsList(
      BuildContext context, WidgetRef ref, bool isPasswordAuth) {
    return Column(
      children: [
        if (isPasswordAuth)
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {}, // TODO
          ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title:
              const Text('Delete Account', style: TextStyle(color: Colors.red)),
          onTap: () => _confirmDeleteAccount(context, ref),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authRepositoryProvider).logout();
              ref.read(biometricUnlockProvider.notifier).setUnlocked(false);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text(
            'This will permanently delete your account and cannot be undone. Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(authRepositoryProvider).deleteAccount();
                ref.read(biometricUnlockProvider.notifier).setUnlocked(false);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Failed to delete account. You may need to log in again first.')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
