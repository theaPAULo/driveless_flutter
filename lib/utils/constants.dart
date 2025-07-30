// lib/utils/constants.dart
//
// App-wide constants and configuration settings
// This file contains API keys, URLs, and other configuration values

class AppConstants {
  // MARK: - Google APIs Configuration
  
  /// Your Google Cloud Console API Key
  /// 🔑 IMPORTANT: Replace 'YOUR_GOOGLE_API_KEY_HERE' with your actual API key
  /// 
  /// To get your API key:
  /// 1. Go to Google Cloud Console (console.cloud.google.com)
  /// 2. Enable Directions API and Places API
  /// 3. Create credentials -> API key
  /// 4. Restrict the key to your app (recommended for production)
  static const String googleApiKey = 'AIzaSyCancy_vwbDbYZavxDjtpL7NW4lYl8Tkmk';
  
  // MARK: - Google Directions API
  
  /// Base URL for Google Directions API
  static const String directionsApiBaseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  
  /// Base URL for Google Places API (for address autocomplete)
  static const String placesApiBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  // MARK: - Route Optimization Settings
  
  /// Default travel mode for route calculations
  /// Options: 'driving', 'walking', 'bicycling', 'transit'
  static const String defaultTravelMode = 'driving';
  
  /// Whether to optimize waypoint order by default
  static const bool optimizeWaypointsByDefault = true;
  
  /// Whether to request traffic data in route calculations
  static const bool includeTrafficData = true;
  
  /// Units for distance/duration display
  /// Options: 'metric' (km/meters) or 'imperial' (miles/feet)
  static const String units = 'imperial';
  
  // MARK: - App Settings
  
  /// App name for display
  static const String appName = 'DriveLess';
  
  /// App version (should match pubspec.yaml)
  static const String appVersion = '1.0.0';
  
  /// Maximum number of waypoints allowed per route
  /// Google Directions API allows up to 25 waypoints
  static const int maxWaypoints = 25;
  
  /// Default timeout for API requests (in seconds)
  static const int apiTimeoutSeconds = 30;
  
  // MARK: - Error Messages
  
  /// User-friendly error messages
  static const String errorNoInternetConnection = 'No internet connection. Please check your network and try again.';
  static const String errorApiKeyInvalid = 'Invalid API configuration. Please contact support.';
  static const String errorNoRouteFound = 'No route could be calculated for the provided addresses.';
  static const String errorTooManyWaypoints = 'Too many stops. Maximum allowed is $maxWaypoints stops.';
  static const String errorGeneric = 'An unexpected error occurred. Please try again.';
  
  // MARK: - UI Constants
  
  /// App color scheme
  static const int primaryColorValue = 0xFF2E7D32; // Dark green
  static const int accentColorValue = 0xFF4CAF50;  // Light green
  
  /// Padding and spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  /// Border radius for cards and buttons
  static const double defaultBorderRadius = 12.0;
}

// MARK: - Development vs Production Configuration

/// Configuration class to handle different environments
class EnvironmentConfig {
  /// Whether the app is running in debug mode
  static const bool isDebug = true; // Set to false for production builds
  
  /// API key to use (can be different for dev/prod)
  static String get apiKey {
    if (isDebug) {
      // Use development API key (if you have a separate one)
      return AppConstants.googleApiKey;
    } else {
      // Use production API key
      return AppConstants.googleApiKey;
    }
  }
  
  /// Whether to show debug information in UI
  static bool get showDebugInfo => isDebug;
  
  /// Whether to log API requests/responses
  static bool get logApiCalls => isDebug;
}