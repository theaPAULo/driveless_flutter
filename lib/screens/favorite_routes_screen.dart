// lib/screens/favorite_routes_screen.dart
//
// Favorite Routes screen - filtered view of saved routes
// Shows only routes marked as favorites with quick access

import 'package:flutter/material.dart';

import '../models/saved_route_model.dart';
import '../services/route_storage_service.dart';
import '../utils/constants.dart';
import 'route_results_screen.dart';

class FavoriteRoutesScreen extends StatefulWidget {
  const FavoriteRoutesScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteRoutesScreen> createState() => _FavoriteRoutesScreenState();
}

class _FavoriteRoutesScreenState extends State<FavoriteRoutesScreen> {
  List<SavedRoute> _favoriteRoutes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteRoutes();
  }

  /// Load favorite routes from storage
  Future<void> _loadFavoriteRoutes() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final allRoutes = await RouteStorageService.getAllSavedRoutes();
      final favorites = allRoutes.where((route) => route.isFavorite).toList();
      
      if (mounted) {
        setState(() {
          _favoriteRoutes = favorites;
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
        print('❌ Error loading favorite routes: $e');
      }
    }
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
          'Favorite Routes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
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
            color: Color(0xFFFF9500),
          ),
          SizedBox(height: 16),
          Text(
            'Loading favorite routes...',
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
    if (_favoriteRoutes.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Stats Header
        _buildStatsHeader(),
        
        // Favorite Routes List
        Expanded(
          child: _buildFavoriteRoutesList(),
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
                color: const Color(0xFFFF9500).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.favorite_outline,
                color: Color(0xFFFF9500),
                size: 50,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Empty State Title
            const Text(
              'No Favorite Routes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Empty State Description
            Text(
              'Mark routes as favorites for quick access. Tap the heart icon on any saved route to add it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Back to History Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9500),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'View All Routes',
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

  // MARK: - Stats Header
  Widget _buildStatsHeader() {
    final totalFavorites = _favoriteRoutes.length;
    final recentFavorites = _favoriteRoutes.where((route) {
      final difference = DateTime.now().difference(route.savedAt);
      return difference.inDays <= 7;
    }).length;
    
    return Container(
      margin: const EdgeInsets.all(20),
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
          // Total Favorites
          Column(
            children: [
              Text(
                '$totalFavorites',
                style: const TextStyle(
                  color: Color(0xFFFF9500),
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
          
          // Recent Favorites
          Column(
            children: [
              Text(
                '$recentFavorites',
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'This Week',
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
          
          // Quick Access
          Column(
            children: [
              const Icon(
                Icons.bolt,
                color: Color(0xFF007AFF),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                'Quick',
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

  // MARK: - Favorite Routes List
  Widget _buildFavoriteRoutesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _favoriteRoutes.length,
      itemBuilder: (context, index) {
        return _buildFavoriteRouteCard(_favoriteRoutes[index]);
      },
    );
  }

  // MARK: - Favorite Route Card
  Widget _buildFavoriteRouteCard(SavedRoute route) {
    final stopCount = route.routeResult.optimizedStops.length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF9500).withOpacity(0.3),
          width: 1,
        ),
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
                    // Route Name with Favorite Icon
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Color(0xFFFF9500),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
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
                        ],
                      ),
                    ),
                    
                    // Quick Load Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Load',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                
                const SizedBox(height: 8),
                
                // Last Used
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saved ${route.formattedDate}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    
                    // Remove from Favorites
                    GestureDetector(
                      onTap: () => _removeFavorite(route),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.grey[600],
                          size: 16,
                        ),
                      ),
                    ),
                  ],
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

  /// Remove from favorites
  Future<void> _removeFavorite(SavedRoute route) async {
    try {
      final updatedRoute = route.copyWith(isFavorite: false);
      final success = await RouteStorageService.updateRoute(updatedRoute);
      
      if (success && mounted) {
        setState(() {
          _favoriteRoutes.removeWhere((r) => r.id == route.id);
        });
        
        // Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error removing favorite: $e');
      }
    }
  }
}