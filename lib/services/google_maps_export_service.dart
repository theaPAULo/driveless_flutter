// lib/services/google_maps_export_service.dart
//
// Service for exporting routes to Google Maps app
// Handles deep linking and URL generation for navigation

import 'package:url_launcher/url_launcher.dart';
import '../models/route_models.dart';

class GoogleMapsExportService {
  
  /// Export optimized route to Google Maps app for navigation
  /// 
  /// [routeResult] - The optimized route to export
  /// [originalInputs] - Original route inputs for context
  /// Returns true if successfully opened, false otherwise
  static Future<bool> exportRouteToGoogleMaps({
    required OptimizedRouteResult routeResult,
    required OriginalRouteInputs originalInputs,
  }) async {
    try {
      // Build Google Maps URL with waypoints
      final String mapsUrl = _buildGoogleMapsUrl(routeResult);
      
      print('🗺️ Opening Google Maps with URL: $mapsUrl');
      
      // Try to open in Google Maps app first
      final Uri googleMapsUri = Uri.parse(mapsUrl);
      
      if (await canLaunchUrl(googleMapsUri)) {
        final bool launched = await launchUrl(
          googleMapsUri,
          mode: LaunchMode.externalApplication, // Open in external app
        );
        
        if (launched) {
          print('✅ Successfully opened route in Google Maps');
          return true;
        }
      }
      
      // Fallback: Try opening in browser if app launch fails
      final String webUrl = _buildGoogleMapsWebUrl(routeResult);
      final Uri webUri = Uri.parse(webUrl);
      
      if (await canLaunchUrl(webUri)) {
        final bool launched = await launchUrl(
          webUri,
          mode: LaunchMode.inAppWebView, // Open in web browser
        );
        
        if (launched) {
          print('✅ Successfully opened route in web browser');
          return true;
        }
      }
      
      print('❌ Failed to open Google Maps');
      return false;
      
    } catch (e) {
      print('❌ Error exporting to Google Maps: $e');
      return false;
    }
  }
  
  /// Build Google Maps app URL with multiple waypoints
  /// 
  /// Format: google.navigation:q=destination&waypoints=waypoint1|waypoint2
  /// Or: https://www.google.com/maps/dir/origin/waypoint1/waypoint2/destination
  static String _buildGoogleMapsUrl(OptimizedRouteResult routeResult) {
    final stops = routeResult.optimizedStops;
    
    if (stops.isEmpty) {
      return 'https://maps.google.com/';
    }
    
    if (stops.length == 1) {
      // Single destination
      final destination = stops.first;
      return 'google.navigation:q=${_encodeLocation(destination)}';
    }
    
    // Multiple waypoints - use Google Maps directions URL
    final origin = stops.first;
    final destination = stops.last;
    final waypoints = stops.sublist(1, stops.length - 1);
    
    String url = 'https://www.google.com/maps/dir/';
    
    // Add origin
    url += '${_encodeLocation(origin)}/';
    
    // Add intermediate waypoints
    for (final waypoint in waypoints) {
      url += '${_encodeLocation(waypoint)}/';
    }
    
    // Add destination
    url += '${_encodeLocation(destination)}';
    
    // Add travel mode (driving)
    url += '/@${origin.latitude},${origin.longitude},12z/data=!3m1!4b1!4m2!4m1!3e0';
    
    return url;
  }
  
  /// Build Google Maps web URL (fallback)
  /// 
  /// Uses the same format but ensures web compatibility
  static String _buildGoogleMapsWebUrl(OptimizedRouteResult routeResult) {
    final stops = routeResult.optimizedStops;
    
    if (stops.isEmpty) {
      return 'https://maps.google.com/';
    }
    
    if (stops.length == 1) {
      // Single destination
      final destination = stops.first;
      return 'https://www.google.com/maps/search/?api=1&query=${_encodeLocation(destination)}';
    }
    
    // Multiple waypoints - use directions API
    final origin = stops.first;
    final destination = stops.last;
    final waypoints = stops.sublist(1, stops.length - 1);
    
    String url = 'https://www.google.com/maps/dir/';
    
    // Add origin
    url += '${_encodeLocation(origin)}/';
    
    // Add intermediate waypoints
    for (final waypoint in waypoints) {
      url += '${_encodeLocation(waypoint)}/';
    }
    
    // Add destination
    url += '${_encodeLocation(destination)}';
    
    return url;
  }
  
  /// Encode location for URL (prefer coordinates for accuracy)
  /// 
  /// Uses latitude,longitude format which is more reliable than addresses
  static String _encodeLocation(RouteStop stop) {
    // Use coordinates for most accurate navigation
    return '${stop.latitude},${stop.longitude}';
  }
  
  /// Generate a shareable route URL for sharing with others
  /// 
  /// [routeResult] - The route to share
  /// Returns a Google Maps URL that can be shared via text/email
  static String generateShareableUrl(OptimizedRouteResult routeResult) {
    return _buildGoogleMapsWebUrl(routeResult);
  }
  
  /// Check if Google Maps app is installed on the device
  /// 
  /// Returns true if the app can be launched
  static Future<bool> isGoogleMapsInstalled() async {
    try {
      const String testUrl = 'google.navigation:q=0,0';
      final Uri uri = Uri.parse(testUrl);
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }
}