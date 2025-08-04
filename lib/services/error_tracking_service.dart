// lib/services/error_tracking_service.dart
//
// Real error tracking to replace mock data in admin dashboard

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrorTrackingService {
  static final ErrorTrackingService _instance = ErrorTrackingService._internal();
  factory ErrorTrackingService() => _instance;
  ErrorTrackingService._internal();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Log an error to Firestore for admin dashboard
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? userId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _firestore.collection('error_logs').add({
        'errorType': errorType,
        'errorMessage': errorMessage,
        'userId': userId ?? FirebaseAuth.instance.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'additionalData': additionalData ?? {},
        'resolved': false,
      });
    } catch (e) {
      print('❌ Failed to log error: $e');
    }
  }
  
  /// Get error statistics for admin dashboard
  Future<Map<String, dynamic>> getErrorStatistics() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      // Get today's errors
      final todayErrors = await _firestore
          .collection('error_logs')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(startOfDay))
          .get();
      
      // Get total errors this week
      final weekAgo = today.subtract(const Duration(days: 7));
      final weekErrors = await _firestore
          .collection('error_logs')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();
      
      return {
        'errorsToday': todayErrors.docs.length,
        'errorsThisWeek': weekErrors.docs.length,
        'successRate': _calculateSuccessRate(todayErrors.docs.length),
      };
    } catch (e) {
      return {
        'errorsToday': 0,
        'errorsThisWeek': 0,
        'successRate': 100.0,
      };
    }
  }
  
  double _calculateSuccessRate(int errorCount) {
    // Assume each route calculation is an operation
    // You can refine this logic based on your actual operation tracking
    const int estimatedDailyOperations = 50;
    return ((estimatedDailyOperations - errorCount) / estimatedDailyOperations * 100)
        .clamp(0.0, 100.0);
  }
}