// lib/widgets/current_location_button.dart
//
// "Use Current Location" button widget matching iOS app design
// Allows users to quickly set their current location as start/destination

import 'package:flutter/material.dart';

import '../services/location_service.dart';
import '../widgets/autocomplete_text_field.dart';
import '../utils/constants.dart';

/// Button widget for "Use Current Location" functionality
class CurrentLocationButton extends StatefulWidget {
  final Function(PlaceDetails)? onLocationSelected;
  final bool isVisible;

  const CurrentLocationButton({
    Key? key,
    this.onLocationSelected,
    this.isVisible = true,
  }) : super(key: key);

  @override
  State<CurrentLocationButton> createState() => _CurrentLocationButtonState();
}

class _CurrentLocationButtonState extends State<CurrentLocationButton> {
  final LocationService _locationService = LocationService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(left: 44, top: 8), // Align with text field content
      child: GestureDetector(
        onTap: _isLoading ? null : _handleLocationTap,
        child: Row(
          children: [
            // Location icon
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(2),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF2E7D32),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.my_location,
                      color: const Color(0xFF2E7D32),
                      size: 14,
                    ),
            ),
            
            const SizedBox(width: 8),
            
            // Button text
            Text(
              'Use current location',
              style: TextStyle(
                color: _isLoading ? Colors.grey[500] : const Color(0xFF2E7D32),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle tap on the current location button
  Future<void> _handleLocationTap() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (EnvironmentConfig.logApiCalls) {
        print('📍 User tapped "Use current location"');
      }

      // Get current location
      final PlaceDetails? locationDetails = await _locationService.getCurrentLocation();

      if (locationDetails != null) {
        // Notify parent widget
        widget.onLocationSelected?.call(locationDetails);
        
        if (EnvironmentConfig.logApiCalls) {
          print('✅ Current location set: ${locationDetails.name}');
        }

        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text('Current location set'),
                ],
              ),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }

    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Current location error: $e');
      }

      // Show error dialog
      if (mounted) {
        _showLocationErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show error dialog for location issues
  void _showLocationErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.location_off,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Location Access',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            _getLocationErrorMessage(error),
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
            ),
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ),
            
            // Settings button (if permission error)
            if (error.contains('denied') || error.contains('disabled'))
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _locationService.openLocationSettings();
                },
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: const Color(0xFF2E7D32),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            
            // Retry button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLocationTap();
              },
              child: Text(
                'Retry',
                style: TextStyle(
                  color: const Color(0xFF2E7D32),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Get user-friendly error message
  String _getLocationErrorMessage(String error) {
    if (error.contains('denied')) {
      return 'DriveLess needs location access to use your current location. Please enable location permissions in Settings.';
    } else if (error.contains('disabled')) {
      return 'Location services are turned off. Please enable location services in your device settings.';
    } else if (error.contains('timeout')) {
      return 'Unable to get your location. Please check your GPS signal and try again.';
    } else {
      return 'Unable to get your current location. Please check your internet connection and try again.';
    }
  }
}