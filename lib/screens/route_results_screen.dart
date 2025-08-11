// lib/screens/route_results_screen.dart
//
// Route results display screen - CONSERVATIVE Theme Update
// ✅ PRESERVES: All existing functionality exactly as it was
// ✅ CHANGES: Only hardcoded colors to use theme provider
// ✅ KEEPS: All logic, methods, UI structure, and behavior identical

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/route_models.dart';
import '../models/saved_route_model.dart';
import '../utils/constants.dart';
import '../widgets/route_map_widget.dart';
import '../widgets/navigation_export_modal.dart';  // Existing import
import '../services/route_storage_service.dart';
import '../providers/theme_provider.dart'; // NEW: Only for theme colors

class RouteResultsScreen extends StatefulWidget {
  final OptimizedRouteResult routeResult;
  final OriginalRouteInputs originalInputs;

  const RouteResultsScreen({
    Key? key,
    required this.routeResult,
    required this.originalInputs,
  }) : super(key: key);

  @override
  State<RouteResultsScreen> createState() => _RouteResultsScreenState();
}

class _RouteResultsScreenState extends State<RouteResultsScreen> {
  bool _trafficEnabled = false; // Traffic toggle state
  bool _isFavorited = false; // Track if route is favorited
  bool _isTogglingFavorite = false; // Track favorite toggle state
  SavedRoute? _savedRoute; // Reference to saved route if exists

  @override
  void initState() {
    super.initState();
    // Initialize traffic state from original inputs
    _trafficEnabled = widget.originalInputs.includeTraffic;
    // Check if route is already saved
    _checkIfRouteFavorited();
  }

