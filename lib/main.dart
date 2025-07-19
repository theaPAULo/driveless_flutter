import 'package:flutter/material.dart';
// Import our custom loading screen
import 'screens/loading_screen.dart';

void main() {
  runApp(const DriveLessApp());
}

class DriveLessApp extends StatelessWidget {
  const DriveLessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveLess',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32), // Forest green from iOS
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ContentView(), // Main app controller (like iOS ContentView)
    );
  }
}

/// ContentView - Main app flow controller matching iOS structure
/// 
/// Manages the app flow exactly like iOS:
/// 1. Show LoadingScreenView first
/// 2. After loading -> check authentication
/// 3. Show appropriate screen based on auth state
class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  // Loading screen state (matching iOS)
  bool _showLoadingScreen = true;
  
  // Authentication state (will be managed by Firebase later)
  bool _isSignedIn = false; // Currently false, will connect to Firebase auth
  
  @override
  Widget build(BuildContext context) {
    // Main app flow logic (matching iOS ContentView)
    if (_showLoadingScreen) {
      // Show loading screen first
      return LoadingScreenView(
        onAnimationComplete: () {
          // Callback when loading animation completes (matching iOS)
          setState(() {
            _showLoadingScreen = false;
          });
        },
      );
    } else if (_isSignedIn) {
      // User is signed in - show main app (will implement MainTabView next)
      return const MainAppView();
    } else {
      // User is not signed in - show sign-in screen (will implement next)
      return const UltraCompactSignInView();
    }
  }
}

/// MainAppView - Placeholder for the main app (will become MainTabView)
/// 
/// This will be replaced with the full MainTabView in the next step
class MainAppView extends StatelessWidget {
  const MainAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'Main App View',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'MainTabView will go here',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// UltraCompactSignInView - Placeholder for sign-in screen
/// 
/// This will be replaced with Firebase authentication in the next step
class UltraCompactSignInView extends StatelessWidget {
  const UltraCompactSignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Matching the forest green gradient from iOS
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF224B22), // Deep forest
              Color(0xFF2E7D32), // Primary green
              Color(0xFF66523D), // Brown accent
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Matching iOS hero section
              Icon(
                Icons.map_rounded,
                size: 50,
                color: Colors.white,
              ),
              SizedBox(height: 8),
              Text(
                'DriveLess',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Drive Less, Save Time',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Sign-in functionality coming next...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}