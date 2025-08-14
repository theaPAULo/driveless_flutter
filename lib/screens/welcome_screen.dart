// lib/screens/welcome_screen.dart
//
// Updated Welcome Screen - Platform-Specific Authentication
// ✅ iOS: Apple Sign In + Google Sign In 
// ✅ Android: Google Sign In only
// ✅ PRESERVES: All existing functionality, theme support, error handling

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../providers/auth_provider.dart';
import 'route_input_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF1B5E20),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                _buildLogo(),
                const SizedBox(height: 24),
                _buildTitle(),
                const SizedBox(height: 12),
                _buildSubtitle(),
                const Spacer(flex: 2),
                _buildAuthenticationSection(context),
                const SizedBox(height: 24),
                _buildPrivacyText(),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build app logo
  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Icon(
        Icons.map,
        color: Colors.white,
        size: 60,
      ),
    );
  }

  /// Build app title
  Widget _buildTitle() {
    return const Text(
      'DriveLess',
      style: TextStyle(
        color: Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
        letterSpacing: -1,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build subtitle
  Widget _buildSubtitle() {
    return Text(
      'Optimize your routes.\nSave time, fuel, and the environment.',
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 18,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build authentication section - PLATFORM-SPECIFIC LOGIC
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

  /// Build Apple Sign In button (iOS ONLY)
  Widget _buildAppleSignInButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: authProvider.isLoading 
            ? null 
            : () => _handleAppleSignIn(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: authProvider.isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Signing In...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Apple icon
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.apple,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Apple',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Build Google Sign In button (BOTH platforms)
  Widget _buildGoogleSignInButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: authProvider.isLoading 
            ? null 
            : () => _handleGoogleSignIn(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: authProvider.isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Signing In...',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google icon
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.g_mobiledata,
                      color: Color(0xFF4285F4),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Build error message
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
        color: Colors.grey[300],
        fontSize: 12,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  // MARK: - Actions - PRESERVED LOGIC
  
  /// Handle Apple Sign-In (iOS ONLY)
  Future<void> _handleAppleSignIn(BuildContext context) async {
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
  
  /// Show error snackbar - PRESERVED LOGIC
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