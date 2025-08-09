// lib/services/auto_save_service.dart
//
// Service to handle automatic route saving based on user settings

import 'package:shared_preferences/shared_preferences.dart';
import '../models/route_models.dart';
import '../services/route_storage_service.dart';
import '../utils/constants.dart';

class AutoSaveService {
  static const String _autoSaveKey = 'auto_save_routes';

  /// Check if auto-save is enabled
  static Future<bool> isAutoSaveEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_autoSaveKey) ?? true; // Default to enabled
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error checking auto-save setting: $e');
      }
      return true; // Default to enabled on error
    }
  }

  /// Automatically save a route if auto-save is enabled
  static Future<void> autoSaveRouteIfEnabled({
    required OptimizedRouteResult routeResult,
    required OriginalRouteInputs originalInputs,
  }) async {
    try {
      final isEnabled = await isAutoSaveEnabled();
      
      if (!isEnabled) {
        if (EnvironmentConfig.logApiCalls) {
          print('⏸️ Auto-save disabled, skipping route save');
        }
        return;
      }

      // Check if route is already saved to avoid duplicates
      final existingRoute = await RouteStorageService.findSimilarRoute(routeResult);
      if (existingRoute != null) {
        if (EnvironmentConfig.logApiCalls) {
          print('⏸️ Similar route already exists, skipping auto-save');
        }
        return;
      }

      // Auto-save the route
      final savedRoute = await RouteStorageService.saveRoute(
        routeResult: routeResult,
        originalInputs: originalInputs,
      );

      if (EnvironmentConfig.logApiCalls) {
        print('🔄 Auto-saved route: ${savedRoute.name}');
      }

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error auto-saving route: $e');
      }
      // Don't throw - auto-save failure shouldn't break the app
    }
  }
}