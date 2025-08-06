// lib/widgets/autocomplete_text_field.dart
//
// COMPLETE VERSION: Theme-aware autocomplete text field
// Now properly switches between light and dark themes
// Matches iOS design in both themes

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

/// Google Places service for API calls
class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  /// Get autocomplete suggestions from Google Places API
  Future<List<PlacePrediction>> getAutocompleteSuggestions(String input) async {
    try {
      final String url = 
          '$_baseUrl/autocomplete/json?input=${Uri.encodeComponent(input)}&key=${AppConstants.googleApiKey}';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['predictions'] != null) {
          return (data['predictions'] as List)
              .map((prediction) => PlacePrediction.fromJson(prediction))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Places API error: $e');
      }
      return [];
    }
  }

  /// Get detailed place information from place ID
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final String url = 
          '$_baseUrl/details/json?place_id=$placeId&fields=place_id,name,formatted_address,geometry&key=${AppConstants.googleApiKey}';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          return PlaceDetails.fromJson(data['result']);
        }
      }
      
      return null;
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Place details API error: $e');
      }
      return null;
    }
  }
}

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

/// Custom autocomplete text field widget with theme support
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
  final FocusNode _focusNode = FocusNode();
  bool _isSelecting = false; // Flag to prevent re-triggering suggestions

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<PlacePrediction>(
      controller: widget.controller,
      focusNode: _focusNode,
      
      // ✅ THEME-AWARE: Configure the text field appearance
      builder: (context, controller, focusNode) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            // 🎨 FIXED: Theme-aware background colors
            color: widget.enabled 
                ? (isDark 
                    ? const Color(0xFF3A3A3C) // Dark theme
                    : const Color(0xFFF2F2F7)) // Light theme - iOS light gray
                : (isDark 
                    ? const Color(0xFF3A3A3C).withOpacity(0.5) // Dark theme disabled
                    : const Color(0xFFF2F2F7).withOpacity(0.5)), // Light theme disabled
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focusNode.hasFocus 
                  ? const Color(0xFF34C759) // Green border when focused (both themes)
                  : (isDark 
                      ? const Color(0xFF48484A) // Dark theme border
                      : const Color(0xFFD1D1D6)), // Light theme border
              width: focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: widget.enabled,
            style: TextStyle(
              // 🎨 FIXED: Theme-aware text colors
              color: widget.enabled 
                  ? (isDark ? Colors.white : Colors.black) // Theme-aware text
                  : (isDark ? Colors.grey[500] : Colors.grey[600]), // Theme-aware disabled text
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                // 🎨 FIXED: Theme-aware hint colors
                color: isDark ? Colors.grey[500] : Colors.grey[600],
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
      hideOnSelect: true, // Automatically hide on selection
      
      // Debounce duration to avoid too many API calls
      debounceDuration: const Duration(milliseconds: 300),
      
      // ✅ THEME-AWARE: Loading builder
      loadingBuilder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          color: isDark 
              ? const Color(0xFF2C2C2E) // Dark theme
              : const Color(0xFFF2F2F7), // Light theme
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
                    const Color(0xFF34C759),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Searching...',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
      
      // Empty builder (when no suggestions)
      emptyBuilder: (context) => Container(),
      
      // ✅ THEME-AWARE: Error builder
      errorBuilder: (context, error) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          color: isDark 
              ? const Color(0xFF2C2C2E) // Dark theme
              : const Color(0xFFF2F2F7), // Light theme
          padding: const EdgeInsets.all(16),
          child: Text(
            'Unable to load suggestions',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
      
      // Suggestions callback - fetch from Google Places API
      suggestionsCallback: (pattern) async {
        // Don't fetch suggestions if we're in the middle of selecting
        if (_isSelecting) return [];
        
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
      
      // ✅ THEME-AWARE: Build suggestion items
      itemBuilder: (context, suggestion) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          color: isDark 
              ? const Color(0xFF2C2C2E) // Dark theme
              : const Color(0xFFF2F2F7), // Light theme
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                // Set the selecting flag to prevent re-triggering
                setState(() {
                  _isSelecting = true;
                });
                
                // Immediately unfocus to hide keyboard and suggestions
                _focusNode.unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
                
                // Set the text immediately for visual feedback
                widget.controller.text = suggestion.mainText ?? suggestion.description;
                
                // Fetch place details in background
                try {
                  final details = await _placesService.getPlaceDetails(suggestion.placeId);
                  if (details != null && widget.onPlaceSelected != null) {
                    widget.onPlaceSelected!(details);
                  }
                } catch (e) {
                  print('❌ Error fetching place details: $e');
                } finally {
                  // Reset the flag after a delay to allow for new searches
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      setState(() {
                        _isSelecting = false;
                      });
                    }
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: const Color(0xFF34C759),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.mainText ?? suggestion.description,
                            style: TextStyle(
                              // 🎨 FIXED: Theme-aware text colors
                              color: isDark ? Colors.white : Colors.black,
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
                                  // 🎨 FIXED: Theme-aware secondary text colors
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
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
      
      // Handle selection - fallback if itemBuilder tap doesn't work
      onSelected: (suggestion) async {
        // Set flag to prevent re-triggering
        setState(() {
          _isSelecting = true;
        });
        
        // Unfocus to dismiss keyboard and suggestions
        _focusNode.unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
        
        // Update text
        widget.controller.text = suggestion.mainText ?? suggestion.description;
        
        // Fetch place details
        try {
          final details = await _placesService.getPlaceDetails(suggestion.placeId);
          if (details != null && widget.onPlaceSelected != null) {
            widget.onPlaceSelected!(details);
          }
        } catch (e) {
          print('❌ Error fetching place details: $e');
        } finally {
          // Reset the flag after a delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _isSelecting = false;
              });
            }
          });
        }
      },
    );
  }
}