// lib/screens/route_input_screen.dart
//
// COMPLETE VERSION: Theme Colors + Proper Theme Switching + All Fixes
// - Now properly uses Theme.of(context) for light/dark theme switching
// - Added "Use Current Location" pins to ALL input fields
// - Fixed spacing to match iOS design
// - Restored reverse geocoding functionality
// - All existing functionality preserved

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/route_models.dart';
import '../services/route_calculator_service.dart';
import '../services/usage_tracking_service.dart';
import '../services/analytics_service.dart';
import '../services/error_tracking_service.dart';
import '../widgets/autocomplete_text_field.dart';
import '../services/saved_address_service.dart';
import '../models/saved_address_model.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart'; // Add theme provider import
import 'route_results_screen.dart';

class RouteInputScreen extends StatefulWidget {
  const RouteInputScreen({Key? key}) : super(key: key);

  @override
  State<RouteInputScreen> createState() => _RouteInputScreenState();
}

class _RouteInputScreenState extends State<RouteInputScreen> {
  // Controllers for text inputs
  final TextEditingController _startLocationController = TextEditingController();
  final TextEditingController _endLocationController = TextEditingController();
  final List<TextEditingController> _stopControllers = [];
  
  // Services
  final RouteCalculatorService _routeService = RouteCalculatorService();
  final UsageTrackingService _usageTrackingService = UsageTrackingService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final ErrorTrackingService _errorTrackingService = ErrorTrackingService();
  final SavedAddressService _savedAddressService = SavedAddressService();
  
  // State variables
  bool _isOptimizing = false;
  bool _isRoundTrip = false;
  bool _includeTraffic = true;
  Map<String, bool> _loadingStates = {}; // Track loading state for each field
  List<SavedAddress> _savedAddresses = [];
  
  // Address storage for formatted addresses from autocomplete
  String _startLocationAddress = '';
  String _endLocationAddress = '';
  String _tempEndLocation = '';
  String _tempEndAddress = '';
  final List<String> _stopAddresses = [];

