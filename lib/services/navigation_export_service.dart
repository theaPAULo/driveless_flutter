// lib/services/navigation_export_service.dart
//
// Enhanced navigation export service supporting Google Maps, Waze, and Apple Maps
// Handles deep linking and URL generation for multiple navigation apps

import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import '../models/route_models.dart';

/// Supported navigation apps
enum NavigationApp {
  googleMaps,
  waze,
  appleMaps, // iOS only
}

/// Result of export attempt
class ExportResult {
  final bool success;
  final String message;
  final String? errorDetails;

  ExportResult({
    required this.success, 
    required this.message,
    this.errorDetails,
  });
}

class NavigationExportService {
  
  /// Export optimized route to specified navigation app
  /// 
  /// [app] - The navigation app to export to
  /// [routeResult] - The optimized route to export
  /// [originalInputs] - Original route inputs for context
  /// Returns ExportResult with success status and message
  static Future<ExportResult> exportRoute({
    required NavigationApp app,
    required OptimizedRouteResult routeResult,
    required OriginalRouteInputs originalInputs,
  }) async {
    try {
      switch (app) {
        case NavigationApp.googleMaps:
          return await _exportToGoogleMaps(routeResult, originalInputs);
        case NavigationApp.waze:
          return await _exportToWaze(routeResult, originalInputs);
        case NavigationApp.appleMaps:
          return await _exportToAppleMaps(routeResult, originalInputs);
      }
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Failed to export route',
        errorDetails: e.toString(),
      );
    }
  }

  /// Check if a navigation app is available on current platform
  /// 
  /// [app] - The navigation app to check
  /// Returns true if app is available/installable on current platform
  static bool isAppAvailable(NavigationApp app) {
    switch (app) {
      case NavigationApp.googleMaps:
        return true; // Available on all platforms
      case NavigationApp.waze:
        return true; // Available on both iOS and Android
      case NavigationApp.appleMaps:
        return Platform.isIOS; // iOS only
    }
  }

  /// Get display name for navigation app
  static String getAppDisplayName(NavigationApp app) {
    switch (app) {
      case NavigationApp.googleMaps:
        return 'Google Maps';
      case NavigationApp.waze:
        return 'Waze';
      case NavigationApp.appleMaps:
        return 'Apple Maps';
    }
  }

  /// Get icon name for navigation app (for UI)
  static String getAppIconName(NavigationApp app) {
    switch (app) {
      case NavigationApp.googleMaps:
        return 'google_maps'; // You can use actual icon assets
      case NavigationApp.waze:
        return 'waze';
      case NavigationApp.appleMaps:
        return 'apple_maps';
    }
  }

  /// Export route to Google Maps
  static Future<ExportResult> _exportToGoogleMaps(
    OptimizedRouteResult routeResult, 
    OriginalRouteInputs originalInputs
  ) async {
    try {
      final String appUrl = _buildGoogleMapsUrl(routeResult);
      final Uri appUri = Uri.parse(appUrl);
      
      print('🗺️ Opening Google Maps with URL: $appUrl');
      
      // Try app first
      if (await canLaunchUrl(appUri)) {
        final bool launched = await launchUrl(
          appUri,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          return ExportResult(
            success: true,
            message: 'Route opened in Google Maps!',
          );
        }
      }
      
      // Fallback to web version
      final String webUrl = _buildGoogleMapsWebUrl(routeResult);
      final Uri webUri = Uri.parse(webUrl);
      
      if (await canLaunchUrl(webUri)) {
        final bool launched = await launchUrl(
          webUri,
          mode: LaunchMode.inAppWebView,
        );
        
        if (launched) {
          return ExportResult(
            success: true,
            message: 'Route opened in browser!',
          );
        }
      }
      
      return ExportResult(
        success: false,
        message: 'Could not open Google Maps',
      );
      
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Failed to open Google Maps',
        errorDetails: e.toString(),
      );
    }
  }

  /// Export route to Waze
  static Future<ExportResult> _exportToWaze(
    OptimizedRouteResult routeResult, 
    OriginalRouteInputs originalInputs
  ) async {
    try {
      final String wazeUrl = _buildWazeUrl(routeResult);
      final Uri wazeUri = Uri.parse(wazeUrl);
      
      // Log which stop we're actually navigating to
      final stops = routeResult.optimizedStops;
      String destinationInfo = 'destination';
      if (stops.length > 1) {
        destinationInfo = 'first stop: ${stops[1].displayName}';
      }
      
      print('🚗 Opening Waze with URL: $wazeUrl');
      print('🚗 Waze will navigate to: $destinationInfo');
      
      // Try to open Waze using universal link (more reliable)
      final bool launched = await launchUrl(
        wazeUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        return ExportResult(
          success: true,
          message: 'Route opened in Waze!',
        );
      }
      
      // If universal link fails, try native scheme as fallback
      final String nativeUrl = _buildWazeNativeUrl(routeResult);
      final Uri nativeUri = Uri.parse(nativeUrl);
      
      print('🚗 Trying Waze native URL: $nativeUrl');
      
      final bool nativeLaunched = await launchUrl(
        nativeUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (nativeLaunched) {
        return ExportResult(
          success: true,
          message: 'Route opened in Waze!',
        );
      }
      
      // Both methods failed
      return ExportResult(
        success: false,
        message: 'Could not open Waze. Please make sure Waze is installed.',
      );
      
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Failed to open Waze',
        errorDetails: e.toString(),
      );
    }
  }

  /// Export route to Apple Maps (iOS only)
  static Future<ExportResult> _exportToAppleMaps(
    OptimizedRouteResult routeResult, 
    OriginalRouteInputs originalInputs
  ) async {
    if (!Platform.isIOS) {
      return ExportResult(
        success: false,
        message: 'Apple Maps is only available on iOS',
      );
    }

    try {
      final String mapsUrl = _buildAppleMapsUrl(routeResult);
      final Uri mapsUri = Uri.parse(mapsUrl);
      
      print('🍎 Opening Apple Maps with URL: $mapsUrl');
      
      // Apple Maps is always available on iOS
      final bool launched = await launchUrl(
        mapsUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        return ExportResult(
          success: true,
          message: 'Route opened in Apple Maps!',
        );
      } else {
        return ExportResult(
          success: false,
          message: 'Failed to open Apple Maps',
        );
      }
      
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Failed to open Apple Maps',
        errorDetails: e.toString(),
      );
    }
  }

  // MARK: - URL Building Methods

  /// Build Google Maps URL (existing logic from GoogleMapsExportService)
  static String _buildGoogleMapsUrl(OptimizedRouteResult routeResult) {
    final stops = routeResult.optimizedStops;
    
    if (stops.isEmpty) {
      return 'https://maps.google.com/';
    }
    
    if (stops.length == 1) {
      final destination = stops.first;
      return 'google.navigation:q=${_encodeLocation(destination)}';
    }
    
    // Multiple waypoints
    final origin = stops.first;
    final destination = stops.last;
    final waypoints = stops.sublist(1, stops.length - 1);
    
    String url = 'https://www.google.com/maps/dir/';
    url += '${_encodeLocation(origin)}/';
    
    for (final waypoint in waypoints) {
      url += '${_encodeLocation(waypoint)}/';
    }
    
    url += '${_encodeLocation(destination)}';
    url += '/@${origin.latitude},${origin.longitude},12z/data=!3m1!4b1!4m2!4m1!3e0';
    
    return url;
  }

  /// Build Google Maps web URL fallback
  static String _buildGoogleMapsWebUrl(OptimizedRouteResult routeResult) {
    final stops = routeResult.optimizedStops;
    
    if (stops.isEmpty) {
      return 'https://maps.google.com/';
    }
    
    if (stops.length == 1) {
      final destination = stops.first;
      return 'https://www.google.com/maps/search/?api=1&query=${_encodeLocation(destination)}';
    }
    
    final origin = stops.first;
    final destination = stops.last;
    final waypoints = stops.sublist(1, stops.length - 1);
    
    String url = 'https://www.google.com/maps/dir/';
    url += '${_encodeLocation(origin)}/';
    
    for (final waypoint in waypoints) {
      url += '${_encodeLocation(waypoint)}/';
    }
    
    url += '${_encodeLocation(destination)}';
    
    return url;
  }

  /// Build Waze URL (Universal Link - targeting first intermediate stop)
  /// 
  /// Waze Universal Link: https://waze.com/ul?ll=latitude,longitude&navigate=yes
  /// Note: Waze ignores custom starting points and always uses current location
  static String _buildWazeUrl(OptimizedRouteResult routeResult) {
    final stops = routeResult.optimizedStops;
    
    if (stops.isEmpty) {
      return 'https://waze.com/';
    }
    
    if (stops.length == 1) {
      // Single destination
      final destination = stops.first;
      return 'https://waze.com/ul?ll=${destination.latitude},${destination.longitude}&navigate=yes';
    }
    
    // Multiple stops - navigate to FIRST INTERMEDIATE STOP (not final destination)
    // This is more useful since Waze can't handle multiple waypoints
    final firstStop = stops[1]; // Skip starting point, get first intermediate stop
    
    return 'https://waze.com/ul?ll=${firstStop.latitude},${firstStop.longitude}&navigate=yes';
  }

  /// Build Waze Native URL (fallback - also targets first intermediate stop)
  /// 
  /// Native Waze URL scheme for fallback
  static String _buildWazeNativeUrl(OptimizedRouteResult routeResult) {
    final stops = routeResult.optimizedStops;
    
    if (stops.isEmpty) {
      return 'waze://';
    }
    
    if (stops.length == 1) {
      // Single destination
      final destination = stops.first;
      return 'waze://?ll=${destination.latitude},${destination.longitude}&navigate=yes';
    }
    
    // Multiple stops - navigate to first intermediate stop
    final firstStop = stops[1];
    
    return 'waze://?ll=${firstStop.latitude},${firstStop.longitude}&navigate=yes';
  }

  /// Build Apple Maps URL
  /// 
  /// Apple Maps URL scheme: maps://?daddr=destination&dirflg=d
  /// For multiple waypoints: maps://?saddr=start&daddr=destination+to:waypoint1+to:waypoint2&dirflg=d
  static String _buildAppleMapsUrl(OptimizedRouteResult routeResult) {
    final stops = routeResult.optimizedStops;
    
    if (stops.isEmpty) {
      return 'maps://';
    }
    
    if (stops.length == 1) {
      final destination = stops.first;
      return 'maps://?daddr=${_encodeLocation(destination)}&dirflg=d';
    }
    
    // Multiple waypoints
    final origin = stops.first;
    final destination = stops.last;
    final waypoints = stops.sublist(1, stops.length - 1);
    
    String url = 'maps://?saddr=${_encodeLocation(origin)}&daddr=${_encodeLocation(destination)}';
    
    // Add intermediate waypoints using +to: format
    for (final waypoint in waypoints) {
      url += '+to:${_encodeLocation(waypoint)}';
    }
    
    url += '&dirflg=d'; // d = driving directions
    
    return url;
  }

  /// Encode location for URL (latitude,longitude format)
  static String _encodeLocation(RouteStop stop) {
    return '${stop.latitude},${stop.longitude}';
  }

  /// Check if specific navigation app is installed (for better user feedback)
  static Future<bool> isAppInstalled(NavigationApp app) async {
    try {
      String testUrl;
      switch (app) {
        case NavigationApp.googleMaps:
          testUrl = 'google.navigation:q=0,0';
          break;
        case NavigationApp.waze:
          // Try universal link first, then native scheme
          testUrl = 'https://waze.com/ul?ll=0,0&navigate=yes';
          break;
        case NavigationApp.appleMaps:
          testUrl = 'maps://?ll=0,0';
          break;
      }
      
      final Uri uri = Uri.parse(testUrl);
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// Get all available navigation apps for current platform
  static List<NavigationApp> getAvailableApps() {
    final List<NavigationApp> apps = [
      NavigationApp.googleMaps,
      NavigationApp.waze,
    ];
    
    if (Platform.isIOS) {
      apps.add(NavigationApp.appleMaps);
    }
    
    return apps;
  }
}