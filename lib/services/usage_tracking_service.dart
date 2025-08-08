// lib/services/usage_tracking_service.dart
//
// Complete usage tracking service that preserves existing functionality
// Works behind the scenes with minimal UI impact

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UsageTrackingService extends ChangeNotifier {
  static const int DAILY_LIMIT = 10;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int _todayUsage = 0;
  bool _isLoading = false;
  
  // Getters
  int get todayUsage => _todayUsage;
  bool get isLoading => _isLoading;
  int get remainingRoutes => _isAdminUser() ? 999 : (DAILY_LIMIT - _todayUsage).clamp(0, DAILY_LIMIT);
  double get usagePercentage => _isAdminUser() ? 0.0 : (_todayUsage / DAILY_LIMIT).clamp(0.0, 1.0);
  
  // Admin emails
  static const List<String> ADMIN_EMAILS = [
    'drivelesssavetime@gmail.com',
  ];
  
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    await _loadTodayUsage();
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> canPerformRouteCalculation() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      if (_isAdminUser()) return true;
      
      await _loadTodayUsage();
      return _todayUsage < DAILY_LIMIT;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> incrementUsage() async {
    try {
      final user = _auth.currentUser;
      if (user == null || _isAdminUser()) return;
      
      HapticFeedback.mediumImpact();
      
      final today = _getTodayDateString();
      final usageDoc = _firestore
          .collection('usage_tracking')
          .doc('${user.uid}_$today');
      
      await usageDoc.set({
        'userId': user.uid,
        'userEmail': user.email ?? 'unknown',
        'date': today,
        'count': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      _todayUsage++;
      notifyListeners();
    } catch (e) {
      print('❌ Error incrementing usage: $e');
    }
  }
  
  Future<bool> showUsageWarningIfNeeded(BuildContext context) async {
    if (_isAdminUser()) return true;
    
    if (_todayUsage >= DAILY_LIMIT) {
      HapticFeedback.heavyImpact();
      return await _showUsageLimitDialog(context);
    } else if (_todayUsage >= 8) {
      HapticFeedback.lightImpact();
      return await _showUsageWarningDialog(context);
    }
    
    return true;
  }
  
  Future<void> resetUsageForToday() async {
    if (!_isAdminUser()) return;
    
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final today = _getTodayDateString();
      await _firestore
          .collection('usage_tracking')
          .doc('${user.uid}_$today')
          .delete();
      
      _todayUsage = 0;
      notifyListeners();
    } catch (e) {
      print('❌ Error resetting usage: $e');
    }
  }
  
  // Private methods
  
  Future<void> _loadTodayUsage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _todayUsage = 0;
        return;
      }
      
      final today = _getTodayDateString();
      final doc = await _firestore
          .collection('usage_tracking')
          .doc('${user.uid}_$today')
          .get();
      
      _todayUsage = doc.exists ? (doc.data()?['count'] ?? 0) : 0;
      notifyListeners();
    } catch (e) {
      _todayUsage = 0;
      notifyListeners();
    }
  }
  
  bool _isAdminUser() {
    final user = _auth.currentUser;
    if (user?.email == null) return false;
    return ADMIN_EMAILS.contains(user!.email!.toLowerCase());
  }
  
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
  
  Future<bool> _showUsageWarningDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[400], size: 28),
            const SizedBox(width: 12),
            const Text('Usage Warning', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          'You have used $_todayUsage of $DAILY_LIMIT daily route calculations. You have ${DAILY_LIMIT - _todayUsage} remaining.',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34C759),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ) ?? false;
  }
  
  Future<bool> _showUsageLimitDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.block_rounded, color: Colors.red[400], size: 28),
            const SizedBox(width: 12),
            const Text('Daily Limit Reached', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: const Text(
          'You have reached your daily limit of 10 route calculations. Please try again tomorrow.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34C759),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('OK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ) ?? false;
  }
}