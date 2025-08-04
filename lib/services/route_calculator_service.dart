// lib/services/route_calculator_service.dart
//
// Route calculation service using Google Directions API
// Converted from Swift RouteCalculator to Flutter/Dart
// Handles route optimization and API communication

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Import our models and constants
import '../models/route_models.dart';
import '../utils/constants.dart';

/// Service class for calculating optimized routes using Google Directions API
class RouteCalculatorService {
  
  // MARK: - Singleton Pattern
  
  /// Singleton instance for app-wide access
  static final RouteCalculatorService _instance = RouteCalculatorService._internal();
  factory RouteCalculatorService() => _instance;
  RouteCalculatorService._internal();
  
  // MARK: - HTTP Client
  
  /// HTTP client for making API requests
  final http.Client _httpClient = http.Client();
  
  // MARK: - Public Methods
  
  /// Calculate optimized route with multiple stops
  /// 
  /// [startLocation] - Starting address (e.g., "123 Main St, City, State")
  /// [endLocation] - Ending address
  /// [stops] - List of intermediate stops/waypoints
  /// [originalInputs] - Original user inputs to preserve display names
  /// 
  /// Returns [OptimizedRouteResult] with calculated route data
  /// Throws [RouteCalculationException] on errors
  Future<OptimizedRouteResult> calculateOptimizedRoute({
    required String startLocation,
    required String endLocation,
    required List<String> stops,
    required OriginalRouteInputs originalInputs,
  }) async {
    try {
      // Validate inputs
      _validateInputs(startLocation, endLocation, stops);
      
      // Build API URL
      final String apiUrl = _buildDirectionsApiUrl(
        startLocation: startLocation,
        endLocation: endLocation,
        stops: stops,
      );
      
      if (EnvironmentConfig.logApiCalls) {
        print('🌐 Making Directions API request to: $apiUrl');
      }
      
      // Make API request
      final DirectionsResponse response = await _makeDirectionsApiRequest(apiUrl);
      
      // Process and return optimized result
      return _processDirectionsResponse(response, originalInputs);
      
    } on RouteCalculationException {
      // Re-throw our custom exceptions
      rethrow;
    } catch (e) {
      // Handle unexpected errors
      throw RouteCalculationException(
        RouteCalculationError.apiError,
        'Unexpected error: ${e.toString()}',
      );
    }
  }
  
  /// Dispose of resources when service is no longer needed
  void dispose() {
    _httpClient.close();
  }
  
  // MARK: - Private Helper Methods
  
  /// Validate input parameters
  void _validateInputs(String startLocation, String endLocation, List<String> stops) {
    if (startLocation.trim().isEmpty) {
      throw RouteCalculationException(
        RouteCalculationError.apiError,
        'Start location cannot be empty',
      );
    }
    
    if (endLocation.trim().isEmpty) {
      throw RouteCalculationException(
        RouteCalculationError.apiError,
        'End location cannot be empty',
      );
    }
    
    if (stops.length > AppConstants.maxWaypoints) {
      throw RouteCalculationException(
        RouteCalculationError.apiError,
        AppConstants.errorTooManyWaypoints,
      );
    }
  }
  
  /// Build the Google Directions API URL with all parameters
  String _buildDirectionsApiUrl({
    required String startLocation,
    required String endLocation,
    required List<String> stops,
  }) {
    // Start building URL
    final Uri baseUri = Uri.parse(AppConstants.directionsApiBaseUrl);
    final Map<String, String> queryParams = {
      'origin': startLocation.trim(),
      'destination': endLocation.trim(),
      'key': EnvironmentConfig.apiKey,
      'mode': AppConstants.defaultTravelMode,
      'units': AppConstants.units,
    };
    
    // Add waypoints if any stops provided
    if (stops.isNotEmpty) {
      final String waypoints = stops
          .where((stop) => stop.trim().isNotEmpty)
          .map((stop) => stop.trim())
          .join('|');
      
      if (waypoints.isNotEmpty) {
        // Add waypoint optimization if enabled
        final String waypointPrefix = AppConstants.optimizeWaypointsByDefault 
            ? 'optimize:true|' 
            : '';
        queryParams['waypoints'] = '$waypointPrefix$waypoints';
      }
    }
    
    // Add traffic data if enabled
    if (AppConstants.includeTrafficData) {
      queryParams['departure_time'] = 'now';
    }
    
    // Build final URI
    final Uri finalUri = baseUri.replace(queryParameters: queryParams);
    
    if (EnvironmentConfig.logApiCalls) {
      print('📍 Built API URL with ${stops.length} waypoints');
    }
    
    return finalUri.toString();
  }
  
