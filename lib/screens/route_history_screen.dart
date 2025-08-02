// lib/screens/route_history_screen.dart
//
// Route History screen matching iOS design
// Displays saved routes with ability to view, reload, favorite, and delete

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../models/saved_route_model.dart';
import '../models/route_models.dart';
import '../services/route_storage_service.dart';
import '../utils/constants.dart';
import 'route_results_screen.dart';

class RouteHistoryScreen extends StatefulWidget {
  const RouteHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RouteHistoryScreen> createState() => _RouteHistoryScreenState();
}

class _RouteHistoryScreenState extends State<RouteHistoryScreen> {
  List<SavedRoute> _savedRoutes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSavedRoutes();
  }

  /// Load saved routes from storage
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

  /// Filter routes based on search query
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Route History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          if (_savedRoutes.isNotEmpty)
            TextButton(
              onPressed: _showClearAllConfirmation,
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  // MARK: - Loading State
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF2E7D32),
          ),
          SizedBox(height: 16),
          Text(
            'Loading route history...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Main Content
  Widget _buildContent() {
    if (_savedRoutes.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Search Bar
        if (_savedRoutes.length > 3) _buildSearchBar(),
        
        // Stats Header
        _buildStatsHeader(),
        
        // Route List
        Expanded(
          child: _buildRouteList(),
        ),
      ],
    );
  }

  // MARK: - Empty State
  Widget _buildEmptyState() {
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
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.history,
                color: Color(0xFF2E7D32),
                size: 50,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Empty State Title
            const Text(
              'No Route History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Empty State Description
            Text(
              'Start planning routes to see your history here. Saved routes will appear automatically for quick access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Back to Planning Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Plan Your First Route',
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

  // MARK: - Search Bar
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search routes...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          filled: true,
          fillColor: const Color(0xFF2C2C2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // MARK: - Stats Header
  Widget _buildStatsHeader() {
    final totalRoutes = _savedRoutes.length;
    final favoriteRoutes = _savedRoutes.where((r) => r.isFavorite).length;
    final filteredCount = filteredRoutes.length;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Total Routes
          Column(
            children: [
              Text(
                '$totalRoutes',
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          // Divider
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[600],
          ),
          
          // Favorite Routes
          Column(
            children: [
              Text(
                '$favoriteRoutes',
                style: TextStyle(
                  color: favoriteRoutes > 0 ? const Color(0xFFFF9500) : Colors.grey[600],
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Favorites',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          // Divider
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[600],
          ),
          
          // Filtered Count (if searching)
          Column(
            children: [
              Text(
                _searchQuery.isNotEmpty ? '$filteredCount' : '${DateTime.now().month}/${DateTime.now().day}',
                style: const TextStyle(
                  color: Color(0xFF007AFF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _searchQuery.isNotEmpty ? 'Found' : 'Today',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Route List
  Widget _buildRouteList() {
    final routes = filteredRoutes;
    
    if (routes.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                color: Colors.grey[600],
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'No routes found',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        return _buildRouteCard(routes[index], index);
      },
    );
  }

  // MARK: - Route Card
  Widget _buildRouteCard(SavedRoute route, int index) {
    final stopCount = route.routeResult.optimizedStops.length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _loadRoute(route),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Route Name
                    Expanded(
                      child: Text(
                        route.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Actions Row
                    Row(
                      children: [
                        // Favorite Button
                        GestureDetector(
                          onTap: () => _toggleFavorite(route),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              route.isFavorite ? Icons.favorite : Icons.favorite_outline,
                              color: route.isFavorite ? const Color(0xFFFF9500) : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ),
                        
                        // More Options Button
                        GestureDetector(
                          onTap: () => _showRouteOptions(route),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Route Info Row
                Row(
                  children: [
                    // Stop Count
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$stopCount stops',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Distance and Time
                    Text(
                      '${route.routeResult.totalDistance} • ${route.routeResult.estimatedTime}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Date
                Text(
                  route.formattedDate,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Route Stops Preview
                Text(
                  _getRouteStopsPreview(route),
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - Helper Methods

  /// Get a preview of route stops
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

  /// Load a route (navigate to results screen)
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

  /// Toggle favorite status
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
        
        // Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedRoute.isFavorite 
                  ? 'Added to favorites' 
                  : 'Removed from favorites',
            ),
            backgroundColor: const Color(0xFF2E7D32),
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

  /// Show route options menu
  void _showRouteOptions(SavedRoute route) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Route Name
                Text(
                  route.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Options
                _buildOptionItem(
                  icon: Icons.visibility,
                  title: 'View Route',
                  onTap: () {
                    Navigator.pop(context);
                    _loadRoute(route);
                  },
                ),
                
                _buildOptionItem(
                  icon: route.isFavorite ? Icons.favorite : Icons.favorite_outline,
                  title: route.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                  color: route.isFavorite ? const Color(0xFFFF9500) : null,
                  onTap: () {
                    Navigator.pop(context);
                    _toggleFavorite(route);
                  },
                ),
                
                _buildOptionItem(
                  icon: Icons.delete_outline,
                  title: 'Delete Route',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(route);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build option item for bottom sheet
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Show delete confirmation
  void _showDeleteConfirmation(SavedRoute route) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text(
            'Delete Route',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${route.name}"? This action cannot be undone.',
            style: TextStyle(color: Colors.grey[400]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF007AFF)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteRoute(route);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Delete a route
  Future<void> _deleteRoute(SavedRoute route) async {
    try {
      final success = await RouteStorageService.deleteRoute(route.id);
      
      if (success && mounted) {
        setState(() {
          _savedRoutes.removeWhere((r) => r.id == route.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Route deleted'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error deleting route: $e');
      }
    }
  }

  /// Show clear all confirmation
  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text(
            'Clear All Routes',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete all ${_savedRoutes.length} saved routes? This action cannot be undone.',
            style: TextStyle(color: Colors.grey[400]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF007AFF)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearAllRoutes();
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Clear all routes
  Future<void> _clearAllRoutes() async {
    try {
      final success = await RouteStorageService.clearAllRoutes();
      
      if (success && mounted) {
        setState(() {
          _savedRoutes.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All routes cleared'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 2),
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