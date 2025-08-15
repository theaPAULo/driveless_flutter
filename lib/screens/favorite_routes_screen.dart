// lib/screens/favorite_routes_screen.dart
//
// Favorite Routes screen - FIXED PROPERTY NAMES
// ✅ FIXED: Use savedAt instead of createdAt
// ✅ FIXED: Access distance/duration through routeResult
// ✅ IMPROVED: Stats header like Route History (formatted numbers, removed "Most Recent")
// ✅ IMPROVED: Route cards show bulleted stop lists like Route History

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/saved_route_model.dart';
import '../services/route_storage_service.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart';
import 'route_results_screen.dart';

class FavoriteRoutesScreen extends StatefulWidget {
  const FavoriteRoutesScreen({super.key});

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

  Future<void> _loadFavoriteRoutes() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final allRoutes = await RouteStorageService.getAllSavedRoutes();
      final favorites = allRoutes.where((route) => route.isFavorite).toList();
      
      // ✅ FIXED: Sort by savedAt (not createdAt)
      favorites.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Favorite Routes',
          style: TextStyle(
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

  // ✅ IMPROVED: Stats header matching Route History format (no "Most Recent")
  Widget _buildStatsHeader(ThemeProvider themeProvider) {
    // ✅ FIXED: Extract distance from routeResult.totalDistance string
    final totalDistance = _favoriteRoutes.fold<double>(
      0.0, 
      (sum, route) => sum + _extractDistanceFromString(route.routeResult.totalDistance),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ IMPROVED: Formatted number like Route History
          Expanded(
            child: Column(
              children: [
                Text(
                  '${_favoriteRoutes.length}',
                  style: const TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Saved Routes',
                  style: TextStyle(
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // ✅ IMPROVED: Formatted distance like Route History
          Expanded(
            child: Column(
              children: [
                Text(
                  '${totalDistance.toStringAsFixed(1)} mi',
                  style: const TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total Distance',
                  style: TextStyle(
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  // ✅ IMPROVED: Route cards with bulleted stop lists like Route History
  Widget _buildRouteItem(SavedRoute route, ThemeProvider themeProvider) {
    final stopsList = _getRouteStopsList(route);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _loadRoute(route),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with icon and favorite button
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.map,
                        color: Color(0xFF34C759),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        route.name,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _toggleFavorite(route),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // ✅ IMPROVED: Bulleted stop list like Route History
                ...stopsList.map((stop) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8, right: 8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF34C759),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          stop,
                          style: TextStyle(
                            color: themeProvider.currentTheme == AppThemeMode.dark 
                              ? Colors.grey[400] 
                              : Colors.grey[600],
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                
                const SizedBox(height: 12),
                
                // Bottom row with stats and date
                Row(
                  children: [
                    Text(
                      route.routeResult.totalDistance, // ✅ FIXED: Access through routeResult
                      style: const TextStyle(
                        color: Color(0xFF34C759),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.schedule,
                      color: themeProvider.currentTheme == AppThemeMode.dark 
                        ? Colors.grey[500] 
                        : Colors.grey[400],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      route.routeResult.estimatedTime, // ✅ FIXED: Access through routeResult
                      style: TextStyle(
                        color: themeProvider.currentTheme == AppThemeMode.dark 
                          ? Colors.grey[400] 
                          : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d').format(route.savedAt), // ✅ FIXED: Use savedAt
                      style: TextStyle(
                        color: themeProvider.currentTheme == AppThemeMode.dark 
                          ? Colors.grey[500] 
                          : Colors.grey[500],
                        fontSize: 12,
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

  // ✅ IMPROVED: Helper method to get clean stop list like Route History
  List<String> _getRouteStopsList(SavedRoute route) {
    List<String> stops = [];
    
    final optimizedStops = route.routeResult.optimizedStops;
    
    if (optimizedStops.isEmpty) {
      return ['No stops available'];
    }
    
    // Start location
    if (optimizedStops.isNotEmpty) {
      final startName = _extractLocationName(optimizedStops.first.displayName);
      stops.add('$startName (start)');
    }
    
    // Intermediate stops (skip first and last)
    if (optimizedStops.length > 2) {
      final intermediateStops = optimizedStops.sublist(1, optimizedStops.length - 1);
      for (int i = 0; i < intermediateStops.length; i++) {
        final stopName = _extractLocationName(intermediateStops[i].displayName);
        stops.add(stopName);
        
        // Show "and X more stops" if more than 2 intermediate stops
        if (i == 1 && intermediateStops.length > 2) {
          stops.add('... and ${intermediateStops.length - 2} more stops');
          break;
        }
      }
    }
    
    // End location
    if (optimizedStops.length > 1) {
      final endName = _extractLocationName(optimizedStops.last.displayName);
      stops.add('$endName (end)');
    }
    
    return stops;
  }

  // ✅ IMPROVED: Extract clean location names like Route History
  String _extractLocationName(String fullName) {
    if (fullName.isEmpty) return 'Unknown Location';
    
    // Try to extract business name (first part before comma)
    if (fullName.contains(',')) {
      final parts = fullName.split(',');
      final firstPart = parts[0].trim();
      
      // If first part looks like a business name (not just numbers/street)
      if (!RegExp(r'^\d+\s').hasMatch(firstPart) && firstPart.length > 3) {
        return firstPart;
      }
    }
    
    // Fallback: use first 25 characters
    return fullName.length > 25 
        ? '${fullName.substring(0, 25)}...'
        : fullName;
  }

  // ✅ FIXED: Extract distance from string like "28.9 mi"
  double _extractDistanceFromString(String distanceString) {
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
        break; // Stop at first non-numeric character after finding numbers
      }
    }
    
    return double.tryParse(numericPart) ?? 0.0;
  }

  // Action methods
  Future<void> _loadRoute(SavedRoute route) async {
    try {
      // Navigate to route results with saved route data
      // You'll need to convert SavedRoute back to OptimizedRouteResult format
      // This is similar to how it's done in route_history_screen.dart
      
      if (EnvironmentConfig.logApiCalls) {
        print('Loading favorite route: ${route.name}');
      }
      
      // TODO: Implement route loading logic similar to route history
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loading route: ${route.name}'),
          backgroundColor: const Color(0xFF34C759),
        ),
      );
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading route: $e');
      }
    }
  }

  Future<void> _toggleFavorite(SavedRoute route) async {
    try {
      // Update favorite status
      final updatedRoute = route.copyWith(isFavorite: !route.isFavorite);
      await RouteStorageService.updateRoute(updatedRoute);
      
      // Refresh the list
      await _loadFavoriteRoutes();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedRoute.isFavorite 
                ? 'Added to favorites' 
                : 'Removed from favorites',
          ),
          backgroundColor: const Color(0xFF34C759),
        ),
      );
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error toggling favorite: $e');
      }
    }
  }
}