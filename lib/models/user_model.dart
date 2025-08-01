// lib/models/user_model.dart
//
// User model for Firebase authentication (matching iOS app structure)

import 'package:firebase_auth/firebase_auth.dart';

/// Authentication provider types (matching iOS app)
enum AuthProvider {
  google,
  apple, // For future Apple Sign-In support
}

/// User model representing authenticated user data
class DriveLessUser {
  /// Firebase user ID (unique identifier)
  final String uid;
  
  /// User's email address
  final String? email;
  
  /// User's display name (from Google/Apple)
  final String? displayName;
  
  /// User's profile photo URL
  final String? photoURL;
  
  /// Authentication provider used (Google, Apple, etc.)
  final AuthProvider provider;
  
  /// When the user was created
  final DateTime? createdAt;
  
  /// Last sign-in time
  final DateTime? lastSignInAt;

  const DriveLessUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.provider,
    this.createdAt,
    this.lastSignInAt,
  });

  /// Create DriveLessUser from Firebase User
  factory DriveLessUser.fromFirebaseUser(User firebaseUser) {
    // Determine provider based on Firebase provider data
    AuthProvider provider = AuthProvider.google; // Default
    
    for (final userInfo in firebaseUser.providerData) {
      switch (userInfo.providerId) {
        case 'google.com':
          provider = AuthProvider.google;
          break;
        case 'apple.com':
          provider = AuthProvider.apple;
          break;
      }
    }

    return DriveLessUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      provider: provider,
      createdAt: firebaseUser.metadata.creationTime,
      lastSignInAt: firebaseUser.metadata.lastSignInTime,
    );
  }

  /// Convert to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'provider': provider.name,
      'createdAt': createdAt?.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
    };
  }

  /// Create from JSON (from Firestore)
  factory DriveLessUser.fromJson(Map<String, dynamic> json) {
    return DriveLessUser(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      provider: AuthProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => AuthProvider.google,
      ),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastSignInAt: json['lastSignInAt'] != null
          ? DateTime.parse(json['lastSignInAt'] as String) 
          : null,
    );
  }

  /// Create a copy with updated fields
  DriveLessUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    AuthProvider? provider,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return DriveLessUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  /// Get user's first name for display
  String get firstName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!.split(' ').first;
    }
    if (email != null && email!.isNotEmpty) {
      return email!.split('@').first;
    }
    return 'User';
  }

  /// Get provider display name
  String get providerDisplayName {
    switch (provider) {
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
    }
  }

  @override
  String toString() {
    return 'DriveLessUser(uid: $uid, email: $email, displayName: $displayName, provider: ${provider.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DriveLessUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}