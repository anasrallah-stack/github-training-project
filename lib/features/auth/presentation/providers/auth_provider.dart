import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl());

final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserEntity?>>((ref) {
  return CurrentUserNotifier(ref.watch(authRepositoryProvider));
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repo;
  CurrentUserNotifier(this._repo) : super(const AsyncValue.loading()) {
    _init();

  }
  Future<void> _saveUserToPrefs(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.uid);
    await prefs.setString('work_ssid', user.workWifiSsid ?? '');
  }
  Future<void> _init() async {
    try {
      final user = await _repo.getCurrentUser();
      state = AsyncValue.data(user);
      if (user != null) await _saveUserToPrefs(user); // ← أضف
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.loginWithEmail(email, password);
      state = AsyncValue.data(user);
      await _saveUserToPrefs(user); // ← أضف
      return true;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.registerWithEmail(email, password, fullName);
      state = AsyncValue.data(user);
      await _saveUserToPrefs(user); // ← أضف
      return true;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.signInWithGoogle();
      state = AsyncValue.data(user);
      await _saveUserToPrefs(user); // ← أضف
      return true;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }

  Future<void> updateProfile({String? fullName, String? photoUrl, String? workWifiSsid}) async {
    await _repo.updateProfile(fullName: fullName, photoUrl: photoUrl, workWifiSsid: workWifiSsid);
    final current = state.value;
    if (current != null) {
      final updated = current.copyWith(
        fullName: fullName,
        photoUrl: photoUrl,
        workWifiSsid: workWifiSsid,
      );
      state = AsyncValue.data(updated);
      await _saveUserToPrefs(updated); // ← أضف — مهم لما يغير شبكة العمل
    }
  }
  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
  }
}
