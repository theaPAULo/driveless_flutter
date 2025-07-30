// lib/screens/route_results_screen.dart
//
// Route results display screen - EXACT iOS App Design Match
// Shows optimized route with Summary card, Route Map, and Your Path sections

import 'package:flutter/material.dart';

import '../models/route_models.dart';
import '../utils/constants.dart';

class RouteResultsScreen extends StatelessWidget {
  final OptimizedRouteResult routeResult;
  final OriginalRouteInputs originalInputs;

  const RouteResultsScreen({
    Key? key,
    required this.routeResult,
    required this.originalInputs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Your Route',  // Changed from "Route Results" to match iOS
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,  // Large iOS title style
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,  // Left-aligned like iOS
      ),
      body: Column(
        children: [
          // MARK: - Main Content (scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MARK: - Summary Card (iOS Style)
                  _buildSummaryCard(),
                  
                  const SizedBox(height: 24),
                  
                  // MARK: - Route Map Section
                  _buildRouteMapSection(),
                  
                  const SizedBox(height: 24),
                  
                  // MARK: - Your Path Section
                  _buildYourPathSection(),
                  
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
          
          // MARK: - Bottom Action Buttons (Fixed at bottom)
          _buildBottomActionButtons(context),
        ],
      ),
    );
  }

  // MARK: - Summary Card (White card matching iOS exactly)
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,  // White background like iOS
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary header
          const Text(
            'Summary',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Three-column metrics layout (exactly like iOS)
          Row(
            children: [
              // Distance column
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.straighten,
                  iconColor: const Color(0xFF34C759), // iOS green
                  value: routeResult.totalDistance,
                  label: 'Distance',
                ),
              ),
              
              // Divider line
              Container(
                width: 1,
                height: 60,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              
              // Time column
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.access_time,
                  iconColor: const Color(0xFFFF9500), // iOS orange
                  value: routeResult.estimatedTime,
                  label: 'Time',
                ),
              ),
              
              // Divider line
              Container(
                width: 1,
                height: 60,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              
              // Stops column
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.location_on,
                  iconColor: const Color(0xFF999999), // iOS gray
                  value: '${routeResult.optimizedStops.length}',
                  label: 'Stops',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Summary Metric Item (matching iOS layout)
  Widget _buildSummaryMetric({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        // Icon in colored circle
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Value (large number)
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Label
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // MARK: - Route Map Section
  Widget _buildRouteMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        const Text(
          'Route Map',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Map container (placeholder for now - will add Google Maps later)
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[800]!,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Map placeholder background
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2C2C2E),
                      const Color(0xFF1C1C1E),
                    ],
                  ),
                ),
              ),
              
              // Google Maps placeholder text
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      color: Colors.grey,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Google Maps Integration',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '(Coming in next update)',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Traffic button overlay (top right)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Traffic',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: - Your Path Section (route stops list)
  Widget _buildYourPathSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with route icon
        Row(
          children: [
            Icon(
              Icons.route,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Your Path',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Route stops list
        ...routeResult.optimizedStops.asMap().entries.map((entry) {
          final index = entry.key;
          final stop = entry.value;
          final isFirst = index == 0;
          final isLast = index == routeResult.optimizedStops.length - 1;
          
          return _buildPathStopItem(
            stop: stop,
            index: index,
            isFirst: isFirst,
            isLast: isLast,
          );
        }).toList(),
      ],
    );
  }

  // MARK: - Path Stop Item (matching iOS design exactly)
  Widget _buildPathStopItem({
    required RouteStop stop,
    required int index,
    required bool isFirst,
    required bool isLast,
  }) {
    // Determine button color and text based on position
    Color buttonColor;
    String buttonText;
    
    if (isFirst) {
      buttonColor = const Color(0xFF34C759); // iOS green
      buttonText = 'START';
    } else if (isLast) {
      buttonColor = const Color(0xFFFF3B30); // iOS red
      buttonText = 'END';
    } else {
      buttonColor = const Color(0xFF007AFF); // iOS blue
      buttonText = 'STOP';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Numbered circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Stop details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business/location name
                Text(
                  stop.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Address
                Text(
                  stop.address,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Distance and time to next stop (if not last)
                if (!isLast && index < routeResult.legs.length) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.straighten,
                        color: Colors.grey[500],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        routeResult.legs[index].distance.text,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        color: Colors.grey[500],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        routeResult.legs[index].duration.text,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Action button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Bottom Action Buttons (matching iOS exactly)
  Widget _buildBottomActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: Colors.grey[800]!,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Save Route button (outlined style)
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement save route functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Save Route functionality coming soon!'),
                        backgroundColor: Color(0xFF34C759),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Save Route',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Google Maps button (filled style)
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759), // iOS green
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: () {
                    // TODO: Open route in Google Maps
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening in Google Maps...'),
                        backgroundColor: Color(0xFF34C759),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.map,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Google Maps',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}