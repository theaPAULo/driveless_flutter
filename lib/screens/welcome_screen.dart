// lib/screens/welcome_screen.dart
//
// UPDATED: Enhanced welcome screen with EXACT iOS gradient colors
// ✅ IMPROVED: Perfect gradient matching from iOS app
// ✅ IMPROVED: Dramatic visual enhancements and premium design
// ✅ IMPROVED: iOS-style animations and effects

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart'; // Import for gradient access
import 'route_input_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _featuresController;
  late AnimationController _buttonsController;
  
  // Logo animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  
  // Text animations
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;
  
  // Feature icons animations
  late Animation<double> _featuresOpacity;
  late Animation<Offset> _featuresSlide;
  
  // Button animations
  late Animation<double> _buttonsOpacity;
  late Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
      begin: const Offset(0, 0.8),
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
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
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
  }

  void _startAnimationSequence() async {
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _textController.forward();
    }
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _featuresController.forward();
    }
    
    await Future.delayed(const Duration(milliseconds: 200));
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // EXACT iOS gradient using new theme colors
          gradient: AppThemes.iOSGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // MARK: - Dramatically Enhanced Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Container(
                          width: 180, // MUCH LARGER
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: AppThemes.systemGreen.withOpacity(0.3),
                                blurRadius: 40,
                                offset: const Offset(0, 5),
                                spreadRadius: -10,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 50,
                                offset: const Offset(0, -10),
                                spreadRadius: -15,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.navigation,
                            color: AppThemes.secondaryGreen,
                            size: 90, // MUCH LARGER ICON
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // MARK: - Dramatically Enhanced Title
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleOpacity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'DriveLess',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 64, // MUCH LARGER
                              fontWeight: FontWeight.w900, // BOLDER
                              letterSpacing: -3,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 30,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // MARK: - Enhanced Subtitle
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _subtitleSlide,
                      child: FadeTransition(
                        opacity: _subtitleOpacity,
                        child: const Text(
                          'Optimize your routes.\nSave time and fuel.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22, // LARGER
                            fontWeight: FontWeight.w600, // BOLDER
                            height: 1.4,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 50),
                
                // MARK: - Enhanced Feature Icons
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
                            _buildFeatureIcon(Icons.route, 'Smart\nRoutes'),
                            _buildFeatureIcon(Icons.access_time, 'Save\nTime'),
                            _buildFeatureIcon(Icons.local_gas_station, 'Save\nFuel'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const Spacer(),
                
                // MARK: - Enhanced Action Buttons
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
    );
  }

  // MARK: - Feature Icon Builder
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
            size: 32, // LARGER ICONS
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14, // LARGER TEXT
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // MARK: - Sign In Button
  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 60, // TALLER BUTTONS
      child: ElevatedButton(
        onPressed: () async {
          // Add haptic feedback for iOS-style interaction
          if (Platform.isIOS) {
            HapticFeedback.lightImpact();
          }
          await context.read<AuthProvider>().signInWithApple();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppThemes.deepForestGreen,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // MORE ROUNDED
          ),
        ),
        child: const Text(
          'Sign In with Apple',
          style: TextStyle(
            fontSize: 20, // LARGER TEXT
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // MARK: - Guest Button
  Widget _buildGuestButton() {
    return Container(
      width: double.infinity,
      height: 60, // TALLER BUTTONS
      child: OutlinedButton(
        onPressed: () {
          // Add haptic feedback for iOS-style interaction
          if (Platform.isIOS) {
            HapticFeedback.lightImpact();
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RouteInputScreen()),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // MORE ROUNDED
          ),
        ),
        child: const Text(
          'Continue as Guest',
          style: TextStyle(
            fontSize: 20, // LARGER TEXT
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}