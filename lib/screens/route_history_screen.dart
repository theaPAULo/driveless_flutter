// lib/screens/route_history_screen.dart
//
// Route History screen - CONSERVATIVE Theme Update
// ✅ PRESERVES: All existing functionality - search, stats, favorites, delete, clear all
// ✅ CHANGES: Only hardcoded colors to use theme provider  
// ✅ KEEPS: All logic, methods, UI structure, and behavior identical

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart'; // NEW: For theme provider

import '../models/saved_route_model.dart';
import '../models/route_models.dart';
import '../services/route_storage_service.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart'; // NEW: Only for theme colors
import 'route_results_screen.dart';

class RouteHistoryScreen extends StatefulWidget {
  const RouteHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RouteHistoryScreen> createState() => _RouteHistoryScreenState();
}

class _RouteHistoryScreenState extends State<RouteHistoryScreen> {
  // PRESERVED: All existing state variables
  List<SavedRoute> _savedRoutes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSavedRoutes(); // PRESERVED: Same initialization
  }

  /// PRESERVED: Load saved routes from storage - EXACT SAME LOGIC
  Future<void> _loadSavedRoutes() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final routes = await RouteStorageService.getAllSavedRoutes();
      
      if (mounted) {
        setState(() {
          _savedRoutes = routes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading saved routes: $e');
      }
    }
  }

  /// PRESERVED: Filter routes based on search query - EXACT SAME LOGIC
  List<SavedRoute> get filteredRoutes {
    if (_searchQuery.isEmpty) {
      return _savedRoutes;
    }
    
    return _savedRoutes.where((route) {
      final query = _searchQuery.toLowerCase();
      return route.name.toLowerCase().contains(query) ||
             route.routeResult.optimizedStops.any((stop) => 
                 stop.displayName.toLowerCase().contains(query) ||
                 stop.address.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider for colors only  
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      // CHANGED: Theme-aware background instead of Colors.black
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // CHANGED: Theme-aware app bar instead of Colors.black
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            // CHANGED: Theme-aware icon color instead of Colors.white
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Route History', // PRESERVED: Original title
          style: TextStyle(
            // CHANGED: Theme-aware text color instead of Colors.white
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 34, // PRESERVED: Original sizing
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false, // PRESERVED: Original alignment
        actions: [
          // PRESERVED: Clear all button logic
          if (_savedRoutes.isNotEmpty)
            TextButton(
              onPressed: _showClearAllConfirmation,
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: Colors.red, // PRESERVED: Keep red for destructive action
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading ? _buildLoadingState(themeProvider) : _buildContent(themeProvider),
    );
  }

  // MARK: - Loading State - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildLoadingState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF34C759), // PRESERVED: iOS green for active states
          ),
          const SizedBox(height: 16),
          Text(
            'Loading route history...', // PRESERVED: Original text
            style: TextStyle(
              // CHANGED: Theme-aware color instead of Colors.grey
              color: themeProvider.currentTheme == AppThemeMode.dark 
                ? Colors.grey[400] 
                : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Main Content - PRESERVED STRUCTURE
  Widget _buildContent(ThemeProvider themeProvider) {
    if (_savedRoutes.isEmpty) {
      return _buildEmptyState(themeProvider);
    }

    return Column(
      children: [
        // PRESERVED: Search bar logic
        if (_savedRoutes.length > 3) _buildSearchBar(themeProvider),
        
        // PRESERVED: Stats header
        _buildStatsHeader(themeProvider),
        
        // PRESERVED: Route list
        Expanded(
          child: _buildRouteList(themeProvider),
        ),
      ],
    );
  }

  // MARK: - Empty State - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF34C759).withOpacity(0.1), // PRESERVED: iOS green
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.history,
                color: Color(0xFF34C759), // PRESERVED: iOS green
                size: 50,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Empty State Title
            Text(
              'No Route History', // PRESERVED: Original text
              style: TextStyle(
                // CHANGED: Theme-aware color instead of Colors.white
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Empty State Description
            Text(
              'Start planning routes to see your history here. Saved routes will appear automatically for quick access.', // PRESERVED: Original text
              textAlign: TextAlign.center,
              style: TextStyle(
                // CHANGED: Theme-aware color instead of Colors.grey[400]
                color: themeProvider.currentTheme == AppThemeMode.dark 
                  ? Colors.grey[400] 
                  : Colors.grey[600],
                fontSize: 16,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Back to Planning Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), // PRESERVED: Original action
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34C759), // PRESERVED: iOS green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Plan Your First Route', // PRESERVED: Original text
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Search Bar - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildSearchBar(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: TextField(
        // PRESERVED: Search functionality
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: TextStyle(
          // CHANGED: Theme-aware text color instead of Colors.white
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        decoration: InputDecoration(
          hintText: 'Search routes...', // PRESERVED: Original hint
          hintStyle: TextStyle(
            // CHANGED: Theme-aware hint color
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.grey[500] 
              : Colors.grey[400],
          ),
          prefixIcon: Icon(
            Icons.search, 
            // CHANGED: Theme-aware icon color
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.grey[500] 
              : Colors.grey[400],
          ),
          filled: true,
          // CHANGED: Theme-aware fill color instead of Color(0xFF2C2C2E)
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // MARK: - Stats Header - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildStatsHeader(ThemeProvider themeProvider) {
    // PRESERVED: All calculations exactly the same
    final totalRoutes = _savedRoutes.length;
    final favoriteRoutes = _savedRoutes.where((r) => r.isFavorite).length;
    final filteredCount = filteredRoutes.length;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // CHANGED: Theme-aware card color instead of Color(0xFF2C2C2E)
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // PRESERVED: Stats display logic
          _buildStatItem(
            value: totalRoutes.toString(),
            label: 'Total\nRoutes',
            themeProvider: themeProvider,
          ),
          _buildStatItem(
            value: '12901.1', // PRESERVED: Hardcoded value as in original
            label: 'Miles\nOptimized',
            themeProvider: themeProvider,
          ),
          _buildStatItem(
            value: '3d ago', // PRESERVED: Hardcoded value as in original
            label: 'Most Recent',
            themeProvider: themeProvider,
          ),
        ],
      ),
    );
  }

  // MARK: - Stat Item - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildStatItem({
    required String value,
    required String label,
    required ThemeProvider themeProvider,
  }) {
    return Column(
      children: [
        Text(
          value, // PRESERVED: Original value
          style: TextStyle(
            color: const Color(0xFF34C759), // PRESERVED: iOS green for stats
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label, // PRESERVED: Original label
          textAlign: TextAlign.center,
          style: TextStyle(
            // CHANGED: Theme-aware color instead of Colors.grey
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.grey[400] 
              : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // MARK: - Route List - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildRouteList(ThemeProvider themeProvider) {
    final routes = filteredRoutes;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return _buildRouteItem(route, themeProvider);
      },
    );
  }

  // MARK: - Route Item - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildRouteItem(SavedRoute route, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        // CHANGED: Theme-aware card color
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          // PRESERVED: Route loading functionality
          onTap: () => _loadRoute(route),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Route Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withOpacity(0.1), // PRESERVED: iOS green
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.map,
                    color: Color(0xFF34C759), // PRESERVED: iOS green
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Route Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route Name and Actions
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              route.name, // PRESERVED: Original route name
                              style: TextStyle(
                                // CHANGED: Theme-aware color instead of Colors.white
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // PRESERVED: Favorite button logic
                          IconButton(
                            onPressed: () => _toggleFavorite(route),
                            icon: Icon(
                              route.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: route.isFavorite ? Colors.red : 
                                (themeProvider.currentTheme == AppThemeMode.dark 
                                  ? Colors.grey[400] 
                                  : Colors.grey[600]),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Distance and Time
                      Row(
                        children: [
                          // Distance Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34C759).withOpacity(0.1), // PRESERVED: iOS green
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '15.1 miles', // PRESERVED: Hardcoded from original
                              style: const TextStyle(
                                color: Color(0xFF34C759), // PRESERVED: iOS green
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Time Info
                          Text(
                            '${route.routeResult.totalDistance} • ${route.routeResult.estimatedTime}', // PRESERVED: Original data
                            style: TextStyle(
                              // CHANGED: Theme-aware color instead of Colors.grey[400]
                              color: themeProvider.currentTheme == AppThemeMode.dark 
                                ? Colors.grey[400] 
                                : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Date
                      Text(
                        route.formattedDate, // PRESERVED: Original date formatting
                        style: TextStyle(
                          // CHANGED: Theme-aware color instead of Colors.grey[500]
                          color: themeProvider.currentTheme == AppThemeMode.dark 
                            ? Colors.grey[500] 
                            : Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Route Stops Preview
                      Text(
                        _getRouteStopsPreview(route), // PRESERVED: Original preview logic
                        style: TextStyle(
                          // CHANGED: Theme-aware color instead of Colors.grey[300]
                          color: themeProvider.currentTheme == AppThemeMode.dark 
                            ? Colors.grey[300] 
                            : Colors.grey[700],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - Helper Methods - PRESERVED EXACTLY

  /// PRESERVED: Get a preview of route stops - EXACT SAME LOGIC
  String _getRouteStopsPreview(SavedRoute route) {
    final stops = route.routeResult.optimizedStops;
    if (stops.isEmpty) return 'No stops';
    
    if (stops.length == 1) {
      return stops.first.displayName;
    }
    
    if (stops.length == 2) {
      return '${stops.first.displayName} → ${stops.last.displayName}';
    }
    
    return '${stops.first.displayName} → ${stops.length - 2} stops → ${stops.last.displayName}';
  }

  /// PRESERVED: Load a route (navigate to results screen) - EXACT SAME LOGIC
  Future<void> _loadRoute(SavedRoute route) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RouteResultsScreen(
          routeResult: route.routeResult,
          originalInputs: route.originalInputs,
        ),
      ),
    );
  }

  /// PRESERVED: Toggle favorite status - EXACT SAME LOGIC
  Future<void> _toggleFavorite(SavedRoute route) async {
    try {
      final updatedRoute = route.copyWith(isFavorite: !route.isFavorite);
      final success = await RouteStorageService.updateRoute(updatedRoute);
      
      if (success && mounted) {
        setState(() {
          final index = _savedRoutes.indexWhere((r) => r.id == route.id);
          if (index != -1) {
            _savedRoutes[index] = updatedRoute;
          }
        });
        
        // PRESERVED: Feedback logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedRoute.isFavorite 
                  ? 'Route added to favorites'
                  : 'Route removed from favorites',
            ),
            backgroundColor: const Color(0xFF34C759), // PRESERVED: iOS green
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error toggling favorite: $e');
      }
    }
  }

  /// PRESERVED: Show delete confirmation - UPDATED COLORS ONLY
  void _showDeleteConfirmation(SavedRoute route) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // CHANGED: Theme-aware background instead of Color(0xFF2C2C2E)
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Delete Route', // PRESERVED: Original title
            style: TextStyle(
              // CHANGED: Theme-aware color instead of Colors.white
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${route.name}"? This action cannot be undone.', // PRESERVED: Original text
            style: TextStyle(
              // CHANGED: Theme-aware color instead of Colors.grey[400]
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // PRESERVED: Original action
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF007AFF)), // PRESERVED: iOS blue
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteRoute(route); // PRESERVED: Original action
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red), // PRESERVED: Red for destructive
              ),
            ),
          ],
        );
      },
    );
  }

  /// PRESERVED: Delete a route - EXACT SAME LOGIC
  Future<void> _deleteRoute(SavedRoute route) async {
    try {
      final success = await RouteStorageService.deleteRoute(route.id);
      
      if (success && mounted) {
        setState(() {
          _savedRoutes.removeWhere((r) => r.id == route.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Route deleted'),
            backgroundColor: const Color(0xFF34C759), // PRESERVED: iOS green
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error deleting route: $e');
      }
    }
  }

  /// PRESERVED: Show clear all confirmation - UPDATED COLORS ONLY
  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // CHANGED: Theme-aware background instead of Color(0xFF2C2C2E)
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Clear All Routes', // PRESERVED: Original title
            style: TextStyle(
              // CHANGED: Theme-aware color instead of Colors.white
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          content: Text(
            'Are you sure you want to delete all ${_savedRoutes.length} saved routes? This action cannot be undone.', // PRESERVED: Original text
            style: TextStyle(
              // CHANGED: Theme-aware color instead of Colors.grey[400]
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // PRESERVED: Original action
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF007AFF)), // PRESERVED: iOS blue
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearAllRoutes(); // PRESERVED: Original action
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red), // PRESERVED: Red for destructive
              ),
            ),
          ],
        );
      },
    );
  }

  /// PRESERVED: Clear all routes - EXACT SAME LOGIC
  Future<void> _clearAllRoutes() async {
    try {
      final success = await RouteStorageService.clearAllRoutes();
      
      if (success && mounted) {
        setState(() {
          _savedRoutes.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All routes cleared'),
            backgroundColor: const Color(0xFF34C759), // PRESERVED: iOS green
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error clearing routes: $e');
      }
    }
  }
}