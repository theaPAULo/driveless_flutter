// lib/models/saved_route_model.dart
//
// Model for saved routes - handles Firestore and local storage
// Allows users to save, load, and manage their favorite routes

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'route_models.dart';

/// Saved route with metadata for user management
class SavedRoute {
  final String id;  // Unique identifier
  final String name;  // User-friendly name
  final DateTime savedAt;  // When it was saved
  final OptimizedRouteResult routeResult;  // The actual route data
  final OriginalRouteInputs originalInputs;  // Original user inputs
  final bool isFavorite;  // Mark as favorite (for future use)

  SavedRoute({
    required this.id,
    required this.name,
    required this.savedAt,
    required this.routeResult,
    required this.originalInputs,
    this.isFavorite = false,
  });

  /// Convert SavedRoute to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'savedAt': savedAt.toIso8601String(),
      'routeResult': routeResult.toJson(),
      'originalInputs': originalInputs.toJson(),
      'isFavorite': isFavorite,
    };
  }

  /// Create SavedRoute from JSON (handles both Firestore and local storage)
  factory SavedRoute.fromJson(Map<String, dynamic> json) {
    DateTime savedAtDate;
    
    // Handle different date formats (Firestore Timestamp vs ISO String)
    if (json['savedAt'] is Timestamp) {
      savedAtDate = (json['savedAt'] as Timestamp).toDate();
    } else if (json['savedAt'] is String) {
      savedAtDate = DateTime.parse(json['savedAt']);
    } else {
      savedAtDate = DateTime.now();
    }
    
    return SavedRoute(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      savedAt: savedAtDate,
      routeResult: OptimizedRouteResult.fromJson(json['routeResult'] ?? {}),
      originalInputs: OriginalRouteInputs.fromJson(json['originalInputs'] ?? {}),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  /// Create a copy with modified fields
  SavedRoute copyWith({
    String? id,
    String? name,
    DateTime? savedAt,
    OptimizedRouteResult? routeResult,
    OriginalRouteInputs? originalInputs,
    bool? isFavorite,
  }) {
    return SavedRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      savedAt: savedAt ?? this.savedAt,
      routeResult: routeResult ?? this.routeResult,
      originalInputs: originalInputs ?? this.originalInputs,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Generate a smart route name based on stops
  static String generateRouteName(OptimizedRouteResult routeResult) {
    final stops = routeResult.optimizedStops;
    
    if (stops.isEmpty) {
      return 'Route ${DateTime.now().month}/${DateTime.now().day}';
    }
    
    if (stops.length == 1) {
      return 'To ${_getShortName(stops.first.displayName)}';
    }
    
    if (stops.length == 2) {
      return '${_getShortName(stops.first.displayName)} → ${_getShortName(stops.last.displayName)}';
    }
    
    // Multiple stops
    return '${_getShortName(stops.first.displayName)} + ${stops.length - 2} stops → ${_getShortName(stops.last.displayName)}';
  }

  /// Get shortened business name for display
  static String _getShortName(String fullName) {
    // Remove common business suffixes and keep it short
    String name = fullName
        .replaceAll(RegExp(r'\s*,.*$'), '') // Remove everything after first comma
        .replaceAll(RegExp(r'\s*(Inc|LLC|Corp|Ltd)\.?$', caseSensitive: false), '')
        .trim();
    
    // Limit length for display
    if (name.length > 15) {
      name = '${name.substring(0, 12)}...';
    }
    
    return name.isEmpty ? 'Unknown' : name;
  }

  /// Get formatted date for display
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(savedAt);
    
    if (difference.inDays == 0) {
      // Today - show time
      final hour = savedAt.hour;
      final minute = savedAt.minute.toString().padLeft(2, '0');
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $amPm';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${savedAt.month}/${savedAt.day}/${savedAt.year}';
    }
  }

  /// Get summary of route for quick viewing
  String get routeSummary {
    final stopCount = routeResult.optimizedStops.length;
    return '$stopCount stops • ${routeResult.totalDistance} • ${routeResult.estimatedTime}';
  }

  @override
  String toString() {
    return 'SavedRoute(id: $id, name: $name, stops: ${routeResult.optimizedStops.length})';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SavedRoute &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}