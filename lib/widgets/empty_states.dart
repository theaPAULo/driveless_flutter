// lib/widgets/empty_states.dart
//
// ✨ Enhanced Empty States System
// Engaging screens for first-time users and empty data states
// Replaces basic "No data" messages with welcoming, actionable interfaces

import 'package:flutter/material.dart';
import '../widgets/animated_button.dart';

/// Types of empty states throughout the app
enum EmptyStateType {
  routeHistory,
  favoriteRoutes,
  savedAddresses,
  searchResults,
  general,
}

/// Enhanced empty state widget with engaging graphics and clear actions
class EnhancedEmptyState extends StatefulWidget {
  final EmptyStateType type;
  final String? customTitle;
  final String? customMessage;
  final String? actionButtonText;
  final VoidCallback? onActionPressed;
  final Widget? customIllustration;
  final bool showSecondaryAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryActionPressed;
  
  const EnhancedEmptyState({
    super.key,
    required this.type,
    this.customTitle,
    this.customMessage,
    this.actionButtonText,
    this.onActionPressed,
    this.customIllustration,
    this.showSecondaryAction = false,
    this.secondaryActionText,
    this.onSecondaryActionPressed,
  });

  @override
  State<EnhancedEmptyState> createState() => _EnhancedEmptyStateState();
}

