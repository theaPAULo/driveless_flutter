// lib/services/analytics_service.dart
//
// Firebase Analytics Service for tracking user events and route calculations
// This service provides real analytics data for the admin dashboard

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Track a general event with details
  /// 
  /// [type] - Event type (e.g., 'route_calculation_started', 'user_action')
  /// [details] - Additional details about the event
  /// [success] - Whether the operation was successful (default: true)
  /// [errorMessage] - Error message if success is false
  Future<void> trackEvent(
    String type, {
    String? details,
    bool success = true,
    String? errorMessage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (EnvironmentConfig.logApiCalls) {
          print('⚠️ Cannot track event - no authenticated user');
        }
        return;
      }

      // Create event data
      final eventData = {
        'userId': user.uid,
        'userEmail': user.email,
        'type': type,
        'details': details ?? '',
        'success': success,
        'errorMessage': errorMessage ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'appVersion': '1.0.0', // You can make this dynamic
      };

      // Add to analytics collection
      await _firestore.collection('analytics').add(eventData);

      if (EnvironmentConfig.logApiCalls) {
        print('📊 Event tracked: $type');
      }

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error tracking event: $e');
      }
    }
  }

  /// Track route calculation specifically
  /// 
  /// [stops] - List of all stops in the route
  /// [totalDistance] - Calculated total distance
  /// [totalTime] - Calculated total time
  /// [success] - Whether calculation was successful
  Future<void> trackRouteCalculation({
    required List<String> stops,
    required String totalDistance,
    required String totalTime,
    required bool success,
    String? errorMessage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Create route calculation data
      final routeData = {
        'userId': user.uid,
        'userEmail': user.email,
        'type': 'route_calculation',
        'stops': stops,
        'stopCount': stops.length,
        'totalDistance': totalDistance,
        'totalTime': totalTime,
        'success': success,
        'errorMessage': errorMessage ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add to analytics collection
      await _firestore.collection('analytics').add(routeData);

      // If successful, also add to routes collection for admin dashboard
      if (success) {
        final routeRecord = {
          'userId': user.uid,
          'userEmail': user.email,
          'stops': stops,
          'stopCount': stops.length,
          'totalDistance': totalDistance,
          'totalTime': totalTime,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('routes').add(routeRecord);
      }

      if (EnvironmentConfig.logApiCalls) {
        print('✅ Route calculation tracked: ${stops.length} stops, success: $success');
      }

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error tracking route calculation: $e');
      }
    }
  }

  /// Update user's last active timestamp
  /// Call this when user performs significant actions
  Future<void> updateUserActivity() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      });

      if (EnvironmentConfig.logApiCalls) {
        print('👤 User activity updated');
      }

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error updating user activity: $e');
      }
    }
  }

  /// Track user login
  Future<void> trackUserLogin() async {
    await trackEvent('user_login', details: 'User signed in');
    await updateUserActivity();
  }

  /// Track user logout
  Future<void> trackUserLogout() async {
    await trackEvent('user_logout', details: 'User signed out');
  }

  /// Track app launch
  Future<void> trackAppLaunch() async {
    await trackEvent('app_launch', details: 'App started');
    await updateUserActivity();
  }

  /// Track error for admin dashboard
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? location,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Create error data
      final errorData = {
        'userId': user.uid,
        'userEmail': user.email,
        'type': 'error',
        'errorType': errorType,
        'errorMessage': errorMessage,
        'location': location ?? 'unknown',
        'additionalData': additionalData ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add to both analytics and errors collections
      await Future.wait([
        _firestore.collection('analytics').add(errorData),
        _firestore.collection('errors').add(errorData),
      ]);

      if (EnvironmentConfig.logApiCalls) {
        print('🚨 Error tracked: $errorType');
      }

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error tracking error: $e');
      }
    }
  }

  /// Get analytics statistics for admin dashboard
  Future<Map<String, dynamic>> getAnalyticsStatistics() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekAgo = now.subtract(const Duration(days: 7));
      final monthAgo = now.subtract(const Duration(days: 30));

      // Get today's events
      final todayEvents = await _firestore
          .collection('analytics')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(todayStart))
          .get();

      // Get week's events
      final weekEvents = await _firestore
          .collection('analytics')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();

      // Get month's events
      final monthEvents = await _firestore
          .collection('analytics')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(monthAgo))
          .get();

      // Calculate statistics
      final todayRoutes = todayEvents.docs
          .where((doc) => doc.data()['type'] == 'route_calculation' && doc.data()['success'] == true)
          .length;

      final weekRoutes = weekEvents.docs
          .where((doc) => doc.data()['type'] == 'route_calculation' && doc.data()['success'] == true)
          .length;

      final monthRoutes = monthEvents.docs
          .where((doc) => doc.data()['type'] == 'route_calculation' && doc.data()['success'] == true)
          .length;

      final todayErrors = todayEvents.docs
          .where((doc) => doc.data()['success'] == false)
          .length;

      return {
        'todayRoutes': todayRoutes,
        'weekRoutes': weekRoutes,
        'monthRoutes': monthRoutes,
        'todayErrors': todayErrors,
        'totalEvents': monthEvents.docs.length,
      };

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error getting analytics statistics: $e');
      }
      return {
        'todayRoutes': 0,
        'weekRoutes': 0,
        'monthRoutes': 0,
        'todayErrors': 0,
        'totalEvents': 0,
      };
    }
  }
}