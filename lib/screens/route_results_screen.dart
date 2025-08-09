// lib/screens/route_results_screen.dart
//
// Route results display screen - EXACT iOS App Design Match
// Shows optimized route with Summary card, Route Map, and Your Path sections
// MINIMAL UPDATE: Just replaced Google Maps button with Export Route modal

import 'package:flutter/material.dart';

import '../models/route_models.dart';
import '../models/saved_route_model.dart';
import '../utils/constants.dart';
import '../widgets/route_map_widget.dart';
import '../widgets/navigation_export_modal.dart';  // NEW: Import navigation modal
import '../services/route_storage_service.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Your Route',  // Changed from "Route Results" to match iOS
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,  // Large iOS title style
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,  // Left-aligned like iOS
      ),
      body: Column(
        children: [
          // MARK: - Main Content (scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MARK: - Summary Card (ORIGINAL STYLING)
                  _buildSummaryCard(),
                  
                  const SizedBox(height: 24),
                  
                  // MARK: - Route Map Section (ORIGINAL STYLING)
                  _buildRouteMapSection(),
                  
                  const SizedBox(height: 24),
                  
                  // MARK: - Your Path Section (ORIGINAL STYLING)
                  _buildYourPathSection(),
                  
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
          
          // MARK: - Bottom Action Buttons (MINIMAL CHANGE - just button text/function)
          _buildBottomActionButtons(context),
        ],
      ),
    );
  }

  // MARK: - Summary Card (ORIGINAL STYLING - Simple "Summary" title, no badge)
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple header - ORIGINAL STYLE
          const Text(
            'Summary',  // ORIGINAL: Not "Route Summary"
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // NO "OPTIMIZED" badge - ORIGINAL STYLE
          
          const SizedBox(height: 16),
          
          // Stats row - ORIGINAL STYLE
          Row(
            children: [
              // Total distance
              Expanded(
                child: _buildStatItem(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: widget.routeResult.totalDistance,
                ),
              ),
              
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[700],
              ),
              
              // Total time
              Expanded(
                child: _buildStatItem(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: widget.routeResult.estimatedTime,
                ),
              ),
              
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[700],
              ),
              
              // Number of stops
              Expanded(
                child: _buildStatItem(
                  icon: Icons.location_on,
                  label: 'Stops',
                  value: '${widget.routeResult.optimizedStops.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ORIGINAL: Stat item styling with original colors
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    // Restore original icon colors
    Color iconColor;
    switch (icon) {
      case Icons.straighten:
        iconColor = const Color(0xFF34C759); // Green for distance
        break;
      case Icons.access_time:
        iconColor = Colors.orange; // Orange for time
        break;
      case Icons.location_on:
        iconColor = Colors.grey; // Gray for stops
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // MARK: - Route Map Section (ORIGINAL STYLING - no overlay traffic button)
  Widget _buildRouteMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header - ORIGINAL STYLE
        const Text(
          'Route Map',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Real Google Maps integration - ORIGINAL STYLE
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

  // MARK: - Your Path Section (ORIGINAL STYLING)
  Widget _buildYourPathSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with route icon - ORIGINAL STYLE
        Row(
          children: [
            Icon(
              Icons.route,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Your Path',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Route stops list
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
          );
        }).toList(),
      ],
    );
  }

  // MARK: - Path Stop Item (ORIGINAL STYLING)
  Widget _buildPathStopItem({
    required RouteStop stop,
    required int index,
    required bool isFirst,
    required bool isLast,
  }) {
    // Determine button color and text based on position - ORIGINAL LOGIC
    Color buttonColor;
    String buttonText;
    
    if (isFirst) {
      buttonColor = const Color(0xFF34C759); // iOS green
      buttonText = 'START';
    } else if (isLast) {
      buttonColor = const Color(0xFFFF3B30); // iOS red
      buttonText = 'END';
    } else {
      buttonColor = const Color(0xFF007AFF); // iOS blue
      buttonText = 'STOP';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Numbered circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Stop details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business/location name
                Text(
                  stop.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Address
                Text(
                  stop.address,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Distance and time to next stop (if not last)
                if (!isLast && index < widget.routeResult.legs.length) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.straighten,
                        color: Colors.grey[500],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.routeResult.legs[index].distance.text,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        color: Colors.grey[500],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.routeResult.legs[index].duration.text,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Action button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Bottom Action Buttons (MINIMAL CHANGE - just replace Google Maps button)
  Widget _buildBottomActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: Colors.grey[800]!,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Save Route button (ORIGINAL STYLING)
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isFavorited ? const Color(0xFF34C759) : Colors.white,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  color: _isFavorited ? const Color(0xFF34C759).withOpacity(0.1) : null,
                ),
                child: TextButton(
                  onPressed: _isTogglingFavorite ? null : _toggleRouteAsFavorite,
                  style: TextButton.styleFrom(
                    foregroundColor: _isFavorited ? const Color(0xFF34C759) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isTogglingFavorite) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
            
            // MINIMAL CHANGE: Export Route button (was Google Maps button)
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
                  onPressed: () => _showExportOptions(context), // CHANGED: was _exportToGoogleMaps
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
                        Icons.navigation, // CHANGED: was Icons.map
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Export Route', // CHANGED: was 'Google Maps'
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

  // NEW: Show Export Options Modal
  Future<void> _showExportOptions(BuildContext context) async {
    await NavigationExportModal.show(
      context: context,
      routeResult: widget.routeResult,
      originalInputs: widget.originalInputs,
    );
  }

  // MARK: - Save/Favorite Route Functionality (ORIGINAL LOGIC)
  Future<void> _toggleRouteAsFavorite() async {
    if (_isTogglingFavorite) return;

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      if (_savedRoute != null) {
        // Route already exists, toggle favorite status
        final updatedRoute = _savedRoute!.copyWith(
          isFavorite: !_savedRoute!.isFavorite,
        );
        
        await RouteStorageService.updateRoute(updatedRoute);
        
        setState(() {
          _isFavorited = updatedRoute.isFavorite;
          _savedRoute = updatedRoute;
        });
      } else {
        // Route doesn't exist, create new saved route
        final newRoute = await RouteStorageService.saveRoute(
          routeResult: widget.routeResult,
          originalInputs: widget.originalInputs,
        );
        
        // Now mark it as favorite
        final favoriteRoute = newRoute.copyWith(isFavorite: true);
        await RouteStorageService.updateRoute(favoriteRoute);
        
        setState(() {
          _isFavorited = true;
          _savedRoute = favoriteRoute;
        });
      }

      // Show success feedback
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
      
      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Failed to save route. Please try again.'),
            ],
          ),
          backgroundColor: Color(0xFFFF3B30),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isTogglingFavorite = false;
      });
    }
  }
}