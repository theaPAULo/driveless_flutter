// lib/screens/initial_loading_screen.dart
//
// ENHANCED: Initial loading screen with "Preparing your journey..." text
// ✅ IMPROVED: Matches iOS timing and text exactly
// ✅ IMPROVED: 3-second duration with perfect animations
// ✅ IMPROVED: "Preparing your journey..." appears after 1.2 seconds

import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

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
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _preparingController; // NEW: for "preparing" text
  
  // Logo animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleOpacity;
  
  // NEW: "Preparing your journey..." animations
  late Animation<double> _preparingOpacity;
  late Animation<Offset> _preparingSlide;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // NEW: Controller for "preparing" text
    _preparingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Logo animations
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

    // NEW: "Preparing your journey..." animations
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
    // Start initial animations (logo and title)
    _fadeController.forward();
    _scaleController.forward();
    
    // Wait 1.2 seconds, then show "Preparing your journey..." (matching iOS)
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      _preparingController.forward();
    }
    
    // Wait total of 3 seconds (extended from original 1.8s)
    await Future.delayed(const Duration(milliseconds: 1800));
    
    // Call completion callback
    if (mounted) {
      widget.onLoadingComplete();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _preparingController.dispose(); // NEW: dispose preparing controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // EXACT iOS gradient
          gradient: AppThemes.iOSGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // MARK: - Logo and Title Section
              AnimatedBuilder(
                animation: Listenable.merge([_scaleController, _fadeController]),
                builder: (context, child) {
                  return Column(
                    children: [
                      // Animated Logo
                      Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                                // Subtle green glow
                                BoxShadow(
                                  color: AppThemes.systemGreen.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 0),
                                  spreadRadius: -3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.navigation,
                              size: 50,
                              color: AppThemes.secondaryGreen,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Animated Title
                      Opacity(
                        opacity: _titleOpacity.value,
                        child: const Text(
                          'DriveLess',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -1,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // MARK: - "Preparing your journey..." Section (NEW)
              AnimatedBuilder(
                animation: _preparingController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _preparingSlide,
                    child: FadeTransition(
                      opacity: _preparingOpacity,
                      child: Column(
                        children: [
                          // Loading Spinner
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // "Preparing your journey..." Text
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