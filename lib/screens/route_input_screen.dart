// lib/screens/route_input_screen.dart
//
// ENHANCED: Route input screen with usage tracking integration
// Preserves ALL existing functionality: autocomplete, reverse geocoding, theme switching, etc.
// Only adds minimal usage tracking enhancements

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Added for haptic feedback
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart'; // ✅ Added for usage tracking

import '../models/route_models.dart';
import '../services/route_calculator_service.dart';
import '../services/usage_tracking_service.dart'; // ✅ Added
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
  // Controllers for text inputs (preserved)
  final TextEditingController _startLocationController = TextEditingController();
  final TextEditingController _endLocationController = TextEditingController();
  final List<TextEditingController> _stopControllers = [];
  
  // Services (preserved with one addition)
  final RouteCalculatorService _routeService = RouteCalculatorService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final ErrorTrackingService _errorTrackingService = ErrorTrackingService();
  final SavedAddressService _savedAddressService = SavedAddressService();
  
  // State variables (all preserved)
  bool _isOptimizing = false;
  bool _isRoundTrip = false;
  bool _includeTraffic = true;
  Map<String, bool> _loadingStates = {};
  List<SavedAddress> _savedAddresses = [];
  
  // Address storage for formatted addresses from autocomplete (preserved)
  String _startLocationAddress = '';
  String _endLocationAddress = '';
  String _tempEndLocation = '';
  String _tempEndAddress = '';
  final List<String> _stopAddresses = [];

  // Helper to get loading state for a specific field (preserved)
  bool _isLoadingLocation(String fieldId) {
    return _loadingStates[fieldId] ?? false;
  }

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
    // ✅ Initialize usage tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UsageTrackingService>().initialize();
      }
    });
  }

  /// Load saved addresses using existing service method (preserved)
  Future<void> _loadSavedAddresses() async {
    try {
      await _savedAddressService.initialize();
      setState(() {
        _savedAddresses = _savedAddressService.savedAddresses;
      });
    } catch (e) {
      print('Error loading saved addresses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with usage indicator (enhanced existing header)
            _buildHeaderWithUsageIndicator(),
            
            // Main content (all existing functionality preserved)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    
                    // Route Input Section (completely preserved)
                    _buildRouteInputSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Settings Section (completely preserved)
                    _buildSettingsSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Enhanced Optimize Button with usage tracking
                    _buildEnhancedOptimizeButton(),
                    
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

  // ✅ ENHANCED: Header with usage indicator (preserves existing design)
  Widget _buildHeaderWithUsageIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        children: [
          // Existing header content (preserved)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Your Route',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Drive Less, Save Time',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          // ✅ Enhanced usage indicator (replaces basic "0/∞ admin")
          _buildUsageIndicator(),
        ],
      ),
    );
  }

  // ✅ NEW: Enhanced usage indicator
  Widget _buildUsageIndicator() {
    return Consumer<UsageTrackingService>(
      builder: (context, usageService, child) {
        final todayUsage = usageService.todayUsage;
        final isAdmin = usageService.remainingRoutes == 999;
        final usagePercentage = usageService.usagePercentage;
        
        // Color based on usage level
        Color indicatorColor;
        String usageText;
        
        if (isAdmin) {
          indicatorColor = Colors.purple[400]!;
          usageText = '∞';
        } else if (usagePercentage >= 1.0) {
          indicatorColor = Colors.red[400]!;
          usageText = '$todayUsage/10';
        } else if (usagePercentage >= 0.8) {
          indicatorColor = Colors.orange[400]!;
          usageText = '$todayUsage/10';
        } else {
          indicatorColor = const Color(0xFF34C759);
          usageText = '$todayUsage/10';
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: indicatorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: indicatorColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                usageText,
                style: TextStyle(
                  color: indicatorColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isAdmin ? 'admin' : 'searches',
                style: TextStyle(
                  color: indicatorColor.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // MARK: - Route Input Section (completely preserved)
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
          // Start location with saved addresses (preserved)
          _buildLocationInput(
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
          
          // Stops (preserved)
          for (int i = 0; i < _stopControllers.length; i++)
            Column(
              children: [
                const SizedBox(height: 20),
                _buildLocationInput(
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
          
          // Add Stop button (preserved)
          _buildAddStopButton(),
          
          const SizedBox(height: 20),
          
          // End location (preserved)
          _buildLocationInput(
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

  // ✅ ENHANCED: Optimize button with usage tracking
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
            ? Row(
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
                  const SizedBox(width: 12),
                  const Text(
                    'Optimizing Route...',
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
                    Icons.map_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
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

  // ✅ ENHANCED: Route calculation with usage tracking
  Future<void> _handleEnhancedOptimizeRoute() async {
    // Haptic feedback for button press
    HapticFeedback.lightImpact();
    
    final usageService = context.read<UsageTrackingService>();
    
    // Check usage limits
    final canCalculate = await usageService.canPerformRouteCalculation();
    if (!canCalculate) {
      final shouldProceed = await usageService.showUsageWarningIfNeeded(context);
      if (!shouldProceed) return;
    } else {
      final shouldProceed = await usageService.showUsageWarningIfNeeded(context);
      if (!shouldProceed) return;
    }
    
    // Proceed with existing route calculation (preserved)
    await _optimizeRoute();
  }

  // MARK: - Preserved Methods (all existing functionality)
  
  Future<void> _optimizeRoute() async {
    if (_isOptimizing) return;

    setState(() {
      _isOptimizing = true;
    });

    try {
      // Collect stop addresses (preserved logic)
      List<String> stops = [];
      for (int i = 0; i < _stopControllers.length; i++) {
        if (i < _stopAddresses.length && _stopAddresses[i].isNotEmpty) {
          stops.add(_stopAddresses[i]);
        }
      }

      List<String> stopDisplayNames = [];
      for (int i = 0; i < _stopControllers.length; i++) {
        stopDisplayNames.add(_stopControllers[i].text);
      }

      // Create original inputs (preserved)
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

      // Call route optimization service (preserved)
      final routeResult = await _routeService.calculateOptimizedRoute(
        startLocation: originalInputs.startLocation,
        endLocation: originalInputs.endLocation,
        stops: stops,
        originalInputs: originalInputs,
      );

      // ✅ Increment usage counter
      await context.read<UsageTrackingService>().incrementUsage();

      // Navigate to results (preserved)
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

  // All other methods preserved exactly as they were...
  // (buildLocationInput, buildSettingsSection, etc.)
  
  Widget _buildLocationInput({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saved addresses chips (preserved)
        if (isStart && _savedAddresses.isNotEmpty) ...[
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _savedAddresses.length,
              itemBuilder: (context, index) {
                final address = _savedAddresses[index];
                final addressType = address.addressType;
                
                Color addressColor;
                IconData addressIcon;
                
                switch (addressType) {
                  case SavedAddressType.home:
                    addressColor = const Color(0xFF34C759);
                    addressIcon = Icons.home;
                    break;
                  case SavedAddressType.work:
                    addressColor = Colors.blue;
                    addressIcon = Icons.work;
                    break;
                  case SavedAddressType.custom:
                  default:
                    addressColor = Colors.orange;
                    addressIcon = Icons.place;
                    break;
                }
                
                return Padding(
                  padding: EdgeInsets.only(right: index < _savedAddresses.length - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _selectSavedAddress(address, isStart, stopIndex: stopIndex);
                    },
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
          const SizedBox(height: 12),
        ],
        
        // Location input field (preserved)
        Row(
          children: [
            GestureDetector(
              onTap: !isDisabled ? () {
                HapticFeedback.lightImpact();
                _useCurrentLocation(isStart, stopIndex: stopIndex);
              } : null,
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
                  icon,
                  color: !isDisabled ? iconColor : Colors.grey,
                  size: 18,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: _isLoadingLocation(fieldId)
                  ? Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF34C759)),
                          ),
                        ),
                      ),
                    )
                  : AutocompleteTextField(
                      controller: controller,
                      hintText: hintText,
                      enabled: !isDisabled,
                      onPlaceSelected: (place) {
                        onAddressSelected(place.formattedAddress);
                      },
                      onChanged: (value) {
                        // Handle text changes if needed
                      },
                    ),
            ),
            
            if (onRemove != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onRemove();
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildSettingCard(
          icon: Icons.sync_alt,
          title: 'Round Trip',
          subtitle: 'Return to starting location',
          value: _isRoundTrip,
          onChanged: (value) {
            HapticFeedback.selectionClick();
            setState(() {
              _isRoundTrip = value;
              if (_isRoundTrip && _endLocationController.text.isNotEmpty) {
                _tempEndLocation = _endLocationController.text;
                _tempEndAddress = _endLocationAddress;
                _endLocationController.text = _startLocationController.text;
                _endLocationAddress = _startLocationAddress;
              } else if (!_isRoundTrip && _tempEndLocation.isNotEmpty) {
                _endLocationController.text = _tempEndLocation;
                _endLocationAddress = _tempEndAddress;
                _tempEndLocation = '';
                _tempEndAddress = '';
              }
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        _buildSettingCard(
          icon: Icons.traffic,
          title: 'Consider Traffic',
          subtitle: 'Include current traffic conditions',
          value: _includeTraffic,
          onChanged: (value) {
            HapticFeedback.selectionClick();
            setState(() {
              _includeTraffic = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? 
                     (isDark ? const Color(0xFF1C1C1E) : Colors.white);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF34C759),
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF34C759),
            activeTrackColor: const Color(0xFF34C759).withOpacity(0.3),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[700],
          ),
        ],
      ),
    );
  }

  Widget _buildAddStopButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _addStop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF34C759),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Add Stop',
              style: TextStyle(
                color: const Color(0xFF34C759),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods (all preserved)
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

  void _selectSavedAddress(SavedAddress address, bool isStart, {int? stopIndex}) {
    if (isStart) {
      setState(() {
        _startLocationController.text = address.displayName;
        _startLocationAddress = address.fullAddress;
        if (_isRoundTrip) {
          _endLocationController.text = _startLocationController.text;
          _endLocationAddress = _startLocationAddress;
        }
      });
    } else if (stopIndex != null) {
      setState(() {
        _stopControllers[stopIndex].text = address.displayName;
        while (_stopAddresses.length <= stopIndex) {
          _stopAddresses.add('');
        }
        _stopAddresses[stopIndex] = address.fullAddress;
      });
    }
  }

  Future<void> _useCurrentLocation(bool isStart, {int? stopIndex}) async {
    final fieldId = isStart ? 'start' : (stopIndex != null ? 'stop_$stopIndex' : 'end');
    
    setState(() {
      _loadingStates[fieldId] = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final address = await _reverseGeocode(position.latitude, position.longitude);
      
      if (isStart) {
        setState(() {
          _startLocationController.text = 'Current Location';
          _startLocationAddress = address;
          if (_isRoundTrip) {
            _endLocationController.text = _startLocationController.text;
            _endLocationAddress = _startLocationAddress;
          }
        });
      } else if (stopIndex != null) {
        setState(() {
          _stopControllers[stopIndex].text = 'Current Location';
          while (_stopAddresses.length <= stopIndex) {
            _stopAddresses.add('');
          }
          _stopAddresses[stopIndex] = address;
        });
      } else {
        setState(() {
          _endLocationController.text = 'Current Location';
          _endLocationAddress = address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get current location: $e'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    } finally {
      setState(() {
        _loadingStates[fieldId] = false;
      });
    }
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${EnvironmentConfig.googleAPIKey}';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      print('❌ Reverse geocoding error: $e');
    }
    
    return '$lat, $lng';
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
}