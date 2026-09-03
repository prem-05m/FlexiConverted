import 'package:firebase_auth/firebase_auth.dart' show User;

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<User?> loginWithEmail(String email, String password);
  Future<User?> signUpWithEmail(String name, String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  
  Future<User?> loginWithGoogle();
  Future<User?> loginWithApple();
  Future<User?> loginAsGuest();
  
  Future<void> logout();
  Future<void> deleteAccount();
}
