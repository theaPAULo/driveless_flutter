// lib/screens/welcome_screen.dart
//
// Welcome and authentication screen matching iOS app design
// Shows when user is not signed in

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              
              // MARK: - App Logo/Icon
              _buildAppIcon(),
              
              const SizedBox(height: 48),
              
              // MARK: - Welcome Text
              _buildWelcomeText(),
              
              const SizedBox(height: 64),
              
              // MARK: - Features List
              _buildFeaturesList(),
              
              const Spacer(),
              
              // MARK: - Sign In Button
              _buildSignInButton(),
              
              const SizedBox(height: 24),
              
              // MARK: - Privacy Text
              _buildPrivacyText(),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - App Icon
  Widget _buildAppIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.route,
        color: Colors.white,
        size: 60,
      ),
    );
  }

  // MARK: - Welcome Text
  Widget _buildWelcomeText() {
    return Column(
      children: [
        const Text(
          'Welcome to DriveLess',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Optimize your routes, save time and fuel with intelligent route planning.',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 18,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // MARK: - Features List
  Widget _buildFeaturesList() {
    return Column(
      children: [
        _buildFeatureItem(
          icon: Icons.route,
          title: 'Smart Route Optimization',
          description: 'Find the best path through multiple stops',
        ),
        
        const SizedBox(height: 24),
        
        _buildFeatureItem(
          icon: Icons.cloud_sync,
          title: 'Cloud Sync',
          description: 'Access your saved routes and addresses anywhere',
        ),
        
        const SizedBox(height: 24),
        
        _buildFeatureItem(
          icon: Icons.analytics,
          title: 'Track Your Savings',
          description: 'See how much time and fuel you\'ve saved',
        ),
      ],
    );
  }

  // MARK: - Feature Item
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        // Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2E7D32),
            size: 24,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: - Sign In Button
  Widget _buildSignInButton() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: authService.isLoading ? null : _handleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: authService.isLoading
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
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // MARK: - Privacy Text
  Widget _buildPrivacyText() {
    return Text(
      'By signing in, you agree to our Terms of Service and Privacy Policy. Your data is securely stored and never shared.',
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 12,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  // MARK: - Actions
  
  /// Handle Google Sign-In
  Future<void> _handleSignIn() async {
    final authService = context.read<AuthService>();
    
    // Clear any previous errors
    authService.clearError();
    
    final success = await authService.signInWithGoogle();
    
    if (!success && mounted) {
      // Show error if sign-in failed
      _showErrorSnackBar(authService.errorMessage ?? 'Sign-in failed');
    }
    // Note: If successful, the auth state change will automatically navigate to the main app
  }

  /// Show error message to user
  void _showErrorSnackBar(String message) {
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