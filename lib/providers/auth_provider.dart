// lib/providers/auth_provider.dart
//
// Authentication Provider using Provider pattern
// Handles Firebase authentication state and Google Sign-In

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

/// Authentication Provider class - manages auth state for the app
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Current authenticated user
  DriveLessUser? _user;
  
  /// Loading state
  bool _isLoading = false;
  
  /// Error message
  String? _errorMessage;

  // Getters
  DriveLessUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _user != null;
  String? get errorMessage => _errorMessage;
  
  /// Getter for user name - this fixes the profile screen error
  String get name => _user?.displayName ?? _user?.email ?? 'User';

  /// Constructor - sets up auth state listener
  AuthProvider() {
    // Listen for auth state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Handle Firebase auth state changes
  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser != null) {
      _user = DriveLessUser.fromFirebaseUser(firebaseUser);
      debugPrint('✅ User signed in: ${_user!.email}');
    } else {
      _user = null;
      debugPrint('❌ User signed out');
    }
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        _setLoading(false);
        return;
      }

      // Get Google authentication credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      await _auth.signInWithCredential(credential);
      
      debugPrint('🌐 Google Sign-In successful');
      
    } catch (e) {
      _errorMessage = 'Sign-in failed: ${e.toString()}';
      debugPrint('❌ Google Sign-In error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Firebase
      await _auth.signOut();
      
      debugPrint('🚪 User signed out');
      
    } catch (e) {
      _errorMessage = 'Sign-out failed: ${e.toString()}';
      debugPrint('❌ Sign-out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      _setLoading(true);
      
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        debugPrint('🗑️ Account deleted');
      }
      
    } catch (e) {
      _errorMessage = 'Account deletion failed: ${e.toString()}';
      debugPrint('❌ Account deletion error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }



  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}