class _EnhancedEmptyStateState extends State<EnhancedEmptyState>
    with TickerProviderStateMixin {
  
  late AnimationController _floatingController;
  late AnimationController _fadeController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Floating animation for illustration
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // Start animations
    _floatingController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateInfo = _getEmptyStateInfo(widget.type);
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated illustration
                _buildIllustration(stateInfo),
                
                const SizedBox(height: 32),
                
                // Title and message
                _buildContent(context, stateInfo),
                
                const SizedBox(height: 40),
                
                // Action buttons
                _buildActionButtons(context, stateInfo),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIllustration(EmptyStateInfo stateInfo) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value),
          child: widget.customIllustration ?? _buildDefaultIllustration(stateInfo),
        );
      },
    );
  }

  Widget _buildDefaultIllustration(EmptyStateInfo stateInfo) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            stateInfo.primaryColor.withOpacity(0.2),
            stateInfo.primaryColor.withOpacity(0.05),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: stateInfo.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: stateInfo.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          // Main icon
          Icon(
            stateInfo.icon,
            size: 50,
            color: stateInfo.primaryColor,
          ),
          // Secondary decorative icons
          ...stateInfo.decorativeIcons.map((decorativeIcon) {
            return Positioned(
              top: decorativeIcon.offset.dy,
              left: decorativeIcon.offset.dx,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: stateInfo.primaryColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  decorativeIcon.icon,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, EmptyStateInfo stateInfo) {
    return Column(
      children: [
        // Title
        Text(
          widget.customTitle ?? stateInfo.title,
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineMedium?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // Message
        Text(
          widget.customMessage ?? stateInfo.message,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        // Additional helpful tips
        if (stateInfo.tips.isNotEmpty) ...[
          const SizedBox(height: 24),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: const Color(0xFF34C759),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Getting Started Tips',
                      style: TextStyle(
                        color: const Color(0xFF34C759),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...stateInfo.tips.map((tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, EmptyStateInfo stateInfo) {
    return Column(
      children: [
        // Primary action button
        if (widget.onActionPressed != null)
          SizedBox(
            width: double.infinity,
            child: PrimaryAnimatedButton(
              onPressed: widget.onActionPressed,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      stateInfo.primaryColor,
                      stateInfo.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      stateInfo.actionIcon,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.actionButtonText ?? stateInfo.actionText,
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
        
        // Secondary action button
        if (widget.showSecondaryAction && widget.onSecondaryActionPressed != null) ...[
          const SizedBox(height: 16),
          AnimatedButton(
            onPressed: widget.onSecondaryActionPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: stateInfo.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.secondaryActionText ?? 'Learn More',
                style: TextStyle(
                  color: stateInfo.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  EmptyStateInfo _getEmptyStateInfo(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.routeHistory:
        return EmptyStateInfo(
          icon: Icons.route,
          primaryColor: const Color(0xFF34C759),
          title: 'No Routes Yet',
          message: 'Start planning your first route to see your optimization history here. Every route you plan will be automatically saved for easy access.',
          actionIcon: Icons.add_road,
          actionText: 'Plan Your First Route',
          tips: [
            'Add your starting location and destination',
            'Include multiple stops for maximum savings',
            'Enable traffic consideration for real-time optimization',
            'Saved routes can be reloaded anytime',
          ],
          decorativeIcons: [
            DecorativeIcon(Icons.location_on, Offset(110, 20)),
            DecorativeIcon(Icons.directions, Offset(20, 110)),
          ],
        );
        
      case EmptyStateType.favoriteRoutes:
        return EmptyStateInfo(
          icon: Icons.favorite,
          primaryColor: Colors.red,
          title: 'No Favorite Routes',
          message: 'Mark routes as favorites to see them here for quick access. Tap the heart icon on any route to add it to your favorites.',
          actionIcon: Icons.history,
          actionText: 'View Route History',
          tips: [
            'Favorite frequently used routes for quick access',
            'Heart icon appears on all your saved routes',
            'Favorites sync across all your devices',
          ],
          decorativeIcons: [
            DecorativeIcon(Icons.star, Offset(105, 25)),
            DecorativeIcon(Icons.bookmark, Offset(25, 105)),
          ],
        );
        
      case EmptyStateType.savedAddresses:
        return EmptyStateInfo(
          icon: Icons.home,
          primaryColor: const Color(0xFF007AFF),
          title: 'No Saved Addresses',
          message: 'Save your frequently visited places like home, work, or favorite restaurants for quick route planning.',
          actionIcon: Icons.add_location,
          actionText: 'Add Your First Address',
          tips: [
            'Add home and work for daily commute optimization',
            'Save favorite restaurants and shopping centers',
            'Custom labels make addresses easy to find',
            'Addresses sync across all your devices',
          ],
          decorativeIcons: [
            DecorativeIcon(Icons.work, Offset(110, 30)),
            DecorativeIcon(Icons.restaurant, Offset(30, 110)),
          ],
        );
        
      case EmptyStateType.searchResults:
        return EmptyStateInfo(
          icon: Icons.search_off,
          primaryColor: Colors.orange,
          title: 'No Results Found',
          message: 'We couldn\'t find any routes matching your search. Try adjusting your search terms or check your spelling.',
          actionIcon: Icons.refresh,
          actionText: 'Clear Search',
          tips: [
            'Check spelling of location names',
            'Try broader search terms',
            'Use landmarks or business names',
          ],
          decorativeIcons: [
            DecorativeIcon(Icons.location_searching, Offset(100, 35)),
          ],
        );
        
      case EmptyStateType.general:
      default:
        return EmptyStateInfo(
          icon: Icons.inbox,
          primaryColor: Colors.grey,
          title: 'Nothing Here Yet',
          message: 'This section is empty, but that\'s about to change! Start using DriveLess to see your data here.',
          actionIcon: Icons.explore,
          actionText: 'Get Started',
          tips: [
            'Explore the app to discover all features',
            'Your data will appear here as you use the app',
          ],
          decorativeIcons: [],
        );
    }
  }
}

/// Data classes for empty state configuration
class EmptyStateInfo {
  final IconData icon;
  final Color primaryColor;
  final String title;
  final String message;
  final IconData actionIcon;
  final String actionText;
  final List<String> tips;
  final List<DecorativeIcon> decorativeIcons;

  EmptyStateInfo({
    required this.icon,
    required this.primaryColor,
    required this.title,
    required this.message,
    required this.actionIcon,
    required this.actionText,
    required this.tips,
    required this.decorativeIcons,
  });
}

class DecorativeIcon {
  final IconData icon;
  final Offset offset;

  DecorativeIcon(this.icon, this.offset);
}

/// Compact empty state for smaller spaces (like list sections)
class CompactEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? color;
  final String? actionText;
  final VoidCallback? onActionPressed;
  
  const CompactEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.color,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? const Color(0xFF34C759);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (onActionPressed != null && actionText != null) ...[
            const SizedBox(height: 20),
            AnimatedButton(
              onPressed: onActionPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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