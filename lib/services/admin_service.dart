// lib/services/admin_service.dart
//
// Admin service for managing admin privileges
// Uses Firebase Firestore to store admin user UIDs

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/constants.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if current user has admin privileges
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      return await isUserAdmin(currentUser.uid);
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error checking admin status: $e');
      }
      return false;
    }
  }

  /// Check if a specific user UID has admin privileges
  static Future<bool> isUserAdmin(String uid) async {
    try {
      final DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc(uid)
          .get();

      final bool isAdmin = adminDoc.exists;
      
      if (EnvironmentConfig.logApiCalls) {
        print('🔐 Admin check for $uid: $isAdmin');
      }
      
      return isAdmin;
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error checking admin status for $uid: $e');
      }
      return false;
    }
  }

  /// Add a user as admin (admin-only operation)
  static Future<bool> addAdmin(String uid, String email) async {
    try {
      // First check if current user is admin
      final bool currentUserIsAdmin = await isCurrentUserAdmin();
      if (!currentUserIsAdmin) {
        if (EnvironmentConfig.logApiCalls) {
          print('❌ Only admins can add other admins');
        }
        return false;
      }

      await _firestore.collection('admins').doc(uid).set({
        'email': email,
        'addedBy': _auth.currentUser?.uid,
        'addedAt': FieldValue.serverTimestamp(),
        'permissions': ['dashboard', 'analytics', 'user_management'],
      });

      if (EnvironmentConfig.logApiCalls) {
        print('✅ Added admin: $email ($uid)');
      }

      return true;
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error adding admin: $e');
      }
      return false;
    }
  }

  /// Remove admin privileges (admin-only operation)
  static Future<bool> removeAdmin(String uid) async {
    try {
      // First check if current user is admin
      final bool currentUserIsAdmin = await isCurrentUserAdmin();
      if (!currentUserIsAdmin) {
        if (EnvironmentConfig.logApiCalls) {
          print('❌ Only admins can remove other admins');
        }
        return false;
      }

      // Don't allow removing yourself
      if (uid == _auth.currentUser?.uid) {
        if (EnvironmentConfig.logApiCalls) {
          print('❌ Cannot remove yourself as admin');
        }
        return false;
      }

      await _firestore.collection('admins').doc(uid).delete();

      if (EnvironmentConfig.logApiCalls) {
        print('✅ Removed admin: $uid');
      }

      return true;
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error removing admin: $e');
      }
      return false;
    }
  }

  /// Get list of all admins (admin-only operation)
  static Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final bool currentUserIsAdmin = await isCurrentUserAdmin();
      if (!currentUserIsAdmin) {
        return [];
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('admins')
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error getting admins list: $e');
      }
      return [];
    }
  }

  /// Initialize admin collection (one-time setup)
  /// Call this method to set up the first admin user
  static Future<void> initializeFirstAdmin(String adminEmail) async {
    try {
      // Get user by email (this would require additional setup)
      // For now, you'll need to manually add the first admin in Firebase Console
      
      if (EnvironmentConfig.logApiCalls) {
        print('ℹ️ To set up first admin:');
        print('1. Go to Firebase Console > Firestore');
        print('2. Create collection "admins"');
        print('3. Add document with user UID as document ID');
        print('4. Add fields: email, addedAt (timestamp), permissions (array)');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error initializing admin: $e');
      }
    }
  }
}

/* 
FIREBASE SETUP INSTRUCTIONS:

To set up admin access in your Firebase project:

1. Go to Firebase Console > Firestore Database
2. Create a new collection called "admins"
3. For each admin user, create a document where:
   - Document ID = User's Firebase UID (get this from Authentication tab)
   - Fields:
     - email: string (admin's email)
     - addedAt: timestamp (when they were made admin)
     - permissions: array ["dashboard", "analytics", "user_management"]

Example admin document:
Document ID: "abc123xyz" (Firebase UID)
Fields:
{
  "email": "admin@yourdomain.com",
  "addedAt": "2024-01-15T10:30:00Z",
  "permissions": ["dashboard", "analytics", "user_management"]
}

To get a user's Firebase UID:
1. Have them sign in to your app
2. Check Firebase Console > Authentication > Users
3. Copy their UID and use it as the admin document ID
*/