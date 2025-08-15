// lib/widgets/animated_button.dart
//
// ✨ Universal Micro-Animations System
// Adds premium button press effects throughout the entire app
// Compatible with all existing buttons - just wrap them!

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/haptic_feedback_service.dart';

/// Universal animated button wrapper that adds premium micro-interactions
/// 
/// Usage: Wrap any existing button with AnimatedButton()
/// Example: AnimatedButton(child: ElevatedButton(...))
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool enableHaptics;
  final double scaleIntensity;
  final Duration animationDuration;
  
  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.enableHaptics = true,
    this.scaleIntensity = 0.95, // 5% scale down on press
    this.animationDuration = const Duration(milliseconds: 100),
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize scale animation controller
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    // Create smooth scale animation
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleIntensity,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    
    // Trigger haptic feedback on press start
    if (widget.enableHaptics && mounted) {
      try {
        context.read<HapticFeedbackService>().lightImpact();
      } catch (e) {
        // Fallback if haptic service not available
        print('Haptic feedback not available: $e');
      }
    }
    
    // Start press animation
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _handleRelease();
  }

  void _handleTapCancel() {
    _handleRelease();
  }

  void _handleRelease() {
    setState(() {
      _isPressed = false;
    });
    
    // Release animation with spring back
    _animationController.reverse();
    
    // Trigger the actual button press after animation starts
    if (widget.onPressed != null) {
      // Small delay to let animation start, then trigger action
      Future.delayed(const Duration(milliseconds: 50), () {
        widget.onPressed?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Specialized animated button for primary actions (Optimize Route, Save, etc.)
/// Includes enhanced haptic feedback and visual effects
class PrimaryAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool enabled;
  
  const PrimaryAnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.enabled = true,
  });

  @override
  State<PrimaryAnimatedButton> createState() => _PrimaryAnimatedButtonState();
}

class _PrimaryAnimatedButtonState extends State<PrimaryAnimatedButton>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Scale animation (more pronounced for primary buttons)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.93, // Slightly more dramatic scale
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Elevation animation (shadow effect)
    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    
    // Enhanced haptic feedback for primary actions
    if (mounted) {
      try {
        context.read<HapticFeedbackService>().mediumImpact();
      } catch (e) {
        print('Haptic feedback not available: $e');
      }
    }
    
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _handleRelease();
  }

  void _handleTapCancel() {
    _handleRelease();
  }

  void _handleRelease() {
    _animationController.reverse();
    
    if (widget.onPressed != null && widget.enabled) {
      Future.delayed(const Duration(milliseconds: 75), () {
        widget.onPressed?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34C759).withOpacity(0.3),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Quick extension methods for easy micro-animation application
extension AnimatedButtonExtensions on Widget {
  /// Wrap any widget with subtle micro-animations
  Widget withMicroAnimations({
    VoidCallback? onPressed,
    bool enableHaptics = true,
    double scaleIntensity = 0.95,
  }) {
    return AnimatedButton(
      onPressed: onPressed,
      enableHaptics: enableHaptics,
      scaleIntensity: scaleIntensity,
      child: this,
    );
  }
  
  /// Wrap any widget with enhanced primary button animations
  Widget withPrimaryAnimations({
    VoidCallback? onPressed,
    bool enabled = true,
  }) {
    return PrimaryAnimatedButton(
      onPressed: onPressed,
      enabled: enabled,
      child: this,
    );
  }
}

/// Animated loading state with pulsing effect
class AnimatedLoadingIndicator extends StatefulWidget {
  final Color? color;
  final double size;
  final String? message;
  
  const AnimatedLoadingIndicator({
    super.key,
    this.color,
    this.size = 24.0,
    this.message,
  });

  @override
  State<AnimatedLoadingIndicator> createState() => _AnimatedLoadingIndicatorState();
}

class _AnimatedLoadingIndicatorState extends State<AnimatedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: CircularProgressIndicator(
                color: widget.color ?? const Color(0xFF34C759),
                strokeWidth: 3,
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }
}