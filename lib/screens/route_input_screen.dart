// lib/screens/route_input_screen.dart
//
// COMPLETE VERSION: All fixes and improvements integrated (SYNTAX FIXED)
// - Horizontal saved addresses above text fields
// - Individual loading states for each location
// - Uniform pin icons
// - Remove stop functionality
// - Improved UI styling

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                    const SizedBox(height: 20),
                    
                    // Route Input Section
                    _buildRouteInputSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Settings Section
                    _buildSettingsSection(),
                    
                    const SizedBox(height: 24),
                    
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Your Route',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Optimize your multi-stop journey',
            style: TextStyle(
              color: Colors.grey[500],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2C2C2E),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Start Location Section
          _buildLocationSection(
            label: 'Starting location',
            controller: _startLocationController,
            icon: Icons.location_on,
            iconColor: const Color(0xFF34C759), // iOS green
            isStart: true,
          ),
          
          if (_stopControllers.isNotEmpty || !_isRoundTrip) ...[
            const SizedBox(height: 12),
            _buildConnectorLine(),
            const SizedBox(height: 12),
          ],
          
          // Stops Section
          ..._buildStopsSection(),
          
          // Add connector line if we have stops
          if (_stopControllers.isNotEmpty && !_isRoundTrip) ...[
            const SizedBox(height: 12),
            _buildConnectorLine(),
            const SizedBox(height: 12),
          ],
          
          // End Location Section (only if not round trip)
          if (!_isRoundTrip)
            // End Location Section (always show, but disabled if round trip)
            _buildLocationSection(
              label: 'Destination',
              controller: _endLocationController,
              icon: Icons.location_on,
              iconColor: const Color(0xFFFF3B30), // iOS red
              isStart: false,
              isDisabled: _isRoundTrip, // This makes it grayed out
            ),
        ],
      ),
    );
  }

  // MARK: - Location Section with Horizontal Saved Addresses and Remove Button
  Widget _buildLocationSection({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required bool isStart,
    bool isDisabled = false,
    int? stopIndex,
  }) {
    // Create unique ID for this field's loading state
    final String fieldId = stopIndex != null 
        ? 'stop_$stopIndex' 
        : (isStart ? 'start' : 'end');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saved address chips - horizontal row above the input field
        if (!isDisabled && _savedAddresses.isNotEmpty) ...[
          Container(
            height: 36,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _savedAddresses.length,
              itemBuilder: (context, index) {
                final address = _savedAddresses[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: 8,
                    left: index == 0 ? 52 : 0, // Align with text field
                  ),
                  child: GestureDetector(
                    onTap: () => _selectSavedAddress(address, isStart, stopIndex: stopIndex),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF34C759).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        address.addressType == SavedAddressType.home
                            ? Icons.home
                            : address.addressType == SavedAddressType.work
                                ? Icons.business
                                : Icons.place,
                        color: const Color(0xFF34C759),
                        size: 18,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        
        // Input field row with current location icon on the left
        Row(
          children: [
            // Current location icon (uniform pin icon)
            GestureDetector(
              onTap: isDisabled || _isLoadingLocation(fieldId)
                  ? null
                  : () => _useCurrentLocation(isStart, stopIndex: stopIndex, fieldId: fieldId),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: _isLoadingLocation(fieldId)
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                        ),
                      )
                    : Icon(
                        Icons.location_on, // Uniform pin icon
                        color: iconColor,
                        size: 20,
                      ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Autocomplete text field
            Expanded(
              child: isDisabled
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3C).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF48484A),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                      ),
                    )
                  : AutocompleteTextField(
                      controller: controller,
                      hint: label,
                      icon: Icons.search,
                      iconColor: Colors.transparent,
                      enabled: true,
                      onPlaceSelected: (placeDetails) {
                        if (isStart) {
                          _startLocationAddress = placeDetails.formattedAddress;
                          controller.text = placeDetails.name.isNotEmpty 
                              ? placeDetails.name 
                              : _formatShortAddress(placeDetails.formattedAddress);
                        } else if (stopIndex != null) {
                          if (stopIndex < _stopAddresses.length) {
                            _stopAddresses[stopIndex] = placeDetails.formattedAddress;
                          } else {
                            _stopAddresses.add(placeDetails.formattedAddress);
                          }
                          controller.text = placeDetails.name.isNotEmpty 
                              ? placeDetails.name 
                              : _formatShortAddress(placeDetails.formattedAddress);
                        } else {
                          _endLocationAddress = placeDetails.formattedAddress;
                          controller.text = placeDetails.name.isNotEmpty 
                              ? placeDetails.name 
                              : _formatShortAddress(placeDetails.formattedAddress);
                        }
                      },
                    ),
            ),
            
            // Add remove button for stops
            if (stopIndex != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _removeStop(stopIndex),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // Helper method to format addresses into shorter display text
  String _formatShortAddress(String fullAddress) {
    final parts = fullAddress.split(',');
    if (parts.isNotEmpty) {
      return parts[0].trim();
    }
    return fullAddress;
  }

  // Select saved address
  void _selectSavedAddress(SavedAddress address, bool isForStart, {int? stopIndex}) {
    if (isForStart) {
      _startLocationController.text = address.displayName.isNotEmpty 
          ? address.displayName 
          : address.label;
      _startLocationAddress = address.fullAddress;
      
      if (_isRoundTrip) {
        _endLocationController.text = _startLocationController.text;
        _endLocationAddress = _startLocationAddress;
      }
    } else if (stopIndex != null && stopIndex < _stopControllers.length) {
      _stopControllers[stopIndex].text = address.displayName.isNotEmpty 
          ? address.displayName 
          : address.label;
      if (stopIndex < _stopAddresses.length) {
        _stopAddresses[stopIndex] = address.fullAddress;
      } else {
        _stopAddresses.add(address.fullAddress);
      }
    } else {
      _endLocationController.text = address.displayName.isNotEmpty 
          ? address.displayName 
          : address.label;
      _endLocationAddress = address.fullAddress;
    }
  }

  // MARK: - Current Location with Reverse Geocoding
  Future<void> _useCurrentLocation(bool isForStart, {int? stopIndex, required String fieldId}) async {
    setState(() {
      _loadingStates[fieldId] = true; // Set loading for specific field
    });

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError(
          'Location permissions are permanently denied. Please enable in settings.');
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Format coordinates
      final coordinates = '${position.latitude},${position.longitude}';
      
      // Try to get a friendly name via reverse geocoding
      final friendlyName = await _reverseGeocode(position.latitude, position.longitude);
      
      // Update the appropriate field
      if (isForStart) {
        _startLocationController.text = friendlyName;
        _startLocationAddress = coordinates;
        
        if (_isRoundTrip) {
          _endLocationController.text = friendlyName;
          _endLocationAddress = coordinates;
        }
      } else if (stopIndex != null && stopIndex < _stopControllers.length) {
        _stopControllers[stopIndex].text = friendlyName;
        if (stopIndex < _stopAddresses.length) {
          _stopAddresses[stopIndex] = coordinates;
        } else {
          _stopAddresses.add(coordinates);
        }
      } else {
        _endLocationController.text = friendlyName;
        _endLocationAddress = coordinates;
      }
      
      print('📍 Using current location: $friendlyName ($coordinates)');
      
    } catch (e) {
      print('❌ Error getting location: $e');
      _showLocationError('Unable to get current location');
    } finally {
      setState(() {
        _loadingStates[fieldId] = false; // Clear loading for specific field
      });
    }
  }

  // Reverse geocode coordinates to get a friendly name
  Future<String> _reverseGeocode(double latitude, double longitude) async {
    try {
      final String apiKey = EnvironmentConfig.apiKey;
      final String url = 'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=$latitude,$longitude'
          '&key=$apiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final results = data['results'] as List;
          
          // Priority 1: Look for a point of interest (business/landmark)
          for (final result in results) {
            final types = result['types'] as List;
            if (types.contains('point_of_interest') || 
                types.contains('establishment') ||
                types.contains('park') ||
                types.contains('airport') ||
                types.contains('transit_station')) {
              final addressComponents = result['address_components'] as List;
              if (addressComponents.isNotEmpty) {
                return addressComponents[0]['long_name'] ?? result['formatted_address'];
              }
            }
          }
          
          // Priority 2: Use street address (shortened)
          final firstResult = results[0];
          final formattedAddress = firstResult['formatted_address'] as String;
          
          if (formattedAddress.contains(RegExp(r'^\d+'))) {
            final parts = formattedAddress.split(',');
            if (parts.isNotEmpty) {
              return parts[0].trim();
            }
          }
          
          // Priority 3: Use neighborhood or locality
          for (final result in results) {
            final types = result['types'] as List;
            if (types.contains('neighborhood') || types.contains('locality')) {
              final addressComponents = result['address_components'] as List;
              if (addressComponents.isNotEmpty) {
                return addressComponents[0]['long_name'];
              }
            }
          }
          
          // Priority 4: Return shortened address
          final parts = formattedAddress.split(',');
          if (parts.length >= 2) {
            return '${parts[0]}, ${parts[1]}'.trim();
          }
          return parts[0].trim();
        }
      }
    } catch (e) {
      print('❌ Reverse geocoding error: $e');
    }
    
    // Fallback to coordinates
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  // Show location error
  void _showLocationError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // MARK: - Connector Line
  Widget _buildConnectorLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 18), // Align with icon center
        Container(
          width: 1,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey[600]!,
                Colors.grey[700]!,
              ],
            ),
          ),
        ),
      ],
    );
  }

  // MARK: - Stops Section
  List<Widget> _buildStopsSection() {
    List<Widget> stops = [];
    
    for (int i = 0; i < _stopControllers.length; i++) {
      stops.add(
        Column(
          children: [
            _buildLocationSection(
              label: 'Stop ${i + 1}',
              controller: _stopControllers[i],
              icon: Icons.location_on,
              iconColor: Colors.orange,
              isStart: false,
              stopIndex: i,
            ),
            if (i < _stopControllers.length - 1 || true) ...[
              const SizedBox(height: 12),
              _buildConnectorLine(),
              const SizedBox(height: 12),
            ],
          ],
        ),
      );
    }
    
    // Improved Add Stop button
    stops.add(
      GestureDetector(
        onTap: _addStop,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF34C759).withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Add Stop',
                style: TextStyle(
                  color: Color(0xFF34C759),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    return stops;
  }

  // MARK: - Add Stop
  void _addStop() {
    setState(() {
      _stopControllers.add(TextEditingController());
    });
  }

  // MARK: - Remove Stop
  void _removeStop(int index) {
    setState(() {
      // Remove the controller
      if (index < _stopControllers.length) {
        _stopControllers[index].dispose();
        _stopControllers.removeAt(index);
      }
      
      // Remove the address
      if (index < _stopAddresses.length) {
        _stopAddresses.removeAt(index);
      }
    });
  }

  // MARK: - Settings Section
  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2C2C2E),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Round Trip Toggle
          _buildToggleOption(
            icon: Icons.loop_rounded,
            title: 'Round Trip',
            subtitle: 'Return to starting location',
            value: _isRoundTrip,
            onChanged: (value) {
              setState(() {
                final previousEndLocation = _endLocationController.text;
                final previousEndAddress = _endLocationAddress;
                
                _isRoundTrip = value;
                if (_isRoundTrip) {
                  // Store what was there before
                  _tempEndLocation = previousEndLocation;
                  _tempEndAddress = previousEndAddress;
                  // Show start location in grayed out end field
                  _endLocationController.text = _startLocationController.text;
                  _endLocationAddress = _startLocationAddress;
                } else {
                  // Restore previous values
                  _endLocationController.text = _tempEndLocation;
                  _endLocationAddress = _tempEndAddress;
                }
              });
            },
          ),
          
          Container(
            height: 0.5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            color: const Color(0xFF2C2C2E),
          ),
          
          // Traffic Toggle
          _buildToggleOption(
            icon: Icons.traffic_rounded,
            title: 'Consider Traffic',
            subtitle: 'Include current traffic conditions',
            value: _includeTraffic,
            activeColor: const Color(0xFFFF9500), // iOS orange
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

  // MARK: - Toggle Option Widget
  Widget _buildToggleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    Color? activeColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (activeColor ?? const Color(0xFF34C759)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: activeColor ?? const Color(0xFF34C759),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: activeColor ?? const Color(0xFF34C759),
          inactiveThumbColor: Colors.grey[300],
          inactiveTrackColor: Colors.grey[600],
        ),
      ],
    );
  }


  // MARK: - Optimize Button
  Widget _buildOptimizeButton() {
    final bool canOptimize = _startLocationController.text.isNotEmpty &&
        (_isRoundTrip || _endLocationController.text.isNotEmpty);

    return GestureDetector(
      onTap: canOptimize && !_isOptimizing ? _optimizeRoute : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: canOptimize
              ? LinearGradient(
                  colors: [
                    const Color(0xFF34C759),
                    const Color(0xFF30B350),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: canOptimize ? null : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: canOptimize
              ? [
                  BoxShadow(
                    color: const Color(0xFF34C759).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: _isOptimizing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.route_rounded,
                      color: canOptimize ? Colors.white : Colors.grey[600],
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Optimize Route',
                      style: TextStyle(
                        color: canOptimize ? Colors.white : Colors.grey[600],
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // MARK: - Optimize Route
  Future<void> _optimizeRoute() async {
    // Validate inputs
    if (_startLocationController.text.isEmpty) {
      _showError('Please enter a starting location');
      return;
    }

    if (!_isRoundTrip && _endLocationController.text.isEmpty) {
      _showError('Please enter a destination');
      return;
    }

    setState(() {
      _isOptimizing = true;
    });

    try {
      // Prepare locations list
      final List<String> stops = [];
      final List<String> stopDisplayNames = [];
      
      // Add stops
      for (int i = 0; i < _stopControllers.length; i++) {
        if (_stopControllers[i].text.isNotEmpty) {
          if (i < _stopAddresses.length && _stopAddresses[i].isNotEmpty) {
            stops.add(_stopAddresses[i]);
          } else {
            stops.add(_stopControllers[i].text);
          }
          stopDisplayNames.add(_stopControllers[i].text);
        }
      }

      // Create original inputs for display
      final originalInputs = OriginalRouteInputs(
        startLocation: _startLocationAddress.isNotEmpty 
            ? _startLocationAddress 
            : _startLocationController.text,
        endLocation: _isRoundTrip 
            ? _startLocationAddress.isNotEmpty 
                ? _startLocationAddress 
                : _startLocationController.text
            : _endLocationAddress.isNotEmpty 
                ? _endLocationAddress 
                : _endLocationController.text,
        stops: stops,
        startLocationDisplayName: _startLocationController.text,
        endLocationDisplayName: _isRoundTrip 
            ? _startLocationController.text 
            : _endLocationController.text,
        stopDisplayNames: stopDisplayNames,
        isRoundTrip: _isRoundTrip,
        includeTraffic: _includeTraffic,
      );

      print('🚗 Optimizing route with ${stops.length} stops');
      
      // Call the route optimization service
      final optimizedRoute = await _routeService.calculateOptimizedRoute(
        startLocation: originalInputs.startLocation,
        endLocation: originalInputs.endLocation,
        stops: stops,
        originalInputs: originalInputs,
      );

      // Track usage
      await _usageTrackingService.incrementUsage();
      
      // Log analytics
      await _analyticsService.trackRouteCalculation(
        stops: [
          originalInputs.startLocation,
          ...stops,
          originalInputs.endLocation,
        ],
        totalDistance: optimizedRoute.totalDistance,
        totalTime: optimizedRoute.estimatedTime,
        success: true,
      );

      // Navigate to results screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RouteResultsScreen(
              routeResult: optimizedRoute,
              originalInputs: originalInputs,
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Route optimization error: $e');
      _showError('Failed to optimize route. Please try again.');
      
      // Track error
      await _errorTrackingService.trackError(
        errorType: ErrorType.routeCalculation,
        errorMessage: e.toString(),
        location: 'route_input_screen',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOptimizing = false;
        });
      }
    }
  }

  // MARK: - Error Display
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}