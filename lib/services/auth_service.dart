import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).asData?.value;
});

final appUserProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
});

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user!.updateDisplayName(fullName);

    final user = AppUser(
      uid: cred.user!.uid,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      totalPosts: 0,
      totalAdoptions: 0,
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(cred.user!.uid).set(user.toFirestore());
    return cred;
  }

  Future<UserCredential> login(
          {required String email, required String password}) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> logout() => _auth.signOut();

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> updateProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? bio,
    String? location,
    String? photoUrl,
  }) async {
    final map = <String, dynamic>{};
    if (fullName != null) {
      map['fullName'] = fullName;
      await _auth.currentUser?.updateDisplayName(fullName);
    }
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    if (bio != null) map['bio'] = bio;
    if (location != null) map['location'] = location;
    if (photoUrl != null) {
      map['photoUrl'] = photoUrl;
      await _auth.currentUser?.updatePhotoURL(photoUrl);
    }
    await _db.collection('users').doc(uid).update(map);
  }

  Future<void> saveFcmToken(String uid, String token) async {
    await _db.collection('users').doc(uid).update({'fcmToken': token});
  }
}
