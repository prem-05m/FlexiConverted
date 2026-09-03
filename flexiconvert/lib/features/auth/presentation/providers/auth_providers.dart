import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/biometric_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final isBiometricEnabledProvider = FutureProvider<bool>((ref) async {
  return ref.watch(biometricServiceProvider).isBiometricEnabled();
});

// A provider to track if the app has been unlocked via biometrics for the current session.
// This is used by the router to determine if we should show the unlock screen.
class BiometricUnlockNotifier extends StateNotifier<bool> {
  BiometricUnlockNotifier() : super(false);

  void setUnlocked(bool unlocked) {
    state = unlocked;
  }
}

final biometricUnlockProvider = StateNotifierProvider<BiometricUnlockNotifier, bool>((ref) {
  return BiometricUnlockNotifier();
});
