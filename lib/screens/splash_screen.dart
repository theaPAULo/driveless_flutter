// lib/screens/splash_screen.dart
//
// Splash screen with green gradient background and loading indicator
// Shown during app initialization and authentication checks

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Green gradient background matching iOS design
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32), // Dark green
              Color(0xFF4CAF50), // Medium green
              Color(0xFF8BC34A), // Light green
              Color(0xFFA1887F), // Brown accent (matching iOS)
            ],
            stops: [0.0, 0.4, 0.8, 1.0],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // MARK: - App Logo
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.map_outlined,
                size: 60,
                color: Color(0xFF2E7D32),
              ),
            ),
            
            SizedBox(height: 24),
            
            // MARK: - App Title
            Text(
              'DriveLess',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            
            SizedBox(height: 8),
            
            // MARK: - Tagline
            Text(
              'Drive Less, Save Time',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
            
            SizedBox(height: 48),
            
            // MARK: - Loading Indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}