// lib/screens/initial_loading_screen.dart
//
// ✨ UPDATED: Now with beautiful rotating compass animation!
// 🧭 ENHANCED: Replaced CircularProgressIndicator with iOS-style compass
// ✅ PRESERVES: All existing timing and functionality

import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../widgets/rotating_compass.dart'; // ✨ NEW: Import compass widget

class InitialLoadingScreen extends StatefulWidget {
  final VoidCallback onLoadingComplete;
  
  const InitialLoadingScreen({
    super.key,
    required this.onLoadingComplete,
  });

  @override
  State<InitialLoadingScreen> createState() => _InitialLoadingScreenState();
}

class _InitialLoadingScreenState extends State<InitialLoadingScreen>
    with TickerProviderStateMixin {
  
  // Animation controllers (PRESERVED - no changes)
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _preparingController;
  
  // Logo animations (PRESERVED - no changes)
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleOpacity;
  
  // "Preparing your journey..." animations (PRESERVED - no changes)
  late Animation<double> _preparingOpacity;
  late Animation<Offset> _preparingSlide;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }

  void _initializeAnimations() {
    // PRESERVED: All existing animation setup
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _preparingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _preparingOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _preparingController,
      curve: Curves.easeOut,
    ));

    _preparingSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _preparingController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startLoadingSequence() async {
    // PRESERVED: Exact same timing as before
    _fadeController.forward();
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      _preparingController.forward();
    }
    
    await Future.delayed(const Duration(milliseconds: 1800));
    
    if (mounted) {
      widget.onLoadingComplete();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _preparingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppThemes.iOSGradient, // PRESERVED: Same gradient
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PRESERVED: Logo and Title Section (no changes)
              AnimatedBuilder(
                animation: Listenable.merge([_scaleController, _fadeController]),
                builder: (context, child) {
                  return Column(
                    children: [
                      Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.navigation,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Opacity(
                        opacity: _titleOpacity.value,
                        child: const Text(
                          'DriveLess',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Opacity(
                        opacity: _titleOpacity.value,
                        child: const Text(
                          'Drive Less, Save Time',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // ✨ ENHANCED: "Preparing your journey..." with Rotating Compass
              AnimatedBuilder(
                animation: _preparingController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _preparingSlide,
                    child: FadeTransition(
                      opacity: _preparingOpacity,
                      child: Column(
                        children: [
                          // 🧭 NEW: Beautiful rotating compass instead of CircularProgressIndicator
                          const RotatingCompass(
                            size: 36,
                            color: Colors.white,
                            strokeWidth: 3,
                            showRing: true,
                            animationDuration: Duration(seconds: 3),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // PRESERVED: Same text as before
                          const Text(
                            'Preparing your journey...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 0.3,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 6,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}