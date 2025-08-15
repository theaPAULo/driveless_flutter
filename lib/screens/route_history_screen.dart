// lib/screens/route_history_screen.dart
//
// ✨ ENHANCED Route History Screen with Professional Empty States
// ✅ UPDATED: Uses new EnhancedEmptyState system for better UX
// ✅ PRESERVES: All existing functionality, logic, and methods
// ✅ ADDS: Engaging empty state with tips, illustrations, and clear actions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_route_model.dart';
import '../services/route_storage_service.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart';
import '../widgets/empty_states.dart'; // NEW: Enhanced empty state widget
import 'route_results_screen.dart';

class RouteHistoryScreen extends StatefulWidget {
  const RouteHistoryScreen({super.key});

  @override
  State<RouteHistoryScreen> createState() => _RouteHistoryScreenState();
}

class _RouteHistoryScreenState extends State<RouteHistoryScreen> {
  List<SavedRoute> _savedRoutes = [];
  List<SavedRoute> _filteredRoutes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedRoutes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // MARK: - Data Loading Methods
  Future<void> _loadSavedRoutes() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final routes = await RouteStorageService.getAllSavedRoutes();
      routes.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      
      if (mounted) {
        setState(() {
          _savedRoutes = routes;
          _filteredRoutes = routes;
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

  // MARK: - Search Functionality
  void _filterRoutes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredRoutes = _savedRoutes;
      } else {
        _filteredRoutes = _savedRoutes.where((route) {
          // Search in route name
          if (route.name.toLowerCase().contains(query.toLowerCase())) {
            return true;
          }
          
          // Search in route stops display names
          final stops = route.routeResult.optimizedStops;
          for (final stop in stops) {
            if (stop.displayName.toLowerCase().contains(query.toLowerCase()) ||
                stop.address.toLowerCase().contains(query.toLowerCase())) {
              return true;
            }
          }
          
          return false;
        }).toList();
      }
    });
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
          'Route History',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: _savedRoutes.isNotEmpty ? [
          IconButton(
            icon: Icon(
              Icons.delete_sweep,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onPressed: _showClearAllConfirmation,
          ),
        ] : null,
      ),
      body: _isLoading 
        ? _buildLoadingState(themeProvider) 
        : _buildContent(themeProvider),
    );
  }

  // MARK: - Loading State
  Widget _buildLoadingState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF34C759)),
          const SizedBox(height: 16),
          Text(
            'Loading route history...',
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

  // MARK: - Main Content
  Widget _buildContent(ThemeProvider themeProvider) {
    if (_savedRoutes.isEmpty) {
      // ✨ NEW: Use Enhanced Empty State instead of basic empty state
      return EnhancedEmptyState(
        type: EmptyStateType.routeHistory,
        onActionPressed: () {
          // Navigate back to route input screen (main tab)
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    }

    return Column(
      children: [
        if (_savedRoutes.length > 3) _buildSearchBar(themeProvider),
        _buildStatsHeader(themeProvider),
        Expanded(child: _buildRouteList(themeProvider)),
      ],
    );
  }

  // MARK: - Search Bar
  Widget _buildSearchBar(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _filterRoutes,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        decoration: InputDecoration(
          hintText: 'Search routes...',
          hintStyle: TextStyle(
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.grey[500] 
              : Colors.grey[400],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.grey[500] 
              : Colors.grey[400],
          ),
          filled: true,
          fillColor: themeProvider.currentTheme == AppThemeMode.dark 
            ? Colors.grey[800] 
            : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // MARK: - Stats Header
  Widget _buildStatsHeader(ThemeProvider themeProvider) {
    final totalMiles = _savedRoutes.fold<double>(
      0.0, 
      (sum, route) => sum + _parseDistanceFromString(route.routeResult.totalDistance),
    );
    
    final mostRecentRoute = _savedRoutes.isNotEmpty ? _savedRoutes.first : null;
    final daysSinceLastRoute = mostRecentRoute != null 
      ? DateTime.now().difference(mostRecentRoute.savedAt).inDays 
      : 0;

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
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '${_savedRoutes.length}',
                  style: const TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total\nRoutes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.grey[600] 
              : Colors.grey[300],
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${totalMiles.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Miles\nOptimized',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.grey[600] 
              : Colors.grey[300],
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  daysSinceLastRoute == 0 
                    ? 'Today' 
                    : '${daysSinceLastRoute}d ago',
                  style: const TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Most Recent',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
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

  // MARK: - Route List
  Widget _buildRouteList(ThemeProvider themeProvider) {
    if (_filteredRoutes.isEmpty && _searchQuery.isNotEmpty) {
      return EnhancedEmptyState(
        type: EmptyStateType.searchResults,
        customTitle: 'No Matching Routes',
        customMessage: 'No routes found matching "$_searchQuery". Try different search terms or check your spelling.',
        onActionPressed: () {
          _searchController.clear();
          _filterRoutes('');
        },
        actionButtonText: 'Clear Search',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredRoutes.length,
      itemBuilder: (context, index) {
        final route = _filteredRoutes[index];
        return _buildRouteCard(route, themeProvider);
      },
    );
  }

  // MARK: - Route Card
  Widget _buildRouteCard(SavedRoute route, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeProvider.currentTheme == AppThemeMode.dark 
          ? Colors.grey[800]?.withOpacity(0.3) 
          : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                        color: const Color(0xFF34C759).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.map,
                        color: Color(0xFF34C759),
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
                      icon: Icon(
                        route.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: route.isFavorite ? Colors.red : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStopsList(route),
                const SizedBox(height: 8),
                Text(
                  '${route.savedAt.month}/${route.savedAt.day}/${route.savedAt.year} • ${route.savedAt.hour}:${route.savedAt.minute.toString().padLeft(2, '0')}',
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

  // MARK: - Stops List Builder
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

  // MARK: - Helper Methods
  double _parseDistanceFromString(String distanceString) {
    final RegExp regex = RegExp(r'(\d+\.?\d*)');
    final match = regex.firstMatch(distanceString);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '0') ?? 0.0;
    }
    return 0.0;
  }

  String _getCleanLocationName(String fullName) {
    if (fullName.isEmpty) return 'Unknown Location';
    
    if (fullName.contains(',')) {
      final parts = fullName.split(',');
      final firstPart = parts[0].trim();
      
      if (!RegExp(r'^\d+\s').hasMatch(firstPart) && firstPart.length > 3) {
        return firstPart;
      }
    }
    
    return fullName.length > 25 
        ? '${fullName.substring(0, 22)}...'
        : fullName;
  }

  // MARK: - Actions
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
      final updatedRoute = route.copyWith(isFavorite: !route.isFavorite);
      final success = await RouteStorageService.updateRoute(updatedRoute);
      
      if (success && mounted) {
        setState(() {
          final index = _savedRoutes.indexWhere((r) => r.id == route.id);
          if (index != -1) {
            _savedRoutes[index] = updatedRoute;
          }
          final filteredIndex = _filteredRoutes.indexWhere((r) => r.id == route.id);
          if (filteredIndex != -1) {
            _filteredRoutes[filteredIndex] = updatedRoute;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedRoute.isFavorite 
                  ? 'Route added to favorites'
                  : 'Route removed from favorites',
            ),
            backgroundColor: const Color(0xFF34C759),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Route favorite toggled: ${route.name}');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error toggling favorite: $e');
      }
    }
  }

  Future<void> _showClearAllConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Routes'),
        content: const Text('Are you sure you want to delete all saved routes? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _clearAllRoutes();
    }
  }

  Future<void> _clearAllRoutes() async {
    try {
      await RouteStorageService.clearAllRoutes();
      await _loadSavedRoutes();
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ All routes cleared');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error clearing routes: $e');
      }
    }
  }
}