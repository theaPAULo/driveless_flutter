// lib/screens/route_input_screen.dart
//
// Main route planning interface with Google Places autocomplete
// Updated to use smart address input fields

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
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      
      // MARK: - Bottom Navigation Bar (matching iOS app)
      bottomNavigationBar: Container(
        height: 90,
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          border: Border(
            top: BorderSide(color: Color(0xFF38383A), width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Search tab (active)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  color: const Color(0xFF2E7D32),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'Search',
                  style: TextStyle(
                    color: const Color(0xFF2E7D32),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            // Profile tab (inactive)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  color: Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Header Section
  Widget _buildHeaderSection() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan Your Route',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Drive Less, Save Time',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        
        const Spacer(),
        
        // Usage indicator (placeholder for now)
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '5/25',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'today',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Start location field with autocomplete
          AutocompleteTextField(
            controller: _startLocationController,
            hint: 'Starting location',
            icon: Icons.radio_button_checked,
            iconColor: const Color(0xFF2E7D32),
            onPlaceSelected: (placeDetails) {
              setState(() {
                _startLocationAddress = placeDetails.formattedAddress;
                // Update end location if round trip is enabled
                if (_isRoundTrip) {
                  _endLocationController.text = placeDetails.name;
                  _endLocationAddress = placeDetails.formattedAddress;
                }
              });
            },
            onChanged: () {
              setState(() {
                // Update button state when text changes
              });
            },
          ),
          
          // "Use current location" button for start location (matches iOS)
          CurrentLocationButton(
            isVisible: _startLocationController.text.isEmpty,
            onLocationSelected: (placeDetails) {
              setState(() {
                _startLocationController.text = placeDetails.name;
                _startLocationAddress = placeDetails.formattedAddress;
                // Update end location if round trip is enabled
                if (_isRoundTrip) {
                  _endLocationController.text = placeDetails.name;
                  _endLocationAddress = placeDetails.formattedAddress;
                }
              });
            },
          ),
          
          // Connector line
          _buildConnectorLine(),
          
          // Stops section
          ..._buildStopsSection(),
          
          // Another connector line (if there are stops)
          if (_stopControllers.isNotEmpty) _buildConnectorLine(),
          
          // Destination field with autocomplete
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

  // MARK: - Individual Stop Field with Autocomplete
  Widget _buildStopField({required int index}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Stop autocomplete field
              Expanded(
                child: AutocompleteTextField(
                  controller: _stopControllers[index],
                  hint: 'Stop ${index + 1}',
                  icon: Icons.location_on,
                  iconColor: Colors.orange,
                  onPlaceSelected: (placeDetails) {
                    setState(() {
                      // Ensure the addresses list is big enough
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
              
              const SizedBox(width: 8),
              
              // Remove stop button
              GestureDetector(
                onTap: () => _removeStop(index),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // "Use current location" button for this stop (matches iOS)
        CurrentLocationButton(
          isVisible: _stopControllers[index].text.isEmpty,
          onLocationSelected: (placeDetails) {
            setState(() {
              _stopControllers[index].text = placeDetails.name;
              // Ensure the addresses list is big enough
              while (_stopAddresses.length <= index) {
                _stopAddresses.add('');
              }
              _stopAddresses[index] = placeDetails.formattedAddress;
            });
          },
        ),
      ],
    );
  }

  // MARK: - Add Stop Button
  Widget _buildAddStopButton() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: GestureDetector(
        onTap: _addStop,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF2E7D32),
                size: 16,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Text(
              'Add Stop',
              style: TextStyle(
                color: const Color(0xFF2E7D32),
                fontSize: 16,
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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Round Trip toggle
          _buildToggleOption(
            icon: Icons.sync,
            title: 'Round Trip',
            subtitle: 'Return to starting location',
            value: _isRoundTrip,
            onChanged: (value) {
              setState(() {
                _isRoundTrip = value;
                if (_isRoundTrip && _startLocationController.text.isNotEmpty) {
                  _endLocationController.text = _startLocationController.text;
                  _endLocationAddress = _startLocationAddress;
                } else {
                  _endLocationController.clear();
                  _endLocationAddress = '';
                }
              });
            },
            activeColor: const Color(0xFF2E7D32),
          ),
          
          const SizedBox(height: 20),
          
          // Consider Traffic toggle
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
            activeColor: const Color(0xFF8B4513), // Brown color from iOS app
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

      // Navigate to results screen instead of showing snackbar
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