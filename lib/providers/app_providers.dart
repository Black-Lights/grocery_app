import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firestore_service.dart';

// Provides an instance of FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Streams the authentication state (logged in or not)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Firestore Service Provider
final firestoreProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Authentication repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirestoreService _firestoreService;

  AuthRepository(this._auth, this._firestoreService);

  void setFirebaseLocale(String locale) {
    _auth.setLanguageCode(locale);
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Initialize user profile in Firestore
      if (credential.user != null) {
        await _firestoreService.createUserProfile(
          userId: credential.user!.uid,
          data: {
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred during sign up';
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred during sign in';
    }
  }

  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // Initialize user profile in Firestore if it's a new user
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _firestoreService.createUserProfile(
          userId: userCredential.user!.uid,
          data: {
            'email': userCredential.user!.email,
            'displayName': userCredential.user!.displayName,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
      }

      return userCredential;
    } catch (e) {
      throw 'Google Sign-In failed: $e';
    }
  }
}
