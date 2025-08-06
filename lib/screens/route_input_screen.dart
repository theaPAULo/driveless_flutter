// lib/screens/route_input_screen.dart
//
// COMPLETE VERSION: Round Trip Bug Fixed + UI Improvements
// - Fixed destination field to always show (grayed out when round trip enabled)
// - Improved spacing to match iOS design better
// - Maintains all existing functionality

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
      padding: const EdgeInsets.all(20), // Increased padding to match iOS
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
          
          // Show connector line and spacing when we have content below
          if (_stopControllers.isNotEmpty || true) ...[
            const SizedBox(height: 16), // Improved spacing
            _buildConnectorLine(),
            const SizedBox(height: 16),
          ],
          
          // Stops Section
          ..._buildStopsSection(),
          
          // Add connector line if we have stops before destination
          if (_stopControllers.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildConnectorLine(),
            const SizedBox(height: 16),
          ],
          
          // FIXED: End Location Section (ALWAYS show, but disabled when round trip)
          _buildLocationSection(
            label: _isRoundTrip ? 'Return to start' : 'Destination',
            controller: _endLocationController,
            icon: Icons.location_on,
            iconColor: const Color(0xFFFF3B30), // iOS red
            isStart: false,
            isDisabled: _isRoundTrip, // This makes it grayed out but still visible
          ),
        ],
      ),
    );
  }

  // MARK: - Connector Line
  Widget _buildConnectorLine() {
    return Row(
      children: [
        const SizedBox(width: 28), // Align with icon position
        Container(
          width: 2,
          height: 24, // Slightly taller for better visual balance
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  // MARK: - Build Stops Section
  List<Widget> _buildStopsSection() {
    List<Widget> stops = [];
    
    // Add existing stops
    for (int i = 0; i < _stopControllers.length; i++) {
      stops.add(
        _buildLocationSection(
          label: 'Stop ${i + 1}',
          controller: _stopControllers[i],
          icon: Icons.location_on,
          iconColor: const Color(0xFF8B4513), // Brown color for stops
          isStart: false,
          stopIndex: i,
        ),
      );
      
      // Add connector line between stops
      if (i < _stopControllers.length - 1) {
        stops.addAll([
          const SizedBox(height: 16),
          _buildConnectorLine(),
          const SizedBox(height: 16),
        ]);
      }
    }
    
    // Add "Add Stop" button with better spacing
    if (!_isRoundTrip) { // Only show Add Stop if not round trip
      if (_stopControllers.isNotEmpty) {
        stops.addAll([
          const SizedBox(height: 16),
          _buildConnectorLine(),
          const SizedBox(height: 16),
        ]);
      }
      
      stops.add(
        GestureDetector(
          onTap: _addStop,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF34C759),
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
      );
    }
    
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
            margin: const EdgeInsets.only(bottom: 12), // Better spacing
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _savedAddresses.length,
              itemBuilder: (context, index) {
                final address = _savedAddresses[index];
                return Padding(
                  padding: EdgeInsets.only(
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: iconColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.push_pin,
                            color: iconColor,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            address.displayName.isNotEmpty ? address.displayName : address.label,
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        
        // Location input field
        Row(
          children: [
            // Location pin icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 16,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Input field - show disabled version when grayed out
            Expanded(
              child: _isLoadingLocation(fieldId)
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
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Getting location...',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : isDisabled 
                    // FIXED: Show grayed out but visible field when disabled (round trip)
                    ? Opacity(
                        opacity: 0.6, // Match iOS opacity
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A3A3C).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF48484A).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  controller.text.isNotEmpty ? controller.text : label,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
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
                            
                            // Update end location if round trip is enabled
                            if (_isRoundTrip) {
                              _endLocationController.text = controller.text;
                              _endLocationAddress = _startLocationAddress;
                            }
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
                  child: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
        
        // "Use current location" button - only show when field is empty and not disabled
        if (controller.text.isEmpty && !isDisabled && !_isLoadingLocation(fieldId)) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _useCurrentLocation(isStart, stopIndex: stopIndex),
            child: Padding(
              padding: const EdgeInsets.only(left: 44), // Align with text field
              child: Row(
                children: [
                  Icon(
                    Icons.my_location,
                    color: const Color(0xFF34C759),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Use current location',
                    style: TextStyle(
                      color: Color(0xFF34C759),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      
      // Update end location if round trip is enabled
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
  Future<void> _useCurrentLocation(bool isForStart, {int? stopIndex}) async {
    final String fieldId = stopIndex != null 
        ? 'stop_$stopIndex' 
        : (isForStart ? 'start' : 'end');
    
    setState(() {
      _loadingStates[fieldId] = true;
    });

    try {
      // Check location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

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
      );

      // Reverse geocode to get address
      final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${AppConstants.googleApiKey}',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final formattedAddress = result['formatted_address'];
          final shortAddress = _formatShortAddress(formattedAddress);

          // Update the appropriate field
          if (isForStart) {
            _startLocationAddress = formattedAddress;
            _startLocationController.text = shortAddress;
            
            // Update end location if round trip is enabled
            if (_isRoundTrip) {
              _endLocationController.text = shortAddress;
              _endLocationAddress = formattedAddress;
            }
          } else if (stopIndex != null && stopIndex < _stopControllers.length) {
            if (stopIndex < _stopAddresses.length) {
              _stopAddresses[stopIndex] = formattedAddress;
            } else {
              _stopAddresses.add(formattedAddress);
            }
            _stopControllers[stopIndex].text = shortAddress;
          } else {
            _endLocationAddress = formattedAddress;
            _endLocationController.text = shortAddress;
          }

          print('📍 Current location set: $shortAddress');
        }
      } else {
        throw Exception('Failed to get address from coordinates');
      }
    } catch (e) {
      print('❌ Error getting current location: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingStates[fieldId] = false;
        });
      }
    }
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
          // Round Trip Toggle - FIXED LOGIC
          _buildToggleOption(
            icon: Icons.loop_rounded,
            title: 'Round Trip',
            subtitle: 'Return to starting location',
            value: _isRoundTrip,
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
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[500],
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
          activeColor: activeColor ?? const Color(0xFF34C759),
          activeTrackColor: (activeColor ?? const Color(0xFF34C759)).withOpacity(0.3),
          inactiveThumbColor: Colors.grey[400],
          inactiveTrackColor: Colors.grey[800],
        ),
      ],
    );
  }

  // MARK: - Optimize Button
  Widget _buildOptimizeButton() {
    final bool canOptimize = _startLocationAddress.isNotEmpty && 
                             (_isRoundTrip || _endLocationAddress.isNotEmpty); // Allow round trip with just start
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canOptimize && !_isOptimizing ? _optimizeRoute : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canOptimize ? const Color(0xFF34C759) : Colors.grey[700],
          foregroundColor: Colors.white,
          elevation: 0,
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

  // MARK: - Optimize Route Logic
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
            backgroundColor: Colors.red,
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