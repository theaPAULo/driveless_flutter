// lib/screens/route_results_screen.dart
//
// Route results display screen - EXACT iOS App Design Match
// Shows optimized route with Summary card, Route Map, and Your Path sections
// Now with functional traffic toggle, route polylines, Google Maps export, and Save Route

import 'package:flutter/material.dart';

import '../models/route_models.dart';
import '../models/saved_route_model.dart';
import '../utils/constants.dart';
import '../widgets/route_map_widget.dart';
import '../services/google_maps_export_service.dart';
import '../services/route_storage_service.dart';  // Import storage service

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
                  // MARK: - Summary Card (iOS Style)
                  _buildSummaryCard(),
                  
                  const SizedBox(height: 24),
                  
                  // MARK: - Route Map Section
                  _buildRouteMapSection(),
                  
                  const SizedBox(height: 24),
                  
                  // MARK: - Your Path Section
                  _buildYourPathSection(),
                  
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
          
          // MARK: - Bottom Action Buttons (Fixed at bottom)
          _buildBottomActionButtons(context),
        ],
      ),
    );
  }
  
  // MARK: - Google Maps Export Functionality
  Future<void> _exportToGoogleMaps(BuildContext context) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Opening Google Maps...'),
          ],
        ),
        backgroundColor: Color(0xFF34C759),
        duration: Duration(seconds: 2),
      ),
    );
    
    try {
      // Export route to Google Maps
      final bool success = await GoogleMapsExportService.exportRouteToGoogleMaps(
        routeResult: widget.routeResult,
        originalInputs: widget.originalInputs,
      );
      
      if (success) {
        // Success feedback
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Route opened in Google Maps!'),
              ],
            ),
            backgroundColor: Color(0xFF34C759),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Error feedback
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Could not open Google Maps. Please install the app or try again.'),
                ),
              ],
            ),
            backgroundColor: Color(0xFFFF3B30), // iOS red
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Exception handling
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error opening Google Maps: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFF3B30), // iOS red
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
// MARK: - Favorite Toggle Functionality
/// Toggle favorite status of the route
Future<void> _toggleFavorite(BuildContext context) async {
  setState(() {
    _isTogglingFavorite = true;
  });

  try {
    SavedRoute routeToUpdate;
    
    if (_savedRoute == null) {
      // Route doesn't exist in storage yet, create it as favorited
      routeToUpdate = await RouteStorageService.saveRoute(
        routeResult: widget.routeResult,
        originalInputs: widget.originalInputs,
      );
      // Mark it as favorite
      routeToUpdate = routeToUpdate.copyWith(isFavorite: true);
      await RouteStorageService.updateRoute(routeToUpdate);
    } else {
      // Route exists, toggle its favorite status
      routeToUpdate = _savedRoute!.copyWith(isFavorite: !_savedRoute!.isFavorite);
      await RouteStorageService.updateRoute(routeToUpdate);
    }

    if (mounted) {
      setState(() {
        _isFavorited = routeToUpdate.isFavorite;
        _savedRoute = routeToUpdate;
        _isTogglingFavorite = false;
      });

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                routeToUpdate.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  routeToUpdate.isFavorite 
                      ? 'Added to favorites'
                      : 'Removed from favorites'
                ),
              ),
            ],
          ),
          backgroundColor: routeToUpdate.isFavorite 
              ? const Color(0xFF34C759) 
              : const Color(0xFF2E7D32),
          duration: const Duration(seconds: 2),
        ),
      );
    }

  } catch (e) {
    if (mounted) {
      setState(() {
        _isTogglingFavorite = false;
      });

      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error updating favorite: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFF3B30), // iOS red
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

  // MARK: - Summary Card (Dark theme card)
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),  // Dark theme background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary header
          const Text(
            'Summary',
            style: TextStyle(
              color: Colors.white,  // White text for dark theme
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Three-column metrics layout (exactly like iOS)
          Row(
            children: [
              // Distance column
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.straighten,
                  iconColor: const Color(0xFF34C759), // iOS green
                  value: widget.routeResult.totalDistance,
                  label: 'Distance',
                ),
              ),
              
              // Divider line
              Container(
                width: 1,
                height: 60,
                color: Colors.grey[600],  // Darker gray for dark theme
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              
              // Time column
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.access_time,
                  iconColor: const Color(0xFFFF9500), // iOS orange
                  value: widget.routeResult.estimatedTime,
                  label: 'Time',
                ),
              ),
              
              // Divider line
              Container(
                width: 1,
                height: 60,
                color: Colors.grey[600],  // Darker gray for dark theme  
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              
              // Stops column
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.location_on,
                  iconColor: const Color(0xFF999999), // iOS gray
                  value: '${widget.routeResult.optimizedStops.length}',
                  label: 'Stops',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Summary Metric Item (matching iOS layout)
  Widget _buildSummaryMetric({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        // Icon in colored circle
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Value (large number)
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,  // White text for dark theme
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Label
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],  // Light gray for dark theme
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // MARK: - Route Map Section
  Widget _buildRouteMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        const Text(
          'Route Map',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Real Google Maps integration with traffic state management
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

  // MARK: - Your Path Section (route stops list)
  Widget _buildYourPathSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with route icon
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

  // MARK: - Path Stop Item (matching iOS design exactly)
  Widget _buildPathStopItem({
    required RouteStop stop,
    required int index,
    required bool isFirst,
    required bool isLast,
  }) {
    // Determine button color and text based on position
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

  // MARK: - Bottom Action Buttons (matching iOS exactly)
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
// Favorite Toggle button (outline style)
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
      onPressed: _isTogglingFavorite ? null : () => _toggleFavorite(context),
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
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? const Color(0xFF34C759) : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            _isFavorited ? 'Favorited' : 'Add Favorite',
            style: TextStyle(
              color: _isFavorited ? const Color(0xFF34C759) : Colors.white,
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
            
            // Google Maps button (filled style)
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759), // iOS green
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: () => _exportToGoogleMaps(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.map,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Google Maps',
                        style: TextStyle(
                          color: Colors.white,
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
}