  /// Check if current route is already favorited
  Future<void> _checkIfRouteFavorited() async {
    try {
      final SavedRoute? existingRoute = await RouteStorageService.findSimilarRoute(widget.routeResult);
      if (mounted) {
        setState(() {
          _isFavorited = existingRoute?.isFavorite ?? false;
          _savedRoute = existingRoute;
        });
      }
    } catch (e) {
      print('Error checking favorited route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider for colors only
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      // CHANGED: Theme-aware background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // CHANGED: Theme-aware app bar
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            // CHANGED: Theme-aware icon color
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Your Route',  // PRESERVED: Original title
          style: TextStyle(
            // CHANGED: Theme-aware text color
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 34,  // PRESERVED: Original sizing
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,  // PRESERVED: Original alignment
      ),
      body: Column(
        children: [
          // MARK: - Main Content (scrollable) - PRESERVED STRUCTURE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MARK: - Summary Card - PRESERVED LOGIC, UPDATED COLORS
                  _buildSummaryCard(themeProvider),
                  
                  const SizedBox(height: 24),
                  
                  // MARK: - Route Map Section - PRESERVED LOGIC, UPDATED COLORS
                  _buildRouteMapSection(themeProvider),
                  
                  const SizedBox(height: 24),
                  
                  // MARK: - Your Path Section - PRESERVED LOGIC, UPDATED COLORS
                  _buildYourPathSection(themeProvider),
                  
                  const SizedBox(height: 100), // PRESERVED: Space for bottom buttons
                ],
              ),
            ),
          ),
          
          // MARK: - Bottom Action Buttons - PRESERVED LOGIC, UPDATED COLORS
          _buildBottomActionButtons(context, themeProvider),
        ],
      ),
    );
  }

  // MARK: - Summary Card - PRESERVED STRUCTURE, UPDATED COLORS ONLY
  Widget _buildSummaryCard(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // CHANGED: Theme-aware card color instead of hardcoded dark
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PRESERVED: Simple header
          Text(
            'Summary',  // PRESERVED: Original title
            style: TextStyle(
              // CHANGED: Theme-aware text color instead of hardcoded white
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // PRESERVED: No "OPTIMIZED" badge
          
          const SizedBox(height: 16),
          
          // PRESERVED: Stats row structure
          Row(
            children: [
              // Total distance
              Expanded(
                child: _buildStatItem(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: widget.routeResult.totalDistance,
                  themeProvider: themeProvider,
                ),
              ),
              
              Container(
                width: 1,
                height: 40,
                // CHANGED: Theme-aware divider color
                color: themeProvider.currentTheme == AppThemeMode.dark 
                  ? Colors.grey[700] 
                  : Colors.grey[300],
              ),
              
              // Total time
              Expanded(
                child: _buildStatItem(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: widget.routeResult.estimatedTime,
                  themeProvider: themeProvider,
                ),
              ),
              
              Container(
                width: 1,
                height: 40,
                // CHANGED: Theme-aware divider color
                color: themeProvider.currentTheme == AppThemeMode.dark 
                  ? Colors.grey[700] 
                  : Colors.grey[300],
              ),
              
              // Number of stops
              Expanded(
                child: _buildStatItem(
                  icon: Icons.location_on,
                  label: 'Stops',
                  value: '${widget.routeResult.optimizedStops.length}',
                  themeProvider: themeProvider,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // PRESERVED: Original stat item logic with theme-aware colors
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeProvider themeProvider,
  }) {
    // PRESERVED: Original icon color logic
    Color iconColor;
    switch (icon) {
      case Icons.straighten:
        iconColor = const Color(0xFF34C759); // PRESERVED: Green for distance
        break;
      case Icons.access_time:
        iconColor = Colors.orange; // PRESERVED: Orange for time
        break;
      case Icons.location_on:
        // CHANGED: Theme-aware grey instead of hardcoded
        iconColor = themeProvider.currentTheme == AppThemeMode.dark 
          ? Colors.grey[400]! 
          : Colors.grey[600]!;
        break;
      default:
        iconColor = const Color(0xFF34C759);
    }

    return Column(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            // CHANGED: Theme-aware text color instead of hardcoded white
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            // CHANGED: Theme-aware secondary text color
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.grey[400] 
              : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // MARK: - Route Map Section - PRESERVED STRUCTURE, UPDATED COLORS
  Widget _buildRouteMapSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PRESERVED: Section header
        Text(
          'Route Map',
          style: TextStyle(
            // CHANGED: Theme-aware text color instead of hardcoded white
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // PRESERVED: Real Google Maps integration
        RouteMapWidget(
          routeResult: widget.routeResult,
          initialTrafficEnabled: _trafficEnabled,
          onTrafficToggled: (bool enabled) {
            setState(() {
              _trafficEnabled = enabled;
            });
          },
        ),
      ],
    );
  }

  // MARK: - Your Path Section - PRESERVED STRUCTURE, UPDATED COLORS
  Widget _buildYourPathSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PRESERVED: Section header with route icon
        Row(
          children: [
            Icon(
              Icons.route,
              // CHANGED: Theme-aware icon color
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Your Path',
              style: TextStyle(
                // CHANGED: Theme-aware text color instead of hardcoded white
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // PRESERVED: Route stops list structure
        ...widget.routeResult.optimizedStops.asMap().entries.map((entry) {
          final index = entry.key;
          final stop = entry.value;
          final isFirst = index == 0;
          final isLast = index == widget.routeResult.optimizedStops.length - 1;
          
          return _buildPathStopItem(
            stop: stop,
            index: index,
            isFirst: isFirst,
            isLast: isLast,
            themeProvider: themeProvider,
          );
        }).toList(),
      ],
    );
  }

  // MARK: - Path Stop Item - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildPathStopItem({
    required RouteStop stop,
    required int index,
    required bool isFirst,
    required bool isLast,
    required ThemeProvider themeProvider,
  }) {
    // PRESERVED: Original button color and text logic
    Color buttonColor;
    String buttonText;
    
    if (isFirst) {
      buttonColor = const Color(0xFF34C759); // PRESERVED: iOS green
      buttonText = 'START';
    } else if (isLast) {
      buttonColor = const Color(0xFFFF3B30); // PRESERVED: iOS red
      buttonText = 'END';
    } else {
      buttonColor = const Color(0xFF007AFF); // PRESERVED: iOS blue
      buttonText = 'STOP';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // CHANGED: Theme-aware card color instead of hardcoded dark
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // PRESERVED: Numbered circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: buttonColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // PRESERVED: Stop details structure
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FIXED: Use correct property name (displayName)
                Text(
                  stop.displayName.isNotEmpty ? stop.displayName : _extractBusinessName(stop.address),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    // CHANGED: Theme-aware text color
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // PRESERVED: Full address
                Text(
                  stop.address,
                  style: TextStyle(
                    fontSize: 14,
                    // CHANGED: Theme-aware secondary text color
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // PRESERVED: Action button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Bottom Action Buttons - PRESERVED EXACT LOGIC, UPDATED COLORS
  Widget _buildBottomActionButtons(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // CHANGED: Theme-aware background
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            // CHANGED: Theme-aware border color
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.grey[800]! 
              : Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // PRESERVED: Save Route button logic
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isFavorited ? const Color(0xFF34C759) : 
                      (themeProvider.currentTheme == AppThemeMode.dark 
                        ? Colors.white 
                        : Colors.grey[600]!),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  color: _isFavorited ? const Color(0xFF34C759).withOpacity(0.1) : null,
                ),
                child: TextButton(
                  onPressed: _isTogglingFavorite ? null : _toggleRouteAsFavorite,
                  style: TextButton.styleFrom(
                    foregroundColor: _isFavorited ? const Color(0xFF34C759) : 
                      Theme.of(context).textTheme.bodyLarge?.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isTogglingFavorite) ...[
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ] else ...[
                        Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_outline,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _isFavorited ? 'Saved' : 'Save Route',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // PRESERVED: Export Route button (was Google Maps button)
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF34C759), Color(0xFF30A46C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: () => _showExportOptions(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.navigation, // PRESERVED: Export icon
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Export Route', // PRESERVED: Export text
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PRESERVED: Show Export Options Modal - EXACT SAME LOGIC
  Future<void> _showExportOptions(BuildContext context) async {
    await NavigationExportModal.show(
      context: context,
      routeResult: widget.routeResult,
      originalInputs: widget.originalInputs,
    );
  }

  // PRESERVED: Save/Favorite Route Functionality - EXACT SAME LOGIC
  Future<void> _toggleRouteAsFavorite() async {
    if (_isTogglingFavorite) return;

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      if (_savedRoute != null) {
        // PRESERVED: Route already exists, toggle favorite status
        final updatedRoute = _savedRoute!.copyWith(
          isFavorite: !_savedRoute!.isFavorite,
        );
        
        await RouteStorageService.updateRoute(updatedRoute);
        
        setState(() {
          _isFavorited = updatedRoute.isFavorite;
          _savedRoute = updatedRoute;
        });
      } else {
        // PRESERVED: Route doesn't exist, create new saved route
        final newRoute = await RouteStorageService.saveRoute(
          routeResult: widget.routeResult,
          originalInputs: widget.originalInputs,
        );
        
        // PRESERVED: Now mark it as favorite
        final favoriteRoute = newRoute.copyWith(isFavorite: true);
        await RouteStorageService.updateRoute(favoriteRoute);
        
        setState(() {
          _isFavorited = true;
          _savedRoute = favoriteRoute;
        });
      }

      // PRESERVED: Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(_isFavorited ? 'Route saved!' : 'Route removed from favorites'),
            ],
          ),
          backgroundColor: const Color(0xFF34C759),
          duration: const Duration(seconds: 2),
        ),
      );

    } catch (e) {
      print('❌ Error toggling favorite: $e');
      
      // PRESERVED: Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Failed to save route'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingFavorite = false;
        });
      }
    }
  }

  // PRESERVED: Helper Methods - EXACT SAME LOGIC
  String _extractBusinessName(String address) {
    if (address.contains(',')) {
      final firstPart = address.split(',').first.trim();
      // Don't extract if it looks like a street address (contains numbers)
      if (RegExp(r'^\d+\s').hasMatch(firstPart)) {
        return address;
      }
      return firstPart;
    }
    return address;
  }
}