import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of user auth changes
  Stream<User?> get user => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);

        // Create user profile in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Success: Sign out so they can log in manually
        await _auth.signOut();
      }

      return result;
    } on FirebaseAuthException catch (e) {
      // If profile creation failed, the user is already created in Auth.
      // We should sign them out so the app doesn't jump to Home with a broken profile.
      await _auth.signOut();

      developer.log(
        'Firebase Auth Sign Up Error',
        error: e.message,
        name: 'AuthService',
      );
      rethrow;
    } catch (e) {
      // Sign out on any other error (like Firestore permission denied)
      await _auth.signOut();

      developer.log('Sign Up Error', error: e.toString(), name: 'AuthService');
      rethrow;
    }
  }

  // Login with email and password
  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Firebase Auth Login Error',
        error: e.message,
        name: 'AuthService',
      );
      rethrow;
    } catch (e) {
      developer.log('Login Error', error: e.toString(), name: 'AuthService');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      developer.log('Logout Error', error: e.toString(), name: 'AuthService');
      rethrow;
    }
  }

  // Reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      developer.log(
        'Reset Password Error',
        error: e.toString(),
        name: 'AuthService',
      );
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
