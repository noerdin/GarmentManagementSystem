import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get user data from Firestore
  Future<UserModel> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection('users').doc(uid).get();

      print('cek log doc ${doc.exists} ${doc.data()}');

      // Pastikan data yang diterima valid
      if (doc.exists) {
        return UserModel.fromFirestore(doc); // Convert data ke UserModel
      } else {
        throw FirebaseException(
          plugin: 'Firestore',
          message: 'User not found',
          stackTrace: StackTrace.current,
        );
      }
    } catch (e) {
      throw FirebaseException(
        plugin: 'Firestore',
        message: 'Failed to get user data: $e',
        stackTrace: StackTrace.current,
      );
    }
  }

  // Check if user is active
  Future<bool> isUserActive(String uid) async {
    print('cek log isUserActive');
    try {
      UserModel user = await getUserData(uid);
      print('cek log ${user.status}');
      return user.isActive;
    } catch (e) {
      print('cek log catch ${e.toString()}');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Error handling
  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'operation-not-allowed':
          return 'This operation is not allowed.';
        case 'requires-recent-login':
          return 'Please log in again to perform this operation.';
        default:
          return 'Authentication error: ${e.message}';
      }
    }
    return 'An error occurred. Please try again.';
  }
}
