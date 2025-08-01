// lib/services/auth_service.dart
//
// Authentication service managing Firebase Auth and Google Sign-In
// Matches iOS AuthenticationManager functionality

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';

/// Authentication service handling all sign-in/sign-out operations
class AuthService extends ChangeNotifier {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _init();
  }

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Current user state
  DriveLessUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  DriveLessUser? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize authentication service
  void _init() {
    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((User? firebaseUser) {
      _updateUserState(firebaseUser);
    });
  }

  /// Update user state when Firebase auth changes
  Future<void> _updateUserState(User? firebaseUser) async {
    if (firebaseUser != null) {
      if (EnvironmentConfig.logApiCalls) {
        print('✅ User signed in: ${firebaseUser.email ?? "No email"}');
        print('🔐 Firebase UID: ${firebaseUser.uid}');
      }

      // Create DriveLess user model
      _currentUser = DriveLessUser.fromFirebaseUser(firebaseUser);
      
      // Save/update user data in Firestore
      await _saveUserToFirestore(_currentUser!);
      
      // Track sign-in analytics
      await _trackUserSignIn();
      
    } else {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ User signed out');
      }
      
      // Track sign-out analytics
      await _trackUserSignOut();
      
      _currentUser = null;
    }

    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Save user data to Firestore (for profile, analytics, etc.)
  Future<void> _saveUserToFirestore(DriveLessUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        ...user.toJson(),
        'lastActiveAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (EnvironmentConfig.logApiCalls) {
        print('✅ User data saved to Firestore');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error saving user to Firestore: $e');
      }
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      
      if (EnvironmentConfig.logApiCalls) {
        print('🌐 Starting Google Sign-In...');
      }

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        _setLoading(false);
        return false;
      }

      // Get Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Google Sign-In successful: ${userCredential.user?.email}');
      }

      return true;

    } catch (e) {
      _setError('Google Sign-In failed: ${e.toString()}');
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Google Sign-In error: $e');
      }
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _setLoading(true);
      
      if (EnvironmentConfig.logApiCalls) {
        print('🚪 Signing out user...');
      }

      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Firebase
      await _auth.signOut();
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Sign out successful');
      }

    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Sign out error: $e');
      }
    }
  }

  /// Delete user account permanently
  Future<bool> deleteAccount() async {
    try {
      if (_currentUser == null) return false;
      
      _setLoading(true);
      
      if (EnvironmentConfig.logApiCalls) {
        print('🗑️ Deleting user account...');
      }

      final String uid = _currentUser!.uid;

      // Delete user data from Firestore
      await _deleteUserDataFromFirestore(uid);

      // Delete Firebase account
      await _auth.currentUser?.delete();
      
      // Sign out from Google
      await _googleSignIn.signOut();

      if (EnvironmentConfig.logApiCalls) {
        print('✅ Account deleted successfully');
      }

      return true;

    } catch (e) {
      _setError('Account deletion failed: ${e.toString()}');
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Account deletion error: $e');
      }
      return false;
    }
  }

  /// Delete all user data from Firestore
  Future<void> _deleteUserDataFromFirestore(String uid) async {
    try {
      final batch = _firestore.batch();

      // Delete user profile
      batch.delete(_firestore.collection('users').doc(uid));

      // Delete user's saved addresses
      final addressesSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('savedAddresses')
          .get();
      
      for (final doc in addressesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's route history
      final routesSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('routeHistory')
          .get();
      
      for (final doc in routesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's analytics data
      final analyticsSnapshot = await _firestore
          .collection('analytics')
          .where('userId', isEqualTo: uid)
          .get();
      
      for (final doc in analyticsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Execute batch delete
      await batch.commit();

      if (EnvironmentConfig.logApiCalls) {
        print('✅ All user data deleted from Firestore');
      }

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error deleting user data: $e');
      }
    }
  }

  /// Track user sign-in for analytics
  Future<void> _trackUserSignIn() async {
    if (_currentUser == null) return;
    
    try {
      await _firestore.collection('analytics').add({
        'userId': _currentUser!.uid,
        'event': 'user_sign_in',
        'provider': _currentUser!.provider.name,
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': _currentUser!.email,
        'userDisplayName': _currentUser!.displayName,
      });
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error tracking sign-in: $e');
      }
    }
  }

  /// Track user sign-out for analytics
  Future<void> _trackUserSignOut() async {
    if (_currentUser == null) return;
    
    try {
      await _firestore.collection('analytics').add({
        'userId': _currentUser!.uid,
        'event': 'user_sign_out',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error tracking sign-out: $e');
      }
    }
  }

  /// Get user statistics from Firestore
  Future<Map<String, dynamic>?> getUserStats() async {
    if (_currentUser == null) return null;
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('stats')
          .doc('summary')
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error fetching user stats: $e');
      }
    }
    
    return null;
  }

  /// Check if user is admin (for admin dashboard access)
  Future<bool> isUserAdmin() async {
    if (_currentUser == null) return false;
    
    try {
      final doc = await _firestore
          .collection('admins')
          .doc(_currentUser!.uid)
          .get();
      
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get user's display name or fallback
  String getUserDisplayName() {
    if (_currentUser?.displayName?.isNotEmpty == true) {
      return _currentUser!.displayName!;
    }
    if (_currentUser?.email?.isNotEmpty == true) {
      return _currentUser!.email!.split('@').first;
    }
    return 'User';
  }

  /// Get user's first name for greeting
  String getUserFirstName() {
    return _currentUser?.firstName ?? 'User';
  }
}