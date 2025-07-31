// lib/services/route_storage_service.dart
//
// Service for saving and loading routes locally
// Uses SharedPreferences for persistent storage

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/route_models.dart';
import '../models/saved_route_model.dart';

class RouteStorageService {
  static const String _storageKey = 'saved_routes';
  static const Uuid _uuid = Uuid();

  /// Save a route to local storage
  /// 
  /// [routeResult] - The optimized route to save
  /// [originalInputs] - Original user inputs
  /// [customName] - Optional custom name (auto-generated if not provided)
  /// Returns the saved route with generated ID
  static Future<SavedRoute> saveRoute({
    required OptimizedRouteResult routeResult,
    required OriginalRouteInputs originalInputs,
    String? customName,
  }) async {
    try {
      // Create saved route object
      final savedRoute = SavedRoute(
        id: _uuid.v4(),
        name: customName ?? SavedRoute.generateRouteName(routeResult),
        savedAt: DateTime.now(),
        routeResult: routeResult,
        originalInputs: originalInputs,
      );

      // Get existing routes
      final List<SavedRoute> existingRoutes = await getAllSavedRoutes();

      // Add new route to the beginning of the list (most recent first)
      existingRoutes.insert(0, savedRoute);

      // Limit to last 50 routes to prevent excessive storage
      if (existingRoutes.length > 50) {
        existingRoutes.removeRange(50, existingRoutes.length);
      }

      // Save to storage
      await _saveRoutesToStorage(existingRoutes);

      print('✅ Route saved: ${savedRoute.name} (${savedRoute.id})');
      return savedRoute;

    } catch (e) {
      print('❌ Error saving route: $e');
      rethrow;
    }
  }

  /// Get all saved routes from storage
  /// 
  /// Returns list of saved routes, most recent first
  static Future<List<SavedRoute>> getAllSavedRoutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? routesJson = prefs.getString(_storageKey);

      if (routesJson == null || routesJson.isEmpty) {
        return [];
      }

      final List<dynamic> routesList = jsonDecode(routesJson);
      final List<SavedRoute> savedRoutes = routesList
          .map((json) => SavedRoute.fromJson(json))
          .toList();

      print('📱 Loaded ${savedRoutes.length} saved routes');
      return savedRoutes;

    } catch (e) {
      print('❌ Error loading saved routes: $e');
      return [];
    }
  }

  /// Delete a saved route
  /// 
  /// [routeId] - ID of the route to delete
  /// Returns true if successful
  static Future<bool> deleteRoute(String routeId) async {
    try {
      final List<SavedRoute> existingRoutes = await getAllSavedRoutes();
      final int initialLength = existingRoutes.length;

      // Remove route with matching ID
      existingRoutes.removeWhere((route) => route.id == routeId);

      if (existingRoutes.length < initialLength) {
        await _saveRoutesToStorage(existingRoutes);
        print('✅ Route deleted: $routeId');
        return true;
      } else {
        print('⚠️ Route not found for deletion: $routeId');
        return false;
      }

    } catch (e) {
      print('❌ Error deleting route: $e');
      return false;
    }
  }

  /// Check if a route is already saved (based on stops similarity)
  /// 
  /// [routeResult] - Route to check
  /// Returns the saved route if found, null otherwise
  static Future<SavedRoute?> findSimilarRoute(OptimizedRouteResult routeResult) async {
    try {
      final List<SavedRoute> savedRoutes = await getAllSavedRoutes();

      for (final savedRoute in savedRoutes) {
        if (_areRoutesSimilar(routeResult, savedRoute.routeResult)) {
          return savedRoute;
        }
      }

      return null;

    } catch (e) {
      print('❌ Error checking for similar routes: $e');
      return null;
    }
  }

  /// Update a saved route (rename, mark as favorite, etc.)
  /// 
  /// [updatedRoute] - The route with updated fields
  /// Returns true if successful
  static Future<bool> updateRoute(SavedRoute updatedRoute) async {
    try {
      final List<SavedRoute> existingRoutes = await getAllSavedRoutes();
      final int index = existingRoutes.indexWhere((route) => route.id == updatedRoute.id);

      if (index != -1) {
        existingRoutes[index] = updatedRoute;
        await _saveRoutesToStorage(existingRoutes);
        print('✅ Route updated: ${updatedRoute.name}');
        return true;
      } else {
        print('⚠️ Route not found for update: ${updatedRoute.id}');
        return false;
      }

    } catch (e) {
      print('❌ Error updating route: $e');
      return false;
    }
  }

  /// Get saved routes count
  /// 
  /// Returns number of saved routes
  static Future<int> getSavedRoutesCount() async {
    final routes = await getAllSavedRoutes();
    return routes.length;
  }

  /// Clear all saved routes (for debugging/reset)
  /// 
  /// Returns true if successful
  static Future<bool> clearAllRoutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      print('✅ All saved routes cleared');
      return true;
    } catch (e) {
      print('❌ Error clearing routes: $e');
      return false;
    }
  }

  // MARK: - Private Helper Methods

  /// Save routes list to SharedPreferences
  static Future<void> _saveRoutesToStorage(List<SavedRoute> routes) async {
    final prefs = await SharedPreferences.getInstance();
    final String routesJson = jsonEncode(routes.map((route) => route.toJson()).toList());
    await prefs.setString(_storageKey, routesJson);
  }

  /// Check if two routes are similar (same stops in same order)
  static bool _areRoutesSimilar(OptimizedRouteResult route1, OptimizedRouteResult route2) {
    final stops1 = route1.optimizedStops;
    final stops2 = route2.optimizedStops;

    if (stops1.length != stops2.length) {
      return false;
    }

    for (int i = 0; i < stops1.length; i++) {
      final stop1 = stops1[i];
      final stop2 = stops2[i];

      // Compare coordinates with some tolerance (about 100 meters)
      const double tolerance = 0.001;
      if ((stop1.latitude - stop2.latitude).abs() > tolerance ||
          (stop1.longitude - stop2.longitude).abs() > tolerance) {
        return false;
      }
    }

    return true;
  }
}