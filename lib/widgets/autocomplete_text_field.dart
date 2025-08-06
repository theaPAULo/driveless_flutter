// lib/widgets/autocomplete_text_field.dart
//
// Smart address input field with Google Places autocomplete
// Updated with inline typing and improved UI

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
    return TypeAheadField<PlacePrediction>(
      controller: widget.controller,
      
      // Configure the text field appearance
      builder: (context, controller, focusNode) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.enabled 
                ? const Color(0xFF3A3A3C) 
                : const Color(0xFF3A3A3C).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focusNode.hasFocus 
                  ? const Color(0xFF2E7D32) // Green border when focused
                  : const Color(0xFF48484A),
              width: focusNode.hasFocus ? 2 : 1,
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
      
      // Configure suggestions behavior
      hideOnEmpty: true,
      hideOnError: true,
      hideOnLoading: false,
      autoFlipDirection: true,
      direction: VerticalDirection.down,
      hideOnUnfocus: true,
      
      // Debounce duration to avoid too many API calls
      debounceDuration: const Duration(milliseconds: 300),
      
      // Loading builder
      loadingBuilder: (context) => Container(
        color: const Color(0xFF2C2C2E),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Searching...',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      
      // Empty builder (when no suggestions)
      emptyBuilder: (context) => Container(),
      
      // Error builder
      errorBuilder: (context, error) => Container(
        color: const Color(0xFF2C2C2E),
        padding: const EdgeInsets.all(16),
        child: Text(
          'Unable to load suggestions',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      
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
      
      // Build suggestion items with improved layout
      itemBuilder: (context, suggestion) {
        return Container(
          color: const Color(0xFF2C2C2E),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                // Set the text immediately for better UX
                widget.controller.text = suggestion.mainText ?? suggestion.description;
                
                // Then fetch full place details
                try {
                  final details = await _placesService.getPlaceDetails(suggestion.placeId);
                  if (details != null && widget.onPlaceSelected != null) {
                    widget.onPlaceSelected!(details);
                  }
                } catch (e) {
                  print('❌ Error fetching place details: $e');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: const Color(0xFF2E7D32),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.mainText ?? suggestion.description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (suggestion.secondaryText != null &&
                              suggestion.secondaryText!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                suggestion.secondaryText!,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      
      // Handle selection
      onSelected: (suggestion) async {
        // This is already handled in itemBuilder's onTap
      },
      
      // Decoration for the suggestions container
      decorationBuilder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      },
    );
  }
}

/// Service to handle Google Places API calls
class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  /// Get autocomplete suggestions
  Future<List<PlacePrediction>> getAutocompleteSuggestions(String input) async {
    if (input.isEmpty) return [];

    final String url = '$_baseUrl/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&key=${EnvironmentConfig.apiKey}'  // FIXED: Use correct API key reference
        '&types=geocode|establishment'
        '&components=country:us';

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions
              .map((p) => PlacePrediction.fromJson(p))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('❌ Places API error: $e');
      return [];
    }
  }

  /// Get detailed place information
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    final String url = '$_baseUrl/details/json'
        '?place_id=$placeId'
        '&fields=place_id,name,formatted_address,geometry'
        '&key=${EnvironmentConfig.apiKey}';  // FIXED: Use correct API key reference

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['result'] != null) {
          return PlaceDetails.fromJson(data['result']);
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Place details error: $e');
      return null;
    }
  }
}