// lib/widgets/autocomplete_text_field.dart
//
// Smart address input field with Google Places autocomplete
// Fixed to show business names instead of full addresses (matches iOS app)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

/// Model for Google Places autocomplete prediction
class PlacePrediction {
  final String placeId;
  final String description;
  final String? mainText;
  final String? secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    this.mainText,
    this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: json['structured_formatting']?['main_text'],
      secondaryText: json['structured_formatting']?['secondary_text'],
    );
  }
}

/// Model for selected place details
class PlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']?['location'] ?? {};
    return PlaceDetails(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      latitude: (location['lat'] ?? 0.0).toDouble(),
      longitude: (location['lng'] ?? 0.0).toDouble(),
    );
  }
}

/// Custom autocomplete text field widget matching iOS functionality
class AutocompleteTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final bool enabled;
  final Function(PlaceDetails)? onPlaceSelected;
  final VoidCallback? onChanged;

  const AutocompleteTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.iconColor,
    this.enabled = true,
    this.onPlaceSelected,
    this.onChanged,
  }) : super(key: key);

  @override
  State<AutocompleteTextField> createState() => _AutocompleteTextFieldState();
}

class _AutocompleteTextFieldState extends State<AutocompleteTextField> {
  final GooglePlacesService _placesService = GooglePlacesService();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              color: widget.iconColor,
              size: 16,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Autocomplete text field
          Expanded(
            child: TypeAheadField<PlacePrediction>(
              controller: widget.controller,
              builder: (context, controller, focusNode) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.enabled 
                        ? const Color(0xFF3A3A3C) 
                        : const Color(0xFF3A3A3C).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF48484A),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    enabled: widget.enabled,
                    style: TextStyle(
                      color: widget.enabled ? Colors.white : Colors.grey[500],
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      widget.onChanged?.call();
                    },
                  ),
                );
              },
              
              // Suggestions callback - fetch from Google Places API
              suggestionsCallback: (pattern) async {
                if (pattern.length < 2) return [];
                
                try {
                  return await _placesService.getAutocompleteSuggestions(pattern);
                } catch (e) {
                  if (EnvironmentConfig.logApiCalls) {
                    print('❌ Autocomplete error: $e');
                  }
                  return [];
                }
              },
              
              // Build suggestion items
              itemBuilder: (context, suggestion) {
                return Container(
                  color: const Color(0xFF2C2C2E),
                  child: ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: widget.iconColor,
                      size: 20,
                    ),
                    title: Text(
                      suggestion.mainText ?? suggestion.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: suggestion.secondaryText != null
                        ? Text(
                            suggestion.secondaryText!,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          )
                        : null,
                    dense: true,
                  ),
                );
              },
              
              // Handle selection - FIXED to show business names
              onSelected: (suggestion) async {
                try {
                  // Get detailed place information
                  final placeDetails = await _placesService.getPlaceDetails(suggestion.placeId);
                  
                  // Update the text field with business name if available, otherwise formatted address
                  // This matches iOS app behavior: show "Home Depot" instead of full address
                  final displayText = _getDisplayText(placeDetails);
                  widget.controller.text = displayText;
                  
                  if (EnvironmentConfig.logApiCalls) {
                    print('📝 Display: "$displayText" | Address: "${placeDetails.formattedAddress}"');
                  }
                  
                  // Notify parent widget
                  widget.onPlaceSelected?.call(placeDetails);
                  widget.onChanged?.call();
                  
                } catch (e) {
                  if (EnvironmentConfig.logApiCalls) {
                    print('❌ Place details error: $e');
                  }
                  // Fallback to suggestion description
                  widget.controller.text = suggestion.description;
                  widget.onChanged?.call();
                }
              },
              
              // Suggestions box decoration
              decorationBuilder: (context, child) {
                return Material(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(8),
                  elevation: 8,
                  child: child,
                );
              },
              
              // Error handling
              errorBuilder: (context, error) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF2C2C2E),
                  child: Text(
                    'Error loading suggestions',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                );
              },
              
              // Empty state
              emptyBuilder: (context) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF2C2C2E),
                  child: Text(
                    'No suggestions found',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Determine what text to display in the field
  /// Prioritize business names over addresses for better UX (matches iOS app)
  String _getDisplayText(PlaceDetails placeDetails) {
    // If we have a meaningful business name (not just an address), use it
    if (placeDetails.name.isNotEmpty && 
        placeDetails.name != placeDetails.formattedAddress &&
        !_isAddressLikeName(placeDetails.name)) {
      return placeDetails.name;
    }
    
    // Otherwise, use the formatted address
    return placeDetails.formattedAddress;
  }

  /// Check if the "name" is actually just an address
  bool _isAddressLikeName(String name) {
    // If name contains common address patterns, it's probably not a business name
    final addressPatterns = [
      RegExp(r'\d+.*\b(St|Street|Ave|Avenue|Rd|Road|Blvd|Boulevard|Dr|Drive|Ln|Lane|Way|Ct|Court)\b', caseSensitive: false),
      RegExp(r'^\d+\s+\w+', caseSensitive: false), // Starts with number and word
    ];
    
    return addressPatterns.any((pattern) => pattern.hasMatch(name));
  }
}

/// Service class for Google Places API calls
class GooglePlacesService {
  static final GooglePlacesService _instance = GooglePlacesService._internal();
  factory GooglePlacesService() => _instance;
  GooglePlacesService._internal();

  final http.Client _httpClient = http.Client();

  /// Get autocomplete suggestions from Google Places API
  Future<List<PlacePrediction>> getAutocompleteSuggestions(String input) async {
    final String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&key=${EnvironmentConfig.apiKey}'
        // Remove types restriction to get businesses, addresses, and everything
        '&components=country:us';  // Restrict to US (adjust as needed)

    if (EnvironmentConfig.logApiCalls) {
      print('🔍 Places Autocomplete: $input');
    }

    try {
      final response = await _httpClient.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final predictions = (data['predictions'] as List)
              .map((prediction) => PlacePrediction.fromJson(prediction))
              .toList();
          
          if (EnvironmentConfig.logApiCalls) {
            print('✅ Found ${predictions.length} suggestions');
          }
          
          return predictions;
        } else {
          throw Exception('Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Places autocomplete error: $e');
      }
      rethrow;
    }
  }

  /// Get detailed place information by place ID
  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    final String url = 'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&key=${EnvironmentConfig.apiKey}'
        '&fields=place_id,name,formatted_address,geometry';

    if (EnvironmentConfig.logApiCalls) {
      print('📍 Getting place details: $placeId');
    }

    try {
      final response = await _httpClient.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final placeDetails = PlaceDetails.fromJson(data['result']);
          
          if (EnvironmentConfig.logApiCalls) {
            print('✅ Got place details: ${placeDetails.name}');
          }
          
          return placeDetails;
        } else {
          throw Exception('Place Details API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Place details error: $e');
      }
      rethrow;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}