// lib/providers/auth_provider.dart
//
// Authentication Provider using Provider pattern
// Handles Firebase authentication state, Google Sign-In, and Apple Sign-In

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';

// 🍎 Use our stub implementation for now (Apple Sign In temporarily disabled)
import '../auth_stubs.dart';

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

  /// Check if Apple Sign-In is available (iOS only)
  bool get isAppleSignInAvailable {
    if (kIsWeb) return false;
    // For now, return false since we're using stubs
    // TODO: Re-enable when we add iOS-specific Apple Sign In
    return false; // Platform.isIOS && !kIsWeb;
  }

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

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
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
        // User canceled the sign-in
        _setLoading(false);
        return;
      }

      // Get Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
      await _auth.signInWithCredential(credential);
      
      debugPrint('✅ Google Sign-In successful');

    } catch (e) {
      _errorMessage = 'Google Sign-In failed: ${e.toString()}';
      debugPrint('❌ Google Sign-In error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Apple (currently disabled - using stub)
  Future<void> signInWithApple() async {
    _errorMessage = 'Apple Sign-In temporarily disabled during Android compatibility fixes';
    debugPrint('ℹ️ Apple Sign-In called but currently disabled');
    
    // TODO: Re-implement with iOS-specific package inclusion
    return;
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _setLoading(true);
      
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Firebase
      await _auth.signOut();
      
      debugPrint('✅ Sign out successful');

    } catch (e) {
      _errorMessage = 'Sign out failed: ${e.toString()}';
      debugPrint('❌ Sign out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}