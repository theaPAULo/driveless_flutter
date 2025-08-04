// lib/services/usage_tracking_service.dart
//
// Daily usage limit enforcement (10 searches/day for non-admin users)
// Matches iOS UsageTrackingManager functionality

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsageTrackingService {
  static const int DAILY_LIMIT = 10; // 10 searches per day
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Check if user can perform another route calculation
  Future<bool> canPerformRouteCalculation() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // Admin users bypass limits
      if (await _isAdminUser(user.uid)) {
        return true;
      }
      
      final todayUsage = await _getTodayUsage(user.uid);
      return todayUsage < DAILY_LIMIT;
      
    } catch (e) {
      print('❌ Error checking usage limits: $e');
      return false;
    }
  }
  
  /// Increment usage counter for today
  Future<void> incrementUsage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      // Don't increment for admin users
      if (await _isAdminUser(user.uid)) return;
      
      final today = _getTodayDateString();
      final usageDoc = _firestore
          .collection('usage_tracking')
          .doc('${user.uid}_$today');
      
      await usageDoc.set({
        'userId': user.uid,
        'date': today,
        'count': FieldValue.increment(1),
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
    } catch (e) {
      print('❌ Error incrementing usage: $e');
    }
  }
  
  /// Get today's usage count for user
  Future<int> getTodayUsage() async {
    final user = _auth.currentUser;
    if (user == null) return 0;
    return await _getTodayUsage(user.uid);
  }
  
  // MARK: - Private Methods
  
  Future<int> _getTodayUsage(String userId) async {
    try {
      final today = _getTodayDateString();
      final doc = await _firestore
          .collection('usage_tracking')
          .doc('${userId}_$today')
          .get();
      
      return doc.exists ? (doc.data()?['count'] ?? 0) : 0;
    } catch (e) {
      return 0;
    }
  }
  
  Future<bool> _isAdminUser(String userId) async {
    // Check if user is in admin list (implement your admin check logic)
    try {
      final adminDoc = await _firestore
          .collection('admins')
          .doc(userId)
          .get();
      return adminDoc.exists;
    } catch (e) {
      return false;
    }
  }
  
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}