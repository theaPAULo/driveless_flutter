// lib/widgets/error_states.dart
//
// ✨ Enhanced Error States System
// Professional error screens with helpful actions and friendly messaging
// Replaces basic error dialogs with engaging, actionable interfaces

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/haptic_feedback_service.dart';
import '../widgets/animated_button.dart';

/// Comprehensive error types for different failure scenarios
enum ErrorType {
  network,
  location,
  apiLimit,
  routeCalculation,
  authentication,
  general,
}

/// Enhanced error screen that provides context and helpful actions
class EnhancedErrorScreen extends StatelessWidget {
  final ErrorType errorType;
  final String? customTitle;
  final String? customMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;
  final bool showContactSupport;
  
  const EnhancedErrorScreen({
    super.key,
    required this.errorType,
    this.customTitle,
    this.customMessage,
    this.onRetry,
    this.onGoHome,
    this.showContactSupport = true,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo(errorType);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header with back button
                _buildHeader(context),
                
                // Main error content (centered)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated error icon
                      _buildErrorIcon(errorInfo),
                      
                      const SizedBox(height: 32),
                      
                      // Error title and message
                      _buildErrorContent(context, errorInfo),
                      
                      const SizedBox(height: 40),
                      
                      // Action buttons
                      _buildActionButtons(context),
                    ],
                  ),
                ),
                
                // Support contact (if enabled)
                if (showContactSupport) _buildSupportSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        AnimatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 24,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildErrorIcon(ErrorInfo errorInfo) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Opacity(
            opacity: value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: errorInfo.color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: errorInfo.color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                errorInfo.icon,
                size: 60,
                color: errorInfo.color,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorContent(BuildContext context, ErrorInfo errorInfo) {
    return Column(
      children: [
        // Error title
        Text(
          customTitle ?? errorInfo.title,
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineMedium?.color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Error message
        Text(
          customMessage ?? errorInfo.message,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        // Additional helpful tips
        if (errorInfo.tip != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF34C759).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: const Color(0xFF34C759),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorInfo.tip!,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary action button (Retry)
        if (onRetry != null)
          SizedBox(
            width: double.infinity,
            child: PrimaryAnimatedButton(
              onPressed: onRetry,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF34C759), Color(0xFF30D158)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      _getRetryButtonText(errorType),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Secondary action button (Go Home)
        if (onGoHome != null)
          SizedBox(
            width: double.infinity,
            child: AnimatedButton(
              onPressed: onGoHome,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF34C759).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home,
                      color: const Color(0xFF34C759),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Go to Home',
                      style: TextStyle(
                        color: const Color(0xFF34C759),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.support_agent,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Still having trouble? Contact our support team',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          AnimatedButton(
            onPressed: () => _contactSupport(context),
            child: Text(
              'Contact',
              style: TextStyle(
                color: const Color(0xFF34C759),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  ErrorInfo _getErrorInfo(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return ErrorInfo(
          icon: Icons.wifi_off,
          color: Colors.orange,
          title: 'Connection Problem',
          message: 'Unable to connect to the internet. Please check your connection and try again.',
          tip: 'Make sure you have a stable internet connection and try again.',
        );
      
      case ErrorType.location:
        return ErrorInfo(
          icon: Icons.location_off,
          color: Colors.red,
          title: 'Location Access Needed',
          message: 'DriveLess needs location access to optimize your routes and provide directions.',
          tip: 'Go to Settings > Privacy > Location Services and enable location for DriveLess.',
        );
      
      case ErrorType.apiLimit:
        return ErrorInfo(
          icon: Icons.schedule,
          color: Colors.amber,
          title: 'Daily Limit Reached',
          message: 'You\'ve reached your daily route optimization limit. Try again tomorrow or upgrade for unlimited access.',
          tip: 'Your limit resets every 24 hours. Premium users get unlimited optimizations.',
        );
      
      case ErrorType.routeCalculation:
        return ErrorInfo(
          icon: Icons.route,
          color: Colors.blue,
          title: 'Route Calculation Failed',
          message: 'We couldn\'t calculate an optimal route with the provided addresses. Please check your locations and try again.',
          tip: 'Make sure all addresses are valid and accessible by car.',
        );
      
      case ErrorType.authentication:
        return ErrorInfo(
          icon: Icons.account_circle_outlined,
          color: Colors.purple,
          title: 'Sign In Required',
          message: 'Please sign in to your account to continue using DriveLess features.',
          tip: 'Your routes and preferences are saved to your account for easy access.',
        );
      
      case ErrorType.general:
      default:
        return ErrorInfo(
          icon: Icons.error_outline,
          color: Colors.grey,
          title: 'Something Went Wrong',
          message: 'An unexpected error occurred. Please try again or contact support if the problem persists.',
          tip: 'Most issues resolve themselves with a quick retry.',
        );
    }
  }

  String _getRetryButtonText(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Try Again';
      case ErrorType.location:
        return 'Check Settings';
      case ErrorType.apiLimit:
        return 'Learn About Premium';
      case ErrorType.routeCalculation:
        return 'Retry Route';
      case ErrorType.authentication:
        return 'Sign In';
      case ErrorType.general:
      default:
        return 'Retry';
    }
  }

  void _contactSupport(BuildContext context) {
    // Implement support contact (email, in-app feedback, etc.)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text('Would you like to send feedback or report this issue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to feedback screen or open email
            },
            child: const Text('Send Feedback'),
          ),
        ],
      ),
    );
  }
}

/// Data class for error information
class ErrorInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String? tip;

  ErrorInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.tip,
  });
}

/// Inline error widget for smaller error states (within screens)
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool compact;
  
  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: Colors.red,
            size: compact ? 24 : 32,
          ),
          SizedBox(height: compact ? 8 : 12),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: compact ? 12 : 16),
            AnimatedButton(
              onPressed: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}