// lib/models/route_models.dart
// 
// Core route data models converted from Swift RouteCalculator.swift
// These models handle Google Directions API responses and route optimization

/// Main result structure for optimized routes
class OptimizedRouteResult {
  final String totalDistance;
  final String estimatedTime;
  final List<RouteStop> optimizedStops;
  final String? routePolyline;
  final List<RouteLeg> legs;
  final List<int> waypointOrder;

  OptimizedRouteResult({
    required this.totalDistance,
    required this.estimatedTime,
    required this.optimizedStops,
    this.routePolyline,
    required this.legs,
    required this.waypointOrder,
  });

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'totalDistance': totalDistance,
      'estimatedTime': estimatedTime,
      'optimizedStops': optimizedStops.map((stop) => stop.toJson()).toList(),
      'routePolyline': routePolyline,
      'legs': legs.map((leg) => leg.toJson()).toList(),
      'waypointOrder': waypointOrder,
    };
  }

  /// Create from JSON (from storage/API)
  factory OptimizedRouteResult.fromJson(Map<String, dynamic> json) {
    return OptimizedRouteResult(
      totalDistance: json['totalDistance'] ?? '',
      estimatedTime: json['estimatedTime'] ?? '',
      optimizedStops: (json['optimizedStops'] as List<dynamic>?)
          ?.map((stop) => RouteStop.fromJson(stop))
          .toList() ?? [],
      routePolyline: json['routePolyline'],
      legs: (json['legs'] as List<dynamic>?)
          ?.map((leg) => RouteLeg.fromJson(leg))
          .toList() ?? [],
      waypointOrder: List<int>.from(json['waypointOrder'] ?? []),
    );
  }
}

/// Individual route stop with location data
class RouteStop {
  final String address;
  final String displayName; // Business name for display
  final double latitude;
  final double longitude;

