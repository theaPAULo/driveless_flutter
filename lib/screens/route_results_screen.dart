// lib/screens/route_results_screen.dart
//
// Route results display screen - shows optimized route information
// Matches iOS app design and functionality

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
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Route Results',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Share or export button (placeholder for now)
          IconButton(
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Add share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon!'),
                  backgroundColor: Color(0xFF2E7D32),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MARK: - Route Summary Card
            _buildRouteSummaryCard(),
            
            const SizedBox(height: 20),
            
            // MARK: - Route Details Card
            _buildRouteDetailsCard(),
            
            const SizedBox(height: 20),
            
            // MARK: - Action Buttons
            _buildActionButtons(context),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // MARK: - Route Summary Card
  Widget _buildRouteSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          // Success icon and title
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Route Optimized!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${routeResult.optimizedStops.length} stops organized',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Distance and Time metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.straighten,
                  iconColor: const Color(0xFF2E7D32),
                  label: 'Total Distance',
                  value: routeResult.totalDistance,
                ),
              ),
              
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[600],
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.access_time,
                  iconColor: const Color(0xFF8B4513),
                  label: 'Estimated Time',
                  value: routeResult.estimatedTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Metric Item Widget
  Widget _buildMetricItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
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
        
        const SizedBox(height: 8),
        
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // MARK: - Route Details Card
  Widget _buildRouteDetailsCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.route,
                color: const Color(0xFF2E7D32),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Optimized Route',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
            
            return _buildRouteStopItem(
              stop: stop,
              index: index,
              isFirst: isFirst,
              isLast: isLast,
            );
          }).toList(),
        ],
      ),
    );
  }

  // MARK: - Route Stop Item
  Widget _buildRouteStopItem({
    required RouteStop stop,
    required int index,
    required bool isFirst,
    required bool isLast,
  }) {
    IconData stopIcon;
    Color stopColor;
    
    if (isFirst) {
      stopIcon = Icons.radio_button_checked;
      stopColor = const Color(0xFF2E7D32);
    } else if (isLast) {
      stopIcon = Icons.flag;
      stopColor = const Color(0xFF2E7D32);
    } else {
      stopIcon = Icons.location_on;
      stopColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Stop number and icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: stopColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: stopColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    stopIcon,
                    color: stopColor,
                    size: 18,
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: stopColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Stop details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (stop.displayName != stop.address) ...[
                  const SizedBox(height: 4),
                  Text(
                    stop.address,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Distance/time to next stop (if not last)
          if (!isLast && index < routeResult.legs.length)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                routeResult.legs[index].distance.text,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // MARK: - Action Buttons
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Navigate button (primary action)
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: ElevatedButton(
            onPressed: () {
              // TODO: Open in navigation app (Google Maps, Apple Maps, etc.)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Navigation integration coming soon!'),
                  backgroundColor: Color(0xFF2E7D32),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Start Navigation',
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
        
        const SizedBox(height: 12),
        
        // Secondary actions row
        Row(
          children: [
            // Save route button
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF48484A),
                    width: 1,
                  ),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    // TODO: Save route functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Save route functionality coming soon!'),
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.bookmark_border,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Save Route',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Plan new route button
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF48484A),
                    width: 1,
                  ),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    // Navigate back to route input screen
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.add_location,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'New Route',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}