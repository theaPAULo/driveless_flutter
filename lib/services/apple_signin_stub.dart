// lib/services/apple_signin_stub.dart
//
// Platform-specific stub for Apple Sign-In
// This file provides a no-op implementation for Android

class AppleIDAuthorizationScopes {
  static const email = 'email';
  static const fullName = 'fullName';
}

class SignInWithApple {
  static Future<bool> isAvailable() async {
    return false; // Always false on Android
  }
  
  static Future<AppleIDCredential> getAppleIDCredential({
    required List<String> scopes,
  }) async {
    throw Exception('Apple Sign-In is not available on Android');
  }
}

class AppleIDCredential {
  final String? identityToken;
  final String? authorizationCode;
  final String? givenName;
  final String? familyName;
  
  AppleIDCredential({
    this.identityToken,
    this.authorizationCode,
    this.givenName,
    this.familyName,
  });
}