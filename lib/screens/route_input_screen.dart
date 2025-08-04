// lib/screens/route_input_screen.dart
//
// iOS-Style Route Input Screen with Saved Address Chips and Current Location
// Matches the iOS version design and functionality

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../models/route_models.dart';
import '../services/route_calculator_service.dart';
import '../services/usage_tracking_service.dart';
import '../services/analytics_service.dart';
import '../services/error_tracking_service.dart';
import '../widgets/autocomplete_text_field.dart';
import '../services/saved_address_service.dart';
import '../models/saved_address_model.dart';
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
  bool _isGettingLocation = false;
  List<SavedAddress> _savedAddresses = [];
  
  // Address storage for formatted addresses from autocomplete
  String _startLocationAddress = '';
  String _endLocationAddress = '';
  final List<String> _stopAddresses = [];

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
      final addresses = _savedAddressService.savedAddresses;
      if (mounted) {
        setState(() {
          _savedAddresses = addresses;
        });
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
                    const SizedBox(height: 24),
                    
                    // Route Input Section
                    _buildRouteInputSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Settings Section
                    _buildSettingsSection(),
                    
                    const SizedBox(height: 32),
                    
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Your Route',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optimize your multi-stop journey',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Route Input Section
  Widget _buildRouteInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Start Location Section
          _buildLocationSection(
            label: 'Starting location',
            controller: _startLocationController,
            icon: Icons.location_on,
            iconColor: const Color(0xFF2E7D32),
            isStart: true,
          ),
          
          const SizedBox(height: 16),
          
          // Connector line
          _buildConnectorLine(),
          
          const SizedBox(height: 16),
          
          // Stops Section
          ..._buildStopsSection(),
          
          // Add connector line if we have stops
          if (_stopControllers.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildConnectorLine(),
            const SizedBox(height: 16),
          ],
          
          // End Location Section
          _buildLocationSection(
            label: _isRoundTrip ? 'Return to start' : 'Destination',
            controller: _endLocationController,
            icon: Icons.flag,
            iconColor: Colors.red,
            isStart: false,
            isDisabled: _isRoundTrip,
          ),
        ],
      ),
    );
  }

  // MARK: - Location Section with Saved Address Chips
  Widget _buildLocationSection({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required bool isStart,
    bool isDisabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saved Address Chips (only show if not disabled and we have addresses)
        if (!isDisabled && _savedAddresses.isNotEmpty)
          _buildSavedAddressChips(isStart),
        
        if (!isDisabled && _savedAddresses.isNotEmpty)
          const SizedBox(height: 12),
        
        // Location Input Row
        Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Text Field
            Expanded(
              child: AutocompleteTextField(
                controller: controller,
                hint: label,
                icon: icon,
                iconColor: iconColor,
                enabled: !isDisabled,
                onPlaceSelected: (placeDetails) {
                  if (isStart) {
                    _startLocationAddress = placeDetails.formattedAddress;
                  } else {
                    _endLocationAddress = placeDetails.formattedAddress;
                  }
                },
              ),
            ),
          ],
        ),
        
        // Current Location Button (only show if field is empty and not disabled)
        if (!isDisabled && controller.text.isEmpty)
          _buildCurrentLocationButton(controller, isStart),
      ],
    );
  }

  // MARK: - Saved Address Chips
  Widget _buildSavedAddressChips(bool isForStart) {
    return Container(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _savedAddresses.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final address = _savedAddresses[index];
          return _buildSavedAddressChip(address, isForStart);
        },
      ),
    );
  }

  Widget _buildSavedAddressChip(SavedAddress address, bool isForStart) {
    IconData chipIcon;
    switch (address.addressType) {
      case SavedAddressType.home:
        chipIcon = Icons.home;
        break;
      case SavedAddressType.work:
        chipIcon = Icons.business;
        break;
      default:
        chipIcon = Icons.place;
    }

    return GestureDetector(
      onTap: () => _selectSavedAddress(address, isForStart),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withOpacity(0.1),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          chipIcon,
          color: const Color(0xFF2E7D32),
          size: 20,
        ),
      ),
    );
  }

  // MARK: - Current Location Button
  Widget _buildCurrentLocationButton(TextEditingController controller, bool isForStart) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 56),
      child: GestureDetector(
        onTap: _isGettingLocation ? null : () => _useCurrentLocation(controller, isForStart),
        child: Row(
          children: [
            Icon(
              _isGettingLocation ? Icons.hourglass_empty : Icons.my_location,
              color: const Color(0xFF2E7D32),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _isGettingLocation ? 'Getting location...' : 'Use current location',
              style: TextStyle(
                color: const Color(0xFF2E7D32),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Connector Line
  Widget _buildConnectorLine() {
    return Container(
      width: 2,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  // MARK: - Stops Section
  List<Widget> _buildStopsSection() {
    List<Widget> stopWidgets = [];
    
    for (int i = 0; i < _stopControllers.length; i++) {
      stopWidgets.add(_buildStopInput(i));
      if (i < _stopControllers.length - 1) {
        stopWidgets.add(const SizedBox(height: 16));
        stopWidgets.add(_buildConnectorLine());
        stopWidgets.add(const SizedBox(height: 16));
      }
    }
    
    // Add "Add Stop" button
    if (stopWidgets.isNotEmpty) {
      stopWidgets.add(const SizedBox(height: 16));
    }
    stopWidgets.add(_buildAddStopButton());
    
    return stopWidgets;
  }

  Widget _buildStopInput(int index) {
    return Row(
      children: [
        // Stop number
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF007AFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Text Field
        Expanded(
          child: AutocompleteTextField(
            controller: _stopControllers[index],
            hint: 'Stop ${index + 1}',
            icon: Icons.place,
            iconColor: const Color(0xFF007AFF),
            onPlaceSelected: (placeDetails) {
              while (_stopAddresses.length <= index) {
                _stopAddresses.add('');
              }
              setState(() {
                _stopAddresses[index] = placeDetails.formattedAddress;
              });
            },
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Remove button
        GestureDetector(
          onTap: () => _removeStop(index),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close,
              color: Colors.red,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddStopButton() {
    return GestureDetector(
      onTap: _addStop,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Color(0xFF2E7D32),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Add Stop',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Settings Section
  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Round Trip Toggle
          _buildToggleRow(
            icon: Icons.refresh,
            title: 'Round Trip',
            subtitle: 'Return to starting location',
            value: _isRoundTrip,
            onChanged: (value) {
              setState(() {
                _isRoundTrip = value;
                if (value) {
                  _endLocationController.clear();
                  _endLocationAddress = '';
                }
              });
            },
            activeColor: const Color(0xFF2E7D32),
          ),
          
          const SizedBox(height: 20),
          
          // Traffic Toggle
          _buildToggleRow(
            icon: Icons.traffic,
            title: 'Consider Traffic',
            subtitle: 'Include current traffic conditions',
            value: _includeTraffic,
            onChanged: (value) {
              setState(() {
                _includeTraffic = value;
              });
            },
            activeColor: const Color(0xFF8B4513),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
  }) {
    return Row(
      children: [
        // Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: activeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: activeColor,
            size: 20,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Title and subtitle
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
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        // Toggle switch
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: activeColor,
          inactiveThumbColor: Colors.grey[300],
          inactiveTrackColor: Colors.grey[600],
        ),
      ],
    );
  }

  // MARK: - Optimize Button
  Widget _buildOptimizeButton() {
    final bool canOptimize = _startLocationController.text.isNotEmpty && 
                             (_endLocationController.text.isNotEmpty || _isRoundTrip) &&
                             _stopControllers.any((controller) => controller.text.isNotEmpty);
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: canOptimize
            ? const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF8B4513)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: canOptimize ? null : Colors.grey[700],
      ),
      child: ElevatedButton(
        onPressed: canOptimize && !_isOptimizing ? _optimizeRoute : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isOptimizing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Optimizing...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    canOptimize ? 'Optimize Route' : 'Enter locations to optimize',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // MARK: - Helper Methods

  void _addStop() {
    setState(() {
      _stopControllers.add(TextEditingController());
      _stopAddresses.add('');
    });
  }

  void _removeStop(int index) {
    setState(() {
      _stopControllers[index].dispose();
      _stopControllers.removeAt(index);
      if (index < _stopAddresses.length) {
        _stopAddresses.removeAt(index);
      }
    });
  }

  void _selectSavedAddress(SavedAddress address, bool isForStart) {
    if (isForStart) {
      _startLocationController.text = address.displayName.isNotEmpty 
          ? address.displayName 
          : address.label;
      _startLocationAddress = address.fullAddress;
    } else {
      _endLocationController.text = address.displayName.isNotEmpty 
          ? address.displayName 
          : address.label;
      _endLocationAddress = address.fullAddress;
    }
  }

  Future<void> _useCurrentLocation(TextEditingController controller, bool isForStart) async {
    setState(() {
      _isGettingLocation = true;
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

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // For now, just set coordinates as text (you could reverse geocode to get address)
      final locationText = 'Current Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
      
      controller.text = locationText;
      
      if (isForStart) {
        _startLocationAddress = locationText;
      } else {
        _endLocationAddress = locationText;
      }

      // Track successful location usage
      await _analyticsService.trackEvent('current_location_used', details: isForStart ? 'start' : 'end');

    } catch (e) {
      // Track error
      await _errorTrackingService.trackLocationError(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current,
      );

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  // MARK: - Route Optimization with Enhanced Error Tracking
  Future<void> _optimizeRoute() async {
    if (_isOptimizing) return;
    
    setState(() {
      _isOptimizing = true;
    });

    try {
      // Check usage limits BEFORE route calculation
      final bool canCalculate = await _usageTrackingService.canPerformRouteCalculation();
      if (!canCalculate) {
        if (mounted) {
          _showUsageLimitDialog();
        }
        return;
      }

      // Use the formatted addresses from autocomplete
      final String startLocation = _startLocationAddress.isNotEmpty 
          ? _startLocationAddress 
          : _startLocationController.text.trim();
      
      final String endLocation = _isRoundTrip 
          ? startLocation 
          : (_endLocationAddress.isNotEmpty 
              ? _endLocationAddress 
              : _endLocationController.text.trim());
      
      // Collect valid stops
      final List<String> stops = [];
      for (int i = 0; i < _stopControllers.length; i++) {
        final stopText = _stopControllers[i].text.trim();
        if (stopText.isNotEmpty) {
          final stopAddress = (i < _stopAddresses.length && _stopAddresses[i].isNotEmpty)
              ? _stopAddresses[i]
              : stopText;
          stops.add(stopAddress);
        }
      }

      // Create original inputs for display names
      final originalInputs = OriginalRouteInputs(
        startLocation: startLocation,
        endLocation: endLocation,
        stops: stops,
        startLocationDisplayName: _startLocationController.text.trim(),
        endLocationDisplayName: _endLocationController.text.trim(),
        stopDisplayNames: _stopControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
        includeTraffic: _includeTraffic,
        isRoundTrip: _isRoundTrip,
      );

      // Track route calculation attempt in analytics
      await _analyticsService.trackEvent(
        'route_calculation_started',
        details: '${stops.length + 2} stops',
      );

      // Calculate optimized route
      final result = await _routeService.calculateOptimizedRoute(
        startLocation: startLocation,
        endLocation: endLocation,
        stops: stops,
        originalInputs: originalInputs,
      );

      // On SUCCESS - Increment usage and track successful calculation
      await _usageTrackingService.incrementUsage();
      
      await _analyticsService.trackRouteCalculation(
        stops: [startLocation, ...stops, endLocation],
        totalDistance: result.totalDistance,
        totalTime: result.estimatedTime,
        success: true,
      );

      // Navigate to results screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RouteResultsScreen(
              routeResult: result,
              originalInputs: originalInputs,
            ),
          ),
        );
      }

    } catch (e) {
      // Enhanced error tracking
      await _errorTrackingService.trackRouteCalculationError(
        errorMessage: e.toString(),
        startLocation: _startLocationController.text,
        endLocation: _endLocationController.text,
        stops: _stopControllers.map((c) => c.text).toList(),
        stackTrace: StackTrace.current,
      );

      await _analyticsService.trackEvent(
        'route_calculation_failed',
        details: e.toString(),
        success: false,
        errorMessage: e.toString(),
      );

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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

  void _showUsageLimitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text(
            'Daily Limit Reached',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'You\'ve reached your daily limit of ${UsageTrackingService.DAILY_LIMIT} route calculations. Your limit will reset at midnight.',
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF2E7D32)),
              ),
            ),
          ],
        );
      },
    );
  }
}