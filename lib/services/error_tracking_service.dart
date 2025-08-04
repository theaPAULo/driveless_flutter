// lib/services/error_tracking_service.dart
//
// Comprehensive error tracking service for real admin dashboard analytics
// Replaces mock error data with actual error logging and tracking

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

// Error types for categorization
enum ErrorType {
  routeCalculation,
  networkConnection,
  authentication,
  firestore,
  locationServices,
  userInput,
  unknown,
}

// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

class ErrorTrackingService {
  static final ErrorTrackingService _instance = ErrorTrackingService._internal();
  factory ErrorTrackingService() => _instance;
  ErrorTrackingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Track an error with full context
  /// 
  /// [errorType] - Category of error
  /// [errorMessage] - Human-readable error description
  /// [stackTrace] - Stack trace if available
  /// [severity] - How critical the error is
  /// [location] - Where in the app the error occurred
  /// [additionalData] - Any additional context data
  Future<void> trackError({
    required ErrorType errorType,
    required String errorMessage,
    StackTrace? stackTrace,
    ErrorSeverity severity = ErrorSeverity.medium,
    String? location,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      final timestamp = DateTime.now();

      // Create comprehensive error data
      final errorData = {
        'userId': user?.uid ?? 'anonymous',
        'userEmail': user?.email ?? 'anonymous',
        'errorType': errorType.toString().split('.').last,
        'errorMessage': errorMessage,
        'stackTrace': stackTrace?.toString() ?? '',
        'severity': severity.toString().split('.').last,
        'location': location ?? 'unknown',
        'additionalData': additionalData ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'deviceInfo': await _getDeviceInfo(),
        'appVersion': '1.0.0',
        'isResolved': false,
      };

      // Store in errors collection for admin dashboard
      await _firestore.collection('errors').add(errorData);

      // Also store in analytics for general tracking
      await _firestore.collection('analytics').add({
        ...errorData,
        'type': 'error',
        'success': false,
      });

      // Log to console in debug mode
      if (EnvironmentConfig.logApiCalls) {
        print('🚨 Error tracked: ${errorType.toString().split('.').last} - $errorMessage');
        if (stackTrace != null && kDebugMode) {
          print('Stack trace: $stackTrace');
        }
      }

      // For critical errors, also log to a priority collection
      if (severity == ErrorSeverity.critical) {
        await _firestore.collection('critical_errors').add(errorData);
      }

    } catch (e) {
      // Fallback: at least log to console if Firebase fails
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Failed to track error: $e');
        print('Original error: $errorMessage');
      }
    }
  }

  /// Track route calculation errors specifically
  Future<void> trackRouteCalculationError({
    required String errorMessage,
    required String startLocation,
    required String endLocation,
    required List<String> stops,
    StackTrace? stackTrace,
    Map<String, dynamic>? apiResponse,
  }) async {
    await trackError(
      errorType: ErrorType.routeCalculation,
      errorMessage: errorMessage,
      stackTrace: stackTrace,
      severity: ErrorSeverity.high,
      location: 'route_calculation',
      additionalData: {
        'startLocation': startLocation,
        'endLocation': endLocation,
        'stops': stops,
        'stopCount': stops.length,
        'apiResponse': apiResponse,
      },
    );
  }

  /// Track network connectivity errors
  Future<void> trackNetworkError({
    required String errorMessage,
    required String endpoint,
    int? statusCode,
    StackTrace? stackTrace,
  }) async {
    await trackError(
      errorType: ErrorType.networkConnection,
      errorMessage: errorMessage,
      stackTrace: stackTrace,
      severity: ErrorSeverity.medium,
      location: 'network_request',
      additionalData: {
        'endpoint': endpoint,
        'statusCode': statusCode,
      },
    );
  }

  /// Track authentication errors
  Future<void> trackAuthenticationError({
    required String errorMessage,
    required String authMethod,
    StackTrace? stackTrace,
  }) async {
    await trackError(
      errorType: ErrorType.authentication,
      errorMessage: errorMessage,
      stackTrace: stackTrace,
      severity: ErrorSeverity.high,
      location: 'authentication',
      additionalData: {
        'authMethod': authMethod,
      },
    );
  }

  /// Track Firestore database errors
  Future<void> trackFirestoreError({
    required String errorMessage,
    required String operation,
    required String collection,
    StackTrace? stackTrace,
  }) async {
    await trackError(
      errorType: ErrorType.firestore,
      errorMessage: errorMessage,
      stackTrace: stackTrace,
      severity: ErrorSeverity.high,
      location: 'firestore_$operation',
      additionalData: {
        'operation': operation,
        'collection': collection,
      },
    );
  }

  /// Track location services errors
  Future<void> trackLocationError({
    required String errorMessage,
    StackTrace? stackTrace,
  }) async {
    await trackError(
      errorType: ErrorType.locationServices,
      errorMessage: errorMessage,
      stackTrace: stackTrace,
      severity: ErrorSeverity.medium,
      location: 'location_services',
    );
  }

  /// Track user input validation errors
  Future<void> trackUserInputError({
    required String errorMessage,
    required String inputField,
    required String inputValue,
  }) async {
    await trackError(
      errorType: ErrorType.userInput,
      errorMessage: errorMessage,
      severity: ErrorSeverity.low,
      location: 'user_input_validation',
      additionalData: {
        'inputField': inputField,
        'inputValue': inputValue,
      },
    );
  }

  /// Get error statistics for admin dashboard
  Future<Map<String, dynamic>> getErrorStatistics() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekAgo = now.subtract(const Duration(days: 7));
      final monthAgo = now.subtract(const Duration(days: 30));

      // Get errors by time period
      final todayErrors = await _firestore
          .collection('errors')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(todayStart))
          .get();

      final weekErrors = await _firestore
          .collection('errors')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();

      final monthErrors = await _firestore
          .collection('errors')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(monthAgo))
          .get();

      // Get critical errors
      final criticalErrors = await _firestore
          .collection('critical_errors')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(monthAgo))
          .get();

      // Categorize errors by type
      final Map<String, int> errorsByType = {};
      for (final doc in monthErrors.docs) {
        final errorType = doc.data()['errorType'] as String? ?? 'unknown';
        errorsByType[errorType] = (errorsByType[errorType] ?? 0) + 1;
      }

      // Get most common error
      String mostCommonError = 'none';
      int maxCount = 0;
      errorsByType.forEach((type, count) {
        if (count > maxCount) {
          maxCount = count;
          mostCommonError = type;
        }
      });

      return {
        'todayErrors': todayErrors.docs.length,
        'weekErrors': weekErrors.docs.length,
        'monthErrors': monthErrors.docs.length,
        'criticalErrors': criticalErrors.docs.length,
        'errorsByType': errorsByType,
        'mostCommonError': mostCommonError,
        'totalResolved': monthErrors.docs
            .where((doc) => doc.data()['isResolved'] == true)
            .length,
      };

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error getting error statistics: $e');
      }
      return {
        'todayErrors': 0,
        'weekErrors': 0,
        'monthErrors': 0,
        'criticalErrors': 0,
        'errorsByType': {},
        'mostCommonError': 'none',
        'totalResolved': 0,
      };
    }
  }

  /// Mark an error as resolved (for admin use)
  Future<void> markErrorAsResolved(String errorId) async {
    try {
      await _firestore.collection('errors').doc(errorId).update({
        'isResolved': true,
        'resolvedAt': FieldValue.serverTimestamp(),
      });

      if (EnvironmentConfig.logApiCalls) {
        print('✅ Error marked as resolved: $errorId');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Failed to mark error as resolved: $e');
      }
    }
  }

  /// Get recent errors for admin review
  Future<List<Map<String, dynamic>>> getRecentErrors({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('errors')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error getting recent errors: $e');
      }
      return [];
    }
  }

  /// Get device info for error context
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // In a real app, you'd use device_info_plus package
    // For now, return basic Flutter info
    return {
      'platform': defaultTargetPlatform.toString(),
      'isDebugMode': kDebugMode,
      'isReleaseMode': kReleaseMode,
    };
  }

  /// Set up global error handling (call this in main.dart)
  static void initializeGlobalErrorHandling() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      ErrorTrackingService().trackError(
        errorType: ErrorType.unknown,
        errorMessage: details.exception.toString(),
        stackTrace: details.stack,
        severity: ErrorSeverity.high,
        location: 'flutter_framework',
        additionalData: {
          'library': details.library ?? 'unknown',
          'context': details.context?.toString() ?? 'unknown',
        },
      );
    };

    // Handle platform/Dart errors
    PlatformDispatcher.instance.onError = (error, stack) {
      ErrorTrackingService().trackError(
        errorType: ErrorType.unknown,
        errorMessage: error.toString(),
        stackTrace: stack,
        severity: ErrorSeverity.critical,
        location: 'platform_dispatcher',
      );
      return true;
    };
  }
}