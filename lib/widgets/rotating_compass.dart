// lib/widgets/rotating_compass.dart
//
// ✨ Rotating Compass Loading Animation
// Replicates the beautiful iOS compass animation from the original app
// Can replace CircularProgressIndicator throughout the app

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Rotating compass widget that replicates the iOS version
/// Can be used as a premium loading indicator throughout the app
class RotatingCompass extends StatefulWidget {
  final double size;
  final Color? color;
  final Color? ringColor;
  final double strokeWidth;
  final Duration animationDuration;
  final bool showRing;
  final IconData? customIcon;
  
  const RotatingCompass({
    super.key,
    this.size = 50.0,
    this.color,
    this.ringColor,
    this.strokeWidth = 2.0,
    this.animationDuration = const Duration(seconds: 4),
    this.showRing = true,
    this.customIcon,
  });

  @override
  State<RotatingCompass> createState() => _RotatingCompassState();
}

class _RotatingCompassState extends State<RotatingCompass>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create rotation animation controller
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    // Create smooth rotation animation (0 to 360 degrees)
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi, // Full 360-degree rotation in radians
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear, // Linear for smooth continuous rotation
    ));
    
    // Start the continuous rotation
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on theme
    final compassColor = widget.color ?? 
        (Theme.of(context).brightness == Brightness.dark 
            ? Colors.white 
            : const Color(0xFF34C759));
    
    final ringColor = widget.ringColor ?? 
        compassColor.withOpacity(0.3);
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer compass ring (optional)
          if (widget.showRing)
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ringColor,
                  width: widget.strokeWidth,
                ),
              ),
            ),
          
          // Rotating compass needle/icon
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.customIcon ?? Icons.navigation,
                    size: widget.size * 0.7, // Icon is 70% of container size
                    color: compassColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Enhanced compass with gradient effect (premium version)
class PremiumRotatingCompass extends StatefulWidget {
  final double size;
  final Duration animationDuration;
  final List<Color>? gradientColors;
  
  const PremiumRotatingCompass({
    super.key,
    this.size = 60.0,
    this.animationDuration = const Duration(seconds: 4),
    this.gradientColors,
  });

  @override
  State<PremiumRotatingCompass> createState() => _PremiumRotatingCompassState();
}

class _PremiumRotatingCompassState extends State<PremiumRotatingCompass>
    with TickerProviderStateMixin {
  
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Rotation animation
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    // Subtle pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.gradientColors ?? [
      const Color(0xFF34C759),
      const Color(0xFF30D158),
    ];
    
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  gradientColors[0].withOpacity(0.2),
                  gradientColors[1].withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: gradientColors[0].withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background glow
                Container(
                  width: widget.size * 0.8,
                  height: widget.size * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        gradientColors[0].withOpacity(0.3),
                        gradientColors[0].withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                
                // Rotating compass icon
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: Icon(
                        Icons.navigation,
                        size: widget.size * 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // Decorative directional markers
                ...List.generate(4, (index) {
                  final angle = (index * math.pi / 2);
                  final offset = Offset(
                    math.cos(angle) * (widget.size * 0.35),
                    math.sin(angle) * (widget.size * 0.35),
                  );
                  
                  return Transform.translate(
                    offset: offset,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: gradientColors[0].withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Compass with loading message (for route optimization screens)
class CompassWithMessage extends StatelessWidget {
  final String message;
  final double compassSize;
  final TextStyle? messageStyle;
  final Duration animationDuration;
  
  const CompassWithMessage({
    super.key,
    required this.message,
    this.compassSize = 50.0,
    this.messageStyle,
    this.animationDuration = const Duration(seconds: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rotating compass
        RotatingCompass(
          size: compassSize,
          animationDuration: animationDuration,
        ),
        
        const SizedBox(height: 16),
        
        // Loading message
        Text(
          message,
          style: messageStyle ?? TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Simple replacement for CircularProgressIndicator
/// Drop-in replacement that maintains the same API
class CompassProgressIndicator extends StatelessWidget {
  final double? value; // Progress value (null for indeterminate)
  final Color? color;
  final double strokeWidth;
  final double size;
  
  const CompassProgressIndicator({
    super.key,
    this.value,
    this.color,
    this.strokeWidth = 4.0,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      // Determinate progress - show progress ring with compass
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress ring
            CircularProgressIndicator(
              value: value,
              color: color ?? const Color(0xFF34C759),
              strokeWidth: strokeWidth,
              backgroundColor: (color ?? const Color(0xFF34C759)).withOpacity(0.2),
            ),
            // Small compass icon
            Icon(
              Icons.navigation,
              size: size * 0.4,
              color: color ?? const Color(0xFF34C759),
            ),
          ],
        ),
      );
    } else {
      // Indeterminate progress - rotating compass
      return RotatingCompass(
        size: size,
        color: color,
        strokeWidth: strokeWidth,
        showRing: true,
      );
    }
  }
}

/// Extension to easily replace CircularProgressIndicator
extension CompassProgressExtension on CircularProgressIndicator {
  /// Convert any CircularProgressIndicator to a CompassProgressIndicator
  CompassProgressIndicator toCompass() {
    return CompassProgressIndicator(
      value: value,
      color: color,
      strokeWidth: strokeWidth ?? 4.0, // Handle nullable strokeWidth
      size: 24.0, // Default size
    );
  }
}