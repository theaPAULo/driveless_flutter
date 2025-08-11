// lib/providers/auth_provider.dart
//
// Authentication Provider using Provider pattern
// Handles Firebase authentication state, Google Sign-In, and Apple Sign-In

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';

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
  bool get isAppleSignInAvailable => Platform.isIOS;

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

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      await _auth.signInWithCredential(credential);
      
      debugPrint('🌐 Google Sign-In successful');
      
    } catch (e) {
      _errorMessage = 'Google Sign-In failed: ${e.toString()}';
      debugPrint('❌ Google Sign-In error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Apple (iOS only)
  Future<void> signInWithApple() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Check if Apple Sign-In is available
      if (!Platform.isIOS) {
        throw Exception('Apple Sign-In is only available on iOS');
      }

      // Check Apple Sign-In availability
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception('Apple Sign-In is not available on this device');
      }

      // Request Apple Sign-In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with Apple credential
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      
      // Update display name if available from Apple but not in Firebase
      if (userCredential.user != null && 
          (userCredential.user!.displayName == null || userCredential.user!.displayName!.isEmpty)) {
        
        // Construct display name from Apple Sign-In data
        String? displayName;
        if (appleCredential.givenName != null || appleCredential.familyName != null) {
          displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
          if (displayName.isNotEmpty) {
            await userCredential.user!.updateDisplayName(displayName);
          }
        }
      }
      
      debugPrint('🍎 Apple Sign-In successful');
      
    } catch (e) {
      _errorMessage = 'Apple Sign-In failed: ${e.toString()}';
      debugPrint('❌ Apple Sign-In error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Sign out from all providers
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      debugPrint('👋 User signed out');
      
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