// lib/screens/welcome_screen.dart
//
// DRAMATICALLY enhanced welcome screen - visually obvious improvements
// ✅ Much larger, more prominent elements
// ✅ Completely different visual treatment
// ✅ iOS-style premium design

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
          // Premium gradient with more dramatic color transitions
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D4E1B), // Very deep forest green
              Color(0xFF1B5E20), // Deep forest green
              Color(0xFF2E7D32), // Dark green (primary)
              Color(0xFF4CAF50), // Main green
              Color(0xFF66BB6A), // Light green
              Color(0xFF8BC34A), // Lime accent
              Color(0xFFCDDC39), // Yellow-green
              Color(0xFFA1887F), // Brown accent (iOS style)
            ],
            stops: [0.0, 0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 1.0],
          ),
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
                                color: Colors.green.withOpacity(0.3),
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
                            color: Color(0xFF2E7D32),
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
                
                // MARK: - Enhanced Subtitle with Background
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _subtitleSlide,
                      child: FadeTransition(
                        opacity: _subtitleOpacity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Optimize your routes, save time and fuel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22, // LARGER
                              fontWeight: FontWeight.w600, // BOLDER
                              letterSpacing: 1.0,
                              height: 1.4,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
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
                
                const SizedBox(height: 50),
                
                // MARK: - Dramatically Enhanced Feature Icons
                AnimatedBuilder(
                  animation: _featuresController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _featuresSlide,
                      child: FadeTransition(
                        opacity: _featuresOpacity,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: _buildEnhancedFeatureIcons(),
                        ),
                      ),
                    );
                  },
                ),
                
                const Spacer(),
                
                // MARK: - Premium Auth Buttons
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
                
                _buildPrivacyText(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedFeatureIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureIcon(
          Icons.navigation,
          'Smart\nRoutes',
          const Color(0xFF4CAF50),
        ),
        _buildFeatureIcon(
          Icons.schedule,
          'Real-Time\nTraffic',
          const Color(0xFF2196F3),
        ),
        _buildFeatureIcon(
          Icons.local_gas_station,
          'Save\nFuel',
          const Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 90, // MUCH LARGER
          height: 90,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.1),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: iconColor.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 40, // LARGER ICON
          ),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16, // LARGER
            fontWeight: FontWeight.w700, // BOLDER
            letterSpacing: 0.8,
            height: 1.2,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthenticationSection(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (Platform.isIOS) ...[
          _buildAppleSignInButton(context, authProvider),
          const SizedBox(height: 20),
        ],
        
        _buildGoogleSignInButton(context, authProvider),
        
        if (authProvider.errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorMessage(authProvider.errorMessage!),
        ],
      ],
    );
  }

  Widget _buildAppleSignInButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      height: 70, // MUCH TALLER
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF1C1C1E), Color(0xFF000000)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -2),
            spreadRadius: -3,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: authProvider.isLoading 
            ? null 
            : () => _handleAppleSignIn(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: authProvider.isLoading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apple, size: 30),
                  SizedBox(width: 16),
                  Text(
                    'Continue with Apple',
                    style: TextStyle(
                      fontSize: 22, // LARGER
                      fontWeight: FontWeight.w700, // BOLDER
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      height: 70, // MUCH TALLER
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 4),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: authProvider.isLoading 
            ? null 
            : () => _handleGoogleSignIn(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: authProvider.isLoading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google_logo.png',
                    width: 30,
                    height: 30,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.g_mobiledata,
                          color: Colors.white,
                          size: 22,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 22, // LARGER
                      fontWeight: FontWeight.w700, // BOLDER
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.2),
            Colors.red.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'By signing in, you agree to our Terms of Service and Privacy Policy. Your data is securely stored and never shared.',
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 14,
          height: 1.5,
          letterSpacing: 0.4,
          shadows: const [
            Shadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // MARK: - Actions (Preserved Logic)
  
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