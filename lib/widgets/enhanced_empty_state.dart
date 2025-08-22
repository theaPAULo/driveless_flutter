// lib/widgets/enhanced_empty_state.dart
//
// 🎨 Enhanced Empty State Widget - Premium UX
// ✅ Beautiful empty states with animations and clear actions
// ✅ Contextual messaging and helpful guidance

import 'package:flutter/material.dart';

class EnhancedEmptyState extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? accentColor;
  final bool showAnimation;

  const EnhancedEmptyState({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionText,
    this.onAction,
    this.accentColor,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  State<EnhancedEmptyState> createState() => _EnhancedEmptyStateState();
}

class _EnhancedEmptyStateState extends State<EnhancedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));
    
    if (widget.showAnimation) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = widget.accentColor ?? const Color(0xFF34C759);
    
    Widget content = Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 40,
                  color: accentColor,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Subtitle
            Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: isDark ? Colors.grey[300] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action button
            if (widget.actionText != null && widget.onAction != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.actionText!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    
    if (widget.showAnimation) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: content,
            ),
          );
        },
      );
    }
    
    return content;
  }

  /// Pre-built empty states for common scenarios
  static Widget noRoutes({VoidCallback? onCreateRoute}) {
    return EnhancedEmptyState(
      icon: Icons.map_outlined,
      title: 'No Routes Yet',
      subtitle: 'Start planning your first optimized route to save time and fuel.',
      actionText: 'Plan Your First Route',
      onAction: onCreateRoute,
      accentColor: const Color(0xFF34C759),
    );
  }

  static Widget noSavedAddresses({VoidCallback? onAddAddress}) {
    return EnhancedEmptyState(
      icon: Icons.location_on_outlined,
      title: 'No Saved Addresses',
      subtitle: 'Save your frequently visited places for quick route planning.',
      actionText: 'Add Your First Address',
      onAction: onAddAddress,
      accentColor: const Color(0xFF007AFF),
    );
  }

  static Widget noSearchResults({String? searchTerm}) {
    return EnhancedEmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      subtitle: searchTerm != null
          ? 'No results found for "$searchTerm". Try a different search term.'
          : 'No results found. Try adjusting your search criteria.',
      accentColor: const Color(0xFF8E8E93),
    );
  }

  static Widget networkError({VoidCallback? onRetry}) {
    return EnhancedEmptyState(
      icon: Icons.wifi_off,
      title: 'Connection Problem',
      subtitle: 'Check your internet connection and try again.',
      actionText: 'Try Again',
      onAction: onRetry,
      accentColor: const Color(0xFFFF9500),
    );
  }

  static Widget locationError({VoidCallback? onRetry}) {
    return EnhancedEmptyState(
      icon: Icons.location_disabled,
      title: 'Location Access Needed',
      subtitle: 'Enable location services to use current location features.',
      actionText: 'Enable Location',
      onAction: onRetry,
      accentColor: const Color(0xFFFF3B30),
    );
  }

  static Widget biometricSetup({VoidCallback? onSetup}) {
    return EnhancedEmptyState(
      icon: Icons.fingerprint,
      title: 'Secure Your Account',
      subtitle: 'Enable biometric authentication for quick and secure access.',
      actionText: 'Set Up Biometrics',
      onAction: onSetup,
      accentColor: const Color(0xFF5856D6),
    );
  }
}