// lib/providers/auth_provider.dart
//
// Updated AuthProvider - Platform-Safe Apple Sign In
// ✅ iOS: Apple Sign In available 
// ✅ Android: Apple Sign In throws proper error
// ✅ PRESERVES: All existing functionality, error handling, state management

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../services/biometric_auth_service.dart';
import '../services/error_tracking_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final BiometricAuthService _biometricAuth = BiometricAuthService();
  final ErrorTrackingService _errorTracker = ErrorTrackingService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _biometricPromptShown = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _user != null;
  BiometricAuthService get biometricAuth => _biometricAuth;
  bool get biometricPromptShown => _biometricPromptShown;

  AuthProvider() {
    // Initialize biometric authentication
    _initializeBiometric();
    
    // Listen to authentication state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  /// Initialize biometric authentication service
  Future<void> _initializeBiometric() async {
    await _biometricAuth.initialize();
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

  /// Sign in with Google (AVAILABLE ON BOTH PLATFORMS)
  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Trigger the authentication flow
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
      
      // Track Google Sign-In errors
      _errorTracker.trackError(
        errorType: ErrorType.authentication,
        errorMessage: 'Google Sign-In failed: ${e.toString()}',
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.medium,
        location: 'auth_provider.signInWithGoogle',
        additionalData: {
          'platform': Platform.operatingSystem,
          'errorType': e.runtimeType.toString(),
        },
      );
      
      debugPrint('❌ Google Sign-In error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Apple (iOS ONLY - PLATFORM-SAFE)
  Future<void> signInWithApple() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // ✅ PLATFORM CHECK: Only allow on iOS
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
      
      // Track Apple Sign-In errors
      _errorTracker.trackError(
        errorType: ErrorType.authentication,
        errorMessage: 'Apple Sign-In failed: ${e.toString()}',
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.medium,
        location: 'auth_provider.signInWithApple',
        additionalData: {
          'platform': Platform.operatingSystem,
          'errorType': e.runtimeType.toString(),
          'isIOS': Platform.isIOS,
        },
      );
      
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

      // Sign out from Firebase
      await _auth.signOut();
      
      // Sign out from Google
      await _googleSignIn.signOut();
      
      debugPrint('✅ Sign-out successful');
      
    } catch (e) {
      _errorMessage = 'Sign-out failed: ${e.toString()}';
      
      // Track sign-out errors
      _errorTracker.trackError(
        errorType: ErrorType.authentication,
        errorMessage: 'Sign-out failed: ${e.toString()}',
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.low,
        location: 'auth_provider.signOut',
        additionalData: {
          'platform': Platform.operatingSystem,
          'errorType': e.runtimeType.toString(),
        },
      );
      
      debugPrint('❌ Sign-out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Delete the user account
      await user.delete();
      
      // Sign out from Google as well
      await _googleSignIn.signOut();
      
      debugPrint('✅ Account deletion successful');
      
    } catch (e) {
      _errorMessage = 'Account deletion failed: ${e.toString()}';
      debugPrint('❌ Account deletion error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Re-authenticate user (for sensitive operations)
  Future<void> reauthenticate() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Determine which provider to use for re-authentication
      final providerData = user.providerData;
      
      if (providerData.any((info) => info.providerId == 'google.com')) {
        await _reauthenticateWithGoogle();
      } else if (providerData.any((info) => info.providerId == 'apple.com')) {
        await _reauthenticateWithApple();
      } else {
        throw Exception('Unknown authentication provider');
      }
      
      debugPrint('✅ Re-authentication successful');
      
    } catch (e) {
      _errorMessage = 'Re-authentication failed: ${e.toString()}';
      debugPrint('❌ Re-authentication error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Re-authenticate with Google
  Future<void> _reauthenticateWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) {
      throw Exception('Google re-authentication was cancelled');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final user = _auth.currentUser;
    if (user != null) {
      await user.reauthenticateWithCredential(credential);
    }
  }

  /// Re-authenticate with Apple (iOS ONLY)
  Future<void> _reauthenticateWithApple() async {
    // ✅ PLATFORM CHECK: Only allow on iOS
    if (!Platform.isIOS) {
      throw Exception('Apple re-authentication is only available on iOS');
    }

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final user = _auth.currentUser;
    if (user != null) {
      await user.reauthenticateWithCredential(oauthCredential);
    }
  }

  /// Authenticate with biometrics for app access
  Future<bool> authenticateWithBiometrics() async {
    if (!_biometricAuth.isAvailable || !_biometricAuth.isEnabled) {
      return false;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      final result = await _biometricAuth.authenticate(
        reason: 'Use ${_biometricAuth.getBiometricTypeName()} to access DriveLess',
      );

      if (result == BiometricAuthResult.success) {
        debugPrint('🔐 Biometric authentication successful');
        return true;
      } else {
        debugPrint('❌ Biometric authentication failed: $result');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Biometric authentication failed: ${e.toString()}';
      debugPrint('❌ Biometric authentication error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Show biometric setup prompt to user
  Future<bool> showBiometricSetup() async {
    if (!_biometricAuth.shouldShowBiometricOption()) {
      return false;
    }

    try {
      final success = await _biometricAuth.enableBiometricAuth();
      if (success) {
        await _biometricAuth.markSetupComplete();
        debugPrint('✅ Biometric setup completed');
      }
      return success;
    } catch (e) {
      _errorMessage = 'Biometric setup failed: ${e.toString()}';
      debugPrint('❌ Biometric setup error: $e');
      return false;
    }
  }

  /// Mark that biometric prompt has been shown
  void markBiometricPromptShown() {
    _biometricPromptShown = true;
    notifyListeners();
  }

  /// Check if biometric setup should be offered to user
  bool shouldOfferBiometricSetup() {
    return _biometricAuth.shouldShowBiometricOption() && 
           !_biometricAuth.isEnabled && 
           !_biometricPromptShown;
  }
}