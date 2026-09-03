import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/snackbar_service.dart';
import '../providers/auth_providers.dart';

class BiometricUnlockScreen extends ConsumerStatefulWidget {
  const BiometricUnlockScreen({super.key});

  @override
  ConsumerState<BiometricUnlockScreen> createState() =>
      _BiometricUnlockScreenState();
}

class _BiometricUnlockScreenState extends ConsumerState<BiometricUnlockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptBiometric();
    });
  }

  Future<void> _promptBiometric() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      final biometricService = ref.read(biometricServiceProvider);
      final didAuthenticate = await biometricService.authenticate();

      if (didAuthenticate && mounted) {
        ref.read(biometricUnlockProvider.notifier).setUnlocked(true);
        // Router guard will automatically redirect to home now since it's unlocked
      } else if (mounted) {
        SnackbarService.showError('Authentication failed or cancelled');
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  Future<void> _logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    // Router guard redirects to login
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fingerprint,
                    size: 80.w, color: theme.colorScheme.primary),
                SizedBox(height: 24.h),
                Text(
                  'Welcome back${user?.displayName != null ? ', ${user!.displayName}' : ''}',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Unlock FlexiConvert',
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: 48.h),
                ElevatedButton.icon(
                  onPressed: _isAuthenticating ? null : _promptBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock with Biometrics'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 24.h),
                TextButton(
                  onPressed: _isAuthenticating ? null : _logout,
                  child: const Text('Use Password Instead (Log Out)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
