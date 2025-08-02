// lib/models/user_model.dart
//
// User model for DriveLess app - matches iOS AuthProvider structure
// Represents authenticated user data from Firebase

import 'package:firebase_auth/firebase_auth.dart';

/// Authentication provider enum - matches iOS version
enum AuthProviderType {
  google,
  apple,
}

/// Extension to get string representation of AuthProvider
extension AuthProviderTypeExtension on AuthProviderType {
  String get name {
    switch (this) {
      case AuthProviderType.google:
        return 'Google';
      case AuthProviderType.apple:
        return 'Apple';
    }
  }
}

/// User model class - represents authenticated user
class DriveLessUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final AuthProviderType provider;

  DriveLessUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.provider,
  });

  /// Create DriveLessUser from Firebase User
  factory DriveLessUser.fromFirebaseUser(User firebaseUser) {
    // Determine provider type based on Firebase provider data
    AuthProviderType provider = AuthProviderType.google; // Default
    
    for (final providerData in firebaseUser.providerData) {
      if (providerData.providerId == 'google.com') {
        provider = AuthProviderType.google;
        break;
      } else if (providerData.providerId == 'apple.com') {
        provider = AuthProviderType.apple;
        break;
      }
    }

    return DriveLessUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      provider: provider,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'provider': provider.name,
    };
  }

  /// Create from JSON
  factory DriveLessUser.fromJson(Map<String, dynamic> json) {
    return DriveLessUser(
      uid: json['uid'] ?? '',
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      provider: json['provider'] == 'Apple' 
          ? AuthProviderType.apple 
          : AuthProviderType.google,
    );
  }
}