// lib/screens/favorite_routes_screen.dart
//
// ✨ ENHANCED Favorite Routes Screen with Professional Empty States
// ✅ UPDATED: Uses new EnhancedEmptyState system for better UX
// ✅ PRESERVES: All existing functionality, logic, and methods
// ✅ ADDS: Engaging empty state that guides users to Route History

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_route_model.dart';
import '../services/route_storage_service.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart';
import '../widgets/empty_states.dart'; // NEW: Enhanced empty state widget
import 'route_results_screen.dart';
import 'route_history_screen.dart'; // NEW: For navigation to route history
import 'route_input_screen.dart';
import 'main_tab_view.dart';

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
      body: _isLoading 
        ? _buildLoadingState(themeProvider) 
        : _buildContent(themeProvider),
    );
  }

  // MARK: - Loading State (Preserved)
  Widget _buildLoadingState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.red),
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

  // MARK: - Main Content (Updated to use Enhanced Empty State)
  Widget _buildContent(ThemeProvider themeProvider) {
    if (_favoriteRoutes.isEmpty) {
      // ✨ NEW: Use Enhanced Empty State instead of basic empty state
      return EnhancedEmptyState(
        type: EmptyStateType.favoriteRoutes,
        actionButtonText: 'Plan New Route',
        onActionPressed: () {
          // Navigate directly to main tab view with Search tab selected
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MainTabView(),
            ),
            (route) => false, // Remove all previous routes
          );
        },
      );
    }

    return Column(
      children: [
        _buildStatsHeader(themeProvider),
        Expanded(child: _buildFavoritesList(themeProvider)),
      ],
    );
  }

  // MARK: - Stats Header (Simplified)
  Widget _buildStatsHeader(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.currentTheme == AppThemeMode.dark 
          ? Colors.grey[800]?.withOpacity(0.3) 
          : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                '${_favoriteRoutes.length}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Favorite Routes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to parse distance from string like "15.1 miles"
  double _parseDistanceFromString(String distanceString) {
    final RegExp regex = RegExp(r'(\d+\.?\d*)');
    final match = regex.firstMatch(distanceString);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '0') ?? 0.0;
    }
    return 0.0;
  }

  // Helper method to get clean location name
  String _getCleanLocationName(String fullName) {
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
        ? '${fullName.substring(0, 22)}...'
        : fullName;
  }

  // MARK: - PRESERVED Favorites List
  Widget _buildFavoritesList(ThemeProvider themeProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _favoriteRoutes.length,
      itemBuilder: (context, index) {
        final route = _favoriteRoutes[index];
        return _buildFavoriteRouteCard(route, themeProvider);
      },
    );
  }

  // MARK: - PRESERVED Route Card Build Method
  Widget _buildFavoriteRouteCard(SavedRoute route, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeProvider.currentTheme == AppThemeMode.dark 
          ? Colors.grey[800]?.withOpacity(0.3) 
          : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route.name,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.straighten,
                                color: themeProvider.currentTheme == AppThemeMode.dark 
                                  ? Colors.grey[500] 
                                  : Colors.grey[400],
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                route.routeResult.totalDistance,
                                style: TextStyle(
                                  color: themeProvider.currentTheme == AppThemeMode.dark 
                                    ? Colors.grey[400] 
                                    : Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time,
                                color: themeProvider.currentTheme == AppThemeMode.dark 
                                  ? Colors.grey[500] 
                                  : Colors.grey[400],
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                route.routeResult.estimatedTime,
                                style: TextStyle(
                                  color: themeProvider.currentTheme == AppThemeMode.dark 
                                    ? Colors.grey[400] 
                                    : Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _toggleFavorite(route),
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStopsList(route),
                const SizedBox(height: 8),
                Text(
                  'Favorited ${route.savedAt.month}/${route.savedAt.day}/${route.savedAt.year}',
                  style: TextStyle(
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[500] 
                      : Colors.grey[400],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - PRESERVED Stops List Builder
  Widget _buildStopsList(SavedRoute route) {
    final stops = route.routeResult.optimizedStops;
    if (stops.isEmpty) {
      return Text(
        'No stops available',
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          fontSize: 13,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stops.take(4).map((stop) {
        final displayName = stop.displayName.isNotEmpty ? stop.displayName : stop.address;
        final cleanName = _getCleanLocationName(displayName);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Text(
                '•',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cleanName,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // MARK: - PRESERVED Actions - ALL EXISTING FUNCTIONALITY

  Future<void> _loadRoute(SavedRoute route) async {
    try {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RouteResultsScreen(
              routeResult: route.routeResult,
              originalInputs: route.originalInputs,
            ),
          ),
        );
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading route: $e');
      }
    }
  }

  Future<void> _toggleFavorite(SavedRoute route) async {
    try {
      final updatedRoute = route.copyWith(isFavorite: false);
      final success = await RouteStorageService.updateRoute(updatedRoute);
      
      if (success && mounted) {
        setState(() {
          _favoriteRoutes.removeWhere((r) => r.id == route.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Route removed from favorites'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () async {
                // Re-favorite the route
                final revertedRoute = updatedRoute.copyWith(isFavorite: true);
                final revertSuccess = await RouteStorageService.updateRoute(revertedRoute);
                if (revertSuccess && mounted) {
                  await _loadFavoriteRoutes(); // Reload to get proper order
                }
              },
            ),
          ),
        );
      }
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Route unfavorited: ${route.name}');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error toggling favorite: $e');
      }
    }
  }
}