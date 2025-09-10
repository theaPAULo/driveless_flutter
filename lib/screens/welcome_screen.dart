// lib/screens/welcome_screen.dart
//
// ✨ UPDATED: Now with beautiful rotating compass feature icon!
// 🧭 ENHANCED: Added compass as a smart navigation feature
// ✅ PRESERVES: All existing functionality and animations

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/rotating_compass.dart'; // ✨ NEW: Import compass widget
import 'route_input_screen.dart';
import 'main_tab_view.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  
  // Animation controllers (PRESERVED - no changes)
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _featuresController;
  late AnimationController _buttonsController;
  late AnimationController _exitController;
  
  // Logo animations (PRESERVED - no changes)
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  
  // Text animations (PRESERVED - no changes)
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;
  
  // Feature icons animations (PRESERVED - no changes)
  late Animation<double> _featuresOpacity;
  late Animation<Offset> _featuresSlide;
  
  // Button animations (PRESERVED - no changes)
  late Animation<double> _buttonsOpacity;
  late Animation<Offset> _buttonsSlide;
  
  // Exit animation for smooth transition
  late Animation<double> _exitOpacity;
  late Animation<double> _exitScale;
  late Animation<Offset> _exitSlide;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // PRESERVED: All existing animation setup (no changes)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    
    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
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

    _subtitleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _featuresOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _featuresController,
      curve: Curves.easeOut,
    ));

    _featuresSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _featuresController,
      curve: Curves.easeOutCubic,
    ));

    _buttonsOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeOut,
    ));

    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeOutCubic,
    ));
    
    _exitOpacity = Tween<double>(
      begin: 1.0,
      end: 0.1, // Don't fade out completely - leave some visibility
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInCubic), // Start fading later
    ));
    
    _exitScale = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInBack,
    ));
    
    _exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.1),
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInBack,
    ));
  }

  void _startAnimationSequence() async {
    // Faster animation sequence for snappier feel
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      _textController.forward();
    }
    
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _featuresController.forward();
    }
    
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      _buttonsController.forward();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _featuresController.dispose();
    _buttonsController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          return Transform.scale(
            scale: _exitScale.value,
            child: SlideTransition(
              position: _exitSlide,
              child: Opacity(
                opacity: _exitOpacity.value,
                child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppThemes.iOSGradient, // PRESERVED: Same gradient
              ),
              child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // PRESERVED: Logo Section (no changes)
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
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
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // PRESERVED: Title and Subtitle Section (no changes)
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
                          ),
                          
                          const SizedBox(height: 12),
                          
                          SlideTransition(
                            position: _subtitleSlide,
                            child: FadeTransition(
                              opacity: _subtitleOpacity,
                              child: const Text(
                                'Drive Less, Save Time',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20,
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
                          ),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // ✨ ENHANCED: Feature Icons with Rotating Compass
                  AnimatedBuilder(
                    animation: _featuresController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _featuresSlide,
                        child: FadeTransition(
                          opacity: _featuresOpacity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Regular feature icon
                              _buildFeatureIcon(Icons.route, 'Multi-Stop\nRoutes'),
                              
                              // 🧭 NEW: Compass feature icon with rotating animation
                              _buildCompassFeatureIcon(),
                              
                              // Regular feature icon
                              _buildFeatureIcon(Icons.save, 'Save Time\n& Fuel'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // PRESERVED: Button Section (no changes)
                  AnimatedBuilder(
                    animation: _buttonsController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _buttonsSlide,
                        child: FadeTransition(
                          opacity: _buttonsOpacity,
                          child: Column(
                            children: [
                              _buildSignInButton(),
                              const SizedBox(height: 16),
                              _buildGuestButton(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // PRESERVED: Regular feature icon builder (no changes)
  Widget _buildFeatureIcon(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🧭 NEW: Special compass feature icon with rotation
  Widget _buildCompassFeatureIcon() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✨ Rotating compass as feature icon
          const RotatingCompass(
            size: 32,
            color: Colors.white,
            showRing: false,
            animationDuration: Duration(seconds: 5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Smart\nNavigation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // PRESERVED: Sign In Button (no changes)
  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // PRESERVED: Guest Button (no changes)
  Widget _buildGuestButton() {
    return TextButton(
      onPressed: _handleContinueAsGuest,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          'Continue as Guest',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // Event handlers with smooth transitions
  void _handleSignIn() async {
    try {
      // Add haptic feedback for better UX
      HapticFeedback.lightImpact();
      
      // Start sign in process
      await context.read<AuthProvider>().signInWithGoogle();
      
      // If successful, navigate with smooth transition
      if (mounted && context.read<AuthProvider>().isSignedIn) {
        _navigateToMainApp();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleContinueAsGuest() {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    // Navigate to main app with smooth fade transition
    _navigateToMainApp();
  }
  
  // Seamless transition with guaranteed overlap to prevent any flicker
  void _navigateToMainApp() async {
    if (_isExiting) return; // Prevent multiple taps
    
    setState(() {
      _isExiting = true;
    });
    
    // Start navigation immediately, don't wait for exit animation
    if (mounted) {
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainTabView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Conservative transition - ensure new screen is fully ready before showing
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                // Scale effect starts later to ensure screen is initialized
                final scaleValue = Tween<double>(
                  begin: 0.98,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
                )).value;
                
                // Fade starts even later to prevent any gaps
                final fadeValue = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                )).value;
                
                return Transform.scale(
                  scale: scaleValue,
                  child: Opacity(
                    opacity: fadeValue,
                    child: child,
                  ),
                );
              },
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 900), // Longer to ensure overlap
          reverseTransitionDuration: const Duration(milliseconds: 400),
        ),
      );
      
      // Start exit animation after navigation starts to ensure overlap
      _exitController.forward();
    }
  }
}