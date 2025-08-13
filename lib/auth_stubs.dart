// lib/auth_stubs.dart
//
// Stub implementations for Apple Sign In on non-iOS platforms
// This prevents compilation errors when sign_in_with_apple is not available

/// Stub class for Apple ID Authorization Scopes
class AppleIDAuthorizationScopes {
  static const String email = 'email';
  static const String fullName = 'fullName';
}

/// Stub class for Apple ID Credential
class AppleIDCredential {
  final String? email;
  final String? identityToken;
  final String? authorizationCode;
  final String? familyName;
  final String? givenName;
  
  AppleIDCredential({
    this.email,
    this.identityToken, 
    this.authorizationCode,
    this.familyName,
    this.givenName,
  });
}

/// Stub class for SignInWithApple
class SignInWithApple {
  /// Stub method that throws an error on non-iOS platforms
  static Future<AppleIDCredential> getAppleIDCredential({
    required List<String> scopes,
  }) async {
    throw UnsupportedError('Apple Sign In is only available on iOS');
  }
  
  /// Stub method for checking availability
  static Future<bool> isAvailable() async {
    return false;
  }
}