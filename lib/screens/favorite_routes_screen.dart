// lib/screens/favorite_routes_screen.dart
//
// Favorite Routes screen - CONSERVATIVE Theme Update
// ✅ PRESERVES: All existing functionality - loading, favorites, navigation
// ✅ CHANGES: Only hardcoded colors to use theme provider
// ✅ KEEPS: All logic, methods, UI structure, and behavior identical

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_route_model.dart';
import '../services/route_storage_service.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart'; // NEW: Only for theme colors
import 'route_results_screen.dart';

class FavoriteRoutesScreen extends StatefulWidget {
  const FavoriteRoutesScreen({super.key});

  @override
  State<FavoriteRoutesScreen> createState() => _FavoriteRoutesScreenState();
}

class _FavoriteRoutesScreenState extends State<FavoriteRoutesScreen> {
  // PRESERVED: All existing state variables
  List<SavedRoute> _favoriteRoutes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteRoutes();
  }

  /// PRESERVED: Load favorite routes from storage - EXACT SAME LOGIC
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
          'Favorite Routes',
          style: TextStyle(
            // CHANGED: Theme-aware text color instead of Colors.white
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
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
            color: Color(0xFF34C759),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading favorite routes...',
            style: TextStyle(
              // CHANGED: Theme-aware text color
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
    if (_favoriteRoutes.isEmpty) {
      return _buildEmptyState(themeProvider);
    }

    return Column(
      children: [
        _buildStatsHeader(themeProvider),
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
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF34C759).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.favorite,
                color: Color(0xFF34C759),
                size: 50,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'No Favorite Routes',
              style: TextStyle(
                // CHANGED: Theme-aware text color
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Mark routes as favorites to see them here for quick access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                // CHANGED: Theme-aware secondary text color
                color: themeProvider.currentTheme == AppThemeMode.dark 
                  ? Colors.grey[400] 
                  : Colors.grey[600],
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Stats Header - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildStatsHeader(ThemeProvider themeProvider) {
    final totalFavorites = _favoriteRoutes.length;
    
    // Calculate total distance
    double totalDistance = 0.0;
    for (final route in _favoriteRoutes) {
      final distanceString = route.routeResult.totalDistance;
      String numericPart = '';
      bool foundDecimal = false;
      
      for (int i = 0; i < distanceString.length; i++) {
        String char = distanceString[i];
        if ('0123456789'.contains(char)) {
          numericPart += char;
        } else if (char == '.' && !foundDecimal) {
          numericPart += char;
          foundDecimal = true;
        } else if (numericPart.isNotEmpty) {
          break;
        }
      }
      
      if (numericPart.isNotEmpty) {
        totalDistance += double.tryParse(numericPart) ?? 0.0;
      }
    }
    
    // Find most recent route
    String mostRecentText = 'None';
    if (_favoriteRoutes.isNotEmpty) {
      final now = DateTime.now();
      final mostRecent = _favoriteRoutes.first.savedAt;
      final difference = now.difference(mostRecent);
      
      if (difference.inDays > 0) {
        mostRecentText = '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        mostRecentText = '${difference.inHours}h ago';
      } else {
        mostRecentText = '${difference.inMinutes}m ago';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // CHANGED: Theme-aware card color
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Saved Routes
          Expanded(
            child: Column(
              children: [
                Text(
                  totalFavorites.toString(),
                  style: const TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Saved Routes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // CHANGED: Theme-aware secondary text color
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          
          // Total Distance
          Expanded(
            child: Column(
              children: [
                Text(
                  '${totalDistance.toStringAsFixed(1)} mi',
                  style: const TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Distance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // CHANGED: Theme-aware secondary text color
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          
          // Most Recent
          Expanded(
            child: Column(
              children: [
                Text(
                  mostRecentText,
                  style: const TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Most\nRecent',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // CHANGED: Theme-aware secondary text color
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Route List - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildRouteList(ThemeProvider themeProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _favoriteRoutes.length,
      itemBuilder: (context, index) {
        final route = _favoriteRoutes[index];
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
          onTap: () => _loadRoute(route),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route name
                      Text(
                        route.name,
                        style: TextStyle(
                          // CHANGED: Theme-aware text color
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Distance and time
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34C759).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              route.routeResult.totalDistance,
                              style: const TextStyle(
                                color: Color(0xFF34C759),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          Text(
                            route.routeResult.estimatedTime,
                            style: TextStyle(
                              // CHANGED: Theme-aware secondary text color
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
                        route.formattedDate,
                        style: TextStyle(
                          // CHANGED: Theme-aware tertiary text color
                          color: themeProvider.currentTheme == AppThemeMode.dark 
                            ? Colors.grey[500] 
                            : Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Route preview
                      Text(
                        _getRouteStopsPreview(route),
                        style: TextStyle(
                          // CHANGED: Theme-aware secondary text color
                          color: themeProvider.currentTheme == AppThemeMode.dark 
                            ? Colors.grey[400] 
                            : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Remove from Favorites button
                GestureDetector(
                  onTap: () => _removeFavorite(route),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.favorite_border,
                      // CHANGED: Theme-aware icon color
                      color: themeProvider.currentTheme == AppThemeMode.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[600],
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - Helper Methods - PRESERVED EXACT LOGIC

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

  /// PRESERVED: Remove from favorites - EXACT SAME LOGIC
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
            backgroundColor: Color(0xFF34C759),
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