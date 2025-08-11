// lib/screens/login_screen.dart
//
// Login screen with Google and Apple Sign-In options

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20), // Dark green background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // App Logo/Title
              _buildAppHeader(),
              
              const SizedBox(height: 40),
              
              // Feature Icons
              _buildFeatureIcons(),
              
              const Spacer(),
              
              // Sign-In Buttons
              _buildSignInButtons(context),
              
              const SizedBox(height: 24),
              
              // Privacy Text
              _buildPrivacyText(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Build app header with logo and title
  Widget _buildAppHeader() {
    return Column(
      children: [
        // App Icon/Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.route,
            color: Colors.white,
            size: 50,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // App Title
        const Text(
          'DriveLess',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle
        const Text(
          'Optimize your routes, save time and fuel',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build feature icons
  Widget _buildFeatureIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureIcon(
          icon: Icons.route,
          label: 'Smart Routes',
        ),
        _buildFeatureIcon(
          icon: Icons.access_time,
          label: 'Real-Time',
        ),
        _buildFeatureIcon(
          icon: Icons.local_gas_station,
          label: 'Save Fuel',
        ),
      ],
    );
  }

  /// Build individual feature icon
  Widget _buildFeatureIcon({
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build sign-in buttons section
  Widget _buildSignInButtons(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
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

  /// Build Apple Sign-In button (iOS only)
  Widget _buildAppleSignInButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: authProvider.isLoading 
              ? null 
              : () => authProvider.signInWithApple(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Apple icon
                if (!authProvider.isLoading) ...[
                  const Icon(
                    Icons.apple,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                
                // Text or loading indicator
                if (authProvider.isLoading) 
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Text(
                    'Continue with Apple',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build Google Sign-In button
  Widget _buildGoogleSignInButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: authProvider.isLoading 
              ? null 
              : () => authProvider.signInWithGoogle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google icon
                if (!authProvider.isLoading) ...[
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://developers.google.com/identity/images/g-logo.png'
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                
                // Text or loading indicator
                if (authProvider.isLoading) 
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF2E7D32),
                    ),
                  )
                else
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
              ],
            ),
          ),
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
}