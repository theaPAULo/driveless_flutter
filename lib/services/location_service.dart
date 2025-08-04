// lib/services/location_service.dart
//
// Location service for getting user's current location
// Matches iOS app functionality for "Use Current Location" feature

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import '../widgets/autocomplete_text_field.dart';

/// Service for handling location-related functionality
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Get the user's current location
  /// Returns a PlaceDetails object representing the current location
  Future<PlaceDetails?> getCurrentLocation() async {
    try {
      if (EnvironmentConfig.logApiCalls) {
        print('📍 Requesting current location...');
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('Location services are disabled');
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationException('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationException('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (EnvironmentConfig.logApiCalls) {
        print('✅ Got location: ${position.latitude}, ${position.longitude}');
      }

      // Convert coordinates to address using reverse geocoding
      final PlaceDetails locationDetails = await _reverseGeocode(
        position.latitude,
        position.longitude,
      );

      return locationDetails;

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Location error: $e');
      }
      rethrow;
    }
  }

  /// Convert coordinates to address using Google Geocoding API
  Future<PlaceDetails> _reverseGeocode(double latitude, double longitude) async {
    try {
      // Use Google Geocoding API to convert coordinates to address
      final String url = 'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=$latitude,$longitude'
          '&key=${EnvironmentConfig.apiKey}';

      if (EnvironmentConfig.logApiCalls) {
        print('🔄 Reverse geocoding: $latitude, $longitude');
      }

      final response = await _makeHttpRequest(url);
      final data = response;

      if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
        final result = data['results'][0];
        
        // Extract the formatted address
        final String formattedAddress = result['formatted_address'] ?? 'Current Location';
        
        // Try to get a more specific name (like "Home" or business name)
        String displayName = 'Current Location';
        
        // Look for address components to create a better display name
        if (result['address_components'] != null) {
          final components = result['address_components'] as List;
          
          // Try to find street number and route for a concise address
          String? streetNumber;
          String? route;
          
          for (var component in components) {
            final types = component['types'] as List;
            if (types.contains('street_number')) {
              streetNumber = component['short_name'];
            } else if (types.contains('route')) {
              route = component['short_name'];
            }
          }
          
          // Create a concise display name if we have street info
          if (streetNumber != null && route != null) {
            displayName = '$streetNumber $route';
          } else if (route != null) {
            displayName = route;
          }
        }

        if (EnvironmentConfig.logApiCalls) {
          print('✅ Reverse geocoded: $displayName');
        }

        return PlaceDetails(
          placeId: result['place_id'] ?? '',
          name: displayName,
          formattedAddress: formattedAddress,
          latitude: latitude,
          longitude: longitude,
        );
      } else {
        throw LocationException('Could not determine address for current location');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Reverse geocoding error: $e');
      }
      
      // Fallback to coordinates if reverse geocoding fails
      return PlaceDetails(
        placeId: '',
        name: 'Current Location',
        formattedAddress: 'Current Location ($latitude, $longitude)',
        latitude: latitude,
        longitude: longitude,
      );
    }
  }

  /// Make HTTP request for reverse geocoding
  Future<Map<String, dynamic>> _makeHttpRequest(String url) async {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw LocationException('HTTP error: ${response.statusCode}');
    }
  }

  /// Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// Open app settings for location permissions
  Future<void> openLocationSettings() async {
    await openAppSettings();
  }
}

/// Custom exception for location-related errors
class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => 'LocationException: $message';
}