  RouteStop({
    required this.address,  
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'displayName': displayName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      address: json['address'] ?? '',
      displayName: json['displayName'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }
}

/// Original user inputs to preserve search terms
class OriginalRouteInputs {
  final String startLocation;
  final String endLocation;
  final List<String> stops;
  final String startLocationDisplayName;
  final String endLocationDisplayName;
  final List<String> stopDisplayNames;

  OriginalRouteInputs({
    required this.startLocation,
    required this.endLocation,
    required this.stops,
    required this.startLocationDisplayName,
    required this.endLocationDisplayName,
    required this.stopDisplayNames,
  });

  Map<String, dynamic> toJson() {
    return {
      'startLocation': startLocation,
      'endLocation': endLocation,
      'stops': stops,
      'startLocationDisplayName': startLocationDisplayName,
      'endLocationDisplayName': endLocationDisplayName,
      'stopDisplayNames': stopDisplayNames,
    };
  }

  factory OriginalRouteInputs.fromJson(Map<String, dynamic> json) {
    return OriginalRouteInputs(
      startLocation: json['startLocation'] ?? '',
      endLocation: json['endLocation'] ?? '',
      stops: List<String>.from(json['stops'] ?? []),
      startLocationDisplayName: json['startLocationDisplayName'] ?? '',
      endLocationDisplayName: json['endLocationDisplayName'] ?? '',
      stopDisplayNames: List<String>.from(json['stopDisplayNames'] ?? []),
    );
  }
}

// MARK: - Google Directions API Response Models

/// Top-level response from Google Directions API
class DirectionsResponse {
  final String status;
  final List<DirectionsRoute> routes;

  DirectionsResponse({
    required this.status,
    required this.routes,
  });

  factory DirectionsResponse.fromJson(Map<String, dynamic> json) {
    return DirectionsResponse(
      status: json['status'] ?? '',
      routes: (json['routes'] as List<dynamic>?)
          ?.map((route) => DirectionsRoute.fromJson(route))
          .toList() ?? [],
    );
  }
}

/// Individual route from Google Directions API
class DirectionsRoute {
  final List<RouteLeg> legs;
  final OverviewPolyline? overviewPolyline;
  final List<int>? waypointOrder;

  DirectionsRoute({
    required this.legs,
    this.overviewPolyline,
    this.waypointOrder,
  });

  factory DirectionsRoute.fromJson(Map<String, dynamic> json) {
    return DirectionsRoute(
      legs: (json['legs'] as List<dynamic>?)
          ?.map((leg) => RouteLeg.fromJson(leg))
          .toList() ?? [],
      overviewPolyline: json['overview_polyline'] != null
          ? OverviewPolyline.fromJson(json['overview_polyline'])  
          : null,
      waypointOrder: json['waypoint_order'] != null
          ? List<int>.from(json['waypoint_order'])
          : null,
    );
  }
}

/// Individual leg of a route (between two points)
class RouteLeg {
  final RouteDistance distance;
  final RouteDuration duration;
  final RouteDuration? durationInTraffic;
  final String startAddress;
  final String endAddress;
  final RouteLocation startLocation;
  final RouteLocation endLocation;

  RouteLeg({
    required this.distance,
    required this.duration,
    this.durationInTraffic,
    required this.startAddress,
    required this.endAddress,
    required this.startLocation,
    required this.endLocation,
  });

  Map<String, dynamic> toJson() {
    return {
      'distance': distance.toJson(),
      'duration': duration.toJson(),
      'durationInTraffic': durationInTraffic?.toJson(),
      'startAddress': startAddress,
      'endAddress': endAddress,
      'startLocation': startLocation.toJson(),
      'endLocation': endLocation.toJson(),
    };
  }

  factory RouteLeg.fromJson(Map<String, dynamic> json) {
    return RouteLeg(
      distance: RouteDistance.fromJson(json['distance'] ?? {}),
      duration: RouteDuration.fromJson(json['duration'] ?? {}),
      durationInTraffic: json['duration_in_traffic'] != null
          ? RouteDuration.fromJson(json['duration_in_traffic'])
          : null,
      startAddress: json['start_address'] ?? '',
      endAddress: json['end_address'] ?? '',
      startLocation: RouteLocation.fromJson(json['start_location'] ?? {}),
      endLocation: RouteLocation.fromJson(json['end_location'] ?? {}),
    );
  }
}

/// Distance information from Google API
class RouteDistance {
  final String text; // Human readable (e.g., "5.2 mi")
  final int value;   // Meters

  RouteDistance({
    required this.text,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'value': value,
    };
  }

  factory RouteDistance.fromJson(Map<String, dynamic> json) {
    return RouteDistance(
      text: json['text'] ?? '',
      value: json['value'] ?? 0,
    );
  }
}

/// Duration information from Google API  
class RouteDuration {
  final String text; // Human readable (e.g., "15 mins")
  final int value;   // Seconds

  RouteDuration({
    required this.text,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'value': value,
    };
  }

  factory RouteDuration.fromJson(Map<String, dynamic> json) {
    return RouteDuration(
      text: json['text'] ?? '',
      value: json['value'] ?? 0,
    );
  }
}

/// Geographic location coordinates
class RouteLocation {
  final double lat;
  final double lng;

  RouteLocation({
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  factory RouteLocation.fromJson(Map<String, dynamic> json) {
    return RouteLocation(
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
    );
  }
}

/// Polyline data for drawing routes on map
class OverviewPolyline {
  final String points; // Encoded polyline string

  OverviewPolyline({
    required this.points,
  });

  factory OverviewPolyline.fromJson(Map<String, dynamic> json) {
    return OverviewPolyline(
      points: json['points'] ?? '',
    );
  }
}

// MARK: - Error Types

/// Route calculation specific errors
enum RouteCalculationError {
  invalidUrl,
  noData,
  apiError,
}

/// Extension to provide error descriptions
extension RouteCalculationErrorExtension on RouteCalculationError {
  String get description {
    switch (this) {
      case RouteCalculationError.invalidUrl:
        return 'Invalid API URL';
      case RouteCalculationError.noData:
        return 'No data received from API';
      case RouteCalculationError.apiError:
        return 'API Error occurred';
    }
  }
}

/// Custom exception for route calculation errors
class RouteCalculationException implements Exception {
  final RouteCalculationError error;
  final String? details;

  RouteCalculationException(this.error, [this.details]);

  @override
  String toString() {
    return details != null 
        ? '${error.description}: $details'
        : error.description;
  }
}