import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity> loginWithEmail(String email, String password);
  Future<UserEntity> registerWithEmail(String email, String password, String fullName);
  Future<UserEntity> signInWithGoogle();
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<void> updateProfile({String? fullName, String? photoUrl, String? workWifiSsid});
}
