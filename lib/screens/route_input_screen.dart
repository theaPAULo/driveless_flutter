// lib/screens/route_input_screen.dart
//
// FIXED: Current location button positioning
// ✅ Fixed: Current location button moved to left of text input
// ✅ Fixed: Saved address buttons stay above input field

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../models/route_models.dart';
import '../services/route_calculator_service.dart';
import '../services/usage_tracking_service.dart';
import '../services/analytics_service.dart';
import '../services/error_tracking_service.dart';
import '../widgets/autocomplete_text_field.dart';
import '../services/saved_address_service.dart';
import '../models/saved_address_model.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart';
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
  final AnalyticsService _analyticsService = AnalyticsService();
  final ErrorTrackingService _errorTrackingService = ErrorTrackingService();
  final SavedAddressService _savedAddressService = SavedAddressService();
  
  // State variables
  bool _isOptimizing = false;
  bool _isRoundTrip = false;
  bool _includeTraffic = true;
  Map<String, bool> _loadingStates = {};
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

    Future<void> _loadDefaultSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _isRoundTrip = prefs.getBool('default_round_trip') ?? false;
        _includeTraffic = prefs.getBool('default_traffic_consideration') ?? true;
      });
      
      print('🔄 Settings reloaded - Round Trip: $_isRoundTrip, Traffic: $_includeTraffic');
    } catch (e) {
      print('❌ Error loading settings: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
    _loadDefaultSettings(); // Just load once on startup

    
    // Initialize usage tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UsageTrackingService>().initialize();
      }
    });
  }

  @override
  void dispose() {
    _startLocationController.dispose();
    _endLocationController.dispose();
    for (var controller in _stopControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSavedAddresses() async {
    try {
      await _savedAddressService.initialize();
      if (mounted) {
        setState(() {
          _savedAddresses = _savedAddressService.savedAddresses;
        });
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading saved addresses: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ FIXED: Usage indicator in normal flow (scrolls with content)
                Row(
                  children: [
                    Expanded(child: _buildHeader()),
                    _buildCompactUsageIndicator(),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Route Input Section
                _buildRouteInputSection(),
                
                const SizedBox(height: 24),
                
                // Settings Section
                _buildSettingsSection(),
                
                const SizedBox(height: 32),
                
                // Optimize Button
                _buildEnhancedOptimizeButton(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - Header Section
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Your Route',
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineLarge?.color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Drive Less, Save Time',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // ✅ FIXED: Compact usage indicator (now scrolls with content)
  Widget _buildCompactUsageIndicator() {
    return Consumer<UsageTrackingService>(
      builder: (context, usageService, child) {
        final todayUsage = usageService.todayUsage;
        final isAdmin = usageService.remainingRoutes == 999; // Admin check
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAdmin 
                  ? Colors.purple.withOpacity(0.3)
                  : (todayUsage >= 10 
                      ? Colors.red.withOpacity(0.3)
                      : (todayUsage >= 8 
                          ? Colors.orange.withOpacity(0.3) 
                          : Colors.green.withOpacity(0.3))),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                // Show ∞ for admin users
                isAdmin ? '$todayUsage/∞' : '$todayUsage/10',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                isAdmin ? 'admin' : 'searches',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
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
        color: cardColor,
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
          // Start location with saved addresses ABOVE input
          _buildLocationInputWithSavedAddresses(
            controller: _startLocationController,
            icon: Icons.trip_origin,
            hintText: 'Enter start location',
            fieldId: 'start',
            isStart: true,
            iconColor: const Color(0xFF34C759),
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
          
          // Stops with saved addresses
          for (int i = 0; i < _stopControllers.length; i++)
            Column(
              children: [
                const SizedBox(height: 20),
                _buildLocationInputWithSavedAddresses(
                  controller: _stopControllers[i],
                  icon: Icons.place,
                  hintText: 'Stop ${i + 1}',
                  fieldId: 'stop_$i',
                  stopIndex: i,
                  iconColor: Colors.orange,
                  isDisabled: false,
                  onAddressSelected: (address) {
                    setState(() {
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
          
          const SizedBox(height: 20),
          
          // Add Stop button
          _buildAddStopButton(),
          
          const SizedBox(height: 20),
          
          // End location with saved addresses ABOVE input
          _buildLocationInputWithSavedAddresses(
            controller: _endLocationController,
            icon: Icons.flag,
            hintText: _isRoundTrip ? 'Return to starting location' : 'Enter destination',
            fieldId: 'end',
            isStart: false,
            iconColor: _isRoundTrip ? Colors.grey : Colors.red,
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

  // MARK: - Add Stop Button
  Widget _buildAddStopButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _addStop();
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF34C759).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF34C759).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Color(0xFF34C759),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
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

  // MARK: - Settings Section
  Widget _buildSettingsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? 
                     (isDark ? const Color(0xFF1C1C1E) : Colors.white);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
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
          // Round Trip Toggle
          _buildToggleItem(
            icon: Icons.sync,
            iconColor: const Color(0xFF34C759),
            title: 'Round Trip',
            subtitle: 'Return to starting location',
            value: _isRoundTrip,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() {
                _isRoundTrip = value;
                if (_isRoundTrip) {
                  _tempEndLocation = _endLocationController.text;
                  _tempEndAddress = _endLocationAddress;
                  _endLocationController.text = _startLocationController.text;
                  _endLocationAddress = _startLocationAddress;
                } else {
                  _endLocationController.text = _tempEndLocation;
                  _endLocationAddress = _tempEndAddress;
                }
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Traffic Toggle
          _buildToggleItem(
            icon: Icons.traffic,
            iconColor: Colors.orange,
            title: 'Consider Traffic',
            subtitle: 'Include current traffic conditions',
            value: _includeTraffic,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() {
                _includeTraffic = value;
              });
            },
          ),
        ],
      ),
    );
  }

// lib/screens/route_input_screen.dart - CORRECTED METHODS
//
// FIXED: Corrected AutocompleteTextField parameters
// Use these methods to replace the existing ones in your route_input_screen.dart

Widget _buildLocationInputWithSavedAddresses({
  required TextEditingController controller,
  required IconData icon,
  required String hintText,
  required String fieldId,
  bool isStart = false,
  int? stopIndex,
  required Color iconColor,
  required bool isDisabled,
  required Function(String) onAddressSelected,
  VoidCallback? onRemove,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ✅ FIXED: Show ALL saved address types (Home, Work, AND Custom addresses)
      if (_savedAddresses.isNotEmpty && !isDisabled) ...[
        // Build a scrollable row of saved address buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Home button (if exists)
              if (_savedAddresses.any((addr) => addr.addressType == SavedAddressType.home))
                _buildSavedAddressButton(
                  SavedAddressType.home,
                  Icons.home,
                  const Color(0xFF34C759),
                  controller,
                  onAddressSelected,
                ),
              
              // Work button (if exists)
              if (_savedAddresses.any((addr) => addr.addressType == SavedAddressType.work)) ...[
                const SizedBox(width: 8),
                _buildSavedAddressButton(
                  SavedAddressType.work,
                  Icons.business,
                  const Color(0xFF1976D2),
                  controller,
                  onAddressSelected,
                ),
              ],
              
              // ✅ FIXED: Custom address buttons (show up to 3 custom addresses)
              ...(_savedAddresses
                  .where((addr) => addr.addressType == SavedAddressType.custom)
                  .take(3)
                  .map((customAddr) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildCustomAddressButton(
                    customAddr,
                    controller,
                    onAddressSelected,
                  ),
                );
              }).toList()),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
      ],
      
      // Input field row with current location button
      Row(
        children: [
          // Current location button (for start, stops, AND destination)
          if (!isDisabled) ...[
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _useCurrentLocation(isStart, stopIndex: stopIndex);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.my_location,
                  color: iconColor,
                  size: 18,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
          ],
          
          // Text input field
          Expanded(
            child: _isLoadingLocation(fieldId)
                ? Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFF2C2C2E)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF34C759)),
                      ),
                    ),
                  )
                : AutocompleteTextField(
                    controller: controller,
                    hint: hintText, // ✅ FIXED: Use 'hint' instead of 'hintText'
                    icon: icon,
                    iconColor: iconColor,
                    enabled: !isDisabled, // ✅ FIXED: Use 'enabled' instead of 'isDisabled'
                    onPlaceSelected: (place) {
                      onAddressSelected(place.formattedAddress);
                    },
                    onChanged: () {
                      // Handle text changes if needed
                    },
                  ),
          ),
          
          // Remove stop button (only for stops)
          if (onRemove != null) ...[
            const SizedBox(width: 8),
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
                  Icons.remove,
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

// ✅ NEW: Helper method for saved address buttons (Home/Work)
Widget _buildSavedAddressButton(
  SavedAddressType type,
  IconData iconData,
  Color color,
  TextEditingController controller,
  Function(String) onAddressSelected,
) {
  return GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      _selectSavedAddress(type, controller, onAddressSelected);
    },
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 18,
      ),
    ),
  );
}

// ✅ NEW: Helper method for custom address buttons
Widget _buildCustomAddressButton(
  SavedAddress customAddress,
  TextEditingController controller,
  Function(String) onAddressSelected,
) {
  return GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      // Use the custom address directly
      controller.text = customAddress.fullAddress;
      onAddressSelected(customAddress.fullAddress);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF7B1FA2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF7B1FA2).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.place,
            color: Color(0xFF7B1FA2),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            customAddress.label.length > 8 
                ? '${customAddress.label.substring(0, 8)}...'
                : customAddress.label,
            style: const TextStyle(
              color: Color(0xFF7B1FA2),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildToggleItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
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
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: iconColor,
          activeTrackColor: iconColor.withOpacity(0.3),
        ),
      ],
    );
  }

  // MARK: - Enhanced Optimize Button
  Widget _buildEnhancedOptimizeButton() {
    final hasValidInputs = _startLocationController.text.isNotEmpty && 
                          _endLocationController.text.isNotEmpty;
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: hasValidInputs && !_isOptimizing
          ? const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
          : LinearGradient(
              colors: [Colors.grey[600]!, Colors.grey[500]!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
        boxShadow: hasValidInputs && !_isOptimizing ? [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ] : [],
      ),
      child: ElevatedButton(
        onPressed: hasValidInputs && !_isOptimizing ? _handleEnhancedOptimizeRoute : null,
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
                    'Optimizing Route...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Optimize Route',
                    style: TextStyle(
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

  void _selectSavedAddress(SavedAddressType type, TextEditingController controller, Function(String) onAddressSelected) {
    final address = _savedAddresses.firstWhere(
      (addr) => addr.addressType == type,
      orElse: () => SavedAddress(
        id: '',
        label: '',
        fullAddress: '',
        displayName: '',
        addressType: type,
        createdDate: DateTime.now(),
      ),
    );
    
    if (address.fullAddress.isNotEmpty) {
      // ✅ FIXED: Use full address instead of display name to prevent autocomplete suggestions
      controller.text = address.fullAddress;
      onAddressSelected(address.fullAddress);
    }
  }

  Future<void> _useCurrentLocation(bool isStart, {int? stopIndex}) async {
    final fieldId = isStart ? 'start' : (stopIndex != null ? 'stop_$stopIndex' : 'end');
    
    setState(() {
      _loadingStates[fieldId] = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      Position position = await Geolocator.getCurrentPosition();
      
      // Reverse geocode
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${EnvironmentConfig.apiKey}';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'] as String;
          
          if (mounted) {
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
            
            // Success haptic feedback
            HapticFeedback.lightImpact();
          }
        } else {
          throw 'Unable to get address for current location';
        }
      } else {
        throw 'Failed to get current location address';
      }
    } catch (e) {
      if (mounted) {
        // Error haptic feedback
        HapticFeedback.heavyImpact();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting current location: $e'),
            backgroundColor: Colors.red[400],
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

  Future<void> _handleEnhancedOptimizeRoute() async {
    // Check usage limits first
    final usageService = context.read<UsageTrackingService>();
    if (!await usageService.canPerformRouteCalculation()) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily usage limit reached (10 searches per day). Please try again tomorrow.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    // Validation
    if (_startLocationController.text.isEmpty || _endLocationController.text.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both start and end locations'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isOptimizing = true;
    });

    // Success haptic feedback
    HapticFeedback.mediumImpact();

    try {
      // Prepare data
      final List<String> stops = _stopControllers
          .asMap()
          .entries
          .where((entry) => entry.value.text.isNotEmpty)
          .map((entry) => _stopAddresses.length > entry.key ? _stopAddresses[entry.key] : entry.value.text)
          .toList();

      final List<String> stopDisplayNames = _stopControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) => controller.text)
          .toList();

      // Create original inputs
      final originalInputs = OriginalRouteInputs(
        startLocation: _startLocationAddress.isNotEmpty ? _startLocationAddress : _startLocationController.text,
        endLocation: _isRoundTrip ? _startLocationAddress : _endLocationAddress,
        stops: stops,
        startLocationDisplayName: _startLocationController.text,
        endLocationDisplayName: _isRoundTrip ? _startLocationController.text : _endLocationController.text,
        stopDisplayNames: stopDisplayNames,
        isRoundTrip: _isRoundTrip,
        includeTraffic: _includeTraffic,
      );

      // Call route optimization service
      final routeResult = await _routeService.calculateOptimizedRoute(
        startLocation: originalInputs.startLocation,
        endLocation: originalInputs.endLocation,
        stops: stops,
        originalInputs: originalInputs,
      );

      // Increment usage counter
      await usageService.incrementUsage();

      // Navigate to results
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
      // Error haptic feedback
      HapticFeedback.heavyImpact();
      
      print('❌ Route optimization failed: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to optimize route: $e'),
            backgroundColor: Colors.red[400],
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