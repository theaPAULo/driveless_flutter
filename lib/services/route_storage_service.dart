// lib/services/route_storage_service.dart
//
// Service for saving and loading routes with Firestore cloud storage
// Replaces SharedPreferences with Firebase Firestore for cross-device sync
// Maintains backward compatibility and offline support

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/route_models.dart';
import '../models/saved_route_model.dart';
import '../utils/constants.dart';

class RouteStorageService {
  static const String _localStorageKey = 'saved_routes';
  static const Uuid _uuid = Uuid();

  // Firebase instances
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save a route to both local storage and Firestore
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

      // Save to both local and cloud storage
      await _saveRoutesToStorage(existingRoutes);

      if (EnvironmentConfig.logApiCalls) {
        print('✅ Route saved: ${savedRoute.name} (${savedRoute.id})');
      }
      return savedRoute;

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error saving route: $e');
      }
      rethrow;
    }
  }

  /// Get all saved routes from Firestore (with local fallback)
  /// 
  /// Returns list of saved routes, most recent first
  static Future<List<SavedRoute>> getAllSavedRoutes() async {
    try {
      final User? currentUser = _auth.currentUser;
      
      if (currentUser != null) {
        // User is signed in - try to load from Firestore
        return await _loadFromFirestore(currentUser.uid);
      } else {
        // User not signed in - load from local storage
        return await _loadFromLocalStorage();
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading routes, fallback to local: $e');
      }
      // Fallback to local storage on any error
      return await _loadFromLocalStorage();
    }
  }

  /// Load routes from Firestore
  static Future<List<SavedRoute>> _loadFromFirestore(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_routes')
          .orderBy('savedAt', descending: true)
          .limit(50) // Limit to last 50 routes
          .get();
      
      final List<SavedRoute> routes = snapshot.docs
          .map((doc) => SavedRoute.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Loaded ${routes.length} routes from Firestore');
      }
      
      // Also save to local storage as backup
      await _saveToLocalStorage(routes);
      
      return routes;
      
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading from Firestore: $e');
      }
      throw e; // Re-throw to trigger local storage fallback
    }
  }

  /// Load routes from local storage (fallback)
  static Future<List<SavedRoute>> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? routesJson = prefs.getString(_localStorageKey);

      if (routesJson == null || routesJson.isEmpty) {
        return [];
      }

      final List<dynamic> routesList = jsonDecode(routesJson);
      final List<SavedRoute> savedRoutes = routesList
          .map((json) => SavedRoute.fromJson(json))
          .toList();

      if (EnvironmentConfig.logApiCalls) {
        print('📱 Loaded ${savedRoutes.length} routes from local storage');
      }
      return savedRoutes;

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading from local storage: $e');
      }
      return [];
    }
  }

  /// Save routes to both Firestore and local storage
  static Future<void> _saveRoutesToStorage(List<SavedRoute> routes) async {
    final User? currentUser = _auth.currentUser;
    
    // Always save to local storage as backup
    await _saveToLocalStorage(routes);
    
    // If user is signed in, also save to Firestore
    if (currentUser != null) {
      await _saveToFirestore(currentUser.uid, routes);
    }
  }

  /// Save routes to Firestore
  static Future<void> _saveToFirestore(String userId, List<SavedRoute> routes) async {
    try {
      final WriteBatch batch = _firestore.batch();
      final CollectionReference routesCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_routes');
      
      // First, get existing documents to delete them
      final QuerySnapshot existingDocs = await routesCollection.get();
      for (QueryDocumentSnapshot doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }
      
      // Add all current routes
      for (SavedRoute route in routes) {
        final DocumentReference docRef = routesCollection.doc(route.id);
        final Map<String, dynamic> data = route.toJson();
        data.remove('id'); // Don't store ID in document data
        
        // Convert DateTime to Timestamp for Firestore
        data['savedAt'] = Timestamp.fromDate(route.savedAt);
        
        batch.set(docRef, data);
      }
      
      // Commit the batch
      await batch.commit();
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Saved ${routes.length} routes to Firestore');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error saving to Firestore: $e');
      }
      // Don't throw - local storage still works
    }
  }

  /// Save routes to local storage (backup)
  static Future<void> _saveToLocalStorage(List<SavedRoute> routes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String routesJson = jsonEncode(routes.map((route) => route.toJson()).toList());
      await prefs.setString(_localStorageKey, routesJson);
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Saved ${routes.length} routes to local storage');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error saving to local storage: $e');
      }
    }
  }

  /// Migrate existing local routes to Firestore (one-time operation)
  static Future<void> migrateLocalRoutesToFirestore() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      if (EnvironmentConfig.logApiCalls) {
        print('⚠️ Cannot migrate routes: user not signed in');
      }
      return;
    }
    
    try {
      // Check if user already has routes in Firestore
      final QuerySnapshot existing = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('saved_routes')
          .limit(1)
          .get();
      
      if (existing.docs.isNotEmpty) {
        if (EnvironmentConfig.logApiCalls) {
          print('ℹ️ User already has Firestore routes, skipping migration');
        }
        return;
      }
      
      // Load local routes
      final List<SavedRoute> localRoutes = await _loadFromLocalStorage();
      
      if (localRoutes.isNotEmpty) {
        // Save to Firestore
        await _saveToFirestore(currentUser.uid, localRoutes);
        
        if (EnvironmentConfig.logApiCalls) {
          print('✅ Migrated ${localRoutes.length} routes to Firestore');
        }
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error during route migration: $e');
      }
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
        
        if (EnvironmentConfig.logApiCalls) {
          print('✅ Route deleted: $routeId');
        }
        return true;
      } else {
        if (EnvironmentConfig.logApiCalls) {
          print('⚠️ Route not found for deletion: $routeId');
        }
        return false;
      }

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error deleting route: $e');
      }
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
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error checking for similar routes: $e');
      }
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
        
        if (EnvironmentConfig.logApiCalls) {
          print('✅ Route updated: ${updatedRoute.name}');
        }
        return true;
      } else {
        if (EnvironmentConfig.logApiCalls) {
          print('⚠️ Route not found for update: ${updatedRoute.id}');
        }
        return false;
      }

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error updating route: $e');
      }
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
      final User? currentUser = _auth.currentUser;
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localStorageKey);
      
      // Clear Firestore if user is signed in
      if (currentUser != null) {
        final QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('saved_routes')
            .get();
        
        final WriteBatch batch = _firestore.batch();
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ All saved routes cleared');
      }
      return true;
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error clearing routes: $e');
      }
      return false;
    }
  }

  // MARK: - Authentication Integration

  /// Handle user sign in - migrate local routes to Firestore
  static Future<void> onUserSignIn() async {
    await migrateLocalRoutesToFirestore();
  }

  /// Handle user sign out - keep local copy
  static Future<void> onUserSignOut() async {
    // Routes are already saved locally, nothing special needed
    if (EnvironmentConfig.logApiCalls) {
      print('ℹ️ User signed out, routes saved locally');
    }
  }

  // MARK: - Private Helper Methods

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

  // MARK: - Statistics and Analytics

  /// Get route statistics for user dashboard
  static Future<Map<String, dynamic>> getRouteStatistics() async {
    try {
      final List<SavedRoute> routes = await getAllSavedRoutes();
      
      if (routes.isEmpty) {
        return {
          'totalRoutes': 0,
          'favoriteRoutes': 0,
          'totalTimeSaved': 0.0,
          'totalDistanceSaved': 0.0,
          'totalFuelSaved': 0.0,
          'co2Saved': 0.0,
        };
      }
      
      // Calculate aggregated statistics
      double totalTimeSaved = 0.0;
      double totalDistanceSaved = 0.0;
      int favoriteCount = 0;
      
      for (final route in routes) {
        // Count favorites
        if (route.isFavorite) {
          favoriteCount++;
        }
        
        // Sum time and distance saved (compared to unoptimized route)
        // This would require original vs optimized comparison
        // For now, we'll estimate based on route complexity
        final stopCount = route.routeResult.optimizedStops.length;
        if (stopCount > 2) {
          // Estimate time saved for multi-stop routes (rough approximation)
          totalTimeSaved += (stopCount - 2) * 15; // 15 minutes per additional stop
        }
      }
      
      // Calculate fuel and CO2 savings based on estimated distance saved
      // These are rough estimates for demonstration
      final double totalFuelSaved = totalDistanceSaved * 0.04; // 0.04 gallons per mile saved
      final double co2Saved = totalFuelSaved * 19.6; // 19.6 lbs CO2 per gallon
      
      return {
        'totalRoutes': routes.length,
        'favoriteRoutes': favoriteCount,
        'totalTimeSaved': totalTimeSaved,
        'totalDistanceSaved': totalDistanceSaved,
        'totalFuelSaved': totalFuelSaved,
        'co2Saved': co2Saved,
      };
      
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error calculating route statistics: $e');
      }
      return {
        'totalRoutes': 0,
        'favoriteRoutes': 0,
        'totalTimeSaved': 0.0,
        'totalDistanceSaved': 0.0,
        'totalFuelSaved': 0.0,
        'co2Saved': 0.0,
      };
    }
  }
}