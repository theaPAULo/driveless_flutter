// lib/screens/route_input_screen.dart
//
// Main route planning interface with Google Places autocomplete
// Updated to work with MainTabView navigation (no bottom nav bar)

import 'package:flutter/material.dart';

// Import our services, models, and widgets
import '../services/route_calculator_service.dart';
import '../models/route_models.dart';
import '../utils/constants.dart';
import '../widgets/autocomplete_text_field.dart';
import '../widgets/current_location_button.dart';
import 'route_results_screen.dart';

class RouteInputScreen extends StatefulWidget {
  const RouteInputScreen({Key? key}) : super(key: key);

  @override
  State<RouteInputScreen> createState() => _RouteInputScreenState();
}

class _RouteInputScreenState extends State<RouteInputScreen> {
  // MARK: - Controllers for text fields
  final TextEditingController _startLocationController = TextEditingController();
  final TextEditingController _endLocationController = TextEditingController();
  final List<TextEditingController> _stopControllers = [TextEditingController()];

  // MARK: - State variables
  bool _isRoundTrip = false;
  bool _considerTraffic = true;
  bool _isOptimizing = false;

  // Store actual addresses for API calls (may differ from display names)
  String _startLocationAddress = '';
  String _endLocationAddress = '';
  List<String> _stopAddresses = [''];

  // MARK: - Services
  final RouteCalculatorService _routeService = RouteCalculatorService();

  @override
  void dispose() {
    // Clean up controllers
    _startLocationController.dispose();
    _endLocationController.dispose();
    for (var controller in _stopControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // MARK: - Header Section
              _buildHeaderSection(),
              
              const SizedBox(height: 24),
              
              // MARK: - Route Input Card
              _buildRouteInputCard(),
              
              const SizedBox(height: 24),
              
              // MARK: - Options Card
              _buildOptionsCard(),
              
              const SizedBox(height: 32),
              
              // MARK: - Optimize Button
              _buildOptimizeButton(),
              
              const SizedBox(height: 40), // Extra padding for tab bar
            ],
          ),
        ),
      ),
      // REMOVED: bottomNavigationBar is now handled by MainTabView
    );
  }

  // MARK: - Header Section (matching iOS exactly)
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Your Route',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Drive Less, Save Time',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            // Admin badge (placeholder for now)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '0/∞\nadmin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // MARK: - Route Input Card
  Widget _buildRouteInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Starting location field
          AutocompleteTextField(
            controller: _startLocationController,
            hint: 'Starting location',
            icon: Icons.my_location,
            iconColor: const Color(0xFF2E7D32),
            onPlaceSelected: (placeDetails) {
              setState(() {
                _startLocationAddress = placeDetails.formattedAddress;
              });
            },
            onChanged: () {
              setState(() {
                // Update button state when text changes
              });
            },
          ),
          
          // "Use current location" button for start (matches iOS)
          CurrentLocationButton(
            isVisible: _startLocationController.text.isEmpty,
            onLocationSelected: (placeDetails) {
              setState(() {
                _startLocationController.text = placeDetails.name;
                _startLocationAddress = placeDetails.formattedAddress;
              });
            },
          ),
          
          // Connector line
          _buildConnectorLine(),
          
          // Stops section
          ..._buildStopsSection(),
          
          // Connector line to destination
          _buildConnectorLine(),
          
          // Destination field
          AutocompleteTextField(
            controller: _endLocationController,
            hint: _isRoundTrip ? 'Return to start' : 'Destination',
            icon: Icons.flag,
            iconColor: const Color(0xFF2E7D32),
            enabled: !_isRoundTrip,
            onPlaceSelected: (placeDetails) {
              setState(() {
                _endLocationAddress = placeDetails.formattedAddress;
              });
            },
            onChanged: () {
              setState(() {
                // Update button state when text changes
              });
            },
          ),
          
          // "Use current location" button for destination (matches iOS)
          CurrentLocationButton(
            isVisible: _endLocationController.text.isEmpty && !_isRoundTrip,
            onLocationSelected: (placeDetails) {
              setState(() {
                _endLocationController.text = placeDetails.name;
                _endLocationAddress = placeDetails.formattedAddress;
              });
            },
          ),
        ],
      ),
    );
  }

  // MARK: - Connector Line
  Widget _buildConnectorLine() {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 20,
            color: Colors.grey[600],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // MARK: - Stops Section
  List<Widget> _buildStopsSection() {
    List<Widget> stopWidgets = [];
    
    // Add existing stops
    for (int i = 0; i < _stopControllers.length; i++) {
      stopWidgets.add(
        _buildStopField(index: i),
      );
      
      // Add connector line between stops
      if (i < _stopControllers.length - 1) {
        stopWidgets.add(_buildConnectorLine());
      }
    }
    
    // Add "Add Stop" button
    stopWidgets.add(_buildAddStopButton());
    
    return stopWidgets;
  }

  // MARK: - Individual Stop Field
  Widget _buildStopField({required int index}) {
    return Row(
      children: [
        Expanded(
          child: AutocompleteTextField(
            controller: _stopControllers[index],
            hint: 'Stop ${index + 1}',
            icon: Icons.info_outline,
            iconColor: const Color(0xFF2E7D32),
            onPlaceSelected: (placeDetails) {
              setState(() {
                // Ensure the addresses list is large enough
                while (_stopAddresses.length <= index) {
                  _stopAddresses.add('');
                }
                _stopAddresses[index] = placeDetails.formattedAddress;
              });
            },
            onChanged: () {
              setState(() {
                // Update button state when text changes
              });
            },
          ),
        ),
        
        // Remove button
        if (_stopControllers.length > 1)
          GestureDetector(
            onTap: () => _removeStop(index),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(8),
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

  // MARK: - Add Stop Button
  Widget _buildAddStopButton() {
    return GestureDetector(
      onTap: _addStop,
      child: Container(
        margin: const EdgeInsets.only(left: 44, top: 8),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF2E7D32),
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Add Stop',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Options Card
  Widget _buildOptionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Round Trip Toggle
          _buildToggleOption(
            icon: Icons.repeat,
            title: 'Round Trip',
            subtitle: 'Return to starting location',
            value: _isRoundTrip,
            onChanged: (value) {
              setState(() {
                _isRoundTrip = value;
                if (_isRoundTrip) {
                  _endLocationController.clear();
                  _endLocationAddress = '';
                }
              });
            },
            activeColor: const Color(0xFF2E7D32),
          ),
          
          const SizedBox(height: 16),
          
          // Traffic Toggle
          _buildToggleOption(
            icon: Icons.traffic,
            title: 'Consider Traffic',
            subtitle: 'Include current traffic conditions',
            value: _considerTraffic,
            onChanged: (value) {
              setState(() {
                _considerTraffic = value;
              });
            },
            activeColor: const Color(0xFF8B4513),
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
                             (_endLocationController.text.isNotEmpty || _isRoundTrip);
    
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
                    canOptimize ? 'Optimize Route' : 'Enter start and destination',
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

  Future<void> _optimizeRoute() async {
    if (_isOptimizing) return;
    
    setState(() {
      _isOptimizing = true;
    });

    try {
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
          // Use formatted address if available, otherwise use user input
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
      );

      // Calculate optimized route
      final result = await _routeService.calculateOptimizedRoute(
        startLocation: startLocation,
        endLocation: endLocation,
        stops: stops,
        originalInputs: originalInputs,
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
}