import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _google = GoogleSignIn.instance;

  @override
  Stream<UserEntity?> get authStateChanges => _auth.authStateChanges().asyncMap((user) async {
    if (user == null) return null;
    return _fetchUser(user.uid);
  });

  Future<UserModel?> _fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<UserEntity> loginWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return (await _fetchUser(cred.user!.uid))!;
  }

  @override
  Future<UserEntity> registerWithEmail(String email, String password, String fullName) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = UserModel(
      uid: cred.user!.uid,
      email: email,
      fullName: fullName,
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(user.uid).set(user.toFirestore());
    await cred.user!.updateDisplayName(fullName);
    return user;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    await _google.initialize();
    final googleUser = await _google.authenticate();
    final auth = googleUser.authentication;
    final cred = GoogleAuthProvider.credential(
      idToken: auth.idToken,
    );
    final result = await _auth.signInWithCredential(cred);
    final uid = result.user!.uid;
    final existing = await _fetchUser(uid);
    if (existing != null) return existing;
    final user = UserModel(
      uid: uid,
      email: result.user!.email ?? '',
      fullName: result.user!.displayName ?? '',
      photoUrl: result.user!.photoURL,
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(uid).set(user.toFirestore());
    return user;
  }

  @override
  Future<void> logout() async {
    await _google.disconnect();
    await _auth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _fetchUser(user.uid);
  }

  @override
  Future<void> updateProfile({String? fullName, String? photoUrl, String? workWifiSsid}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final updates = <String, dynamic>{};
    if (fullName != null) updates['fullName'] = fullName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (workWifiSsid != null) updates['workWifiSsid'] = workWifiSsid;
    await _db.collection('users').doc(uid).update(updates);
  }
}
