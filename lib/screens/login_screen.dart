// lib/screens/login_screen.dart
//
// ✨ ENHANCED: Login screen with subtle gradients, improved feature icons, and micro-animations
// 🎯 IMPROVEMENTS:
//   - Subtle gradient buttons for Apple/Google sign-in
//   - Enhanced feature icons with better visual design
//   - Micro-animations (bounce, scale, pulse effects)
//   - Improved shadows and depth
//   - Better haptic feedback integration
//
// 📍 PLACEMENT: Replace the existing lib/screens/login_screen.dart file

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/haptic_feedback_service.dart';
import 'route_input_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  
  // Animation controllers for different elements
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _buttonsController;
  late AnimationController _featureIconController; // NEW: For micro-animations
  
  // Animation objects
  late Animation<double> _backgroundOpacity;
  late Animation<Offset> _logoSlide;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _contentSlide;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _buttonsSlide;
  late Animation<double> _buttonsOpacity;
  late Animation<double> _featureIconScale; // NEW: For bounce effects
  
  // Haptic feedback service
  final HapticFeedbackService hapticFeedback = HapticFeedbackService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimations();
  }

  void _initializeAnimations() {
    // Background animation (preserved)
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeIn),
    );

    // Logo animations (preserved)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_logoController);

    // Content animations (preserved)
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOut));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_contentController);

    // Button animations (preserved)
    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _buttonsController, curve: Curves.easeOut));
    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_buttonsController);

    // 🆕 NEW: Feature icon micro-animations
    _featureIconController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _featureIconScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _featureIconController, curve: Curves.elasticOut),
    );
  }

  void _startEntryAnimations() async {
    await _backgroundController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Start logo and content animations simultaneously
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    
    _contentController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    
    // 🆕 NEW: Start feature icon animations with stagger
    _featureIconController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    
    _buttonsController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _contentController.dispose();
    _buttonsController.dispose();
    _featureIconController.dispose(); // NEW: Dispose feature icon controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppThemes.iOSGradient, // Using your existing gradient
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        
                        // MARK: - Logo Section (preserved with enhancements)
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return SlideTransition(
                              position: _logoSlide,
                              child: FadeTransition(
                                opacity: _logoOpacity,
                                child: Column(
                                  children: [
                                    // 🆕 ENHANCED: Logo with subtle pulse animation
                                    AnimatedBuilder(
                                      animation: _featureIconController,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: 1.0 + (0.05 * _featureIconController.value),
                                          child: Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.25),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 10),
                                                ),
                                                BoxShadow(
                                                  color: AppThemes.primaryGreen.withOpacity(0.3),
                                                  blurRadius: 30,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.navigation,
                                              size: 50,
                                              color: AppThemes.primaryGreen,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // App title with enhanced shadow
                                    const Text(
                                      'DriveLess',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black38,
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                          Shadow(
                                            color: Colors.black26,
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 8),
                                    
                                    // Subtitle with enhanced styling
                                    const Text(
                                      'Drive Less, Save Time',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black38,
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
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
                        
                        const SizedBox(height: 50),
                        
                        // 🆕 ENHANCED: Feature Icons with micro-animations
                        AnimatedBuilder(
                          animation: _contentController,
                          builder: (context, child) {
                            return SlideTransition(
                              position: _contentSlide,
                              child: FadeTransition(
                                opacity: _contentOpacity,
                                child: AnimatedBuilder(
                                  animation: _featureIconScale,
                                  builder: (context, child) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildEnhancedFeatureIcon(
                                          Icons.route_outlined, 
                                          'Smart\nRoutes',
                                          const Color(0xFF4CAF50),
                                          0, // No delay
                                        ),
                                        _buildEnhancedFeatureIcon(
                                          Icons.access_time_outlined, 
                                          'Save\nTime',
                                          const Color(0xFF2196F3),
                                          200, // 200ms delay
                                        ),
                                        _buildEnhancedFeatureIcon(
                                          Icons.local_gas_station_outlined, 
                                          'Save\nFuel',
                                          const Color(0xFFFF9800),
                                          400, // 400ms delay
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              
              // MARK: - 🆕 ENHANCED: Sign In Card with gradients
              AnimatedBuilder(
                animation: _buttonsController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _buttonsSlide,
                    child: FadeTransition(
                      opacity: _buttonsOpacity,
                      child: _buildEnhancedSignInCard(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 🆕 ENHANCED: Feature icon with micro-animations and gradients
  Widget _buildEnhancedFeatureIcon(
    IconData icon, 
    String label, 
    Color accentColor, 
    int delayMs,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delayMs),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () async {
              // Haptic feedback and micro-animation on tap
              await hapticFeedback.buttonTap();
              
              // Quick scale animation
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icon with subtle glow effect
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🆕 ENHANCED: Sign In Card with subtle gradients
  Widget _buildEnhancedSignInCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sign in to start planning routes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Consumer for authentication state
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Column(
                children: [
                  // 🆕 ENHANCED: Apple Sign In Button with gradient
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Color(0xFFF5F5F5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _handleAppleSignIn(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black54,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.apple, size: 24),
                                  SizedBox(width: 12),
                                  Text(
                                    'Continue with Apple',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 🆕 ENHANCED: Google Sign In Button with gradient
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: OutlinedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _handleGoogleSignIn(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_mobiledata, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Privacy notice (preserved)
          const Text(
            'By continuing, you agree to our Terms of Service and Privacy Policy. Your data is securely stored and never shared.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.4,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // MARK: - Sign In Handlers with Enhanced Haptics (preserved functionality)
  Future<void> _handleAppleSignIn(BuildContext context) async {
    // Enhanced haptic feedback for button tap
    await hapticFeedback.importantAction();
    
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();
    await authProvider.signInWithApple();
    
    if (authProvider.errorMessage != null && context.mounted) {
      await hapticFeedback.error();
      _showErrorSnackBar(context, authProvider.errorMessage!);
    } else if (authProvider.user != null) {
      await hapticFeedback.success();
    }
  }
  
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    // Enhanced haptic feedback for button tap
    await hapticFeedback.importantAction();
    
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();
    await authProvider.signInWithGoogle();
    
    if (authProvider.errorMessage != null && context.mounted) {
      await hapticFeedback.error();
      _showErrorSnackBar(context, authProvider.errorMessage!);
    } else if (authProvider.user != null) {
      await hapticFeedback.success();
    }
  }

  // Enhanced error display
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppThemes.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}