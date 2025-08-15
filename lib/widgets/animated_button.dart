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
    
    // Trigger haptic feedback on press start using correct method
    if (widget.enableHaptics && mounted) {
      try {
        // Using buttonTap() method which calls impact(HapticType.light)
        context.read<HapticFeedbackService>().buttonTap();
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
    
    // Enhanced haptic feedback for primary actions using correct method
    if (mounted) {
      try {
        // Using importantAction() method which calls impact(HapticType.medium)
        context.read<HapticFeedbackService>().importantAction();
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
        animation: _scaleAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
              ],
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}