// lib/screens/welcome_screen.dart
//
// Welcome screen with Google and Apple Sign-In options

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../providers/auth_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32), // Dark green
              Color(0xFF1B5E20), // Darker green
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 80),
                
                // App Logo and Title
                _buildHeader(),
                
                const SizedBox(height: 60),
                
                // Feature showcase
                _buildFeatures(),
                
                const Spacer(),
                
                // Sign-In Section
                _buildSignInSection(context),
                
                const SizedBox(height: 24),
                
                // Privacy Text
                _buildPrivacyText(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build app header
  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.route,
            color: Colors.white,
            size: 60,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // App Name
        const Text(
          'DriveLess',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Tagline
        const Text(
          'Smart route optimization for\neffortless travel',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build features section
  Widget _buildFeatures() {
    return Column(
      children: [
        _buildFeatureItem(
          icon: Icons.route,
          title: 'Smart Routing',
          description: 'AI-powered route optimization for multiple stops',
        ),
        const SizedBox(height: 24),
        _buildFeatureItem(
          icon: Icons.access_time,
          title: 'Save Time',
          description: 'Reduce travel time with real-time traffic analysis',
        ),
        const SizedBox(height: 24),
        _buildFeatureItem(
          icon: Icons.eco,
          title: 'Eco-Friendly',
          description: 'Lower fuel consumption and carbon footprint',
        ),
      ],
    );
  }

  /// Build individual feature item
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build sign-in section
  Widget _buildSignInSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            // Welcome text
            const Text(
              'Get started with your account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Apple Sign-In Button (iOS only)
            if (Platform.isIOS) ...[
              _buildAppleSignInButton(context, authProvider),
              const SizedBox(height: 16),
            ],
            
            // Google Sign-In Button
            _buildGoogleSignInButton(context, authProvider),
          ],
        );
      },
    );
  }

  /// Build Apple Sign-In button
  Widget _buildAppleSignInButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : () => _handleAppleSignIn(context),
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
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apple,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
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

  /// Build Google Sign-In button
  Widget _buildGoogleSignInButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : () => _handleGoogleSignIn(context),
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

  // MARK: - Actions
  
  /// Handle Apple Sign-In
  Future<void> _handleAppleSignIn(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    
    authProvider.clearError();
    await authProvider.signInWithApple();
    
    if (authProvider.errorMessage != null && context.mounted) {
      _showErrorSnackBar(context, authProvider.errorMessage!);
    }
  }
  
  /// Handle Google Sign-In
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    
    authProvider.clearError();
    await authProvider.signInWithGoogle();
    
    if (authProvider.errorMessage != null && context.mounted) {
      _showErrorSnackBar(context, authProvider.errorMessage!);
    }
  }

  /// Show error message to user
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}