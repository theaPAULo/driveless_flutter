// lib/test_route_api.dart
//
// TEMPORARY TEST FILE - DELETE AFTER TESTING
// This file tests the Google Directions API integration
// Run this to verify your API key and service work correctly

import 'package:flutter/material.dart';
import 'services/route_calculator_service.dart';
import 'models/route_models.dart';

/// Temporary test widget to verify API integration
class TestRouteApi extends StatefulWidget {
  const TestRouteApi({Key? key}) : super(key: key);

  @override
  State<TestRouteApi> createState() => _TestRouteApiState();
}

class _TestRouteApiState extends State<TestRouteApi> {
  final RouteCalculatorService _routeService = RouteCalculatorService();
  String _status = 'Ready to test API';
  bool _isLoading = false;
  OptimizedRouteResult? _lastResult;

  /// Test the API with sample addresses
  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing API...';
      _lastResult = null;
    });

    try {
      // Sample test data - you can modify these addresses
      final originalInputs = OriginalRouteInputs(
        startLocation: 'Times Square, New York, NY',
        endLocation: 'Central Park, New York, NY', 
        stops: ['Empire State Building, New York, NY'],
        startLocationDisplayName: 'Times Square',
        endLocationDisplayName: 'Central Park',
        stopDisplayNames: ['Empire State Building'],
      );

      // Calculate the route
      final result = await _routeService.calculateOptimizedRoute(
        startLocation: originalInputs.startLocation,
        endLocation: originalInputs.endLocation,
        stops: originalInputs.stops,
        originalInputs: originalInputs,
      );

      setState(() {
        _status = '✅ API Test Successful!';
        _lastResult = result;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _status = '❌ API Test Failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route API Test'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Status:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test button
            ElevatedButton(
              onPressed: _isLoading ? null : _testApi,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Testing...'),
                      ],
                    )
                  : const Text('Test Route API'),
            ),
            
            const SizedBox(height: 16),
            
            // Results display
            if (_lastResult != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Route Results:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Total distance and time
                          _buildResultRow('Total Distance:', _lastResult!.totalDistance),
                          _buildResultRow('Estimated Time:', _lastResult!.estimatedTime),
                          _buildResultRow('Number of Stops:', '${_lastResult!.optimizedStops.length}'),
                          
                          const SizedBox(height: 16),
                          
                          // Route stops
                          Text(
                            'Route Stops:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          ...(_lastResult!.optimizedStops.asMap().entries.map((entry) {
                            final index = entry.key;
                            final stop = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text('${index + 1}. ${stop.displayName}'),
                            );
                          })),
                          
                          const SizedBox(height: 16),
                          
                          // Raw data (for debugging)
                          ExpansionTile(
                            title: const Text('Raw API Data'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _lastResult!.toJson().toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('1. Make sure you\'ve added your Google API key to constants.dart'),
                    Text('2. Ensure Directions API is enabled in Google Cloud Console'),
                    Text('3. Tap "Test Route API" to verify integration'),
                    Text('4. Check console output for detailed logs'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}