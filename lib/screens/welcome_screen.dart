// lib/screens/welcome_screen.dart
//
// Enhanced animated welcome screen with iOS-style animations and polish
// ✅ ENHANCED: Smooth animations for all elements
// ✅ ENHANCED: Professional timing and easing curves
// ✅ ENHANCED: Better styling and iOS-native feel
// ✅ PRESERVES: All existing functionality and platform logic

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../providers/auth_provider.dart';
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
    // Logo controller (600ms)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Text controller (500ms)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Features controller (400ms)
    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Buttons controller (500ms)
    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Logo animations
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

    // Title animations
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

    // Subtitle animations
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

    // Features animations
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

    // Buttons animations
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
    // Start logo animation immediately
    _logoController.forward();
    
    // Start text animation after 200ms
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _textController.forward();
    }
    
    // Start features animation after 300ms
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _featuresController.forward();
    }
    
    // Start buttons animation after 200ms
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
          // Enhanced gradient matching splash screen
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E20), // Deep forest green
              Color(0xFF2E7D32), // Dark green (primary)
              Color(0xFF388E3C), // Medium green
              Color(0xFF4CAF50), // Main green
              Color(0xFF66BB6A), // Light green
              Color(0xFF8BC34A), // Lime accent
              Color(0xFFA1887F), // Brown accent (iOS style)
            ],
            stops: [0.0, 0.15, 0.3, 0.5, 0.7, 0.85, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // MARK: - Animated Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 40,
                                offset: const Offset(0, -5),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.navigation,
                            color: Color(0xFF2E7D32),
                            size: 70,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // MARK: - Animated Title
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleOpacity,
                        child: const Text(
                          'DriveLess',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -2.5,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 25,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // MARK: - Animated Subtitle
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _subtitleSlide,
                      child: FadeTransition(
                        opacity: _subtitleOpacity,
                        child: const Text(
                          'Optimize your routes, save time and fuel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                            height: 1.4,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 15,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // MARK: - Animated Feature Icons
                AnimatedBuilder(
                  animation: _featuresController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _featuresSlide,
                      child: FadeTransition(
                        opacity: _featuresOpacity,
                        child: _buildFeatureIcons(),
                      ),
                    );
                  },
                ),
                
                const Spacer(),
                
                // MARK: - Animated Auth Buttons
                AnimatedBuilder(
                  animation: _buttonsController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _buttonsSlide,
                      child: FadeTransition(
                        opacity: _buttonsOpacity,
                        child: _buildAuthenticationSection(context),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // MARK: - Privacy Text (always visible)
                _buildPrivacyText(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build feature icons with enhanced styling
  Widget _buildFeatureIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureIcon(
          Icons.navigation,
          'Smart Routes',
          const Color(0xFF4CAF50),
        ),
        _buildFeatureIcon(
          Icons.schedule,
          'Real-Time',
          const Color(0xFF2196F3),
        ),
        _buildFeatureIcon(
          Icons.local_gas_station,
          'Save Fuel',
          const Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -3),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            shadows: [
              Shadow(
                color: Colors.black38,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build authentication section with platform-specific logic
  Widget _buildAuthenticationSection(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Show Apple Sign In button ONLY on iOS
        if (Platform.isIOS) ...[
          _buildAppleSignInButton(context, authProvider),
          const SizedBox(height: 16),
        ],
        
        // Show Google Sign In button on BOTH platforms
        _buildGoogleSignInButton(context, authProvider),
        
        // Show error message if exists
        if (authProvider.errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorMessage(authProvider.errorMessage!),
        ],
      ],
    );
  }

  /// Build enhanced Apple Sign In button (iOS ONLY)
  Widget _buildAppleSignInButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: authProvider.isLoading 
            ? null 
            : () => _handleAppleSignIn(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: authProvider.isLoading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apple, size: 26),
                  SizedBox(width: 14),
                  Text(
                    'Continue with Apple',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Build enhanced Google Sign In button
  Widget _buildGoogleSignInButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -2),
            spreadRadius: -3,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: authProvider.isLoading 
            ? null 
            : () => _handleGoogleSignIn(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: authProvider.isLoading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google_logo.png',
                    width: 26,
                    height: 26,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.g_mobiledata,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Build error message with enhanced styling
  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build privacy text
  Widget _buildPrivacyText() {
    return Text(
      'By signing in, you agree to our Terms of Service and Privacy Policy. Your data is securely stored and never shared.',
      style: TextStyle(
        color: Colors.white.withOpacity(0.85),
        fontSize: 13,
        height: 1.5,
        letterSpacing: 0.3,
        shadows: const [
          Shadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  // MARK: - Actions (Preserved Logic)
  
  /// Handle Apple Sign-In (iOS ONLY)
  Future<void> _handleAppleSignIn(BuildContext context) async {
    HapticFeedback.lightImpact();
    final authProvider = context.read<AuthProvider>();
    
    authProvider.clearError();
    await authProvider.signInWithApple();
    
    if (authProvider.errorMessage != null && context.mounted) {
      _showErrorSnackBar(context, authProvider.errorMessage!);
      return;
    }
    
    if (authProvider.user != null && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RouteInputScreen(),
        ),
      );
    }
  }
  
  /// Handle Google Sign-In (BOTH platforms)
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    HapticFeedback.lightImpact();
    final authProvider = context.read<AuthProvider>();
    
    authProvider.clearError();
    await authProvider.signInWithGoogle();
    
    if (authProvider.errorMessage != null && context.mounted) {
      _showErrorSnackBar(context, authProvider.errorMessage!);
      return;
    }
    
    if (authProvider.user != null && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RouteInputScreen(),
        ),
      );
    }
  }
  
  /// Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}