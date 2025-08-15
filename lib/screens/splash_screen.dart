// lib/screens/splash_screen.dart
//
// ✨ UPDATED: Now with beautiful rotating compass animation!
// 🧭 ENHANCED: Replaced CircularProgressIndicator with iOS-style compass
// ✅ PRESERVES: All existing timing and functionality

import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../widgets/rotating_compass.dart'; // ✨ NEW: Import compass widget

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  
  // Animation controllers (PRESERVED - no changes)
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;
  
  // Animations for logo (PRESERVED - no changes)
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  
  // Animations for text (PRESERVED - no changes)
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;
  
  // Animation for loading indicator (PRESERVED - no changes)
  late Animation<double> _loadingOpacity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // PRESERVED: All existing animation setup
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    ));

    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _taglineOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _loadingOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimationSequence() async {
    // PRESERVED: Exact same timing as before
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _textController.forward();
    }
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _loadingController.forward();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
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
              // PRESERVED: Logo Section (no changes)
              AnimatedBuilder(
                animation: Listenable.merge([_logoController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: Container(
                        width: 100,
                        height: 100,
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
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.navigation,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 30),
              
              // PRESERVED: Text Section (no changes)
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Column(
                    children: [
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleOpacity,
                          child: const Text(
                            'DriveLess',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1.0,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      SlideTransition(
                        position: _taglineSlide,
                        child: FadeTransition(
                          opacity: _taglineOpacity,
                          child: const Text(
                            'Drive Less, Save Time',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 50),
              
              // ✨ ENHANCED: Loading Section with Rotating Compass
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _loadingOpacity,
                    child: Column(
                      children: [
                        // 🧭 NEW: Beautiful rotating compass instead of CircularProgressIndicator
                        const RotatingCompass(
                          size: 32,
                          color: Colors.white,
                          strokeWidth: 2.5,
                          showRing: true,
                          animationDuration: Duration(seconds: 4),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // PRESERVED: Loading text (optional)
                        const Text(
                          'Loading...',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
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