  /// Make HTTP request to Google Directions API
  Future<DirectionsResponse> _makeDirectionsApiRequest(String url) async {
    try {
      // Make HTTP GET request with timeout
      final http.Response response = await _httpClient
          .get(Uri.parse(url))
          .timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (EnvironmentConfig.logApiCalls) {
        print('📡 API Response Status: ${response.statusCode}');
      }
      
      // Check HTTP status
      if (response.statusCode != 200) {
        throw RouteCalculationException(
          RouteCalculationError.apiError,
          'HTTP Error: ${response.statusCode}',
        );
      }
      
      // Parse JSON response
      final Map<String, dynamic> jsonData = json.decode(response.body);
      
      if (EnvironmentConfig.logApiCalls) {
        print('📊 API Response: ${jsonData['status']}');
      }
      
      // Create DirectionsResponse object
      final DirectionsResponse directionsResponse = DirectionsResponse.fromJson(jsonData);
      
      // Check API status
      if (directionsResponse.status != 'OK') {
        throw RouteCalculationException(
          RouteCalculationError.apiError,
          'API Error: ${directionsResponse.status}',
        );
      }
      
      // Validate we have routes
      if (directionsResponse.routes.isEmpty) {
        throw RouteCalculationException(
          RouteCalculationError.noData,
          AppConstants.errorNoRouteFound,
        );
      }
      
      return directionsResponse;
      
    } on SocketException {
      // Handle network connectivity issues
      throw RouteCalculationException(
        RouteCalculationError.apiError,
        AppConstants.errorNoInternetConnection,
      );
    } on http.ClientException {
      // Handle HTTP client errors
      throw RouteCalculationException(
        RouteCalculationError.apiError,
        'Network error occurred',
      );
    } on FormatException {
      // Handle JSON parsing errors
      throw RouteCalculationException(
        RouteCalculationError.noData,
        'Invalid response format from API',
      );
    }
  }
  
  /// Process Google Directions API response into our optimized result format
  OptimizedRouteResult _processDirectionsResponse(
    DirectionsResponse response,
    OriginalRouteInputs originalInputs,
  ) {
    // Get the first (best) route from response
    final DirectionsRoute route = response.routes.first;
    
    // Calculate total distance and time
    final (String totalDistance, String totalTime) = _calculateTotals(route.legs);
    
    // Build optimized stops list
    final List<RouteStop> optimizedStops = _buildOptimizedStops(
      route.legs,
      originalInputs,
      route.waypointOrder,
    );
    
    // Extract polyline for map display
    final String? polyline = route.overviewPolyline?.points;
    
    // Get waypoint order (for optimization results)
    final List<int> waypointOrder = route.waypointOrder ?? [];
    
    if (EnvironmentConfig.logApiCalls) {
      print('✅ Route processed: $totalDistance, $totalTime, ${optimizedStops.length} stops');
    }
    
    return OptimizedRouteResult(
      totalDistance: totalDistance,
      estimatedTime: totalTime,
      optimizedStops: optimizedStops,
      routePolyline: polyline,
      legs: route.legs,
      waypointOrder: waypointOrder,
    );
  }
  
  /// Calculate total distance and time from all route legs
  (String, String) _calculateTotals(List<RouteLeg> legs) {
    int totalDistanceMeters = 0;
    int totalTimeSeconds = 0;
    
    for (final leg in legs) {
      totalDistanceMeters += leg.distance.value;
      
      // Use traffic time if available, otherwise use normal duration
      final duration = leg.durationInTraffic ?? leg.duration;
      totalTimeSeconds += duration.value;
    }
    
    // Convert to human-readable format
    final String totalDistance = _formatDistance(totalDistanceMeters);
    final String totalTime = _formatDuration(totalTimeSeconds);
    
    return (totalDistance, totalTime);
  }
  
  /// Build list of optimized route stops with proper display names
  List<RouteStop> _buildOptimizedStops(
    List<RouteLeg> legs,
    OriginalRouteInputs originalInputs,
    List<int>? waypointOrder,
  ) {
    final List<RouteStop> stops = [];
    
    // Add start location
    if (legs.isNotEmpty) {
      final firstLeg = legs.first;
      stops.add(RouteStop(
        address: firstLeg.startAddress,
        displayName: originalInputs.startLocationDisplayName,
        latitude: firstLeg.startLocation.lat,
        longitude: firstLeg.startLocation.lng,
      ));
    }
    
    // Add intermediate stops (waypoints)
    for (int i = 0; i < legs.length - 1; i++) {
      final leg = legs[i];
      
      // Get display name from original inputs (handle optimization reordering)
      String displayName = leg.endAddress;
      if (i < originalInputs.stopDisplayNames.length) {
        displayName = originalInputs.stopDisplayNames[i];
      }
      
      stops.add(RouteStop(
        address: leg.endAddress,
        displayName: displayName,
        latitude: leg.endLocation.lat,
        longitude: leg.endLocation.lng,
      ));
    }
    
    // Add end location
    if (legs.isNotEmpty) {
      final lastLeg = legs.last;
      stops.add(RouteStop(
        address: lastLeg.endAddress,
        displayName: originalInputs.endLocationDisplayName,
        latitude: lastLeg.endLocation.lat,
        longitude: lastLeg.endLocation.lng,
      ));
    }
    
    return stops;
  }
  
  /// Format distance from meters to human-readable string
  String _formatDistance(int meters) {
    if (AppConstants.units == 'imperial') {
      final double miles = meters * 0.000621371;
      if (miles < 0.1) {
        final int feet = (meters * 3.28084).round();
        return '$feet ft';
      }
      return '${miles.toStringAsFixed(1)} mi';
    } else {
      if (meters < 1000) {
        return '$meters m';
      }
      final double km = meters / 1000.0;
      return '${km.toStringAsFixed(1)} km';
    }
  }
  
  /// Format duration from seconds to human-readable string
  String _formatDuration(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}