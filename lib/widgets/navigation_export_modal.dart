// lib/widgets/navigation_export_modal.dart
//
// Modal bottom sheet for selecting navigation app export option
// Shows available apps based on platform (Apple Maps iOS only)

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../services/navigation_export_service.dart';
import '../models/route_models.dart';

class NavigationExportModal extends StatelessWidget {
  final OptimizedRouteResult routeResult;
  final OriginalRouteInputs originalInputs;

  const NavigationExportModal({
    Key? key,
    required this.routeResult,
    required this.originalInputs,
  }) : super(key: key);

  /// Show the navigation export modal
  static Future<void> show({
    required BuildContext context,
    required OptimizedRouteResult routeResult,
    required OriginalRouteInputs originalInputs,
  }) async {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return NavigationExportModal(
          routeResult: routeResult,
          originalInputs: originalInputs,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableApps = NavigationExportService.getAvailableApps();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E), // Dark gray background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MARK: - Modal Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // MARK: - Title
              const Text(
                'Export Route',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Choose your navigation app',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // MARK: - Navigation App Options
              ...availableApps.map((app) => _buildAppOption(
                context,
                app,
                isLast: app == availableApps.last,
              )),
              
              const SizedBox(height: 20),
              
              // MARK: - Cancel Button
              _buildCancelButton(context),
              
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  /// Build individual app option tile
  Widget _buildAppOption(BuildContext context, NavigationApp app, {bool isLast = false}) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _handleAppSelection(context, app),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2C2C2E), // Dark base
                    const Color(0xFF1C1C1E), // Darker gradient
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getAppColor(app).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getAppColor(app).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // App Icon with brand gradient
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: _getAppGradient(app),
                      boxShadow: [
                        BoxShadow(
                          color: _getAppColor(app).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getAppIcon(app),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // App Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          NavigationExportService.getAppDisplayName(app),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getAppDescription(app),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow indicator
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[500],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        if (!isLast) const SizedBox(height: 12),
      ],
    );
  }

  /// Build cancel button
  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF2C2C2E),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Handle app selection and export
  Future<void> _handleAppSelection(BuildContext context, NavigationApp app) async {
    // Close the modal first
    Navigator.of(context).pop();
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('Opening ${NavigationExportService.getAppDisplayName(app)}...'),
          ],
        ),
        backgroundColor: const Color(0xFF34C759),
        duration: const Duration(seconds: 2),
      ),
    );

    // Export to selected app
    final ExportResult result = await NavigationExportService.exportRoute(
      app: app,
      routeResult: routeResult,
      originalInputs: originalInputs,
    );

    // Hide loading indicator
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Show result feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              result.success ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(result.message),
            ),
          ],
        ),
        backgroundColor: result.success 
          ? const Color(0xFF34C759) 
          : const Color(0xFFFF3B30),
        duration: Duration(seconds: result.success ? 2 : 4),
      ),
    );
  }

  /// Get app icon
  IconData _getAppIcon(NavigationApp app) {
    switch (app) {
      case NavigationApp.googleMaps:
        return Icons.map;
      case NavigationApp.waze:
        return Icons.navigation;
      case NavigationApp.appleMaps:
        return Icons.location_on;
    }
  }

  /// Get authentic brand colors for each navigation app
  Color _getAppColor(NavigationApp app) {
    switch (app) {
      case NavigationApp.googleMaps:
        return const Color(0xFF4285F4); // Authentic Google Blue
      case NavigationApp.waze:
        return const Color(0xFF00D4FF); // Authentic Waze Cyan  
      case NavigationApp.appleMaps:
        return const Color(0xFF007AFF); // Authentic Apple Blue
    }
  }

  /// Get brand-specific gradient colors for enhanced styling
  LinearGradient _getAppGradient(NavigationApp app) {
    switch (app) {
      case NavigationApp.googleMaps:
        return const LinearGradient(
          colors: [Color(0xFF4285F4), Color(0xFF34A853)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case NavigationApp.waze:
        return const LinearGradient(
          colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case NavigationApp.appleMaps:
        return const LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF005BB8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  /// Get app description with warnings for limitations
  String _getAppDescription(NavigationApp app) {
    switch (app) {
      case NavigationApp.googleMaps:
        return 'Navigate with Google Maps';
      case NavigationApp.waze:
        return 'From current location only'; // Warning about Waze limitation
      case NavigationApp.appleMaps:
        return Platform.isIOS ? 'Native iOS navigation' : 'iOS only';
    }
  }
}