  // Helper to get loading state for a specific field
  bool _isLoadingLocation(String fieldId) {
    return _loadingStates[fieldId] ?? false;
  }

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
    _loadSettings();
  }

  @override
  void dispose() {
    _startLocationController.dispose();
    _endLocationController.dispose();
    for (final controller in _stopControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Load saved addresses from storage
  Future<void> _loadSavedAddresses() async {
    try {
      await _savedAddressService.initialize();
      final addresses = _savedAddressService.savedAddresses;
      if (mounted) {
        setState(() {
          _savedAddresses = addresses;
        });
        print('📍 Loaded ${addresses.length} saved addresses');
      }
    } catch (e) {
      print('Error loading saved addresses: $e');
    }
  }

  /// Load user settings
  void _loadSettings() {
    setState(() {
      _isRoundTrip = false;
      _includeTraffic = true;
    });
  }

  // Helper functions for address types - FIXED WITH CORRECT TYPE
  IconData getAddressIcon(SavedAddressType type) {
    switch (type) {
      case SavedAddressType.home:
        return Icons.home;
      case SavedAddressType.work:
        return Icons.work;
      case SavedAddressType.custom:
        return Icons.place;
    }
  }

  Color getAddressColor(SavedAddressType type) {
    switch (type) {
      case SavedAddressType.home:
        return AppThemes.primaryGreen; // Use theme color
      case SavedAddressType.work:
        return Colors.blue;
      case SavedAddressType.custom:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME-AWARE: Use Theme.of(context) for proper theme switching
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color ?? 
                     (isDark ? const Color(0xFF1C1C1E) : Colors.white);
    
    return Scaffold(
      backgroundColor: backgroundColor, // 🎨 THEME-AWARE
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24), // Better spacing
                    
                    // Route Input Section
                    _buildRouteInputSection(),
                    
                    const SizedBox(height: 24), // Better spacing
                    
                    // Settings Section
                    _buildSettingsSection(),
                    
                    const SizedBox(height: 32), // Better spacing
                    
                    // Optimize Button
                    _buildOptimizeButton(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), // Better spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan Your Route',
            style: TextStyle(
              color: Theme.of(context).textTheme.headlineLarge?.color, // 🎨 THEME-AWARE
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6), // Better spacing
          Text(
            'Drive Less, Save Time',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), // 🎨 THEME-AWARE
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Route Input Section
  Widget _buildRouteInputSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? 
                     (isDark ? const Color(0xFF1C1C1E) : Colors.white);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor, // 🎨 THEME-AWARE
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Start location with saved addresses
          _buildLocationInput(
            controller: _startLocationController,
            icon: Icons.trip_origin,
            hintText: 'Enter start location',
            fieldId: 'start',
            isStart: true,
            iconColor: AppThemes.primaryGreen, // Green for start
            isDisabled: false,
            onAddressSelected: (address) {
              setState(() {
                _startLocationAddress = address;
                if (_isRoundTrip) {
                  _endLocationController.text = _startLocationController.text;
                  _endLocationAddress = _startLocationAddress;
                }
              });
            },
          ),
          
          // Stops (dynamically added)
          for (int i = 0; i < _stopControllers.length; i++)
            Column(
              children: [
                const SizedBox(height: 20), // Better spacing
                _buildLocationInput(
                  controller: _stopControllers[i],
                  icon: Icons.place,
                  hintText: 'Stop ${i + 1}',
                  fieldId: 'stop_$i',
                  stopIndex: i,
                  iconColor: Colors.orange, // Orange for stops
                  isDisabled: false,
                  onAddressSelected: (address) {
                    setState(() {
                      // Ensure _stopAddresses list is long enough
                      while (_stopAddresses.length <= i) {
                        _stopAddresses.add('');
                      }
                      _stopAddresses[i] = address;
                    });
                  },
                  onRemove: () => _removeStop(i),
                ),
              ],
            ),
          
          const SizedBox(height: 20), // Better spacing
          
          // Add Stop button
          _buildAddStopButton(),
          
          const SizedBox(height: 20), // Better spacing
          
          // End location
          _buildLocationInput(
            controller: _endLocationController,
            icon: Icons.flag,
            hintText: _isRoundTrip ? 'Return to starting location' : 'Enter destination',
            fieldId: 'end',
            isStart: false,
            iconColor: _isRoundTrip ? Colors.grey : Colors.red, // Red for destination, grey when disabled
            isDisabled: _isRoundTrip,
            onAddressSelected: (address) {
              if (!_isRoundTrip) {
                setState(() {
                  _endLocationAddress = address;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // MARK: - Location Input Field - FIXED TO MATCH iOS DESIGN
  Widget _buildLocationInput({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required String fieldId,
    required Color iconColor,
    required bool isDisabled,
    required Function(String) onAddressSelected,
    bool isStart = false,
    int? stopIndex,
    VoidCallback? onRemove,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ FIXED: Saved addresses chips row ABOVE text field for more horizontal space
        if (_savedAddresses.isNotEmpty) ...[
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _savedAddresses.length,
              itemBuilder: (context, index) {
                final address = _savedAddresses[index];
                final addressIcon = getAddressIcon(address.addressType);
                final addressColor = getAddressColor(address.addressType);
                
                return Container(
                  margin: EdgeInsets.only(
                    right: 8,
                    left: index == 0 ? 0 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => _selectSavedAddress(
                      address, 
                      isStart,
                      stopIndex: stopIndex,
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: addressColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: addressColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        addressIcon,
                        color: addressColor,
                        size: 20,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12), // Space between chips and input
        ],
        
        // Location input field
        Row(
          children: [
            // ✅ FIXED: Single pin icon that serves as both field identifier AND "use current location"
            GestureDetector(
              onTap: !isDisabled ? () => _useCurrentLocation(isStart, stopIndex: stopIndex) : null,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: !isDisabled 
                      ? iconColor.withOpacity(0.1) 
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: !isDisabled
                        ? iconColor.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon, // Use the field-specific icon (trip_origin, place, flag)
                  color: !isDisabled ? iconColor : Colors.grey,
                  size: 18,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // ✅ FIXED: Text field with proper light theme colors
            Expanded(
              child: _isLoadingLocation(fieldId)
                  ? Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : const Color(0xFFF2F2F7), // Light iOS background
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    )
                  : AutocompleteTextField(
                      controller: controller,
                      hint: hintText,
                      icon: icon,
                      iconColor: iconColor,
                      enabled: !isDisabled,
                      onPlaceSelected: (PlaceDetails place) {
                        // Convert PlaceDetails to address string and call the callback
                        onAddressSelected(place.formattedAddress);
                      },
                      onChanged: () {
                        // Optional: Handle text changes if needed
                      },
                    ),
            ),
            
            // Remove button for stops
            if (onRemove != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // MARK: - Add Stop Button
  Widget _buildAddStopButton() {
    return GestureDetector(
      onTap: _addStop,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppThemes.primaryGreen.withOpacity(0.1), // Use theme color
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppThemes.primaryGreen.withOpacity(0.3), // Use theme color
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: AppThemes.primaryGreen, // Use theme color
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Stop',
              style: TextStyle(
                color: AppThemes.primaryGreen, // Use theme color
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Settings Section (Round Trip & Traffic) - THEME-AWARE
  Widget _buildSettingsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? 
                     (isDark ? const Color(0xFF1C1C1E) : Colors.white);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor, // 🎨 THEME-AWARE
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Round Trip Toggle - NOW USES THEME PRIMARY GREEN
          _buildToggleOption(
            icon: Icons.refresh,
            title: 'Round Trip',
            subtitle: 'Return to starting location',
            value: _isRoundTrip,
            activeColor: AppThemes.primaryGreen, // Use theme color instead of hardcoded
            onChanged: (value) {
              setState(() {
                _isRoundTrip = value;
                if (_isRoundTrip) {
                  // Store what was in destination before
                  _tempEndLocation = _endLocationController.text;
                  _tempEndAddress = _endLocationAddress;
                  // Show start location in destination field
                  _endLocationController.text = _startLocationController.text;
                  _endLocationAddress = _startLocationAddress;
                } else {
                  // Restore previous destination values
                  _endLocationController.text = _tempEndLocation;
                  _endLocationAddress = _tempEndAddress;
                }
              });
            },
          ),
          
          Container(
            height: 0.5,
            margin: const EdgeInsets.symmetric(vertical: 16), // Better spacing
            color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[300], // 🎨 THEME-AWARE
          ),
          
          // Traffic Toggle - NOW USES THEME TRAFFIC ORANGE
          _buildToggleOption(
            icon: Icons.traffic_rounded,
            title: 'Consider Traffic',
            subtitle: 'Include current traffic conditions',
            value: _includeTraffic,
            activeColor: AppThemes.trafficOrange, // Use theme color instead of hardcoded
            onChanged: (value) {
              setState(() {
                _includeTraffic = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // MARK: - Toggle Option Widget - THEME-AWARE
  Widget _buildToggleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    Color? activeColor,
  }) {
    // Use theme primary green as default fallback
    final effectiveColor = activeColor ?? AppThemes.primaryGreen;
    
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: effectiveColor.withOpacity(0.1), // Use theme color
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: effectiveColor, // Use theme color
            size: 20,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, // 🎨 THEME-AWARE
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), // 🎨 THEME-AWARE
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: effectiveColor, // Use theme color
          activeTrackColor: effectiveColor.withOpacity(0.3), // Use theme color
          inactiveThumbColor: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey[400] : Colors.grey[600], // 🎨 THEME-AWARE
          inactiveTrackColor: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey[800] : Colors.grey[300], // 🎨 THEME-AWARE
        ),
      ],
    );
  }

  // MARK: - Optimize Button with Theme-Based Gradient
  Widget _buildOptimizeButton() {
    final bool canOptimize = _startLocationAddress.isNotEmpty && 
                             (_isRoundTrip || _endLocationAddress.isNotEmpty);
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: canOptimize 
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemes.primaryGreen, // Use theme primary green
                  AppThemes.primaryGreen.withOpacity(0.8), // Lighter version
                  AppThemes.secondaryGreen, // Use theme secondary green
                ],
                stops: const [0.0, 0.6, 1.0],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[700]!,
                  Colors.grey[800]!,
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: canOptimize ? [
          BoxShadow(
            color: AppThemes.primaryGreen.withOpacity(0.3), // Use theme color
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: ElevatedButton(
        onPressed: canOptimize && !_isOptimizing ? _optimizeRoute : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Let gradient show through
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isOptimizing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.route, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    canOptimize ? 'Optimize Route' : 'Enter start and destination',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // MARK: - Helper Methods (All existing functionality preserved)

  void _addStop() {
    setState(() {
      _stopControllers.add(TextEditingController());
    });
  }

  void _removeStop(int index) {
    setState(() {
      _stopControllers[index].dispose();
      _stopControllers.removeAt(index);
      
      // Also remove from addresses list if it exists
      if (index < _stopAddresses.length) {
        _stopAddresses.removeAt(index);
      }
    });
  }

  void _selectSavedAddress(SavedAddress address, bool isStart, {int? stopIndex}) {
    setState(() {
      if (isStart) {
        _startLocationController.text = address.displayName.isNotEmpty ? address.displayName : address.label;
        _startLocationAddress = address.fullAddress;
        if (_isRoundTrip) {
          _endLocationController.text = address.displayName.isNotEmpty ? address.displayName : address.label;
          _endLocationAddress = address.fullAddress;
        }
      } else if (stopIndex != null) {
        _stopControllers[stopIndex].text = address.displayName.isNotEmpty ? address.displayName : address.label;
        while (_stopAddresses.length <= stopIndex) {
          _stopAddresses.add('');
        }
        _stopAddresses[stopIndex] = address.fullAddress;
      } else {
        _endLocationController.text = address.displayName.isNotEmpty ? address.displayName : address.label;
        _endLocationAddress = address.fullAddress;
      }
    });
  }

  // ✅ RESTORED: Use Current Location with Reverse Geocoding
  Future<void> _useCurrentLocation(bool isStart, {int? stopIndex}) async {
    setState(() {
      if (isStart) {
        _loadingStates['start'] = true;
      } else if (stopIndex != null) {
        _loadingStates['stop_$stopIndex'] = true;
      } else {
        _loadingStates['end'] = true;
      }
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // ✅ RESTORED: Reverse geocode to get address
      String address = await _reverseGeocode(position.latitude, position.longitude);
      
      setState(() {
        if (isStart) {
          _startLocationController.text = 'Current Location';
          _startLocationAddress = address;
          if (_isRoundTrip) {
            _endLocationController.text = 'Current Location';
            _endLocationAddress = address;
          }
        } else if (stopIndex != null) {
          _stopControllers[stopIndex].text = 'Current Location';
          while (_stopAddresses.length <= stopIndex) {
            _stopAddresses.add('');
          }
          _stopAddresses[stopIndex] = address;
        } else {
          _endLocationController.text = 'Current Location';
          _endLocationAddress = address;
        }
      });

      print('✅ Current location set: $address');

    } catch (e) {
      print('❌ Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get current location: ${e.toString()}'),
            backgroundColor: AppThemes.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      setState(() {
        if (isStart) {
          _loadingStates['start'] = false;
        } else if (stopIndex != null) {
          _loadingStates['stop_$stopIndex'] = false;
        } else {
          _loadingStates['end'] = false;
        }
      });
    }
  }

  // ✅ RESTORED: Reverse Geocoding
  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final String url = 
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${AppConstants.googleApiKey}';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && 
            data['results'] != null && 
            data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        } else {
          print('❌ Geocoding API error: ${data['status']}');
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Reverse geocoding error: $e');
    }
    
    // Fallback to coordinates
    return '$lat, $lng';
  }

  // MARK: - Optimize Route Logic (All existing functionality preserved)
  Future<void> _optimizeRoute() async {
    if (_isOptimizing) return;

    setState(() {
      _isOptimizing = true;
    });

    try {
      // Collect stop addresses (intermediate stops only)
      List<String> stops = [];
      for (int i = 0; i < _stopControllers.length; i++) {
        if (i < _stopAddresses.length && _stopAddresses[i].isNotEmpty) {
          stops.add(_stopAddresses[i]);
        }
      }

      // Collect display names for UI
      List<String> stopDisplayNames = [];
      for (int i = 0; i < _stopControllers.length; i++) {
        stopDisplayNames.add(_stopControllers[i].text);
      }

      print('🔄 Optimizing route:');
      print('   Start: ${_startLocationAddress} (${_startLocationController.text})');
      print('   Stops: $stops ($stopDisplayNames)');
      print('   End: ${_endLocationAddress} (${_endLocationController.text})');

      // Create original inputs to preserve display names
      final originalInputs = OriginalRouteInputs(
        startLocation: _startLocationAddress,
        endLocation: _isRoundTrip ? _startLocationAddress : _endLocationAddress,
        stops: stops,
        startLocationDisplayName: _startLocationController.text,
        endLocationDisplayName: _isRoundTrip ? _startLocationController.text : _endLocationController.text,
        stopDisplayNames: stopDisplayNames,
        isRoundTrip: _isRoundTrip,
        includeTraffic: _includeTraffic,
      );

      // Call route optimization service with correct method name
      final routeResult = await _routeService.calculateOptimizedRoute(
        startLocation: originalInputs.startLocation,
        endLocation: originalInputs.endLocation,
        stops: stops,
        originalInputs: originalInputs,
      );

      print('✅ Route optimization completed');

      // Navigate to results screen with correct constructor
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RouteResultsScreen(
              routeResult: routeResult,
              originalInputs: originalInputs,
            ),
          ),
        );
      }

    } catch (e) {
      print('❌ Route optimization failed: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to optimize route: $e'),
            backgroundColor: AppThemes.errorRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOptimizing = false;
        });
      }
    }
  }
}